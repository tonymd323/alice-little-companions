"""Place the authored transparent motion on the captured game camera."""
import argparse
import json
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


FONT = "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc"


def open_frame(path):
    with Image.open(path) as frame:
        return frame.convert("RGBA")


def root_advance(poses, moment):
    for left, right in zip(poses, poses[1:]):
        if moment <= right["time"]:
            t = (moment - left["time"]) / (right["time"] - left["time"])
            return left["advance"] * (1 - t) + right["advance"] * t
    return poses[-1]["advance"]


def ground_shadow(scene, center_x, sole_y):
    shade = Image.new("RGBA", scene.size)
    ImageDraw.Draw(shade).ellipse(
        (center_x - 58, sole_y - 8, center_x + 58, sole_y + 8),
        fill=(49, 60, 38, 113),
    )
    scene.alpha_composite(shade.filter(ImageFilter.GaussianBlur(7)))


def touch_mark(scene, target, frames_since_tap):
    if frames_since_tap not in range(8):
        return
    x, y = target
    radius = 6 + frames_since_tap * 1.9
    overlay = Image.new("RGBA", scene.size)
    ImageDraw.Draw(overlay).ellipse(
        (x - radius, y - radius, x + radius, y + radius),
        outline=(255, 252, 214, 195 - frames_since_tap * 19),
        width=2,
    )
    scene.alpha_composite(overlay)


def video(path, size, fps):
    return subprocess.Popen([
        "ffmpeg", "-y", "-v", "error", "-f", "rawvideo", "-pixel_format", "rgb24",
        "-video_size", f"{size[0]}x{size[1]}", "-framerate", str(fps), "-i", "-",
        "-c:v", "libx264", "-crf", "18", "-preset", "fast", "-pix_fmt", "yuv420p",
        "-movflags", "+faststart", str(path),
    ], stdin=subprocess.PIPE)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("shipped", "empty", "art", "poses", "output"):
        parser.add_argument(name, type=Path)
    args = parser.parse_args()
    take = json.loads((args.shipped / "take.json").read_text())
    clean_take = json.loads((args.empty / "take.json").read_text())
    for key in ("screen_start", "screen_target", "raw_scale", "start_frame", "fps"):
        assert take[key] == clean_take[key], key
    spec = json.loads(args.poses.read_text())
    frames = sorted(args.art.glob("cat-*.png"))
    if not frames:
        raise ValueError("No transparent motion frames in " + str(args.art))
    example = open_frame(args.shipped / "court-000.png")
    width, height = example.size
    scale = take["raw_scale"]
    screen_root = take["screen_start"]
    art_root = spec["rootStart"]
    anchor = tuple(round(a - b * scale) for a, b in zip(screen_root, art_root))
    art_size = tuple(round(value * scale) for value in spec["canvas"])
    goal = screen_root[0] + scale * (spec["rootEnd"][0] - art_root[0])
    assert abs(goal - take["screen_target"][0]) < .1
    fps = take["fps"]
    fullscreen = sorted(args.shipped.glob("court-*.png"))
    comparison_size = (2 * width, height + 48)
    args.output.mkdir(parents=True, exist_ok=True)
    compare = video(args.output / "tuantuan-comparison.mp4", comparison_size, fps)
    rehearsal = video(args.output / "tuantuan-rehearsal.mp4", (width, height), fps)
    font = ImageFont.truetype(FONT, size=26)
    try:
        for index, original in enumerate(fullscreen):
            t = max(0, index - take["start_frame"]) / fps
            art_frame = min(round(t * spec["fps"]), len(frames) - 1)
            picture = open_frame(frames[art_frame])
            assert tuple(spec["canvas"]) == picture.size
            before = open_frame(original)
            after = open_frame(args.empty / original.name)
            ground_shadow(after, screen_root[0] + scale * root_advance(spec["poses"], t), screen_root[1])
            after.alpha_composite(picture.resize(art_size, Image.Resampling.LANCZOS), anchor)
            for scene in (before, after):
                touch_mark(scene, take["screen_target"], index - take["start_frame"])
            output = Image.new("RGB", comparison_size, (44, 35, 30))
            output.paste(before.convert("RGB"), (0, 48))
            output.paste(after.convert("RGB"), (width, 48))
            labels = ImageDraw.Draw(output)
            labels.text((20, 4), "0.16 家庭版", fill=(255, 247, 230), font=font)
            labels.text((width + 20, 4), "团团短程表演小样", fill=(255, 247, 230), font=font)
            compare.stdin.write(output.tobytes())
            rehearsal.stdin.write(after.convert("RGB").tobytes())
    finally:
        for worker in (compare, rehearsal):
            worker.stdin.close()
        codes = [compare.wait(), rehearsal.wait()]
        assert codes == [0, 0], "ffmpeg failed"


if __name__ == "__main__":
    main()
