import 'package:alice_companions/application/family.dart';
import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/domain/pin.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/families.dart';

const light = TaskDraft('测试任务A', '', '测试标准A', 'light');
const focus = TaskDraft('测试任务B', '', '测试标准B', 'focus');
const challenge = TaskDraft('测试任务C', '', '测试标准C', 'challenge');

void main() {
  test('AC-04/05 staged project unlocks in order and totals ten', () async {
    final fixture = await TestFamily.create();
    addTearDown(fixture.dispose);
    final service = fixture.service;
    final parent = await service.pin.unlock(TestFamily.pin);
    await service.publishProject(light, [
      const StageDraft('测试阶段A', '测试份额A', 'light'),
      const StageDraft('测试阶段B', '测试份额B', 'focus'),
      const StageDraft('测试阶段C', '测试份额C', 'challenge'),
    ], session: parent);
    final steps = await service.tasks();
    expect(steps.map((task) => task.state), ['OPEN', 'WAITING', 'WAITING']);
    await expectLater(
      service.submit(steps[1].id, ''),
      throwsA(isA<UserError>()),
    );
    for (final step in steps) {
      await service.submit(step.id, '');
      final result = await service.approve(
        step.id,
        service.today,
        '',
        session: parent,
      );
      expect(result['delta'], step.reward);
    }
    expect((await service.overview())!.balance, 10);
    expect(await service.ledger(), hasLength(3));
    expect((await service.overview())!.days, 1);
  });

  test(
    'AC-06/07 repeat slots survive edit, pause, date rollback and cancel',
    () async {
      var now = DateTime.utc(2026, 10, 1);
      final fixture = await TestFamily.create(now: () => now);
      addTearDown(fixture.dispose);
      var parent = await fixture.service.pin.unlock(TestFamily.pin);
      final configuration = RepeatSchedule('2026-10-01', '2026-10-08', 2);
      final template =
          (await fixture.service.publishRecurring(
                focus,
                configuration,
                session: parent,
              ))['template_id']
              as String;
      final first = await fixture.service.tasks();
      expect(first, hasLength(2));
      await fixture.service.cancel(first.last.id, session: parent);
      await fixture.service.editRecurring(
        template,
        1,
        challenge,
        configuration,
        session: parent,
      );
      now = now.add(const Duration(days: 1));
      await fixture.reopen(now: () => now);
      parent = await fixture.service.pin.unlock(TestFamily.pin);
      await fixture.service.processCalendar();
      final next = await fixture.service.tasks();
      expect(next.map((task) => task.reward), [5, 5, 3, 3]);
      expect(
        next.where((task) => task.state == 'CANCELLED').single.id,
        first.last.id,
      );
      await fixture.service.reopen(first.first.id, null, session: parent);
      await fixture.service.submit(first.first.id, '');
      await fixture.service.approve(
        first.first.id,
        fixture.service.today,
        '',
        session: parent,
      );
      expect((await fixture.service.overview())!.balance, 3);
      await fixture.service.pauseRecurring(template, true, session: parent);
      now = now.add(const Duration(days: 2));
      await fixture.service.processCalendar();
      expect(await fixture.service.tasks(), hasLength(4));
      await fixture.service.pauseRecurring(template, false, session: parent);
      await fixture.service.processCalendar();
      expect(await fixture.service.tasks(), hasLength(6));
      now = DateTime.utc(2026, 10, 1);
      await fixture.service.processCalendar();
      expect(await fixture.service.tasks(), hasLength(6));
    },
  );

  test('AC-08/09 past-date backfill and overdue submission do not trigger extra points', () async {
    var now = DateTime.utc(2026, 10, 1);
    final fixture = await TestFamily.create(now: () => now);
    addTearDown(fixture.dispose);
    final service = fixture.service;
    final parent = await service.pin.unlock(TestFamily.pin);
    final timed = TaskDraft(
      light.title,
      light.content,
      light.criteria,
      light.type,
      due: service.today,
    );
    final id =
        (await service.publish(timed, session: parent))['instance_id']
            as String;
    await service.submit(id, '测试申报A');
    await service.returnTask(id, '测试退回', session: parent);
    expect(await service.ledger(), isEmpty);
    await service.submit(id, '测试申报B');
    now = now.add(const Duration(days: 1));
    await service.processCalendar();
    expect((await service.task(id)).state, 'SUBMITTED');
    await service.approve(id, '2026-10-01', '测试反馈', session: parent);
    await service.backfill(challenge, '2026-09-29', '测试补录', session: parent);
    expect(await service.ledger(), hasLength(2));
    expect((await service.overview())!.balance, 7);
    expect((await service.overview())!.days, 2);
  });

  test(
    'AC-13/14 penalty is bounded and reversal does not release the cap',
    () async {
      final fixture = await TestFamily.create();
      addTearDown(fixture.dispose);
      final service = fixture.service;
      final parent = await service.pin.unlock(TestFamily.pin);
      await service.backfill(light, service.today, '', session: parent);
      await expectLater(
        service.definePenalty('测试行为', '测试条件', 3),
        throwsA(isA<UserError>()),
      );
      final rule =
          (await service.definePenalty(
                '测试行为',
                '测试条件',
                3,
                session: parent,
              ))['rule_id']
              as String;
      await expectLater(
        service.applyPenalty(rule, 'event-a', '测试事实', service.today),
        throwsA(isA<UserError>()),
      );
      final first = await service.applyPenalty(
        rule,
        'event-a',
        '测试事实',
        service.today,
        session: parent,
      );
      expect(first['deducted'], 2);
      expect((await service.overview())!.balance, 0);
      expect(await service.penaltyUsed(service.today), 2);
      await service.reversePenalty('event-a', session: parent);
      await service.reversePenalty('event-a', session: parent);
      expect((await service.overview())!.balance, 2);
      expect(await service.penaltyUsed(service.today), 2);
      final second = await service.applyPenalty(
        rule,
        'event-b',
        '测试事实B',
        service.today,
        session: parent,
      );
      expect(second['deducted'], 1);
      expect(await service.penaltyUsed(service.today), 3);
      expect(await service.ledger(), hasLength(4));
    },
  );

  test(
    'AC-15/43 correction records explicit shortfall with ownership retained',
    () async {
      final fixture = await TestFamily.create();
      addTearDown(fixture.dispose);
      final service = fixture.service;
      final parent = await service.pin.unlock(TestFamily.pin);
      await service.backfill(light, service.today, '', session: parent);
      await service.backfill(challenge, service.today, '', session: parent);
      final id =
          (await service.backfill(
                challenge,
                service.today,
                '测试反馈',
                session: parent,
              ))['instance_id']
              as String;
      await service.purchase('accessory_scarf');
      await service.backfill(light, service.today, '', session: parent);
      final quote = await service.correctionQuote(id, [], parent);
      expect((quote.reward, quote.recoverable, quote.shortfall), (5, 2, 3));
      await expectLater(
        service.correctAward(quote, '测试更正说明', false, session: parent),
        throwsA(isA<UserError>()),
      );
      await service.correctAward(quote, '测试更正说明', true, session: parent);
      expect((await service.overview())!.balance, 0);
      final corrected = await service.task(id);
      expect(
        (corrected.state, corrected.feedback, corrected.resolution),
        ('CORRECTED', '测试反馈', '测试更正说明'),
      );
      expect(await service.items(), hasLength(1));
      await expectLater(
        service.approve(id, service.today, '', session: parent),
        throwsA(isA<UserError>()),
      );
      final newResult = await service.backfill(
        light,
        service.today,
        '',
        session: parent,
        correcting: id,
        commandId: 'supplement-once',
      );
      expect(newResult['balance'], 2);
      final experienceBeforeRetry = (await service.overview())!.experience;
      expect(
        await service.db.value(
          'SELECT prior_instance_id FROM task_instances WHERE id = ?',
          [newResult['instance_id']],
        ),
        id,
      );
      expect(
        await service.backfill(
          light,
          service.today,
          '',
          session: parent,
          correcting: id,
          commandId: 'supplement-once',
        ),
        newResult,
      );
      await expectLater(
        service.backfill(
          light,
          service.today,
          '',
          session: parent,
          correcting: id,
        ),
        throwsA(isA<UserError>()),
      );
      expect((await service.overview())!.balance, 2);
      expect((await service.overview())!.experience, experienceBeforeRetry);
    },
  );

  test(
    'AC-17/18 all growth thresholds apply to the starter and locked companions stay out',
    () async {
      final fixture = await TestFamily.create(pet: Companion.cat);
      addTearDown(fixture.dispose);
      final service = fixture.service;
      final parent = await service.pin.unlock(TestFamily.pin);
      for (var offset = 0; offset < 55; offset++) {
        final day = parseDayForTest(service.today, offset);
        await service.backfill(light, day, '', session: parent);
        if (offset == 0) {
          await service.backfill(focus, day, '', session: parent);
        }
        final expected =
            1 +
            [
              3,
              10,
              20,
              35,
              55,
            ].where((threshold) => offset + 2 >= threshold).length;
        final summary = (await service.overview())!;
        expect(
          (summary.days, summary.experience, summary.stage),
          (offset + 1, offset + 2, expected),
        );
        if ([1, 2, 3, 9, 10, 19, 20, 34, 35, 54, 55].contains(offset + 1)) {
          for (final pet in [Companion.fox, Companion.rabbit]) {
            await expectLater(service.selectCompanion(pet), throwsA(isA<UserError>()));
          }
          await service.selectCompanion(Companion.cat);
          final after = (await service.overview())!;
          expect(
            (after.companion, after.experience, after.stage, after.balance),
            (Companion.cat, summary.experience, expected, summary.balance),
          );
        }
      }
      expect(await service.db.value('SELECT retained_stage FROM owned_companions'), 6);
      final old = (await service.tasks()).last;
      await service.correctAward(
        await service.correctionQuote(old.id, [], parent),
        '测试更正',
        true,
        session: parent,
      );
      await fixture.reopen();
      expect(
        (
          (await fixture.service.overview())!.stage,
          (await fixture.service.overview())!.companion,
        ),
        (6, Companion.cat),
      );
      expect(
        await fixture.service.db.value('SELECT retained_stage FROM owned_companions'),
        6,
      );
    },
  );

  test(
    'AC-11 simultaneous fixed purchases cannot overdraw or duplicate ownership',
    () async {
      final fixture = await TestFamily.create();
      addTearDown(fixture.dispose);
      final service = fixture.service;
      final parent = await service.pin.unlock(TestFamily.pin);
      for (final task in [challenge, challenge, light]) {
        await service.backfill(task, service.today, '', session: parent);
      }
      final attempts = await Future.wait(
        ['accessory_hat', 'accessory_scarf'].map((item) async {
          try {
            return await service.purchase(item);
          } on UserError {
            return null;
          }
        }),
      );
      expect(attempts.whereType<Map>(), hasLength(1));
      expect((await service.overview())!.balance, 0);
      expect(await service.items(), hasLength(1));
      await service.verifyAccounting();
    },
  );

  test('AC-12 transaction fault at balance, ledger and ownership rolls back after reopen', () async {
    final fixture = await TestFamily.create();
    addTearDown(fixture.dispose);
    var phase = 'none';
    FamilyService inject() => FamilyService(
      fixture.service.db,
      fixture.service.pin,
      fixture.rules,
      fault: (point) {
        if (point == phase) throw StateError('test write interruption');
      },
    );
    var service = inject();
    var parent = await service.pin.unlock(TestFamily.pin);
    for (var i = 0; i < 3; i++) {
      await service.backfill(challenge, service.today, '', session: parent);
    }
    final pending =
        (await service.publish(light, session: parent))['instance_id']
            as String;
    await service.submit(pending, '');
    for (final injection in ['balance', 'ledger', 'ownership']) {
      phase = injection;
      if (injection != 'ownership') {
        await expectLater(
          service.approve(pending, service.today, '', session: parent),
          throwsStateError,
        );
      }
      await expectLater(service.purchase('accessory_scarf'), throwsStateError);
      await fixture.reopen();
      service = inject();
      parent = await service.pin.unlock(TestFamily.pin);
      expect((await service.overview())!.balance, 15);
      expect(await service.items(), isEmpty);
      expect(await service.ledger(), hasLength(3));
      expect((await service.task(pending)).state, 'SUBMITTED');
    }
  });
}

String parseDayForTest(String value, int offset) =>
    DateTime.parse(value)
        .subtract(Duration(days: offset))
        .toIso8601String()
        .substring(0, 10);
