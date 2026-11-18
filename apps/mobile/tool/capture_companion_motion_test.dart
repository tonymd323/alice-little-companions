// Run from apps/mobile with flutter test tool/capture_companion_motion_test.dart
// --dart-define=ALICE_MOTION_FRAMES=/absolute/path/to/an/existing/directory
// --dart-define=ALICE_CJK_FONT=/absolute/path/to/a/Chinese/font.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/features/garden.dart' show gardenTheme;
import 'package:alice_companions/illustration/action_poses.dart';
import 'package:alice_companions/illustration/companion_motion.dart';
import 'package:alice_companions/illustration/living_scene.dart';
import 'package:alice_companions/illustration/tailoring.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show ByteData, FontLoader, rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'record the production scene at fixed time steps for visual review',
    (tester) async {
      const target = String.fromEnvironment('ALICE_MOTION_FRAMES');
      if (target.isEmpty) return;
      const font = String.fromEnvironment('ALICE_CJK_FONT');
      const family = 'Garden Review';
      await tester.runAsync(() async {
        final bytes = await File(font).readAsBytes();
        final loader = FontLoader(family)
          ..addFont(Future.value(ByteData.sublistView(bytes)));
        final icons = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await Future.wait([loader.load(), icons.load()]);
      });
      final theme = gardenTheme();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(448, 430);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = GlobalKey();
      var sequence = 0;
      for (final pet in Companion.values) {
        final stage = switch (pet) {
          Companion.fox => 1,
          Companion.rabbit => 2,
          Companion.cat => 4,
        };
        final indoor = pet == Companion.rabbit;
        final outfit = <String, String>{
          if (pet == Companion.rabbit) 'neck': 'item_accessory_scarf',
          if (pet == Companion.cat) 'head': 'item_accessory_bow',
        };
        await tester.pumpWidget(
          MaterialApp(
            theme: theme.copyWith(
              textTheme: theme.textTheme.apply(fontFamily: family),
            ),
            home: Scaffold(
              body: Align(
                alignment: Alignment.topCenter,
                child: RepaintBoundary(
                  key: container,
                  child: GardenScene(
                    key: ValueKey(pet),
                    companion: pet,
                    stage: stage,
                    playable: true,
                    height: 353,
                    label: '${pet.label} · ${pet.nickname}',
                    view: indoor ? HomeView.veranda : HomeView.courtyard,
                    windowsLit: indoor,
                    outfit: outfit,
                  ),
                ),
              ),
            ),
          ),
        );
        final ctx = container.currentContext!;
        await tester.runAsync(
          () => Future.wait([
            for (final path in [
              pet.artwork(stage),
              actionArtwork(pet, stage, null),
              'assets/art/${indoor ? 'veranda' : 'garden'}.webp',
              for (final asset in outfit.values) ...[
                fittedAccessory(asset, pet),
                fittedAccessory(asset, pet, airborne: true),
              ],
            ])
              precacheImage(AssetImage(path), ctx),
          ]),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 80));
        for (var i = 0; i < 65; i++) {
          if (i == 8) await tester.tap(find.text(pet.skillName));
          await tester.pump(const Duration(milliseconds: 67));
          final render =
              container.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final frame = await render.toImage(pixelRatio: 1.5);
            final data = await frame.toByteData(format: ui.ImageByteFormat.png);
            final no = (sequence++).toString().padLeft(3, '0');
            await File('$target/frame-$no.png')
                .writeAsBytes(data!.buffer.asUint8List());
            frame.dispose();
          });
        }
      }
      expect(sequence, 195);
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
