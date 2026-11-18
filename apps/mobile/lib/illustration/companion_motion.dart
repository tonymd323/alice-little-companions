import 'dart:math' as math;
import 'dart:ui';

import '../domain/companions.dart';

enum PetAction { rest, look, stretch, nuzzle, skill }

extension CompanionSkill on Companion {
  String get skillName => switch (this) {
    Companion.fox => '银杏叶舞',
    Companion.rabbit => '月牙连跳',
    Companion.cat => '踏云追风',
  };
}

/// Time windows with stationary endpoints, shared by the body and its effect.
double motionWindow(double t, double from, double to) =>
    ((t - from) / (to - from)).clamp(0.0, 1.0);
double easeMotion(double x) => x * x * (3 - 2 * x);
double pulse(double t, double from, double to) =>
    math.sin(math.pi * motionWindow(t, from, to));

class PetMotion {
  const PetMotion(this.action, this.progress);
  const PetMotion.rest() : this(PetAction.rest, 1);
  final PetAction action;
  final double progress;

  double get curl => switch (action) {
    PetAction.nuzzle => pulse(progress, 0, 1) * .95,
    PetAction.stretch => pulse(progress, 0, 1) * .78,
    PetAction.skill =>
      pulse(progress, 0, .26) -
          .35 * pulse(progress, .28, .72) +
          .5 * pulse(progress, .74, .97),
    _ => 0,
  };
  double get lean => switch (action) {
    PetAction.look => math.sin(progress * math.pi * 2) * pulse(progress, 0, 1),
    PetAction.nuzzle =>
      math.sin(progress * math.pi * 3) * pulse(progress, 0, 1),
    PetAction.stretch => -pulse(progress, 0, 1),
    _ => 0,
  };
  double get keyPose => action == PetAction.skill
      ? easeMotion(motionWindow(progress, .225, .34)) *
            (1 - easeMotion(motionWindow(progress, .69, .83)))
      : 0;
  double height(Companion pet) {
    if (action != PetAction.skill) return 0;
    return switch (pet) {
      Companion.rabbit =>
        .42 * pulse(progress, .20, .56) + .24 * pulse(progress, .56, .86),
      Companion.cat => .42 * pulse(progress, .20, .85),
      Companion.fox => .28 * pulse(progress, .21, .80),
    };
  }

  double travel(Companion pet) => action == PetAction.skill
      ? (pet == Companion.fox ? .26 : .15) * pulse(progress, .20, .84)
      : 0;
}

class CompanionEffects {
  static const _gold = Color(0xFFE6AC31),
      _cream = Color(0xFFFFF2B8),
      _lilac = Color(0xFF9581D3),
      _moon = Color(0xFFFFEDB4),
      _blue = Color(0xFF80BCD6),
      _cloud = Color(0xFFE7F6F9);
  static final leaf = Path()
    ..moveTo(0, 6)
    ..cubicTo(-3, 1, -13, 0, -11, -6)
    ..quadraticBezierTo(-8, -12, -1, -8)
    ..lineTo(0, -5)
    ..quadraticBezierTo(5, -13, 10, -8)
    ..cubicTo(15, -1, 5, 1, 0, 6)
    ..close();
  static final crescent = Path()
    ..moveTo(-7, -11)
    ..cubicTo(-11, 8, 4, 13, 12, 3)
    ..cubicTo(6, 18, -15, 14, -13, -1)
    ..quadraticBezierTo(-13, -7, -7, -11)
    ..close();

  static void spark(Canvas c, Offset p, double size, Color color) {
    final star = Path()
      ..moveTo(p.dx, p.dy - size)
      ..quadraticBezierTo(
        p.dx + size * .12,
        p.dy - size * .12,
        p.dx + size * .69,
        p.dy,
      )
      ..quadraticBezierTo(
        p.dx + size * .12,
        p.dy + size * .12,
        p.dx,
        p.dy + size,
      )
      ..quadraticBezierTo(
        p.dx - size * .12,
        p.dy + size * .12,
        p.dx - size * .69,
        p.dy,
      )
      ..quadraticBezierTo(
        p.dx - size * .12,
        p.dy - size * .12,
        p.dx,
        p.dy - size,
      );
    c.drawPath(star, Paint()..color = color);
  }

  static void ginkgo(
    Canvas c,
    Offset p,
    double radius,
    double angle,
    Color color,
  ) {
    c.save();
    c.translate(p.dx, p.dy);
    c.rotate(angle);
    c.scale(radius / 12);
    c.drawPath(leaf, Paint()..color = color);
    final pen = Paint()
      ..color = _cream.withValues(alpha: color.a * .8)
      ..strokeWidth = .8
      ..strokeCap = StrokeCap.round;
    for (final x in [-7.0, -3.0, 4.0, 8.0]) {
      c.drawLine(const Offset(0, 5), Offset(x, -6), pen);
    }
    c.drawLine(const Offset(0, 4), const Offset(1.4, 9), pen);
    c.restore();
  }

  static void moon(
    Canvas c,
    Offset p,
    double radius,
    double angle,
    double opacity,
  ) {
    c.save();
    c.translate(p.dx, p.dy);
    c.rotate(angle);
    c.scale(radius / 12);
    c.drawPath(crescent, Paint()..color = _moon.withValues(alpha: opacity));
    c.drawPath(
      crescent,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .95
        ..color = _lilac.withValues(alpha: opacity * .9),
    );
    c.restore();
  }

  static void wisp(
    Canvas c,
    Offset p,
    double radius,
    double angle,
    double opacity,
  ) {
    c.save();
    c.translate(p.dx, p.dy);
    c.rotate(angle);
    c.scale(radius / 14);
    final w = Path()
      ..moveTo(-20, 4)
      ..quadraticBezierTo(-9, 5, -7, -1)
      ..cubicTo(-7, -10, 4, -11, 7, -5)
      ..cubicTo(15, -9, 20, 3, 11, 5)
      ..cubicTo(7, 7, 1, 4, 5, 1)
      ..cubicTo(1, 6, -4, 10, -20, 4)
      ..close();
    c.drawPath(w, Paint()..color = _cloud.withValues(alpha: opacity));
    c.drawPath(
      w,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.05
        ..color = _blue.withValues(alpha: .9 * opacity),
    );
    c.restore();
  }

  static void skill(
    Canvas c,
    Companion pet,
    Offset foot,
    double side,
    double t, {
    required bool front,
    required bool left,
  }) {
    if (t <= 0 || t >= 1) return;
    final fade = pulse(t, 0, 1);
    c.save();
    c.translate(foot.dx, foot.dy);
    c.scale(left ? -side / 180 : side / 180, side / 180);
    final main = switch (pet) {
      Companion.fox => _gold,
      Companion.rabbit => _lilac,
      Companion.cat => _blue,
    };
    if (!front) {
      final r = Rect.fromCenter(
        center: const Offset(0, -7),
        width: 144 + 60 * t,
        height: 24 + 10 * t,
      );
      final halo = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7
        ..color = main.withValues(alpha: .67 * fade);
      c.drawOval(r, halo);
      final arc = Path();
      for (var j = 0; j <= 40; j++) {
        final f = j / 40, a = t * math.pi * 2.4 + f * 4.7;
        final p = Offset(
          math.cos(a) * (63 + 24 * f),
          -23 - 113 * f + 13 * math.sin(a),
        );
        if (j == 0) {
          arc.moveTo(p.dx, p.dy);
        } else {
          arc.lineTo(p.dx, p.dy);
        }
      }
      c.drawPath(
        arc,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 3
          ..color = main.withValues(alpha: .48 * fade),
      );
    }
    for (var i = 0; i < 14; i++) {
      final f = motionWindow(t, (i % 5) * .029, .72 + (i % 4) * .08);
      if (f <= 0 || f >= 1) continue;
      final a = i * 2.399 + f * (pet == Companion.fox ? 4.8 : 2.6);
      if ((math.sin(a) > 0) != front) continue;
      final strength = math.sin(math.pi * f);
      final p = Offset(
        math.cos(a) * (32 + 70 * f) + 15 * f,
        -15 - f * (110 + i % 4 * 12) + math.sin(a) * 14,
      );
      switch (pet) {
        case Companion.fox:
          ginkgo(
            c,
            p,
            (5 + i % 4 * 2) * strength,
            t * 4 + i,
            Color.lerp(_gold, _cream, i % 3 / 3)!.withValues(alpha: strength),
          );
        case Companion.rabbit:
          moon(c, p, (5 + i % 4 * 1.7) * strength, -.65 + f, strength);
        case Companion.cat:
          wisp(
            c,
            p,
            (6 + i % 4 * 2) * strength,
            -.2 + math.sin(a) * .27,
            strength,
          );
      }
      spark(
        c,
        p + const Offset(5, -9),
        3.4 * strength,
        _cream.withValues(alpha: strength),
      );
    }
    c.restore();
  }
}
