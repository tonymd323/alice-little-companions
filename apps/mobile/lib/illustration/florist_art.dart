import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../domain/layout_rules.dart' show contains;

abstract final class FloristRack {
  static const art = 'assets/art/florist-drying-rack.webp';
  static const shadow = 'assets/art/florist-drying-rack-shadow.webp';
  static const frame = Rect.fromLTRB(
    1020 / 1536,
    656 / 1024,
    1448 / 1536,
    968 / 1024,
  );
  static const depth = 949 / 1024;
  static const footprint = [
    (1055 / 1536, 908 / 1024),
    (1336 / 1536, 878 / 1024),
    (1409 / 1536, 919 / 1024),
    (1119 / 1536, 949 / 1024),
  ];

  static double _cross(Offset a, Offset b) => a.dx * b.dy - a.dy * b.dx;

  static bool blocksWalk(Offset from, Offset to) {
    if (contains(footprint, to.dx, to.dy)) return true;
    if (contains(footprint, from.dx, from.dy)) return false;
    final direction = to - from;
    for (var i = 0; i < footprint.length; i++) {
      final (x, y) = footprint[i];
      final (nextX, nextY) = footprint[(i + 1) % footprint.length];
      final edge = Offset(nextX - x, nextY - y);
      final divisor = _cross(direction, edge);
      if (divisor.abs() < 1e-9) continue;
      final origin = Offset(x, y) - from;
      final stepFraction = _cross(origin, edge) / divisor;
      final edgeFraction = _cross(origin, direction) / divisor;
      if (stepFraction > 0 &&
          stepFraction <= 1 &&
          edgeFraction >= 0 &&
          edgeFraction <= 1) {
        return true;
      }
    }
    return false;
  }
}

/// The wide and close paintings share the same six flowers, ordered by depth.
class FloristTray extends StatelessWidget {
  const FloristTray({super.key, required this.flowers, this.inRoom = false});

  static const roomBackground = 'assets/art/florist-room.webp';
  // The wide sprite group shares the SC-03 scene camera.
  static const roomFrame = Rect.fromLTRB(
    192 / 1536,
    356 / 1024,
    864 / 1536,
    540 / 1024,
  );
  static const trayCenter = Offset(594 / 1536, 477 / 1024);
  static const closeAspectRatio = 792 / 351;
  static const holeCount = 6;

  final ValueListenable<Set<int>> flowers;
  final bool inRoom;

  @override
  Widget build(BuildContext context) {
    final view = inRoom ? 'shop' : 'close';
    Widget layer(String name) => Image.asset(
      'assets/art/florist-$view-$name.webp',
      key: ValueKey('florist-$view-$name'),
      fit: BoxFit.fill,
      filterQuality: FilterQuality.medium,
      excludeFromSemantics: true,
    );

    return IgnorePointer(
      child: ValueListenableBuilder(
        valueListenable: flowers,
        builder: (context, filled, _) => Stack(
          fit: StackFit.expand,
          children: [
            layer('tray'),
            for (var hole = 0; hole < holeCount; hole++)
              if (filled.contains(hole)) layer('flower-${hole + 1}'),
            layer('rim'),
          ],
        ),
      ),
    );
  }
}
