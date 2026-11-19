import 'dart:math' as math;
import 'dart:ui';

import '../domain/companions.dart';

// The same coordinates are used by the walk artwork and the scene projection.
const walkCanvas = Size(512, 464);
const walkOrigin = Offset(256, 440);
const walkWorld = Size(1536, 1024);

enum WalkLeg {
  nearHind('near-hind'),
  nearFront('near-front'),
  farHind('far-hind'),
  farFront('far-front');

  const WalkLeg(this.asset);
  final String asset;
  bool get near => this == nearHind || this == nearFront;
  bool get hind => this == nearHind || this == farHind;
}

class WalkJoints {
  const WalkJoints(this.hip, this.knee, this.pad);
  final Offset hip, knee, pad;
}

typedef WalkDepthJoints = ({Offset hip, Offset pad});

class WalkRig {
  const WalkRig._({
    required this.joints,
    required this.seatedPads,
    required this.sideStride,
    required this.depthStride,
    required this.speed,
    required this.rise,
    required this.sit,
    this.front,
    this.away,
    this.track = 35,
    this.turnArc = 0,
  });

  final List<WalkJoints> joints;
  final List<Offset> seatedPads;
  final List<WalkDepthJoints>? front, away;
  final double sideStride, depthStride, speed, rise, sit, track, turnArc;

  WalkDepthJoints? depthJoints(WalkLeg leg, double depth) =>
      (depth < 0 ? away : front)?[leg.index];

  Offset groundOffset(WalkLeg leg, double side, double depth) {
    final pad = joints[leg.index].pad - walkOrigin;
    if (depthJoints(leg, depth) case final view?) {
      final angled = view.pad - walkOrigin;
      return Offset(pad.dx * side, pad.dy * side.abs()) + angled * depth.abs();
    }
    return Offset(
      pad.dx * side + (leg.near ? -track : track) * depth,
      pad.dy * side.abs() + pad.dx * depth * .33,
    );
  }

  static WalkRig? forPet(Companion pet, int stage, bool reveal) {
    if (stage != 1 || reveal) return null;
    return switch (pet) {
      Companion.cat => cat,
      Companion.fox => fox,
      Companion.rabbit => null,
    };
  }

  static const cat = WalkRig._(
    joints: [
      WalkJoints(Offset(157, 301), Offset(177, 356), Offset(166, 440)),
      WalkJoints(Offset(344, 305), Offset(338, 358), Offset(358, 440)),
      WalkJoints(Offset(195, 291), Offset(216, 343), Offset(206, 423)),
      WalkJoints(Offset(372, 296), Offset(372, 345), Offset(397, 423)),
    ],
    seatedPads: [
      Offset(218, 439),
      Offset(292, 440),
      Offset(244, 422),
      Offset(348, 432),
    ],
    sideStride: 132,
    depthStride: 90,
    speed: 210,
    rise: .30,
    sit: .33,
  );

  static const fox = WalkRig._(
    joints: [
      WalkJoints(Offset(153, 316), Offset(180, 367), Offset(151, 440)),
      WalkJoints(Offset(359, 301), Offset(351, 357), Offset(372, 440)),
      WalkJoints(Offset(189, 304), Offset(210, 351), Offset(193, 420)),
      WalkJoints(Offset(388, 291), Offset(397, 344), Offset(412, 420)),
    ],
    seatedPads: [
      Offset(232, 432),
      Offset(292, 433),
      Offset(372, 421),
      Offset(342, 430),
    ],
    front: [
      (hip: Offset(201, 296), pad: Offset(184, 407)),
      (hip: Offset(222, 311), pad: Offset(214, 440)),
      (hip: Offset(312, 293), pad: Offset(328, 407)),
      (hip: Offset(294, 309), pad: Offset(296, 438)),
    ],
    away: [
      (hip: Offset(214, 316), pad: Offset(210, 439)),
      (hip: Offset(202, 292), pad: Offset(184, 406)),
      (hip: Offset(298, 315), pad: Offset(304, 439)),
      (hip: Offset(311, 293), pad: Offset(329, 405)),
    ],
    sideStride: 144,
    depthStride: 96,
    speed: 214,
    rise: .41,
    sit: .39,
    turnArc: 16,
  );
}

enum WalkStage { rise, turn, walk, gather, sit }

class WalkPaw {
  const WalkPaw(this.ground, [this.lift = 0]);
  final Offset ground;
  final double lift;
  bool get planted => lift == 0;
}

class WalkPose {
  const WalkPose({
    required this.rig,
    required this.root,
    required this.yaw,
    required this.scale,
    required this.paws,
    required this.stage,
    this.crouch = 0,
    this.ink = 1,
    this.phase = 0,
    this.effort = 0,
  });

  /// Root and paws live in the original 1536 × 1024 painting, before any crop.
  final WalkRig rig;
  final Offset root;
  final double yaw, scale, crouch, ink, phase, effort;
  final List<WalkPaw> paws;
  final WalkStage stage;
  bool get left => math.cos(yaw) < 0;

  factory WalkPose.seated(WalkRig rig, Offset root, bool left, double scale) {
    return WalkPose(
      rig: rig,
      root: root,
      yaw: left ? math.pi : 0,
      scale: scale,
      paws: [
        for (final pad in rig.seatedPads)
          WalkPaw(
            root +
                Offset((pad.dx - 256) * (left ? -1 : 1), pad.dy - 440) * scale,
          ),
      ],
      stage: WalkStage.sit,
      crouch: 1,
      ink: 0,
    );
  }
}

class WalkPlan {
  WalkPlan._(this.start, this._segments);
  final double start;
  final List<_Segment> _segments;
  late final double end =
      start + _segments.fold(0.0, (time, segment) => time + segment.duration);

  factory WalkPlan.to(double now, WalkPose from, Offset destination) {
    final rig = from.rig;
    final delta = destination - from.root;
    if (delta.distance < .05) return WalkPlan.stop(now, from);
    final yaw = math.atan2(delta.dy / .58, delta.dx);
    final segments = <_Segment>[];
    var prepared = from;
    if (from.crouch > .01) {
      final stand = _standing(rig, from.root, from.yaw, from.scale);
      segments.add(_Transition(prepared, stand, WalkStage.rise, rig.rise));
      prepared = stand;
    }
    final turn = _turnAngle(prepared.yaw, yaw);
    final aligned = _standing(rig, from.root, prepared.yaw + turn, from.scale);
    final movingPaws = _differentPaws(prepared, aligned);
    if (turn.abs() > .04 || movingPaws) {
      final turning = turn.abs() > .16;
      segments.add(
        _Transition(
          prepared,
          aligned,
          turning ? WalkStage.turn : WalkStage.gather,
          turning ? .21 + .32 * (turn.abs() / math.pi).clamp(0.0, 1.0) : .25,
        ),
      );
    }
    final travel = _Travel(aligned, destination);
    segments.add(travel);
    _settle(segments, travel.at(1));
    return WalkPlan._(now, segments);
  }

  factory WalkPlan.stop(double now, WalkPose from) {
    final segments = <_Segment>[];
    _settle(segments, from);
    return WalkPlan._(now, segments);
  }

  static void _settle(List<_Segment> segments, WalkPose from) {
    final rig = from.rig;
    final seated = WalkPose.seated(rig, from.root, from.left, from.scale);
    final turn = _turnAngle(from.yaw, seated.yaw);
    final stand = _standing(rig, from.root, from.yaw + turn, from.scale);
    if (_differentPaws(from, stand) && from.crouch < .2) {
      segments.add(_Transition(from, stand, WalkStage.gather, .28));
      from = stand;
    }
    segments.add(_Transition(from, seated, WalkStage.sit, rig.sit));
  }

  WalkPose at(double time) {
    var elapsed = math.max(0.0, time - start);
    for (final segment in _segments) {
      if (elapsed < segment.duration) {
        return segment.at(elapsed / segment.duration);
      }
      elapsed -= segment.duration;
    }
    return _segments.last.at(1);
  }
}

double _turnAngle(double from, double to) {
  final delta = to - from;
  final turn = math.atan2(math.sin(delta), math.cos(delta));
  // When changing sides as we set out or sit down, show the face through
  // the turn. A companion already pointed into depth can turn the nearer way.
  final side = math.cos(from);
  if (side.abs() > .97 && side * math.cos(to) < -.22 && side * turn < 0) {
    return turn + 2 * math.pi * side.sign;
  }
  return turn;
}

WalkPose _standing(WalkRig rig, Offset root, double yaw, double scale) =>
    WalkPose(
      rig: rig,
      root: root,
      yaw: yaw,
      scale: scale,
      paws: [
        for (final leg in WalkLeg.values)
          WalkPaw(
            root + rig.groundOffset(leg, math.cos(yaw), math.sin(yaw)) * scale,
          ),
      ],
      stage: WalkStage.gather,
    );

bool _differentPaws(WalkPose a, WalkPose b) => WalkLeg.values.any((leg) {
  final current = a.paws[leg.index], next = b.paws[leg.index];
  return current.lift > 0 || (current.ground - next.ground).distance > .05;
});

double _ease(double t) => t * t * (3 - 2 * t);

double _arc(double t) => 4 * t * (1 - t);

abstract class _Segment {
  const _Segment(this.duration);
  final double duration;
  WalkPose at(double progress);
}

class _Transition extends _Segment {
  _Transition(this.from, this.to, this.stage, super.duration);

  final WalkPose from, to;
  final WalkStage stage;
  late final List<WalkLeg> _plantedAtStart = [
    for (final leg in WalkLeg.values)
      if (from.paws[leg.index].planted) leg,
  ];

  @override
  WalkPose at(double progress) {
    final shift = _ease(progress);
    final scale = from.scale;
    return WalkPose(
      rig: from.rig,
      root: from.root,
      scale: scale,
      stage: stage,
      yaw: from.yaw + _turnAngle(from.yaw, to.yaw) * shift,
      crouch: lerpDouble(from.crouch, to.crouch, shift)!,
      // Hold a single drawing across the cut. Blending the seated and
      // standing silhouettes would create a second face, tail, and paws.
      ink: switch (stage) {
        WalkStage.rise when progress < .075 => from.ink,
        WalkStage.sit when progress >= .94 || from.ink == 0 => 0,
        _ => 1,
      },
      phase: from.phase,
      effort: from.effort * (1 - shift),
      paws: [for (final leg in WalkLeg.values) _paw(leg, progress)],
    );
  }

  WalkPaw _paw(WalkLeg leg, double progress) {
    final a = from.paws[leg.index], b = to.paws[leg.index];
    final length = (b.ground - a.ground).distance;
    if (length < .05 && a.planted) return a;
    final interrupted = _plantedAtStart.length < WalkLeg.values.length;
    // Finish any steps already in the air before lifting another paw.
    final begin = !a.planted
        ? 0.0
        : interrupted
        ? .32 + _plantedAtStart.indexOf(leg) * .20
        : leg.index * .20;
    final span = interrupted ? (a.planted ? .24 : .30) : .38;
    final t = ((progress - begin) / span).clamp(0.0, 1.0);
    final height = (length * .24).clamp(3 * from.scale, 19 * from.scale);
    final ground = Offset.lerp(a.ground, b.ground, _ease(t))!;
    // Step around the other paw on a sharp turn, with the arc ending exactly
    // at the next support so both the old and new contacts stay locked.
    final arc = stage == WalkStage.turn ? from.rig.turnArc * from.scale : 0.0;
    return WalkPaw(
      arc == 0 ? ground : ground + Offset(0, (leg.near ? arc : -arc) * _arc(t)),
      a.lift * (1 - t) + height * _arc(t),
    );
  }
}

typedef _Footfall = ({double begin, double end, Offset from, Offset to});

class _Travel extends _Segment {
  _Travel(this.from, this.destination)
    : distance = (destination - from.root).distance,
      super(.36 + (destination - from.root).distance / from.rig.speed);

  final WalkPose from;
  final Offset destination;
  final double distance;
  late final Offset direction = (destination - from.root) / distance;
  late final double cycle = math.min(
    distance,
    from.scale *
        lerpDouble(
          from.rig.sideStride,
          from.rig.depthStride,
          math.sin(from.yaw).abs(),
        )!,
  );
  late final List<List<_Footfall>> steps = [
    for (final leg in WalkLeg.values) _footfalls(leg),
  ];

  List<_Footfall> _footfalls(WalkLeg leg) {
    final intervals = <_Footfall>[];
    final initial = from.paws[leg.index].ground;
    var previous = initial;
    final spacing = cycle / 4;
    final swingDistance = spacing;
    for (var begin = spacing * leg.index; begin < distance; begin += cycle) {
      final end = math.min(begin + swingDistance, distance);
      if (end - begin < swingDistance * .28) break;
      // The next contact lies ahead of the body at touchdown. Freeze it at
      // that point until toe-off, including while the root is easing out.
      final reach = math.min(end + cycle * .28, distance);
      final next = initial + direction * reach;
      intervals.add((begin: begin, end: end, from: previous, to: next));
      previous = next;
    }
    return intervals;
  }

  WalkPaw _paw(WalkLeg leg, double advanced) {
    var position = from.paws[leg.index].ground;
    for (final step in steps[leg.index]) {
      if (advanced <= step.begin) break;
      if (advanced < step.end) {
        final t = (advanced - step.begin) / (step.end - step.begin);
        final length = (step.to - step.from).distance;
        return WalkPaw(
          Offset.lerp(step.from, step.to, _ease(t))!,
          _arc(t) * math.min(length * .29, 31 * from.scale),
        );
      }
      position = step.to;
    }
    return WalkPaw(position);
  }

  @override
  WalkPose at(double progress) {
    // Accelerate and brake over equal portions of the travel, with a steady
    // middle. Paws and drawn key poses use the resulting distance, not time.
    const ramp = .24;
    const brake = 1 - ramp;
    final fraction =
        switch (progress) {
          < ramp => progress * progress / (2 * ramp),
          > brake => brake - (1 - progress) * (1 - progress) / (2 * ramp),
          _ => progress - ramp / 2,
        } /
        (1 - ramp);
    final advanced = distance * fraction;
    return WalkPose(
      rig: from.rig,
      root: Offset.lerp(from.root, destination, fraction)!,
      yaw: from.yaw,
      scale: from.scale,
      stage: WalkStage.walk,
      phase: .75 + advanced / cycle,
      effort: math.min(1.0, math.min(progress, 1 - progress) / ramp),
      paws: [for (final leg in WalkLeg.values) _paw(leg, advanced)],
    );
  }
}
