import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../domain/companions.dart';

String wornArtwork(String asset) =>
    'assets/art/worn_${asset.substring(5)}.webp';

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
  String? headAsset,
) {
  final w = body.width.toDouble(), h = body.height.toDouble();
  final px = (w * .18).ceil(), py = (h * .20).ceil();
  final recording = ui.PictureRecorder();
  final c = Canvas(recording)..translate(px.toDouble(), py.toDouble());
  final brush = Paint()..filterQuality = FilterQuality.medium;
  c.drawImage(body, Offset.zero, brush);
  final near = Offset(leftEye.dx * w, leftEye.dy * h),
      far = Offset(rightEye.dx * w, rightEye.dy * h);
  final eyeLine = far - near,
      span = eyeLine.distance,
      middle = (far + near) / 2;
  final scarf = clothes['neck'];
  if (scarf != null) {
    final point = pet == Companion.cat && stage == 4 && !reveal
        ? const Offset(.73, .50)
        : _necks[pet]![stage - 1];
    final n = Offset(point.dx * w, point.dy * h);
    final wide = span * 2.12;
    final neck = Rect.fromCenter(
      center: n + Offset(0, span * .17),
      width: wide,
      height: wide * .72,
    );
    _draw(c, scarf, neck, -.13);
  }
  final head = clothes['head'];
  if (head != null) {
    final bow = headAsset == 'item_accessory_bow';
    final width = span * (bow ? 1.12 : 2.16);
    final center = bow
        ? near + Offset(-span * .58, -span * .65)
        : middle + Offset(-span * .20, -span * .85);
    final r = Rect.fromCenter(
      center: center,
      width: width,
      height: width * head.height / head.width,
    );
    _draw(c, head, r, bow ? -.30 : -.14);
  }
  final glasses = clothes['face'];
  if (glasses != null) {
    // The centers of the two painted lenses are at 41% and 79% of the cutout.
    final width = span / .38, height = width * glasses.height / glasses.width;
    c.save();
    c.translate(near.dx, near.dy);
    c.rotate(math.atan2(eyeLine.dy, eyeLine.dx));
    c.drawImageRect(
      glasses,
      Rect.fromLTWH(0, 0, glasses.width.toDouble(), glasses.height.toDouble()),
      Rect.fromLTWH(-width * .41, -height * .5, width, height),
      brush,
    );
    c.restore();
  }
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
