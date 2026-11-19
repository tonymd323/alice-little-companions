"""Export the layered first-stage fox drawings with Inkscape and Pillow."""

from __future__ import annotations

import argparse
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
MOBILE = SOURCE.parents[2] / "apps/mobile"
ASSETS = MOBILE / "assets/fox_walk"
SPEC = json.loads((SOURCE / "poses.json").read_text(encoding="utf-8"))
CANVAS = tuple(SPEC["canvas"])
LIMBS = SPEC["limbs"]
BODY_PARTS = ("torso", "coat", "apron")
VIEWS = ("", "-front", "-away")
ARTWORK = {
    "body.svg": ["head", "tail", "trim-coat", "trim-apron", *(
        part + view for view in VIEWS for part in BODY_PARTS
    )],
    "turn-heads.svg": ["head-front", "head-away"],
    "legs.svg": [f"leg-{row['id']}-{part}" for row in LIMBS for part in ("upper", "lower")],
    "paws.svg": [f"paw-{row['id']}" for row in LIMBS],
}
FONT = Path("/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc")


def open_original() -> Image.Image:
    with Image.open(MOBILE / SPEC["head"]["side"]["source"]) as image:
        return image.convert("RGBA")


def paper_pigment(image: Image.Image) -> Image.Image:
    """Carry fine paper and uneven pigment through the painted masks."""
    noise = random.Random(18947)
    fibers = Image.frombytes(
        "L", image.size,
        bytes(max(0, min(255, round(noise.gauss(128, 24)))) for _ in range(math.prod(image.size))),
    ).filter(ImageFilter.GaussianBlur(.52))
    blooms = Image.frombytes("L", (24, 21), bytes(noise.randrange(91, 170) for _ in range(504)))
    grain = Image.blend(fibers, blooms.resize(image.size, Image.Resampling.BICUBIC), .36)
    rgb = [Image.blend(channel, ImageChops.add(channel, grain, offset=-128), .67)
           for channel in image.split()[:3]]
    return Image.merge("RGBA", (*rgb, image.getchannel("A")))


def load_drawings() -> dict[str, Image.Image]:
    drawings = {}
    with tempfile.TemporaryDirectory(prefix="alice-fox-parts-") as tmp:
        for source, names in ARTWORK.items():
            for name in names:
                png = Path(tmp) / f"{name}.png"
                subprocess.run(
                    ["inkscape", str(SOURCE / source), "--export-area-page", f"--export-id={name}",
                     "--export-id-only", f"--export-filename={png}"],
                    stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True,
                )
                with Image.open(png) as opened:
                    drawing = opened.convert("RGBA")
                assert drawing.getchannel("A").getbbox(), f"No pixels in {name}"
                if name.startswith("paw-"):
                    # The painted contact at the pad center is the actual terrain anchor.
                    alpha = drawing.getchannel("A")
                    sole = max(y for y in range(drawing.height) if alpha.getpixel((64, y)) >= 128)
                    drawing = drawing.transform(
                        drawing.size, Image.Transform.AFFINE, (1, 0, 0, 0, 1, sole - 84),
                    )
                drawings[name] = drawing if name in ("head", "tail") else paper_pigment(drawing)
    return drawings


def sprite_bytes(drawings: dict[str, Image.Image]) -> dict[str, bytes]:
    sprites = {name: image for name, image in drawings.items() if not name.startswith(("coat", "apron"))}
    for view in VIEWS:
        for clothing in ("coat", "apron"):
            sprites[f"torso{view}-{clothing}"] = Image.alpha_composite(
                drawings[f"torso{view}"], drawings[f"{clothing}{view}"],
            )
    encoded = {}
    for name, sprite in sprites.items():
        out = io.BytesIO()
        sprite.save(out, "WEBP", lossless=True, method=6)
        encoded[name] = out.getvalue()
    return encoded


def moved(image: Image.Image, dx: float, dy: float) -> Image.Image:
    return image.transform(CANVAS, Image.Transform.AFFINE,
                           (1, 0, -dx, 0, 1, -dy), Image.Resampling.BICUBIC)


def leg_segment(image: Image.Image, start: tuple, end: tuple) -> Image.Image:
    """Painted reference joints sit 96 pixels apart. Keep the brush width."""
    dx, dy = end[0] - start[0], end[1] - start[1]
    distance = max(.01, math.hypot(dx, dy))
    sine, cosine, scale = dx / distance, dy / distance, 96 / distance
    x, y = start
    return image.transform(
        CANVAS, Image.Transform.AFFINE,
        (cosine, -sine, 64 - x * cosine + y * sine,
         sine * scale, cosine * scale, 32 - (x * sine + y * cosine) * scale),
        Image.Resampling.BICUBIC,
    )


def standing_marks(direction: str = "") -> list[tuple]:
    rows = SPEC["directions"].get(direction, LIMBS)
    return [tuple(row["pad"]) for row in rows]


def step_marks(phase: float) -> tuple[list[tuple], list[bool]]:
    paws, support = [], []
    stride = SPEC["cycle"]["stride"]
    stance = SPEC["cycle"]["support"]
    for i, (x, y) in enumerate(standing_marks()):
        since_contact = (phase - i / 4) % 1
        planted = since_contact <= stance
        swing = max(0.0, (since_contact - stance) / (1 - stance))
        traverse = swing * swing * (3 - 2 * swing)
        height = (25 if i % 2 == 0 else 33) * math.sin(math.pi * swing)
        paws.append((x + stride * (stance / 2 - since_contact + traverse), y - height))
        support.append(planted)
    return paws, support


def compose_layers(
    drawings: dict[str, Image.Image],
    pose: dict,
    paws: list[tuple],
    outfit: str = "",
    direction: str = "",
) -> list[tuple[str, Image.Image]]:
    placement = {}
    joints = SPEC["directions"].get(direction, LIMBS)
    for index, (row, pad) in enumerate(zip(LIMBS, paws)):
        name = row["id"]
        hip_shift = pose["hip"] if name.endswith("hind") else pose["shoulder"]
        hip = tuple(a + b for a, b in zip(joints[index]["hip"], hip_shift))
        wrist = pad[0], pad[1] - 29
        ref_wrist = row["pad"][0], row["pad"][1] - 29
        knee_bias = [row["bend"][axis] - (row["hip"][axis] + ref_wrist[axis]) / 2 for axis in (0, 1)]
        if direction:
            knee_bias[0] *= .43
        knee = tuple((a + b) / 2 + c for a, b, c in zip(hip, wrist, knee_bias))
        placement[name] = [
            (f"{name} · 上段", leg_segment(drawings[f"leg-{name}-upper"], hip, knee)),
            (f"{name} · 下段", leg_segment(drawings[f"leg-{name}-lower"], knee, wrist)),
            (f"{name} · 掌垫", moved(drawings[f"paw-{name}"], pad[0] - 64, pad[1] - 84)),
        ]

    if direction == "front":
        back = ("near-hind", "far-hind")
        tail_dx = 100
    elif direction == "away":
        back = ("near-front", "far-front")
        tail_dx = 130
    else:
        back = ("far-hind", "far-front")
        tail_dx = 0
    view = f"-{direction}" if direction else ""
    tail = drawings["tail"].rotate(-pose["tailDegrees"], Image.Resampling.BICUBIC, center=tuple(SPEC["tailPivot"]))
    layers = [("奶油尾尖与栗色尾巴", moved(tail, pose["hip"][0] + tail_dx, pose["hip"][1]))]
    for name in back:
        layers.extend(placement[name])
    layers.append(("躯干和胸毛", moved(drawings[f"torso{view}"], *pose["body"])))
    if outfit:
        layers.append(("衣料", moved(drawings[f"{outfit}{view}"], *pose["body"])))
    for row in LIMBS:
        if row["id"] not in back:
            layers.extend(placement[row["id"]])
    if outfit and not direction:
        layers.append(("前层袖口", moved(drawings[f"trim-{outfit}"], *pose["shoulder"])))
    layers.append(("眼耳、额纹与颈毛", moved(drawings[f"head{view}"], *pose["head"])))
    return layers


def flatten(layers: list[tuple[str, Image.Image]]) -> Image.Image:
    result = Image.new("RGBA", CANVAS)
    for _, image in layers:
        result.alpha_composite(image)
    return result


def blend_marks(progress: float) -> list[tuple]:
    return [
        tuple(seated + (standing - seated) * progress for seated, standing in zip(row["seatedPad"], row["pad"]))
        for row in LIMBS
    ]


def seated_drawing() -> Image.Image:
    sprite = open_original()
    scale = SPEC["root"][1] / SPEC["seatedArtHeight"]
    sprite = sprite.resize((round(sprite.width * scale), SPEC["root"][1]), Image.Resampling.LANCZOS)
    result = Image.new("RGBA", CANVAS)
    result.alpha_composite(sprite, ((result.width - sprite.width) // 2, 0))
    return result


def groups(drawings: dict[str, Image.Image]) -> list[tuple]:
    stand = SPEC["transitions"]["stand"]
    poses = [
        ("侧面站姿", compose_layers(drawings, stand, standing_marks()), standing_marks(), None),
        ("侧面外套", compose_layers(drawings, stand, standing_marks(), "coat"), None, None),
        ("侧面围裙", compose_layers(drawings, stand, standing_marks(), "apron"), None, None),
        ("正向换身", compose_layers(drawings, stand, standing_marks("front"), "coat", "front"), None, None),
        ("背向入庭", compose_layers(drawings, stand, standing_marks("away"), "apron", "away"), None, None),
    ]
    for key, title, shift in [("pushUp", "撑起", .25), ("sitBack", "收步回坐", .49)]:
        paws = blend_marks(shift)
        poses.append((title, compose_layers(drawings, SPEC["transitions"][key], paws), paws, None))
    for pose in SPEC["cycle"]["keyPoses"]:
        paws, support = step_marks(pose["phase"])
        poses.append((pose["label"], compose_layers(drawings, pose, paws), paws, support))
    return poses


def png_bytes(image: Image.Image) -> bytes:
    out = io.BytesIO()
    image.save(out, "PNG")
    return out.getvalue()


def write_ora(poses: list[tuple]) -> None:
    root = ET.Element("image", {"version": "0.0.3", "w": "512", "h": "464", "name": "奶油一阶 · 步态"})
    stack = ET.SubElement(root, "stack")
    with zipfile.ZipFile(SOURCE / "naiyou-walk.ora", "w", zipfile.ZIP_DEFLATED) as archive:
        archive.writestr("mimetype", "image/openraster", compress_type=zipfile.ZIP_STORED)
        layers_by_digest = {}
        for index, (title, layers, _, _) in enumerate(poses):
            group = ET.SubElement(stack, "stack", {"name": title, "visibility": "visible" if index == 0 else "hidden",
                                                  "opacity": "1", "composite-op": "svg:src-over"})
            for label, image in reversed(layers):
                data = png_bytes(image)
                digest = hashlib.sha256(data).hexdigest()
                if digest not in layers_by_digest:
                    path = f"data/layer-{len(layers_by_digest):03d}.png"
                    archive.writestr(path, data)
                    layers_by_digest[digest] = path
                ET.SubElement(group, "layer", {"name": label, "src": layers_by_digest[digest], "x": "0", "y": "0",
                                               "opacity": "1", "visibility": "visible", "composite-op": "svg:src-over"})
        archive.writestr("stack.xml", ET.tostring(root, encoding="utf-8", xml_declaration=True))
        default = flatten(poses[0][1])
        archive.writestr("mergedimage.png", png_bytes(default))
        default.thumbnail((256, 256), Image.Resampling.LANCZOS)
        archive.writestr("Thumbnails/thumbnail.png", png_bytes(default))


def write_contact_sheet(poses: list[tuple]) -> None:
    panel = 300, 248
    sheet = Image.new("RGB", (panel[0] * 4, panel[1] * 4 + 47), "#f1eddf")
    draw = ImageDraw.Draw(sheet)
    title_font = ImageFont.truetype(str(FONT), 26)
    label_font = ImageFont.truetype(str(FONT), 15)
    draw.text((14, 8), "奶油 · 第一阶段 · 爪掌与原画", font=title_font, fill="#4c3423")
    all_poses = [("C 版坐姿", [("坐姿", seated_drawing())], None, None), *poses]
    for index, (title, layers, paws, support) in enumerate(all_poses):
        x, y = index % 4 * panel[0], index // 4 * panel[1] + 47
        draw.rounded_rectangle((x + 5, y, x + 294, y + 242), radius=12, fill=("#d7dfce" if index % 2 else "#e8ddce"))
        draw.text((x + 15, y + 8), title, font=label_font, fill="#4c3423")
        sprite = flatten(layers)
        sprite.thumbnail((244, 205), Image.Resampling.LANCZOS)
        sx, sy = x + 37, y + 29
        sheet.paste(sprite, (sx, sy), sprite)
        if paws:
            for i, (px, py) in enumerate(paws):
                dx, dy = sx + px * sprite.width / 512, sy + py * sprite.height / 464
                planted = support is None or support[i]
                circle = (dx - 3, dy - 3, dx + 3, dy + 3)
                draw.ellipse(circle, fill="#35634b" if planted else None, outline="#35634b" if planted else "#bd6536", width=2)
    sheet.save(SOURCE / "contact-sheet.jpg", quality=94, optimize=True)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Compare the runtime drawings with the sources.")
    parser.add_argument("--sprites-only", action="store_true", help="Skip the contact sheet and layered proof.")
    args = parser.parse_args()
    reference = SOURCE / "face-source.png"
    original = open_original()
    if args.check:
        with Image.open(reference) as stored:
            if stored.convert("RGBA").tobytes() != original.tobytes():
                raise SystemExit("C portrait source differed")
    else:
        original.save(reference)
    drawings = load_drawings()
    if not args.check:
        ASSETS.mkdir(parents=True, exist_ok=True)
    sprites = sprite_bytes(drawings)
    for name, data in sprites.items():
        output = ASSETS / f"{name}.webp"
        if args.check:
            if output.read_bytes() != data:
                raise SystemExit(f"Runtime export differed for {name}")
        else:
            output.write_bytes(data)
    if not (args.check or args.sprites_only):
        poses = groups(drawings)
        write_ora(poses)
        write_contact_sheet(poses)
    print(f"{len(sprites)} fox layers {'matched' if args.check else 'exported'}")


if __name__ == "__main__":
    main()
