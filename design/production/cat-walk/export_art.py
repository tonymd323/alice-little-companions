"""Rasterize the stage-one Tuantuan drawings and build the editable contact proof.

Run from any directory with Inkscape and Pillow installed:
  python3 design/production/cat-walk/export_art.py
"""
from __future__ import annotations

import hashlib
import io
import json
import math
import random
import subprocess
import tempfile
import xml.etree.ElementTree as ET
import zipfile
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

SOURCE = Path(__file__).resolve().parent
ROOT = SOURCE.parents[2]
ASSETS = ROOT / "apps/mobile/assets/cat_walk"
SPEC = json.loads((SOURCE / "poses.json").read_text())
CANVAS = tuple(SPEC["canvas"])
PAW_NAMES = tuple(row["id"] for row in SPEC["limbs"])
ARTWORK = {
    "body.svg": [
        "tail", "head", "torso", "coat", "apron", "trim-coat", "trim-apron",
        "torso-front", "coat-front", "apron-front",
        "torso-away", "coat-away", "apron-away",
    ],
    "turn-heads.svg": ["head-front", "head-away"],
    "legs.svg": [f"leg-{paw}-{part}" for paw in PAW_NAMES for part in ("upper", "lower")],
    "paws.svg": [f"paw-{paw}" for paw in PAW_NAMES],
}


def load_drawings() -> dict[str, Image.Image]:
    drawings = {}
    with tempfile.TemporaryDirectory(prefix="alice-cat-parts-") as tmp:
        for source, layers in ARTWORK.items():
            for layer in layers:
                png = Path(tmp) / f"{layer}.png"
                subprocess.run(
                    ["inkscape", str(SOURCE / source), "--export-area-page",
                     f"--export-id={layer}", "--export-id-only", f"--export-filename={png}"],
                    stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True,
                )
                drawing = Image.open(png).convert("RGBA")
                if drawing.getbbox() is None:
                    raise ValueError(f"Empty layer: {layer}")
                drawings[layer] = drawing if layer == "head" else paper_pigment(drawing)
    return drawings


def paper_pigment(image: Image.Image) -> Image.Image:
    """Fine white fibers and slow pigment blooms within the original brush masks."""
    random_source = random.Random(215791)
    fiber = Image.frombytes(
        "L", image.size,
        bytes(max(0, min(255, int(random_source.gauss(128, 24))))
              for _ in range(image.width * image.height)),
    ).filter(ImageFilter.GaussianBlur(.47))
    patches = Image.frombytes(
        "L", (28, 26), bytes(random_source.randrange(95, 162) for _ in range(28 * 26))
    ).resize(image.size, Image.Resampling.BICUBIC)
    grain = Image.blend(fiber, patches, .28)
    channels = [
        Image.blend(channel, ImageChops.add(channel, grain, offset=-128), .46)
        for channel in image.split()[:3]
    ]
    return Image.merge("RGBA", (*channels, image.getchannel("A")))


def png_bytes(image: Image.Image) -> bytes:
    stream = io.BytesIO()
    image.save(stream, "PNG")
    return stream.getvalue()


def export_sprites(drawings: dict[str, Image.Image]) -> int:
    ASSETS.mkdir(parents=True, exist_ok=True)
    sprites = {
        name: drawing for name, drawing in drawings.items()
        if not name.startswith(("coat", "apron"))
    }
    for direction in ("", "-front", "-away"):
        for garment in ("coat", "apron"):
            sprites[f"torso{direction}-{garment}"] = Image.alpha_composite(
                drawings[f"torso{direction}"], drawings[f"{garment}{direction}"],
            )
    for name, drawing in sprites.items():
        drawing.save(ASSETS / f"{name}.webp", "WEBP", lossless=True, method=6)
    return len(sprites)


def moved(image: Image.Image, dx: float, dy: float) -> Image.Image:
    return image.transform(CANVAS, Image.Transform.AFFINE,
                           (1, 0, -dx, 0, 1, -dy), Image.Resampling.BICUBIC)


def leg_segment(image: Image.Image, start: tuple, end: tuple) -> Image.Image:
    # Source y=32 and y=128 attach to the two given joints. Keep the painted
    # width of the leg while rotating and advancing the segment along its axis.
    dx, dy = end[0] - start[0], end[1] - start[1]
    distance = math.hypot(dx, dy)
    sine, cosine = dx / distance, dy / distance
    x, y = start
    scale = 96 / distance
    return image.transform(
        CANVAS, Image.Transform.AFFINE,
        (cosine, -sine, 64 - x * cosine + y * sine,
         sine * scale, cosine * scale, 32 - (x * sine + y * cosine) * scale),
        Image.Resampling.BICUBIC,
    )


def standing_marks() -> list[tuple]:
    return [tuple(row["pad"]) for row in SPEC["limbs"]]


def step_marks(phase: float) -> tuple[list[tuple], list[bool]]:
    feet, support = [], []
    stride = SPEC["cycle"]["stride"]
    for i, (x, y) in enumerate(standing_marks()):
        elapsed = (phase - i / 4) % 1
        planted = elapsed <= .75
        if planted:
            dx, lift = stride * (.375 - elapsed), 0
        else:
            swing = (elapsed - .75) / .25
            release = swing * swing * (3 - 2 * swing)
            dx = stride * (.375 + release - elapsed)
            lift = (24 if i % 2 == 0 else 30) * math.sin(math.pi * swing)
        feet.append((x + dx, y - lift))
        support.append(planted)
    return feet, support


def compose_layers(
    drawings: dict[str, Image.Image], pose: dict, feet: list[tuple], outfit: str = "",
    direction: str = "",
) -> list[tuple[str, Image.Image]]:
    placement = {}
    hips_and_pads = SPEC["directions"].get(direction)
    for index, (row, pad) in enumerate(zip(SPEC["limbs"], feet)):
        name = row["id"]
        hips = pose["hip"] if name.endswith("hind") else pose["shoulder"]
        x, y = hips_and_pads[index]["hip"] if hips_and_pads else row["hip"]
        hip = x + hips[0], y + hips[1]
        wrist = pad[0], pad[1] - 29
        bend_x = 15 if name.endswith("hind") else -13
        bend = (hip[0] + wrist[0]) / 2 + bend_x, (hip[1] + wrist[1]) / 2
        placement[name] = [
            (f"{name} / 下段", leg_segment(drawings[f"leg-{name}-lower"], bend, wrist)),
            (f"{name} / 上段", leg_segment(drawings[f"leg-{name}-upper"], hip, bend)),
            (f"{name} / 掌垫", moved(drawings[f"paw-{name}"], pad[0] - 64, pad[1] - 84)),
        ]
    offsets = pose["body"]
    if direction:
        torso_name = f"torso-{direction}"
        tail_dx = 124 if direction == "front" else 112
        layers = [("卷尾", moved(drawings["tail"], tail_dx, 8))]
        back, front = (
            (("near-hind", "far-hind"), ("near-front", "far-front"))
            if direction == "front" else
            (("near-front", "far-front"), ("near-hind", "far-hind"))
        )
        for name in back:
            layers.extend(placement[name])
        layers.append(("蓝灰躯干", moved(drawings[torso_name], *offsets)))
        if outfit:
            layers.append(("衣料", moved(drawings[f"{outfit}-{direction}"], *offsets)))
        for name in front:
            layers.extend(placement[name])
        layers.append(("头与胸前毛缘", moved(drawings[f"head-{direction}"], *pose["head"])))
        return layers

    layers = [("卷尾", moved(drawings["tail"], *pose["hip"]))]
    for name in ("far-hind", "far-front"):
        layers.extend(placement[name])
    layers.append(("蓝灰躯干", moved(drawings["torso"], *offsets)))
    if outfit:
        layers.append(("衣料", moved(drawings[outfit], *offsets)))
    for name in ("near-hind", "near-front"):
        layers.extend(placement[name])
    if outfit:
        layers.append(("前层袖口", moved(drawings[f"trim-{outfit}"], *pose["shoulder"])))
    layers.append(("头与胸前毛缘", moved(drawings["head"], *pose["head"])))
    return layers


def direction_marks(direction: str) -> list[tuple]:
    return [tuple(row["pad"]) for row in SPEC["directions"][direction]]


def transition_marks(pose: dict) -> list[tuple]:
    return [
        (x + delta[0], y + delta[1])
        for (x, y), delta in zip(standing_marks(), pose["feet"])
    ]


def flatten(layers: list[tuple[str, Image.Image]]) -> Image.Image:
    composite = Image.new("RGBA", CANVAS)
    for _, image in layers:
        composite.alpha_composite(image)
    return composite


def export_ora(drawings: dict[str, Image.Image]) -> None:
    root = ET.Element("image", {
        "version": "0.0.3", "w": str(CANVAS[0]), "h": str(CANVAS[1]), "name": "团团一阶 · 步态",
    })
    stack = ET.SubElement(root, "stack")
    stand = SPEC["transitions"]["stand"]
    default = compose_layers(drawings, stand, standing_marks())
    with zipfile.ZipFile(SOURCE / "tuantuan-walk.ora", "w", zipfile.ZIP_DEFLATED) as project:
        project.writestr("mimetype", "image/openraster", compress_type=zipfile.ZIP_STORED)
        groups = [
            ("侧面站姿 · 原装", default),
            ("侧面站姿 · 外套", compose_layers(drawings, stand, standing_marks(), "coat")),
            ("侧面站姿 · 围裙", compose_layers(drawings, stand, standing_marks(), "apron")),
            ("正向换身", compose_layers(drawings, stand, direction_marks("front"), "coat", "front")),
            ("背向入庭", compose_layers(drawings, stand, direction_marks("away"), "apron", "away")),
        ]
        for key, title in [("pushUp", "撑起"), ("sitBack", "收步回坐")]:
            pose = SPEC["transitions"][key]
            groups.append((title, compose_layers(drawings, pose, transition_marks(pose))))
        for i, pose in enumerate(SPEC["cycle"]["keyPoses"], 1):
            feet, _ = step_marks(pose["phase"])
            groups.append((f"第 {i} 姿 · {pose['label']}", compose_layers(drawings, pose, feet)))

        layer_hashes = {}
        for group_i, (name, layers) in enumerate(groups):
            attrs = {"name": name, "opacity": "1", "composite-op": "svg:src-over",
                     "isolation": "isolate", "visibility": "visible" if group_i == 0 else "hidden"}
            group = ET.SubElement(stack, "stack", attrs)
            for layer_i, (label, layer) in enumerate(reversed(layers)):
                x, y, right, bottom = layer.getbbox()
                data = png_bytes(layer.crop((x, y, right, bottom)))
                digest = hashlib.sha256(data).digest()
                path = layer_hashes.get(digest)
                if path is None:
                    path = f"data/{group_i}-{layer_i}.png"
                    layer_hashes[digest] = path
                    project.writestr(path, data)
                ET.SubElement(group, "layer", {
                    "name": label, "src": path, "x": str(x), "y": str(y),
                    "opacity": "1", "visibility": "visible", "composite-op": "svg:src-over",
                })
        project.writestr("stack.xml", ET.tostring(root, encoding="utf-8", xml_declaration=True))
        image = flatten(default)
        project.writestr("mergedimage.png", png_bytes(image))
        image.thumbnail((256, 256))
        project.writestr("Thumbnails/thumbnail.png", png_bytes(image))


def export_contact_sheet(drawings: dict[str, Image.Image]) -> None:
    stand = SPEC["transitions"]["stand"]
    sheet = Image.new("RGB", (1280, 1034), "#e9eadd")
    ink = ImageDraw.Draw(sheet)
    title = ImageFont.load_default(size=23)
    small = ImageFont.load_default(size=15)
    ink.text((24, 15), "TUANTUAN / STAGE 1     SKIN, COSTUMES & WALK CONTACTS", font=title, fill="#33384b")

    def tile(column: int, row: int, frame: Image.Image, label: str) -> None:
        x, y = column * 320, 46 + row * 246
        panel_color = "#e8e3d3" if (row + column) % 2 == 0 else "#b3bdb3"
        ink.rounded_rectangle((x + 7, y + 6, x + 311, y + 238), radius=8, fill=panel_color)
        image = frame.resize((240, 217), Image.Resampling.LANCZOS)
        sheet.paste(image, (x + 40, y + 16), image)
        ink.text((x + 18, y + 10), label, font=small, fill="#383d52")

    original = Image.open(SOURCE / "face-source.png").convert("RGBA")
    old = Image.new("RGBA", CANVAS)
    old.alpha_composite(original, (67, 0))
    tile(0, 0, old, "Original sit")
    for col, outfit in enumerate(("", "coat", "apron"), start=1):
        frame = flatten(compose_layers(drawings, stand, standing_marks(), outfit))
        tile(col, 0, frame, outfit.capitalize() or "Stand")

    for i, pose in enumerate(SPEC["cycle"]["keyPoses"]):
        feet, support = step_marks(pose["phase"])
        frame = flatten(compose_layers(drawings, pose, feet))
        marks = ImageDraw.Draw(frame)
        for foot, planted in zip(feet, support):
            x, y = foot
            color = "#477d60" if planted else "#aa6040"
            if planted:
                marks.ellipse((x - 6, y - 6, x + 6, y + 6), fill=color)
            else:
                marks.ellipse((x - 6, y - 6, x + 6, y + 6), outline=color, width=2)
        tile(i % 4, 1 + i // 4, frame, f"{i + 1}  {pose['label']}")

    for col, direction in enumerate(("front", "away"), start=1):
        layers = compose_layers(drawings, stand, direction_marks(direction), "coat", direction)
        tile(col, 3, flatten(layers), "Face through turn" if direction == "front" else "Look into clearing")
    first = SPEC["transitions"]["pushUp"]
    last = SPEC["transitions"]["sitBack"]
    for col, pose, label in [(0, first, "Push up"), (3, last, "Settle")]:
        feet = transition_marks(pose)
        tile(col, 3, flatten(compose_layers(drawings, pose, feet)), label)
    sheet.save(SOURCE / "contact-sheet.jpg", "JPEG", quality=91, optimize=True)


def main() -> None:
    drawings = load_drawings()
    sprites = export_sprites(drawings)
    export_ora(drawings)
    export_contact_sheet(drawings)
    print(f"{sprites} lossless WebP layers, one OpenRaster original and one pose sheet")


if __name__ == "__main__":
    main()
