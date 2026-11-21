import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:alice_companions/application/controller.dart';
import 'package:alice_companions/application/family.dart';
import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/illustration/accessory_poses.dart';
import 'package:alice_companions/illustration/action_poses.dart';
import 'package:alice_companions/illustration/animated_backdrop.dart';
import 'package:alice_companions/illustration/companion_motion.dart';
import 'package:alice_companions/illustration/companion_walk.dart';
import 'package:alice_companions/illustration/companion_walk_art.dart';
import 'package:alice_companions/illustration/living_scene.dart';
import 'package:alice_companions/illustration/puppet.dart';
import 'package:alice_companions/illustration/tailoring.dart';
import 'package:alice_companions/main.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/families.dart';

const _frames = String.fromEnvironment('ALICE_POSE_ACCESSORY_FRAMES');

Future<void> _waitFor(WidgetTester tester, Finder widget) async {
  for (var attempt = 0; attempt < 50 && !tester.any(widget); attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 48));
  }
  expect(widget, findsOneWidget);
}

Future<List<int>> _actorFrame(WidgetTester tester, String name) async {
  final finder = find.descendant(
    of: find.byType(IllustratedPet),
    matching: find.byType(RepaintBoundary),
  );
  await _waitFor(tester, finder);
  return _frame(tester, finder, name, pixelRatio: 2);
}

Future<List<int>> _frame(
  WidgetTester tester,
  Finder finder,
  String name, {
  double pixelRatio = 1,
}) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(finder);
  return (await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    try {
      if (_frames.isNotEmpty) {
        final data = (await image.toByteData(format: ui.ImageByteFormat.png))!;
        await Directory(_frames).create(recursive: true);
        await File('$_frames/$name.png').writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
      }
      final data = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } finally {
      image.dispose();
    }
  }))!;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final config = jsonDecode(
    File('../../design/asset_manifest.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  test(
    'each fitted plate uses the exact runtime size and a bundled file',
    () async {
      final bundle = await AssetManifest.loadFromAssetBundle(rootBundle);
      final assets = bundle.listAssets().toSet();
      final group = config['pose_accessories'] as Map<String, dynamic>;
      final rows = (group['assets'] as List).cast<Map<String, dynamic>>();
      final expected = <String>{};
      for (final (pet, item) in [
        (Companion.fox, 'item_accessory_bow'),
        (Companion.cat, 'item_accessory_glasses'),
        (Companion.rabbit, 'item_accessory_scarf'),
      ]) {
        for (final body in [null, 'item_single_coat', 'item_single_apron']) {
          for (final pose in AccessoryPose.values) {
            final path = registeredAccessory(item, pet, 1, pose, body);
            if (path != null) expected.add(path);
            expect(registeredAccessory(item, pet, 2, pose, body), isNull);
          }
        }
      }
      expect(expected, hasLength(31));
      for (final record in rows) {
        final path = (record['runtime_path'] as String).substring(
          'apps/mobile/'.length,
        );
        final original = ((record['pose'] as Map)['path'] as String).substring(
          'apps/mobile/'.length,
        );
        expect(expected.remove(path), isTrue, reason: path);
        expect(assets, containsAll([path, original]));
        final layer = await ui.instantiateImageCodec(
          await File(path).readAsBytes(),
        );
        final body = await ui.instantiateImageCodec(
          await File(original).readAsBytes(),
        );
        try {
          final attachment = (await layer.getNextFrame()).image;
          final character = (await body.getNextFrame()).image;
          try {
            expect(
              (attachment.width, attachment.height),
              (character.width, character.height),
            );
          } finally {
            attachment.dispose();
            character.dispose();
          }
        } finally {
          layer.dispose();
          body.dispose();
        }
      }
      expect(expected, isEmpty);
    },
  );

  for (final (pet, item, slot, coat) in [
    (Companion.fox, 'accessory_bow', 'head', null),
    (Companion.cat, 'accessory_glasses', 'face', 'single_coat'),
    (Companion.rabbit, 'accessory_scarf', 'neck', 'single_apron'),
  ]) {
    testWidgets(
      '${pet.name} wears its fitted accessory from the real wardrobe',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final stock = (await tester.runAsync(
          () => TestFamily.create(
            pet: pet == Companion.rabbit ? Companion.fox : Companion.rabbit,
          ),
        ))!;
        addTearDown(stock.dispose);
        final controller = FamilyController(stock.device, stock.rules)
          ..service = stock.service;
        addTearDown(controller.dispose);
        final owned = (await tester.runAsync(() async {
          final source = stock.service;
          final parent = await source.pin.unlock(TestFamily.pin);
          final items = [item, ?coat];
          final price = items.fold(
            stock.rules.companionUnlockPrice,
            (sum, id) => sum + (stock.rules.catalog[id]!['price'] as int),
          );
          for (var score = 0; score < price; score += 5) {
            await source.backfill(
              const TaskDraft('测试任务A', '', '测试标准A', 'challenge'),
              source.today,
              '',
              session: parent,
            );
          }
          await source.unlockCompanion(pet);
          await source.purchase(item);
          if (coat != null) await source.purchase(coat, wearOn: pet);
          await source.selectCompanion(pet);
          await controller.refresh();
          return (await source.items()).singleWhere(
            (row) => row['item_id'] == item,
          );
        }))!;
        expect(controller.family!.stage, 1);
        final originalLedger = (await tester.runAsync(stock.service.ledger))!;
        final id = 'item_$item';
        expect(owned['asset_id'], id);
        final root = GlobalKey();

        Future<void> showHome() async {
          await tester.pumpWidget(
            RepaintBoundary(
              key: root,
              child: CompanionsApp(controller: controller),
            ),
          );
          await tester.pump(const Duration(milliseconds: 60));
        }

        Future<void> prewarm(BuildContext context) async {
          await tester.runAsync(
            () => Future.wait([
              for (final path in {
                portraitArtwork(
                  pet,
                  1,
                  false,
                  coat == null ? null : 'item_$coat',
                ),
                actionArtwork(pet, 1, coat == null ? null : 'item_$coat'),
                if (pet != Companion.rabbit)
                  ...walkAssets(pet, coat == null ? null : 'item_$coat'),
                for (final pose in AccessoryPose.values)
                  ?registeredAccessory(
                    id,
                    pet,
                    1,
                    pose,
                    coat == null ? null : 'item_$coat',
                  ),
              })
                precacheImage(AssetImage(path), context),
            ]),
          );
          await tester.pump();
        }

        Future<void> tap(Finder button) async {
          await Scrollable.ensureVisible(tester.element(button), alignment: .5);
          await tester.pump();
          await tester.runAsync(() => tester.tap(button.hitTestable()));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 420));
        }

        Future<void> close() async {
          await tester.tap(find.byType(BackButton).hitTestable());
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 820));
          await tester.pump();
        }

        await showHome();
        await tap(find.text('衣橱'));
        await _waitFor(tester, find.text('伙伴衣橱'));
        final shown = find.byType(GardenScene);
        await _waitFor(tester, find.text('试穿衣服和配饰'));
        await tap(find.text('试穿衣服和配饰'));
        final thumbnail = fittedAccessoryThumbnail(id, pet, 1);
        expect(thumbnail, isNotNull);
        await _waitFor(
          tester,
          find.byWidgetPredicate(
            (node) =>
                node is Image &&
                node.image is AssetImage &&
                (node.image as AssetImage).assetName == thumbnail,
          ),
        );
        await tap(find.text(owned['name'] as String));
        await _waitFor(tester, shown);
        expect(tester.widget<GardenScene>(shown).outfit[slot], id);
        await close();
        await _waitFor(tester, find.text('衣服与配饰'));
        await close();
        final select = find.byKey(
          ValueKey<(Companion, String, String?)>((pet, slot, null)),
        );
        await _waitFor(tester, select);
        await Scrollable.ensureVisible(tester.element(shown));
        await tester.pump();
        await prewarm(tester.element(find.byType(IllustratedPet)));
        final without = await _actorFrame(tester, '${pet.name}-without');
        await tap(select);
        await tap(find.text(owned['name'] as String).hitTestable());
        expect(tester.widget<GardenScene>(shown).outfit[slot], id);
        await Scrollable.ensureVisible(tester.element(shown));
        await tester.pump();
        final dressed = await _actorFrame(tester, '${pet.name}-wardrobe');
        expect(dressed, isNot(equals(without)));

        final save = find.text('保存搭配');
        await tap(save);
        await _waitFor(tester, find.text('搭配已保存。'));
        final saved = await tester.runAsync(() => stock.service.wardrobe(pet));
        expect(
          saved!.singleWhere((row) => row['slot'] == slot)['entitlement_id'],
          owned['id'],
        );

        await tester.pumpWidget(const SizedBox());
        await tester.runAsync(() async {
          await stock.reopen();
          controller.service = stock.service;
          await controller.refresh();
        });
        await showHome();
        expect(tester.widget<GardenScene>(shown).outfit[slot], id);
        await prewarm(tester.element(find.byType(IllustratedPet)));
        final home = await _actorFrame(tester, '${pet.name}-home');
        final actor = find.byType(IllustratedPet);
        if (pet != Companion.rabbit) {
          await tap(find.text('暖廊'));
          final room = tester.getRect(find.byType(AnimatedBackdrop));
          for (final (point, view) in [
            (const Offset(.22, .917), 'left'),
            (const Offset(.325, .691), 'back'),
            (const Offset(.39, .92), 'front'),
            (const Offset(.78, .92), 'right'),
          ]) {
            await tester.tapAt(
              room.topLeft +
                  Offset(point.dx * room.width, point.dy * room.height),
            );
            var observed = false;
            for (var step = 0; step < 142; step++) {
              await tester.pump(const Duration(milliseconds: 40));
              final pose = tester
                  .widget<IllustratedPet>(actor)
                  .walkPose
                  ?.call();
              if (pose == null && observed) break;
              if (observed || pose == null || pose.stage != WalkStage.walk)
                continue;
              final side = math.cos(pose.yaw), depth = math.sin(pose.yaw);
              final rendered = side.abs() >= .43
                  ? (side < 0 ? 'left' : 'right')
                  : (depth < 0 ? 'back' : 'front');
              if (rendered == view && pose.ink >= .99) {
                final frame = await _actorFrame(
                  tester,
                  '${pet.name}-walk-$view',
                );
                expect(frame, isNot(equals(home)));
                observed = true;
              }
            }
            expect(
              observed,
              isTrue,
              reason: '${pet.name} $view actual walking',
            );
          }
        }
        await tap(find.text(pet.skillName));
        var action = false;
        for (var i = 0; i < 76; i++) {
          await tester.pump(const Duration(milliseconds: 40));
          final motion = tester.widget<IllustratedPet>(actor).motion?.call();
          if (motion != null && motion.keyPose == 1) {
            final frame = await _actorFrame(tester, '${pet.name}-skill');
            expect(frame, isNot(equals(home)));
            if (pet == Companion.rabbit && _frames.isNotEmpty) {
              await _frame(tester, find.byKey(root), 'rabbit-skill-room');
            }
            action = true;
            break;
          }
        }
        expect(action, isTrue);
        expect(await tester.runAsync(stock.service.ledger), originalLedger);
        expect((await tester.runAsync(stock.service.overview))!.experience, 0);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
