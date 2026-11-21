import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../domain/companions.dart';

String wornArtwork(String asset) =>
    'assets/art/worn_${asset.substring(5)}.webp';

String fittedAccessory(String id, Companion pet, {bool airborne = false}) {
  if (id == 'item_accessory_glasses' || pet.hasGroundSkill) {
    return wornArtwork(id);
  }
  final kind = id.substring('item_accessory_'.length);
  final pose = airborne ? 'flight' : 'rest';
  return 'assets/art/fitted-$kind-${pet.name}-$pose.webp';
}

enum FittedCoat {
  mapVest('map-vest', '苔绿地图背心'),
  wingCape('wing-cape', '双开衩短披肩');

  const FittedCoat(this.asset, this.nameInWardrobe);
  final String asset, nameInWardrobe;

  String get thumbnail => 'assets/art/wardrobe-$asset-thumbnail.webp';

  String on(
    String original, {
    bool facesLeft = false,
    bool paintedScarf = false,
  }) {
    if (this != mapVest) return original.replaceFirst('.webp', '-$asset.webp');
    final side = facesLeft ? '-left' : '';
    final version = paintedScarf ? 'scarf' : 'painted';
    return original.replaceFirst('.webp', '-$asset-$version$side.webp');
  }
}

FittedCoat? fittedCoat(Companion pet, int stage, String? garment) =>
    switch ((pet, stage, garment)) {
      (Companion.fox, 1, 'item_single_coat') => FittedCoat.mapVest,
      (Companion.cat, 4, 'item_single_coat') => FittedCoat.wingCape,
      _ => null,
    };

String portraitArtwork(
  Companion pet,
  int stage,
  bool reveal,
  String? garment, {
  bool facesLeft = false,
  bool paintedScarf = false,
}) {
  final original = pet.artwork(stage, reveal: reveal);
  if (fittedCoat(pet, stage, garment) case final coat?) {
    return coat.on(original, facesLeft: facesLeft, paintedScarf: paintedScarf);
  }
  if (paintedScarf && garment == null) return foxScarfArtwork(original);
  final cut = switch (garment) {
    'item_single_coat' => 'coat',
    'item_single_apron' => 'apron',
    _ => null,
  };
  return cut == null ? original : original.replaceFirst('.webp', '-$cut.webp');
}

String foxScarfArtwork(String original) =>
    original.replaceFirst('.webp', '-scarf-painted.webp');

// Where the neck emerges from the fur, in each original portrait.
const _necks = <Companion, List<Offset>>{
  Companion.fox: [
    Offset(.68, .63),
    Offset(.38, .57),
    Offset(.34, .42),
    Offset(.36, .56),
    Offset(.51, .54),
    Offset(.60, .55),
  ],
  Companion.rabbit: [
    Offset(.61, .56),
    Offset(.57, .47),
    Offset(.58, .43),
    Offset(.63, .67),
    Offset(.64, .64),
    Offset(.58, .49),
  ],
  Companion.cat: [
    Offset(.68, .60),
    Offset(.69, .48),
    Offset(.69, .49),
    Offset(.78, .46),
    Offset(.64, .43),
    Offset(.65, .47),
  ],
  Companion.otter: [
    Offset(.710, .590),
    Offset(.722, .590),
    Offset(.725, .595),
    Offset(.707, .597),
    Offset(.721, .600),
    Offset(.740, .600),
  ],
  Companion.hedgehog: [
    Offset(.690, .664),
    Offset(.699, .681),
    Offset(.699, .686),
    Offset(.709, .700),
    Offset(.703, .701),
    Offset(.712, .718),
  ],
};

// Crown, near ear root and skull width measured on each painted portrait.
// Late stages have a large tail or wings; the whole sprite width and the eye
// separation alone are both poor measures of hat or neckwear size.
const _heads = <Companion, List<(double, double, double, double, double)>>{
  Companion.fox: [
    (.64, .26, .40, .36, .54),
    (.38, .24, .22, .32, .43),
    (.34, .165, .19, .19, .38),
    (.30, .37, .17, .45, .32),
    (.45, .35, .34, .37, .28),
    (.65, .30, .565, .345, .27),
  ],
  Companion.rabbit: [
    (.60, .086, .394, .224, .49),
    (.53, .06, .34, .16, .44),
    (.57, .115, .43, .24, .34),
    (.57, .419, .466, .49, .29),
    (.58, .40, .49, .46, .28),
    (.55, .278, .46, .34, .26),
  ],
  Companion.cat: [
    (.63, .207, .37, .32, .55),
    (.71, .128, .49, .245, .43),
    (.69, .139, .49, .232, .42),
    (.815, .125, .70, .192, .32),
    (.646, .149, .535, .238, .28),
    (.664, .224, .573, .28, .238),
  ],
  Companion.otter: [
    (.730, .123, .553, .199, .371),
    (.740, .126, .555, .200, .373),
    (.742, .130, .560, .198, .365),
    (.728, .144, .549, .214, .356),
    (.744, .145, .568, .218, .347),
    (.761, .155, .579, .221, .334),
  ],
  Companion.hedgehog: [
    (.726, .280, .647, .342, .313),
    (.738, .304, .654, .354, .319),
    (.737, .306, .656, .360, .306),
    (.745, .320, .667, .376, .304),
    (.743, .323, .660, .380, .293),
    (.758, .352, .673, .400, .285),
  ],
};
typedef AccessoryFit = ({Offset crown, Offset ear, Offset neck, double width});
typedef ScarfFit = ({Offset center, double span, bool back});
typedef AccessoryTextures = ({
  Map<String, ui.Image> generic,
  Map<String, ui.Image> registered,
});

bool hasAccessories(AccessoryTextures textures) =>
    textures.generic.isNotEmpty || textures.registered.isNotEmpty;

AccessoryFit _fit(
  Companion pet,
  int stage,
  bool reveal,
  bool airborne,
  Offset near,
  Offset far,
) {
  if (airborne) {
    final wide = switch (pet) {
      Companion.fox => const [.41, .35, .33, .27, .25, .247],
      Companion.rabbit => const [.38, .35, .33, .28, .255, .245],
      Companion.cat => const [.37, .33, .35, .29, .256, .228],
      Companion.otter => const [.35, .35, .34, .34, .33, .33],
      Companion.hedgehog => const [.32, .32, .31, .30, .29, .29],
    }[stage - 1];
    final mid = (near + far) / 2;
    final vertical =
        switch (pet) {
          Companion.fox => .18,
          Companion.rabbit => .18,
          Companion.cat => .16,
          Companion.otter => .19,
          Companion.hedgehog => .15,
        } *
        (stage <= 3 ? 1 : .76);
    return (
      crown: Offset(
        mid.dx - wide * .12,
        mid.dy - vertical * (pet == Companion.cat ? .62 : .90),
      ),
      ear: Offset(near.dx - wide * .30, near.dy - vertical * .59),
      neck: Offset(near.dx - wide * .18, near.dy + vertical * 1.40),
      width: wide,
    );
  }
  if (pet == Companion.cat && stage == 4 && !reveal) {
    return (
      crown: const Offset(.799, .157),
      ear: const Offset(.678, .226),
      neck: const Offset(.75, .47),
      width: .337,
    );
  }
  final h = _heads[pet]![stage - 1];
  return (
    crown: Offset(h.$1, h.$2),
    ear: Offset(h.$3, h.$4),
    neck: _necks[pet]![stage - 1],
    width: h.$5,
  );
}

class DressedPortrait {
  const DressedPortrait(this.image, this.padding);
  final ui.Image image;
  final Offset padding;
}

DressedPortrait applyAccessories(
  ui.Image body,
  Companion pet,
  int stage,
  bool reveal,
  Offset leftEye,
  Offset rightEye,
  Map<String, ui.Image> clothes,
  String? headAsset, {
  bool airborne = false,
  AccessoryFit? fit,
  ScarfFit? scarfFit,
  (Offset, Offset)? rearTemples,
  bool headOn = false,
  bool nearLensOnly = false,
  Offset? distantBowEar,
  Map<String, ui.Image> registered = const {},
}) {
  final w = body.width.toDouble(), h = body.height.toDouble();
  final px = (w * .18).ceil(), py = (h * .20).ceil();
  final recording = ui.PictureRecorder();
  final c = Canvas(recording)..translate(px.toDouble(), py.toDouble());
  final brush = Paint()..filterQuality = FilterQuality.medium;
  c.drawImage(body, Offset.zero, brush);
  final near = Offset(leftEye.dx * w, leftEye.dy * h),
      far = Offset(rightEye.dx * w, rightEye.dy * h);
  final anchors = fit ?? _fit(pet, stage, reveal, airborne, leftEye, rightEye);
  Offset anchor(Offset p) => Offset(p.dx * w, p.dy * h);
  final skull = anchors.width * w;
  void place(ui.Image paint) {
    assert(paint.width == body.width && paint.height == body.height);
    c.drawImage(paint, Offset.zero, brush);
  }

  if (registered['neck'] case final neck?) {
    place(neck);
  } else if (clothes['neck'] case final scarf?) {
    final seam =
        scarfFit ??
        (pet == Companion.fox && stage == 1 && airborne
            ? (center: const Offset(.58, .565), span: .29, back: false)
            : (
                center: anchors.neck,
                span: anchors.width * (pet.hasGroundSkill ? .74 : 1),
                back: false,
              ));
    final collar = anchor(seam.center);
    final span = seam.span * w;
    final wide = span * (airborne ? .97 : .86);
    if (seam.back) {
      c.saveLayer(Offset.zero & Size(w, h), Paint());
      _scarfBack(c, scarf, collar, wide, brush);
      c.drawImage(body, Offset.zero, Paint()..blendMode = BlendMode.dstIn);
      c.restore();
    } else {
      final height = math.min(
        wide * scarf.height / scarf.width,
        span * (airborne ? .53 : .58),
      );
      final frame = Rect.fromCenter(
        center: collar + Offset(-wide * (airborne ? .09 : 0), height * .35),
        width: wide,
        height: height,
      );
      final angle = airborne ? -.12 : -.075;
      if (pet == Companion.fox && stage == 1) {
        _draw(
          c,
          scarf,
          frame.shift(Offset(-.6, height * .044)),
          angle,
          tint: const Color(0x65433325),
        );
      }
      _draw(c, scarf, frame, angle);
      // Let the chin overlap the top of the neckerchief.
      c.save();
      c.clipPath(
        Path()..addOval(
          Rect.fromCenter(
            center: collar + Offset(0, -height * .40),
            width: wide * .61,
            height: height * .82,
          ),
        ),
      );
      c.drawImage(body, Offset.zero, brush);
      c.restore();
    }
  }
  if (registered['head'] case final placedHead?) {
    place(placedHead);
  } else if (clothes['head'] case final head?) {
    final bow = headAsset == 'item_accessory_bow';
    final distant = bow && distantBowEar != null;
    final wide = skull * (bow ? (distant ? .31 : .51) : .88);
    final height = math.min(
      wide * head.height / head.width,
      skull * (bow ? .49 : .48),
    );
    final Offset center;
    if (!bow) {
      center = anchor(anchors.crown) + Offset(-wide * .065, -height * .30);
    } else if (distantBowEar != null) {
      center = anchor(distantBowEar) + Offset(wide * .025, -height * .07);
    } else {
      final ear = anchor(anchors.ear);
      center = Offset(
        math.min(ear.dx - wide * .07, near.dx - wide * .55 - skull * .04),
        ear.dy - height * .02,
      );
    }
    _draw(
      c,
      head,
      Rect.fromCenter(center: center, width: wide, height: height),
      bow
          ? (distant
                ? .15
                : airborne
                ? -.24
                : -.14)
          : -.10,
    );
  }
  if (registered['face'] case final face?) {
    place(face);
  } else if (clothes.containsKey('face')) {
    if (rearTemples case (final left, final right)) {
      _spectacleEnds(c, anchor(left), anchor(right), skull);
    } else {
      _spectacles(
        c,
        near,
        far,
        skull,
        airborne,
        pet == Companion.hedgehog && !headOn,
        headOn,
        nearLensOnly,
      );
    }
  }
  final picture = recording.endRecording();
  final image = picture.toImageSync(body.width + 2 * px, body.height + 2 * py);
  picture.dispose();
  return DressedPortrait(image, Offset(px.toDouble(), py.toDouble()));
}

void _scarfBack(
  Canvas c,
  ui.Image scarf,
  Offset collar,
  double wide,
  Paint brush,
) {
  final half = wide / 2;
  final drop = wide * .16;
  c.save();
  c.translate(collar.dx, collar.dy);
  c.clipPath(
    Path()
      ..moveTo(-half, -drop * .64)
      ..quadraticBezierTo(0, drop * .22, half, -drop * .55)
      ..quadraticBezierTo(half * .99, drop * .31, half * .87, drop * .5)
      ..quadraticBezierTo(0, drop * 1.48, -half * .92, drop * .40)
      ..close(),
  );
  c.drawImageRect(
    scarf,
    Rect.fromLTWH(
      scarf.width * .29,
      scarf.height * .035,
      scarf.width * .38,
      scarf.height * .145,
    ),
    Rect.fromLTRB(-half, -drop, half, drop * 1.2),
    brush,
  );
  c.restore();
}

void _draw(Canvas c, ui.Image image, Rect dest, double angle, {Color? tint}) {
  c.save();
  c.translate(dest.center.dx, dest.center.dy);
  c.rotate(angle);
  c.drawImageRect(
    image,
    Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    Rect.fromCenter(
      center: Offset.zero,
      width: dest.width,
      height: dest.height,
    ),
    Paint()
      ..filterQuality = FilterQuality.medium
      ..colorFilter = tint == null
          ? null
          : ColorFilter.mode(tint, BlendMode.srcIn),
  );
  c.restore();
}

void _spectacleEnds(Canvas c, Offset left, Offset right, double skull) {
  final rim = Paint()
    ..strokeCap = StrokeCap.round
    ..strokeWidth = skull * .018
    ..color = const Color(0xff915a39);
  final shine = Paint()
    ..strokeCap = StrokeCap.round
    ..strokeWidth = skull * .008
    ..color = const Color(0xffefb77e);
  for (final (ear, side) in [(left, 1), (right, -1)]) {
    final end = ear + Offset(skull * .080 * side, -skull * .031);
    c.drawLine(ear, end, rim);
    c.drawLine(ear, end, shine);
  }
}

/// Draw two lenses on their respective eyes. The far lens narrows in profile,
/// and the temple runs back towards the near ear rather than across the pupil.
void _spectacles(
  Canvas c,
  Offset near,
  Offset far,
  double skull,
  bool airborne,
  bool narrowFarLens,
  bool headOn,
  bool nearLensOnly,
) {
  final axis = far - near, span = axis.distance;
  final radius = math.min(skull * (airborne ? .20 : .215), span * .49);
  final farRadius =
      radius *
      (headOn
          ? 1.0
          : narrowFarLens
          ? .48
          : airborne
          ? .66
          : .82);
  c.save();
  c.translate(near.dx, near.dy);
  c.rotate(math.atan2(axis.dy, axis.dx));
  final width = math.max(1.1, skull * .018);
  final rim = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..color = const Color(0xff915a39);
  final shine = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width * .47
    ..strokeCap = StrokeCap.round
    ..color = const Color(0xffefb77e);
  final arm = Path()
    ..moveTo(-radius * .88, -radius * .31)
    ..quadraticBezierTo(
      -radius * 1.55,
      -radius * .75,
      -radius * 2.05,
      -radius * .55,
    );
  final bridge = Path()
    ..moveTo(radius * .9, -radius * .23)
    ..quadraticBezierTo(
      span * .53,
      -radius * .62,
      span - farRadius * .92,
      -radius * .28,
    );
  for (final path in [arm, if (!nearLensOnly) bridge]) {
    c.drawPath(path, rim);
    c.drawPath(path, shine);
  }
  for (final (x, rx) in [(0.0, radius), if (!nearLensOnly) (span, farRadius)]) {
    final lens = Rect.fromCenter(
      center: Offset(x, 0),
      width: rx * 2,
      height: radius * (narrowFarLens && x != 0 ? 1.46 : 2.03),
    );
    c.drawOval(lens, Paint()..color = const Color(0x09ffe4a1));
    c.drawOval(lens, rim);
    c.drawArc(lens, 3.1, 2.56, false, shine);
  }
  c.restore();
}
