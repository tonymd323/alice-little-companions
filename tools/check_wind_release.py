#!/usr/bin/env python3
"""Verify the packaged Wind Through the Veranda art, layout and PCM cues against this checkout."""

import argparse
import hashlib
import io
import json
import math
import re
import sys
import wave
import zipfile
from pathlib import Path
from xml.etree import ElementTree

from PIL import Image


BUNDLE = "assets/flutter_assets/"
WIND = "assets/wind/"


def require(condition, message):
    if not condition:
        raise ValueError(message)


def match(actual, expected, label):
    missing = sorted(expected - actual)
    extra = sorted(actual - expected)
    require(not missing and not extra, f"{label}: missing {missing}, unexpected {extra}")


def declared_names(file, pattern, names):
    source = file.read_text(encoding="utf-8")
    body = re.search(pattern, source, re.DOTALL)
    require(body, f"Could not find the runtime asset declaration in {file}")
    return re.findall(names, body.group(1))


def inventory(apk, mobile):
    prefix = BUNDLE + WIND
    source = {p.relative_to(mobile).as_posix(): p for p in (mobile / WIND).rglob("*") if p.is_file()}
    data = {}
    with zipfile.ZipFile(apk) as archive:
        archive.getinfo("AndroidManifest.xml")
        archive.getinfo(BUNDLE + "AssetManifest.bin")
        paths = [item.filename[len(BUNDLE):] for item in archive.infolist()
                 if item.filename.startswith(prefix) and not item.is_dir()]
        require(len(paths) == len(set(paths)), "Duplicate ZIP entries under assets/wind")
        match(set(paths), set(source), "Packaged wind files")
        for path in sorted(paths):
            payload = archive.read(BUNDLE + path)
            require(payload == source[path].read_bytes(), f"{path}: APK differs from checkout")
            data[path] = payload
    return data


def size(value, label):
    require(isinstance(value, list) and len(value) == 2
            and all(type(v) is int and v > 0 for v in value), f"{label}: invalid pixel size {value}")
    return tuple(value)


def normalized(value, count, label):
    require(isinstance(value, list) and len(value) == count
            and all(type(v) in (int, float) and math.isfinite(v) and 0 <= v <= 1 for v in value),
            f"{label}: invalid normalized coordinates {value}")
    return tuple(value)


def check_picture(data, path, dimensions, transparent=True):
    with Image.open(io.BytesIO(data[path])) as picture:
        require(picture.format == "WEBP" and picture.n_frames == 1, f"{path}: expected one WebP image")
        require(picture.size == dimensions, f"{path}: expected {dimensions}, found {picture.size}")
        picture.load()
        if transparent:
            require("A" in picture.getbands(), f"{path}: missing alpha channel")
            alpha = picture.getchannel("A")
            levels = alpha.histogram()
            require(levels[0] and levels[255] and sum(levels[1:255]),
                    f"{path}: expected transparent edges, opaque paint and antialiasing")
            return alpha
        if "A" in picture.getbands():
            require(picture.getchannel("A").getextrema() == (255, 255), f"{path}: background has holes")
    return None


def paintings(data, group):
    prefix = WIND + group + "/"
    return {p for p in data if p.startswith(prefix) and p.endswith(".webp")}


def check_actors(data, mobile):
    prefix = WIND + "actors/"
    poses = json.loads(data[prefix + "poses.json"])
    actors, props = poses["actors"], poses["props"]
    require(len(actors) >= 22 and len(props) == 3, "Expected at least 22 actor poses and three prop drawings")
    names = declared_names(mobile / "lib/illustration/wind_stage_art.dart",
                           r"\b_sprites\s*=\s*\[([^\]]+)\]", r"""['"]([\w-]+)['"]""")
    require(len(names) == len(set(names)), "Duplicate sprite names in the Flutter loader")
    match(set(names), set(actors) | set(props), "Flutter sprites versus pose metadata")
    expected = {prefix + name + ".webp" for name in names}
    match(paintings(data, "actors"), expected, "Actor WebPs")
    require(len({data[p] for p in expected}) == len(expected), "Two actor or prop exports are identical")
    canvas = size(poses["canvas"], "Actor canvas")
    for name in names:
        dimensions = size(props[name]["size"], name) if name in props else canvas
        check_picture(data, prefix + name + ".webp", dimensions)
    return len(expected)


def check_room(data, mobile):
    room = json.loads(data[WIND + "room/room.json"])
    canvas = size(room["size"], "Stage camera")
    require(canvas[0] * 4 == canvas[1] * 3, "Expected a 3:4 stage camera")
    patches = room["cells"]
    lights = room["lights"]
    require([(p["window"], p["cell"]) for p in patches] ==
            [(window, cell) for window in range(3) for cell in range(4)],
            "The Flutter stage requires twelve ordered, unique window/cell pairs")
    require([p["window"] for p in lights] == list(range(3)), "Expected one ordered light per window")
    home = room["home"]
    home_size = size(home["size"], "Home camera")
    with Image.open(mobile / "assets/art/veranda.webp") as veranda:
        require(home_size == veranda.size, "Home restoration does not match the veranda camera")
    for full in (room["base"], home):
        require(full["rect"] == [0, 0, 1, 1], f"{full['path']}: expected a full-camera painting")
    entries = [room["base"], *patches, *lights, room["rail"], home]
    paths = {p["path"] for p in entries}
    require(len(paths) == 18, "Expected eighteen independently addressable room WebPs")
    match(paintings(data, "room"), paths, "Room WebPs")
    for part in entries:
        path = part["path"]
        rect = normalized(part["rect"], 4, path)
        camera = home_size if part is home else canvas
        x, y, right, bottom = [round(v * length) for v, length in zip(rect, camera * 2)]
        require(x < right and y < bottom, f"{path}: empty rectangle")
        check_picture(data, path, (right - x, bottom - y), transparent=part is not room["base"])

    # Compare every indexed pane directly with its source drawing, including its absolute origin.
    original = mobile.parents[1] / "design/production/wind/room/wind-room.ora"
    with zipfile.ZipFile(original) as package:
        artwork = ElementTree.fromstring(package.read("stack.xml"))
        layers = {p.attrib["name"].split(" · ", 1)[0]: p.attrib for p in artwork.iter("layer")}
        require((int(artwork.attrib["w"]), int(artwork.attrib["h"])) == canvas,
                "Stage camera is inconsistent with its OpenRaster master")
        for pane in patches:
            role = f"glass-{pane['window'] + 1}-{pane['cell'] + 1}"
            require(Path(pane["path"]).stem == role, f"{role}: incorrect painting for this pane")
            layer = layers[role]
            left, top = int(layer["x"]), int(layer["y"])
            with package.open(layer["src"]) as source, Image.open(source) as drawing:
                box = left, top, left + drawing.width, top + drawing.height
            runtime_box = tuple(round(v * length) for v, length in zip(pane["rect"], canvas * 2))
            require(box == runtime_box, f"{role}: rectangle differs from its painted glass opening")
    points = [normalized(p, 2, "Bridge") for p in room["bridge"]]
    require(len(points) >= 2 and all(a[0] < b[0] for a, b in zip(points, points[1:])),
            "Bridge path must run from left to right")
    for key in ("rabbit", "basket", "door"):
        normalized(room["actors"][key], 2, key)
    return len(paths)


def check_wardrobe(data, mobile):
    base = WIND + "wardrobe/"
    expected = {base + pose + "rabbit-3" + clothes + ".webp" for pose in ("", "leap-")
                for clothes in ("", "-apron", "-coat")}
    match(paintings(data, "wardrobe"), expected, "Complete scarf portraits")
    # Fitted full-figure paintings use the canvas and registration of each existing stage-three rig.
    for path in sorted(expected):
        with Image.open(mobile / "assets/art" / Path(path).name) as rig:
            alpha = check_picture(data, path, rig.size)
            worn = alpha.point(lambda a: 255 if a > 12 else 0).getbbox()
            original = rig.getchannel("A").point(lambda a: 255 if a > 12 else 0).getbbox()
            require(original and worn and max(abs(a - b) for a, b in zip(worn, original)) <= .02 * max(rig.size),
                    f"{path}: drawn figure does not fill its original rig")
    return len(expected)


def check_sounds(data, mobile):
    names = declared_names(mobile / "lib/illustration/wind_sound.dart",
                           r"\benum\s+WindCue\s*\{([^}]+)\}", r"\b\w+\b")
    expected = {WIND + "audio/" + name + ".wav" for name in names}
    require(len(expected) == 7, "Expected seven independent WindCue events")
    match({p for p in data if p.startswith(WIND + "audio/")}, expected, "PCM cues")
    for path in sorted(expected):
        with wave.open(io.BytesIO(data[path]), "rb") as cue:
            require((cue.getcomptype(), cue.getnchannels(), cue.getsampwidth(), cue.getframerate())
                    == ("NONE", 2, 2, 32000), f"{path}: expected 32 kHz stereo 16-bit PCM")
            frames = cue.getnframes()
            pcm = cue.readframes(frames)
            require(frames > 0 and len(pcm) == frames * 4 and any(pcm),
                    f"{path}: truncated or silent PCM")
    return len(expected)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("apk", type=Path, help="Flutter release APK")
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1],
                        help="source checkout (defaults to the checkout containing this script)")
    args = parser.parse_args()
    mobile = args.root / "apps/mobile"
    try:
        data = inventory(args.apk, mobile)
        result = {"actor_webp": check_actors(data, mobile), "room_webp": check_room(data, mobile),
                  "wardrobe_webp": check_wardrobe(data, mobile), "pcm_cues": check_sounds(data, mobile)}
        with args.apk.open("rb") as apk:
            digest = hashlib.sha256()
            for block in iter(lambda: apk.read(1 << 20), b""):
                digest.update(block)
        print(json.dumps({"apk_sha256": digest.hexdigest(), "wind_files": len(data),
                          "wind_bytes": sum(map(len, data.values())), **result}, indent=2))
    except (OSError, ValueError, KeyError, TypeError, EOFError, zipfile.BadZipFile,
            wave.Error, ElementTree.ParseError) as error:
        sys.exit(f"Wind release check failed: {error}")


if __name__ == "__main__":
    main()
