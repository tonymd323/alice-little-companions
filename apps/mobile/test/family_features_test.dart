import 'dart:convert';
import 'dart:io';

import 'package:alice_companions/application/controller.dart';
import 'package:alice_companions/application/family.dart';
import 'package:alice_companions/application/transfer.dart';
import 'package:alice_companions/data/device.dart';
import 'package:alice_companions/data/snapshot.dart';
import 'package:alice_companions/domain/companion_bond.dart';
import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/domain/pin.dart';
import 'package:alice_companions/domain/rain_map.dart';
import 'package:alice_companions/domain/window_page.dart';
import 'package:alice_companions/main.dart';
import 'package:flutter/widgets.dart' show Size, SizedBox, ValueKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'support/families.dart';

final assets = (jsonDecode(
  File('assets/config/runtime_assets.json').readAsStringSync(),
) as Map<String, dynamic>).keys.toSet();

Future<void> waitFor(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 40 && !tester.any(finder); attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(finder, findsOneWidget);
}

void main() {
  test(
    'a v6 home keeps the same save and gains empty map and memory sections',
    () async {
      final stock = await TestFamily.create();
      addTearDown(stock.dispose);
      await stock.service.saveWindowMathBookmark(WindowPage.finished, {1, 3});
      final run = (await stock.service.beginWindStory()).run;
      await stock.service.placeWindLeaf(2, run: run);
      final id = stock.service.pin.generation;
      final file = stock.device.databaseFile(id);
      await stock.service.close();
      final legacy = sqlite3.open(file.path);
      try {
        legacy.execute(
          'DROP TABLE rain_map_runs; DROP TABLE companion_memories; PRAGMA user_version = 6',
        );
      } finally {
        legacy.close();
      }
      final schema = await expectedSchema();
      final old = await checkSnapshot(file.path, schema, stock.rules, assets);
      stock.service = await FamilyService.load(stock.device, id, stock.rules);
      final upgraded = await checkSnapshot(
        file.path,
        schema,
        stock.rules,
        assets,
      );
      expect((old.schemaVersion, upgraded.schemaVersion), (6, 7));
      expect(upgraded.businessDigest, old.businessDigest);
      expect(upgraded.summary, old.summary);
      expect((await stock.service.overview())!.bond.label, '初见');
      expect((await stock.service.rainMapProgress()).started, isFalse);
      expect((await stock.service.windProgress()).mask, 1 << 2);
      expect((await stock.service.windowMathBookmark()).pattern, {1, 3});
    },
  );

  test(
    'an encrypted round trip keeps the ledger, furnishings and story',
    () async {
      final stock = await TestFamily.create(pet: Companion.fox);
      addTearDown(stock.dispose);
      var source = stock.service;
      await expectLater(source.beginRainMap(), throwsA(isA<UserError>()));
      final parent = await source.pin.unlock(TestFamily.pin);
      await source.backfill(
        const TaskDraft('测试任务A', '', '测试标准A', 'focus'),
        source.today,
        '',
        session: parent,
      );
      for (var i = 0; i < 9; i++) {
        await source.backfill(
          const TaskDraft('测试任务B', '', '测试标准B', 'challenge'),
          source.today,
          '',
          session: parent,
        );
      }
      final pending =
          (await source.publish(
                const TaskDraft('测试任务C', '', '测试标准C', 'light'),
                session: parent,
              ))['instance_id']
              as String;
      await source.submit(pending, '测试申报');
      await source.purchase('decor_vase');
      await source.purchase('single_armchair');
      await source.purchase('accessory_scarf');
      await source.setWish('single_coat');
      final room = (await source.spaces()).single['id'] as String;
      final items = await source.items();
      final furnishings = await source.furnishings(room);
      final wardrobe = await source.wardrobe(Companion.fox);
      final wish = await source.wish();
      expect(
        items.map((item) => item['item_id']),
        unorderedEquals(['decor_vase', 'single_armchair', 'accessory_scarf']),
      );
      expect(
        furnishings.map((item) => item['item_id']),
        unorderedEquals([
          'base_bed',
          'base_rug',
          'decor_vase',
          'single_armchair',
        ]),
      );
      expect(
        wardrobe.single['entitlement_id'],
        items.singleWhere((item) => item['item_id'] == 'accessory_scarf')['id'],
      );
      expect(wish?['item_id'], 'single_coat');
      await source.saveWindowMathBookmark(WindowPage.finished, {1, 3});
      final ledger = await source.ledger();
      final first = (await source.overview())!;
      expect((first.balance, first.experience, first.stage), (5, 10, 3));
      await Future.wait([
        for (var i = 0; i < 4; i++)
          source.recordCompanionMoment(Companion.fox, CompanionMoment.touch),
      ]);
      expect((await source.overview())!.revision, first.revision + 1);
      expect((await source.overview())!.bond.label, '熟悉');
      await source.recordCompanionMoment(Companion.fox, CompanionMoment.call);
      expect((await source.overview())!.bond.label, '默契');
      await source.selectCompanion(Companion.cat);
      expect((await source.overview())!.bond.label, '初见');
      await source.recordCompanionMoment(Companion.cat, CompanionMoment.call);
      await source.selectCompanion(Companion.fox);
      expect((await source.overview())!.bond.label, '默契');

      final initial = await source.beginRainMap();
      expect(initial.run, 1);
      await expectLater(
        source.stampRainMap(run: 1, group: 0),
        throwsA(isA<UserError>()),
      );
      await expectLater(
        source.stepRainMapStone(run: 1, group: 0, stone: 2),
        throwsA(isA<UserError>()),
      );
      await Future.wait([
        source.stepRainMapStone(run: 1, group: 0, stone: 0),
        source.stepRainMapStone(run: 1, group: 0, stone: 0),
      ]);
      await stock.reopen();
      source = stock.service;
      final halfway = await source.rainMapProgress();
      expect((halfway.run, halfway.stamps, halfway.stones), (1, 0, 1));
      for (var group = 0; group < RainMapProgress.groupCount; group++) {
        for (
          var stone = group == 0 ? halfway.stones : 0;
          stone < RainMapProgress.groupSize;
          stone++
        ) {
          await source.stepRainMapStone(run: 1, group: group, stone: stone);
        }
        await source.stampRainMap(run: 1, group: group);
      }
      final finish = await source.rainMapProgress();
      expect(
        (finish.complete, finish.cleared, finish.totalStones),
        (true, true, 12),
      );
      await expectLater(
        source.solveRainMapChallenge(6),
        throwsA(isA<UserError>()),
      );
      expect((await source.solveRainMapChallenge(9)).challengeSolved, isTrue);
      final replay = await source.restartRainMap(run: 1);
      expect(
        (replay.run, replay.complete, replay.cleared, replay.challengeSolved),
        (2, false, true, true),
      );
      await source.stepRainMapStone(run: replay.run, group: 0, stone: 0);
      // An old action can be retried without changing the new round.
      expect((await source.stampRainMap(run: 1, group: 0)).stones, 1);
      expect(await source.ledger(), ledger);

      const password = '家园备份测试密码-1234';
      const targetPin = '264915';
      const returnedPin = '784103';
      final handoff = await Directory(
        p.join(stock.root.path, 'handoff'),
      ).create();
      final originalGeneration = source.pin.generation;
      final exporting = TransferService(
        device: stock.device,
        rules: stock.rules,
        availableAssets: assets,
        current: () => source,
      );
      final session = await source.pin.unlock(TestFamily.pin);
      final ticket = await exporting.prepareExport(
        'migration',
        password,
        session,
      );
      final outbound = await ticket.file.copy(p.join(handoff.path, ticket.name));
      await exporting.finishExport(ticket, SaveOutcome.handedToSystem);
      expect(source.frozen, isTrue);
      expect((await exporting.status())['state'], 'AWAITING_FILE_VERIFICATION');
      await expectLater(
        exporting.endMigration(archive: true, session: session),
        throwsA(isA<UserError>()),
      );
      await exporting.verifyExternal(outbound, password, session);
      expect((await exporting.status())['state'], 'MIGRATION_PENDING');
      await expectLater(
        source.stampRainMap(run: 2, group: 0),
        throwsA(isA<UserError>()),
      );
      await expectLater(
        source.recordCompanionMoment(Companion.fox, CompanionMoment.touch),
        throwsA(isA<UserError>()),
      );
      await expectLater(
        source.approve(pending, source.today, '', session: session),
        throwsA(isA<UserError>()),
      );
      FamilyService? targetFamily;
      final targetDevice = DeviceStore(
        Directory(p.join(stock.root.path, 'new-device')),
        MemorySecureValues(),
      );
      final target = TransferService(
        device: targetDevice,
        rules: stock.rules,
        availableAssets: assets,
        current: () => targetFamily,
      );
      final preview = await target.inspect(outbound, password, null);
      addTearDown(preview.close);
      final restored = (await target.activate(
        preview,
        targetPin,
        PinGate.newRecoveryCode(),
        session: null,
        replace: false,
      )).service;
      targetFamily = restored;
      addTearDown(restored.close);
      final family = (await restored.overview())!;
      final progress = await restored.rainMapProgress();
      expect(
        (family.balance, family.experience, family.stage, family.companion),
        (first.balance, first.experience, first.stage, Companion.fox),
      );
      expect((family.bond.label, family.rainMapCleared), ('默契', true));
      expect(
        (
          progress.run,
          progress.stones,
          progress.stamps,
          progress.challengeSolved,
        ),
        (2, 1, 0, true),
      );
      expect(await restored.ledger(), ledger);
      expect(await restored.items(), items);
      expect(await restored.furnishings(room), furnishings);
      expect(await restored.wardrobe(Companion.fox), wardrobe);
      expect(await restored.wish(), wish);
      expect((await restored.task(pending)).state, 'SUBMITTED');
      expect((await restored.windowMathBookmark()).pattern, {1, 3});
      final targetSnapshot = await checkSnapshot(
        targetDevice.databaseFile(restored.pin.generation).path,
        await target.schema,
        stock.rules,
        assets,
      );
      expect(targetSnapshot.businessDigest, preview.info.businessDigest);
      await expectLater(
        restored.pin.unlock(TestFamily.pin),
        throwsA(isA<UserError>()),
      );

      await exporting.endMigration(archive: true, session: session);
      await stock.reopen();
      source = stock.service;
      expect(source.pin.generation, originalGeneration);
      expect(source.frozen, isTrue);
      expect((await exporting.status())['state'], 'ARCHIVED');
      final archiveSession = await source.pin.unlock(TestFamily.pin);
      await expectLater(
        source.approve(pending, source.today, '', session: archiveSession),
        throwsA(isA<UserError>()),
      );

      await restored.selectCompanion(Companion.cat);
      expect((await restored.overview())!.bond.label, '熟悉');
      await restored.stepRainMapStone(run: 2, group: 0, stone: 1);
      final targetSession = await restored.pin.unlock(targetPin);
      await restored.approve(
        pending,
        restored.today,
        '测试反馈',
        session: targetSession,
      );
      final updatedLedger = await restored.ledger();
      expect(updatedLedger, hasLength(ledger.length + 1));
      expect(await source.ledger(), ledger);
      final returnTicket = await target.prepareExport(
        'migration',
        password,
        targetSession,
      );
      final inbound = await returnTicket.file.copy(
        p.join(handoff.path, returnTicket.name),
      );
      await target.finishExport(returnTicket, SaveOutcome.handedToSystem);
      await target.verifyExternal(inbound, password, targetSession);
      expect(restored.frozen, isTrue);
      await expectLater(
        restored.selectCompanion(Companion.fox),
        throwsA(isA<UserError>()),
      );

      final returned = await exporting.inspect(
        inbound,
        password,
        archiveSession,
      );
      addTearDown(returned.close);
      final sendingSnapshot = await checkSnapshot(
        targetDevice.databaseFile(restored.pin.generation).path,
        await target.schema,
        stock.rules,
        assets,
      );
      expect(returned.info.businessDigest, sendingSnapshot.businessDigest);
      await expectLater(
        exporting.activate(
          returned,
          returnedPin,
          PinGate.newRecoveryCode(),
          session: archiveSession,
          replace: true,
        ),
        throwsA(isA<UserError>()),
      );
      expect(await stock.device.activeGeneration(), originalGeneration);
      final protection = (await exporting.protectCurrent(archiveSession))!;
      final checkpoint = await exporting.inspectCheckpoint(
        protection.checkpoint,
        archiveSession,
      );
      addTearDown(checkpoint.close);
      expect(checkpoint.info.businessDigest, preview.info.businessDigest);
      final activation = await exporting.activate(
        returned,
        returnedPin,
        PinGate.newRecoveryCode(),
        session: archiveSession,
        replace: true,
        protection: protection,
      );
      await source.close();
      stock.service = activation.service;
      await stock.reopen();
      source = stock.service;
      final replacement = source;
      expect(replacement.pin.generation, isNot(originalGeneration));
      expect((await exporting.status())['state'], 'IDLE');
      expect(replacement.frozen, isFalse);
      await expectLater(
        replacement.pin.unlock(TestFamily.pin),
        throwsA(isA<UserError>()),
      );
      final newSession = await replacement.pin.unlock(returnedPin);
      final finalSnapshot = await checkSnapshot(
        stock.device.databaseFile(replacement.pin.generation).path,
        await exporting.schema,
        stock.rules,
        assets,
      );
      expect(finalSnapshot.businessDigest, sendingSnapshot.businessDigest);
      final reimport = await exporting.activate(
        returned,
        returnedPin,
        PinGate.newRecoveryCode(),
        session: newSession,
        replace: true,
      );
      expect(reimport.alreadyRestored, isTrue);
      expect(reimport.service, same(replacement));
      expect(await stock.device.activeGeneration(), replacement.pin.generation);
      final archived = await checkSnapshot(
        stock.device.databaseFile(originalGeneration).path,
        await exporting.schema,
        stock.rules,
        assets,
      );
      expect(archived.businessDigest, preview.info.businessDigest);
      await target.endMigration(archive: true, session: targetSession);
      expect((await target.status())['state'], 'ARCHIVED');
      final roundTrip = (await replacement.overview())!;
      expect(
        (roundTrip.companion, roundTrip.bond.label, roundTrip.rainMapCleared),
        (Companion.cat, '熟悉', true),
      );
      expect((await replacement.rainMapProgress()).totalStones, 2);
      expect(
        (roundTrip.balance, roundTrip.experience, roundTrip.stage),
        (7, 11, 3),
      );
      expect(await replacement.ledger(), updatedLedger);
      expect(await replacement.items(), items);
      expect(await replacement.furnishings(room), furnishings);
      expect(await replacement.wardrobe(Companion.fox), wardrobe);
      expect(await replacement.wish(), wish);
      expect((await replacement.task(pending)).state, 'APPROVED');
      await replacement.backfill(
        const TaskDraft('测试回迁后补录', '', '测试标准', 'light'),
        replacement.today,
        '测试反馈',
        session: newSession,
      );
      final continued = (await replacement.overview())!;
      expect((continued.balance, continued.experience), (9, 12));
      expect(await restored.ledger(), updatedLedger);
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );

  testWidgets('closed task details load in Growth and in the completed list', (
    tester,
  ) async {
    final stock = (await tester.runAsync(TestFamily.create))!;
    addTearDown(stock.dispose);
    final controller = FamilyController(stock.device, stock.rules)
      ..service = stock.service;
    addTearDown(controller.dispose);
    await tester.runAsync(() async {
      final parent = await stock.service.pin.unlock(TestFamily.pin);
      await stock.service.backfill(
        const TaskDraft('测试成果A', '测试详情A', '测试标准A', 'focus'),
        stock.service.today,
        '测试反馈A',
        session: parent,
      );
      await controller.refresh();
    });
    expect(controller.currentTasks, isEmpty);
    expect(controller.family!.taskCount, 1);

    await tester.pumpWidget(CompanionsApp(controller: controller));
    await tester.tap(find.text('成长').hitTestable());
    await tester.pump();
    expect(find.text('成长记录'), findsOneWidget);
    await waitFor(tester, find.text('测试反馈A'));
    expect(find.text('测试详情A'), findsOneWidget);
    expect(find.text('测试标准A'), findsOneWidget);

    await tester.tap(find.text('小事').hitTestable());
    await tester.pump();
    expect(find.text('这里还没有待完成的小事。'), findsOneWidget);
    await tester.tap(find.text('已完成'));
    await tester.pump();
    final title = find.text('测试成果A');
    await waitFor(tester, title);
    await tester.tap(title.hitTestable());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await waitFor(tester, find.text('测试反馈A'));
    expect(find.text('测试标准A'), findsOneWidget);
    expect((controller.family!.balance, controller.family!.experience), (3, 1));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('an open task detail reflects expiry after a calendar refresh', (
    tester,
  ) async {
    var clock = DateTime.utc(2026, 11, 18);
    final stock = (await tester.runAsync(() => TestFamily.create(now: () => clock)))!;
    addTearDown(stock.dispose);
    final controller = FamilyController(stock.device, stock.rules)
      ..service = stock.service;
    addTearDown(controller.dispose);
    await tester.runAsync(() async {
      final parent = await stock.service.pin.unlock(TestFamily.pin);
      await stock.service.publish(
        TaskDraft('测试限期小事', '', '测试标准', 'light', due: stock.service.today),
        session: parent,
      );
      await controller.refresh();
    });
    await tester.pumpWidget(CompanionsApp(controller: controller));
    await tester.tap(find.text('小事').hitTestable());
    await tester.pump();
    await tester.tap(find.text('测试限期小事').hitTestable());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('我完成了'), findsOneWidget);

    clock = clock.add(const Duration(days: 1));
    await tester.runAsync(controller.refresh);
    await tester.pump();
    expect(find.text('我完成了'), findsNothing);
    await waitFor(tester, find.text('已到期'));
    expect(find.text('测试标准'), findsOneWidget);
    expect(controller.family!.balance, 0);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the real home interaction writes a memory visible in Growth', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final stock = (await tester.runAsync(TestFamily.create))!;
    addTearDown(stock.dispose);
    final controller = FamilyController(
      stock.device,
      stock.rules,
      assets: assets,
    )..service = stock.service;
    addTearDown(controller.dispose);
    await tester.runAsync(controller.refresh);
    await tester.pumpWidget(CompanionsApp(controller: controller));
    await tester.pump(const Duration(milliseconds: 80));
    await tester.runAsync(() => tester.tap(find.text('摸摸桃桃').hitTestable()));
    await tester.runAsync(() async {
      for (
        var attempt = 0;
        attempt < 40 && controller.family?.bond.touched != true;
        attempt++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    });
    await tester.pump();
    expect(controller.family?.bond.label, '熟悉');
    await tester.runAsync(() => tester.tap(find.text('过来').hitTestable()));
    await tester.runAsync(() async {
      for (
        var attempt = 0;
        attempt < 40 && controller.family?.bond.called != true;
        attempt++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    });
    await tester.pump();
    expect(controller.family?.bond.label, '默契');
    expect((controller.family?.balance, controller.family?.experience), (0, 0));
    await tester.tap(find.text('成长').hitTestable());
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('亲密度 · 默契'), findsOneWidget);
    await tester.ensureVisible(find.text('伙伴回忆'));
    await tester.tap(find.text('伙伴回忆').hitTestable());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('第一次摸摸桃桃'), findsOneWidget);
    expect(find.text('第一次叫桃桃过来'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the mainline opens the map and resumes at its saved scene', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final stock = (await tester.runAsync(TestFamily.create))!;
    addTearDown(stock.dispose);
    final controller = FamilyController(
      stock.device,
      stock.rules,
      assets: assets,
    )..service = stock.service;
    addTearDown(controller.dispose);
    await tester.runAsync(() async {
      await stock.service.saveWindowMathBookmark(WindowPage.finished, {1, 3});
      await stock.service.beginRainMap();
      await stock.service.stepRainMapStone(run: 1, group: 0, stone: 0);
      await controller.refresh();
    });
    await tester.pumpWidget(CompanionsApp(controller: controller));
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(find.text('主线').hitTestable());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.runAsync(
      () => tester.tap(find.text(rainMapTitle).hitTestable()),
    );
    await tester.pump();
    final next = find.byKey(const ValueKey('rain-map-stone-1'));
    await waitFor(tester, next);
    expect(find.text('和奶油出发'), findsNothing);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.ensureVisible(next);
    await tester.runAsync(() => tester.tap(next.hitTestable()));
    final progress = await tester.runAsync(() async {
      var value = await stock.service.rainMapProgress();
      for (var attempt = 0; attempt < 40 && value.stones != 2; attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        value = await stock.service.rainMapProgress();
      }
      return value;
    });
    expect(progress?.totalStones, 2);
    await tester.pumpWidget(const SizedBox());
  });
}
