#!/usr/bin/env python3
"""Check the shipping portraits for the hard alpha edges found in 0.9.0."""
import hashlib
import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / "apps/mobile/assets/art"
SPEC = json.loads((ROOT / "design/asset_manifest.json").read_text())
MATERIALS = {"base_bed", "base_rug", "item_single_armchair", "item_decor_vase",
             "item_decor_cushion", "item_decor_plant"}
report = []
for entry in SPEC["production_assets"]:
    if entry["kind"] != "pet" and entry["id"] not in MATERIALS:
        continue
    path = ROOT / entry["runtime_path"]
    assert hashlib.sha256(path.read_bytes()).hexdigest() == entry["sha256"], path
    with Image.open(path) as image:
        assert image.mode == "RGBA" and list(image.size) == entry["runtime_size"], path
        levels = image.getchannel("A").histogram()
        intermediate = sum(levels[1:255])
        values = sum(n > 0 for n in levels)
        assert min(image.size) >= 285 and max(image.size) >= 390, path
        assert values >= 100 and intermediate > 1000 and levels[0] and levels[255], path
        report.append({"asset": path.name, "pixels": image.size, "distinct_alpha": values,
                       "transparent_pixels": levels[0], "partial_alpha_pixels": intermediate})
assert len(report) == 25
veranda = SPEC["home_veranda"]
assert hashlib.sha256((ROOT / veranda["runtime_path"]).read_bytes()).hexdigest() == veranda["sha256"]
print(json.dumps({"portraits_and_furnishings":report, "veranda":veranda["runtime_size"]}, indent=2))
