#!/usr/bin/env python3
"""Fit the three production accessory handoffs to the released actor paintings."""

import argparse
import hashlib
import json
import math
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "apps/mobile/assets"
ART = ASSETS / "art"
WALK_SIZE = (512, 464)
RESAMPLE = Image.Resampling.LANCZOS


def rgba(path):
    with Image.open(path) as image:
        return image.convert("RGBA")


def compose(*tiles):
    canvas = Image.new("RGBA", tiles[0].size)
    for tile in tiles:
        canvas.alpha_composite(tile)
    return canvas


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def tight(tile):
    return tile.crop(tile.getchannel("A").getbbox())


def placed(tile, canvas_size, box):
    x, y, w, h = box
    canvas = Image.new("RGBA", canvas_size)
    canvas.alpha_composite(tile.resize((w, h), RESAMPLE), (x, y))
    return canvas


def cut_fur(tile, mask):
    tile = tile.copy()
    tile.putalpha(ImageChops.multiply(tile.getchannel("A"), ImageOps.invert(mask)))
    return tile


def fur_mask(size, points, radius=.75):
    alpha = Image.new("L", size)
    ImageDraw.Draw(alpha).polygon(points, fill=255)
    return alpha.filter(ImageFilter.GaussianBlur(radius))


def stable_base(base, original, mirror=False):
    pixels = rgba(base)
    if mirror:
        pixels = ImageOps.mirror(pixels)
    if pixels.tobytes() != rgba(original).tobytes():
        raise ValueError(f"Registration of {base.name} drifted from {original.name}")


def export_costume_views(kit, job, name, plate, base, sources, shifts):
    kit.write(job, name, plate, base, sources)
    for garment, offset in shifts.items():
        costume = base.with_name(f"{base.stem}-{garment}{base.suffix}")
        translated = Image.new("RGBA", rgba(costume).size)
        translated.alpha_composite(plate, offset)
        kit.write(job, f"{name}-{garment}", translated, costume, sources)


class Export:
    def __init__(self, returns):
        self.returns = returns
        self.assets = []
        self.thumbnails = []

    def source(self, job, name):
        return self.returns / job / "r02-openai/production-v2" / f"{name}.png"

    def write(self, job, name, plate, base, sources):
        dest = ART / f"wardrobe-{name}.webp"
        actor_size = rgba(base).size
        if plate.size != actor_size or not plate.getbbox() or plate.getbbox() == (0, 0, *actor_size):
            raise ValueError(f"{name} has non-local paint or the wrong actor canvas")
        plate.save(dest, lossless=True, exact=True)
        self.assets.append({
            "work_order": job,
            "runtime_path": dest.relative_to(ROOT).as_posix(),
            "runtime_size": list(plate.size),
            "paint_bbox": list(plate.getbbox()),
            "sha256": digest(dest),
            "pose": {"path": base.relative_to(ROOT).as_posix(), "sha256": digest(base)},
            "sources": [{"file": path.name, "sha256": digest(path)} for path in sources],
        })

    def thumbnail(self, job, name, image, sources):
        tile = tight(image)
        tile.thumbnail((320, 320), RESAMPLE)
        path = ART / f"wardrobe-{name}-thumbnail.webp"
        tile.save(path, lossless=True, exact=True)
        self.thumbnails.append({
            "work_order": job,
            "runtime_path": path.relative_to(ROOT).as_posix(),
            "runtime_size": list(tile.size),
            "sha256": digest(path),
            "sources": [{"file": source.name, "sha256": digest(source)} for source in sources],
        })


def bow(kit):
    job = "AC-01"
    side = ASSETS / "fox_walk/head.webp"
    seat = ART / "fox-1.webp"
    air = ART / "leap-fox-1.webp"
    sitting = {"coat": (2, 0), "apron": (1, 0)}
    flying = {"coat": (2, 6), "apron": (3, 1)}
    board = kit.returns / job / "r02-openai/design-board-transparent-candidate.png"
    kit.thumbnail(job, "fox-bow", rgba(board).crop((20, 112, 640, 470)), [board])
    layers = {}
    for source, name, base in (
        ("seated", "seated", seat),
        ("right", "walk-side", side),
        ("front", "walk-front", ASSETS / "fox_walk/head-front.webp"),
        ("back", "walk-back", ASSETS / "fox_walk/head-away.webp"),
        ("left", "walk-left", side),
    ):
        stable_base(base, kit.source(job, f"{source}__unworn"), mirror=source == "left")
        paper = kit.source(job, f"{source}__bow-cloth")
        fur = kit.source(job, f"{source}__original-ear-fur-occlusion")
        face = cut_fur(rgba(paper), rgba(fur).getchannel("A"))
        layers[source] = (tight(face), [paper, fur])
        if source == "left":
            # Retain the far knot's ear-root pivot while tucking its wings back.
            side_mask = fur_mask(WALK_SIZE, [(47, 115), (64, 122), (81, 107), (86, 135), (47, 148)])
            reduced = placed(tight(face), WALK_SIZE, (52, 94, 27, 32))
            face = ImageOps.mirror(cut_fur(reduced, side_mask))
        if source == "seated":
            export_costume_views(kit, job, f"fox-bow-{name}", face, base, [paper, fur], sitting)
        else:
            kit.write(job, f"fox-bow-{name}", face, base, [paper, fur])

    look_left, sources = layers["left"]
    export_costume_views(
        kit, job, "fox-bow-seated-left",
        placed(ImageOps.mirror(look_left), rgba(seat).size, (298, 101, 25, 30)),
        seat, sources, sitting,
    )
    air_size = rgba(air).size
    close, sources = layers["seated"]
    tuft = fur_mask(air_size, [(186, 111), (206, 116), (210, 125), (201, 130), (180, 120)])
    export_costume_views(
        kit, job, "fox-bow-airborne",
        cut_fur(placed(close, air_size, (177, 77, 60, 36)), tuft), air, sources, flying,
    )
    export_costume_views(
        kit, job, "fox-bow-airborne-left",
        placed(ImageOps.mirror(look_left), air_size, (302, 47, 24, 29)),
        air, layers["left"][1], flying,
    )


def neckerchief(kit):
    job = "AC-02"
    for view, source, suffix in (
        ("seated", "seated", ""),
        ("seated-apron", "apron-seated", "-apron"),
    ):
        base = ART / f"rabbit-1{suffix}.webp"
        stable_base(base, kit.source(job, f"{source}__unworn"))
        paths = [kit.source(job, f"{source}__{name}") for name in (
            "rear-knot-visible", "neck-ring", "front-leaf-embroidered-point",
            "original-underjaw-fur-occlusion",
        )]
        knot, ring, leaf, fur = map(rgba, paths)
        plate = compose(knot, cut_fur(compose(ring, leaf), fur.getchannel("A")))
        if view == "seated":
            kit.thumbnail(job, "rabbit-neckerchief", compose(knot, ring, leaf), paths[:3])
            export_costume_views(kit, job, f"rabbit-neckerchief-{view}", plate, base, paths,
                                 {"coat": (0, -1)})
        else:
            kit.write(job, f"rabbit-neckerchief-{view}", plate, base, paths)
    paths = [kit.source(job, f"jump__{name}") for name in (
        "rear-knot-visible", "neck-ring", "front-leaf-embroidered-point",
    )]
    knot, ring, leaf = [tight(rgba(path)) for path in paths]
    for suffix, boxes, jaw in (
        ("", [(244, 156, 38, 25), (279, 151, 94, 32), (265, 162, 76, 41)],
         [(272, 143), (390, 142), (383, 161), (358, 174), (330, 176), (301, 171), (278, 165)]),
        ("-apron", [(244, 152, 34, 20), (266, 154, 101, 31), (265, 160, 71, 35)],
         [(260, 137), (391, 140), (387, 157), (356, 170), (322, 172), (285, 164), (260, 160)]),
        ("-coat", [(242, 152, 36, 23), (268, 153, 101, 31), (265, 160, 71, 36)],
         [(260, 138), (390, 140), (385, 157), (353, 170), (319, 172), (285, 164), (260, 161)]),
    ):
        base = ART / f"leap-rabbit-1{suffix}.webp"
        actor = rgba(base)
        pieces = [placed(body, actor.size, box) for body, box in zip([knot, ring, leaf], boxes)]
        plate = cut_fur(compose(*pieces), fur_mask(actor.size, jaw))
        plate.putalpha(ImageChops.multiply(plate.getchannel("A"), actor.getchannel("A")))
        kit.write(job, f"rabbit-neckerchief-airborne{suffix}", plate, base, paths)


def raw_lens(rim, glass):
    return compose(glass, rim)


def lens_center(center, size):
    return (round(center[0] - size[0] / 2), round(center[1] - size[1] / 2), *size)


def closest_ink(tile, point, radius=10):
    # Use the true painted edge distinctly from the very pale glass fill.
    alpha = tile.getchannel("A")
    x, y = (round(value) for value in point)
    candidates = [
        (px, py) for py in range(y - radius, y + radius + 1)
        for px in range(x - radius, x + radius + 1)
        if 0 <= px < tile.width and 0 <= py < tile.height
        and alpha.getpixel((px, py)) >= 52
    ]
    if not candidates:
        raise ValueError(f"Missing painted contact at {point}")
    return min(candidates, key=lambda p: (p[0] - x)**2 + (p[1] - y)**2)


def strand(source, size, start, end):
    # A similarity transform joins the hand-painted ends to two real rim
    # samples, retaining the bend and paper grain of the original stroke.
    alpha = source.getchannel("A").point(lambda value: 255 if value > 48 else 0)
    lo, _, hi, _ = alpha.getbbox()
    border = []
    for x in (lo + 2, hi - 3):
        hit = [y for y in range(source.height) if alpha.getpixel((x, y))]
        if not hit:
            raise ValueError("Missing strand attachment")
        border.append(complex(x, sum(hit) / len(hit)))
    start, end = complex(*start), complex(*end)
    scale = (border[1] - border[0]) / (end - start)
    shift = border[0] - start * scale
    inverse = (scale.real, -scale.imag, shift.real, scale.imag, scale.real, shift.imag)
    return source.transform(size, Image.Transform.AFFINE, inverse, Image.Resampling.BICUBIC)


def glasses(kit):
    job = "AC-03"
    paths = [kit.source(job, f"right__{name}") for name in (
        "near-reed-ring-lens-clear", "near-glass-generated-tint-alpha12",
        "far-reed-ring-lens-clear", "far-glass-generated-tint-alpha12",
        "reed-nose-bridge", "temple-near-behind-fur",
    )]
    near_rim, near_tint, far_rim, far_tint, bridge, temple = map(rgba, paths)
    near = tight(raw_lens(near_rim, near_tint))
    far = tight(raw_lens(far_rim, far_tint))
    seat = ART / "cat-1.webp"
    stable_base(seat, kit.source(job, "right__unworn"))
    for spec in (
        ("seated", seat, (208, 177), (312, 155), (82, 87), (48, 65), (144, 161), None),
        ("airborne", ART / "leap-cat-1.webp", (263, 110), (324, 89), (56, 60), (28, 43), (205, 100), None),
        ("walk-side", ASSETS / "cat_walk/head.webp",
         (337, 167), (433, 147), (75, 80), (44, 60), (278, 152), None),
        ("walk-front", ASSETS / "cat_walk/head-front.webp",
         (208, 178), (305, 178), (80, 81), (80, 81), (135, 154), (381, 155)),
    ):
        view, base, lead, other, lead_wh, other_wh, ear, other_ear = spec
        size = rgba(base).size
        lens_a = placed(near, size, lens_center(lead, lead_wh))
        lens_b = placed(far if other_ear is None else ImageOps.mirror(near),
                        size, lens_center(other, other_wh))

        def contact(lens, center, wh, edge):
            return closest_ink(lens, (center[0] + edge * wh[0] * .45, center[1] - wh[1] * .16))

        left_at = contact(lens_a, lead, lead_wh, 1)
        right_at = contact(lens_b, other, other_wh, -1)
        bent = strand(tight(bridge), size, left_at, right_at)
        near_arm = strand(tight(temple), size, ear, contact(lens_a, lead, lead_wh, -1))
        stack = [near_arm]
        if other_ear is not None:
            stack.append(strand(
                ImageOps.mirror(tight(temple)), size,
                contact(lens_b, other, other_wh, 1), other_ear,
            ))
        paint = compose(*stack, bent, lens_a, lens_b)
        if view == "walk-front":
            kit.thumbnail(job, "cat-glasses", paint, paths)
        shifts = {
            "seated": {"coat": (0, -1), "apron": (-2, -1)},
            "airborne": {"coat": (4, 0), "apron": (0, -2)},
        }
        export_costume_views(kit, job, f"cat-glasses-{view}", paint, base, paths,
                             shifts.get(view, {}))

    rear = ASSETS / "cat_walk/head-away.webp"
    paths = [kit.source(job, f"back-detail__visible-{side}-temple-only") for side in ("left", "right")]
    stems = [placed(tight(rgba(path)), WALK_SIZE, box) for path, box in
             zip(paths, [(135, 137, 10, 22), (369, 137, 10, 22)])]
    kit.write(job, "cat-glasses-walk-back", compose(*stems), rear, paths)


def main():
    args = argparse.ArgumentParser(description=__doc__)
    args.add_argument("returns", type=Path)
    pack = Export(args.parse_args().returns)
    bow(pack)
    neckerchief(pack)
    glasses(pack)
    print(json.dumps({
        "work_orders": ["AC-01", "AC-02", "AC-03"],
        "source_revision": "r02-openai/production-v2",
        "device_qa": "pending",
        "assets": pack.assets,
        "catalog_thumbnails": pack.thumbnails,
    }, indent=2))


if __name__ == "__main__":
    main()
