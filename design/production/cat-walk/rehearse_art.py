"""Render the original artwork acting proof at its intended speed with FFmpeg."""
from __future__ import annotations

import math
import subprocess

from PIL import Image, ImageDraw

from export_art import (
    CANVAS, SOURCE, SPEC, compose_layers, direction_marks, flatten,
    load_drawings, standing_marks, step_marks, transition_marks,
)

SIZE = 800, 410
FPS = 30
SCALE = .72
FLOOR = 375
START_X = 253
STRIDE = SPEC["cycle"]["stride"]
KEYS = SPEC["cycle"]["keyPoses"]
STANCE = SPEC["transitions"]["stand"]
DRAWINGS = ("hip", "shoulder", "body", "head")


def ease(t: float) -> float:
    return t * t * (3 - 2 * t)


def mix_pairs(a: list, b: list, u: float) -> list:
    return [round(x + (y - x) * u, 2) for x, y in zip(a, b)]


def mix_pose(a: dict, b: dict, u: float) -> dict:
    return {part: mix_pairs(a[part], b[part], u) for part in DRAWINGS}


def mix_feet(a: list, b: list, u: float) -> list:
    return [mix_pairs(x, y, u) for x, y in zip(a, b)]


def seated_picture() -> Image.Image:
    actor = Image.new("RGBA", CANVAS)
    original = Image.open(SOURCE / "face-source.png").convert("RGBA")
    actor.alpha_composite(original, (67, 0))
    return actor


def render_poses(drawings: dict, t: float, seated: Image.Image) -> tuple[Image.Image, float]:
    if t < .34:
        return seated, 0
    first_feet, _ = step_marks(0)
    if t < .82:
        fraction = (t - .34) / .48
        k = ease(fraction)
        push = SPEC["transitions"]["pushUp"]
        lifting = mix_pose(push, KEYS[0], k)
        feet = mix_feet(transition_marks(push), first_feet, k)
        lifted = flatten(compose_layers(drawings, lifting, feet))
        return Image.blend(seated, lifted, ease(min(1, fraction * 3))), 0
    if t < 2.48:
        progress = ease((t - .82) / 1.66)
        travelled = STRIDE * 2 * progress
        phase = (travelled / STRIDE) % 1
        n = int(phase * len(KEYS))
        pose = mix_pose(KEYS[n], KEYS[(n + 1) % len(KEYS)], phase * len(KEYS) - n)
        feet, _ = step_marks(phase)
        return flatten(compose_layers(drawings, pose, feet)), travelled
    if t < 2.79:
        progress = ease((t - 2.48) / .31)
        pose = mix_pose(KEYS[0], STANCE, progress)
        feet = mix_feet(first_feet, standing_marks(), progress)
        for j, foot in enumerate(feet):
            foot[1] -= math.sin(math.pi * progress) * 12 * (1 - j * .14)
        return flatten(compose_layers(drawings, pose, feet)), 2 * STRIDE
    if t < 3.35:
        progress = ease((t - 2.79) / .56)
        actor = turn(drawings, progress)
        return actor, 2 * STRIDE
    if t < 3.76:
        progress = ease((t - 3.35) / .41)
        sit = SPEC["transitions"]["sitBack"]
        pose = mix_pose(STANCE, sit, progress)
        feet = mix_feet(standing_marks(), transition_marks(sit), progress)
        crouch = flatten(compose_layers(drawings, pose, feet))
        actor = Image.blend(crouch, seated, ease(max(0, (progress - .55) / .45)))
        return actor.transpose(Image.Transpose.FLIP_LEFT_RIGHT), 2 * STRIDE
    return seated.transpose(Image.Transpose.FLIP_LEFT_RIGHT), 2 * STRIDE


def turn(drawings: dict, progress: float) -> Image.Image:
    side = flatten(compose_layers(drawings, STANCE, standing_marks()))
    front = flatten(compose_layers(drawings, STANCE, direction_marks("front"), direction="front"))
    half = abs(progress - .5) * 2
    if progress > .5:
        side = side.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
    # Shorten the profile towards the frontal key without moving the ground root.
    target_width = round(CANVAS[0] * (.57 + half * .43))
    side = side.resize((target_width, CANVAS[1]), Image.Resampling.LANCZOS)
    positioned = Image.new("RGBA", CANVAS)
    positioned.alpha_composite(side, (round((CANVAS[0] - target_width) / 2), 0))
    return Image.blend(front, positioned, ease(min(1, half / .72)))


def main() -> None:
    drawings = load_drawings()
    seated = seated_picture()
    backdrop = Image.new("RGB", SIZE, "#e7eadf")
    ground = ImageDraw.Draw(backdrop)
    ground.rectangle((0, FLOOR - 125, SIZE[0], SIZE[1]), fill="#dce0d0")
    ground.line((0, FLOOR, SIZE[0], FLOOR), fill="#a8b49e", width=1)
    for x in range(3, SIZE[0], 12):
        ground.line((x, FLOOR, x, FLOOR + (8 if x % 36 == 3 else 3)), fill="#a6b09a")
    command = [
        "ffmpeg", "-v", "error", "-y", "-f", "rawvideo", "-pix_fmt", "rgb24",
        "-s", f"{SIZE[0]}x{SIZE[1]}", "-framerate", str(FPS), "-i", "-",
        "-c:v", "libx264", "-crf", "19", "-pix_fmt", "yuv420p", "-movflags",
        "+faststart", str(SOURCE / "acting-rehearsal.mp4"),
    ]
    with subprocess.Popen(command, stdin=subprocess.PIPE) as movie:
        for frame in range(round(FPS * 4.10)):
            actor, travelled = render_poses(drawings, frame / FPS, seated)
            actor = actor.resize(
                (round(CANVAS[0] * SCALE), round(CANVAS[1] * SCALE)),
                Image.Resampling.LANCZOS,
            )
            plate = backdrop.copy()
            x = round(START_X + (travelled - SPEC["root"][0]) * SCALE)
            y = round(FLOOR - SPEC["root"][1] * SCALE)
            plate.paste(actor, (x, y), actor)
            movie.stdin.write(plate.tobytes())
        movie.stdin.close()
        if movie.wait():
            raise RuntimeError("FFmpeg could not save the pose rehearsal")


if __name__ == "__main__":
    main()
