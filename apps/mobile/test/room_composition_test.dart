import 'dart:io';
import 'dart:ui' as ui;

import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/domain/layout_rules.dart' show SceneDefinition, freeFurnishings;
import 'package:alice_companions/domain/rules.dart';
import 'package:alice_companions/features/storybook.dart';
import 'package:alice_companions/illustration/living_scene.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final rules = Rules.decode(
    File('assets/config/rules.json').readAsStringSync(),
    File('assets/config/catalog.json').readAsStringSync(),
    File('assets/config/scene_slots.json').readAsStringSync(),
  );
  final portable = rules.catalog.values
      .where((p) => p['space_id'] == null && p['slot'] == null)
      .toList();
  final free = [
    for (final i in freeFurnishings.entries) ScenePiece(i.key, i.value),
  ];
  testWidgets(
    'every decoration, furniture purchase and room is composed inside the complete painted canvas on a phone and tablet',
    (tester) async {
      const captures = String.fromEnvironment('ALICE_ROOM_EVIDENCE');
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final boundary = GlobalKey();
      Future<void> render(
        String id,
        String room,
        List<ScenePiece> pieces,
        double width,
      ) async {
        final height = width * 2 / 3;
        tester.view.physicalSize = Size(width, height + 125);
        final painting = RoomPainting(room, pieces);
        final places = pieces.map((p) => p.name).toSet();
        expect(
          painting.layers.every(
            (l) =>
                (const Rect.fromLTWH(0, 0, 1, 1)).contains(l.frame.topLeft) &&
                (const Rect.fromLTWH(0, 0, 1, 1)).contains(l.frame.bottomRight),
          ),
          isTrue,
          reason: '$id at $width',
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topCenter,
                child: MediaQuery(
                  data: const MediaQueryData(disableAnimations: true),
                  child: RepaintBoundary(
                    key: boundary,
                    child: GardenScene(
                      companion: Companion.rabbit,
                      stage: 2,
                      view: HomeView.veranda,
                      scene: SceneDefinition(rules, room),
                      pieces: pieces,
                      showLabel: false,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        final ctx = boundary.currentContext!;
        final assets = [
          painting.background ??
              (room == 'base_room'
                  ? 'assets/art/veranda.webp'
                  : SceneDefinition(rules, room).background),
          ...painting.layers.map((l) => l.art),
          Companion.rabbit.artwork(2),
        ];
        await tester.runAsync(
          () => Future.wait([
            for (final a in assets) precacheImage(AssetImage(a), ctx),
          ]),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 45));
        expect(tester.getSize(find.byKey(boundary)).height, closeTo(height, 1));
        for (final layer in painting.layers) {
          expect(
            find.bySemanticsLabel(layer.name),
            findsWidgets,
            reason: '$id: ${layer.name}',
          );
        }
        if (room == 'base_room') expect(places, contains('编织小毯'));
        if (captures.isNotEmpty) {
          final render =
              boundary.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final bitmap = await render.toImage(
              pixelRatio: width < 450 ? 2 : 1,
            );
            final data = await bitmap.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File('$captures/$id-${width.toInt()}.png')
                .writeAsBytes(data!.buffer.asUint8List());
            bitmap.dispose();
          });
        }
      }

      for (final width in [360.0, 768.0]) {
        for (final product in portable) {
          await render(product['id'] as String, 'base_room', [
            ...free,
            ...ScenePiece.preview(product),
          ], width);
        }
        final complete = [
          for (final product in portable) ...ScenePiece.preview(product),
        ];
        await render('home-all', 'base_room', [...free, ...complete], width);
        for (final room in furnishedRooms.keys) {
          final built = ScenePiece.preview(rules.catalog[room]!);
          await render(room, room, built, width);
          await render('$room-all', room, [...built, ...complete], width);
        }
      }
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );
  testWidgets(
    'the garden story and each companion biography can be read offline at large text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 700);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        MaterialApp(
          builder: (c, v) => MediaQuery(
            data: MediaQuery.of(c)
                .copyWith(textScaler: const TextScaler.linear(1.3)),
            child: v!,
          ),
          home: GardenStorybook(
            stages: {for (final pet in Companion.values) pet: 4},
          ),
        ),
      );
      expect(find.text('桥头的一片叶'), findsOneWidget);
      for (final pet in Companion.values) {
        await tester.tap(find.text(pet.nickname));
        await tester.pump();
        expect(find.text(pet.label), findsOneWidget);
        expect(find.text('第 4 阶段 · 暖暖陪伴'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
