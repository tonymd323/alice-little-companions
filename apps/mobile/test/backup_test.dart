import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:alice_companions/application/family.dart';
import 'package:alice_companions/application/transfer.dart';
import 'package:alice_companions/data/checkpoints.dart';
import 'package:alice_companions/data/database.dart';
import 'package:alice_companions/data/device.dart';
import 'package:alice_companions/data/snapshot.dart';
import 'package:alice_companions/domain/backup_codec.dart';
import 'package:alice_companions/domain/companion_badge.dart';
import 'package:alice_companions/domain/companion_bond.dart';
import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/domain/pin.dart';
import 'package:alice_companions/domain/rules.dart';
import 'package:alice_companions/domain/window_page.dart';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'support/families.dart';

const codec = BackupCodec();
final vectorBook = jsonDecode(
  File('../../fixtures/migration_roundtrip.json').readAsStringSync(),
) as Json;
final formatVector = vectorBook['codec_vector'] as Json;
final password = formatVector['passphrase'] as String;
final assets =
    (jsonDecode(File('assets/config/runtime_assets.json').readAsStringSync())
            as Json)
        .entries
        .where((item) => File(item.value as String).existsSync())
        .map((entry) => entry.key)
        .toSet();
final pin = 739184.toString();
const fixtureDraft = TaskDraft('测试任务A', '测试内容', '测试标准A', 'focus');
const dropV7AndLater = '${dropCompanionTables}DROP TABLE companion_memories; DROP TABLE rain_map_runs; ';

TransferService transfers(TestFamily fixture, {Set<String>? withAssets}) =>
    TransferService(
      device: fixture.device,
      rules: fixture.rules,
      availableAssets: withAssets ?? assets,
      current: () => fixture.service,
    );

Uint8List hex(String value) => Uint8List.fromList(
  List.generate(
    value.length ~/ 2,
    (i) => int.parse(value.substring(i * 2, i * 2 + 2), radix: 16),
  ),
);

Future<void> fails(Future<Object?> operation) async =>
    expectLater(operation, throwsA(isA<UserError>()));

void main() {
  test(
    'AC-23/24/28 ALICEBK1 exact published vector and authentication failures',
    () async {
      final header = utf8.encode(formatVector['header_utf8'] as String);
      final expected = BytesBuilder()
        ..add(ascii.encode('ALICEBK1'))
        ..add(
          (ByteData(
            4,
          )..setUint32(0, header.length, Endian.big)).buffer.asUint8List(),
        )
        ..add(header)
        ..add(hex(formatVector['ciphertext_hex'] as String))
        ..add(hex(formatVector['tag_hex'] as String));
      final payload = hex(formatVector['payload_hex'] as String);
      final seal = await codec.encryptPayload(
        payload,
        password,
        salt: List.generate(16, (i) => i),
        nonce: List.generate(12, (i) => i + 16),
      );
      expect(seal, expected.toBytes());
      expect(sha256.convert(seal).toString(), formatVector['container_sha256']);
      expect(await codec.decryptPayload(seal, password), payload);
      await fails(codec.decryptPayload(seal, password.trim()));
      await fails(
        codec.decryptPayload(
          Uint8List.sublistView(seal, 0, seal.length - 1),
          password,
        ),
      );
      await fails(
        codec.decryptPayload(
          Uint8List.fromList(seal)..[seal.length - 1] ^= 1,
          password,
        ),
      );
      final headerLimit = Uint8List.fromList(seal);
      ByteData.sublistView(headerLimit).setUint32(8, 4097);
      await fails(codec.decryptPayload(headerLimit, password));
      Uint8List replaceHeader(String from, String to) {
        final text = utf8.decode(header).replaceFirst(from, to);
        return Uint8List.fromList([
          ...seal.sublist(0, 12),
          ...utf8.encode(text),
          ...seal.sublist(12 + header.length),
        ]);
      }

      await fails(
        codec.decryptPayload(
          replaceHeader('"format_version":1', '"format_version":8'),
          password,
        ),
      );
      await fails(
        codec.decryptPayload(replaceHeader('600000', '6000000'), password),
      );
    },
  );

  test('AC-22/27/28/31 fixed 37-point replica, freeze, fresh credentials and reward to 42', () async {
    final clock = DateTime.utc(2026, 11, 18);
    final source = await TestFamily.create(now: () => clock);
    addTearDown(source.dispose);
    final s = source.service;
    final parent = await s.pin.unlock(TestFamily.pin);
    final fixture = vectorBook['domain_fixture'] as Json;
    for (final day in (fixture['reward_days'] as List).cast<Json>()) {
      final types = (day['approved_task_types'] as List)
          .cast<String>()
          .toList();
      if (day['actual_date'] == '2024-01-08') {
        types.remove('focus');
        await s.publishProject(fixtureDraft, [
          const StageDraft('测试阶段A', '测试标准A', 'focus'),
          const StageDraft('测试阶段B', '测试标准B', 'challenge'),
        ], session: parent);
        final first = (await s.tasks()).singleWhere(
          (task) => task.state == 'OPEN',
        );
        await s.submit(first.id, '');
        await s.approve(first.id, '2024-01-08', '测试阶段反馈', session: parent);
      }
      for (final type in types) {
        await s.backfill(
          TaskDraft('测试任务A', '测试内容', '测试标准', type),
          day['actual_date'] as String,
          '测试反馈',
          session: parent,
        );
      }
    }
    await s.publish(
      const TaskDraft('测试任务A', '', '测试A', 'light'),
      session: parent,
    );
    final pending =
        (await s.publish(
              const TaskDraft('测试任务B', '', '测试B', 'challenge'),
              session: parent,
            ))['instance_id']
            as String;
    await s.submit(pending, '');
    for (final item
        in (fixture['purchased_catalog_ids'] as List).cast<String>()) {
      await s.purchase(item);
    }
    await s.setWish('single_armchair');
    final items = await s.items();
    final space = (await s.spaces()).single;
    expect(
      (await s.wardrobe(Companion.rabbit)).single['entitlement_id'],
      items.singleWhere((item) => item['item_id'] == 'accessory_scarf')['id'],
    );
    await s.db.insertRow('placements', {
      'space_id': space['id'],
      'entitlement_id': items.singleWhere(
        (item) => item['item_id'] == 'decor_plant',
      )['id'],
      'x': .3,
      'y': .8,
      'z': 1,
    });
    await s.saveWindowMathBookmark(WindowPage.finished, {4, 0});
    final outgoing = transfers(source);
    await fails(outgoing.prepareExport('migration', password, null));
    final outgoingFile = outgoing.prepareExport('migration', password, parent);
    final tryingWrite = fails(s.selectCompanion(source.rules.companion('cat')));
    final ticket = await outgoingFile;
    await tryingWrite;
    await outgoing.finishExport(ticket, SaveOutcome.handedToSystem);
    expect((await outgoing.status())['state'], 'AWAITING_FILE_VERIFICATION');
    await source.reopen(now: () => clock);
    final oldOwner = await source.service.pin.unlock(TestFamily.pin);
    expect(source.service.frozen, isTrue);
    await fails(source.service.saveWindowMathBookmark(WindowPage.count, {}));
    await fails(
      source.service.approve(pending, '2024-01-16', '', session: oldOwner),
    );
    await fails(source.service.purchase('accessory_hat'));
    await outgoing.verifyExternal(ticket.file, password, oldOwner);
    expect((await outgoing.status())['state'], 'MIGRATION_PENDING');

    final targetDir = await Directory.systemTemp.createTemp('alice-target-');
    addTearDown(() => targetDir.delete(recursive: true));
    final targetDevice = DeviceStore(targetDir, MemorySecureValues());
    FamilyService? target;
    addTearDown(() async => target?.close());
    final incoming = TransferService(
      device: targetDevice,
      rules: source.rules,
      availableAssets: assets,
      current: () => target,
    );
    final preview = await incoming.inspect(ticket.file, password, null);
    addTearDown(preview.close);
    expect(preview.info.summary, {
      'balance': 37,
      'ledger_count': 22,
      'valid_completion_count': 17,
      'owned_item_count': 5,
      'space_count': 1,
      'max_growth_stage': 3,
      'owned_companion_count': 1,
      'active_companion_experience': 17,
    });
    // Encode the original 0.12 shape as a separate authenticated archive. It
    // reported stage 2 on four actual dates, despite having 17 valid outcomes.
    final oldDb = await preview.database.copy(
      p.join(targetDir.path, 'legacy.sqlite'),
    );
    final legacySql = sqlite3.open(oldDb.path);
    legacySql.execute(
      '${dropV7AndLater}DROP TABLE wind_story_runs; DROP TABLE window_story_milestones; '
      'INSERT INTO growth_awards SELECT id, 3, 2, 0 FROM child_profiles; PRAGMA user_version=3',
    );
    legacySql.close();
    final legacyInfo = await checkSnapshot(
      oldDb.path,
      await expectedSchema(),
      source.rules,
      assets,
    );
    expect(legacyInfo.summary['max_growth_stage'], 2);
    final legacyArchive = File(p.join(targetDir.path, 'legacy.alicebackup'));
    await codec.write(
      oldDb,
      {...preview.manifest, 'schema_version': 3, 'summary': legacyInfo.summary},
      password,
      legacyArchive,
    );
    final legacyPreview = await incoming.inspect(legacyArchive, password, null);
    addTearDown(legacyPreview.close);
    expect(legacyPreview.info.summary['balance'], 37);
    expect(legacyPreview.info.summary['valid_completion_count'], 17);
    expect(legacyPreview.info.summary['max_growth_stage'], 2);
    final legacyDevice = DeviceStore(
      Directory(p.join(targetDir.path, 'legacy-device')),
      MemorySecureValues(),
    );
    final legacyTarget = TransferService(
      device: legacyDevice,
      rules: source.rules,
      availableAssets: assets,
      current: () => null,
    );
    final migrated = await legacyTarget.activate(
      legacyPreview,
      pin,
      PinGate.newRecoveryCode(),
      session: null,
      replace: false,
    );
    addTearDown(migrated.service.close);
    final oldFamily = (await migrated.service.overview())!;
    expect(
      (
        oldFamily.balance,
        oldFamily.stage,
        oldFamily.days,
        oldFamily.experience,
        oldFamily.companion.name,
      ),
      (37, 3, 4, 17, 'rabbit'),
    );
    final oldAfter = await checkSnapshot(
      legacyDevice.databaseFile(migrated.service.pin.generation).path,
      await expectedSchema(),
      source.rules,
      assets,
      compareWithSchemaVersion: legacyInfo.schemaVersion,
    );
    expect(oldAfter.businessDigest, legacyInfo.businessDigest);
    final restored = await incoming.activate(
      preview,
      pin,
      PinGate.newRecoveryCode(),
      session: null,
      replace: false,
    );
    target = restored.service;
    final chapter = await target.windowMathBookmark();
    expect(chapter.page, WindowPage.finished);
    expect(chapter.pattern, {0, 4});
    expect((await target.overview())!.windowsLit, isTrue);
    final restoredSnapshot = (await target.overview())!;
    expect(
      (
        restoredSnapshot.balance,
        restoredSnapshot.stage,
        restoredSnapshot.days,
        restoredSnapshot.experience,
        restoredSnapshot.companion.name,
      ),
      (37, 3, 4, 17, 'rabbit'),
    );
    expect((await target.wish())!['item_id'], 'single_armchair');
    expect(await target.db.value('SELECT COUNT(*) FROM placements'), 1);
    expect(await target.db.value('SELECT COUNT(*) FROM pet_state'), 1);
    await fails(target.pin.unlock(TestFamily.pin));
    final targetParent = await target.pin.unlock(pin);
    expect(
      await targetDevice.secure.read(
        'alice.pin.${source.service.pin.generation}',
      ),
      isNull,
    );
    final repeated = await incoming.activate(
      preview,
      pin,
      PinGate.newRecoveryCode(),
      session: targetParent,
      replace: true,
    );
    expect(repeated.alreadyRestored, isTrue);
    await target.approve(pending, '2024-01-16', '', session: targetParent);
    expect((await target.overview())!.balance, 42);
    await fails(
      incoming.activate(
        preview,
        pin,
        PinGate.newRecoveryCode(),
        session: targetParent,
        replace: true,
      ),
    );
    expect((await source.service.overview())!.balance, 37);
  }, timeout: const Timeout(Duration(minutes: 4)));

  test('snapshot rejects a balanced reward without a matching completion', () async {
    final stock = await TestFamily.create();
    addTearDown(stock.dispose);
    final owner = await stock.service.pin.unlock(TestFamily.pin);
    await stock.service.backfill(
      fixtureDraft,
      stock.service.today,
      '',
      session: owner,
    );
    final snapshot = p.join(stock.root.path, 'stray-credit.sqlite');
    await vacuumFile(
      stock.device.databaseFile(stock.service.pin.generation).path,
      snapshot,
    );
    final schema = await expectedSchema();
    final valid = await checkSnapshot(snapshot, schema, stock.rules, assets);
    expect(valid.summary['ledger_count'], 1);
    final exportInfo = await validateSnapshot(
      snapshot,
      schema,
      stock.rules,
      assets,
    );
    expect(exportInfo.summary, valid.summary);

    final db = sqlite3.open(snapshot);
    try {
      db.execute('''
        INSERT INTO ledger_entries (
          id, account_id, delta, balance_after, kind, source_key, actual_date,
          posted_day, created_at, command_id
        )
        SELECT 'stray-credit', account_id, delta, balance_after + delta,
               kind, source_key || ':unexpected', actual_date, posted_day,
               created_at, 'stray-credit-command'
        FROM ledger_entries WHERE kind = 'reward';
        UPDATE accounts SET balance = balance * 2;
      ''');
    } finally {
      db.close();
    }

    final invalidLinks = throwsA(
      isA<UserError>().having(
        (error) => error.message,
        'message',
        '存档的成果、兑换或布置关联校验失败。',
      ),
    );
    await expectLater(
      checkSnapshot(snapshot, schema, stock.rules, assets),
      invalidLinks,
    );
    await expectLater(
      validateSnapshot(snapshot, schema, stock.rules, assets),
      invalidLinks,
    );
  });

  test('0.10 family upgrades with an empty chapter, keeps its ledger and restores the bookmark on restart', () async {
    final stock = await TestFamily.create();
    addTearDown(stock.dispose);
    final owner = await stock.service.pin.unlock(TestFamily.pin);
    await stock.service.backfill(
      fixtureDraft,
      stock.service.today,
      '',
      session: owner,
    );
    final id = (await stock.device.activeGeneration())!;
    final file = stock.device.databaseFile(id);
    await stock.service.close();
    final legacy = sqlite3.open(file.path);
    legacy.execute(
      '${dropV7AndLater}DROP TABLE wind_story_runs; DROP TABLE window_story_milestones; DROP TABLE window_math_bookmarks; PRAGMA user_version = 2',
    );
    legacy.close();
    final schema = await expectedSchema();
    final before = await checkSnapshot(file.path, schema, stock.rules, assets);
    expect(before.schemaVersion, 2);
    stock.service = await FamilyService.load(stock.device, id, stock.rules);
    final service = stock.service;
    final after = await checkSnapshot(file.path, schema, stock.rules, assets, compareWithSchemaVersion: before.schemaVersion);
    expect(after.schemaVersion, currentSchemaVersion);
    expect(after.businessDigest, before.businessDigest);
    expect(after.summary, {...before.summary, 'owned_companion_count': 1, 'active_companion_experience': 1});
    expect(await CheckpointStore(stock.device).files(), hasLength(1));
    final first = await service.windowMathBookmark();
    expect(first.page, WindowPage.count);
    expect(first.pattern, isEmpty);
    await fails(service.saveWindowMathBookmark(WindowPage.finished, {0, 5}));
    await fails(service.saveWindowMathBookmark(WindowPage.missing, {1}));
    await service.saveWindowMathBookmark(WindowPage.finished, {1, 3});
    await stock.reopen();
    final saved = await stock.service.windowMathBookmark();
    expect(saved.page, WindowPage.finished);
    expect(saved.pattern, {1, 3});
    expect((await stock.service.overview())!.balance, 3);
    expect(await stock.service.ledger(), hasLength(1));
    final current = await checkSnapshot(file.path, schema, stock.rules, assets, compareWithSchemaVersion: before.schemaVersion);
    expect(current.businessDigest, isNot(after.businessDigest));
    expect(current.summary, after.summary);
  });

  test('a v8 encrypted backup restores first memories and allows new affinity', () async {
    final stock = await TestFamily.create(pet: Companion.cat);
    addTearDown(stock.dispose);
    final service = stock.service;
    final parent = await service.pin.unlock(TestFamily.pin);
    await service.backfill(fixtureDraft, service.today, '', session: parent);
    await service.recordCompanionMoment(Companion.cat, CompanionMoment.touch);
    await service.recordCompanionMoment(Companion.cat, CompanionMoment.call);
    final outgoing = transfers(stock);
    final ticket = await outgoing.prepareExport('backup', password, parent);
    await outgoing.finishExport(ticket, SaveOutcome.handedToSystem);

    final device = DeviceStore(
      Directory(p.join(stock.root.path, 'affinity-target')),
      MemorySecureValues(),
    );
    final incoming = TransferService(
      device: device,
      rules: stock.rules,
      availableAssets: assets,
      current: () => null,
    );
    final current = await incoming.inspect(ticket.file, password, null);
    addTearDown(current.close);
    final oldDb = await current.database.copy(
      p.join(stock.root.path, 'v8.sqlite'),
    );
    final sql = sqlite3.open(oldDb.path);
    try {
      sql.execute(
        "${dropAffinityTables}DELETE FROM processed_commands WHERE id LIKE 'affinity/%'; PRAGMA user_version=8",
      );
    } finally {
      sql.close();
    }
    final schema = await expectedSchema();
    final oldInfo = await checkSnapshot(
      oldDb.path,
      schema,
      service.rules,
      assets,
    );
    final archive = File(p.join(stock.root.path, 'v8.alicebackup'));
    await codec.write(
      oldDb,
      {
        ...current.manifest,
        'schema_version': oldInfo.schemaVersion,
        'summary': oldInfo.summary,
      },
      password,
      archive,
    );
    final preview = await incoming.inspect(archive, password, null);
    addTearDown(preview.close);
    final restored = (await incoming.activate(
      preview,
      pin,
      PinGate.newRecoveryCode(),
      session: null,
      replace: false,
    )).service;
    addTearDown(restored.close);
    final saved = (await restored.overview())!;
    expect(saved.memories, CompanionMoment.values.toSet());
    expect(
      (saved.bond.value, saved.bond.label, saved.experience, saved.balance),
      (2, '默契', 1, 3),
    );
    expect(
      await restored.recordCompanionMoment(
        Companion.cat,
        CompanionMoment.touch,
      ),
      3,
    );
    expect((await restored.overview())!.bond.value, 3);
    expect(
      await restored.recordCompanionMoment(
        Companion.cat,
        CompanionMoment.touch,
      ),
      isNull,
    );
    expect(await restored.ledger(), await service.ledger());
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('candy transactions and an encrypted restore keep stock and affinity separate', () async {
    final stock = await TestFamily.create(pet: Companion.cat);
    addTearDown(stock.dispose);
    final service = stock.service;
    final parent = await service.pin.unlock(TestFamily.pin);
    await fails(service.redeemAffinityCandy());
    final last = await service.backfill(
      const TaskDraft('测试奖励', '', '测试标准', 'challenge'),
      service.today,
      '',
      session: parent,
    );
    for (var index = 0; index < 7; index++) {
      await service.backfill(
        const TaskDraft('测试任务A', '', '测试标准', 'challenge'),
        service.today,
        '',
        session: parent,
      );
    }
    await service.unlockCompanion(Companion.fox);
    final repeated = await Future.wait([
      service.redeemAffinityCandy(commandId: 'test-candy-once'),
      service.redeemAffinityCandy(commandId: 'test-candy-once'),
    ]);
    expect(repeated.first, repeated.last);
    final fed = repeated.first['id'] as String;
    final held = (await service.redeemAffinityCandy())['id'] as String;
    final cancelled = (await service.redeemAffinityCandy())['id'] as String;
    expect((await service.availableAffinityCandy())?.count, 3);
    expect((await service.overview())!.balance, 1);
    await fails(service.redeemAffinityCandy());
    await fails(service.feedAffinityCandy(fed, Companion.fox));
    final ledger = await service.ledger();
    final results = await Future.wait([
      service.feedAffinityCandy(fed, Companion.cat),
      service.feedAffinityCandy(fed, Companion.cat),
    ]);
    expect(results.map((row) => row['affinity']), [3, 3]);
    expect(results.map((row) => row['previous_affinity']), [0, 0]);
    expect(CompanionBadge.affinityReached(0, 3).map((badge) => badge.name), [
      '熟悉',
      '默契',
    ]);
    expect((await service.overview())!.bond.value, 3);
    expect(await service.ledger(), ledger);
    final quote = await service.correctionQuote(
      last['instance_id'] as String,
      [],
      parent,
    );
    expect(
      quote.related.map((row) => row['id']),
      unorderedEquals([held, cancelled]),
    );
    await fails(service.refund(fed, session: parent));
    await service.refund(cancelled);
    expect((await service.availableAffinityCandy())?.id, held);
    expect((await service.overview())!.balance, 4);
    await service.selectCompanion(Companion.fox);
    expect((await service.overview())!.bond.value, 0);

    final outgoing = transfers(stock);
    final ticket = await outgoing.prepareExport('backup', password, parent);
    await outgoing.finishExport(ticket, SaveOutcome.handedToSystem);
    final incoming = TransferService(
      device: DeviceStore(
        Directory(p.join(stock.root.path, 'candy-target')),
        MemorySecureValues(),
      ),
      rules: stock.rules,
      availableAssets: assets,
      current: () => null,
    );
    final preview = await incoming.inspect(ticket.file, password, null);
    addTearDown(preview.close);
    final restored = (await incoming.activate(
      preview,
      pin,
      PinGate.newRecoveryCode(),
      session: null,
      replace: false,
    )).service;
    addTearDown(restored.close);
    final progress = await restored.companionProgress();
    expect(
      (
        progress[Companion.cat]!.bond.value,
        progress[Companion.cat]!.experience,
      ),
      (3, 8),
    );
    expect(
      (
        progress[Companion.fox]!.bond.value,
        progress[Companion.fox]!.experience,
      ),
      (0, 0),
    );
    final catalog = CompanionBadge.evolutions.followedBy(
      CompanionBadge.affinities,
    );
    expect(
      catalog
          .where(
            (badge) => badge.isEarned(
              stage: progress[Companion.cat]!.stage,
              affinity: progress[Companion.cat]!.bond.value,
            ),
          )
          .map((badge) => badge.name),
      ['小小成长', '熟悉', '默契'],
    );
    expect(
      catalog.any(
        (badge) => badge.isEarned(
          stage: progress[Companion.fox]!.stage,
          affinity: progress[Companion.fox]!.bond.value,
        ),
      ),
      isFalse,
    );
    expect(await restored.availableAffinityCandy(), (
      id: held,
      affinity: 3,
      count: 1,
    ));
    expect(await restored.ledger(), await service.ledger());
    await restored.feedAffinityCandy(held, Companion.fox);
    expect((await restored.overview())!.bond.value, 3);
    expect(await restored.availableAffinityCandy(), isNull);
    expect(await restored.ledger(), await service.ledger());
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('Wind scene survives a v5 upgrade and partial encrypted handoff independently of the old chapter', () async {
    final stock = await TestFamily.create();
    addTearDown(stock.dispose);
    await stock.service.saveWindowMathBookmark(WindowPage.finished, {0, 4});
    final generation = stock.service.pin.generation;
    final file = stock.device.databaseFile(generation);
    await stock.service.close();
    final legacy = sqlite3.open(file.path);
    legacy.execute(
      '${dropV7AndLater}DROP TABLE wind_story_runs; PRAGMA user_version=5',
    );
    legacy.close();
    final schema = await expectedSchema();
    final old = await checkSnapshot(file.path, schema, stock.rules, assets);
    final oldFile = File(p.join(stock.root.path, 'v5.sqlite'));
    await vacuumFile(file.path, oldFile.path);
    stock.service = await FamilyService.load(
      stock.device,
      generation,
      stock.rules,
    );
    final upgraded = await checkSnapshot(
      file.path,
      schema,
      stock.rules,
      assets,
      compareWithSchemaVersion: old.schemaVersion,
    );
    expect(upgraded.businessDigest, old.businessDigest);
    expect(upgraded.summary, {...old.summary, 'owned_companion_count': 1, 'active_companion_experience': 0});
    expect((await stock.service.overview())!.windowsLit, isTrue);
    expect((await stock.service.windProgress()).started, isFalse);
    expect((await stock.service.windowMathBookmark()).pattern, {0, 4});

    final run = (await stock.service.beginWindStory()).run;
    await stock.service.placeWindLeaf(3, run: run);
    await stock.service.placeWindLeaf(1, run: run);
    final outgoing = transfers(stock);
    final owner = await stock.service.pin.unlock(TestFamily.pin);
    final ticket = await outgoing.prepareExport('migration', password, owner);
    await outgoing.finishExport(ticket, SaveOutcome.handedToSystem);
    await stock.reopen();
    expect(stock.service.frozen, isTrue);
    await fails(stock.service.placeWindLeaf(2, run: run));
    await fails(stock.service.beginWindStory());
    await fails(stock.service.replayWindStory(run: run));

    final nextDevice = DeviceStore(
      Directory(p.join(stock.root.path, 'wind-target')),
      MemorySecureValues(),
    );
    final incoming = TransferService(
      device: nextDevice,
      rules: stock.rules,
      availableAssets: assets,
      current: () => null,
    );
    final preview = await incoming.inspect(ticket.file, password, null);
    addTearDown(preview.close);
    final oldArchive = File(p.join(stock.root.path, 'v5.alicebackup'));
    await codec.write(
      oldFile,
      {
        ...preview.manifest,
        'schema_version': 5,
        'summary': old.summary,
        'snapshot_revision': old.revision,
      },
      password,
      oldArchive,
    );
    final oldPreview = await incoming.inspect(oldArchive, password, null);
    addTearDown(oldPreview.close);
    expect(oldPreview.info.businessDigest, old.businessDigest);
    expect(oldPreview.info.schemaVersion, 5);

    // Install the imported v5 household into a fresh destination with the
    // production activation path, then continue the original v6 handoff.
    final oldDestination = TransferService(
      device: DeviceStore(
        Directory(p.join(stock.root.path, 'legacy-target')),
        MemorySecureValues(),
      ),
      rules: stock.rules,
      availableAssets: assets,
      current: () => null,
    );
    final oldRestored = (await oldDestination.activate(
      oldPreview,
      pin,
      PinGate.newRecoveryCode(),
      session: null,
      replace: false,
    )).service;
    try {
      expect((await oldRestored.windProgress()).started, isFalse);
      expect((await oldRestored.overview())!.windowsLit, isTrue);
      expect((await oldRestored.windowMathBookmark()).pattern, {0, 4});
    } finally {
      await oldRestored.close();
    }
    final restored = (await incoming.activate(
      preview,
      pin,
      PinGate.newRecoveryCode(),
      session: null,
      replace: false,
    )).service;
    addTearDown(restored.close);
    final partial = await restored.windProgress();
    expect((partial.run, partial.mask, partial.remaining), (1, 10, 3));
    expect((await restored.windowMathBookmark()).pattern, {0, 4});
    for (final slot in [0, 2, 4]) {
      await restored.placeWindLeaf(slot, run: partial.run);
    }
    expect((await restored.windProgress()).complete, isTrue);
    final family = (await restored.overview())!;
    expect(
      (family.windowsLit, family.balance, family.experience),
      (true, 0, 0),
    );
    expect(await restored.ledger(), isEmpty);
    expect((await stock.service.windProgress()).mask, 10);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('AC-24/25/26/32/33 invalid input and interrupted activation preserve generation', () async {
    final fixture = await TestFamily.create();
    addTearDown(fixture.dispose);
    final safe = transfers(fixture);
    final service = fixture.service;
    final parent = await service.pin.unlock(TestFamily.pin);
    await service.backfill(
      fixtureDraft,
      service.today,
      '测试反馈',
      session: parent,
    );
    final ticket = await safe.prepareExport('migration', password, parent);
    expect(service.frozen, isTrue);
    await safe.finishExport(ticket, SaveOutcome.cancelled);
    expect(service.frozen, isFalse);
    expect((await safe.status())['state'], 'IDLE');
    final backup = await safe.prepareExport('backup', password, parent);
    await safe.finishExport(backup, SaveOutcome.handedToSystem);
    expect((await safe.status())['last_verified_at'], isNull);
    final preview = await safe.inspect(backup.file, password, parent);
    addTearDown(preview.close);
    final active = await fixture.device.activeGeneration();
    final absentAsset = transfers(
      fixture,
      withAssets: {...assets}..remove('pet_cat_4_rest'),
    );
    await fails(absentAsset.inspect(backup.file, password, parent));
    await fails(safe.inspect(backup.file, 'incorrect password', parent));
    await fails(safe.inspect(backup.file, password, null));

    final invalid = File(p.join(fixture.root.path, 'invalid.alicebackup'));
    final unsafeZip = ZipEncoder().encode(
      Archive()
        ..addFile(ArchiveFile('../snapshot.sqlite', 1, [2]))
        ..addFile(ArchiveFile('manifest.json', 2, utf8.encode('{}'))),
    );
    await invalid.writeAsBytes(
      await codec.encryptPayload(Uint8List.fromList(unsafeZip), password),
    );
    await fails(safe.inspect(invalid, password, parent));
    final largeManifest = Uint8List(BackupCodec.maxManifest + 1);
    final largeZip = ZipEncoder().encode(
      Archive()
        ..addFile(ArchiveFile('snapshot.sqlite', 1, [2]))
        ..addFile(
          ArchiveFile('manifest.json', largeManifest.length, largeManifest),
        ),
    );
    await invalid.writeAsBytes(
      await codec.encryptPayload(Uint8List.fromList(largeZip), password),
    );
    await fails(safe.inspect(invalid, password, parent));

    final differentHash = utf8.encode(
      jsonEncode({'database_sha256': sha256.convert([1]).toString()}),
    );
    final differentSnapshotZip = ZipEncoder().encodeBytes(
      Archive()
        ..addFile(ArchiveFile('snapshot.sqlite', 1, [2]))
        ..addFile(
          ArchiveFile('manifest.json', differentHash.length, differentHash),
        ),
    );
    await invalid.writeAsBytes(
      await codec.encryptPayload(differentSnapshotZip, password),
    );
    await expectLater(
      codec.verify(invalid, password),
      throwsA(
        isA<UserError>().having(
          (error) => error.message,
          'message',
          '备份文件结构或摘要校验失败。',
        ),
      ),
    );
    final badVersion = File(p.join(fixture.root.path, 'future.sqlite'));
    await preview.database.copy(badVersion.path);
    final sql = sqlite3.open(badVersion.path);
    sql.userVersion = 98;
    sql.close();
    await codec.write(
      badVersion,
      {...preview.manifest, 'schema_version': 98},
      password,
      invalid,
    );
    await fails(safe.inspect(invalid, password, parent));
    expect(await fixture.device.activeGeneration(), active);
    expect((await service.overview())!.balance, 3);

    final blocked = File(p.join(fixture.root.path, 'checkpoints'));
    await blocked.writeAsString('fixture');
    await expectLater(
      safe.protectCurrent(parent),
      throwsA(isA<FileSystemException>()),
    );
    await blocked.delete();
    expect(await fixture.device.activeGeneration(), active);
    final protection = await safe.protectCurrent(parent);
    for (final phase in [
      'database',
      'credentials',
      'before_pointer',
      'after_pointer',
    ]) {
      final interrupted = TransferService(
        device: fixture.device,
        rules: fixture.rules,
        availableAssets: assets,
        current: () => service,
        fault: (at) {
          if (at == phase) throw StateError('simulated interruption');
        },
      );
      await expectLater(
        interrupted.activate(
          preview,
          pin,
          PinGate.newRecoveryCode(),
          session: parent,
          replace: true,
          protection: protection,
        ),
        throwsStateError,
      );
      final generation = (await fixture.device.activeGeneration())!;
      expect(generation == active, phase != 'after_pointer');
      final reloaded = await FamilyService.load(
        fixture.device,
        generation,
        fixture.rules,
      );
      expect((await reloaded.overview())!.balance, 3);
      expect(await reloaded.ledger(), hasLength(1));
      await reloaded.close();
    }
  }, timeout: const Timeout(Duration(minutes: 5)));

  test('AC-34 schema upgrade keeps balance, ownership and at most five encrypted restore points', () async {
    final stock = await TestFamily.create();
    addTearDown(stock.dispose);
    final parent = await stock.service.pin.unlock(TestFamily.pin);
    for (var i = 0; i < 4; i++) {
      await stock.service.backfill(
        fixtureDraft,
        stock.service.today,
        '',
        session: parent,
      );
    }
    await stock.service.purchase('accessory_hat');
    final id = (await stock.device.activeGeneration())!;
    await stock.service.close();
    final old = sqlite3.open(stock.device.databaseFile(id).path);
    old.execute(
      '${dropV7AndLater}DROP TABLE wind_story_runs; DROP TABLE window_story_milestones; DROP TABLE window_math_bookmarks; DROP TABLE base_furnishings; DROP INDEX ledger_day_kind_idx; DROP INDEX purchase_ledger_idx; PRAGMA user_version = 1',
    );
    old.close();
    stock.service = await FamilyService.load(stock.device, id, stock.rules);
    expect(
      await stock.service.db.value('PRAGMA user_version'),
      currentSchemaVersion,
    );
    expect((await stock.service.overview())!.balance, 0);
    expect(await stock.service.items(), hasLength(1));
    final backups = CheckpointStore(stock.device);
    expect(await backups.files(), hasLength(1));
    final checkpoint = (await backups.files()).single;
    final header = await checkpoint.openRead(0, 8).first;
    expect(utf8.decode(header), 'ALICECP1');
    for (var i = 0; i < 6; i++) {
      await backups.protectDatabase(stock.device.databaseFile(id));
    }
    expect(await backups.files(), hasLength(5));
  }, timeout: const Timeout(Duration(minutes: 2)));
}
