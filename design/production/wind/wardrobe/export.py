"""Pack the six complete scarf portraits onto the existing stage-three rigs."""
from pathlib import Path

from PIL import Image


def main():
    source = Path(__file__).resolve().parent
    assets = source.parents[3] / "apps/mobile/assets"
    target = assets / "wind/wardrobe"
    target.mkdir(parents=True, exist_ok=True)
    atlas = Image.open(source / "worn-portraits.png").convert("RGBA")
    cell_width, cell_height = atlas.width // 3, atlas.height // 2
    # Remove transparent image-generator padding while preserving the paint edge.
    alpha = [round(max(0, min(1, (n - 5) / 245)) * 255) for n in range(256)]
    for row, prefix in enumerate(("", "leap-")):
        for column, garment in enumerate(("", "-coat", "-apron")):
            name = f"{prefix}rabbit-3{garment}.webp"
            with Image.open(assets / "art" / name) as original:
                size = original.size
                bounds = original.getchannel("A").point(lambda n: 255 if n > 12 else 0).getbbox()
            x, y = column * cell_width, row * cell_height
            tile = atlas.crop((x, y, x + cell_width, y + cell_height))
            tile.putalpha(tile.getchannel("A").point(alpha))
            cutout = tile.crop(tile.getbbox())
            left, top, right, bottom = bounds
            cutout = cutout.resize((right - left, bottom - top), Image.Resampling.LANCZOS)
            frame = Image.new("RGBA", size)
            frame.alpha_composite(cutout, (left, top))
            frame.save(target / name, quality=93, method=6, exact=False)


if __name__ == "__main__":
    main()
