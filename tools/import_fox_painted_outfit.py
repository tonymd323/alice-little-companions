#!/usr/bin/env python3
"""Export whole painted fox poses into the original animation canvases."""

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageOps


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "apps/mobile/assets"
ART = ("fox-1", "leap-fox-1")
ALL_POSES = (
    "fox-1", "stand", "back", "leap-fox-1",
    "brace", "reach", "follow", "gather",
    "front", "frontReach", "frontFollow", "turnFront",
    "turnBack", "backReach", "backFollow",
)
LEFT_POSES = (
    "fox-1", "stand", "leap-fox-1",
    "brace", "reach", "follow",
    "gather", "turnFront", "turnBack",
)

# Left poses are painted from the left, then stored in the painter's usual
# right-facing coordinates. Front and back views have a single drawing.
BOARDS = (
    ("base", 2, ("", "", "back"), "map-vest-scarf"),
    ("side", 2, ("brace", "reach", "follow", "gather"), "map-vest-scarf"),
    ("rear", 2, ("turnBack", "backReach", "backFollow"), "map-vest-scarf"),
    ("plain", 3, ("fox-1", "stand", "leap-fox-1", "front",
                  "frontReach", "frontFollow", "turnFront"), "map-vest-scarf"),
    ("pocket", 3, LEFT_POSES, "map-vest-scarf"),
    ("vest-plain", 4, ALL_POSES, "map-vest-painted"),
    ("vest-pocket", 3, LEFT_POSES, "map-vest-painted"),
    ("scarf-alone", 4, ALL_POSES, "scarf-painted"),
)


def cutout(cell):
    """Keep paint connected to the animal and its antialiased fur edge."""
    alpha = cell.getchannel("A")
    islands = alpha.point(lambda value: 255 if value >= 56 else 0)
    bounds = islands.getbbox()
    if bounds is None:
        raise ValueError("Missing painted figure")
    x0, y0, x1, y1 = bounds
    # The centre of the painted silhouette is inside the head or chest.
    center = ((x0 + x1) // 2, (y0 + y1) // 2)
    inside = min(
        (
            (x, y)
            for y in range(y0, y1)
            for x in range(x0, x1)
            if islands.getpixel((x, y)) == 255
        ),
        key=lambda point: (point[0] - center[0]) ** 2 +
                          (point[1] - center[1]) ** 2,
    )
    ImageDraw.floodfill(islands, inside, 128)
    solid = islands.point(lambda value: 255 if value == 128 else 0)
    margin = solid.filter(ImageFilter.MaxFilter(5))
    ink = ImageChops.darker(alpha, margin)
    if not (bounds := ink.getbbox()):
        raise ValueError("Empty painted figure")
    cell.putalpha(ink)
    return cell.crop(bounds), bounds


def pose_path(name):
    if name in ART:
        return ASSETS / f"art/{name}.webp"
    return ASSETS / f"fox_walk/full-{name}.webp"


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def export(source_dir):
    records = []
    for board, grid, poses, finish in BOARDS:
        source = source_dir / f"fox-wear-{board}-r03.png"
        with Image.open(source) as image:
            sheet = image.convert("RGBA")
        left = board.endswith("pocket")
        for index, name in enumerate(poses):
            if not name:
                continue
            row, col = divmod(index, grid)
            x0, x1 = (sheet.width * i // grid for i in (col, col + 1))
            y0, y1 = (sheet.height * i // grid for i in (row, row + 1))
            frame, bounds = cutout(sheet.crop((x0, y0, x1, y1)))
            if left:
                frame = ImageOps.mirror(frame)
            original = pose_path(name)
            suffix = f"-{finish}-left" if left else f"-{finish}"
            target = original.with_stem(original.stem + suffix)
            with Image.open(original) as base:
                size = base.size
                bx, by, rx, ground = base.convert("RGBA").getchannel("A").getbbox()
            width, height = rx - bx, ground - by
            scale = min(width / frame.width, height / frame.height)
            frame = frame.resize(
                (round(frame.width * scale), round(frame.height * scale)),
                Image.Resampling.LANCZOS,
            )
            # Maintain the original framing and contact baseline. Size is
            # uniform so dressing does not squash the original pose depth.
            output = Image.new("RGBA", size)
            x, y = bx + (width - frame.width) // 2, ground - frame.height
            output.alpha_composite(frame, (x, y))
            # The painted body is opaque. Retain the softer alpha on
            # the antialiased fur edge and inside the gaps between paws.
            alpha = output.getchannel("A").point(
                lambda value: 255 if value >= 245 else value
            )
            output.putalpha(alpha)
            output.save(target, lossless=True, exact=True)
            a, b, c, d = bounds
            records.append({
                "runtime_path": target.relative_to(ROOT).as_posix(),
                "runtime_size": list(size),
                "sha256": digest(target),
                "source": {"file": source.name, "sha256": digest(source)},
                "source_crop": [x0 + a, y0 + b, x0 + c, y0 + d],
                "placement": [x, y],
                "baseline": ground,
            })
    return records


def export_near_back(source_dir):
    source = source_dir / "fox-wear-near-back-r05.png"
    with Image.open(source) as image:
        sheet = image.convert("RGBA")
    names = ("", "-scarf-painted", "-map-vest-painted", "-map-vest-scarf")
    records = []
    baseline = 442
    target_height = 417
    for col, suffix in enumerate(names):
        left, right = (sheet.width * edge // 4 for edge in (col, col + 1))
        frame, bounds = cutout(sheet.crop((left, 0, right, sheet.height // 2)))
        width = round(frame.width * target_height / frame.height)
        frame = frame.resize((width, target_height), Image.Resampling.LANCZOS)
        frame.putalpha(frame.getchannel("A").point(lambda a: 255 if a >= 245 else a))
        output = Image.new("RGBA", (512, 464))
        x, y = 108, baseline - target_height
        output.alpha_composite(frame, (x, y))
        target = pose_path(f"nearBackLeft{suffix}")
        output.save(target, quality=94, method=6, alpha_quality=100, exact=True)
        alpha = output.getchannel("A")
        with Image.open(target) as encoded:
            if alpha.tobytes() != encoded.getchannel("A").tobytes():
                raise ValueError(f"Transparent edge changed in {target.name}")
        x0, y0, x1, y1 = bounds
        records.append({
            "runtime_path": target.relative_to(ROOT).as_posix(),
            "runtime_size": list(output.size),
            "ink_bounds": list(alpha.getbbox()),
            "sha256": digest(target),
            "source": {"file": source.name, "sha256": digest(source)},
            "source_crop": [left + x0, y0, left + x1, y1],
            "placement": [x, y],
            "baseline": baseline,
        })
    return records


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("painted", type=Path)
    parser.add_argument("--near-back-only", action="store_true")
    args = parser.parse_args()
    render = export_near_back if args.near_back_only else export
    print(json.dumps(render(args.painted), ensure_ascii=False, indent=2))
