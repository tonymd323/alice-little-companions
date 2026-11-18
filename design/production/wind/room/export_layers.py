"""Export the editable OpenRaster scene and home overlays for the Flutter asset bundle."""

from __future__ import annotations

import argparse
import io
import json
from dataclasses import dataclass
from pathlib import Path
from xml.etree import ElementTree
from zipfile import ZipFile

from PIL import Image


ART = Path(__file__).resolve().parent
DEFAULT_OUTPUT = ART.parents[3] / "apps/mobile/assets/wind/room"
ASSET_PREFIX = "assets/wind/room"


@dataclass(frozen=True)
class Layer:
    pixels: Image.Image
    offset: tuple[int, int]


def read_layers(path: Path) -> tuple[tuple[int, int], dict[str, Layer]]:
    with ZipFile(path) as package:
        image = ElementTree.fromstring(package.read("stack.xml"))
        size = int(image.attrib["w"]), int(image.attrib["h"])
        layers = {}
        for node in image.iter("layer"):
            role = node.attrib["name"].split(" · ", maxsplit=1)[0]
            if role == "reference-restored":
                continue
            pixels = Image.open(io.BytesIO(package.read(node.attrib["src"])))
            pixels.load()
            offset = int(node.attrib.get("x", "0")), int(node.attrib.get("y", "0"))
            layers[role] = Layer(pixels, offset)
        return size, layers


def composite(size: tuple[int, int], *layers: Layer, trim: bool = True) -> Layer:
    canvas = Image.new("RGBA", size)
    for layer in layers:
        canvas.alpha_composite(layer.pixels.convert("RGBA"), layer.offset)
    if trim:
        box = canvas.getchannel("A").getbbox()
        if box is None:
            raise ValueError("The requested artwork has no visible pixels")
        return Layer(canvas.crop(box), box[:2])
    return Layer(canvas, (0, 0))


def export(output: Path) -> None:
    output.mkdir(parents=True, exist_ok=True)
    size, room = read_layers(ART / "wind-room.ora")
    home_size, home = read_layers(ART / "home-restoration.ora")

    def write(key: str, layer: Layer, canvas: tuple[int, int] = size) -> dict:
        name = f"{key}.webp"
        x, y = layer.offset
        w, h = layer.pixels.size
        if not (0 <= x < x + w <= canvas[0] and 0 <= y < y + h <= canvas[1]):
            raise ValueError(f"{key} extends beyond the camera")
        layer.pixels.save(
            output / name, "WEBP", quality=93, method=5, alpha_quality=100, exact=True
        )
        return {
            "path": f"{ASSET_PREFIX}/{name}",
            "rect": [
                round(value / length, 8)
                for value, length in zip((x, y, x + w, y + h), canvas * 2)
            ],
        }

    base = write("room-base", room["room-base"])
    cells = []
    lights = []
    for window in range(3):
        for cell in range(4):
            key = f"glass-{window + 1}-{cell + 1}"
            cells.append({"window": window, "cell": cell, **write(key, room[key])})
        light = composite(
            size, room[f"bridge-light-{window + 1}"], room[f"floor-light-{window + 1}"]
        )
        lights.append({"window": window, **write(f"light-{window + 1}", light)})
    rail = write("bridge-rail", room["bridge-rail"])
    home_overlay = composite(
        home_size, home["home-glass"], home["home-floor"], home["home-bridge"], trim=False
    )
    mounted_home = write("home-restored", home_overlay, home_size)
    manifest = {
        "size": list(size),
        "base": base,
        "cells": cells,
        "lights": lights,
        "rail": rail,
        "bridge": [[.164, .594], [.33, .562], [.49, .549], [.66, .557], [.816, .593]],
        "actors": {"rabbit": [.37, .87], "basket": [.62, .875], "door": [.94, .82]},
        "home": {**mounted_home, "size": list(home_size)},
    }
    (output / "room.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, default=DEFAULT_OUTPUT)
    export(parser.parse_args().out)
