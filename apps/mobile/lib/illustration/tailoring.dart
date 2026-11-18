import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../domain/companions.dart';

String wornArtwork(String asset) =>
    'assets/art/worn_${asset.substring(5)}.webp';

String fittedAccessory(String id, Companion pet, {bool airborne = false}) {
  if (id == 'item_accessory_glasses') return wornArtwork(id);
  final kind = id.substring('item_accessory_'.length);
  final pose = airborne ? 'flight' : 'rest';
  return 'assets/art/fitted-$kind-${pet.name}-$pose.webp';
}

String portraitArtwork(Companion pet, int stage, bool reveal, String? garment) {
  final original = pet.artwork(stage, reveal: reveal);
  final cut = switch (garment) {
    'item_single_coat' => 'coat',
    'item_single_apron' => 'apron',
    _ => null,
  };
  return cut == null ? original : original.replaceFirst('.webp', '-$cut.webp');
}

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
};
typedef _Fit = ({Offset crown, Offset ear, Offset neck, double width});
_Fit _fit(
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
    }[stage - 1];
    final mid = (near + far) / 2;
    final vertical =
        switch (pet) {
          Companion.fox => .18,
          Companion.rabbit => .18,
          Companion.cat => .16,
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
}) {
  final w = body.width.toDouble(), h = body.height.toDouble();
  final px = (w * .18).ceil(), py = (h * .20).ceil();
  final recording = ui.PictureRecorder();
  final c = Canvas(recording)..translate(px.toDouble(), py.toDouble());
  final brush = Paint()..filterQuality = FilterQuality.medium;
  c.drawImage(body, Offset.zero, brush);
  final near = Offset(leftEye.dx * w, leftEye.dy * h),
      far = Offset(rightEye.dx * w, rightEye.dy * h);
  final fit = _fit(pet, stage, reveal, airborne, leftEye, rightEye);
  Offset anchor(Offset p) => Offset(p.dx * w, p.dy * h);
  final skull = fit.width * w;
  if (clothes['neck'] case final scarf?) {
    final collar = anchor(fit.neck);
    final wide = skull * (airborne ? .97 : .86);
    final height = math.min(
      wide * scarf.height / scarf.width,
      skull * (airborne ? .53 : .58),
    );
    final frame = Rect.fromCenter(
      center: collar + Offset(-wide * (airborne ? .09 : 0), height * .35),
      width: wide,
      height: height,
    );
    _draw(c, scarf, frame, airborne ? -.12 : -.075);
    // Let a little of the actual chin overlap the back edge of the neckerchief.
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
  if (clothes['head'] case final head?) {
    final bow = headAsset == 'item_accessory_bow';
    final wide = skull * (bow ? .51 : .88);
    final height = math.min(
      wide * head.height / head.width,
      skull * (bow ? .49 : .48),
    );
    final center = bow
        ? Offset(
            math.min(
              anchor(fit.ear).dx - wide * .07,
              near.dx - wide * .55 - skull * .04,
            ),
            anchor(fit.ear).dy - height * .02,
          )
        : anchor(fit.crown) + Offset(-wide * .065, -height * .30);
    _draw(
      c,
      head,
      Rect.fromCenter(center: center, width: wide, height: height),
      bow ? (airborne ? -.24 : -.14) : -.10,
    );
  }
  if (clothes.containsKey('face')) _spectacles(c, near, far, skull, airborne);
  final picture = recording.endRecording();
  final image = picture.toImageSync(body.width + 2 * px, body.height + 2 * py);
  picture.dispose();
  return DressedPortrait(image, Offset(px.toDouble(), py.toDouble()));
}

void _draw(Canvas c, ui.Image image, Rect dest, double angle) {
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
    Paint()..filterQuality = FilterQuality.medium,
  );
  c.restore();
}

/// Draw two lenses on their respective eyes. The far lens narrows in profile,
/// and the temple runs back towards the near ear rather than across the pupil.
void _spectacles(
  Canvas c,
  Offset near,
  Offset far,
  double skull,
  bool airborne,
) {
  final axis = far - near, span = axis.distance;
  final radius = math.min(skull * (airborne ? .20 : .215), span * .49);
  final farRadius = radius * (airborne ? .66 : .82);
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
  for (final path in [arm, bridge]) {
    c.drawPath(path, rim);
    c.drawPath(path, shine);
  }
  for (final (x, rx) in [(0.0, radius), (span, farRadius)]) {
    final lens = Rect.fromCenter(
      center: Offset(x, 0),
      width: rx * 2,
      height: radius * 2.03,
    );
    c.drawOval(lens, Paint()..color = const Color(0x09ffe4a1));
    c.drawOval(lens, rim);
    c.drawArc(lens, 3.1, 2.56, false, shine);
  }
  c.restore();
}
