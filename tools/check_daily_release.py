#!/usr/bin/env python3
"""Verify the installed Flutter art against the source manifest and its alpha."""
import argparse
import hashlib
import io
import json
import zipfile
from pathlib import Path
from PIL import Image

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument("apk", type=Path)
args = parser.parse_args()
spec = json.loads((root / "design/asset_manifest.json").read_text())
expected = spec["production_assets"]
counts = {}
with zipfile.ZipFile(args.apk) as archive:
    paths = json.loads(archive.read("assets/flutter_assets/assets/config/runtime_assets.json"))
    assert set(paths) == {entry["id"] for entry in expected}
    for entry in expected:
        path = paths[entry["id"]]
        data = archive.read("assets/flutter_assets/" + path)
        assert hashlib.sha256(data).hexdigest() == entry["sha256"], path
        kind = entry["kind"]
        counts[kind] = counts.get(kind, 0) + 1
        if kind in ("pet_action", "fitted_accessory"):
            with Image.open(io.BytesIO(data)) as picture:
                assert list(picture.size) == entry["runtime_size"], path
                levels = picture.getchannel("A").histogram()
                assert levels[0] > 100 and levels[255] > 1000, path
                assert sum(levels[1:255]) > 130, path
    assert counts["pet_action"] == 54 and counts["fitted_accessory"] == 18
print(json.dumps({"apk_sha256": hashlib.sha256(args.apk.read_bytes()).hexdigest(),
                  "verified_asset_ids": len(expected), "by_kind": counts,
                  "alpha_verified_for_all_new_paintings": True}, indent=2))
