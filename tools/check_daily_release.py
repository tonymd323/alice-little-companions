#!/usr/bin/env python3
"""Verify the bundled art against the source manifest and its alpha."""

import argparse
from collections import Counter
import hashlib
import io
import json
from pathlib import Path
from zipfile import ZipFile

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "design/asset_manifest.json"
APP_PREFIX = "apps/mobile/"
APK_PREFIX = "assets/flutter_assets/"


def artwork_rows(value):
    """Yield runtime entries, excluding source art and design references."""
    if isinstance(value, dict):
        path = value.get("runtime_path", value.get("path"))
        if (isinstance(path, str) and path.startswith(APP_PREFIX + "assets/")
                and "runtime_size" in value and "sha256" in value):
            yield path[len(APP_PREFIX):], value
        for child in value.values():
            yield from artwork_rows(child)
    elif isinstance(value, list):
        for child in value:
            yield from artwork_rows(child)


def require(condition, message):
    if not condition:
        raise ValueError(message)


def verify(read, spec):
    paths = json.loads(read("assets/config/runtime_assets.json"))
    indexed = {}
    images = {}
    for path, entry in artwork_rows(spec):
        images.setdefault(path, []).append(entry)
        if "id" in entry:
            asset_id = entry["id"]
            require(asset_id not in indexed, f"Duplicate runtime ID: {asset_id}")
            indexed[asset_id] = path
    require(paths == indexed, "Packaged asset IDs or paths differ from the manifest")

    counts = Counter()
    for path, entries in images.items():
        data = read(path)
        checksum = hashlib.sha256(data).hexdigest()
        with Image.open(io.BytesIO(data)) as art:
            alpha = art.getchannel("A") if "A" in art.getbands() else None
            for row in entries:
                require(checksum == row["sha256"], f"{path}: SHA-256 differs")
                require(list(art.size) == row["runtime_size"], f"{path}: size differs")
                if "ink_bounds" in row:
                    require(alpha is not None, f"{path}: missing transparency")
                    require(list(alpha.getbbox()) == row["ink_bounds"],
                            f"{path}: paint bounds differ")
                if "id" not in row:
                    continue
                kind = row.get("kind", "pet")
                counts[kind] += 1
                if kind in ("pet_action", "fitted_accessory", "cat_walk", "fox_walk"):
                    require(alpha is not None, f"{path}: missing transparency")
                    levels = alpha.histogram()
                    require(levels[0] > 100 and levels[255] > 0,
                            f"{path}: missing transparent or opaque pixels")
                    if kind in ("pet_action", "fitted_accessory"):
                        require(levels[255] > 1000 and sum(levels[1:255]) > 130,
                                f"{path}: painted edge lost")
    require(counts["pet_action"] == 54 and counts["fitted_accessory"] == 18,
            "The original action and fitted accessory sets must be complete")
    return {
        "verified_asset_ids": len(indexed),
        "verified_runtime_images": len(images),
        "by_kind": dict(counts),
        "alpha_verified_for_all_new_paintings": True,
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("artifact", type=Path, help="signed APK or Flutter bundle directory")
    args = parser.parse_args()
    spec = json.loads(MANIFEST.read_text())
    try:
        if args.artifact.is_dir():
            result = verify(lambda path: (args.artifact / path).read_bytes(), spec)
        else:
            with ZipFile(args.artifact) as archive:
                result = verify(lambda path: archive.read(APK_PREFIX + path), spec)
            result["apk_sha256"] = hashlib.sha256(args.artifact.read_bytes()).hexdigest()
    except (OSError, ValueError, KeyError) as error:
        parser.error(str(error))
    print(json.dumps(result, indent=2))
