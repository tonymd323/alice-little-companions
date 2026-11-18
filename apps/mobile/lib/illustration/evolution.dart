import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../domain/companions.dart';
import 'companion_motion.dart';
import 'puppet.dart';
import 'tailoring.dart';

Future<void> showEvolution(
  BuildContext context,
  Companion pet,
  int from,
  int to, {
  Map<String, String> outfit = const {},
  bool preview = false,
  String? receipt,
}) => showDialog<void>(
  context: context,
  builder: (context) => Dialog(
    clipBehavior: Clip.antiAlias,
    backgroundColor: const Color(0xfffff8e8),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 490),
      child: EvolutionMoment(
        pet: pet,
        from: from,
        to: to,
        outfit: outfit,
        preview: preview,
        receipt: receipt,
      ),
    ),
  ),
);

class EvolutionMoment extends StatefulWidget {
  const EvolutionMoment({
    super.key,
    required this.pet,
    required this.from,
    required this.to,
    required this.outfit,
    this.preview = false,
    this.receipt,
  });
  final Companion pet;
  final int from, to;
  final Map<String, String> outfit;
  final bool preview;
  final String? receipt;
  @override
  State<EvolutionMoment> createState() => _EvolutionMomentState();
}

class _EvolutionMomentState extends State<EvolutionMoment>
    with SingleTickerProviderStateMixin {
  late final AnimationController film = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: widget.preview ? 3200 : 1600),
  );
  bool loading = false, quiet = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    quiet =
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context);
    if (quiet) {
      film.value = 1;
      return;
    }
    if (!loading && film.value < 1) {
      loading = true;
      _start();
    }
  }

  Future<void> _start() async {
    await Future.wait([
      for (final stage in [widget.from, widget.to])
        precacheImage(
          AssetImage(
            portraitArtwork(widget.pet, stage, true, widget.outfit['body']),
          ),
          context,
        ),
    ]);
    if (mounted && !quiet && film.value < 1) film.forward();
  }

  @override
  void dispose() {
    film.dispose();
    super.dispose();
  }

  Widget actor(int stage) => IllustratedPet(
    pet: widget.pet,
    stage: stage,
    reveal: true,
    outfit: widget.outfit,
    clock: film,
    seconds: () => film.value * (widget.preview ? 3.2 : 1.6),
    reaction: () => 1,
    walking: () => 0,
    gaze: () => 0,
    still: quiet,
  );
  @override
  Widget build(BuildContext context) {
    final young = actor(widget.from), grown = actor(widget.to);
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: film,
              builder: (context, _) {
                final t = film.value;
                final change = easeMotion(motionWindow(t, .43, .62)),
                    shine = pulse(t, .18, .83);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.65,
                      child: LayoutBuilder(
                        builder: (context, box) {
                          final side = box.maxHeight * .76;
                          final center = Offset(
                            box.maxWidth * .5,
                            box.maxHeight * .86,
                          );
                          final frame = Rect.fromLTWH(
                            center.dx - side / 2,
                            center.dy - side,
                            side,
                            side,
                          );
                          return Semantics(
                            image: true,
                            label:
                                '${widget.pet.label}第 ${t < .54 ? widget.from : widget.to} 阶段',
                            child: Stack(
                              fit: StackFit.expand,
                              clipBehavior: Clip.hardEdge,
                              children: [
                                Image.asset(
                                  'assets/art/garden.webp',
                                  fit: BoxFit.cover,
                                  excludeFromSemantics: true,
                                ),
                                ColoredBox(
                                  color: Color.fromRGBO(
                                    58,
                                    40,
                                    43,
                                    .16 * shine,
                                  ),
                                ),
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _EvolutionLight(widget.pet, t),
                                  ),
                                ),
                                Positioned.fromRect(
                                  rect: frame,
                                  child: Opacity(
                                    opacity: 1 - change,
                                    child: Transform.scale(
                                      scale: 1 - .1 * shine,
                                      alignment: Alignment.bottomCenter,
                                      child: young,
                                    ),
                                  ),
                                ),
                                Positioned.fromRect(
                                  rect: frame,
                                  child: Opacity(
                                    opacity: change,
                                    child: Transform.scale(
                                      scale:
                                          .84 +
                                          .16 *
                                              easeMotion(
                                                motionWindow(t, .46, .84),
                                              ) +
                                          .045 * pulse(t, .58, .88),
                                      alignment: Alignment.bottomCenter,
                                      child: grown,
                                    ),
                                  ),
                                ),
                                if (t < 1)
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _EvolutionPetals(widget.pet, t),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 16, 15, 0),
                      child: Text(
                        widget.preview ? '进化预演' : '${widget.pet.nickname}长大了',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Text(
                        '${stageNames[widget.from - 1]}  →  ${stageNames[widget.to - 1]}',
                      ),
                    ),
                    if (widget.receipt case final message?)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(message, textAlign: TextAlign.center),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextButton(
                        onPressed: () {
                          if (film.value < 1) {
                            film.value = 1;
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Text(t < 1 ? '跳过动画' : '完成'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EvolutionLight extends CustomPainter {
  const _EvolutionLight(this.pet, this.t);
  final Companion pet;
  final double t;
  @override
  void paint(Canvas c, Size s) {
    final k = pulse(t, .04, .98);
    if (k <= .001) return;
    final center = Offset(s.width * .5, s.height * .57);
    final r = s.height * (.21 + .54 * k);
    final area = Rect.fromCircle(center: center, radius: r);
    final hue = switch (pet) {
      Companion.fox => const Color(0xffffcf6c),
      Companion.rabbit => const Color(0xffdfd7ff),
      Companion.cat => const Color(0xffbcf0ff),
    };
    c.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xfffff3ca).withValues(alpha: .83 * k),
            hue.withValues(alpha: .52 * k),
            hue.withValues(alpha: 0),
          ],
          stops: const [0, .4, 1],
        ).createShader(area),
    );
    for (var i = 0; i < 3; i++) {
      final f = (t * 1.8 + i / 3) % 1;
      c.drawOval(
        Rect.fromCenter(
          center: Offset(s.width * .5, s.height * .87),
          width: s.width * (.15 + .61 * f),
          height: s.height * (.035 + .12 * f),
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = hue.withValues(alpha: k * (1 - f) * .92),
      );
    }
  }

  @override
  bool shouldRepaint(_EvolutionLight old) => old.t != t || old.pet != pet;
}

class _EvolutionPetals extends CustomPainter {
  const _EvolutionPetals(this.pet, this.t);
  final Companion pet;
  final double t;
  @override
  void paint(Canvas c, Size s) {
    final k = pulse(t, .02, .99),
        spread = easeMotion(motionWindow(t, .43, .96));
    if (k <= .001) return;
    for (var i = 0; i < 24; i++) {
      final depth = i % 3 / 3, a = i * 2.39996 + t * (i.isEven ? 3.9 : -2.3);
      final r = s.height * (.20 + .22 * depth + .42 * spread);
      final p = Offset(
        s.width * .5 + math.cos(a) * r * 1.18,
        s.height * .53 + math.sin(a) * r * .86,
      );
      if (i % 3 != 0) {
        CompanionEffects.spark(
          c,
          p,
          (2.4 + 4 * depth) * k,
          const Color(0xffffefb1).withValues(alpha: k),
        );
        continue;
      }
      final size = s.height * (.028 + depth * .014) * k;
      switch (pet) {
        case Companion.fox:
          CompanionEffects.ginkgo(
            c,
            p,
            size,
            a,
            const Color(0xffffce62).withValues(alpha: k),
          );
        case Companion.rabbit:
          CompanionEffects.moon(c, p, size, a * .19, k);
        case Companion.cat:
          CompanionEffects.wisp(c, p, size, a * .14, k);
      }
    }
  }

  @override
  bool shouldRepaint(_EvolutionPetals old) => old.t != t || old.pet != pet;
}
