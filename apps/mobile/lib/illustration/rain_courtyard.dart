import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The two painted planes of the playable courtyard after the rain chapter.
class RainCourtyardArt extends StatelessWidget {
  const RainCourtyardArt({
    super.key,
    required this.clock,
    required this.seconds,
    required this.still,
    this.foreground = false,
  });

  final Listenable clock;
  final double Function() seconds;
  final bool still;
  final bool foreground;

  static const _canvas = Size(1536, 1024);
  static const _branch = Rect.fromLTWH(747, 207, 190, 140);
  static const _ladder = Rect.fromLTWH(211, 478, 102, 79);
  static const _wood = Rect.fromLTWH(162, 457, 497, 278);
  static const _water = Rect.fromLTWH(1285, 822, 220, 45);
  static const _flowers = Rect.fromLTWH(0, 802, 365, 218);
  static const _bank = Rect.fromLTWH(1310, 872, 226, 152);
  static const _cycle = 5.0;

  double get _phase => seconds() % _cycle * (2 * math.pi / _cycle);

  Widget _image(String part) => Image.asset(
    'assets/art/rain-courtyard-$part.webp',
    key: ValueKey('rain-courtyard-$part'),
    fit: BoxFit.fill,
    excludeFromSemantics: true,
    filterQuality: FilterQuality.medium,
  );

  Widget _place(Size world, Rect frame, Widget child) => Positioned.fromRect(
    rect: Rect.fromLTRB(
      frame.left / _canvas.width * world.width,
      frame.top / _canvas.height * world.height,
      frame.right / _canvas.width * world.width,
      frame.bottom / _canvas.height * world.height,
    ),
    child: child,
  );

  Widget _sway(
    Size world,
    Rect frame,
    String part,
    Offset pivot,
    double amplitude,
    double delay,
  ) {
    final art = _image(part);
    return _place(
      world,
      frame,
      still
          ? art
          : AnimatedBuilder(
              animation: clock,
              child: art,
              builder: (context, child) => Transform.rotate(
                alignment: Alignment(
                  2 * pivot.dx / frame.width - 1,
                  2 * pivot.dy / frame.height - 1,
                ),
                angle:
                    amplitude *
                    (math.sin(_phase + delay) + .2 * math.sin(2 * _phase)),
                child: child,
              ),
            ),
    );
  }

  Widget _ripples(Size world) {
    final art = _image('water-ripples');
    return _place(
      world,
      _water,
      still
          ? art
          : AnimatedBuilder(
              animation: clock,
              child: art,
              builder: (context, child) {
                final phase = _phase;
                return Transform.translate(
                  offset: Offset(
                    4 * math.sin(phase) * world.width / _canvas.width,
                    1.5 * math.sin(2 * phase) * world.height / _canvas.height,
                  ),
                  child: Opacity(
                    opacity: .73 + .22 * math.sin(phase + math.pi / 3),
                    child: child,
                  ),
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final world = constraints.biggest;
        return Stack(
          fit: StackFit.expand,
          children: foreground
              ? [
                  _sway(
                    world,
                    _flowers,
                    'foreground-botanicals',
                    const Offset(180, 211),
                    .012,
                    2,
                  ),
                  _place(world, _bank, _image('rocky-bank')),
                ]
              : [
                  _image('base'),
                  _sway(
                    world,
                    _branch,
                    'canopy-branchlet',
                    const Offset(2, 2),
                    .039,
                    0,
                  ),
                  _sway(
                    world,
                    _ladder,
                    'ladder-leaves',
                    const Offset(28, 73),
                    .029,
                    1.2,
                  ),
                  _place(world, _wood, _image('wood')),
                  _ripples(world),
                ],
        );
      },
    ),
  );
}
