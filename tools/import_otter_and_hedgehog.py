#!/usr/bin/env python3
"""Export companion paintings from SP-01, SP-02, EV-02 and EV-03."""

import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image, ImageOps

from import_fox_painted_outfit import cutout


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "apps/mobile/assets"
MOTION_CANVAS = (512, 464)
GROUND = 440
POSES = ("stand", "reach", "follow", "brace", "front", "back",
         "turnFront", "turnBack", "skill")
SPECIES = (
    ("otter", "SP-01", "EV-02", "otter_six_stages", 4),
    ("hedgehog", "SP-02", "EV-03", "hedgehog_six_stages", 5),
)
TURN_SHEETS = {
    "otter": (
        ("six-turns", (0, 426, 718, 1143, 1448), (0, 365, 710, 1086)),
        ("six-near-axial", (0, 724, 1448), (0, 360, 714, 1086)),
    ),
    "hedgehog": (
        ("six-turns", (0, 412, 734, 1100, 1448), (0, 355, 719, 1086)),
        ("six-near-axial", (0, 512, 1024), (0, 476, 990, 1536)),
    ),
}
TURN_VIEWS = (("towards", "front", "away", "rear"), ("near-front", "near-rear"))
REAR_BRIDGE = {"otter": "middle-rear", "hedgehog": "shallow-rear"}


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def plate(path, index=0, grid=(1, 1)):
    with Image.open(path) as file:
        picture = file.convert("RGBA")
    columns, rows = grid
    row, col = divmod(index, columns)
    x0, x1 = (picture.width * i // columns for i in (col, col + 1))
    y0, y1 = (picture.height * i // rows for i in (row, row + 1))
    cell = picture.crop((x0, y0, x1, y1))
    figure, bounds = cutout(cell)
    x, y, rx, by = bounds
    return figure, [x0 + x, y0 + y, x0 + rx, y0 + by]


def save(output, path, source, crop, job, returns, *, quality=None):
    path.parent.mkdir(parents=True, exist_ok=True)
    # Antialiasing is transparent, while the painted interior is matte.
    output.putalpha(output.getchannel("A").point(
        lambda value: 255 if value >= 245 else value
    ))
    if quality is None:
        output.save(path, lossless=True, exact=True)
    else:
        output.save(path, quality=quality, alpha_quality=100, method=6, exact=True)
    return {
        "work_order": job,
        "runtime_path": path.relative_to(ROOT).as_posix(),
        "runtime_size": list(output.size),
        "ink_bounds": list(output.getchannel("A").getbbox()),
        "sha256": digest(path),
        "source": {
            "path": source.relative_to(returns).as_posix(),
            "sha256": digest(source),
            "crop_xyxy": crop,
        },
    }


def stage_plate(returns, species, origin, growth, prefix, first_repaint, stage):
    if species == "otter" and stage == 1:
        reference = "concept_creek_otter__front34__fullcanvas__r02-openai.png"
        return returns / origin / "r02-openai" / reference, 0, (1, 1)
    if stage >= first_repaint:
        source = returns / growth / "app-companions" / f"{species}-growth-r03.png"
        return source, stage - first_repaint, (7 - first_repaint, 1)
    reference = f"concept_{prefix}__S{stage}__fullcanvas__r02-openai.png"
    return returns / growth / "r02-openai" / reference, 0, (1, 1)


def portrait(image, size=None):
    if size is None:
        image.thumbnail((496, 408), Image.Resampling.LANCZOS)
        size = (image.width + 4, image.height + 4)
    width, height = size
    scale = min((width - 4) / image.width, (height - 4) / image.height)
    drawing = image.resize(
        (round(image.width * scale), round(image.height * scale)),
        Image.Resampling.LANCZOS,
    )
    output = Image.new("RGBA", size)
    output.alpha_composite(drawing, ((width - drawing.width) // 2,
                                     height - 2 - drawing.height))
    return output


def walk_frame(image, width, height):
    # The original low body is rendered at the portrait's world scale.
    ratio = min(width / image.width, height / image.height)
    picture = image.resize(
        (round(image.width * ratio), round(image.height * ratio)),
        Image.Resampling.LANCZOS,
    )
    canvas = Image.new("RGBA", MOTION_CANVAS)
    canvas.alpha_composite(picture, ((MOTION_CANVAS[0] - picture.width) // 2,
                                    GROUND - picture.height))
    return canvas


def export_turns(returns):
    entries = []
    for pet, _, growth, _, _ in SPECIES:
        with Image.open(ASSETS / f"art/{pet}-6.webp") as original:
            size = original.size
        for (board, columns, rows), views in zip(TURN_SHEETS[pet], TURN_VIEWS):
            source = returns / growth / "app-companions" / f"{pet}-{board}.png"
            with Image.open(source) as file:
                sheet = file.convert("RGBA")
            if sheet.size != (columns[-1], rows[-1]):
                raise ValueError(f"Unexpected turn sheet dimensions: {source}")
            for row, suffix in enumerate(("", "-coat", "-apron")):
                for col, view in enumerate(views):
                    left, top = columns[col], rows[row]
                    cell = sheet.crop((left, top, columns[col + 1], rows[row + 1]))
                    figure, (x, y, rx, by) = cutout(cell)
                    crop = [left + x, top + y, left + rx, top + by]
                    path = ASSETS / f"{pet}_walk/6-{view}{suffix}.webp"
                    entries.append(save(portrait(figure, size), path, source, crop,
                                        growth, returns, quality=94))
        source = returns / growth / "app-companions" / f"{pet}-six-rear-bridge.png"
        for col, suffix in enumerate(("", "-coat", "-apron")):
            figure, crop = plate(source, col, (3, 1))
            path = ASSETS / f"{pet}_walk/6-{REAR_BRIDGE[pet]}{suffix}.webp"
            entries.append(save(portrait(figure, size), path, source, crop,
                                growth, returns, quality=94))
    return entries


def export(returns):
    entries = []
    for pet, origin, growth, prefix, first_repaint in SPECIES:
        stage_sources = returns / growth / "app-companions"
        last_otter = stage_sources / "otter-water-drop-tip.png"
        dimensions = {}
        for stage in range(1, 7):
            water_drop = pet == "otter" and stage == 6
            if water_drop:
                source, cell, grid = last_otter, 0, (3, 2)
            else:
                source, cell, grid = stage_plate(
                    returns, pet, origin, growth, prefix, first_repaint, stage,
                )
            figure, crop = plate(source, cell, grid)
            if pet == "hedgehog":
                figure = ImageOps.mirror(figure)
            canvas = portrait(figure, (500, 303) if water_drop else None)
            dimensions[stage] = canvas.size
            portrait_entry = save(canvas, ASSETS / f"art/{pet}-{stage}.webp",
                                  source, crop, growth, returns)
            portrait_entry["id"] = f"pet_{pet}_{stage}"
            entries.append(portrait_entry)
        for suffixes, sheet, grid, first_stage, final_cells in (
            (("-coat", "-apron"), "stage-clothes", (3, 4), 1, (1, 2)),
            (("-skill",), "stage-skills", (3, 2), 2, (3,)),
            (("-skill-coat", "-skill-apron"), "habits-wear", (3, 4), 1, (4, 5)),
        ):
            for i, suffix in enumerate(suffixes):
                for stage in range(first_stage, 7):
                    source = stage_sources / f"{pet}-{sheet}.png"
                    cell, layout = i * 6 + stage - 1, grid
                    if pet == "otter" and stage == 6:
                        source, cell, layout = last_otter, final_cells[i], (3, 2)
                    figure, crop = plate(source, cell, layout)
                    path = ASSETS / f"art/{pet}-{stage}{suffix}.webp"
                    entries.append(save(portrait(figure, dimensions[stage]),
                                        path, source, crop, growth, returns))
        motion_sources = returns / origin / "app-companions"
        bare = motion_sources / f"{pet}-s1-poses.png"
        dressed = motion_sources / f"{pet}-movement-wear.png"
        for outfit, (source, suffix, start, grid) in enumerate((
            (bare, "", 0, (3, 3)),
            (dressed, "-coat", 0, (3, 6)),
            (dressed, "-apron", 9, (3, 6)),
        )):
            for cell, pose in enumerate(POSES[:-1]):
                pose_source, index, layout = source, start + cell, grid
                if pet == "hedgehog" and pose == "follow":
                    pose_source = motion_sources / "hedgehog-follow.png"
                    index, layout = outfit, (3, 1)
                figure, crop = plate(pose_source, index, layout)
                width = dimensions[1][0] - 4
                if pose == "front":
                    width = round(width * (.67 if pet == "otter" else .76))
                if pose == "back":
                    width = round(width * (.61 if pet == "otter" else .74))
                canvas = walk_frame(figure, width, dimensions[1][1] - 4)
                path = ASSETS / f"{pet}_walk/full-{pose}{suffix}.webp"
                entries.append(save(canvas, path, pose_source, crop, origin,
                                    returns))
        habit, crop = plate(bare, 8, (3, 3))
        path = ASSETS / f"art/{pet}-1-skill.webp"
        entries.append(save(portrait(habit, dimensions[1]), path, bare,
                            crop, origin, returns))
        if pet == "hedgehog":
            # Keep the burr as an independent ground prop, using the original
            # painted overlap-free region in the position test.
            x, y = 1120, 1077
            with Image.open(bare) as sheet:
                burr, area = cutout(sheet.convert("RGBA").crop((x, y, 1249, 1165)))
            crop = [area[0] + x, area[1] + y, area[2] + x, area[3] + y]
            entries.append(save(burr, ASSETS / "art/hedgehog-chestnut.webp",
                                bare, crop, origin, returns))
    return entries


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("returns", type=Path)
    parser.add_argument("--turns-only", action="store_true")
    args = parser.parse_args()
    base = [] if args.turns_only else export(args.returns)
    print(json.dumps(base + export_turns(args.returns), ensure_ascii=False, indent=2))
