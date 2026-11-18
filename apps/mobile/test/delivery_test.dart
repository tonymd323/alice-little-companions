import 'dart:convert';
import 'dart:io';

import 'package:alice_companions/application/controller.dart';
import 'package:alice_companions/application/family.dart';
import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/domain/pin.dart';
import 'package:alice_companions/domain/rules.dart';
import 'package:alice_companions/features/garden.dart';
import 'package:alice_companions/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/families.dart';

final fixtureAssets = (jsonDecode(
  File('assets/config/runtime_assets.json').readAsStringSync(),
) as Json).keys.toSet();

void main() {
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
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      final selectedContrast =
          (Colors.white.computeLuminance() + .05) /
          (foliage.computeLuminance() + .05);
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
      final before = (await tester.runAsync(() async {
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
      await tester.pumpAndSettle();
      final preview = find.text('外观预览');
      await tester.ensureVisible(preview);
      await tester.tap(preview);
      await tester.pumpAndSettle();
      for (final pet in Companion.values) {
        await tester.ensureVisible(find.text(pet.label));
        await tester.tap(find.text(pet.label));
        await tester.pumpAndSettle();
        for (var stage = 1; stage <= 6; stage++) {
          final button = find.byTooltip(
            '第 $stage 阶段 · ${stageNames[stage - 1]}',
          );
          await tester.ensureVisible(button);
          await tester.tap(button);
          await tester.pumpAndSettle();
        }
      }
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final latest = (await fixture.service.overview())!;
        expect(
          (
            latest.balance,
            latest.revision,
            latest.stage,
            latest.companion,
            latest.days,
          ),
          (
            before.balance,
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
