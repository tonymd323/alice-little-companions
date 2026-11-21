#!/usr/bin/env python3
"""Export earned growth illustrations from the three EV production sets."""

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / "apps/mobile/assets/art"
JOBS = {"cat": "EV-01", "fox": "EV-04", "rabbit": "EV-05"}
CANVAS = (576, 576)
BASELINE = 548
# Scene height ratios from DESIGN_SPEC, mapped to the portrait canvas.
HEIGHTS = (328, 369, 410, 465, 492, 533)
VISIBLE_ALPHA = [0] * 9 + list(range(9, 256))


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load(path):
    with Image.open(path) as original:
        if original.mode != "RGBA":
            raise ValueError(f"{path} needs a transparent character layer")
        image = original.copy()
    image.putalpha(image.getchannel("A").point(VISIBLE_ALPHA))
    return image


def cat_fold_and_open(path):
    sheet = load(path)
    mid = sheet.width // 2
    if sheet.getchannel("A").crop((mid - 8, 0, mid + 8, sheet.height)).getbbox():
        raise ValueError("The two wing poses need a clear space between them")
    cells = [
        (0, 0, mid, sheet.height),
        (mid, 0, mid * 2, sheet.height),
    ]
    parts = [sheet.crop(cell) for cell in cells]
    left, right = [part.getchannel("A").getbbox() for part in parts]
    bounds = (
        min(left[0], right[0]),
        min(left[1], right[1]),
        max(left[2], right[2]),
        max(left[3], right[3]),
    )
    for cell, part in zip(cells, parts):
        box = (bounds[0] + cell[0], bounds[1], bounds[2] + cell[0], bounds[3])
        yield part.crop(bounds), box


def placed(portrait, stage):
    scale = min(HEIGHTS[stage - 1] / portrait.height, 544 / portrait.width)
    width = round(portrait.width * scale)
    height = round(portrait.height * scale)
    xy = ((CANVAS[0] - width) // 2, BASELINE - height)
    result = Image.new("RGBA", CANVAS)
    result.alpha_composite(portrait.resize((width, height), Image.Resampling.LANCZOS), xy)
    return result, xy, scale


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("returns", type=Path)
    parser.add_argument("--cat-four", type=Path, required=True)
    options = parser.parse_args()
    wings = dict(zip(("S4-rest", "S4-open"), cat_fold_and_open(options.cat_four)))
    entries = []
    for species, job in JOBS.items():
        package = options.returns / job / "r02-openai"
        coordinates = json.loads((package / "stage_coordinates.json").read_text())
        expected = ["S1", "S2", "S3", "S4-rest", "S4-open", "S5", "S6"] if species == "cat" else [
            "S1", "S2", "S3", "S4", "S5", "S6"
        ]
        if [item["stage"] for item in coordinates] != expected:
            raise ValueError(f"{job}: unexpected order or number of stages")
        for item in coordinates:
            key = item["stage"]
            stage = int(key[1])
            chosen = package / item["file"]
            if species == "cat" and key in wings:
                portrait, crop = wings[key]
                source = options.cat_four
            else:
                image = load(chosen)
                crop = image.getchannel("A").getbbox()
                portrait = image.crop(crop)
                source = chosen
            result, xy, scale = placed(portrait, stage)
            suffix = "-rest" if key == "S4-rest" else ""
            path = ART / f"growth-{species}-{stage}{suffix}.webp"
            result.save(path, lossless=True, exact=True)
            entries.append({
                "work_order": job,
                "species": species,
                "stage": stage,
                "reveal": key != "S4-rest",
                "runtime_path": path.relative_to(ROOT).as_posix(),
                "runtime_size": list(CANVAS),
                "sha256": digest(path),
                "ink_bounds": list(result.getchannel("A").getbbox()),
                "placed_xy": list(xy),
                "scale": scale,
                "source": {
                    "path": source.resolve().relative_to(options.returns.resolve()).as_posix(),
                    "sha256": digest(source),
                    "crop_xyxy": list(crop),
                },
            })
    print(json.dumps({
        "work_orders": list(JOBS.values()),
        "exporter": "tools/import_growth_portraits.py",
        "portrait_bottom": BASELINE,
        "portraits": entries,
        "device_qa": "pending",
    }, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
