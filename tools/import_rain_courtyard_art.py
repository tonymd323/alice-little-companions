#!/usr/bin/env python3
"""Package the registered SC-01 art for the playable courtyard."""

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image, ImageChops

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / "apps/mobile/assets/art"
CANVAS = (1536, 1024)
RIVER = (1000, 700, 1536, 1024)
PARTS = {
    "canopy-branchlet": (747, 207, 937, 347),
    "ladder-leaves": (211, 478, 313, 557),
    "wood": (162, 457, 659, 735),
    "water-ripples": (1285, 822, 1505, 867),
    "foreground-botanicals": (0, 802, 365, 1020),
    "rocky-bank": (1310, 872, 1536, 1024),
}


def read(path):
    with Image.open(path) as image:
        if image.size != CANVAS:
            raise ValueError(f"Unregistered SC-01 canvas: {path}")
        return image.convert("RGBA")


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("handoff", type=Path, help="SC-01 production-v3 directory")
    handoff = parser.parse_args().handoff

    def source(name):
        return handoff / f"{name}.png"

    original = ART / "garden.webp"
    base, wet = source("00-clean-background"), source("01-wet-stone-dew-local-support")
    original_courtyard = read(original)
    clean = read(base)
    # The v2 creek repair was inside this region. Reuse the matching authored
    # scene over that region, then register the wet stone and dew over it.
    clean.paste(original_courtyard.crop(RIVER), RIVER[:2])
    clean.alpha_composite(read(wet))
    parts = [("base", clean, [base, wet, original], (0, 0, *CANVAS))]

    for part in ("canopy-branchlet", "ladder-leaves", "wood", "water-ripples", "foreground-botanicals"):
        path = source("02-fixed-original-wood" if part == "wood" else part)
        image = read(path)
        if image.getchannel("A").getbbox() != PARTS[part]:
            raise ValueError(f"SC-01 layer changed registration: {path}")
        parts.append((part, image, [path], PARTS[part]))

    legacy_front = ART / "scene_base_room_foreground.webp"
    bank = read(legacy_front)
    # Keep the original right bank in foreground; the new flowers own the left.
    if bank.getchannel("A").crop((768, 0, *CANVAS)).getbbox() != (542, 872, 768, 1024):
        raise ValueError("The original foreground bank changed registration")
    parts.append(("rocky-bank", bank, [legacy_front], PARTS["rocky-bank"]))

    for part, art, _, bounds in parts:
        if part == "wood":
            original_rgb = original_courtyard.convert("RGB")
            wood_on_original = original_rgb.copy()
            visible = art.getchannel("A").point(lambda alpha: 255 if alpha else 0)
            wood_on_original.paste(art.convert("RGB"), mask=visible)
            if ImageChops.difference(wood_on_original, original_rgb).getbbox():
                raise ValueError("The wood layer must use the fixed original painting")
        if art.crop(bounds).getchannel("A").getbbox() is None:
            raise ValueError(f"Empty export: {part}")

    records = []
    for part, art, sources, bounds in parts:
        target = ART / f"rain-courtyard-{part}.webp"
        cropped = art.crop(bounds)
        cropped.save(target, lossless=True, exact=True)
        records.append({
            "runtime_path": target.relative_to(ROOT).as_posix(),
            "runtime_size": list(cropped.size),
            "crop_on_master": list(bounds),
            "sha256": digest(target),
            "sources": [{"file": path.name, "sha256": digest(path)} for path in sources],
        })
    print(json.dumps({
        "work_order": "SC-01",
        "source_revision": "r02-openai/production-v3",
        "master_size": list(CANVAS),
        "reused_original_river_on_master": list(RIVER),
        "device_qa": "pending",
        "assets": records,
    }, indent=2))


if __name__ == "__main__":
    main()
