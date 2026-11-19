"""Export the editable Wind Veranda cels, or compare them with the runtime art."""

import argparse
import io
import json
from pathlib import Path
import zipfile
import xml.etree.ElementTree as ET

from PIL import Image


HERE = Path(__file__).resolve().parent
ASSETS = HERE.parents[3] / "apps/mobile/assets/wind/actors"


def render_stack(archive, group, size):
    image = Image.new("RGBA", size)
    for element in reversed(list(group)):
        if element.get("visibility", "visible") == "hidden":
            continue
        if element.get("composite-op", "svg:src-over") != "svg:src-over":
            raise ValueError(f"Unsupported OpenRaster blend in {element.get('name')}")
        if element.tag == "stack":
            layer = render_stack(archive, element, size)
        elif element.tag == "layer":
            with archive.open(element.attrib["src"]) as source:
                layer = Image.open(source).convert("RGBA")
        else:
            continue
        opacity = float(element.get("opacity", "1"))
        if opacity != 1:
            layer.putalpha(layer.getchannel("A").point(lambda a: round(a * opacity)))
        pos = (int(element.get("x", 0)), int(element.get("y", 0)))
        image.alpha_composite(layer, dest=pos)
    return image


def export(args):
    with (HERE / "poses.json").open() as source:
        drawings = json.load(source)
    destination = args.out
    if not args.check:
        destination.mkdir(parents=True, exist_ok=True)
    count = 0
    for package in ("rabbit-poses.ora", "fox-poses.ora", "props.ora"):
        with zipfile.ZipFile(HERE / package) as archive:
            groups = ET.fromstring(archive.read("stack.xml")).find("stack")
            for group in groups.findall("stack"):
                key = group.attrib["name"]
                if key in drawings["actors"]:
                    registration = drawings["actors"][key]["export"]
                    cel = render_stack(archive, group, tuple(registration["sourceSize"]))
                    size = tuple(registration["size"])
                    aligned = Image.new("RGBA", tuple(drawings["canvas"]))
                    aligned.alpha_composite(
                        cel.resize(size, Image.Resampling.LANCZOS),
                        dest=tuple(registration["xy"]),
                    )
                else:
                    record = drawings["props"][key]
                    cel = render_stack(archive, group, tuple(record["sourceSize"]))
                    aligned = cel.resize(tuple(record["size"]), Image.Resampling.LANCZOS)
                output = destination / (key + ".webp")
                with io.BytesIO() as buffer:
                    aligned.save(buffer, "WEBP", quality=94, method=6, alpha_quality=100)
                    if args.check:
                        if buffer.getvalue() != output.read_bytes():
                            raise ValueError(f"Runtime drawing differs from source: {output.name}")
                    else:
                        output.write_bytes(buffer.getvalue())
                count += 1

    for record in drawings["actors"].values():
        del record["export"]
    for record in drawings["props"].values():
        del record["sourceSize"]
    metadata = json.dumps(drawings, ensure_ascii=False, separators=(",", ":")) + "\n"
    target = destination / "poses.json"
    if args.check:
        if json.loads(metadata) != json.loads(target.read_text()):
            raise ValueError("Runtime anchors differ from the production registration")
    else:
        target.write_text(metadata)
    print(f"{'Verified' if args.check else 'Exported'} {count} drawings and their registration.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, default=ASSETS)
    parser.add_argument("--check", action="store_true")
    export(parser.parse_args())
