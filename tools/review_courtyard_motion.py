"""Compare two runs of apps/mobile/tool/capture_courtyard_walk_test.dart."""

import argparse
import csv
import json
from pathlib import Path
import subprocess

import numpy as np
from PIL import Image, ImageDraw, ImageFont


WOOD_FRAMES = range(150, 275)  # 5 seconds after the cat settles on the right
WALKS = (
    ("点地", range(18, 83)),
    ("过来", range(90, 155)),
    ("自主走动", range(440, 505)),
)
LANDMARKS = {
    "upper_tread": (207, 328),
    "middle_tread": (159, 379),
    "lower_tread": (135, 424),
    "hanging_leaves": (145, 254),
    "canopy": (572, 80),
    "platform": (336, 323),
}


def frame(folder, number):
    return folder / f"frame-{number:04}.png"


def background_motion(folder, numbers=WOOD_FRAMES):
    samples = {name: [] for name in LANDMARKS}
    identical = dict.fromkeys(LANDMARKS, 0)
    first = np.asarray(Image.open(frame(folder, numbers.start)).convert("L"))
    for number in numbers:
        current = np.asarray(Image.open(frame(folder, number)).convert("L"), dtype=np.int16)
        for name, (x, y) in LANDMARKS.items():
            reference = first[y - 6:y + 7, x - 8:x + 9]
            at_rest = current[y - 6:y + 7, x - 8:x + 9]
            identical[name] += int(np.array_equal(reference, at_rest))
            # Match the same painted detail within 24 px horizontally and 12 px vertically.
            search = current[y - 18:y + 19, x - 32:x + 33]
            windows = np.lib.stride_tricks.sliding_window_view(search, reference.shape)
            error = np.abs(windows - reference).sum(axis=(-2, -1))
            dy, dx = np.unravel_index(error.argmin(), error.shape)
            samples[name].append((int(dx) - 24, int(dy) - 12))
    return {
        name: {
            "horizontal_span_px": int(np.ptp(points, axis=0)[0]),
            "vertical_span_px": int(np.ptp(points, axis=0)[1]),
            "identical_patches_out_of_125": identical[name],
        }
        for name, points in samples.items()
    }


def front_paw(folder, number, row):
    # The sprite is captured before facing is applied. The leading white paw
    # is the rightmost paw in its lower 14%, in both directions of travel.
    alpha = np.asarray(Image.open(frame(folder / "paws", number)))[:, :, 3] > 160
    rightmost = np.where(alpha[int(len(alpha) * .86):])[1].max()
    columns = np.arange(rightmost - 17, rightmost + 1)
    bottom = np.where(alpha[:, columns], np.arange(len(alpha))[:, None], -1).max(axis=0)
    sole_y = int(bottom.max())
    sole_x = float(np.median(columns[bottom >= sole_y - 1])) + .5
    # The capture has two pixels per Flutter logical pixel.
    world_x = 2 * float(row["spriteLeft"]) + int(row["facing"]) * sole_x
    return world_x, sole_y


def paw_motion(folder):
    with (folder / "positions.csv").open() as data:
        rows = list(csv.DictReader(data))
    _, resting_y = front_paw(folder, 0, rows[0])
    report = {}
    for name, numbers in WALKS:
        walking = [i for i in numbers if rows[i]["walking"] == "true"]
        soles = {i: front_paw(folder, i, rows[i]) for i in walking}
        # A low painted paw is observable. A support/contact flag does not
        # exist in this version, so these samples do not identify a planted paw.
        pairs = []
        for i, (x, y) in soles.items():
            if i + 1 not in soles:
                continue
            next_x, next_y = soles[i + 1]
            if max(abs(y - resting_y), abs(next_y - resting_y)) <= 4:
                pairs.append((abs(next_x - x), i))
        shift, start = max(pairs)
        report[name] = {
            "walking_frames": [walking[0], walking[-1]],
            "low_adjacent_pairs": len(pairs),
            "largest_horizontal_change_px": round(shift, 1),
            "example_frames": [start, start + 1],
        }
    return report


def make_video(output, directories, segments, crop, detail, font_path,
               versions=("修改前   0.14.0+11", "修改后   0.14.1+12")):
    width, height = 1024, 758
    encoder = subprocess.Popen([
        "ffmpeg", "-hide_banner", "-loglevel", "error", "-y",
        "-f", "rawvideo", "-pixel_format", "rgb24", "-video_size", f"{width}x{height}",
        "-framerate", "25", "-i", "-", "-an", "-c:v", "libx264",
        "-threads", "3", "-crf", "17", "-pix_fmt", "yuv420p",
        "-movflags", "+faststart", str(output),
    ], stdin=subprocess.PIPE)
    title = ImageFont.truetype(str(font_path), 29)
    label = ImageFont.truetype(str(font_path), 22)
    try:
        for caption, numbers in segments:
            layout = Image.new("RGB", (width, height), "#f7f2e8")
            text = ImageDraw.Draw(layout)
            text.text((16, 4), caption, font=title, fill="#392b24")
            text.text((16, 47), versions[0], font=label, fill="#513e34")
            text.text((520, 47), versions[1], font=label, fill="#513e34")
            text.text((16, 472), detail, font=label, fill="#513e34")
            for number in numbers:
                canvas = layout.copy()
                for folder, left in zip(directories, (16, 520)):
                    with Image.open(frame(folder, number)) as source:
                        scene = source.convert("RGB")
                    scale = Image.Resampling.LANCZOS
                    canvas.paste(scene.resize((488, 380), scale), (left, 83))
                    zoom = scene.crop(crop)
                    zoom = zoom.resize((488, round(488 * zoom.height / zoom.width)), scale)
                    canvas.paste(zoom, (left, 510))
                encoder.stdin.write(canvas.tobytes())
    finally:
        encoder.stdin.close()
        status = encoder.wait()
        if status:
            raise RuntimeError(f"ffmpeg exited with {status}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for argument in ("before", "after", "output", "font"):
        parser.add_argument(argument, type=Path)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    revisions = {"before": args.before, "after": args.after}
    folders = tuple(revisions.values())
    report = {
        "source_size_px": [960, 748],
        "fps": 25,
        "background_clip_frames": [WOOD_FRAMES.start, WOOD_FRAMES.stop - 1],
        "probes_px": LANDMARKS,
        "background": {key: background_motion(folder) for key, folder in revisions.items()},
        "low_paw": {key: paw_motion(folder) for key, folder in revisions.items()},
    }
    before_paws = {p.name for p in (args.before / "paws").glob("frame-*.png")}
    after_paws = {p.name for p in (args.after / "paws").glob("frame-*.png")}
    if before_paws != after_paws:
        raise ValueError("Missing matched actor captures")
    report["sampled_actor_frames"] = len(before_paws)
    report["identical_actor_frames"] = sum(
        (args.before / "paws" / name).read_bytes() == (args.after / "paws" / name).read_bytes()
        for name in before_paws
    )
    report["identical_actor_trajectory"] = (
        (args.before / "positions.csv").read_bytes() == (args.after / "positions.csv").read_bytes()
    )
    (args.output / "measurements.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    make_video(args.output / "courtyard-stairs.mp4", folders,
               [("庭院木梯与树叶", WOOD_FRAMES)], (20, 226, 484, 456),
               "木梯与上方的叶簇 · 固定放大", args.font)
    segments = [(f"第一阶段团团 · {name}", frames) for name, frames in WALKS]
    make_video(args.output / "cat-three-walks.mp4", folders, segments,
               (100, 376, 656, 640), "四爪与草地 · 固定放大", args.font)


if __name__ == "__main__":
    main()
