"""Render Naiyou's fixed-camera acting sample at its intended speed."""

from __future__ import annotations

import math
import subprocess

from PIL import Image, ImageDraw

from export_art import (
    CANVAS, LIMBS, SOURCE, SPEC, compose_layers, flatten, leg_segment,
    load_drawings, seated_drawing, standing_marks, step_marks,
)


SIZE = 800, 416
FPS = 30
FRAMES = 141
SCALE = .69
FLOOR = 380
START_X = 235
STRIDE = SPEC["cycle"]["stride"]
KEYS = SPEC["cycle"]["keyPoses"]
STANCE = SPEC["transitions"]["stand"]
ROOT = tuple(SPEC["root"])
TAIL = tuple(SPEC["tailPivot"])
SEAT_PADS = [row["seatedPad"] for row in LIMBS]
SEAT_HIPS = [(233, 380), (293, 334), (338, 367), (342, 328)]
SIDE_HIPS = [row["hip"] for row in LIMBS]
FRONT_HIPS = [row["hip"] for row in SPEC["directions"]["front"]]
FRONT_PADS = standing_marks("front")
FLIP = Image.Transpose.FLIP_LEFT_RIGHT
EYES = {view: [SPEC["head"][view][name] for name in ("nearEye", "farEye")] for view in ("side", "front")}
SEAT_EYES = [(281.2, 188.5), (380.9, 172.9)]


def ease(t: float) -> float:
    return t * t * (3 - 2 * t)


def mix(a: tuple | list, b: tuple | list, u: float) -> tuple:
    return tuple(x + (y - x) * u for x, y in zip(a, b))


def translate(a: tuple | list, b: tuple | list) -> tuple:
    return tuple(x + y for x, y in zip(a, b))


def mix_pose(a: dict, b: dict, t: float) -> dict:
    pose = {part: mix(a[part], b[part], t) for part in ("hip", "shoulder", "body", "head")}
    pose["tailDegrees"] = a["tailDegrees"] + (b["tailDegrees"] - a["tailDegrees"]) * t
    return pose


def stamp(image: Image.Image, pin: tuple, at: tuple, sx: float = 1, sy: float = 1, angle: float = 0) -> Image.Image:
    sine, cosine = math.sin(angle), math.cos(angle)
    x, y = at
    return image.transform(
        CANVAS, Image.Transform.AFFINE,
        (cosine / sx, sine / sx, pin[0] - (x * cosine + y * sine) / sx,
         -sine / sy, cosine / sy, pin[1] - (-x * sine + y * cosine) / sy),
        Image.Resampling.BICUBIC,
    )


def fitted_head(image: Image.Image, source: list, target: list) -> Image.Image:
    dx, dy = (b - a for a, b in zip(*source))
    tx, ty = (b - a for a, b in zip(*target))
    scale = math.hypot(tx, ty) / math.hypot(dx, dy)
    angle = math.atan2(ty, tx) - math.atan2(dy, dx)
    return stamp(image, source[0], target[0], scale, scale, angle)


def stepping_between(a: list, b: list, progress: float, clearance: float) -> list:
    feet = []
    for i, (start, end) in enumerate(zip(a, b)):
        swing = max(0, min(1, (progress - .17 * i) / .49))
        x, y = mix(start, end, ease(swing))
        lift = min(clearance, math.dist(start, end) * .43)
        feet.append((x, y - lift * 4 * swing * (1 - swing)))
    return feet


def rig(drawings: dict, tail: Image.Image, torso: Image.Image, head: Image.Image,
        hips: list, feet: list, behind: tuple[int, int], depth: float) -> Image.Image:
    actor = tail.copy()
    order = (*behind, *(i for i in range(4) if i not in behind))
    for n, i in enumerate(order):
        if n == len(behind):
            actor.alpha_composite(torso)
        row = LIMBS[i]
        hip, pad = hips[i], feet[i]
        wrist = pad[0], pad[1] - min(29, (pad[1] - hip[1]) * .35)
        ref_wrist = row["pad"][0], row["pad"][1] - 29
        fixed_knee_bias = tuple(row["bend"][axis] - (row["hip"][axis] + ref_wrist[axis]) / 2 for axis in (0, 1))
        knee = translate(mix(hip, wrist, .5), (fixed_knee_bias[0] * depth, fixed_knee_bias[1]))
        for limb, start, end in (("upper", hip, knee), ("lower", knee, wrist)):
            actor.alpha_composite(leg_segment(drawings[f"leg-{row['id']}-{limb}"], start, end))
        actor.alpha_composite(stamp(drawings[f"paw-{row['id']}"], (64, 84), pad, .71 + .29 * abs(depth)))
    actor.alpha_composite(head)
    return actor


def bridged_seat(drawings: dict, progress: float, pose: dict, target_pads: list) -> Image.Image:
    shift = ease(progress)
    target_hips = [translate(hip, pose["hip" if index % 2 == 0 else "shoulder"]) for index, hip in enumerate(SIDE_HIPS)]
    hips = [mix(a, b, shift) for a, b in zip(SEAT_HIPS, target_hips)]
    feet = stepping_between(SEAT_PADS, target_pads, progress, 13)
    tail_target = mix((205, 381), translate(TAIL, pose["hip"]), shift)
    tail = stamp(drawings["tail"], TAIL, tail_target, 1.06 - .06 * shift, 1.04 - .04 * shift,
                 math.radians(pose["tailDegrees"] * ease(max(0, (progress - .16) / .84))))
    shoulders = (256, 304)
    torso_at = mix((264, 352), translate(shoulders, pose["body"]), shift)
    torso = stamp(drawings["torso"], shoulders, torso_at, .57 + .43 * shift, 1.12 - .12 * shift)
    next_eyes = [translate(eye, pose["head"]) for eye in EYES["side"]]
    eyes = [mix(a, b, shift) for a, b in zip(SEAT_EYES, next_eyes)]
    head = fitted_head(drawings["head"], EYES["side"], eyes)
    return rig(drawings, tail, torso, head, hips, feet, (2, 3), 1)


def head_on_turn(drawings: dict, progress: float, leftward: bool) -> Image.Image:
    shift = ease(progress)
    facing_front = progress >= .59
    side = 1 - .82 * shift
    hips = [mix(a, b, shift) for a, b in zip(SIDE_HIPS, FRONT_HIPS)]
    feet = stepping_between(standing_marks(), FRONT_PADS, progress, 19)
    tail = stamp(drawings["tail"], TAIL, mix(TAIL, (256, 329), shift), .53 + .47 * side,
                 angle=math.radians(-8 * shift))
    center = (256, 305)
    torso = (stamp(drawings["torso-front"], center, center, .9 + .1 * shift) if facing_front else
             stamp(drawings["torso"], center, center, 1 - .36 * shift))
    eyes = [mix(a, b, shift) for a, b in zip(EYES["side"], EYES["front"])]
    if facing_front and leftward:
        mirrored_eyes = [(CANVAS[0] - x, y) for x, y in reversed(eyes)]
        head = fitted_head(drawings["head-front"], EYES["front"], mirrored_eyes).transpose(FLIP)
    else:
        profile = "front" if facing_front else "side"
        head = fitted_head(drawings["head-front" if facing_front else "head"], EYES[profile], eyes)
    actor = rig(drawings, tail, torso, head, hips, feet, (0, 2) if facing_front else (2, 3), side)
    return actor.transpose(FLIP) if leftward else actor


def action_frame(drawings: dict, t: float, seated: Image.Image) -> tuple[Image.Image, float]:
    if t < .48:
        attention = .024 * ease(max(0, (t - .29) / .19))
        return stamp(seated, ROOT, ROOT, angle=attention), 0

    first_feet, _ = step_marks(0)
    if t < 1.01:
        return bridged_seat(drawings, (t - .48) / .53, KEYS[0], first_feet), 0

    if t < 2.88:
        distance = STRIDE * 2 * ease((t - 1.01) / 1.87)
        phase = (distance / STRIDE) % 1
        mark = phase * len(KEYS)
        frame = int(mark)
        pose = mix_pose(KEYS[frame], KEYS[(frame + 1) % len(KEYS)], mark - frame)
        feet, _ = step_marks(phase)
        return flatten(compose_layers(drawings, pose, feet)), distance

    distance = 2 * STRIDE
    if t < 3.22:
        progress = (t - 2.88) / .34
        pose = mix_pose(KEYS[0], STANCE, ease(progress))
        feet = stepping_between(first_feet, standing_marks(), progress, 14)
        return flatten(compose_layers(drawings, pose, feet)), distance

    if t < 3.98:
        progress = ease((t - 3.22) / .76)
        leftward = progress > .5
        part = (1 - progress if leftward else progress) * 2
        if part >= .87:
            return head_on_turn(drawings, 1, False), distance
        return head_on_turn(drawings, part / .87, leftward), distance

    if t < 4.43:
        actor = bridged_seat(drawings, 1 - (t - 3.98) / .45, STANCE, standing_marks())
        return actor.transpose(FLIP), distance
    return seated.transpose(FLIP), distance


def main() -> None:
    artwork = load_drawings()
    seated = seated_drawing()
    backdrop = Image.new("RGB", SIZE, "#e9e9db")
    ground = ImageDraw.Draw(backdrop)
    ground.rectangle((0, FLOOR - 124, SIZE[0], SIZE[1]), fill="#dfe1d2")
    ground.line((0, FLOOR, SIZE[0], FLOOR), fill="#aab39f")
    for x in range(8, SIZE[0], 12):
        ground.line((x, FLOOR, x, FLOOR + (8 if (x - 8) % 36 == 0 else 3)), fill="#a9b39e")

    mp4 = SOURCE / "acting-rehearsal.mp4"
    command = ["ffmpeg", "-v", "error", "-y", "-f", "rawvideo", "-pix_fmt", "rgb24",
               "-s", f"{SIZE[0]}x{SIZE[1]}", "-framerate", str(FPS), "-i", "-", "-an",
               "-c:v", "libx264", "-crf", "19", "-pix_fmt", "yuv420p", "-movflags", "+faststart", str(mp4)]
    with subprocess.Popen(command, stdin=subprocess.PIPE) as output:
        for frame in range(FRAMES):
            actor, distance = action_frame(artwork, frame / FPS, seated)
            actor = actor.resize(tuple(round(d * SCALE) for d in CANVAS), Image.Resampling.LANCZOS)
            image = backdrop.copy()
            image.paste(actor, (round(START_X + (distance - ROOT[0]) * SCALE), round(FLOOR - ROOT[1] * SCALE)), actor)
            output.stdin.write(image.tobytes())
        output.stdin.close()
        if output.wait():
            raise RuntimeError("FFmpeg could not save the acting sample")


if __name__ == "__main__":
    main()
