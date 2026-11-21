#!/usr/bin/env python3
"""Export the SC-03, PR-02 and FU-02 layers for the flower shop."""

import argparse
import hashlib
import json
from io import BytesIO
from pathlib import Path
from xml.etree import ElementTree
from zipfile import ZipFile

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / "apps/mobile/assets/art"
PREFIX = "draft_florist_six_vials"
SHOP_SIZE = (1536, 1024)
TRAY_SIZE = (1200, 720)
SHOP_CROP = (192, 356, 864, 540)
TRAY_CROP = (72, 234, 1128, 702)
STATES = {"empty": (), "three": (4, 5, 6), "five": (1, 2, 3, 4, 5), "six": (1, 2, 3, 4, 5, 6)}
BODY = ["contact-shadow", "tray-body"]
FLOWERS = [
    [f"flower-{index}-{part}" for part in ("insertion-stub", "upper-branch", "calyx", "corolla")]
    for index in range(1, 7)
]
RIM = ["front-fascia-and-feet", *(f"socket-{index}-front-rim" for index in range(1, 7))]
ROOM = "fixed-original-camera-background"
LIP = "actual-cabinet-front-lip"
RACK_PREFIX = "draft_florist_drying_rack"
RACK_CROP = (1020, 656, 1448, 968)
RACK_FEET = ((1055, 908), (1119, 949), (1336, 878), (1409, 919))


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_image(source, size):
    with Image.open(source) as image:
        if image.size != size:
            raise ValueError(f"Expected image size {size}, got {image.size}")
        return image.convert("RGBA")


def composite(size, layers):
    result = Image.new("RGBA", size)
    for layer in layers:
        result.alpha_composite(layer)
    return result


def same_visible_pixels(actual, expected, label):
    # Fully transparent RGB and small premultiplication rounding errors are
    # irrelevant to the displayed sprite. Compare it against a fixed paper tone.
    paper = Image.new("RGBA", actual.size, (249, 236, 210, 255))
    difference = ImageChops.difference(
        Image.alpha_composite(paper, actual).convert("RGB"),
        Image.alpha_composite(paper, expected).convert("RGB"),
    )
    if max(high for _, high in difference.getextrema()) > 2:
        raise ValueError(f"Registration differs from {label}")


def ora_layers(source, size, order):
    layers = {}
    with ZipFile(source) as archive:
        stack = ElementTree.fromstring(archive.read("stack.xml")).find("stack")
        for node in reversed(list(stack)):
            attrs = node.attrib
            if (
                node.tag != "layer"
                or (attrs["x"], attrs["y"], attrs["opacity"], attrs["visibility"])
                != ("0", "0", "1.0", "visible")
                or attrs["composite-op"] != "svg:src-over"
            ):
                raise ValueError(f"Unexpected unregistered layer in {source.name}")
            layers[attrs["name"]] = read_image(BytesIO(archive.read(attrs["src"])), size)
    if list(layers) != order:
        raise ValueError(f"Unexpected layer order in {source.name}")
    return layers


def export(name, image, crop, size, sources, records):
    left, top, right, bottom = crop
    x0, y0, x1, y1 = image.getchannel("A").getbbox()
    if not (left <= x0 <= x1 <= right and top <= y0 <= y1 <= bottom):
        raise ValueError(f"Crop {crop} clips {name} at {(x0, y0, x1, y1)}")
    dest = ART / f"florist-{name}.webp"
    sprite = image.crop(crop).resize(size, Image.Resampling.LANCZOS)
    if sprite.getchannel("A").getextrema() == (255, 255):
        sprite = sprite.convert("RGB")
    sprite.save(dest, lossless=True, exact=True)
    records.append({
        "runtime_path": dest.relative_to(ROOT).as_posix(),
        "runtime_size": list(size),
        "crop_on_master": list(crop),
        "sha256": digest(dest),
        "sources": [{"file": path.name, "sha256": digest(path)} for path in sources],
    })


def export_tray(scene_dir, prop_dir, records, room_source):
    for in_room in (True, False):
        view = "shop" if in_room else "front-low"
        name = "shop" if in_room else "close"
        size, crop, export_size = (
            (SHOP_SIZE, SHOP_CROP, (336, 92)) if in_room
            else (TRAY_SIZE, TRAY_CROP, (792, 351))
        )
        suffix = "scene-editable" if in_room else "editable"
        ora = prop_dir / f"{PREFIX}__six__{view}__{suffix}__r03.ora"
        order = [*BODY, *(part for flower in FLOWERS for part in flower), *RIM]
        if in_room:
            order = [ROOM, *order, LIP]
        source = ora_layers(ora, size, order)
        body = composite(size, (source[key] for key in BODY))
        blooms = [composite(size, (source[key] for key in flower)) for flower in FLOWERS]
        rim_order = [*RIM, LIP] if in_room else RIM
        rim = composite(size, (source[key] for key in rim_order))
        if in_room:
            same_visible_pixels(
                composite(size, [room_source, source[LIP]]),
                source[ROOM],
                "SC-03 room with the original cabinet lip",
            )
        for state, selected in STATES.items():
            layers = [body, *(blooms[index - 1] for index in selected), rim]
            original_keys = [
                *BODY, *(part for index in selected for part in FLOWERS[index - 1]),
                *rim_order,
            ]
            original = [source[key] for key in original_keys]
            if in_room:
                layers.insert(0, room_source)
                original.insert(0, room_source)
            ending = "scene-composite" if in_room else "composite"
            reference = prop_dir / f"{PREFIX}__{state}__{view}__{ending}__r03.png"
            same_visible_pixels(
                composite(size, [source[ROOM], *original[1:]] if in_room else original),
                read_image(reference, size),
                reference.name,
            )
            # The showpiece ORA repeats the cabinet lip over its baked room.
            # Place that lip just once at runtime, after the worktop sprites.
            same_visible_pixels(composite(size, layers), composite(size, original), f"{view} {state}")
        export(f"{name}-tray", body, crop, export_size, [ora], records)
        for index, flower in enumerate(blooms, start=1):
            export(f"{name}-flower-{index}", flower, crop, export_size, [ora], records)
        front_sources = [ora, scene_dir / "03-original-front-lip-occluder.png"] if in_room else [ora]
        export(f"{name}-rim", rim, crop, export_size, front_sources, records)


def export_rack(rack_dir, records):
    source = rack_dir / f"{RACK_PREFIX}__scene-rack-visible.png"
    floor_source = rack_dir / f"{RACK_PREFIX}__scene-floor-shadow.png"
    rack = read_image(source, SHOP_SIZE)
    alpha = rack.getchannel("A")
    if alpha.getbbox() != (1030, 664, 1420, 952):
        raise ValueError("Unexpected drying rack registration")
    paint = rack.convert("RGB")
    tone = Image.new("L", SHOP_SIZE)
    brush = ImageDraw.Draw(tone)
    # Warm the original painted grain on the two supports and top rail.
    # The flower heads and pale clips keep their original colors.
    brush.polygon([(1040, 686), (1097, 685), (1115, 830), (1132, 952),
                   (1025, 951), (1032, 793)], fill=198)
    brush.polygon([(1365, 658), (1400, 658), (1430, 948), (1317, 948),
                   (1320, 835), (1346, 751)], fill=207)
    brush.polygon([(1085, 709), (1363, 676), (1369, 702), (1088, 734)], fill=118)
    glaze = ImageOps.colorize(
        paint.convert("L"), (42, 24, 13), (252, 219, 174), mid=(147, 88, 46)
    )
    rack = Image.composite(glaze, paint, tone.filter(ImageFilter.GaussianBlur(6)))
    rack.putalpha(alpha)

    soft = read_image(floor_source, SHOP_SIZE)
    contact = Image.new("RGBA", SHOP_SIZE)
    feet = ImageDraw.Draw(contact)
    for x, y in RACK_FEET:
        feet.ellipse((x - 9, y - 2, x + 10, y + 4), fill=(76, 40, 21, 112))
    soft.alpha_composite(contact.filter(ImageFilter.GaussianBlur(2)))
    runtime_size = (428, 312)
    export("drying-rack", rack, RACK_CROP, runtime_size, [source], records)
    export("drying-rack-shadow", soft, RACK_CROP, runtime_size, [floor_source], records)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("scene", type=Path, help="SC-03 production-v3 directory")
    parser.add_argument("prop", type=Path, help="PR-02 production-v3 directory")
    parser.add_argument("rack", type=Path, help="FU-02 processed-v4 directory")
    args = parser.parse_args()
    records = []
    room_files = [
        args.scene / "00-genuine-openai-hidden-wall-and-floor.png",
        args.scene / "02-original-green-cabinet-and-complete-top.png",
    ]
    room = composite(SHOP_SIZE, (read_image(path, SHOP_SIZE) for path in room_files))
    export_tray(args.scene, args.prop, records, room)
    export("room", room, (0, 0, *SHOP_SIZE), (1152, 768), room_files, records)
    export_rack(args.rack, records)
    print(json.dumps({
        "work_orders": ["SC-03", "PR-02", "FU-02"],
        "source_revisions": {
            "SC-03": "r02-openai/production-v3",
            "PR-02": "r02-openai/production-v3",
            "FU-02": "r02-openai/processed-v4",
        },
        "shop_master_size": SHOP_SIZE,
        "tray_master_size": TRAY_SIZE,
        "device_qa": "pending",
        "assets": records,
    }, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
