import 'dart:io';
import 'dart:ui' as ui;

import 'package:alice_companions/application/controller.dart';
import 'package:alice_companions/application/family.dart';
import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/illustration/action_poses.dart';
import 'package:alice_companions/illustration/companion_hops.dart';
import 'package:alice_companions/illustration/companion_walk_art.dart';
import 'package:alice_companions/illustration/evolution.dart';
import 'package:alice_companions/illustration/living_scene.dart';
import 'package:alice_companions/illustration/puppet.dart';
import 'package:alice_companions/illustration/tailoring.dart';
import 'package:alice_companions/main.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/families.dart';

const _folder = String.fromEnvironment('ALICE_COAT_FRAMES');
const _body = 'item_single_coat';
const _task = TaskDraft('测试任务A', '', '测试标准A', 'challenge');

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  for (var tries = 0; tries < 50 && !tester.any(finder); tries++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 40));
  }
  expect(finder, findsOneWidget);
}

Future<void> _tap(WidgetTester tester, Finder button) async {
  await _waitFor(tester, button);
  await Scrollable.ensureVisible(tester.element(button), alignment: .5);
  await tester.pump();
  await tester.runAsync(() => tester.tap(button.hitTestable()));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 420));
}

Future<int> _coatPixels(
  WidgetTester tester,
  Finder actor,
  FittedCoat coat,
  String label,
) async {
  final sprite = find.descendant(
    of: actor,
    matching: find.byType(RepaintBoundary),
  );
  final boundary = tester.renderObject<RenderRepaintBoundary>(sprite);
  return (await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    try {
      if (_folder.isNotEmpty) {
        await Directory(_folder).create(recursive: true);
        final file = (await image.toByteData(format: ui.ImageByteFormat.png))!;
        await File('$_folder/$label.png')
            .writeAsBytes(file.buffer.asUint8List());
      }
      final pixels = (await image.toByteData())!.buffer.asUint8List();
      var count = 0;
      for (var i = 0; i < pixels.length; i += 4) {
        if (pixels[i + 3] < 220) continue;
        final r = pixels[i], g = pixels[i + 1], b = pixels[i + 2];
        final fabric = coat == FittedCoat.mapVest
            ? g > 55 && g < 145 && r - g < 36 && g - b > 19
            : r > 140 && r - b > 39 && r - g > 23 && r - g < 71 && g - b > 14;
        if (fabric) count++;
      }
      return count;
    } finally {
      image.dispose();
    }
  }))!;
}

void main() {
  for (final (pet, stage, coat) in [
    (Companion.fox, 1, FittedCoat.mapVest),
    (Companion.cat, 4, FittedCoat.wingCape),
  ]) {
    testWidgets(
      '${pet.name} wears its fitted coat in play from a saved entitlement',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final stock = (await tester.runAsync(TestFamily.create))!;
        addTearDown(stock.dispose);
        final controller = FamilyController(stock.device, stock.rules)
          ..service = stock.service;
        addTearDown(controller.dispose);

        final owned = (await tester.runAsync(() async {
          final source = stock.service;
          final parent = await source.pin.unlock(TestFamily.pin);
          final accessories = [
            'accessory_scarf',
            if (pet == Companion.fox) ...['accessory_bow', 'accessory_glasses'],
          ];
          final cost =
              source.rules.companionUnlockPrice +
              (source.rules.catalog['single_coat']!['price'] as int) +
              accessories.fold<int>(
                0,
                (sum, item) =>
                    sum + (source.rules.catalog[item]!['price'] as int),
              );
          for (var score = 0; score < cost; score += 5) {
            await source.backfill(_task, source.today, '', session: parent);
          }
          await source.purchase('single_coat');
          await source.unlockCompanion(pet);
          await source.selectCompanion(pet);
          for (
            var count = 0;
            stage == 4 && count < source.rules.thresholds[2];
            count++
          ) {
            await source.backfill(_task, source.today, '', session: parent);
          }
          for (final accessory in accessories) {
            await source.purchase(accessory, wearOn: pet);
          }
          await controller.refresh();
          return (await source.items()).singleWhere(
            (item) => item['item_id'] == 'single_coat',
          );
        }))!;
        expect(controller.family!.stage, stage);
        final ledger = (await tester.runAsync(stock.service.ledger))!;
        final experience = controller.family!.experience;
        final actor = find.byType(IllustratedPet);
        final room = find.byType(GardenScene);

        Future<void> openApp() async {
          await tester.pumpWidget(CompanionsApp(controller: controller));
          await tester.pump(const Duration(milliseconds: 60));
        }

        Future<void> warm(Set<String> paths) async {
          final context = tester.element(actor);
          await tester.runAsync(
            () => Future.wait([
              for (final path in paths)
                precacheImage(AssetImage(path), context),
            ]),
          );
          await tester.pump();
        }

        Future<int> callAndReadFabric(String label, String? garment) async {
          final tailored = garment == null ? null : coat;
          final wearing = tester.widget<IllustratedPet>(actor).outfit;
          final paintedScarf =
              pet == Companion.fox && wearing['neck'] == 'item_accessory_scarf';
          await warm({
            portraitArtwork(
              pet,
              stage,
              false,
              garment,
              paintedScarf: paintedScarf,
            ),
            actionArtwork(pet, stage, garment, paintedScarf: paintedScarf),
            if (!paintedScarf) ...[
              fittedAccessory('item_accessory_scarf', pet),
              fittedAccessory('item_accessory_scarf', pet, airborne: true),
            ],
            if (pet == Companion.cat)
              for (final picture in [
                cloudBraceArt,
                cloudFlightArt,
                cloudLandingArt,
              ])
                tailored?.on(picture) ?? picture
            else ...{
              if (tailored != null) ...{
                portraitArtwork(
                  pet,
                  stage,
                  false,
                  garment,
                  facesLeft: true,
                  paintedScarf: paintedScarf,
                ),
                actionArtwork(
                  pet,
                  stage,
                  garment,
                  facesLeft: true,
                  paintedScarf: paintedScarf,
                ),
              },
              ...walkAssets(pet, garment, paintedScarf: paintedScarf),
            },
          });
          await _tap(tester, find.text('过来'));
          bool moving() {
            final current = tester.widget<IllustratedPet>(actor);
            return current.walkPose?.call()?.ink == 1 ||
                current.hop?.call()?.airborne == true;
          }

          for (var i = 0; i < 60 && !moving(); i++) {
            await tester.pump(const Duration(milliseconds: 40));
          }
          expect(moving(), isTrue);
          return _coatPixels(tester, actor, coat, label);
        }

        await openApp();
        final plainMove = await callAndReadFabric(
          '${pet.name}-bare-move',
          null,
        );
        await _tap(tester, find.text('衣橱'));
        final tryOn = find.text('试穿衣服和配饰');
        await _tap(tester, tryOn);
        final tile = find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName == coat.thumbnail,
        );
        await _waitFor(tester, tile);
        await _tap(tester, find.text(coat.nameInWardrobe));
        await _waitFor(tester, room);
        expect(tester.widget<GardenScene>(room).outfit['body'], _body);
        await _tap(tester, find.text('原样'));
        expect(tester.widget<GardenScene>(room).outfit['body'], isNull);
        for (var pages = 0; pages < 2; pages++) {
          await _tap(tester, find.byType(BackButton).hitTestable());
          await tester.pump(const Duration(milliseconds: 820));
        }

        final body = find.byKey(
          ValueKey<(Companion, String, String?)>((pet, 'body', null)),
        );
        await _waitFor(tester, body);
        await warm({
          portraitArtwork(
            pet,
            stage,
            false,
            null,
            paintedScarf: pet == Companion.fox,
          ),
          portraitArtwork(
            pet,
            stage,
            false,
            _body,
            paintedScarf: pet == Companion.fox,
          ),
          if (pet != Companion.fox)
            fittedAccessory('item_accessory_scarf', pet),
        });
        await Scrollable.ensureVisible(tester.element(room));
        await tester.pump();
        final plain = await _coatPixels(
          tester,
          actor,
          coat,
          '${pet.name}-bare',
        );
        await _tap(tester, body);
        await _tap(tester, find.text(coat.nameInWardrobe).hitTestable());
        await Scrollable.ensureVisible(tester.element(room));
        await tester.pump();
        final trial = await _coatPixels(
          tester,
          actor,
          coat,
          '${pet.name}-wardrobe',
        );
        expect(trial, greaterThan(plain + 100));
        expect(
          tester.widget<GardenScene>(room).outfit['neck'],
          'item_accessory_scarf',
        );

        if (pet == Companion.fox) {
          final wardrobe = (await tester.runAsync(
            () => stock.service.wardrobe(pet),
          ))!;
          final neckId =
              wardrobe.singleWhere(
                    (row) => row['slot'] == 'neck',
                  )['entitlement_id']
                  as String;
          final scarfName =
              stock.rules.catalog['accessory_scarf']!['name'] as String;
          Finder neckSlot(String? id) => find.byKey(
            ValueKey<(Companion, String, String?)>((pet, 'neck', id)),
          );
          await _tap(tester, neckSlot(neckId));
          await _tap(tester, find.text('空').last.hitTestable());
          expect(tester.widget<GardenScene>(room).outfit['neck'], isNull);
          expect(tester.widget<GardenScene>(room).outfit['body'], _body);
          await warm({portraitArtwork(pet, stage, false, _body)});
          await Scrollable.ensureVisible(tester.element(room));
          await tester.pump();
          expect(
            await _coatPixels(tester, actor, coat, 'fox-vest-alone'),
            greaterThan(100),
          );
          await _tap(tester, neckSlot(null));
          await _tap(tester, find.text(scarfName).last.hitTestable());
          expect(
            tester.widget<GardenScene>(room).outfit['neck'],
            'item_accessory_scarf',
          );
        }

        await _tap(tester, find.text('保存搭配'));
        await _waitFor(tester, find.text('搭配已保存。'));
        await tester.pumpWidget(const SizedBox());
        await tester.runAsync(() async {
          await stock.reopen();
          controller.service = stock.service;
          await controller.refresh();
        });
        await openApp();
        expect(tester.widget<GardenScene>(room).outfit['body'], _body);
        if (pet == Companion.fox) {
          expect(tester.widget<GardenScene>(room).outfit, {
            'body': _body,
            'neck': 'item_accessory_scarf',
            'head': 'item_accessory_bow',
            'face': 'item_accessory_glasses',
          });
        }
        expect(
          await callAndReadFabric('${pet.name}-move', _body),
          greaterThan(plainMove + 50),
        );

        if (pet == Companion.cat) {
          await _tap(tester, find.text('成长').hitTestable());
          await _tap(tester, find.text('回看进化'));
          final opened = find.descendant(
            of: find.byType(EvolutionMoment),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is IllustratedPet &&
                  widget.stage == 4 &&
                  widget.reveal,
            ),
          );
          await _waitFor(tester, opened);
          await tester.runAsync(
            () => precacheImage(
              AssetImage(portraitArtwork(pet, stage, true, _body)),
              tester.element(opened),
            ),
          );
          await tester.pump(const Duration(seconds: 2));
          await tester.pump(const Duration(seconds: 2));
          expect(tester.widget<IllustratedPet>(opened).reveal, isTrue);
          expect(
            await _coatPixels(tester, opened, coat, 'cat-evolution'),
            greaterThan(100),
          );
        }
        final saved = (await tester.runAsync(
          () => stock.service.wardrobe(pet),
        ))!;
        expect(
          saved.singleWhere((row) => row['slot'] == 'body')['entitlement_id'],
          owned['id'],
        );
        expect((await tester.runAsync(stock.service.ledger))!, ledger);
        expect(controller.family!.experience, experience);
      },
    );
  }
}
