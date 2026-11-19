import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/domain/layout_rules.dart';
import 'package:alice_companions/domain/rules.dart';
import 'package:alice_companions/features/garden.dart' show gardenTheme;
import 'package:alice_companions/illustration/companion_walk.dart';
import 'package:alice_companions/illustration/living_scene.dart';
import 'package:alice_companions/illustration/puppet.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> saveActor(RenderRepaintBoundary actor, File file) async {
  final image = await actor.toImage(pixelRatio: 2);
  try {
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
    await file.writeAsBytes(bytes.buffer.asUint8List());
  } finally {
    image.dispose();
  }
}

void main() {
  testWidgets('capture a bow during a courtyard walk away from camera', (
    tester,
  ) async {
    final resources = await Future.wait([
      for (final name in ['rules', 'catalog', 'scene_slots'])
        rootBundle.loadString('assets/config/$name.json'),
    ]);
    final rules = Rules.decode(resources[0], resources[1], resources[2]);
    final room = SceneDefinition(rules, 'base_room');
    final screen = GlobalKey();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(480, 430);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final output = Directory('bow-depth-e014029');
    await tester.pumpWidget(
      MaterialApp(
        theme: gardenTheme(),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: GardenScene(
              key: screen,
              companion: Companion.fox,
              stage: 1,
              rules: rules,
              scene: room,
              outfit: const {
                'body': 'item_single_apron',
                'head': 'item_accessory_bow',
                'face': 'item_accessory_glasses',
                'neck': 'item_accessory_scarf',
              },
              immersive: true,
              showLabel: false,
              onViewChanged: (_) {},
              height: 375,
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final context = screen.currentContext!;
      await Future.wait([
        for (final path in [
          room.background,
          room.foreground,
          'assets/art/fox-1.webp',
          ...manifest.listAssets().where(
            (path) =>
                path.startsWith('assets/fox_walk/') ||
                path.contains('fitted-') && path.contains('-fox-') ||
                path.contains('worn_item_accessory_glasses') ||
                path.contains('fox-1-'),
          ),
        ])
          precacheImage(AssetImage(path), context),
      ]);
      await output.create(recursive: true);
    });
    await tester.pump();
    final actor = find.byType(IllustratedPet);
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.descendant(of: actor, matching: find.byType(RepaintBoundary)).first,
    );
    final track = StringBuffer('frame,time,stage,yaw,away,facingLeft,x,y\n');
    var backFrames = 0;
    for (var frame = 0; frame <= 122; frame++) {
      if (frame == 30) {
        await tester.tapAt(const Offset(480 * .422, 320 * .748));
      }
      await tester.pump(const Duration(milliseconds: 40));
      final pet = tester.widget<IllustratedPet>(actor);
      final pose = pet.walkPose?.call();
      final away = pose != null && math.sin(pose.yaw) < -.9;
      if (pose?.stage == WalkStage.walk && away) backFrames++;
      final anchor = tester.getCenter(actor);
      track.writeln(
        '$frame,${frame * .04},${pose?.stage.name ?? "seated"},${pose?.yaw ?? ""},'
        '$away,${pet.walkFacesLeft?.call()},${anchor.dx},${anchor.dy}',
      );
      if (frame == 24 || frame >= 32 && frame <= 103) {
        final name = frame.toString().padLeft(3, '0');
        await tester.runAsync(
          () => saveActor(boundary, File('${output.path}/$name.png')),
        );
      }
    }
    await tester.runAsync(
      () => File('${output.path}/poses.csv').writeAsString('$track'),
    );
    expect(backFrames, greaterThan(10));
    expect(tester.widget<IllustratedPet>(actor).walkPose?.call(), isNull);
    expect(tester.getCenter(actor).dx, closeTo(480 * .422, .01));
    expect(tester.takeException(), isNull);
    debugPrint(
      'Away-facing walk with bow: $backFrames walking frames, then seated',
    );
  });
}
