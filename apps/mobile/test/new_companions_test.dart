import 'dart:convert';
import 'dart:io';

import 'package:alice_companions/application/controller.dart';
import 'package:alice_companions/application/family.dart';
import 'package:alice_companions/application/transfer.dart';
import 'package:alice_companions/data/database.dart';
import 'package:alice_companions/data/device.dart';
import 'package:alice_companions/data/snapshot.dart';
import 'package:alice_companions/domain/companion_food.dart';
import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/domain/pin.dart';
import 'package:alice_companions/domain/rules.dart';
import 'package:alice_companions/features/garden.dart';
import 'package:alice_companions/illustration/companion_motion.dart';
import 'package:alice_companions/illustration/puppet.dart';
import 'package:alice_companions/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/families.dart';

const _task = TaskDraft('测试小事', '', '测试标准', 'challenge');
const _newPets = [Companion.otter, Companion.hedgehog];

Future<void> _wait(WidgetTester tester, Finder finder) async {
  for (
    var attempt = 0;
    attempt < 275 && finder.evaluate().length != 1;
    attempt++
  ) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 16)),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
  expect(finder, findsOneWidget);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await _wait(tester, finder);
  await Scrollable.ensureVisible(tester.element(finder), alignment: .5);
  await tester.pump();
  await _wait(tester, finder.hitTestable());
  await tester.runAsync(() => tester.tap(finder.hitTestable()));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 360));
}

void main() {
  for (final (version, balance, ledgerCount) in [(8, 48, 26), (10, 27, 29)]) {
    test('a released schema $version save upgrades and restores', () async {
      final fixture = await TestFamily.create();
      addTearDown(fixture.dispose);
      final folder = await Directory.systemTemp.createTemp('alice-roster-');
      addTearDown(() => folder.delete(recursive: true));
      final device = DeviceStore(folder, MemorySecureValues());
      final assetMap = jsonDecode(
        File('assets/config/runtime_assets.json').readAsStringSync(),
      ) as Json;
      final available = {
        for (final entry in assetMap.entries)
          if (File(entry.value as String).existsSync()) entry.key,
      };
      final transfer = TransferService(
        device: device,
        rules: fixture.rules,
        availableAssets: available,
        current: () => null,
      );
      final preview = await transfer.inspect(
        File('test/fixtures/pre_roster_v$version.alicebackup'),
        'Alice-Synthetic-V$version',
        null,
      );
      addTearDown(preview.close);
      expect(preview.info.schemaVersion, version);
      expect(preview.info.summary['balance'], balance);
      expect(preview.info.summary['ledger_count'], ledgerCount);
      expect(preview.info.summary['owned_companion_count'], 2);

      final schema = await expectedSchema();
      Future<Snapshot> verifyMigrated(File database) => checkSnapshot(
        database.path,
        schema,
        fixture.rules,
        available,
        compareWithSchemaVersion: version,
      );
      final existing = await preview.database.copy(
        '${folder.path}/upgrade.sqlite',
      );
      final db = FamilyDatabase.open(existing);
      try {
        expect(await db.value('PRAGMA user_version'), currentSchemaVersion);
        expect(await db.value('PRAGMA foreign_keys'), 1);
        expect(await db.rows('PRAGMA foreign_key_check'), isEmpty);
      } finally {
        await db.close();
      }
      final updated = await verifyMigrated(existing);
      expect(updated.summary, preview.info.summary);
      expect(updated.businessDigest, preview.info.businessDigest);

      final restored = await transfer.activate(
        preview,
        TestFamily.pin,
        PinGate.newRecoveryCode(),
        session: null,
        replace: false,
      );
      final service = restored.service;
      addTearDown(service.close);
      final file = device.databaseFile(service.pin.generation);
      final verified = await verifyMigrated(file);
      expect(verified.schemaVersion, currentSchemaVersion);
      expect(verified.summary, preview.info.summary);
      expect(verified.businessDigest, preview.info.businessDigest);
      final progress = await service.companionProgress();
      final cat = progress[Companion.cat]!;
      final fox = progress[Companion.fox]!;
      expect(
        (cat.stage, cat.experience, cat.bond.value),
        (4, 20, version == 10 ? 6 : 1),
      );
      expect((fox.stage, fox.experience, fox.bond.value), (2, 3, 1));
      final stock = await service.availableFood();
      if (version == 10) {
        expect(stock.keys, [CompanionFood.pudding]);
        expect(stock[CompanionFood.pudding]!.count, 2);
      } else {
        expect(stock, isEmpty);
      }
      expect((await service.overview())!.companion, Companion.fox);
      expect(
        (await service.wardrobe(Companion.cat)).single['asset_id'],
        'item_single_coat',
      );
      expect(
        (await service.wardrobe(Companion.fox)).single['asset_id'],
        'item_accessory_scarf',
      );
      expect(await service.db.rows('PRAGMA foreign_key_check'), isEmpty);
      await service.verifyAccounting();
    });
  }

  testWidgets(
    'both new companions unlock through the child home and play dressed',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final fixture = (await tester.runAsync(
        () => TestFamily.create(pet: Companion.cat),
      ))!;
      addTearDown(fixture.dispose);
      final service = fixture.service;
      final controller = FamilyController(fixture.device, fixture.rules)
        ..service = service;
      addTearDown(controller.dispose);
      await tester.runAsync(() async {
        final parent = await service.pin.unlock(TestFamily.pin);
        for (var i = 0; i < 19; i++) {
          await service.backfill(_task, service.today, '', session: parent);
        }
        await service.purchase('single_coat');
        await controller.refresh();
      });
      await tester.pumpWidget(CompanionsApp(controller: controller));
      await tester.pump(const Duration(milliseconds: 350));
      final scene = find.byType(GardenScene);
      final sprite = find.byType(IllustratedPet);
      final price = service.rules.companionUnlockPrice;
      for (final pet in _newPets) {
        final before = controller.family!.balance;
        await _tap(tester, find.text('伙伴'));
        final card = find.ancestor(
          of: find.text(pet.nickname),
          matching: find.byType(GardenCard),
        );
        await _tap(
          tester,
          find.descendant(of: card, matching: find.text('用 $price 分解锁')),
        );
        await _tap(tester, find.text('确认解锁'));
        final takeHome = find.descendant(of: card, matching: find.text('带回小家'));
        await _wait(tester, takeHome);
        await tester.runAsync(() async {
          final current = (await service.overview())!;
          expect(current.balance, before - price);
          final unlocked = (await service.companionProgress())[pet]!;
          expect((unlocked.stage, unlocked.experience), (1, 0));
        });
        await _tap(tester, takeHome);
        await _wait(tester, scene);
        final ledger = (await tester.runAsync(service.ledger))!;
        await _tap(tester, find.text('衣橱'));
        await _tap(
          tester,
          find.byKey(
            ValueKey<(Companion, String, String?)>((pet, 'body', null)),
          ),
        );
        await _tap(tester, find.text('杏色外套').last.hitTestable());
        await _tap(tester, find.text('保存搭配'));
        await _wait(tester, find.text('搭配已保存。'));
        await _tap(tester, find.byType(BackButton));
        await _wait(tester, scene);
        final selected = tester.widget<GardenScene>(scene);
        expect((selected.companion, selected.stage), (pet, 1));
        expect(selected.outfit['body'], 'item_single_coat');
        await _tap(tester, find.text(pet.skillName));
        for (var i = 0; i < 24; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        expect(
          tester.widget<IllustratedPet>(sprite).motion!().usesGroundArt(pet),
          isTrue,
        );
        await _tap(tester, find.text('过来'));
        expect(
          tester.widget<IllustratedPet>(sprite).walkPose?.call(),
          isNotNull,
        );
        await tester.runAsync(() async {
          await service.serial.run(() async {});
          final end = (await service.overview())!;
          expect((end.balance, end.experience), (before - price, 0));
          expect(await service.ledger(), ledger);
        });
      }
      expect(tester.takeException(), isNull);
    },
  );
}
