#!/usr/bin/env python3
"""Fit CL-01 and CL-02 fabric to the original in-game pose paintings."""

from __future__ import annotations

import argparse
from collections import OrderedDict
from dataclasses import dataclass
from io import BytesIO
import json
from pathlib import Path
import xml.etree.ElementTree as ET
from zipfile import ZIP_DEFLATED, ZIP_STORED, ZipFile

from PIL import Image, ImageChops, ImageDraw

from import_pose_accessories import ART, ASSETS, ROOT, RESAMPLE, compose, digest, rgba, tight


def curve(points, closed=True):
    """Follow the fitted contour without the straight corners of a crop."""
    knots = list(points)
    extended = ([knots[-1]] + knots + knots[:2] if closed
                else knots[:1] + knots + knots[-1:])
    path = []
    for a, b, c, d in zip(extended, extended[1:], extended[2:], extended[3:]):
        for step in range(12):
            t = step / 12
            path.append(tuple(
                (2 * q + (r - p) * t + (2 * p - 5 * q + 4 * r - s) * t**2
                 + (s - p + 3 * (q - r)) * t**3) / 2
                for p, q, r, s in zip(a, b, c, d)
            ))
    return path + ([path[0]] if closed else [knots[-1]])


def trace(size, points, width=None, *, soft=True):
    tile = Image.new("L", (size[0] * 3, size[1] * 3))
    coords = [(round(x * 3), round(y * 3))
              for x, y in (curve(points, closed=width is None) if soft else points)]
    if width is None:
        ImageDraw.Draw(tile).polygon(coords, fill=255)
    else:
        ImageDraw.Draw(tile).line(coords, fill=255, width=max(1, round(width * 3)))
    return tile.resize(size, RESAMPLE)


def paint_mask(mask, color):
    layer = Image.new("RGBA", mask.size, color)
    layer.putalpha(mask)
    return layer


def clip(paint, allowed):
    layer = paint.copy()
    layer.putalpha(ImageChops.multiply(layer.getchannel("A"), allowed))
    return layer


def fit_piece(size, tile, frame):
    x, y, width, height = frame
    layer = Image.new("RGBA", size)
    layer.alpha_composite(tile.resize((width, height), RESAMPLE), (x, y))
    return layer


def painted_panel(size, textile, outline, *, bias, light, edge, width, hem):
    shape = trace(size, outline)
    left, top, right, bottom = shape.getbbox()
    expanded = fit_piece(size, textile, (left, top, right - left, bottom - top))
    body = clip(expanded, shape)
    # The lower cloth turns under. Keep the original fabric texture visible.
    return_layers = [body]
    for weight, ink, shift, line in (
        (width * 1.40, edge, 0, [*outline, outline[0]]),
        (width * 1.34, bias, -width * 1.7, hem),
        (width * .47, light, -width * 2.05, hem),
    ):
        desired = [(x, y + shift) for x, y in line]
        seam = paint_mask(trace(size, desired, weight), ink)
        return_layers.append(clip(seam, shape))
    return compose(*return_layers), shape


@dataclass(frozen=True)
class Vest:
    outline: tuple
    pocket: tuple
    left: tuple | None = None
    fold: tuple = ()
    foreground: tuple = ()


# Canvas pixels of the current painted action frames, with the head, paws,
# and leaf tail outside each fitted torso outline.
VESTS = {
    "brace": Vest(
        ((164, 386), (170, 350), (199, 327), (237, 319), (264, 335),
         (256, 355), (244, 365), (244, 390), (258, 411), (219, 411),
         (192, 403)),
        (284, 360, 18, 31), (181, 351, 36, 49),
        ((176, 365), (195, 354), (218, 358)),
    ),
    "stand": Vest(
        ((174, 369), (173, 344), (198, 313), (235, 305), (274, 313),
         (304, 333), (281, 345), (266, 354), (257, 375), (262, 398),
         (232, 397), (203, 387)),
        (300, 359, 19, 28), (189, 334, 37, 51),
        ((184, 353), (208, 339), (235, 340)),
    ),
    "reach": Vest(
        ((173, 365), (183, 330), (214, 307), (252, 301), (297, 314),
         (324, 332), (303, 346), (283, 357), (270, 380), (273, 399),
         (233, 397), (203, 385)),
        (319, 352, 20, 29), (196, 330, 39, 51),
        ((189, 349), (216, 335), (242, 338)),
    ),
    "follow": Vest(
        ((207, 359), (214, 327), (244, 301), (287, 295), (326, 309),
         (349, 331), (330, 349), (313, 360), (297, 375), (296, 393),
         (260, 392), (232, 380)),
        (346, 347, 19, 29), (233, 327, 40, 50),
        ((222, 345), (249, 330), (282, 331)),
    ),
    "gather": Vest(
        ((168, 385), (177, 348), (206, 316), (242, 311), (280, 323),
         (294, 338), (273, 352), (259, 364), (258, 390), (271, 413),
         (228, 413), (193, 407)),
        (302, 361, 17, 33), (186, 342, 37, 52),
        ((185, 365), (210, 350), (238, 352)),
    ),
    "front": Vest(
        ((177, 389), (181, 354), (200, 319), (229, 308), (257, 327),
         (273, 349), (289, 341), (311, 326), (332, 328), (341, 353),
         (352, 375), (346, 397), (321, 397), (302, 380), (272, 368),
         (250, 390), (225, 401), (198, 398)),
        (320, 345, 26, 41),
    ),
    "back": Vest(
        ((196, 390), (191, 350), (197, 310), (227, 317), (253, 314),
         (281, 303), (294, 320), (284, 340), (274, 360), (268, 388),
         (239, 403), (214, 404)),
        (197, 340, 31, 47), fold=((231, 328), (227, 353), (233, 382)),
    ),
    "turnFront": Vest(
        ((180, 368), (177, 338), (203, 306), (235, 288), (273, 300),
         (291, 323), (275, 345), (264, 364), (253, 385), (258, 400),
         (224, 407), (200, 390)),
        (294, 352, 17, 29), (192, 336, 38, 49),
        ((183, 352), (207, 336), (236, 340)),
    ),
    "turnBack": Vest(
        ((180, 365), (190, 333), (216, 305), (251, 289), (281, 287),
         (316, 297), (342, 320), (319, 340), (302, 361), (297, 384),
         (281, 403), (247, 400), (213, 386)),
        (319, 347, 17, 28), (207, 334, 40, 49),
        ((189, 348), (219, 331), (247, 326)),
    ),
    "frontReach": Vest(
        ((188,369),(190,328),(208,303),(235,294),(259,312),(281,322),
         (310,307),(336,296),(351,317),(350,347),(338,379),
         (320,388),(284,382),(246,375),(223,390),(202,389)),
        (323,325,19,28), fold=((198,338),(199,355),(207,368)),
        foreground=(
            ((222,286),(314,276),(366,288),(357,315),(339,349),(318,371),
             (290,382),(278,361),(248,349),(227,321)),
            ((228,369),(252,352),(280,359),(290,380),(289,407),
             (243,416),(233,398)),
        ),
    ),
    "frontFollow": Vest(
        ((184,368),(186,331),(204,305),(229,294),(258,310),(287,319),
         (314,309),(337,296),(357,317),(357,350),(350,378),
         (332,386),(288,384),(244,385),(213,382),(198,386)),
        (332,324,18,27), fold=((194,342),(196,359),(204,371)),
        foreground=(
            ((229,285),(314,277),(364,288),(353,316),(335,346),(312,374),
             (285,379),(270,355),(244,339),(225,315)),
            ((291,359),(316,347),(341,352),(353,372),(352,403),(332,418),
             (303,415),(288,389)),
        ),
    ),
    "backReach": Vest(
        ((158,345),(157,306),(177,282),(211,271),(248,269),(276,286),
         (285,315),(278,347),(262,374),(240,392),(207,395),(176,379)),
        (165,324,35,50), fold=((207,301),(211,325),(216,358)),
        foreground=(
            ((135,263),(208,232),(249,239),(289,262),(280,280),(248,281),
             (214,283),(179,289),(157,304)),
            ((316,240),(405,244),(428,290),(433,340),(407,389),(360,402),
             (304,380),(268,354),(250,325),(255,300),(278,273)),
            ((259,351),(293,349),(311,369),(305,398),(294,416),
             (265,418),(250,393)),
        ),
    ),
    "backFollow": Vest(
        ((160,349),(160,312),(180,284),(212,270),(249,270),(271,289),
         (286,320),(277,351),(259,376),(234,387),(204,387),(175,375)),
        (171,304,36,47), fold=((216,298),(224,323),(234,356)),
        foreground=(
            ((135,263),(208,232),(249,239),(289,262),(282,281),(248,282),
             (213,282),(181,288),(154,299)),
            ((315,241),(404,244),(428,277),(432,331),(411,383),(362,402),
             (306,384),(267,359),(250,326),(255,298),(281,271)),
            ((163,355),(182,342),(209,349),(228,374),(226,413),
             (194,426),(168,403)),
        ),
    ),
    "leap": Vest(
        ((155, 232), (163, 211), (188, 198), (218, 195), (251, 206),
         (274, 215), (261, 229), (241, 232), (227, 251), (235, 265),
         (209, 274), (179, 270), (159, 259)),
        (265, 223, 14, 23), (173, 212, 35, 44),
        ((162, 233), (186, 219), (210, 221)),
    ),
}


def vest_layers(base, textile, pocket, fit, faces_left=False):
    size = base.size
    panel, shape = painted_panel(
        size, textile, fit.outline,
        bias=(209, 151, 99), light=(244, 198, 139), edge=(81, 63, 38),
        width=2.7, hem=fit.outline[-5:] + fit.outline[:2],
    )
    if fit.fold:
        fold = paint_mask(
            trace(size, fit.fold, 1.8),
            (96, 82, 47),
        )
        panel.alpha_composite(clip(fold, shape))
    box = fit.left if faces_left else fit.pocket
    solid = base.getchannel("A")
    layers = OrderedDict()
    pocket_on_fur = solid
    if fit.left is not None:
        # Wrap the lining around the shoulder to the opposite flank. The
        # original pale ruff and forepaw are in front of that far panel.
        x, y, w, h = fit.pocket
        shoulder, cuff = fit.outline[4:6]
        seam = (
            (shoulder[0] - 15, shoulder[1] + 5), cuff,
            (x + w * .7, y - h * .37), (x + w * 1.10, y + h * .25),
            (x + w * .83, y + h * .94), (x - w * .44, y + h * .75),
            (x - w * .90, y + h * .23),
        )
        far, _ = painted_panel(
            size, textile, seam,
            bias=(181, 127, 82), light=(235, 180, 118), edge=(77, 61, 38),
            width=2.1, hem=seam[3:] + seam[:1],
        )
        uncovered = Image.new("L", size)
        uncovered.putdata([
            0 if g > 137 and b > 104 and r - g < 88 else 255
            for r, g, b in base.convert("RGB").getdata()
        ])
        far_side = ImageChops.multiply(solid, uncovered)
        layers["Far vest panel behind original chest fur"] = clip(far, far_side)
        if not faces_left:
            pocket_on_fur = far_side
    layers["Moss vest and apricot binding"] = clip(panel, solid)
    layers["Left pocket and folded map"] = clip(
        fit_piece(size, pocket, box), pocket_on_fur
    )
    if fit.foreground:
        occlusion = Image.new("L", size)
        for outline in fit.foreground:
            occlusion = ImageChops.lighter(occlusion, trace(size, outline))
        layers["Original ruff, paws and tail overlap"] = clip(base, occlusion)
    return layers


@dataclass(frozen=True)
class Cape:
    outline: tuple
    wing: tuple
    ruff: tuple
    slits: tuple
    button: tuple
    second_wing: tuple = ()


# Fractional coordinates on each illustration. The nearest root is exposed
# along the layered feathers. The far opening follows the shoulder line.
CAPES = {
    "cat-4-rest": Cape(
        ((.38,.699),(.459,.605),(.545,.534),(.645,.485),(.735,.479),
         (.842,.496),(.958,.522),(.923,.602),(.879,.667),(.789,.703),
         (.680,.744),(.550,.791),(.438,.773)),
        ((.35,.607),(.424,.526),(.517,.493),(.600,.502),(.652,.549),
         (.660,.585),(.628,.615),(.574,.635),(.499,.681),(.414,.712)),
        ((.663,.449),(.911,.444),(.960,.492),(.920,.563),(.881,.606),
         (.812,.625),(.761,.584),(.731,.573),(.688,.544)),
        ((.601,.613,.049,.061),(.885,.629,.032,.045)), (.647,.642),
    ),
    "cat-4": Cape(
        ((.410,.696),(.472,.604),(.553,.514),(.629,.456),(.726,.403),
         (.833,.401),(.973,.438),(.952,.498),(.889,.561),(.807,.598),
         (.718,.621),(.590,.695),(.488,.733)),
        ((.372,.472),(.524,.376),(.596,.383),(.664,.432),(.700,.476),
         (.687,.524),(.647,.558),(.583,.599),(.513,.627),(.442,.617)),
        ((.685,.383),(.916,.340),(.942,.403),(.918,.465),(.901,.513),
         (.839,.569),(.781,.550),(.767,.507),(.699,.463)),
        ((.626,.555,.053,.061),(.946,.481,.029,.046)), (.678,.587),
    ),
    "cloud-cat-4-brace": Cape(
        ((.355,.719),(.422,.630),(.492,.553),(.610,.505),(.732,.497),
         (.851,.522),(.901,.605),(.866,.666),(.805,.711),(.709,.742),
         (.594,.755),(.491,.790),(.400,.772)),
        ((.284,.317),(.432,.300),(.551,.342),(.622,.416),(.678,.481),
         (.654,.545),(.591,.575),(.507,.578),(.421,.547),(.342,.512)),
        ((.662,.479),(.914,.446),(.938,.523),(.913,.599),(.862,.668),
         (.793,.693),(.749,.637),(.690,.601)),
        ((.600,.574,.055,.054),(.862,.677,.028,.040)), (.649,.635),
    ),
    "cloud-cat-4-flight": Cape(
        ((.348,.707),(.419,.633),(.518,.557),(.617,.523),(.729,.522),
         (.853,.558),(.855,.614),(.805,.663),(.740,.716),(.629,.745),
         (.514,.777),(.407,.771)),
        ((.476,.316),(.593,.354),(.671,.438),(.689,.500),(.658,.543),
         (.601,.584),(.539,.623),(.481,.612),(.435,.542),(.415,.442)),
        ((.645,.489),(.891,.465),(.936,.509),(.878,.585),(.799,.657),
         (.739,.650),(.691,.606)),
        ((.594,.608,.045,.046),(.830,.642,.029,.039)), (.635,.671),
    ),
    "cloud-cat-4-land": Cape(
        ((.332,.738),(.407,.660),(.473,.600),(.570,.568),(.691,.545),
         (.816,.562),(.907,.586),(.875,.677),(.820,.729),(.728,.752),
         (.610,.774),(.490,.804),(.393,.795)),
        ((.333,.467),(.432,.413),(.536,.423),(.641,.460),(.702,.525),
         (.697,.571),(.661,.610),(.589,.637),(.499,.632),(.416,.612)),
        ((.675,.533),(.914,.497),(.943,.549),(.905,.622),(.859,.689),
         (.799,.715),(.752,.660),(.702,.618)),
        ((.641,.632,.048,.051),(.867,.682,.029,.039)), (.687,.674),
    ),
    "leap-cat-4": Cape(
        ((.367,.742),(.455,.663),(.551,.569),(.644,.509),(.743,.456),
         (.855,.435),(.930,.470),(.895,.536),(.823,.581),(.738,.646),
         (.641,.713),(.515,.773),(.420,.781)),
        ((.423,.420),(.545,.377),(.623,.418),(.686,.465),(.704,.528),
         (.669,.573),(.599,.615),(.524,.636),(.455,.592)),
        ((.674,.443),(.904,.373),(.951,.434),(.903,.505),(.841,.569),
         (.770,.614),(.711,.558)),
        ((.628,.602,.050,.054),(.890,.523,.028,.042)), (.672,.653),
    ),
    "cloud-cat-4-rear-brace": Cape(
        ((.334,.731),(.415,.633),(.489,.565),(.569,.511),(.655,.470),
         (.733,.472),(.813,.514),(.842,.586),(.829,.675),(.781,.738),
         (.681,.762),(.555,.781),(.448,.796),(.362,.777)),
        ((.322,.446),(.417,.388),(.524,.387),(.609,.429),(.645,.488),
         (.618,.532),(.550,.555),(.496,.583),(.404,.599),(.348,.562)),
        ((.607,.421),(.817,.424),(.870,.469),(.885,.538),(.851,.591),
         (.812,.577),(.774,.536),(.682,.497)),
        ((.575,.545,.064,.061),(.707,.564,.058,.067)), (.643,.604),
        ((.656,.486),(.710,.460),(.775,.478),(.831,.532),(.854,.619),
         (.839,.701),(.804,.715),(.760,.673),(.735,.614),(.688,.576),
         (.653,.546)),
    ),
    "cloud-cat-4-rear-flight": Cape(
        ((.345,.756),(.405,.661),(.484,.594),(.571,.522),(.648,.482),
         (.703,.478),(.793,.494),(.836,.542),(.811,.612),(.751,.668),
         (.681,.709),(.553,.769),(.437,.804),(.363,.797)),
        ((.266,.189),(.413,.181),(.485,.263),(.526,.353),(.571,.440),
         (.613,.483),(.614,.513),(.565,.537),(.505,.527),(.443,.497),
         (.376,.446),(.305,.392),(.273,.309)),
        ((.617,.377),(.810,.388),(.914,.404),(.906,.470),(.885,.542),
         (.842,.593),(.796,.576),(.744,.519),(.684,.489)),
        ((.572,.507,.059,.076),(.677,.531,.049,.069)), (.619,.583),
        ((.629,.271),(.701,.236),(.776,.264),(.811,.334),(.807,.420),
         (.762,.490),(.702,.551),(.656,.559),(.620,.529),(.622,.484),
         (.643,.436),(.619,.361)),
    ),
    "cloud-cat-4-rear-land": Cape(
        ((.334,.765),(.422,.669),(.495,.601),(.589,.539),(.661,.491),
         (.740,.491),(.824,.532),(.860,.621),(.836,.708),(.760,.762),
         (.663,.787),(.554,.809),(.436,.814),(.361,.792)),
        ((.328,.458),(.423,.402),(.523,.402),(.606,.448),(.659,.520),
         (.646,.576),(.579,.594),(.515,.615),(.441,.633),(.365,.587)),
        ((.624,.451),(.814,.448),(.894,.504),(.903,.576),(.876,.626),
         (.830,.595),(.782,.562),(.713,.522)),
        ((.603,.573,.063,.067),(.755,.608,.060,.067)), (.682,.641),
        ((.698,.519),(.767,.511),(.839,.535),(.887,.595),(.902,.661),
         (.886,.723),(.843,.742),(.800,.707),(.752,.673),(.714,.632),
         (.681,.585)),
    ),
}


def oval(size, cx, cy, rx, ry):
    mask = Image.new("L", (size[0] * 3, size[1] * 3))
    ImageDraw.Draw(mask).ellipse(
        [((cx - rx) * 3), ((cy - ry) * 3), ((cx + rx) * 3), ((cy + ry) * 3)],
        fill=255,
    )
    return mask.resize(size, RESAMPLE)


def cape_layers(base, textile, fit):
    size = base.size
    w, h = size
    def positions(points):
        return [(x * w, y * h) for x, y in points]

    width = h / 133
    outline = positions(fit.outline)
    main, shape = painted_panel(
        size, textile, outline, bias=(183, 138, 86), light=(255, 226, 170),
        edge=(105, 76, 49), width=width, hem=outline[-6:] + outline[:2],
    )
    # Each wing exits its own opening. The welt ends where the original
    # feather and chest paint sit in front of it.
    open_cut = Image.new("L", size)
    welts = Image.new("RGBA", size)
    for x, y, rx, ry in fit.slits:
        outside = oval(size, x * w, y * h, rx * w, ry * h)
        inside = oval(size, x * w, y * h, rx * w - width, ry * h - width)
        seam = ImageChops.subtract(outside, inside)
        welts.alpha_composite(paint_mask(seam, (123, 90, 56)))
        open_cut = ImageChops.lighter(open_cut, inside)

    # Restore visible original tail, wing and ruff pixels over the fabric.
    wing = trace(size, positions(fit.wing))
    if fit.second_wing:
        wing = ImageChops.lighter(wing, trace(size, positions(fit.second_wing)))
    ruff = trace(size, positions(fit.ruff))
    original_over = ImageChops.lighter(wing, ruff)
    keep = ImageChops.multiply(
        base.getchannel("A"), ImageChops.invert(original_over)
    )
    fabric = clip(clip(main, ImageChops.invert(open_cut)), keep)
    welts = clip(clip(welts, shape), keep)

    x, y = positions([fit.button])[0]
    radius = h * .015
    button = compose(
        paint_mask(oval(size, x, y, radius, radius * .8), (119, 83, 56)),
        paint_mask(oval(size, x, y - radius * .10, radius * .81, radius * .56),
                   (192, 151, 99)),
        paint_mask(oval(size, x, y - radius * .04, radius * .38, radius * .09),
                   (117, 82, 52)),
    )
    button = clip(clip(button, shape), keep)
    return OrderedDict([
        ("Wheat cloth and folded hem", fabric),
        ("Two bound wing openings", welts),
        ("Dorsal cloth button", button),
    ])


def png(image):
    buffer = BytesIO()
    image.save(buffer, format="PNG")
    return buffer.getvalue()


def master(path, base, layers, final):
    header = ET.Element("image", w=str(base.width), h=str(base.height))
    stack = ET.SubElement(header, "stack")
    stack_layers = [("Reference character", base), *layers.items()]
    with ZipFile(path, "w", compression=ZIP_DEFLATED) as archive:
        archive.writestr("mimetype", "image/openraster", compress_type=ZIP_STORED)
        for index, (label, plate) in enumerate(reversed(stack_layers)):
            name = f"data/{index}.png"
            ET.SubElement(stack, "layer", name=label, src=name, x="0", y="0",
                          opacity="1.0", visibility="visible", **{"composite-op": "svg:src-over"})
            archive.writestr(name, png(plate))
        archive.writestr("stack.xml", ET.tostring(header))
        archive.writestr("mergedimage.png", png(final))
        thumb = final.copy()
        thumb.thumbnail((256, 256), RESAMPLE)
        archive.writestr("Thumbnails/thumbnail.png", png(thumb))


class Package:
    def __init__(self, masters):
        self.masters = masters
        self.poses = []
        self.thumbnails = []
        self.rear_paintings = []
        self.fox_turn_paintings = []
        self.fox_depth_paintings = []

    def export(self, job, base_path, suffix, layers, sources):
        base = rgba(base_path)
        target = base_path.with_stem(f"{base_path.stem}-{suffix}")
        final = compose(base, *layers.values())
        final.save(target, lossless=True, exact=True)
        matte = Image.new("RGBA", base.size, (0, 0, 0, 255))
        region = ImageChops.difference(
            Image.alpha_composite(matte, base).convert("RGB"),
            Image.alpha_composite(matte, final).convert("RGB"),
        ).getbbox()
        if not region or final.getchannel("A").getbbox() != base.getchannel("A").getbbox():
            raise ValueError(f"{target.name} changed the pose bounds or has no garment")
        self.poses.append({
            "work_order": job,
            "runtime_path": target.relative_to(ROOT).as_posix(),
            "runtime_size": list(base.size),
            "paint_bbox": list(region),
            "sha256": digest(target),
            "pose": {"path": base_path.relative_to(ROOT).as_posix(), "sha256": digest(base_path)},
            "sources": [{"file": path.name, "sha256": digest(path)} for path in sources],
        })
        if self.masters is not None:
            folder = self.masters / job / "app-fitted"
            folder.mkdir(parents=True, exist_ok=True)
            master(folder / f"{target.stem}.ora", base, layers, final)
            final.save(folder / f"{target.stem}.png")

    def thumbnail(self, job, name, source):
        path = ART / f"wardrobe-{name}-thumbnail.webp"
        image = rgba(source)
        image.save(path, lossless=True, exact=True)
        self.thumbnails.append({
            "work_order": job, "runtime_path": path.relative_to(ROOT).as_posix(),
            "runtime_size": list(image.size), "sha256": digest(path),
            "sources": [{"file": source.name, "sha256": digest(source)}],
        })


def fox_turn_poses(package, source):
    sheet = rgba(source)
    mid = sheet.width // 2
    if sheet.getchannel("A").crop((mid - 8, 0, mid + 8, sheet.height)).getextrema()[1] > 12:
        raise ValueError("The fox turn poses need a clear gutter")
    for index, name in enumerate(("turnFront", "turnBack")):
        cell = sheet.crop((index * mid, 0, (index + 1) * mid, sheet.height))
        alpha = cell.getchannel("A")
        cell.putalpha(alpha.point(lambda x: x if x > 8 else 0))
        bounds = alpha.point(lambda x: 255 if x > 16 else 0).getbbox()
        image = cell.crop(bounds)
        width = round(image.width * 400 / image.height)
        xy = ((512 - width) // 2, 440 - 400)
        plate = Image.new("RGBA", (512, 464))
        plate.alpha_composite(image.resize((width, 400), RESAMPLE), xy)
        target = ASSETS / f"fox_walk/full-{name}.webp"
        plate.save(target, lossless=True, exact=True)
        package.fox_turn_paintings.append({
            "runtime_path": target.relative_to(ROOT).as_posix(),
            "runtime_size": list(plate.size),
            "sha256": digest(target),
            "crop_on_master": [bounds[0] + index * mid, bounds[1],
                               bounds[2] + index * mid, bounds[3]],
            "source": {"file": source.name, "sha256": digest(source)},
        })


def fox_depth_poses(package, source):
    sheet = rgba(source)
    columns = (0, sheet.width // 2, sheet.width)
    rows = (0, sheet.height // 2, sheet.height)
    names = (("frontReach", "frontFollow"), ("backReach", "backFollow"))
    for row, poses in enumerate(names):
        cells = [
            sheet.crop((columns[col], rows[row], columns[col + 1], rows[row + 1]))
            for col in range(2)
        ]
        bounds = [cell.getchannel("A").point(lambda x: 255 if x > 26 else 0).getbbox()
                  for cell in cells]
        if any(box is None for box in bounds):
            raise ValueError("Every fox step needs its own complete silhouette")
        # Hold the same scale and ground line through both contacts.
        height = max(box[3] - box[1] for box in bounds)
        scale = 412 / height
        for col, (name, cell, box) in enumerate(zip(poses, cells, bounds)):
            cell.putalpha(cell.getchannel("A").point(lambda x: x if x > 8 else 0))
            art = cell.crop(box)
            width, tall = round(art.width * scale), round(art.height * scale)
            plate = Image.new("RGBA", (512, 464))
            plate.alpha_composite(art.resize((width, tall), RESAMPLE),
                                  ((512 - width) // 2, 440 - tall))
            path = ASSETS / f"fox_walk/full-{name}.webp"
            plate.save(path, lossless=True, exact=True)
            package.fox_depth_paintings.append({
                "runtime_path": path.relative_to(ROOT).as_posix(),
                "runtime_size": list(plate.size),
                "sha256": digest(path),
                "crop_on_master": [
                    box[0] + columns[col], box[1] + rows[row],
                    box[2] + columns[col], box[3] + rows[row],
                ],
                "source": {"file": source.name, "sha256": digest(source)},
            })


def fox(package, source):
    production = source / "r02-openai/production-v2"
    cloth_path = production / "seated__cloth-body-visible.png"
    pocket_path = production / "seated__anatomical-LEFT-pocket-and-map.png"
    trim_path = production / "seated__anterior-cuff-and-trim.png"
    fur_path = production / "seated__original-jaw-fur-occlusion.png"
    fur = rgba(fur_path)
    raw = rgba(cloth_path)
    fabric = raw.crop((133, 365, 155, 387))
    pocket = tight(rgba(pocket_path))
    base_path = ART / "fox-1.webp"
    for view, cloth in (("map-vest", rgba(pocket_path)), ("map-vest-left",
                      fit_piece(raw.size, pocket, (145, 342, 39, 53)))):
        layers = OrderedDict([
            ("Moss cloth", raw),
            ("Apricot opening and binding", rgba(trim_path)),
            ("Left pocket and folded map", cloth),
            ("Original jaw fur", fur),
        ])
        package.export("CL-01", base_path, view, layers,
                       [cloth_path, trim_path, pocket_path, fur_path])
    for name, fit in VESTS.items():
        path = (ART / "leap-fox-1.webp" if name == "leap"
                else ASSETS / f"fox_walk/full-{name}.webp")
        base = rgba(path)
        package.export("CL-01", path, "map-vest", vest_layers(base, fabric, pocket, fit),
                       [cloth_path, pocket_path])
        if fit.left is not None:
            package.export("CL-01", path, "map-vest-left",
                           vest_layers(base, fabric, pocket, fit, faces_left=True),
                           [cloth_path, pocket_path])
    package.thumbnail("CL-01", "map-vest", next((source / "r01").glob("*__shop__item__*.png")))


def rear_poses(package, source):
    sheet = rgba(source)
    if sheet.size != (2172, 724):
        raise ValueError("Unexpected stage-four rear pose sheet")
    for index, pose in enumerate(("brace", "flight", "land")):
        cell = sheet.crop((index * 724, 0, (index + 1) * 724, 724))
        x, y, right, bottom = cell.getchannel("A").point(
            lambda alpha: 255 if alpha >= 80 else 0
        ).getbbox()
        crop = (x - 2, y - 2, right + 2, bottom + 2)
        picture = cell.crop(crop)
        picture.thumbnail((650, 552), RESAMPLE)
        target = ART / f"cloud-cat-4-rear-{pose}.webp"
        picture.save(target, lossless=True, exact=True)
        package.rear_paintings.append({
            "runtime_path": target.relative_to(ROOT).as_posix(),
            "runtime_size": list(picture.size),
            "sha256": digest(target),
            "crop_on_master": [crop[0]+index*724,crop[1],crop[2]+index*724,crop[3]],
            "source": {"file": source.name, "sha256": digest(source)},
        })


def cat(package, source, rear):
    source_path = source / "r02-openai/production-v2/rest__cape-rear-hem.png"
    fabric = rgba(source_path).crop((573, 841, 668, 896))
    rear_poses(package, rear)
    for name, fit in CAPES.items():
        path = ART / f"{name}.webp"
        package.export("CL-02", path, "wing-cape", cape_layers(rgba(path), fabric, fit),
                       [source_path])
    package.thumbnail("CL-02", "wing-cape", next((source / "r01").glob("*__shop__item__*.png")))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("returns", type=Path)
    parser.add_argument("--masters", type=Path)
    parser.add_argument("--rear", type=Path, required=True)
    parser.add_argument("--fox-turns", type=Path)
    parser.add_argument("--fox-depth", type=Path)
    arguments = parser.parse_args()
    package = Package(arguments.masters)
    fox_turn_poses(package, arguments.fox_turns or
                  arguments.returns / "MO-01/app-locomotion/fox-turning-pair.png")
    fox_depth_poses(package, arguments.fox_depth or
                   arguments.returns / "MO-01/app-locomotion/fox-depth-steps.png")
    fox(package, arguments.returns / "CL-01")
    cat(package, arguments.returns / "CL-02", arguments.rear)
    print(json.dumps({
        "poses": package.poses,
        "thumbnails": package.thumbnails,
        "rear_paintings": package.rear_paintings,
        "fox_turn_paintings": package.fox_turn_paintings,
        "fox_depth_paintings": package.fox_depth_paintings,
    }, indent=2))


if __name__ == "__main__":
    main()
