#!/usr/bin/env python3
"""Stage compact WebPs for new art in the signed Android update."""

import argparse
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor
import hashlib
import io
import json
from pathlib import Path
from tempfile import TemporaryDirectory
from zipfile import ZipFile

from PIL import Image, ImageChops, ImageStat, features

from check_daily_release import APK_PREFIX, APP_PREFIX, MANIFEST, ROOT
from check_daily_release import artwork_rows, require, verify


REFERENCE_RECEIPT = ROOT / "docs/evidence/feeding-0240/package.json"
QUALITY = 94
MAX_SCREEN_RGB_DIFFERENCE = 2.5


def is_lossless_webp(content):
    if content[:4] != b"RIFF" or content[8:12] != b"WEBP":
        raise ValueError("Expected a WebP file")
    offset = 12
    while offset + 8 <= len(content):
        tag = content[offset:offset + 4]
        if tag in (b"VP8 ", b"VP8L"):
            return tag == b"VP8L"
        size = int.from_bytes(content[offset + 4:offset + 8], "little")
        offset += 8 + size + size % 2
    raise ValueError("Missing WebP image data")


def screen_difference(original, encoded):
    limit = (540, 330) if original.width >= 1500 else (224, 190)

    def display(image):
        image.thumbnail(limit, Image.Resampling.LANCZOS)
        paper = Image.new("RGBA", image.size, "#dcb577")
        return Image.alpha_composite(paper, image).convert("RGB")

    delta = ImageChops.difference(display(original), display(encoded))
    return sum(ImageStat.Stat(delta).mean) / 3


def prepare(reference, receipt_path, output):
    receipt = json.loads(receipt_path.read_text())
    require(hashlib.sha256(reference.read_bytes()).hexdigest() == receipt["sha256"],
            "The reference APK differs from its release receipt")
    with ZipFile(reference) as apk:
        shipped = set(apk.namelist())

    manifest = json.loads(MANIFEST.read_text())
    records = defaultdict(list)
    for path, row in artwork_rows(manifest):
        records[path].append(row)
    output = output.resolve()
    require(not output.exists(), f"Output already exists: {output}")
    require(output.parent.is_dir(), f"Missing output directory: {output.parent}")

    with TemporaryDirectory(dir=output.parent, prefix=".webp-") as folder:
        staged = Path(folder) / "output"

        def encode(path):
            relative = Path(path)
            require(".." not in relative.parts and not relative.is_absolute(),
                    f"Invalid asset path: {path}")
            source = ROOT / APP_PREFIX / relative
            content = source.read_bytes()
            checksum = hashlib.sha256(content).hexdigest()
            require(all(row["sha256"] == checksum for row in records[path]),
                    f"Artwork manifest differs from {path}")
            if not is_lossless_webp(content):
                return
            with Image.open(io.BytesIO(content)) as image:
                original = image.convert("RGBA")
                profile = image.info.get("icc_profile")
            result = io.BytesIO()
            original.save(result, "WEBP", quality=QUALITY, method=6, exact=True,
                          alpha_quality=100, icc_profile=profile)
            data = result.getvalue()
            if len(data) >= len(content):
                return
            with Image.open(result) as image:
                encoded = image.convert("RGBA")
            require(original.size == encoded.size, f"Image size changed: {path}")
            require(original.getchannel("A").tobytes() == encoded.getchannel("A").tobytes(),
                    f"Alpha changed: {path}")
            mean = screen_difference(original, encoded)
            if mean > MAX_SCREEN_RGB_DIFFERENCE:
                return
            dest = staged / APP_PREFIX / relative
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_bytes(data)
            return (path, checksum, hashlib.sha256(data).hexdigest(),
                    len(content) - len(data), mean)

        candidates = sorted(path for path in records
                            if path.endswith(".webp") and APK_PREFIX + path not in shipped)
        with ThreadPoolExecutor(max_workers=4) as workers:
            results = [item for item in workers.map(encode, candidates) if item is not None]

        for path, original, encoded, _, _ in results:
            for row in records[path]:
                row["lossless_sha256"] = original
                row["sha256"] = encoded

        def read(path):
            optimized = staged / APP_PREFIX / path
            return (optimized if optimized.is_file() else ROOT / APP_PREFIX / path).read_bytes()

        summary = verify(read, manifest)
        summary.update({
            "baseline_version": receipt["version"],
            "baseline_apk_sha256": receipt["sha256"],
            "webp_quality": QUALITY,
            "pillow_version": Image.__version__,
            "webp_version": features.version("webp"),
            "reencoded_webps": len(results),
            "saved_runtime_bytes": sum(item[3] for item in results),
            "max_render_mean_rgb_difference": round(max((item[4] for item in results), default=0), 4),
            "alpha_channels_unchanged": True,
        })
        manifest_path = staged / MANIFEST.relative_to(ROOT)
        manifest_path.parent.mkdir(parents=True, exist_ok=True)
        manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")
        (staged / "report.json").write_text(json.dumps(summary, indent=2) + "\n")
        staged.rename(output)
    return summary


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("reference_apk", type=Path)
    parser.add_argument("output", type=Path, help="staging directory to create")
    parser.add_argument("--reference-receipt", type=Path, default=REFERENCE_RECEIPT)
    args = parser.parse_args()
    try:
        report = prepare(args.reference_apk, args.reference_receipt, args.output)
    except (OSError, ValueError, KeyError) as error:
        parser.error(str(error))
    print(json.dumps(report, indent=2))
