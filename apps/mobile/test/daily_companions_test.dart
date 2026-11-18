import 'dart:io';

import 'package:alice_companions/application/family.dart';
import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/illustration/action_poses.dart';
import 'package:alice_companions/illustration/companion_motion.dart';
import 'package:alice_companions/illustration/evolution.dart';
import 'package:alice_companions/illustration/living_scene.dart';
import 'package:alice_companions/illustration/puppet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/families.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('same-day approvals, retry, correction and reopening retain one shared experience history', () async {
    final f = await TestFamily.create();
    addTearDown(f.dispose);
    final s = f.service, owner = await s.pin.unlock(TestFamily.pin);
    const draft = TaskDraft('测试任务A', '', '测试标准', 'focus');
    for (var i = 0; i < 2; i++) {
      final backfilled = await s.backfill(
        draft,
        s.today,
        '',
        session: owner,
        commandId: 'backfill-$i',
      );
      expect(backfilled['experience_delta'], 1);
      await s.backfill(
        draft,
        s.today,
        '',
        session: owner,
        commandId: 'backfill-$i',
      );
    }
    final id =
        (await s.publish(draft, session: owner))['instance_id'] as String;
    await s.submit(id, '');
    final third = await s.approve(id, s.today, '', session: owner);
    expect(
      (
        third['experience_delta'],
        third['previous_stage'],
        third['stage'],
        third['new_stage'],
      ),
      (1, 1, 2, true),
    );
    final secondTap = await s.approve(id, s.today, '', session: owner);
    expect((secondTap['experience_delta'], secondTap['new_stage']), (0, false));
    final atThreshold = (await s.overview())!;
    expect(
      (atThreshold.experience, atThreshold.days, atThreshold.balance),
      (3, 1, 9),
    );
    // The same effective family can be opened from 0.12 with no stored XP award.
    await s.db.customStatement('DELETE FROM growth_awards');
    expect((await s.overview())!.stage, 2);
    await s.correctAward(
      await s.correctionQuote(id, [], owner),
      '测试说明',
      false,
      session: owner,
    );
    await s.selectCompanion(Companion.cat);
    await f.reopen();
    final after = (await f.service.overview())!;
    expect(
      (after.experience, after.stage, after.balance, after.companion),
      (2, 2, 6, Companion.cat),
    );
    expect(await f.service.db.value('SELECT COUNT(*) FROM growth_awards'), 1);
  });
  test('every pet, stage and tailored outfit has an individual airborne silhouette', () {
    final paths = <String>{};
    for (final pet in Companion.values) {
      for (var stage = 1; stage <= 6; stage++) {
        for (final body in [null, 'item_single_coat', 'item_single_apron']) {
          final path = actionArtwork(pet, stage, body);
          expect(File(path).lengthSync(), greaterThan(4000), reason: path);
          paths.add(path);
        }
      }
    }
    expect(paths, hasLength(54));
  });
  testWidgets(
    'all three signature moves charge, take a painted airborne pose and land; calling and nuzzling interrupt the motion',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      IllustratedPet actor() =>
          tester.widget<IllustratedPet>(find.byType(IllustratedPet));
      for (final pet in Companion.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topCenter,
                child: GardenScene(
                  companion: pet,
                  stage: 1,
                  playable: true,
                  height: 320,
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text(pet.skillName));
        for (var frame = 0; frame < 5; frame++) {
          await tester.pump(const Duration(milliseconds: 235));
        }
        final flight = actor().motion!();
        expect(flight.action, PetAction.skill);
        expect(flight.keyPose, 1);
        expect(flight.height(pet), greaterThan(.15));
        await tester.tap(find.text('过来'));
        await tester.pump(const Duration(milliseconds: 60));
        expect(actor().walking(), 1);
        expect(actor().motion!().action, PetAction.rest);
        for (var frame = 0; frame < 8; frame++) {
          await tester.pump(const Duration(milliseconds: 230));
        }
        final rect = tester.getRect(find.byType(IllustratedPet));
        await tester.longPressAt(rect.center);
        await tester.pump(const Duration(milliseconds: 90));
        expect(actor().motion!().action, PetAction.nuzzle);
      }
    },
  );
  testWidgets(
    'evolution can be skipped and Reduce Motion opens the final stage directly',
    (tester) async {
      for (final reduced in [false, true]) {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: reduced),
              child: Scaffold(
                body: Builder(
                  builder: (c) => TextButton(
                    onPressed: () =>
                        showEvolution(c, Companion.cat, 3, 4, preview: true),
                    child: const Text('预演'),
                  ),
                ),
              ),
            ),
            builder: (c, child) => MediaQuery(
              data: MediaQueryData(disableAnimations: reduced),
              child: child!,
            ),
          ),
        );
        await tester.tap(find.text('预演'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        expect(find.text('进化预演'), findsOneWidget);
        if (!reduced) {
          await tester.tap(find.text('跳过动画'));
          await tester.pump();
        }
        expect(find.bySemanticsLabel('云翼猫第 4 阶段'), findsOneWidget);
        await tester.tap(find.text('完成'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.byType(EvolutionMoment), findsNothing);
      }
    },
  );
}
