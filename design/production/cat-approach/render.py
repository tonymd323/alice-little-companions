"""Render a continuous approach from the original first-stage cat painting."""

from __future__ import annotations

import argparse
import bisect
import json
import math
import subprocess
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont
from scipy.interpolate import PchipInterpolator, RBFInterpolator
from scipy.ndimage import map_coordinates


HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
SPEC = json.loads((HERE / "poses.json").read_text(encoding="utf-8"))
CANVAS = tuple(SPEC["canvas"])
CAMERA = 960, 640
CAMERA_ROOT = 451, 600
DISPLAY_SCALE = CAMERA[1] * .343 / SPEC["rootStart"][1]
IMAGE_ORIGIN = np.array(SPEC["sourceOrigin"])
POSES = SPEC["poses"]
TIMES = [pose["time"] for pose in POSES]
FPS = SPEC["fps"]
CURVES = {
    key: PchipInterpolator(TIMES, [pose[key] for pose in POSES], axis=0)
    for key in POSES[0] if key not in ("time", "beat")
}
ORIGINAL = Image.open(REPO / SPEC["source"]).convert("RGBA")
SOURCE = np.asarray(ORIGINAL, dtype=np.float32) / 255
SOURCE[:, :, :3] *= SOURCE[:, :, 3:4]

HEAD_CENTER = np.array([235, 162])
HEAD = [
    (85, 57), (106, 91), (88, 142), (121, 186), (97, 217), (143, 228),
    (176, 110), (195, 160), (204, 199), (181, 243),
    (214, 75), (264, 20), (283, 8), (300, 54), (327, 102),
    (258, 131), (301, 148), (321, 173), (353, 184), (329, 210),
    (293, 242), (272, 235), (245, 213), (252, 259), (221, 264),
]
SHOULDERS = [(177, 293), (215, 282), (250, 277), (278, 280), (261, 315), (224, 314), (191, 325)]
RUMP = [(137, 309), (154, 325), (125, 330), (102, 351), (136, 356), (163, 368), (116, 388)]
TAIL = [(15, 332), (24, 299), (44, 278), (73, 272), (91, 288), (68, 322), (46, 350)]
PAW_POINTS = {
    "nearHind": [(115, 411), (129, 425), (153, 433), (178, 425), (148, 407), (171, 402), (134, 401)],
    "nearFront": [(194, 412), (201, 427), (218, 435), (241, 428), (246, 412), (213, 402), (208, 391)],
    "farFront": [(258, 411), (269, 423), (286, 426), (302, 420), (290, 403), (271, 399), (284, 391)],
}
KNEES = {
    "nearHind": [(107, 399), (146, 388), (174, 388)],
    "nearFront": [(189, 377), (213, 376), (236, 382)],
    "farFront": [(253, 377), (278, 366), (291, 383)],
}
EYES = ((205, 175, 34, 36), (311, 153, 18, 28))
FONT = "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc"


def state_at(time: float) -> dict:
    time = min(max(TIMES[0], time), TIMES[-1])
    index = bisect.bisect_right(TIMES, time) - 1
    # These curves run through the middle of a swing without stopping at
    # each authored drawing. Equal consecutive keys keep a support fixed.
    return {"time": time, "beat": POSES[index]["beat"],
            **{key: curve(time).tolist() for key, curve in CURVES.items()}}


def controls(pose: dict) -> tuple[np.ndarray, np.ndarray]:
    before, after = [], []
    depth = pose["advance"]
    advance = np.array([depth, 0])
    head_x, head_y, head_angle = pose["head"]
    rump = advance + np.array(pose["rump"])
    shoulders = advance + np.array(pose["shoulders"])
    tail = rump * [.84, .32] + np.array(pose["tail"])

    def add(source, dest) -> None:
        before.append(source)
        after.append(dest)

    cosine, sine = math.cos(head_angle), math.sin(head_angle)
    rotation = np.array([[cosine, -sine], [sine, cosine]])
    for point in HEAD:
        add(point, HEAD_CENTER + rotation @ (point - HEAD_CENTER) + advance + [head_x, head_y])
    for points, delta in ((SHOULDERS, shoulders), (RUMP, rump), (TAIL, tail)):
        for point in points:
            add(point, point + delta)

    for point, share in [((8, 365), .38), ((30, 384), .24), ((59, 400), .11), ((82, 403), 0)]:
        add(point, point + rump * [.92, .69] + np.array(pose["tail"]) * share)

    for name, paw in PAW_POINTS.items():
        delta = np.array(pose[name])
        knee_root = rump if name == "nearHind" else shoulders
        knee = .41 * knee_root + .59 * delta
        for point in KNEES[name]:
            add(point, point + knee)
        for point in paw:
            add(point, point + delta)

    # Keep empty space around the character open without taking a second
    # image at the seat-to-stand transition.
    for point in ((-45, -45), (195, -45), (423, -45), (-45, 190), (423, 190),
                  (-45, 485), (140, 487), (337, 489), (439, 485), (449, 359)):
        add(point, point + advance)
    return np.array(before), np.array(after)


def eased(values: np.ndarray) -> np.ndarray:
    t = np.clip(values, 0, 1)
    return t * t * (3 - 2 * t)


def manipulate_eyes(x: np.ndarray, y: np.ndarray, gaze: float, blink: float) -> tuple[np.ndarray, np.ndarray]:
    for cx, cy, rx, ry in EYES:
        dx, dy = (x - cx) / rx, (y - cy) / ry
        interior = np.maximum(0, 1 - dx * dx - dy * dy) ** 1.6
        x = x - gaze * interior
        if blink:
            # Close across the entire painted iris. Taper beyond the corners
            # in the surrounding fur so the dark rim does not leave spikes.
            spread = rx + 11
            width = eased((spread - np.abs(x - cx)) / 11)
            if cx > 250:
                width *= (1 - eased((y - 162) / 12) * eased((298 - x) / 10))
                width *= 1 - eased((x - 327) / 8)
            inner = ry * (1.1 - .15 * np.minimum(1, dx * dx))
            margin = inner + 14
            height = inner * (1 - .91 * blink * width)
            offset = y - cy
            distance = np.abs(offset)
            expanded = np.where(
                distance < height,
                distance * inner / height,
                inner + (distance - height) * (margin - inner) / (margin - height),
            )
            changed = cy + np.sign(offset) * expanded
            y = np.where((distance < margin) & (width > 0), changed, y)
    return x, y


def transparent(pose: dict) -> Image.Image:
    advance = pose["advance"]
    clean = not any((pose["blink"], pose["gaze"], *pose["head"],
                     *pose["shoulders"], *pose["rump"], *pose["tail"]))
    if clean and all(pose[key] == [advance, 0] for key in PAW_POINTS):
        frame = Image.new("RGBA", CANVAS)
        frame.alpha_composite(ORIGINAL, (round(IMAGE_ORIGIN[0] + advance), int(IMAGE_ORIGIN[1])))
        return frame

    rest, moved = controls(pose)
    inverse = RBFInterpolator(moved, rest - moved, kernel="thin_plate_spline", smoothing=.4)
    # Sample a 4-pixel grid, then interpolate the smooth displacement for
    # every foreground pixel. Read RGB and alpha in premultiplied coordinates.
    x0, y0 = max(0, round(IMAGE_ORIGIN[0] + advance - 28)), 0
    x1 = min(CANVAS[0], round(IMAGE_ORIGIN[0] + advance + ORIGINAL.width + 73))
    y1 = CANVAS[1]
    coarse_y, coarse_x = np.mgrid[y0:y1 + 4:4, x0:x1 + 4:4]
    reference = np.stack((coarse_x - IMAGE_ORIGIN[0], coarse_y - IMAGE_ORIGIN[1]), axis=-1)
    rows, cols = coarse_y.shape
    values = inverse(reference.reshape(-1, 2)).reshape(rows, cols, 2)
    py, px = np.mgrid[y0:y1, x0:x1]
    samples = [(py - y0) / 4, (px - x0) / 4]
    sx = px - IMAGE_ORIGIN[0] + map_coordinates(values[:, :, 0], samples, order=1)
    sy = py - IMAGE_ORIGIN[1] + map_coordinates(values[:, :, 1], samples, order=1)
    x, y = manipulate_eyes(sx, sy, pose["gaze"], pose["blink"])
    pixels = np.stack([map_coordinates(SOURCE[:, :, c], [y, x], order=1)
                       for c in range(4)], axis=-1)
    np.divide(pixels[:, :, :3], np.maximum(pixels[:, :, 3:4], 1e-7), out=pixels[:, :, :3])
    drawing = Image.fromarray(np.rint(pixels.clip(0, 1) * 255).astype(np.uint8))
    frame = Image.new("RGBA", CANVAS)
    frame.alpha_composite(drawing, (x0, y0))
    return frame


def backgrounds() -> tuple[Image.Image, Image.Image]:
    art = REPO / "apps/mobile/assets/art"
    backdrop = Image.open(art / "garden.webp").convert("RGBA").resize(CAMERA, Image.Resampling.LANCZOS)
    foreground = Image.open(art / "scene_base_room_foreground.webp").convert("RGBA")
    return backdrop, foreground.resize(CAMERA, Image.Resampling.LANCZOS)


def courtyard(actor: Image.Image, advance: float, layers: tuple[Image.Image, Image.Image]) -> Image.Image:
    back, front = layers
    frame = back.copy()
    shadow = Image.new("RGBA", CAMERA)
    pen = ImageDraw.Draw(shadow)
    support = CAMERA_ROOT[0] + advance * DISPLAY_SCALE
    pen.ellipse((support - 52, CAMERA_ROOT[1] - 14, support + 48, CAMERA_ROOT[1] + 6),
                fill=(57, 68, 34, 75))
    frame.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(6)))
    actor = actor.resize(tuple(round(size * DISPLAY_SCALE) for size in CANVAS), Image.Resampling.LANCZOS)
    frame.alpha_composite(actor, (round(CAMERA_ROOT[0] - SPEC["rootStart"][0] * DISPLAY_SCALE),
                                  round(CAMERA_ROOT[1] - SPEC["rootStart"][1] * DISPLAY_SCALE)))
    frame.alpha_composite(front)
    return frame.convert("RGB")


def pose_sheet(layers: tuple[Image.Image, Image.Image]) -> None:
    samples = (0, .53, .8, .95, 1.12, 1.27, 2.13, 2.62)
    width, height = 292, 236
    sheet = Image.new("RGB", (width * 4, height * 2 + 44), "#f1ebdc")
    labels = ImageDraw.Draw(sheet)
    title = ImageFont.truetype(FONT, 23)
    small = ImageFont.truetype(FONT, 15)
    labels.text((15, 9), "团团 · 两步走近 · 固定机位", fill="#4b3537", font=title)
    for n, time in enumerate(samples):
        pose = state_at(time)
        frame = courtyard(transparent(pose), pose["advance"], layers)
        cell = frame.crop((308, 356, 600, 625)).resize((280, 202), Image.Resampling.LANCZOS)
        x, y = n % 4 * width, n // 4 * height + 44
        sheet.paste(cell, (x + 6, y + 26))
        labels.text((x + 7, y + 3), f"{time:.2f}s  {pose['beat']}", fill="#4b3537", font=small)
    sheet.save(HERE / "pose-study.jpg", quality=95, optimize=True)


def encoder(path: Path, mode: str, size: tuple[int, int], options: list[str]) -> subprocess.Popen:
    return subprocess.Popen(
        ["ffmpeg", "-v", "error", "-y", "-f", "rawvideo", "-pix_fmt", mode,
         "-s", f"{size[0]}x{size[1]}", "-framerate", str(FPS), "-i", "-", "-an",
         *options, str(path)], stdin=subprocess.PIPE,
    )


def movies(layers: tuple[Image.Image, Image.Image], png: Path | None) -> None:
    video = encoder(HERE / "courtyard.mp4", "rgb24", CAMERA,
                    ["-c:v", "libx264", "-crf", "19", "-pix_fmt", "yuv420p", "-movflags", "+faststart"])
    actor_only = encoder(HERE / "transparent.webm", "rgba", CANVAS,
                         ["-c:v", "libvpx-vp9", "-b:v", "0", "-lossless", "1",
                          "-pix_fmt", "yuva420p", "-auto-alt-ref", "0"])
    if png:
        png.mkdir(parents=True, exist_ok=True)
    for n in range(round(SPEC["duration"] * FPS)):
        pose = state_at(n / FPS)
        drawing = transparent(pose)
        if png:
            drawing.save(png / f"cat-{n:03}.png")
        video.stdin.write(courtyard(drawing, pose["advance"], layers).tobytes())
        actor_only.stdin.write(drawing.tobytes())
    for output in (video, actor_only):
        output.stdin.close()
        if output.wait():
            raise RuntimeError("FFmpeg did not save the rehearsal")


def main() -> None:
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("--stills", action="store_true", help="Generate only the pose study.")
    cli.add_argument("--png", type=Path, help="Also save every transparent drawing to this folder.")
    args = cli.parse_args()
    layers = backgrounds()
    pose_sheet(layers)
    if not args.stills:
        movies(layers, args.png)


if __name__ == "__main__":
    main()
