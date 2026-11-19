import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../domain/companions.dart';
import 'companion_walk.dart';
import 'companion_motion.dart';
import 'tailoring.dart';

String _walkFolder(Companion pet) => 'assets/${pet.name}_walk/';

String _clothes(String? garment) => switch (garment) {
  'item_single_coat' => '-coat',
  'item_single_apron' => '-apron',
  _ => '',
};

List<String> walkAssets(Companion pet, String? garment) {
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
    for (final leg in WalkLeg.values) ...[
      'leg-${leg.asset}-upper',
      'leg-${leg.asset}-lower',
      'paw-${leg.asset}',
    ],
  ].map((name) => '${_walkFolder(pet)}$name.webp').toList();
}

class WalkArt {
  WalkArt(
    this.pet,
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

  final Companion pet;
  final Map<String, ui.Image> _images;
  final String _coat;
  late final _WalkFitting _fit = _fittings[pet]!;
  DressedPortrait? _sideHead, _frontHead, _awayHead;

  ui.Image _image(String name) => _images['${_walkFolder(pet)}$name.webp']!;

  DressedPortrait _dress(
    _Head view,
    Map<String, ui.Image> clothes,
    String? headAsset,
  ) {
    Offset normalized(Offset p) =>
        Offset(p.dx / walkCanvas.width, p.dy / walkCanvas.height);
    final fitting = _fit.heads[view.index];
    return applyAccessories(
      _image(view.asset),
      pet,
      1,
      false,
      normalized(fitting.nearEye),
      normalized(fitting.farEye),
      clothes,
      headAsset,
      fit: (
        crown: normalized(fitting.crown),
        ear: normalized(fitting.ear),
        neck: normalized(fitting.neck),
        width: fitting.width / walkCanvas.width,
      ),
    );
  }

  void dispose() {
    _sideHead?.image.dispose();
    _frontHead?.image.dispose();
    _awayHead?.image.dispose();
  }

  void paint(Canvas canvas, Rect box, WalkPose pose, PetMotion motion) {
    final artScale = box.height / walkOrigin.dy;
    canvas.save();
    canvas.translate(box.center.dx, box.bottom);
    canvas.scale(artScale);
    canvas.translate(-walkOrigin.dx, -walkOrigin.dy);
    _WalkPainting(canvas, this, pose, motion).paint();
    canvas.restore();
  }
}

enum _Head {
  side('head'),
  front('head-front'),
  away('head-away');

  const _Head(this.asset);
  final String asset;
}

class _HeadFitting {
  const _HeadFitting(
    this.pivot,
    this.nearEye,
    this.farEye,
    this.crown,
    this.ear,
    this.neck,
    this.width,
  );
  final Offset pivot, nearEye, farEye, crown, ear, neck;
  final double width;
}

class _WalkFitting {
  const _WalkFitting({
    required this.heads,
    required this.seatedEyeShift,
    required this.seatedHeadScale,
    required this.tailPivot,
    this.tailSweep = 0,
  });
  final List<_HeadFitting> heads;
  final Offset seatedEyeShift, tailPivot;
  final double seatedHeadScale, tailSweep;
}

// The middle of the eyes registers the three views through an in-place turn.
const _fittings = {
  Companion.cat: _WalkFitting(
    heads: [
      _HeadFitting(
        Offset(384, 154),
        Offset(338, 166),
        Offset(431, 142),
        Offset(365, 88),
        Offset(274, 134),
        Offset(383, 247),
        191,
      ),
      _HeadFitting(
        Offset(256, 179),
        Offset(207, 179),
        Offset(306, 179),
        Offset(256, 112),
        Offset(161, 111),
        Offset(256, 275),
        213,
      ),
      _HeadFitting(
        Offset(256, 179),
        Offset(207, 179),
        Offset(306, 179),
        Offset(256, 112),
        Offset(161, 111),
        Offset(256, 278),
        213,
      ),
    ],
    seatedEyeShift: Offset(-58.3, 9.05),
    seatedHeadScale: 1 / .92,
    tailPivot: Offset(149, 298),
  ),
  Companion.fox: _WalkFitting(
    heads: [
      _HeadFitting(
        Offset(403, 183),
        Offset(358, 190),
        Offset(448, 176),
        Offset(391, 130),
        Offset(257, 135),
        Offset(410, 260),
        215,
      ),
      _HeadFitting(
        Offset(256, 191),
        Offset(210, 192),
        Offset(301, 190),
        Offset(256, 132),
        Offset(171, 133),
        Offset(256, 269),
        229,
      ),
      _HeadFitting(
        Offset(256, 191),
        Offset(210, 192),
        Offset(301, 190),
        Offset(256, 132),
        Offset(171, 128),
        Offset(256, 268),
        229,
      ),
    ],
    seatedEyeShift: Offset(-72, -3),
    seatedHeadScale: 440 / (451 * .88),
    tailPivot: Offset(152, 322),
    tailSweep: .18,
  ),
};

class _WalkPainting {
  _WalkPainting(this.canvas, this.art, this.pose, this.motion);

  final Canvas canvas;
  final WalkArt art;
  final WalkPose pose;
  final PetMotion motion;
  final brush = Paint()..filterQuality = FilterQuality.medium;

  late final double side = math.cos(pose.yaw), depth = math.sin(pose.yaw);
  late final double facing = side < 0 ? -1 : 1;
  late final double profile = _fade((side.abs() - .22) / .42);
  late final bool sideView = profile >= .5;
  late final double width = (.53 + side.abs() * .47) * (1 - pose.crouch * .48);
  late final _WeightShift shift = _weightShift(
    art.pet,
    pose.phase,
    pose.effort,
  );
  late final double drop = 32 * pose.crouch + shift.body.dy;
  late final double slope = depth * .18 - pose.crouch * .21 + shift.tilt;

  void paint() {
    final legs = WalkLeg.values.toList()
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

  double _depthOf(WalkLeg leg) => pose.rig.groundOffset(leg, side, depth).dy;

  Offset _bodyPoint(Offset p) {
    final dx = p.dx - walkOrigin.dx;
    return Offset(
      walkOrigin.dx + (dx * width - 10 * pose.crouch + shift.body.dx) * facing,
      p.dy + drop + dx * slope,
    );
  }

  void _tail() {
    final fitting = art._fit;
    final away = art.pet == Companion.fox && depth < 0
        ? (1 - profile) * -depth
        : 0.0;
    final root = Offset.lerp(
      _bodyPoint(fitting.tailPivot),
      Offset(walkOrigin.dx, fitting.tailPivot.dy + drop),
      away,
    )!;
    final transition = switch (pose.stage) {
      WalkStage.rise => 1.0,
      WalkStage.sit => -1.0,
      _ => 0.0,
    };
    final delayedSwing = fitting.tailSweep == 0
        ? 0.0
        : fitting.tailSweep *
              (math.sin((pose.phase - .18) * math.pi * 2) * pose.effort +
                  .65 * transition * math.sin(pose.crouch * math.pi));
    canvas.save();
    canvas.translate(root.dx, root.dy);
    canvas.rotate(facing * (.14 * pose.crouch + shift.tilt * 2 + delayedSwing));
    final sideWidth = side.abs() < .22
        ? side / .22 * .64
        : .64 * facing + side * .36;
    canvas.scale(ui.lerpDouble(sideWidth, .46, away)!, 1);
    canvas.drawImage(art._image('tail'), -fitting.tailPivot, brush);
    canvas.restore();
  }

  void _crossSection(String name) {
    if (name == 'torso' && !sideView) {
      canvas.save();
      canvas.translate(walkOrigin.dx, walkOrigin.dy + drop + depth * 4);
      canvas.scale(1 - pose.crouch * .22, 1);
      canvas.drawImage(
        art._image('torso-${depth < 0 ? 'away' : 'front'}${art._coat}'),
        -walkOrigin,
        brush,
      );
      canvas.restore();
    }
    if (sideView) {
      final root = _bodyPoint(walkOrigin);
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
      canvas.drawImage(art._image('$name${art._coat}'), -walkOrigin, brush);
      canvas.restore();
    }
  }

  void _leg(WalkLeg leg) {
    final joints = pose.rig.joints[leg.index];
    final step = pose.paws[leg.index];
    final ground = walkOrigin + (step.ground - pose.root) / pose.scale;
    final pad = ground - Offset(0, step.lift / pose.scale);
    final ankle = pad - const Offset(0, 29);
    final sideHip = _bodyPoint(joints.hip);
    final depthArt = pose.rig.depthJoints(leg, depth);
    final frontHip = depthArt == null
        ? Offset(
            walkOrigin.dx + (leg.near ? -31 : 31) * depth,
            joints.hip.dy + drop + (leg.hind ? -10 : 12) * depth,
          )
        : depthArt.hip + Offset(0, drop + depth * 4);
    final hip = Offset.lerp(frontHip, sideHip, profile)!;
    final kneeRest =
        joints.knee -
        Offset.lerp(joints.hip, joints.pad - const Offset(0, 29), .49)!;
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
    final nudge = motion.action == PetAction.nuzzle
        ? motion.lean
        : art.pet == Companion.fox && pose.stage == WalkStage.rise
        ? pulse(1 - pose.crouch, 0, .75) * .9
        : 0.0;
    final fitting = art._fit;
    final eyes = fitting.heads[_Head.side.index].pivot;
    final center = Offset(
      walkOrigin.dx +
          side *
              (eyes.dx -
                  walkOrigin.dx +
                  fitting.seatedEyeShift.dx * pose.crouch +
                  nudge * 12),
      eyes.dy +
          fitting.seatedEyeShift.dy * pose.crouch +
          shift.head.dy +
          depth.abs() * 20 +
          nudge.abs() * 8,
    );
    canvas.save();
    canvas.translate(center.dx + shift.head.dx * facing, center.dy);
    canvas.rotate(
      facing * (shift.tilt - .12 * pose.crouch * (1 - pose.crouch)) * profile,
    );
    final scale = 1 + pose.crouch * (fitting.seatedHeadScale - 1);
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
      -art._fit.heads[view.index].pivot - (dressed?.padding ?? Offset.zero),
      brush,
    );
  }
}

double _fade(double t) {
  final k = t.clamp(0.0, 1.0);
  return k * k * (3 - 2 * k);
}

typedef _WeightShift = ({Offset body, Offset head, double tilt});

_WeightShift _weightShift(Companion pet, double phase, double effort) {
  // Two authored poses per beat: step down, then pass over the support.
  final poses = pet == Companion.fox
      ? const [
          (Offset(-1, 2), Offset(-3, 2), -5),
          (Offset(2, -3), Offset(5, -1), -1),
          (Offset(1, 3), Offset(4, 5), 5),
          (Offset(3, -2), Offset(3, -1), 1),
          (Offset(-1, 2), Offset(-4, 3), -3),
          (Offset(0, -3), Offset(3, -3), -2),
          (Offset(-1, 3), Offset(0, 5), 3),
          (Offset(-3, -3), Offset(-4, 1), 3),
        ]
      : const [
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
