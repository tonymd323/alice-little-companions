#!/usr/bin/env python3
"""Encode the two routes recorded by apps/mobile/tool/capture_wind_test.dart.

Requires Python with Pillow and NumPy, FFmpeg with libx264, and a Chinese font.
All audio times are read from the production chapter's platform-channel log.
"""
import argparse
import hashlib
import json
import math
import shutil
import subprocess
import wave
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
SOUNDS = ROOT / "apps/mobile/assets/wind/audio"


def read_stereo(path):
    with wave.open(str(path), "rb") as source:
        if (source.getnchannels(), source.getsampwidth()) != (2, 2):
            raise ValueError(f"{path.name} requires signed 16-bit stereo PCM")
        return source.getframerate(), np.frombuffer(
            source.readframes(source.getnframes()), dtype="<i2"
        ).reshape(-1, 2)


def soundtrack(folder, route):
    """Same cue restarts from its beginning, matching Android and iOS players."""
    sounds = {p.stem: read_stereo(p) for p in SOUNDS.glob("*.wav")}
    rates = {r for r, _ in sounds.values()}
    if len(rates) != 1:
        raise ValueError(f"Expected one rate across the original cues, got {rates}")
    rate = rates.pop()
    n = round(route["frames"] * rate / route["fps"])
    mix = np.zeros((n, 2), dtype=np.float64)
    # Track intervals in reverse to truncate each cue at its next start or stop.
    next_start = {}
    next_stop = n
    for event in reversed(route["audio"]):
        begin = round(event["frame"] * rate / route["fps"])
        method = event["method"]
        cue = event["argument"]
        if method == "stop" or (method == "setMuted" and cue):
            next_stop = begin
        if method != "play":
            continue
        samples = sounds[cue][1]
        end = min(begin + len(samples), next_start.get(cue, n), next_stop, n)
        mix[begin:end] += samples[: end - begin]
        next_start[cue] = begin
    peak = float(np.abs(mix).max())
    gain = min(1.0, 32766 / max(peak, 1))
    with wave.open(str(folder / "soundtrack.wav"), "wb") as out:
        out.setnchannels(2)
        out.setsampwidth(2)
        out.setframerate(rate)
        out.writeframes(np.rint(mix * gain).astype("<i2").tobytes())
    return {
        "sampleRate": rate,
        "frameRate": route["fps"],
        "sourcePeakDbfs": round(20 * math.log10(peak / 32768), 2),
        "gain": round(gain, 6),
        "source": "apps/mobile/assets/wind/audio/*.wav",
        "eventTimes": "far-first.json",
    }


def contact_sheet(folder, routes, font):
    shots = [
        ("opening.png", "风起，桥上还有缺口"),
        ("scarf-contact.png", "桃桃的前爪压住围巾"),
        ("basket.png", "两爪把叶篮推来"),
        ("window-gaps.png", "七片在窗上，五片在篮里"),
        ("leaf-in-hand.png", "从叶篮拿起第一片"),
        ("far-light-gap.png", "先补远窗，奶油还在缺口等"),
        ("middle-path.png", "先补中窗，奶油走到下一段"),
        ("crossing.png", "光路连通，奶油跑过石桥"),
        ("reunion.png", "在暖廊门口团圆"),
    ]
    shot_index = {
        still["file"]: (route, still)
        for route in routes.values() for still in route["stills"]
    }
    # Select the actual contact from the emitted scarf cue, which precedes
    # the held pose and subsequent reach in the continuous opening shot.
    far = routes["far-first"]
    contact = next(e for e in far["audio"] if e["method"] == "play" and e["argument"] == "scarf")
    frame = contact["frame"]
    shutil.copyfile(folder / "frames" / f"frame-{frame:04d}.png",
                    folder / "stills/scarf-contact.png")
    shot_index["scarf-contact.png"] = (far, {"frame": frame})
    cols, width, gap, pad = 3, 320, 18, 30
    height = round(width * 4 / 3)
    top, stride = 106, height + 65
    canvas = Image.new("RGB", (2 * pad + cols * width + (cols - 1) * gap,
                               top + 3 * stride + 8), "#fbf4e7")
    draw = ImageDraw.Draw(canvas)
    title = ImageFont.truetype(str(font), 39)
    label = ImageFont.truetype(str(font), 20)
    small = ImageFont.truetype(str(font), 15)
    draw.text((pad, 12), "风过暖廊", font=title, fill="#4a372e")
    draw.text((pad, 67), "两种补窗顺序的游戏画面", font=label, fill="#75594a")
    for index, (filename, caption) in enumerate(shots):
        route, still = shot_index[filename]
        x = pad + index % cols * (width + gap)
        y = top + index // cols * stride
        with Image.open(folder / "stills" / filename) as shot:
            area = shot.crop(tuple(route["stageRect"]))
            if abs(area.width / area.height - width / height) > 0.005:
                raise ValueError(f"Unexpected canvas aspect in {filename}")
            canvas.paste(area.convert("RGB").resize((width, height), Image.Resampling.LANCZOS), (x, y))
        draw.text((x, y + height + 3), caption, font=label, fill="#45342b")
        stamp = still["frame"] / route["fps"]
        note = "中窗先补 · 静音" if route["muted"] else "远窗先补"
        draw.text((x, y + height + 33), f"{stamp:.1f} s   {note}", font=small, fill="#775c4c")
    canvas.save(folder / "wind-contact-sheet.jpg", quality=92, optimize=True)


def hash_inputs_and_evidence(folder):
    mobile = ROOT / "apps/mobile"
    inputs = [
        mobile / "lib/features/wind_chapter.dart",
        mobile / "lib/features/garden.dart",
        mobile / "lib/application/family.dart",
        mobile / "lib/domain/wind_progress.dart",
        mobile / "tool/capture_wind_test.dart",
        Path(__file__).resolve(),
        *mobile.glob("lib/illustration/wind*.dart"),
        *(p for p in (mobile / "assets/wind").rglob("*")
          if p.is_file() and p.parent.name in {"actors", "audio", "room"}),
    ]
    evidence = [
        folder / name for name in ["wind-veranda.mp4", "wind-contact-sheet.jpg",
                                   "far-first.json", "middle-first.json", "mix.json"]
    ] + list((folder / "stills").glob("*.png"))

    def fingerprints(base, paths):
        return {
            str(path.relative_to(base)): hashlib.sha256(path.read_bytes()).hexdigest()
            for path in sorted(paths)
        }

    identity = {
        "source": fingerprints(ROOT, inputs),
        "evidence": fingerprints(folder, evidence),
    }
    (folder / "capture-sha256.json").write_text(
        json.dumps(identity, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )


def capture_routes(folder, font, serif):
    # Each widget test gets its own fresh engine, isolate and fake test clock.
    folder.mkdir(parents=True, exist_ok=True)
    for route in ("far-first", "middle-first"):
        log = folder / f"{route}-test.log"
        print(f"Recording {route} ({log})", flush=True)
        with log.open("w", encoding="utf-8") as output:
            subprocess.run(
                ["flutter", "test", "--no-pub", "--reporter", "expanded",
                 "--plain-name", f"record production chapter {route}",
                 f"--dart-define=ALICE_WIND_OUTPUT={folder}",
                 f"--dart-define=ALICE_CJK_FONT={font.resolve()}",
                 f"--dart-define=ALICE_CJK_SERIF={serif.resolve()}",
                 "tool/capture_wind_test.dart"],
                cwd=ROOT / "apps/mobile", stdout=output, stderr=subprocess.STDOUT, check=True,
            )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("folder", type=Path)
    parser.add_argument("--font", type=Path,
                        default=Path("/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc"))
    parser.add_argument("--serif", type=Path,
                        default=Path("/usr/share/fonts/opentype/noto/NotoSerifCJK-Regular.ttc"))
    parser.add_argument("--capture", action="store_true",
                        help="record both routes in separate Flutter test processes before encoding")
    args = parser.parse_args()
    folder = args.folder.resolve()
    if args.capture:
        capture_routes(folder, args.font, args.serif)
    routes = {name: json.loads((folder / f"{name}.json").read_text(encoding="utf-8"))
              for name in ("far-first", "middle-first")}
    far = routes["far-first"]
    for name, route in routes.items():
        if route["final"] != {"mask": 31, "windowsLit": True, "experience": 0, "balance": 0}:
            raise ValueError(f"{name} did not finish with the expected family state")
    audio_stats = soundtrack(folder, far)
    (folder / "mix.json").write_text(
        json.dumps(audio_stats, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )
    subprocess.run(
        ["ffmpeg", "-hide_banner", "-loglevel", "warning", "-y",
         "-framerate", str(far["fps"]), "-start_number", "0",
         "-i", str(folder / "frames/frame-%04d.png"), "-i", str(folder / "soundtrack.wav"),
         "-map", "0:v:0", "-map", "1:a:0", "-frames:v", str(far["frames"]),
         "-c:v", "libx264", "-preset", "medium", "-crf", "19", "-threads", "3",
         "-vf", "scale=out_color_matrix=bt709:out_range=tv,format=yuv420p",
         "-colorspace", "bt709", "-color_primaries", "bt709", "-color_trc", "bt709",
         "-c:a", "aac", "-b:a", "160k", "-movflags", "+faststart",
         str(folder / "wind-veranda.mp4")],
        check=True,
    )
    contact_sheet(folder, routes, args.font)
    hash_inputs_and_evidence(folder)


if __name__ == "__main__":
    main()
