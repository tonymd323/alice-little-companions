import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/domain/layout_rules.dart';
import 'package:alice_companions/domain/rules.dart';
import 'package:alice_companions/features/garden.dart' show gardenTheme;
import 'package:alice_companions/illustration/living_scene.dart';
import 'package:alice_companions/illustration/puppet.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const viewWidth = 480.0, groundHeight = 320.0, pixelRatio = 2.0;
const sourceStep = int.fromEnvironment(
  'COURTYARD_REHEARSAL_STEP',
  defaultValue: 132,
);
const startFrame = 14;

void main() {
  testWidgets('record a short point-to-ground at the shipped courtyard scale', (
    tester,
  ) async {
    const output = String.fromEnvironment('COURTYARD_REHEARSAL');
    const empty = bool.fromEnvironment('COURTYARD_EMPTY_REHEARSAL');
    if (output.isEmpty) return;
    const font = '/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc';
    await tester.runAsync(() async {
      final bytes = await File(font).readAsBytes();
      await (FontLoader(
        'Courtyard Review',
      )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
      await Directory(output).create(recursive: true);
    });
    final config = await Future.wait(
      [
        'rules',
        'catalog',
        'scene_slots',
      ].map((name) => rootBundle.loadString('assets/config/$name.json')),
    );
    final rules = Rules.decode(config[0], config[1], config[2]);
    final scene = SceneDefinition(rules, 'base_room');
    final key = GlobalKey();
    final theme = gardenTheme();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(viewWidth, 430);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: theme.copyWith(
          textTheme: theme.textTheme.apply(fontFamily: 'Courtyard Review'),
        ),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: RepaintBoundary(
              key: key,
              child: GardenScene(
                companion: Companion.cat,
                stage: 1,
                rules: rules,
                scene: scene,
                immersive: true,
                showLabel: false,
                onViewChanged: (_) {},
                height: groundHeight + 55,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final context = key.currentContext!;
      if (!context.mounted) throw StateError('Courtyard closed');
      for (final asset in [
        scene.background,
        scene.foreground,
        'assets/art/cat-1.webp',
        'assets/art/leap-cat-1.webp',
        ...manifest.listAssets().where(
          (path) => path.startsWith('assets/cat_walk/'),
        ),
      ]) {
        await precacheImage(AssetImage(asset), context);
      }
    });
    await tester.pump();
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(key),
    );
    final actor = find.byKey(const ValueKey('home-companion'));
    final start = const Offset(viewWidth * .47, groundHeight * .895);
    const scale = groundHeight * .343 / 440;
    final target = start + const Offset(sourceStep * scale, 0);
    final positions = <Map<String, Object?>>[];
    for (var frame = 0; frame < 104; frame++) {
      if (frame == startFrame && !empty) {
        await tester.tapAt(target);
      }
      await tester.pump(const Duration(milliseconds: 40));
      if (!empty) {
        final current = tester.widget<IllustratedPet>(
          find.byType(IllustratedPet),
        );
        final pose = current.walkPose?.call();
        positions.add({
          'frame': frame,
          'x': tester.getCenter(actor).dx,
          'stage': pose?.stage.name,
          'ink': pose?.ink,
        });
      }
      final label = frame.toString().padLeft(3, '0');
      await tester.runAsync(() async {
        final picture = await boundary.toImage(pixelRatio: pixelRatio);
        try {
          final png = (await picture.toByteData(
            format: ui.ImageByteFormat.png,
          ))!;
          await File('$output/court-$label.png')
              .writeAsBytes(png.buffer.asUint8List());
        } finally {
          picture.dispose();
        }
      });
    }
    if (!empty) expect(tester.getCenter(actor).dx, closeTo(target.dx, .02));
    await tester.runAsync(
      () => File('$output/take.json').writeAsString(
        jsonEncode({
          'start_frame': startFrame,
          'fps': 25,
          'screen_start': [start.dx * pixelRatio, start.dy * pixelRatio],
          'screen_target': [target.dx * pixelRatio, target.dy * pixelRatio],
          'raw_scale': scale * pixelRatio,
          'positions': positions,
        }),
      ),
    );
  });
}
