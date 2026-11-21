#!/usr/bin/env python3
"""Prepare the SC-02 light and FU-01 map stool in the home camera."""

import argparse
import hashlib
import json
import sys
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / "apps/mobile/assets/art"
WIND = ROOT / "design/production/wind/room"
SIZE = (1536, 1024)
LIGHT = (136, 704, 1068, 968)
WINDOW = (218, 200, 1472, 592)
STOOL_FRAME = (712, 647, 879, 808)
SOURCE_STOOL_FRAME = (1040, 610, 1420, 975)
STOOL_PREFIX = "draft_veranda_map_stool__"

sys.dont_write_bytecode = True
sys.path.insert(0, str(WIND))
from export_layers import composite, read_layers


def rgba(path):
    with Image.open(path) as image:
        if image.size != SIZE:
            raise ValueError(f"Unexpected reading room camera: {path}")
        return image.convert("RGBA")


def byte_hash(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def export(name, image, crop, records, sources, size=None):
    bounds = image.getchannel("A").getbbox()
    if bounds is None or not (
        crop[0] <= bounds[0] <= bounds[2] <= crop[2]
        and crop[1] <= bounds[1] <= bounds[3] <= crop[3]
    ):
        raise ValueError(f"Export would clip {name}: {bounds} outside {crop}")
    tile = image.crop(crop)
    if size is not None:
        tile = tile.resize(size, Image.Resampling.LANCZOS)
    if tile.getchannel("A").getextrema() == (255, 255):
        tile = tile.convert("RGB")
    target = ART / f"reading-veranda-{name}.webp"
    tile.save(target, lossless=True, exact=True)
    records.append({
        "runtime_path": target.relative_to(ROOT).as_posix(),
        "runtime_size": list(tile.size),
        "crop_on_master": list(crop),
        "sha256": byte_hash(target),
        "sources": [{"file": source.name, "sha256": byte_hash(source)} for source in sources],
    })


def inverse_perspective(matrix):
    ((a, b, c), (d, e, f), (g, h, i)) = matrix
    adjugate = (
        e * i - f * h, c * h - b * i, b * f - c * e,
        f * g - d * i, a * i - c * g, c * d - a * f,
        d * h - e * g, b * g - a * h, a * e - b * d,
    )
    return tuple(value / adjugate[8] for value in adjugate[:8])


def stained_light(gold, glass, matrix):
    warped = glass.transform(
        SIZE, Image.Transform.PERSPECTIVE,
        inverse_perspective(matrix), Image.Resampling.BICUBIC,
    )
    red, green, _, glass_alpha = warped.split()
    cool = ImageChops.multiply(
        ImageChops.subtract(green, red).point(lambda value: min(218, value * 4)),
        glass_alpha,
    )
    r, g, b, alpha = gold.split()
    green_light = Image.merge("RGB", (
        r.point(lambda value: round(value * .63)),
        g.point(lambda value: min(255, round(value * 1.09))),
        b.point(lambda value: min(255, round(value * 1.87 + 34))),
    ))
    filtered = Image.composite(green_light, gold.convert("RGB"), cool)
    filtered.putalpha(alpha)
    return filtered


def export_room(scene, records):
    unlit = scene / "all-floor-projections-off.png"
    layer_paths = sorted((scene / "layers").glob("*__light-P-L*.png"))
    if len(layer_paths) != 12:
        raise ValueError("SC-02 requires its twelve registered left-window projections")
    floor = Image.new("RGBA", SIZE)
    for path in layer_paths:
        floor.alpha_composite(rgba(path))
    room = rgba(unlit)
    assembled = rgba(scene / "assembled-empty-scene.png")
    if Image.alpha_composite(room, floor).tobytes() != assembled.tobytes():
        raise ValueError("The twelve lights fail to reconstruct the SC-02 handoff")

    home = WIND / "home-restoration.ora"
    size, old = read_layers(home)
    if size != SIZE:
        raise ValueError("The existing story window does not share the home scene camera")
    glass = composite(size, old["home-glass"], trim=False).pixels
    repaired = composite(size, old["home-glass"], old["home-bridge"], trim=False).pixels
    mapping = scene / "pane-map.json"
    matrix = json.loads(mapping.read_text())["left_mapping_homography"]
    stained = stained_light(floor, glass, matrix)
    if ImageChops.multiply(stained.getchannel("A"), glass.getchannel("A")).getbbox():
        raise ValueError("Stained light escapes the floor")

    export("room", room, (0, 0, *SIZE), records, [unlit], size=(1152, 768))
    export("gold-light", floor, LIGHT, records, layer_paths)
    export("stained-light", stained, LIGHT, records, [*layer_paths, mapping, home])
    export("restored-windows", repaired, WINDOW, records, [home])


def export_stool(handoff, records):
    def source(part):
        return handoff / f"{STOOL_PREFIX}scene-{part}.png"

    def placed(image):
        left, top, right, bottom = SOURCE_STOOL_FRAME
        x0, y0, x1, y1 = image.getchannel("A").getbbox()
        if not (left <= x0 <= x1 <= right and top <= y0 <= y1 <= bottom):
            raise ValueError("The new stool placement clips source pixels")
        x, y, right, bottom = STOOL_FRAME
        moved = Image.new("RGBA", SIZE)
        moved.alpha_composite(
            image.crop(SOURCE_STOOL_FRAME).resize((right - x, bottom - y), Image.Resampling.LANCZOS),
            (x, y),
        )
        return moved

    stool = rgba(source("stool"))
    warm_wood = ImageEnhance.Brightness(stool.convert("RGB")).enhance(.88)
    warm_wood.putalpha(stool.getchannel("A"))
    shadow = placed(rgba(source("floor-shadow")))
    contact = Image.new("RGBA", SIZE)
    brush = ImageDraw.Draw(contact)
    for x, y in ((744, 776), (828, 795), (858, 751)):
        brush.ellipse((x - 5, y - 1, x + 5, y + 2), fill=(72, 42, 23, 110))
    shadow.alpha_composite(contact.filter(ImageFilter.GaussianBlur(1.5)))
    scroll = rgba(source("scroll-contact"))
    scroll.alpha_composite(rgba(source("scroll")))
    export("stool-shadow", shadow, STOOL_FRAME, records, [source("floor-shadow")])
    export("stool", placed(warm_wood), STOOL_FRAME, records, [source("stool")])
    export("rolled-map", placed(scroll), STOOL_FRAME, records, [source("scroll-contact"), source("scroll")])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("scene", type=Path, help="SC-02 production-v3 directory")
    parser.add_argument("stool", type=Path, help="FU-01 processed-v4 directory")
    args = parser.parse_args()
    records = []
    export_room(args.scene, records)
    export_stool(args.stool, records)
    print(json.dumps({
        "work_orders": ["SC-02", "FU-01"],
        "source_revisions": {
            "SC-02": "r02-openai/production-v3",
            "FU-01": "r02-openai/processed-v4",
        },
        "master_size": SIZE,
        "device_qa": "pending",
        "assets": records,
    }, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
