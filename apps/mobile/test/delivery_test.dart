import 'dart:convert';
import 'dart:io';

import 'package:alice_companions/application/controller.dart';
import 'package:alice_companions/application/family.dart';
import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/domain/pin.dart';
import 'package:alice_companions/domain/rules.dart';
import 'package:alice_companions/domain/window_page.dart';
import 'package:alice_companions/features/garden.dart';
import 'package:alice_companions/features/rewards.dart';
import 'package:alice_companions/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alice_companions/illustration/puppet.dart';
import 'package:alice_companions/illustration/wind_stage.dart';
import 'package:material_ui/material_ui.dart';

import 'support/families.dart';

final fixtureAssets = (jsonDecode(
  File('assets/config/runtime_assets.json').readAsStringSync(),
) as Json).keys.toSet();

// The illustrated home has a continuous idle pose. Advance transitions by a
// fixed interval so this check also exercises an active animation clock.
Future<void> advanceScene(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 450));
  await tester.pump(const Duration(milliseconds: 40));
}

// Drift and image decoding make progress outside the widget-test clock.
Future<void> waitForScene(WidgetTester tester, Finder target) async {
  for (var i = 0; i < 180 && target.evaluate().isEmpty; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 40)),
    );
    await tester.pump(const Duration(milliseconds: 10));
  }
  expect(target, findsOneWidget);
}

void main() {
  testWidgets(
    'the home story repairs actual panes in either order and keeps a permanent light with zero income',
    (tester) async {
      final stock = (await tester.runAsync(TestFamily.create))!;
      final controller = FamilyController(
        stock.device,
        stock.rules,
        assets: fixtureAssets,
      )..service = stock.service;
      addTearDown(() async {
        controller.dispose();
        await stock.dispose();
      });
      await tester.runAsync(controller.refresh);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(CompanionsApp(controller: controller));
      await advanceScene(tester);
      Future<void> press(Finder target, {bool persist = false}) async {
        await tester.ensureVisible(target);
        if (persist) {
          await tester.runAsync(() async {
            await tester.tap(target);
            await stock.service.db.value('SELECT 1');
            await stock.service.serial.run(() async {});
            await controller.refresh();
          });
        } else {
          await tester.tap(target);
        }
        await advanceScene(tester);
      }

      await press(find.text('主线 · 风过暖廊'), persist: true);
      await waitForScene(tester, find.byType(WindStage));
      await press(find.text('直接去窗边'), persist: true);
      final basket = find.byKey(const ValueKey('wind-basket'));
      await waitForScene(tester, basket);
      for (final pane in [10, 9, 11, 8]) {
        await press(basket);
        await press(find.byKey(ValueKey('wind-pane-$pane')), persist: true);
      }
      expect(tester.widget<WindStage>(find.byType(WindStage)).mask, 30);
      expect(find.textContaining('脚下这段还暗着'), findsOneWidget);
      await press(basket);
      await press(find.byKey(const ValueKey('wind-pane-7')), persist: true);
      await press(find.text('看团聚结果'));
      await press(find.text('再演一次'), persist: true);
      await press(find.text('直接去窗边'), persist: true);
      await press(basket);
      await press(find.byKey(const ValueKey('wind-pane-7')), persist: true);
      expect(tester.widget<WindStage>(find.byType(WindStage)).mask, 1);
      expect(find.textContaining('走到下一段桥'), findsOneWidget);
      await press(find.byTooltip('回到小家'), persist: true);
      expect(
        tester.widget<GardenScene>(find.byType(GardenScene)).windowsLit,
        isTrue,
      );
      await tester.runAsync(() async {
        await stock.service.saveWindowMathBookmark(WindowPage.count, {});
        await stock.reopen();
        final family = (await stock.service.overview())!;
        final replay = await stock.service.windProgress();
        expect((replay.run, replay.mask), (2, 1));
        expect(
          (family.windowsLit, family.balance, family.experience),
          (true, 0, 0),
        );
        expect((await stock.service.windowMathBookmark()).started, isTrue);
        expect(await stock.service.ledger(), isEmpty);
      });
    },
  );

  testWidgets(
    'the family home opens its own saved window chapter with the chosen companion',
    (tester) async {
      final stock = (await tester.runAsync(
        () => TestFamily.create(pet: Companion.cat),
      ))!;
      final controller = FamilyController(
        stock.device,
        stock.rules,
        assets: fixtureAssets,
      )..service = stock.service;
      addTearDown(() async {
        controller.dispose();
        await stock.dispose();
      });
      await tester.runAsync(() async {
        await stock.service.saveWindowMathBookmark(WindowPage.missing, {});
        await controller.refresh();
      });
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(CompanionsApp(controller: controller));
      await advanceScene(tester);
      final entry = find.text('主线 · 风过暖廊');
      expect(entry.hitTestable(), findsOneWidget);
      await tester.runAsync(() async {
        await tester.tap(entry);
        // Wait for the chapter read on Drift's background isolate before pumping navigation.
        await stock.service.db.value('SELECT 1');
      });
      await advanceScene(tester);
      await waitForScene(tester, find.text('风过暖廊'));
      await advanceScene(tester);
      await tester.tap(find.byTooltip('章节选项'));
      await advanceScene(tester);
      await tester.runAsync(() async {
        await tester.tap(find.text('继续原来的数学书签'));
        await stock.service.db.value('SELECT 1');
      });
      await advanceScene(tester);
      await waitForScene(tester, find.text('还差几片叶子？'));
      await advanceScene(tester);
      expect(find.textContaining('团团已经嵌好了'), findsOneWidget);
      final room = tester.widget<GardenScene>(find.byType(GardenScene));
      expect(room.companion, Companion.cat);
      expect(room.view, HomeView.veranda);
      expect(room.stage, controller.family!.stage);
      await tester.tap(find.byTooltip('回到风过暖廊'));
      await advanceScene(tester);
      await tester.tap(find.byTooltip('回到小家'));
      await advanceScene(tester);
      expect(entry.hitTestable(), findsOneWidget);
      expect(
        tester.widget<GardenScene>(find.byType(GardenScene)).view,
        HomeView.veranda,
      );
    },
  );

  testWidgets(
    'room and clothing comparisons open from the family catalogue without changing the SQLite state',
    (tester) async {
      final stock = (await tester.runAsync(TestFamily.create))!;
      final controller = FamilyController(
        stock.device,
        stock.rules,
        assets: fixtureAssets,
      )..service = stock.service;
      addTearDown(() async {
        controller.dispose();
        await stock.dispose();
      });
      await tester.runAsync(controller.refresh);
      Future<List<Object?>> state() async => [
        (await stock.service.overview())!.revision,
        (await stock.service.overview())!.balance,
        await stock.service.db.value('SELECT count(*) FROM processed_commands'),
        await stock.service.ledger(),
        await stock.service.items(),
        await stock.service.wardrobe(Companion.rabbit),
      ];
      final before = await tester.runAsync(state);
      for (final id in ['single_armchair', 'single_coat']) {
        await tester.pumpWidget(
          MaterialApp(
            home: RewardPage(
              key: ValueKey(id),
              controller: controller,
              product: stock.rules.catalog[id]!,
            ),
          ),
        );
        final option = find.text(id == 'single_coat' ? '试穿效果' : '看摆好效果');
        for (var i = 0; i < 24 && option.evaluate().isEmpty; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 15)),
          );
          await advanceScene(tester);
        }
        expect(option, findsOneWidget);
        GardenScene room() =>
            tester.widget<GardenScene>(find.byType(GardenScene));
        final look = room();
        if (id == 'single_coat') {
          expect(look.outfit['body'], 'item_single_coat');
        } else {
          expect(
            look.pieces.map((p) => p.asset),
            contains('item_single_armchair'),
          );
        }
        await tester.tap(find.text('原样'));
        await advanceScene(tester);
        expect(room().outfit, isEmpty);
        expect(
          room().pieces.map((p) => p.asset),
          isNot(contains('item_single_armchair')),
        );
        await tester.tap(option);
        await advanceScene(tester);
        expect(room().outfit, look.outfit);
        expect(tester.takeException(), isNull);
      }
      expect(await tester.runAsync(state), before);
    },
  );

  test('AC-26/34 active file failure can open the encrypted checkpoint through current PIN', () async {
    final fixture = await TestFamily.create();
    addTearDown(fixture.dispose);
    final service = fixture.service;
    final parent = await service.pin.unlock(TestFamily.pin);
    await service.backfill(
      const TaskDraft('测试任务A', '', '测试标准A', 'focus'),
      service.today,
      '测试反馈',
      session: parent,
    );
    final original = (await fixture.device.activeGeneration())!;
    final controller = FamilyController(
      fixture.device,
      fixture.rules,
      assets: fixtureAssets,
    )..service = service;
    addTearDown(controller.dispose);
    final backup = await controller.transfer.protectCurrent(parent);
    await service.close();
    final broken = fixture.device.databaseFile(original);
    await broken.writeAsBytes([1, 2, 3], flush: true);
    await controller.open();
    expect(controller.needsRepair, isTrue);
    expect(controller.family, isNull);
    await expectLater(
      controller.transfer.inspectCheckpoint(backup!.checkpoint, null),
      throwsA(isA<UserError>()),
    );
    await controller.unlock(TestFamily.pin);
    final preview = await controller.transfer.inspectCheckpoint(
      backup.checkpoint,
      controller.session,
    );
    addTearDown(preview.close);
    expect(preview.info.summary['balance'], 3);
    final result = await controller.transfer.activate(
      preview,
      685385.toString(),
      PinGate.newRecoveryCode(),
      session: controller.session,
      replace: true,
    );
    fixture.service = result.service;
    await controller.acceptActivation(result);
    expect(controller.needsRepair, isFalse);
    expect(controller.family!.balance, 3);
    expect(await broken.readAsBytes(), [1, 2, 3]);
    expect(await fixture.device.activeGeneration(), isNot(original));
    expect(await fixture.service.ledger(), hasLength(1));
  });

  testWidgets(
    'AC-35/36/37 preview is operable at four reference viewport sizes with 130% text',
    (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      final selectedContrast =
          (Colors.white.computeLuminance() + .05) /
          (terracotta.computeLuminance() + .05);
      expect(selectedContrast, greaterThanOrEqualTo(4.5));
      for (final target in [
        const Size(1194, 834),
        const Size(834, 1194),
        const Size(390, 844),
        const Size(360, 800),
      ]) {
        tester.view.physicalSize = target;
        await tester.pumpWidget(CompanionsApp(key: ValueKey(target)));
        await tester.pumpAndSettle();
        final button = find.byTooltip('第 6 阶段 · 满满的爱');
        await tester.ensureVisible(button);
        await tester.pumpAndSettle();
        expect(tester.getSize(button).shortestSide, greaterThanOrEqualTo(48));
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(find.text('第 6 阶段 · 满满的爱'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'AC-18/35 preview for an existing family leaves the entire SQLite command state unchanged',
    (tester) async {
      final fixture = (await tester.runAsync(
        () => TestFamily.create(pet: Companion.rabbit),
      ))!;
      final controller = FamilyController(
        fixture.device,
        fixture.rules,
        assets: fixtureAssets,
      )..service = fixture.service;
      addTearDown(() async {
        controller.dispose();
        await fixture.dispose();
      });
      final initial = (await tester.runAsync(() async {
        final adult = await fixture.service.pin.unlock(TestFamily.pin);
        await fixture.service.backfill(
          const TaskDraft('测试任务A', '', '测试标准A', 'focus'),
          fixture.service.today,
          '测试反馈',
          session: adult,
        );
        await controller.refresh();
        return (await fixture.service.overview())!;
      }))!;
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(CompanionsApp(controller: controller));
      await advanceScene(tester);
      await tester.tap(find.text('暖廊'));
      await advanceScene(tester);
      final petPosition = tester.getCenter(find.byType(IllustratedPet));
      await tester.runAsync(() => tester.tapAt(petPosition));
      await advanceScene(tester);
      expect(find.text('桃桃轻轻跳了一下'), findsOneWidget);
      final before = (await tester.runAsync(() async {
        // The live interaction records its first memory before the preview.
        await fixture.service.serial.run(() async {});
        final touched = (await fixture.service.overview())!;
        expect(touched.bond.touched, isTrue);
        expect(touched.revision, initial.revision + 1);
        expect((touched.balance, touched.experience), (3, 1));
        return touched;
      }))!;
      final preview = find.text('外观预览');
      await tester.ensureVisible(preview);
      await tester.tap(preview);
      await advanceScene(tester);
      for (final pet in Companion.values) {
        await tester.ensureVisible(find.text(pet.label));
        await tester.tap(find.text(pet.label));
        await advanceScene(tester);
        for (var stage = 1; stage <= 6; stage++) {
          final button = find.byTooltip(
            '第 $stage 阶段 · ${stageNames[stage - 1]}',
          );
          await tester.ensureVisible(button);
          await tester.tap(button);
          await advanceScene(tester);
        }
      }
      await tester.tap(find.byType(BackButton));
      await advanceScene(tester);
      await tester.runAsync(() async {
        final latest = (await fixture.service.overview())!;
        expect(
          (
            latest.balance,
            latest.experience,
            latest.revision,
            latest.stage,
            latest.companion,
            latest.days,
          ),
          (
            before.balance,
            before.experience,
            before.revision,
            before.stage,
            before.companion,
            before.days,
          ),
        );
        expect((await fixture.service.ledger()).single['delta'], 3);
        expect(
          await fixture.service.db.value(
            'SELECT COUNT(*) FROM processed_commands',
          ),
          before.revision,
        );
      });
    },
  );
}
