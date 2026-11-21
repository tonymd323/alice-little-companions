import 'dart:convert';
import 'dart:io';

import 'package:alice_companions/application/family.dart';
import 'package:alice_companions/data/snapshot.dart';
import 'package:alice_companions/domain/companion_badge.dart';
import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/domain/pin.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import 'support/families.dart';

void main() {
  test('unlock is charged once and experience follows the companion at confirmation', () async {
    final family = await TestFamily.create(pet: Companion.fox);
    addTearDown(family.dispose);
    final service = family.service;
    final parent = await service.pin.unlock(TestFamily.pin);
    const starter = Companion.fox;
    const newcomer = Companion.cat;
    const task = TaskDraft('测试小事', '', '测试标准', 'challenge');

    expect((await service.companionProgress()).keys, [starter]);
    await expectLater(
      service.selectCompanion(newcomer),
      throwsA(isA<UserError>()),
    );
    await expectLater(
      service.unlockCompanion(newcomer),
      throwsA(isA<UserError>()),
    );
    expect(await service.ledger(), isEmpty);

    final count = service.rules.companionUnlockPrice ~/ 5;
    for (var i = 0; i < count; i++) {
      await service.backfill(task, service.today, '', session: parent);
    }
    final submitted =
        (await service.publish(task, session: parent))['instance_id'] as String;
    await service.submit(submitted, '');
    final before = (await service.overview())!;
    final interrupted = FamilyService(
      service.db,
      service.pin,
      service.rules,
      fault: (phase) {
        if (phase == 'ownership') throw StateError('test interruption');
      },
    );
    await expectLater(interrupted.unlockCompanion(newcomer), throwsStateError);
    expect((await service.overview())!.balance, before.balance);
    expect(await service.purchases(), isEmpty);
    expect((await service.companionProgress()).keys, [starter]);

    final attempts = await Future.wait([
      service.unlockCompanion(newcomer, commandId: 'unlock-first'),
      service.unlockCompanion(newcomer, commandId: 'unlock-repeat'),
    ]);
    final [receipt, duplicate] = attempts;
    expect(receipt['charged'], service.rules.companionUnlockPrice);
    expect((duplicate['id'], duplicate['charged']), (receipt['id'], 0));
    expect((await service.purchases()).single['refundable'], 0);
    await expectLater(
      service.refund(receipt['id'] as String, session: parent),
      throwsA(isA<UserError>()),
    );
    final afterUnlock = (await service.overview())!;
    expect(
      (
        afterUnlock.companion,
        afterUnlock.balance,
        afterUnlock.experience,
        afterUnlock.stage,
      ),
      (starter, 0, 6, 2),
    );

    await service.selectCompanion(newcomer);
    final arrival = (await service.overview())!;
    expect(
      (arrival.experience, arrival.stage, arrival.validCompletionCount),
      (0, 1, 6),
    );
    await service.approve(submitted, service.today, '', session: parent);
    for (var i = 0; i < 2; i++) {
      await service.backfill(task, service.today, '', session: parent);
    }
    final grown = (await service.overview())!;
    expect(
      (grown.experience, grown.stage, grown.validCompletionCount),
      (3, 2, 9),
    );

    await service.selectCompanion(starter);
    final quote = await service.correctionQuote(submitted, [], parent);
    await service.correctAward(quote, '测试更正', false, session: parent);
    await family.reopen();
    final restored = family.service;
    final progress = await restored.companionProgress();
    expect((progress[starter]!.experience, progress[starter]!.stage), (6, 2));
    expect((progress[newcomer]!.experience, progress[newcomer]!.stage), (2, 2));
    final awards = CompanionBadge.evolutions.where(
      (badge) => badge.isEarned(
        stage: progress[newcomer]!.stage,
        affinity: progress[newcomer]!.bond.value,
      ),
    );
    expect(awards.map((badge) => badge.target), [2]);
    expect((await restored.overview())!.validCompletionCount, 8);
    await expectLater(
      restored.selectCompanion(Companion.rabbit),
      throwsA(isA<UserError>()),
    );
    await restored.verifyAccounting();

    final copy = File('${family.root.path}/companion-check.sqlite');
    await restored.db.customStatement('VACUUM INTO ?', [copy.path]);
    final snapshotDb = sqlite3.open(copy.path);
    try {
      snapshotDb.execute('DELETE FROM companion_completions WHERE pet_id = ?', [
        newcomer.name,
      ]);
    } finally {
      snapshotDb.close();
    }
    final schema = await expectedSchema();
    final assets = (jsonDecode(
      File('assets/config/runtime_assets.json').readAsStringSync(),
    ) as Map).keys.cast<String>().toSet();
    await expectLater(
      checkSnapshot(copy.path, schema, family.rules, assets),
      throwsA(isA<UserError>()),
    );
  });

  test(
    'correcting the only credited completion leaves zero experience',
    () async {
      final family = await TestFamily.create();
      addTearDown(family.dispose);
      final service = family.service;
      final parent = await service.pin.unlock(TestFamily.pin);
      final result = await service.backfill(
        const TaskDraft('测试任务A', '测试内容', '测试标准', 'focus'),
        service.today,
        '',
        session: parent,
      );
      expect((await service.overview())!.experience, 1);

      final quote = await service.correctionQuote(
        result['instance_id'] as String,
        const [],
        parent,
      );
      await service.correctAward(quote, '测试更正', false, session: parent);

      final after = (await service.overview())!;
      expect(
        (after.balance, after.validCompletionCount, after.experience),
        (0, 0, 0),
      );
      final progress = (await service.companionProgress())[Companion.rabbit]!;
      expect((progress.experience, progress.stage), (0, 1));
      await service.verifyAccounting();
    },
  );
}
