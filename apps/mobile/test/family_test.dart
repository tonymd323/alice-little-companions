import 'package:alice_companions/application/family.dart';
import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/domain/pin.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/families.dart';

const draft = TaskDraft('测试任务A', '测试内容', '测试标准A', 'focus');

void main() {
  test(
    'M1 AC-02/09/10 one atomic reward and completion survive reopen',
    () async {
      final fixture = await TestFamily.create();
      addTearDown(fixture.dispose);
      final service = fixture.service;
      expect((await service.overview())!.balance, 0);
      expect(await service.tasks(), isEmpty);
      await expectLater(service.publish(draft), throwsA(isA<UserError>()));
      final adult = await service.pin.unlock(TestFamily.pin);
      final instance =
          (await service.publish(draft, session: adult))['instance_id']
              as String;
      await service.submit(instance, '测试申报');
      expect((await service.overview())!.balance, 0);
      expect(await service.ledger(), isEmpty);
      await expectLater(
        service.approve(instance, service.today, ''),
        throwsA(isA<UserError>()),
      );
      final approval = service.approve(
        instance,
        service.today,
        '确认测试',
        session: adult,
        commandId: 'approval-a',
      );
      final retries = List.generate(
        19,
        (_) => service.approve(
          instance,
          service.today,
          '确认测试',
          session: adult,
          commandId: 'approval-a',
        ),
      );
      final results = await Future.wait([approval, ...retries]);
      expect(results.map((result) => result['id']).toSet(), hasLength(1));
      await expectLater(
        service.approve(
          instance,
          service.today,
          '另一段反馈',
          session: adult,
          commandId: 'approval-a',
        ),
        throwsA(isA<UserError>()),
      );
      await service.approve(
        instance,
        service.today,
        '',
        session: adult,
        commandId: 'retry-other-id',
      );
      expect(await service.ledger(), hasLength(1));
      await service.verifyAccounting();
      await fixture.reopen();
      final summary = (await fixture.service.overview())!;
      expect(
        (summary.balance, summary.days, summary.stage, summary.companion),
        (3, 1, 1, Companion.rabbit),
      );
      final entries = await fixture.service.tasks();
      expect(entries.single.state, 'APPROVED');
      expect(entries.single.feedback, '确认测试');
      expect((await fixture.service.ledger()).single['delta'], 3);
      expect(fixture.service.pin.allows(adult), isFalse);
    },
  );

  test(
    'AC-03 PIN session locks and five failures remain throttled after restart',
    () async {
      var now = DateTime.utc(2026, 11, 18);
      final fixture = await TestFamily.create(now: () => now);
      addTearDown(fixture.dispose);
      final session = await fixture.service.pin.unlock(TestFamily.pin);
      fixture.service.pin.lock();
      await expectLater(
        fixture.service.publish(draft, session: session),
        throwsA(isA<UserError>()),
      );
      final wrong = 654321.toString();
      for (var attempt = 1; attempt <= 5; attempt++) {
        await expectLater(
          fixture.service.pin.unlock(wrong),
          throwsA(isA<UserError>()),
        );
      }
      await fixture.reopen(now: () => now);
      await expectLater(
        fixture.service.pin.unlock(TestFamily.pin),
        throwsA(
          isA<UserError>().having(
            (e) => e.message,
            'persistent delay',
            contains('60'),
          ),
        ),
      );
      now = now.add(const Duration(seconds: 61));
      expect(
        fixture.service.pin.allows(
          await fixture.service.pin.unlock(TestFamily.pin),
        ),
        isTrue,
      );
    },
  );
}
