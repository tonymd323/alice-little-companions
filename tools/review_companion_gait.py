"""Measure and edit the live courtyard comparison at its recorded 25 fps."""

import argparse
import csv
import json
import math
from pathlib import Path

import numpy as np
from PIL import Image

from review_courtyard_motion import LANDMARKS, background_motion, frame, make_video


LEGS = ("near-hind", "near-front", "far-hind", "far-front")
WALKS = ("点草地", "过来", "自主走动")
CROP = (66, 300, 689, 615)
WOOD_FRAMES = range(234, 359)
SOLE_SCALE = 320 * .343 * 2 / 440


def load_rows(folder, name):
    with (folder / f"{name}.csv").open(newline="", encoding="utf-8") as source:
        return list(csv.DictReader(source))


def walk_intervals(rows):
    intervals = []
    start = None
    for row in rows:
        number = int(row["frame"])
        if row["walking"] == "true" and start is None:
            start = number
        elif row["walking"] == "false" and start is not None:
            intervals.append((start, number - 1))
            start = None
    if len(intervals) != len(WALKS):
        raise ValueError(f"Expected three complete walks, got {intervals}")
    return intervals


def texture_at_contact(folder, number, position, x, y):
    x, y = round(x), round(y)
    with Image.open(frame(folder / "paws", number)) as source:
        matte = np.asarray(source, dtype=np.int16)
    left = round(float(position["spriteLeft"]) * 2)
    top = round(float(position["rootY"]) * 2 - matte.shape[0] * 5 / 6)
    rect = (x - 4, y - 11, x + 5, y - 3)
    x0, y0, x1, y1 = rect
    toes = matte[y0 - top:y1 - top, x0 - left:x1 - left]
    if toes.shape != (8, 9, 4):
        return None
    # Cream highlights distinguish Tuantuan's paw from the blue fur.
    mask = (toes[..., 3] > 230) & (toes[..., 0] > 104) & (toes[..., 0] > toes[..., 2] - 40)
    if mask.sum() < 29:
        return None
    return (rect, mask)


def painted_sole(image, x, y, facing):
    """Sample the authored sole at the same pixel centers as the courtyard."""
    cx, cy = round(x), round(y)
    rect = (cx - 13, cy - 12, cx + 14, cy + 3)
    x0, y0, x1, y1 = rect
    # The pixel centers of the 128 × 100 sheet are numbered from zero.
    # The painted ground contact is at (64, 84) in image coordinates.
    u = 63.5 + (np.arange(x0, x1) + .5 - x) * facing / SOLE_SCALE
    v = 83.5 + (np.arange(y0, y1) + .5 - y) / SOLE_SCALE
    col, row = np.floor(u).astype(int), np.floor(v).astype(int)
    dx, dy = (u - col)[None, :, None], (v - row)[:, None, None]
    top = (1 - dx) * image[row[:, None], col] + dx * image[row[:, None], col + 1]
    bottom = (1 - dx) * image[row[:, None] + 1, col] + dx * image[row[:, None] + 1, col + 1]
    rgba = (1 - dy) * top + dy * bottom
    mask = rgba[..., 3] >= 253
    return (rect, mask, rgba[..., :3][mask]) if mask.sum() >= 40 else None


def find_sole(scene, rect, mask, reference, max_error=8):
    x0, y0, x1, y1 = rect
    fits = []
    for dy in range(-4, 5):
        for dx in range(-4, 5):
            patch = scene[y0 + dy:y1 + dy, x0 + dx:x1 + dx]
            if patch.shape[:2] == mask.shape:
                error = float(np.abs(patch[mask] - reference).mean())
                fits.append((error, dx * dx + dy * dy, dx, dy))
    if not fits:
        return None
    error, _, dx, dy = min(fits)
    return (dx, dy) if error < max_error else None


def contacts(folder, positions, companion):
    layers = {}
    if companion == "fox":
        folder_art = Path(__file__).resolve().parents[1] / "apps/mobile/assets/fox_walk"
        for leg in LEGS:
            with Image.open(folder_art / f"paw-{leg}.webp") as source:
                layers[leg] = np.asarray(source.convert("RGBA"), dtype=np.float32)
    stations = []
    ongoing = {}
    images = {}
    current_number = None
    for row in load_rows(folder, "contacts"):
        number = int(row["frame"])
        leg = LEGS[int(row["leg"])]
        position = positions[number]
        if row["planted"] != "true" or float(position["ink"]) == 0:
            ongoing.pop(leg, None)
            images.pop(leg, None)
            continue
        x, y = float(row["x"]), float(row["y"])
        run = ongoing.get(leg)
        if run is None or number != run["last"] + 1:
            run = {"leg": leg, "first": number, "last": number, "origin": (x, y),
                   "runtime_max_px": 0.0, "matched": 0, "visible_max_px": 0.0}
            stations.append(run)
            ongoing[leg] = run
            images.pop(leg, None)
        run["last"] = number
        run["runtime_max_px"] = max(run["runtime_max_px"], math.dist(run["origin"], (x, y)))
        if number != current_number:
            with Image.open(frame(folder, number)) as source:
                scene = np.asarray(source.convert("RGB"), dtype=np.int16)
            current_number = number
        if leg in layers:
            # A dark rear sole can be covered by the other paw. Identify the
            # matching painted layer before counting any comparison, including
            # after the turn changes the direction of the visible paint.
            sample = painted_sole(layers[leg], x, y, int(position["facing"]))
            offset = None if sample is None else find_sole(scene, *sample, max_error=6)
            if offset is not None:
                drawn = (x + offset[0], y + offset[1])
                if "reference_frame" not in run:
                    run["reference_frame"] = number
                    run["visible_origin"] = drawn
                else:
                    run["matched"] += 1
                    run["visible_max_px"] = max(
                        run["visible_max_px"], math.dist(run["visible_origin"], drawn)
                    )
            continue
        if leg not in images:
            texture = texture_at_contact(folder, number, position, x, y)
            if texture is not None:
                rect, mask = texture
                x0, y0, x1, y1 = rect
                patch = scene[y0:y1, x0:x1]
                if patch.shape[:2] == mask.shape and np.std(patch[mask]) >= 13:
                    images[leg] = (rect, mask, patch[mask])
                    run["reference_frame"] = number
            continue
        offset = find_sole(scene, *images[leg])
        if offset is not None:
            run["matched"] += 1
            run["visible_max_px"] = max(run["visible_max_px"], math.hypot(*offset))
    return stations


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for argument in ("before", "after", "output", "font"):
        parser.add_argument(argument, type=Path)
    parser.add_argument("--coat", type=Path)
    parser.add_argument("--apron", type=Path)
    parser.add_argument("--companion", choices=("cat", "fox"), default="cat")
    parser.add_argument("--measure-only", action="store_true")
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    after_positions = load_rows(args.after, "positions")
    turns = walk_intervals(after_positions)
    before_turns = walk_intervals(load_rows(args.before, "positions"))
    stations = contacts(args.after, after_positions, args.companion)
    per_walk = {}
    for action, (start, end) in zip(WALKS, turns):
        runs = [run for run in stations if start <= run["first"] <= end]
        matched = [run for run in runs if run["matched"] > 0]
        if not matched:
            raise ValueError(f"No visible planted-sole matches for {action}")
        per_walk[action] = {
            "frames": [start, end],
            "contacts": len(runs),
            "visually_measured_intervals": len(matched),
            "visible_frame_comparisons": sum(run["matched"] for run in matched),
            "visible_max_px": round(max((run["visible_max_px"] for run in matched), default=0), 3),
            "runtime_max_px": round(max(run["runtime_max_px"] for run in runs), 8),
        }
    report = {
        "scene_width_px": 960,
        "frames_per_second": 25,
        "before_intervals": before_turns,
        "after_intervals": per_walk,
        "support_intervals": stations,
        "background_sample_points": LANDMARKS,
        "background": {label: background_motion(folder, WOOD_FRAMES) for label, folder in (
            ("before", args.before), ("after", args.after))},
    }
    (args.output / "measurements.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    if args.measure_only:
        return
    name, before_version, after_version = {
        "cat": ("团团", "0.14.1+12", "0.15.0+13"),
        "fox": ("奶油", "0.15.0+13", "0.16.0+14"),
    }[args.companion]
    versions = (f"原版   {before_version}", f"步态候选   {after_version}")
    directories = (args.before, args.after)
    clips = [(f"第一阶段{name} · {action}", range(min(a, c) - 8, max(b, d) + 9))
             for action, (a, b), (c, d) in zip(WALKS, before_turns, turns)]
    make_video(args.output / "three-walks.mp4", directories, clips, CROP,
               "四爪与草地 · 固定放大 · 原速", args.font, versions)
    make_video(args.output / "stairs-and-leaves.mp4", directories,
               [("庭院木梯与银杏叶", WOOD_FRAMES)], (20, 226, 484, 456),
               "木梯与上方叶簇 · 固定放大 · 原速", args.font, versions)
    if args.coat is not None and args.apron is not None:
        make_video(args.output / "wardrobe.mp4", (args.coat, args.apron), clips[:2], CROP,
                   "同机位试穿夹具 · 原速", args.font,
                   ("外套 · 帽子 · 眼镜 · 围巾", "围裙 · 蝴蝶结 · 眼镜 · 围巾"))


if __name__ == "__main__":
    main()
