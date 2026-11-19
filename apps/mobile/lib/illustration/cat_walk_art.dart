import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../domain/companions.dart';
import 'cat_walk.dart';
import 'tailoring.dart';

const _folder = 'assets/cat_walk/';
// Align the eyes between the side and face-on drawings during the turn.
const _headPivot = Offset(384, 154);
const _frontPivot = Offset(256, 179);
const _tailPivot = Offset(149, 298);

String _clothes(String? garment) => switch (garment) {
  'item_single_coat' => '-coat',
  'item_single_apron' => '-apron',
  _ => '',
};

List<String> catWalkAssets(String? garment) {
  final outfit = _clothes(garment);
  return [
    'head',
    'head-front',
    'head-away',
    'tail',
    'torso$outfit',
    'torso-front$outfit',
    'torso-away$outfit',
    if (outfit.isNotEmpty) 'trim$outfit',
    for (final leg in CatLeg.values) ...[
      'leg-${leg.asset}-upper',
      'leg-${leg.asset}-lower',
      'paw-${leg.asset}',
    ],
  ].map((name) => '$_folder$name.webp').toList();
}

class CatWalkArt {
  CatWalkArt(
    this._images,
    String? garment,
    Map<String, ui.Image> clothes,
    String? headAsset,
  ) : _coat = _clothes(garment) {
    if (clothes.isEmpty) return;
    _sideHead = _dress(_Head.side, clothes, headAsset);
    _frontHead = _dress(_Head.front, clothes, headAsset);
    final rearClothes = Map.of(clothes)..remove('face');
    if (rearClothes.isNotEmpty) {
      _awayHead = _dress(_Head.away, rearClothes, headAsset);
    }
  }

  final Map<String, ui.Image> _images;
  final String _coat;
  DressedPortrait? _sideHead, _frontHead, _awayHead;

  ui.Image _image(String name) => _images['$_folder$name.webp']!;

  DressedPortrait _dress(
    _Head view,
    Map<String, ui.Image> clothes,
    String? headAsset,
  ) {
    Offset normalized(Offset p) =>
        Offset(p.dx / catWalkCanvas.width, p.dy / catWalkCanvas.height);
    final side = view == _Head.side;
    return applyAccessories(
      _image(view.asset),
      Companion.cat,
      1,
      false,
      normalized(side ? const Offset(338, 166) : const Offset(207, 179)),
      normalized(side ? const Offset(431, 142) : const Offset(306, 179)),
      clothes,
      headAsset,
      fit: (
        crown: normalized(
          side ? const Offset(365, 88) : const Offset(256, 112),
        ),
        ear: normalized(side ? const Offset(274, 134) : const Offset(161, 111)),
        neck: normalized(switch (view) {
          _Head.side => const Offset(383, 247),
          _Head.front => const Offset(256, 275),
          _Head.away => const Offset(256, 278),
        }),
        width: (side ? 191 : 213) / catWalkCanvas.width,
      ),
    );
  }

  void dispose() {
    _sideHead?.image.dispose();
    _frontHead?.image.dispose();
    _awayHead?.image.dispose();
  }

  void paint(Canvas canvas, Rect box, CatWalkPose pose) {
    final artScale = box.height / catWalkOrigin.dy;
    canvas.save();
    canvas.translate(box.center.dx, box.bottom);
    canvas.scale(artScale);
    canvas.translate(-catWalkOrigin.dx, -catWalkOrigin.dy);
    _CatPosePainting(canvas, this, pose).paint();
    canvas.restore();
  }
}

enum _Head {
  side('head', _headPivot),
  front('head-front', _frontPivot),
  away('head-away', _frontPivot);

  const _Head(this.asset, this.pivot);
  final String asset;
  final Offset pivot;
}

class _CatPosePainting {
  _CatPosePainting(this.canvas, this.art, this.pose);

  final Canvas canvas;
  final CatWalkArt art;
  final CatWalkPose pose;
  final brush = Paint()..filterQuality = FilterQuality.medium;

  late final double side = math.cos(pose.yaw), depth = math.sin(pose.yaw);
  late final double facing = side < 0 ? -1 : 1;
  late final double profile = _fade((side.abs() - .22) / .42);
  late final bool sideView = profile >= .5;
  late final double width = (.53 + side.abs() * .47) * (1 - pose.crouch * .48);
  late final _WeightShift shift = _weightShift(pose.phase, pose.effort);
  late final double drop = 32 * pose.crouch + shift.body.dy;
  late final double slope = depth * .18 - pose.crouch * .21 + shift.tilt;

  void paint() {
    final legs = CatLeg.values.toList()
      ..sort((a, b) => _depthOf(a).compareTo(_depthOf(b)));
    _tail();
    _leg(legs[0]);
    _leg(legs[1]);
    _crossSection('torso');
    _leg(legs[2]);
    _leg(legs[3]);
    if (art._coat.isNotEmpty) _crossSection('trim');
    _head();
  }

  double _depthOf(CatLeg leg) =>
      (leg.pad.dy - catWalkOrigin.dy) * side.abs() +
      (leg.pad.dx - catWalkOrigin.dx) * depth * .33;

  Offset _bodyPoint(Offset p) {
    final dx = p.dx - catWalkOrigin.dx;
    return Offset(
      catWalkOrigin.dx +
          (dx * width - 10 * pose.crouch + shift.body.dx) * facing,
      p.dy + drop + dx * slope,
    );
  }

  void _tail() {
    final root = _bodyPoint(_tailPivot);
    canvas.save();
    canvas.translate(root.dx, root.dy);
    canvas.rotate(facing * (.14 * pose.crouch + shift.tilt * 2));
    canvas.scale(
      side.abs() < .22 ? side / .22 * .64 : .64 * facing + side * .36,
      1,
    );
    canvas.drawImage(art._image('tail'), -_tailPivot, brush);
    canvas.restore();
  }

  void _crossSection(String name) {
    if (name == 'torso' && !sideView) {
      canvas.save();
      canvas.translate(catWalkOrigin.dx, catWalkOrigin.dy + drop + depth * 4);
      canvas.scale(1 - pose.crouch * .22, 1);
      canvas.drawImage(
        art._image('torso-${depth < 0 ? 'away' : 'front'}${art._coat}'),
        -catWalkOrigin,
        brush,
      );
      canvas.restore();
    }
    if (sideView) {
      final root = _bodyPoint(catWalkOrigin);
      canvas.save();
      canvas.translate(root.dx, root.dy);
      canvas.transform(
        Float64List.fromList([
          facing * width,
          slope,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          1,
        ]),
      );
      canvas.drawImage(art._image('$name${art._coat}'), -catWalkOrigin, brush);
      canvas.restore();
    }
  }

  void _leg(CatLeg leg) {
    final step = pose.paws[leg.index];
    final ground = catWalkOrigin + (step.ground - pose.root) / pose.scale;
    final pad = ground - Offset(0, step.lift / pose.scale);
    final ankle = pad - const Offset(0, 29);
    final sideHip = _bodyPoint(leg.hip);
    final frontHip = Offset(
      catWalkOrigin.dx + (leg.near ? -31 : 31) * depth,
      leg.hip.dy + drop + (leg.hind ? -10 : 12) * depth,
    );
    final hip = Offset.lerp(frontHip, sideHip, profile)!;
    final kneeRest =
        leg.knee - Offset.lerp(leg.hip, leg.pad - const Offset(0, 29), .49)!;
    final flex =
        (leg.hind ? 1 : -1) * (step.lift / pose.scale * .72).clamp(0.0, 22.0);
    final knee =
        Offset.lerp(hip, ankle, .49)! +
        Offset((kneeRest.dx + flex) * side, kneeRest.dy);
    _bone('leg-${leg.asset}-upper', hip, knee);
    _bone('leg-${leg.asset}-lower', knee, ankle);
    canvas.save();
    canvas.translate(pad.dx, pad.dy);
    canvas.scale(facing, 1);
    canvas.drawImage(
      art._image('paw-${leg.asset}'),
      const Offset(-64, -84),
      brush,
    );
    canvas.restore();
  }

  void _bone(String texture, Offset joint, Offset end) {
    final axis = end - joint;
    canvas.save();
    canvas.translate(joint.dx, joint.dy);
    canvas.rotate(math.atan2(axis.dy, axis.dx) - math.pi / 2);
    canvas.scale(facing, axis.distance / 96);
    canvas.drawImage(art._image(texture), const Offset(-64, -32), brush);
    canvas.restore();
  }

  void _head() {
    final center = Offset(
      catWalkOrigin.dx + side * (128 - 58.3 * pose.crouch),
      154 + 9.05 * pose.crouch + shift.head.dy + depth.abs() * 20,
    );
    canvas.save();
    canvas.translate(center.dx + shift.head.dx * facing, center.dy);
    canvas.rotate(
      facing * (shift.tilt - .12 * pose.crouch * (1 - pose.crouch)) * profile,
    );
    final scale = 1 + pose.crouch * (1 / .92 - 1);
    canvas.scale(
      sideView ? facing * (.83 + .17 * side.abs()) * scale : scale,
      scale,
    );
    _drawHead(
      sideView
          ? _Head.side
          : depth < 0
          ? _Head.away
          : _Head.front,
    );
    canvas.restore();
  }

  void _drawHead(_Head view) {
    final dressed = switch (view) {
      _Head.side => art._sideHead,
      _Head.front => art._frontHead,
      _Head.away => art._awayHead,
    };
    canvas.drawImage(
      dressed?.image ?? art._image(view.asset),
      -view.pivot - (dressed?.padding ?? Offset.zero),
      brush,
    );
  }
}

double _fade(double t) {
  final k = t.clamp(0.0, 1.0);
  return k * k * (3 - 2 * k);
}

typedef _WeightShift = ({Offset body, Offset head, double tilt});

_WeightShift _weightShift(double phase, double effort) {
  // Two authored poses per beat: step down, then pass over the support.
  const poses = [
    (Offset(-1, 2), Offset(-3, 4), -3),
    (Offset(2, -3), Offset(4, -2), -1),
    (Offset(1, 2), Offset(3, 5), 4),
    (Offset(3, -2), Offset(5, 0), 3),
    (Offset(-1, 2), Offset(-4, 3), -3),
    (Offset(0, -3), Offset(3, -2), -1),
    (Offset(-1, 3), Offset(1, 5), 3),
    (Offset(-3, -2), Offset(-5, 1), 2),
  ];
  final point = phase % 1 * poses.length;
  final before = poses[point.floor()];
  final after = poses[(point.floor() + 1) % poses.length];
  final mix = _fade(point % 1);
  return (
    body: Offset.lerp(before.$1, after.$1, mix)! * effort,
    head: Offset.lerp(before.$2, after.$2, mix)! * effort,
    tilt: ui.lerpDouble(before.$3, after.$3, mix)! * effort / 187,
  );
}
