#!/usr/bin/env python3
"""Export the MO-02 tuck and front-paw landing silhouettes."""

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SHAPES = (
    ("tuck", (0, 512), (67, 66, 455, 376)),
    ("landing", (512, 512), (18, 110, 442, 416)),
)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, help="MO-02 identity-fit transparent study")
    source = parser.parse_args().source
    exports = []
    with Image.open(source) as sheet:
        if sheet.size != (1536, 1024) or sheet.mode != "RGBA":
            raise ValueError("Unexpected MO-02 study")
        for name, (x, y), expected in SHAPES:
            cell = sheet.crop((x, y, x + 512, y + 512))
            if cell.getchannel("A").getbbox() != expected:
                raise ValueError(f"The {name} silhouette moved within its source")
            body = cell.crop(expected)
            runtime = ROOT / f"apps/mobile/assets/art/rabbit-hop-{name}.webp"
            body.save(runtime, lossless=True, exact=True)
            left, top, right, bottom = expected
            exports.append({
                "runtime_path": runtime.relative_to(ROOT).as_posix(),
                "sha256": hashlib.sha256(runtime.read_bytes()).hexdigest(),
                "runtime_size": list(body.size),
                "crop_on_master": [x + left, y + top, x + right, y + bottom],
            })
    print(json.dumps({
        "work_order": "MO-02",
        "source_revision": "r02-openai",
        "source_file": source.name,
        "source_sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
        "pose": "stage 1 without clothes during a short hop and skill landing",
        "device_qa": "pending",
        "assets": exports,
    }, indent=2))


if __name__ == "__main__":
    main()
