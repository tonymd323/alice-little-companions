"""Render the original artwork acting proof at its intended speed with FFmpeg."""
from __future__ import annotations

import math
import subprocess

from PIL import Image, ImageDraw

from export_art import (
    CANVAS, SOURCE, SPEC, compose_layers, direction_marks, flatten, leg_segment,
    load_drawings, standing_marks, step_marks,
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
ROOT = tuple(SPEC["root"])
TAIL = tuple(SPEC["tailPivot"])
LIMBS = SPEC["limbs"]
SIDE_HIPS = [row["hip"] for row in LIMBS]
FRONT_HIPS = [row["hip"] for row in SPEC["directions"]["front"]]
FRONT_NEAR_PADS = direction_marks("front")[:2]
FRONT_PADS = [*FRONT_NEAR_PADS, *((2 * ROOT[0] - x, y) for x, y in FRONT_NEAR_PADS)]
SEAT_HIPS = [(202, 354), (274, 312), (240, 336), (317, 306)]
SEAT_PADS = [(218, 439), (292, 440), (244, 422), (348, 432)]
SEAT_EYES = [(276, 176), (377, 150)]
SEAT_LEAN = .023
EYES = {
    facing: [SPEC["head"][facing][name] for name in ("nearEye", "farEye")]
    for facing in ("side", "front")
}
FLIP = Image.Transpose.FLIP_LEFT_RIGHT


def ease(t: float) -> float:
    return t * t * (3 - 2 * t)


def mix_pairs(a: list, b: list, u: float) -> list:
    return [round(x + (y - x) * u, 2) for x, y in zip(a, b)]


def mix_pose(a: dict, b: dict, u: float) -> dict:
    return {part: mix_pairs(a[part], b[part], u) for part in DRAWINGS}


def mix_points(a: list, b: list, u: float) -> list:
    return [mix_pairs(x, y, u) for x, y in zip(a, b)]


def stamp(
    image: Image.Image, pin: tuple, at: tuple,
    sx: float = 1, sy: float = 1, angle: float = 0,
) -> Image.Image:
    """Place one original drawing around a marked pivot."""
    cosine, sine = math.cos(angle), math.sin(angle)
    x, y = at
    return image.transform(
        CANVAS, Image.Transform.AFFINE,
        (
            cosine / sx, sine / sx, pin[0] - (x * cosine + y * sine) / sx,
            -sine / sy, cosine / sy, pin[1] - (-x * sine + y * cosine) / sy,
        ), Image.Resampling.BICUBIC,
    )


def fitted_head(image: Image.Image, eyes: list, targets: list) -> Image.Image:
    """Register both eyes when stepping from one inked view to the next."""
    vx, vy = eyes[1][0] - eyes[0][0], eyes[1][1] - eyes[0][1]
    tx, ty = targets[1][0] - targets[0][0], targets[1][1] - targets[0][1]
    scale = math.hypot(tx, ty) / math.hypot(vx, vy)
    angle = math.atan2(ty, tx) - math.atan2(vy, vx)
    return stamp(image, eyes[0], targets[0], scale, scale, angle)


def moving_pads(a: list, b: list, progress: float, height: float) -> list:
    pads = []
    for i, (start, end) in enumerate(zip(a, b)):
        u = max(0, min(1, (progress - .14 * i) / .58))
        pad = mix_pairs(start, end, ease(u))
        lift = min(height, math.dist(start, end) * .42)
        pad[1] -= lift * 4 * u * (1 - u)
        pads.append(pad)
    return pads


def rig(
    drawings: dict, head: Image.Image, torso: Image.Image, tail: Image.Image,
    hips: list, pads: list, behind: tuple[int, int], facing: float, *, mirror_light: bool = False,
) -> Image.Image:
    actor = tail
    order = (*behind, *(i for i in range(4) if i not in behind))
    for n, i in enumerate(order):
        if n == len(behind):
            actor.alpha_composite(torso)
        kind = LIMBS[i ^ 2 if mirror_light else i]["id"]
        hip, pad = hips[i], pads[i]
        wrist = (pad[0], pad[1] - min(29, (pad[1] - hip[1]) * .26))
        bend_x = 15 if kind.endswith("hind") else -13
        bend = ((hip[0] + wrist[0]) / 2 + bend_x * facing, (hip[1] + wrist[1]) / 2)
        for bone, start, end in (("lower", bend, wrist), ("upper", hip, bend)):
            actor.alpha_composite(leg_segment(drawings[f"leg-{kind}-{bone}"], start, end))
        actor.alpha_composite(stamp(drawings[f"paw-{kind}"], (64, 84), pad, .72 + .28 * abs(facing)))
    actor.alpha_composite(head)
    return actor


def seated_picture() -> Image.Image:
    actor = Image.new("RGBA", CANVAS)
    original = Image.open(SOURCE / "face-source.png").convert("RGBA")
    actor.alpha_composite(original, (67, 0))
    return actor


def seated_lean(image: Image.Image, u: float) -> Image.Image:
    # Small anticipatory weight shift around the seated contact line.
    return stamp(image, ROOT, ROOT, angle=SEAT_LEAN * u)


def leaning_marks(marks: list) -> list:
    cosine, sine = math.cos(SEAT_LEAN), math.sin(SEAT_LEAN)
    ox, oy = ROOT
    return [
        (ox + (x - ox) * cosine - (y - oy) * sine,
         oy + (x - ox) * sine + (y - oy) * cosine)
        for x, y in marks
    ]


def crouch(drawings: dict, progress: float, destination: dict, pads: list) -> Image.Image:
    u = ease(progress)
    target_hips = [
        [x + dx, y + dy]
        for i, (x, y) in enumerate(SIDE_HIPS)
        for dx, dy in [destination["hip" if i % 2 == 0 else "shoulder"]]
    ]
    hips = mix_points(SEAT_HIPS, target_hips, u)
    feet = moving_pads(leaning_marks(SEAT_PADS), pads, progress, 10)
    tail_target = mix_pairs((167, 379), [sum(a) for a in zip(TAIL, destination["hip"])], u)
    tail = stamp(drawings["tail"], TAIL, tail_target, .68 + .32 * u, .81 + .19 * u)
    chest = (256, 301)
    torso_target = mix_pairs((261, 343), [sum(a) for a in zip(chest, destination["body"])], u)
    torso = stamp(drawings["torso"], chest, torso_target, .68 + .32 * u, 1.15 - .15 * u)
    side_eyes = EYES["side"]
    open_eyes = [[sum(a) for a in zip(eye, destination["head"])] for eye in side_eyes]
    eyes = mix_points(leaning_marks(SEAT_EYES), open_eyes, u)
    head = fitted_head(drawings["head"], side_eyes, eyes)
    return rig(drawings, head, torso, tail, hips, feet, (2, 3), 1)


def turn_half(drawings: dict, progress: float, leftward: bool) -> Image.Image:
    """Transfer weight one paw at a time as the side view turns towards Alice."""
    weight = ease(progress)
    front = progress >= .58
    side = 1 - .87 * weight
    hips = mix_points(SIDE_HIPS, FRONT_HIPS, weight)
    feet = moving_pads(standing_marks(), FRONT_PADS, progress, 16)
    tail_at = mix_pairs(TAIL, (253, 307), weight)
    tail = stamp(drawings["tail"], TAIL, tail_at, side)
    # The torso and paw positions have the same centre in both handed views.
    # Turn the existing flank around the chest, then use the frontal drawing.
    torso = (
        stamp(drawings["torso-front"], (256, 302), (256, 302), 1 - .12 * (1 - weight))
        if front else
        stamp(drawings["torso"], (256, 302), (256, 302), 1 - .38 * weight)
    )
    eyes = mix_points(EYES["side"], EYES["front"], weight)
    if leftward and front:
        # Keep the same frontal drawing across the middle of the turn.
        front_eyes = [[CANVAS[0] - x, y] for x, y in reversed(eyes)]
        front_head = fitted_head(drawings["head-front"], EYES["front"], front_eyes)
        head = front_head.transpose(FLIP)
    else:
        source = "front" if front else "side"
        head = fitted_head(drawings["head-front" if front else "head"], EYES[source], eyes)
    actor = rig(
        drawings, head, torso, tail, hips, feet,
        (0, 2) if front else (2, 3), side, mirror_light=leftward and front,
    )
    return actor.transpose(FLIP) if leftward else actor


def turn(drawings: dict, progress: float) -> Image.Image:
    leftward = progress > .5
    amount = (1 - progress if leftward else progress) * 2
    # Hold the released weight at the frontal stance for a few camera frames.
    if amount >= .83:
        return turn_half(drawings, 1, False)
    return turn_half(drawings, amount / .83, leftward)


def render_poses(drawings: dict, t: float, seated: Image.Image) -> tuple[Image.Image, float]:
    if t < .34:
        return seated, 0
    if t < .44:
        return seated_lean(seated, ease((t - .34) / .10)), 0
    first_feet, _ = step_marks(0)
    if t < .82:
        return crouch(drawings, (t - .44) / .38, KEYS[0], first_feet), 0
    if t < 2.48:
        progress = ease((t - .82) / 1.66)
        travelled = STRIDE * 2 * progress
        phase = (travelled / STRIDE) % 1
        n = int(phase * len(KEYS))
        pose = mix_pose(KEYS[n], KEYS[(n + 1) % len(KEYS)], phase * len(KEYS) - n)
        feet, _ = step_marks(phase)
        return flatten(compose_layers(drawings, pose, feet)), travelled
    if t < 2.79:
        progress = (t - 2.48) / .31
        pose = mix_pose(KEYS[0], STANCE, ease(progress))
        feet = moving_pads(first_feet, standing_marks(), progress, 12)
        return flatten(compose_layers(drawings, pose, feet)), 2 * STRIDE
    if t < 3.35:
        progress = ease((t - 2.79) / .56)
        return turn(drawings, progress), 2 * STRIDE
    if t < 3.67:
        actor = crouch(drawings, 1 - (t - 3.35) / .32, STANCE, standing_marks())
        return actor.transpose(FLIP), 2 * STRIDE
    if t < 3.76:
        actor = seated_lean(seated, 1 - ease((t - 3.67) / .09))
        return actor.transpose(FLIP), 2 * STRIDE
    return seated.transpose(FLIP), 2 * STRIDE


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
