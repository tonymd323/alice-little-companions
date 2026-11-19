import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:alice_companions/illustration/animated_backdrop.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the wooden stair stays still while the courtyard leaves sway', (
    tester,
  ) async {
    const width = 768, height = 512;
    const art = AssetImage('assets/art/garden.webp');
    final clock = ValueNotifier(0.0);
    addTearDown(clock.dispose);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(768, 512);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: AnimatedBackdrop(
          asset: art.assetName,
          place: 'courtyard',
          clock: clock,
          seconds: () => clock.value,
        ),
      ),
    );
    final context = key.currentContext!;
    await tester.runAsync(() => precacheImage(art, context));
    await tester.pump();
    final boundary = context.findRenderObject()! as RenderRepaintBoundary;
    Future<Uint32List> pixels() async {
      final result = await tester.runAsync(() async {
        final image = await boundary.toImage();
        try {
          final data = (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!;
          return data.buffer.asUint32List(data.offsetInBytes, width * height);
        } finally {
          image.dispose();
        }
      });
      return result!;
    }

    final first = await pixels();
    int changed(Uint32List next, Rect area) {
      var count = 0;
      for (var y = area.top.toInt(); y < area.bottom; y++) {
        for (var x = area.left.toInt(); x < area.right; x++) {
          final i = y * width + x;
          if (first[i] != next[i]) count++;
        }
      }
      return count;
    }

    for (final time in [.63, 1.57, 2.98, 4.37]) {
      clock.value = time;
      await tester.pump();
      final next = await pixels();
      // Whole staircase, including both stringers and the foot on the grass.
      expect(
        changed(next, const Rect.fromLTRB(79, 246, 202, 363)),
        0,
        reason: 'wood at $time s',
      );
      expect(
        changed(next, const Rect.fromLTRB(360, 25, 535, 80)),
        greaterThan(100),
        reason: 'overhead canopy at $time s',
      );
      expect(
        changed(next, const Rect.fromLTRB(102, 191, 128, 212)),
        greaterThan(20),
        reason: 'leaves above the stairs at $time s',
      );
    }
  });
}
