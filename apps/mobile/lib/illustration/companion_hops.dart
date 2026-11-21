import 'dart:math' as math;
import 'dart:ui';

import '../domain/companions.dart';
import 'companion_motion.dart';

const rabbitShortHopArt = 'assets/art/rabbit-hop-tuck.webp';
const rabbitLandingArt = 'assets/art/rabbit-hop-landing.webp';
const cloudBraceArt = 'assets/art/cloud-cat-4-brace.webp';
const cloudFlightArt = 'assets/art/cloud-cat-4-flight.webp';
const cloudLandingArt = 'assets/art/cloud-cat-4-land.webp';
const cloudRearBraceArt = 'assets/art/cloud-cat-4-rear-brace.webp';
const cloudRearFlightArt = 'assets/art/cloud-cat-4-rear-flight.webp';
const cloudRearLandingArt = 'assets/art/cloud-cat-4-rear-land.webp';

enum HopStyle {
  rabbit(.20, .34, .24, .20, .142),
  cloudHop(.20, .43, .22, .22, .21),
  cloudCat(.24, .70, .20, .26, .30),
  leafFox(.18, .48, .23, .22, .234);

  const HopStyle(this.prepare, this.flight, this.land, this.turn, this.stride);
  final double prepare, flight, land, turn, stride;
  double get beat => prepare + flight + land;

  static HopStyle? forPose(Companion pet, int stage) {
    if (pet == Companion.rabbit) return HopStyle.rabbit;
    if (pet == Companion.cat && stage >= 4) {
      return stage == 4 ? HopStyle.cloudHop : HopStyle.cloudCat;
    }
    if (pet == Companion.fox && stage == 6) return HopStyle.leafFox;
    return null;
  }
}

class CompanionHopPose {
  const CompanionHopPose({
    this.airborne = false,
    this.forepawPose = false,
    this.bracePose = false,
    this.facesAway = false,
    this.lift = 0,
    this.compression = 0,
    this.lean = 0,
    this.earLag = 0,
    this.hindLift = 0,
    this.width = 1,
    this.recovery = 0,
  });

  final bool airborne, forepawPose, bracePose, facesAway;
  final double lift, compression, lean, earLag, hindLift, width, recovery;
}

typedef CompanionHopFrame = ({Offset ground, bool left, CompanionHopPose pose});

/// Short hops, leaf bounds and longer wingbeats have distinct timing. Each
/// preparation and recovery is kept over the original patch of ground.
class CompanionHopPlan {
  CompanionHopPlan(
    this.style,
    this.start,
    this.from,
    this.destination,
    this.wasLeft, {
    this.wasAway = false,
  }) {
    final dx = destination.dx - from.dx;
    final dy = destination.dy - from.dy;
    left = dx.abs() < .01 ? wasLeft : dx < 0;
    facesAway =
        style == HopStyle.cloudHop && dy < -.085 && -dy > dx.abs() * .82;
    final stride = Offset(dx * 1.5, dy).distance;
    hops = (stride / style.stride).ceil().clamp(1, 7);
    final length = stride / hops;
    peak = switch (style) {
      HopStyle.rabbit => (length * .8).clamp(.065, .144),
      HopStyle.cloudHop => (.036 + length * .67).clamp(.075, .160),
      HopStyle.cloudCat => (.082 + length * .57).clamp(.105, .215),
      HopStyle.leafFox => (length * .67).clamp(.08, .162),
    };
  }

  final HopStyle style;
  final double start;
  final Offset from, destination;
  final bool wasLeft, wasAway;
  late final bool left, facesAway;
  late final int hops;
  late final double peak;
  double get pivot => wasLeft == left && wasAway == facesAway ? 0 : style.turn;
  double get _arrival => start + pivot + style.beat * hops;
  double get end => _arrival + (facesAway ? style.turn : 0);

  double nextRest(double now) {
    final afterPivot = now - start - pivot;
    if (afterPivot < 0) return start + pivot;
    final beat = style.beat;
    final hop = (afterPivot / beat).floor().clamp(0, hops - 1);
    return hop == hops - 1 ? end : start + pivot + (hop + 1) * beat;
  }

  CompanionHopPose _pivot(double progress, bool away) {
    final bending = math.sin(progress * math.pi);
    return CompanionHopPose(
      bracePose: away,
      facesAway: away,
      width: 1 - bending * (style == HopStyle.rabbit ? .075 : .090),
      compression: bending * .033,
      lean: .22 * bending,
    );
  }

  CompanionHopFrame at(double now) {
    final elapsed = math.max(0.0, now - start);
    if (elapsed < pivot) {
      final turn = elapsed / pivot;
      return (
        ground: from,
        left: turn < .5 ? wasLeft : left,
        pose: _pivot(turn, turn < .5 ? wasAway : facesAway),
      );
    }
    if (now >= end) {
      return (ground: destination, left: left, pose: const CompanionHopPose());
    }
    if (now >= _arrival) {
      final turn = (now - _arrival) / style.turn;
      return (ground: destination, left: left, pose: _pivot(turn, turn < .5));
    }
    final beat = style.beat;
    final prepare = style.prepare, flight = style.flight;
    final current = elapsed - pivot;
    final n = (current / beat).floor().clamp(0, hops - 1);
    final phase = current - n * beat;
    if (phase < prepare) {
      final t = easeMotion(phase / prepare);
      return (
        ground: Offset.lerp(from, destination, n / hops)!,
        left: left,
        pose: CompanionHopPose(
          bracePose: facesAway || style == HopStyle.cloudHop && t > .35,
          facesAway: facesAway,
          compression: t * (style == HopStyle.cloudCat ? .075 : .135),
          lean: t * (style == HopStyle.cloudCat ? -.18 : -.40),
          earLag: .032 * t,
        ),
      );
    }
    if (phase < prepare + flight) {
      final t = (phase - prepare) / flight;
      final arc = 4 * t * (1 - t);
      final winged = style == HopStyle.cloudCat || style == HopStyle.cloudHop;
      final wing = winged ? math.sin(t * math.pi * 3) * arc : arc;
      return (
        ground: Offset.lerp(from, destination, (n + easeMotion(t)) / hops)!,
        left: left,
        pose: CompanionHopPose(
          airborne: true,
          facesAway: facesAway,
          forepawPose:
              (style == HopStyle.rabbit || style == HopStyle.cloudHop) &&
              t > .76,
          lift: peak * arc,
          compression: -.032 * arc,
          lean: .60 - .94 * t,
          earLag: wing * (winged ? .135 : .058),
        ),
      );
    }
    final t = (phase - prepare - flight) / style.land;
    final press = 1 - easeMotion(t);
    return (
      ground: Offset.lerp(from, destination, (n + 1) / hops)!,
      left: left,
      pose: CompanionHopPose(
        facesAway: facesAway,
        bracePose: facesAway,
        forepawPose:
            (style == HopStyle.rabbit || style == HopStyle.cloudHop) && t < .72,
        compression: press * .095,
        lean: press * .47,
        earLag: -.055 * pulse(t, .15, 1),
        hindLift: .065 * (1 - easeMotion((t / .55).clamp(0, 1))),
        recovery: easeMotion((t / .72).clamp(0, 1)),
      ),
    );
  }
}

CompanionHopPose? rabbitSkillRecovery(PetMotion motion) {
  if (motion.action != PetAction.skill) return null;
  final t = motion.progress;
  final landing = switch (t) {
    > .40 && < .519 => .445,
    > .774 && < .932 => .820,
    _ => null,
  };
  if (landing == null) return null;
  final recovery = easeMotion(motionWindow(t, landing, landing + .067));
  return CompanionHopPose(
    forepawPose: recovery < .99,
    compression: .08 * (1 - recovery),
    lean: .28 * (1 - recovery),
    recovery: recovery,
  );
}
