import 'dart:math' as math;
import 'dart:ui';

import '../domain/companions.dart';

// The same coordinates are used by the walk artwork and the scene projection.
const walkCanvas = Size(512, 464);
const walkOrigin = Offset(256, 440);
const walkWorld = Size(1536, 1024);

enum WalkLeg {
  nearHind,
  nearFront,
  farHind,
  farFront;

  bool get near => this == nearHind || this == nearFront;
}

class WalkRig {
  const WalkRig._({
    required this.standingPads,
    required this.seatedPads,
    required this.sideStride,
    required this.depthStride,
    required this.speed,
    required this.rise,
    required this.sit,
    this.front,
    this.away,
    this.turnArc = 0,
    this.usesPortrait = false,
  });

  factory WalkRig.painted(
    List<Offset> pads, {
    required double sideStride,
    required double depthStride,
    required double speed,
  }) => WalkRig._(
    standingPads: pads,
    seatedPads: pads,
    sideStride: sideStride,
    depthStride: depthStride,
    speed: speed,
    rise: .34,
    sit: .36,
    turnArc: 9,
    usesPortrait: true,
  );

  final List<Offset> standingPads, seatedPads;
  final List<Offset>? front, away;
  final double sideStride, depthStride, speed, rise, sit, turnArc;
  final bool usesPortrait;

  Offset groundOffset(WalkLeg leg, double side, double depth) {
    final pad = standingPads[leg.index] - walkOrigin;
    if (usesPortrait) {
      return Offset(
        pad.dx * side + (leg.near ? -24 : 24) * depth,
        pad.dy + pad.dx * depth * .18,
      );
    }
    final angled = (depth < 0 ? away! : front!)[leg.index] - walkOrigin;
    return Offset(pad.dx * side, pad.dy * side.abs()) + angled * depth.abs();
  }

  static WalkRig? forPet(Companion pet, int stage) {
    if (stage != 1) return null;
    return switch (pet) {
      Companion.cat => cat,
      Companion.fox => fox,
      Companion.rabbit => null,
      Companion.otter => otter,
      Companion.hedgehog => hedgehog,
    };
  }

  static const cat = WalkRig._(
    standingPads: [
      Offset(176, 436),
      Offset(304, 438),
      Offset(223, 419),
      Offset(363, 435),
    ],
    seatedPads: [
      Offset(218, 439),
      Offset(292, 440),
      Offset(244, 422),
      Offset(348, 432),
    ],
    front: [
      Offset(139, 428),
      Offset(272, 438),
      Offset(207, 426),
      Offset(344, 428),
    ],
    away: [
      Offset(193, 435),
      Offset(144, 423),
      Offset(339, 436),
      Offset(264, 425),
    ],
    sideStride: 114,
    depthStride: 80,
    speed: 210,
    rise: .41,
    sit: .38,
    turnArc: 10,
  );

  static const fox = WalkRig._(
    standingPads: [
      Offset(164, 435),
      Offset(275, 438),
      Offset(231, 416),
      Offset(364, 431),
    ],
    seatedPads: [
      Offset(232, 432),
      Offset(292, 433),
      Offset(372, 421),
      Offset(342, 430),
    ],
    front: [
      Offset(167, 433),
      Offset(267, 439),
      Offset(204, 421),
      Offset(343, 434),
    ],
    away: [
      Offset(231, 437),
      Offset(182, 427),
      Offset(352, 433),
      Offset(295, 418),
    ],
    sideStride: 126,
    depthStride: 86,
    speed: 214,
    rise: .48,
    sit: .43,
    turnArc: 16,
  );

  static const otter = WalkRig._(
    standingPads: [
      Offset(182, 438),
      Offset(358, 438),
      Offset(212, 424),
      Offset(385, 435),
    ],
    seatedPads: [
      Offset(173, 434),
      Offset(316, 440),
      Offset(222, 425),
      Offset(410, 434),
    ],
    front: [
      Offset(175, 432),
      Offset(220, 439),
      Offset(322, 432),
      Offset(293, 438),
    ],
    away: [
      Offset(173, 436),
      Offset(199, 430),
      Offset(344, 436),
      Offset(312, 430),
    ],
    sideStride: 99,
    depthStride: 64,
    speed: 186,
    rise: .30,
    sit: .32,
    turnArc: 7,
  );

  static const hedgehog = WalkRig._(
    standingPads: [
      Offset(111, 436),
      Offset(289, 438),
      Offset(177, 432),
      Offset(348, 436),
    ],
    seatedPads: [
      Offset(110, 434),
      Offset(277, 439),
      Offset(180, 429),
      Offset(371, 435),
    ],
    front: [
      Offset(154, 431),
      Offset(206, 438),
      Offset(361, 431),
      Offset(310, 438),
    ],
    away: [
      Offset(174, 439),
      Offset(201, 431),
      Offset(340, 437),
      Offset(312, 431),
    ],
    sideStride: 72,
    depthStride: 51,
    speed: 157,
    rise: .24,
    sit: .26,
    turnArc: 5,
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
    this.headYaw,
    this.load = Offset.zero,
  });

  /// Root and paws live in the original 1536 × 1024 painting, before any crop.
  final WalkRig rig;
  final Offset root;
  final double yaw, scale, crouch, ink, phase, effort;
  final double? headYaw;
  final Offset load;
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
                Offset(
                      (pad.dx - walkOrigin.dx) * (left ? -1 : 1),
                      pad.dy - walkOrigin.dy,
                    ) *
                    scale,
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
      final duration = turning
          ? .21 + .32 * (turn.abs() / math.pi).clamp(0.0, 1.0)
          : .25;
      if (turn.abs() > 1.65) {
        // Set all four paws in the middle view before swinging the shoulders
        // through a reversal. The longer front legs can stay under the chest.
        final middle = _standing(
          rig,
          from.root,
          prepared.yaw + turn / 2,
          from.scale,
        );
        segments.add(
          _Transition(prepared, middle, WalkStage.turn, duration * .65),
        );
        segments.add(
          _Transition(middle, aligned, WalkStage.turn, duration * .65),
        );
      } else {
        segments.add(
          _Transition(
            prepared,
            aligned,
            turning ? WalkStage.turn : WalkStage.gather,
            duration,
          ),
        );
      }
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
    // The fox's rear drawing carries the tail to the right. It turns back
    // over that shoulder before sitting so the tail follows the same arc.
    final turnBack = rig == WalkRig.fox && math.sin(from.yaw) < -.815;
    final seated = WalkPose.seated(
      rig,
      from.root,
      turnBack || from.left,
      from.scale,
    );
    final turn = _turnAngle(from.yaw, seated.yaw);
    final stand = _standing(rig, from.root, from.yaw + turn, from.scale);
    if (_differentPaws(from, stand) && from.crouch < .2) {
      final duration = .32 + (turnBack ? .13 * turn.abs() : 0);
      segments.add(_Transition(from, stand, WalkStage.gather, duration));
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
  // A lateral reversal presents the face. When setting out into depth,
  // turn directly towards the destination.
  final side = math.cos(from);
  if (math.sin(to) > -.38 &&
      side.abs() > .97 &&
      side * math.cos(to) < -.22 &&
      side * turn < 0) {
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
    final bracing = stage == WalkStage.rise && from.ink == 0;
    final action = bracing
        ? ((progress - .22) / .78).clamp(0.0, 1.0)
        : progress;
    final shift = _ease(action);
    final scale = from.scale;
    final angle = _turnAngle(from.yaw, to.yaw);
    final yaw = from.yaw + angle * shift;
    final headLead = stage == WalkStage.turn
        ? angle * (_ease((action * 1.26).clamp(0.0, 1.0)) - shift)
        : 0.0;
    final load = switch (stage) {
      WalkStage.rise when from.rig == WalkRig.cat => _catRiseLoad(
        progress,
        shift,
      ),
      WalkStage.rise => Offset(
        -5 * _arc(progress) + 12 * _arc(action),
        9 * _arc(progress) - 11 * _arc(action),
      ),
      WalkStage.turn => Offset(4 * _arc(action), 5 * _arc(action)),
      WalkStage.gather => Offset(-5 * _arc(action), 6 * _arc(action)),
      WalkStage.sit => Offset(-11 * _arc(action), 7 * _arc(action)),
      WalkStage.walk => Offset.zero,
    };
    return WalkPose(
      rig: from.rig,
      root: from.root,
      scale: scale,
      stage: stage,
      yaw: yaw,
      headYaw:
          yaw +
          headLead +
          ((from.headYaw ?? from.yaw) - from.yaw) * (1 - shift),
      crouch: lerpDouble(from.crouch, to.crouch, shift)!,
      // Hold a single drawing across the cut. Blending the seated and
      // standing silhouettes would create a second face, tail, and paws.
      ink: switch (stage) {
        WalkStage.rise when action <= .075 => from.ink,
        WalkStage.sit when action >= .94 || from.ink == 0 => 0,
        _ => 1,
      },
      phase: from.phase,
      effort: from.effort * (1 - shift),
      load: Offset.lerp(from.load, to.load, shift)! + load,
      paws: [for (final leg in WalkLeg.values) _paw(leg, action)],
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

// MO-01 production-v3, frames 0, 7, 14, 20 and 27. These are the means of
// the shoulder and haunch displacements with the path translation removed.
const _catRiseKeys = [
  (0.0, Offset.zero),
  (7 / 27, Offset(0, 2.405)),
  (14 / 27, Offset(-.940, -5.610)),
  (20 / 27, Offset(-4.100, -28.710)),
  (1.0, Offset(-5.995, -41.945)),
];

Offset _catRiseLoad(double time, double rise) {
  for (var i = 1; i < _catRiseKeys.length; i++) {
    final (to, high) = _catRiseKeys[i];
    if (time > to) continue;
    final (from, low) = _catRiseKeys[i - 1];
    final paint = Offset.lerp(low, high, _ease((time - from) / (to - from)))!;
    return (paint - _catRiseKeys.last.$2 * rise) * .55;
  }
  return Offset.zero;
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
