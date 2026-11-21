#!/usr/bin/env python3
"""Register the full painted cat and fox walk poses on the app canvas."""

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image, ImageChops

ROOT = Path(__file__).resolve().parents[1]
CANVAS = (512, 464)
VIEWS = ("brace", "stand", "reach", "follow", "gather")

# The centre of the feet in the uncropped cell and the height of the
# illustration above the ground, in runtime pixels.
SIDE = {
    "cat": ((264, 412), (234, 412), (231, 414), (211, 414), (239, 408)),
    "fox": ((248, 405), (227, 400), (232, 402), (219, 404), (255, 405)),
}
TURN = {
    "cat": ([(0, 0, 646, 574), (646, 0, 1293, 574)], [352, 288]),
    "fox": ([(0, 580, 646, 1216), (646, 580, 1293, 1216)], [344, 258]),
}


def checksum(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def card(sheet, window, centre, height, output):
    cell = sheet.crop(window)
    cut = cell.getchannel("A").point(lambda alpha: 255 if alpha >= 64 else 0)
    left, top, right, bottom = cut.getbbox()
    source = cell.crop((left - 2, top - 2, right + 2, bottom + 2))
    scale = min(height / (bottom - top), 500 / source.width)
    art = source.resize(
        (round(source.width * scale), round(source.height * scale)),
        Image.Resampling.LANCZOS,
    )
    x = min(max(round(256 - (centre - left + 2) * scale), 2), 510 - art.width)
    y = round(440 - (bottom - top + 2) * scale)
    runtime = Image.new("RGBA", CANVAS)
    runtime.paste(art, (x, y))
    runtime.save(output, lossless=True, exact=True)
    return {
        "path": output.relative_to(ROOT).as_posix(),
        "sha256": checksum(output),
        "runtime_size": list(runtime.size),
        "window": list(window),
        "source_crop": [left - 2, top - 2, right + 2, bottom + 2],
        "output_offset": [x, y],
        "scale": round(scale, 8),
    }


def cloth(folder, view, style):
    suffix = "" if view == "side" else f"-{view}"
    bare = Image.open(folder / f"torso{suffix}.webp").convert("RGBA")
    fitted = Image.open(folder / f"torso{suffix}-{style}.webp").convert("RGBA")
    red, green, blue, _ = ImageChops.difference(bare, fitted).split()
    change = ImageChops.lighter(ImageChops.lighter(red, green), blue)
    alpha = change.point(lambda value: min(255, max(0, (value - 16) * 6)))
    fitted.putalpha(ImageChops.multiply(fitted.getchannel("A"), alpha))
    if view == "side":
        trim = Image.open(folder / f"trim-{style}.webp").convert("RGBA")
        fitted.alpha_composite(trim)
    result = folder / f"cloth-{view}-{style}.webp"
    piece = fitted.crop(fitted.getchannel("A").getbbox())
    piece.save(result, lossless=True, exact=True)
    return {
        "path": result.relative_to(ROOT).as_posix(),
        "sha256": checksum(result),
        "runtime_size": list(piece.size),
    }


def wing_hop(path):
    with Image.open(path) as sheet:
        if sheet.mode != "RGBA" or sheet.size != (2172, 724):
            raise ValueError("Unexpected stage-four wing sheet")
        for i, pose in enumerate(("brace", "flight", "land")):
            cell = sheet.crop((i * 724, 0, (i + 1) * 724, 724))
            bbox = cell.getchannel("A").point(lambda a: 255 if a >= 64 else 0).getbbox()
            x, y, right, bottom = bbox
            body = cell.crop((x - 2, y - 2, right + 2, bottom + 2))
            body.thumbnail((650, 552), Image.Resampling.LANCZOS)
            path = ROOT / f"apps/mobile/assets/art/cloud-cat-4-{pose}.webp"
            body.save(path, lossless=True, exact=True)
            yield {
                "path": path.relative_to(ROOT).as_posix(),
                "sha256": checksum(path),
                "runtime_size": list(body.size),
                "crop_on_master": [x + i * 724 - 2, y - 2, right + i * 724 + 2, bottom + 2],
            }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("cat", type=Path)
    parser.add_argument("fox", type=Path)
    parser.add_argument("turn", type=Path)
    parser.add_argument("cloud", type=Path)
    args = parser.parse_args()
    sources = {pet: getattr(args, pet) for pet in ("cat", "fox", "turn", "cloud")}
    metadata = {
        "sources": {
            key: {"file": path.name, "sha256": checksum(path)}
            for key, path in sources.items()
        },
        "assets": [],
    }
    with Image.open(args.turn) as turn:
        if turn.mode != "RGBA" or turn.size != (1293, 1216):
            raise ValueError("Unexpected four-view turn sheet")
        for pet in ("cat", "fox"):
            folder = ROOT / f"apps/mobile/assets/{pet}_walk"
            with Image.open(sources[pet]) as side:
                if side.mode != "RGBA" or side.size != (1536, 1024):
                    raise ValueError(f"Unexpected {pet} short approach sheet")
                for i, (view, (centre, height)) in enumerate(zip(VIEWS, SIDE[pet])):
                    x, y = i % 3 * 512, i // 3 * 512
                    metadata["assets"].append(card(
                        side, (x, y, x + 512, y + 512), centre, height,
                        folder / f"full-{view}.webp",
                    ))
            windows, centres = TURN[pet]
            for view, window, centre in zip(("front", "back"), windows, centres):
                metadata["assets"].append(card(
                    turn, window, centre, 414, folder / f"full-{view}.webp",
                ))
            for view in ("side", "front", "away"):
                for style in ("coat", "apron"):
                    metadata["assets"].append(cloth(folder, view, style))
    metadata["assets"].extend(wing_hop(args.cloud))
    print(json.dumps(metadata, indent=2))


if __name__ == "__main__":
    main()
