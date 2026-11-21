#!/usr/bin/env python3
"""Export the PR-01 production-v3 layers used by the story and its journal."""

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / "apps/mobile/assets/art"
PREFIX = "draft_bridge_stamp_map"
PAPER = (54, 116, 970, 629)
FOLDED = (47, 116, 309, 629)
STAMP = (124, 345, 260, 506)
PRINTS = (
    (162, 464, 238, 536),
    (370, 464, 446, 536),
    (575, 464, 651, 536),
    (784, 465, 860, 537),
)
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("handoff", type=Path, help="PR-01 production-v3 directory")
handoff = parser.parse_args().handoff


def read(path):
    with Image.open(handoff / path) as image:
        if image.size != (1024, 768) or image.mode != "RGBA":
            raise ValueError(f"Unexpected PR-01 canvas: {path}")
        return image.copy()


def digest(data):
    return hashlib.sha256(data).hexdigest()


records = []


def export(name, image, crop, sources):
    bounds = image.getchannel("A").getbbox()
    if bounds is None:
        raise ValueError(f"Missing paint for {name}")
    if not (crop[0] <= bounds[0] <= bounds[2] <= crop[2]
            and crop[1] <= bounds[1] <= bounds[3] <= crop[3]):
        raise ValueError(f"Crop clips visible paint: {name}, {bounds}")
    path = ART / f"rain-map-{name}.webp"
    image.crop(crop).save(path, lossless=True, exact=True)
    records.append({
        "runtime_path": path.relative_to(ROOT).as_posix(),
        "runtime_size": [crop[2] - crop[0], crop[3] - crop[1]],
        "crop_on_master": list(crop),
        "sha256": digest(path.read_bytes()),
        "sources": [
            {"path": source, "sha256": digest((handoff / source).read_bytes())}
            for source in sources
        ],
    })


zero = f"states/{PREFIX}__zero__front__composite__r03.png"
paper = read(zero)
recomposed = paper.copy()
export("paper", paper, PAPER, [zero])
for index, bounds in enumerate(PRINTS, start=1):
    name = f"layers/{PREFIX}__print-slot-{index}__front__ink__r03.png"
    ink = read(name)
    if ink.getchannel("A").getbbox() != bounds:
        raise ValueError(f"Print {index} changed registration")
    recomposed.alpha_composite(ink)
    export(f"ink-{index}", ink, bounds, [name])

reference = read(f"states/{PREFIX}__four__front__composite__r03.png")
if recomposed.tobytes() != reference.tobytes():
    raise ValueError("The four independently registered prints do not reconstruct the handoff")
folded = f"states/{PREFIX}__folded__front__composite__r03.png"
export("folded", read(folded), FOLDED, [folded])

wood = f"layers/{PREFIX}__pressing__front__stamp-wood__r03.png"
rubber = f"layers/{PREFIX}__pressing__front__stamp-rubber-front-pad__r03.png"
stamp = read(wood)
stamp.alpha_composite(read(rubber))
export("stamp", stamp, STAMP, [wood, rubber])

print(json.dumps({
    "work_order": "PR-01",
    "source_revision": "r02-openai/production-v3",
    "master_size": [1024, 768],
    "device_qa": "pending",
    "assets": records,
}, ensure_ascii=False, indent=2))
