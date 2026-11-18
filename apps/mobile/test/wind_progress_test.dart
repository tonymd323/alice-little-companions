import 'package:alice_companions/application/family.dart';
import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/domain/pin.dart';
import 'package:alice_companions/domain/wind_progress.dart';
import 'package:alice_companions/domain/window_page.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/families.dart';

void main() {
  test(
    'every socket persists once, both orders reach home, replay keeps it lit',
    () async {
      final stock = await TestFamily.create(pet: Companion.cat);
      addTearDown(stock.dispose);
      var service = stock.service;
      final parent = await service.pin.unlock(TestFamily.pin);
      await service.backfill(
        const TaskDraft('测试任务A', '', '测试标准A', 'focus'),
        service.today,
        '',
        session: parent,
      );
      await service.saveWindowMathBookmark(WindowPage.missing, {});
      final before = (await service.overview())!;
      final ledger = await service.ledger();
      final first = await service.windProgress();
      expect((first.run, first.started, first.remaining), (0, false, 5));
      expect((await service.overview())!.revision, before.revision);
      await expectLater(
        service.placeWindLeaf(1, run: 0),
        throwsA(isA<UserError>()),
      );
      await Future.wait([service.beginWindStory(), service.beginWindStory()]);
      final begun = (await service.overview())!;
      expect(begun.revision, before.revision + 1);
      await expectLater(
        service.replayWindStory(run: 1),
        throwsA(isA<UserError>()),
      );
      await expectLater(
        service.placeWindLeaf(5, run: 1),
        throwsA(isA<UserError>()),
      );
      await expectLater(
        service.placeWindLeaf(-1, run: 1),
        throwsA(isA<UserError>()),
      );
      expect((await service.overview())!.revision, begun.revision);

      // Four leaves in the far pane leave an actual gap in front of the fox.
      await Future.wait([
        for (final slot in [4, 2, 4, 3, 1]) service.placeWindLeaf(slot, run: 1),
      ]);
      await stock.reopen();
      service = stock.service;
      final partial = await service.windProgress();
      expect(
        (partial.mask, partial.middleLit, partial.farLit, partial.remaining),
        (30, false, true, 1),
      );
      expect((await service.overview())!.windowsLit, isFalse);
      final duplicate = await service.placeWindLeaf(4, run: 1);
      expect(duplicate.mask, partial.mask);
      expect((await service.overview())!.revision, begun.revision + 4);
      expect((await service.beginWindStory()).mask, partial.mask);

      // The last leaf, home milestone, command receipt, and revision commit together.
      await service.db.customStatement("""
      CREATE TEMP TRIGGER stop_light BEFORE INSERT ON window_story_milestones
      BEGIN SELECT RAISE(ABORT, 'test interruption'); END
    """);
      await expectLater(service.placeWindLeaf(0, run: 1), throwsA(anything));
      expect((await service.windProgress()).mask, 30);
      expect((await service.overview())!.revision, begun.revision + 4);
      await service.db.customStatement('DROP TRIGGER stop_light');
      final complete = await service.placeWindLeaf(0, run: 1);
      expect(complete.mask, WindProgress.fullMask);
      expect(complete.complete, isTrue);
      await stock.reopen();
      service = stock.service;
      expect((await service.windProgress()).complete, isTrue);
      expect((await service.overview())!.windowsLit, isTrue);

      await Future.wait([
        service.replayWindStory(run: 1),
        service.replayWindStory(run: 1),
      ]);
      expect((await service.windProgress()).run, 2);
      // A delayed slot from the previous run cannot be placed in the replay.
      expect((await service.placeWindLeaf(0, run: 1)).mask, 0);
      final nearFirst = await service.placeWindLeaf(0, run: 2);
      expect(
        (nearFirst.middleLit, nearFirst.farLit, nearFirst.remaining),
        (true, false, 4),
      );
      expect((await service.overview())!.windowsLit, isTrue);
      for (final slot in [2, 1, 4, 3]) {
        await service.placeWindLeaf(slot, run: 2);
      }
      await stock.reopen();
      service = stock.service;
      final finalRun = await service.windProgress();
      expect((finalRun.run, finalRun.complete), (2, true));
      final after = (await service.overview())!;
      expect(
        (after.balance, after.experience, after.stage, after.companion),
        (before.balance, before.experience, before.stage, before.companion),
      );
      expect(await service.ledger(), ledger);
      expect((await service.windowMathBookmark()).page, WindowPage.missing);
    },
  );
}
