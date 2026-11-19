import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:alice_companions/application/controller.dart';
import 'package:alice_companions/application/family.dart';
import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/illustration/companion_walk.dart';
import 'package:alice_companions/illustration/living_scene.dart';
import 'package:alice_companions/illustration/puppet.dart';
import 'package:alice_companions/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/families.dart';

final _scene = find.byType(GardenScene);
final _actor = find.byType(IllustratedPet);
final _grass = find.descendant(
  of: _scene,
  matching: find.byWidgetPredicate(
    (widget) => widget is Semantics && widget.properties.hint == '点按伙伴打招呼',
  ),
);

FamilyController controllerFor(TestFamily stock) => FamilyController(
  stock.device,
  stock.rules,
  assets: (jsonDecode(
    File('assets/config/runtime_assets.json').readAsStringSync(),
  ) as Map<String, dynamic>).keys.toSet(),
)..service = stock.service;

Future<Map<String, Object?>> domain(FamilyService family) async {
  final current = (await family.overview())!;
  return {
    'balance': current.balance,
    'experience': current.experience,
    'stage': current.stage,
    'species': current.companion,
    'revision': current.revision,
    'ledger': await family.ledger(),
    'items': await family.items(),
    'purchases': await family.purchases(),
    'wardrobe': await family.wardrobe(Companion.fox),
  };
}

Future<void> openCourtyard(
  WidgetTester tester,
  FamilyController controller,
) async {
  await tester.runAsync(controller.refresh);
  await tester.pumpWidget(CompanionsApp(controller: controller));
  await tester.pump(const Duration(milliseconds: 40));
  expect(find.text('银杏家园'), findsOneWidget);
  expect(find.text('奶油'), findsOneWidget);
  expect(tester.widget<GardenScene>(_scene).stage, 1);
  await tester.tap(find.text('暖廊').hitTestable());
  await tester.pump(const Duration(milliseconds: 40));
  expect(tester.widget<GardenScene>(_scene).view, HomeView.veranda);
  await tester.tap(find.text('庭院').hitTestable());
  await tester.pump(const Duration(milliseconds: 40));
  expect(tester.widget<GardenScene>(_scene).view, HomeView.courtyard);
}

Offset groundPoint(WidgetTester tester, Offset local) {
  final rect = tester.getRect(_grass);
  return rect.topLeft + SceneProjection.fit(rect.size, 0, false).screen(local);
}

WalkPose? visiblePose(WidgetTester tester) =>
    tester.widget<IllustratedPet>(_actor).walkPose?.call();

Future<Set<WalkStage>> advanceUntilSitting(
  WidgetTester tester, {
  int frames = 140,
}) async {
  final stages = <WalkStage>{};
  for (var frame = 0; frame < frames; frame++) {
    await tester.pump(const Duration(milliseconds: 40));
    final pose = visiblePose(tester);
    if (pose != null) {
      stages.add(pose.stage);
    } else if (stages.isNotEmpty) {
      return stages;
    }
  }
  throw StateError(
    'The fox did not visibly begin and settle within $frames frames.',
  );
}

void main() {
  testWidgets(
    'the first-stage fox walks from the real home three ways and retains a seeded family on reopen',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final stock = (await tester.runAsync(
        () => TestFamily.create(pet: Companion.fox),
      ))!;
      final controller = controllerFor(stock);
      addTearDown(() async {
        controller.dispose();
        await stock.dispose();
      });
      final before = (await tester.runAsync(() async {
        final adult = await stock.service.pin.unlock(TestFamily.pin);
        for (final (name, kind) in [
          ('测试任务A', 'focus'),
          ('测试任务B', 'challenge'),
        ]) {
          await stock.service.backfill(
            TaskDraft(name, '', '测试标准', kind),
            stock.service.today,
            '',
            session: adult,
          );
        }
        await stock.service.purchase('decor_vase');
        return domain(stock.service);
      }))!;
      expect(before['balance'], 2);
      expect(before['experience'], 2);
      expect(before['stage'], 1);
      expect(before['items'], hasLength(1));
      expect(before['ledger'], hasLength(3));

      await openCourtyard(tester, controller);
      final initial = tester.getCenter(_actor);
      final leftGrass = groundPoint(tester, const Offset(.23, .83));
      await tester.tapAt(leftGrass);
      final tapStages = await advanceUntilSitting(tester);
      final tapped = tester.getCenter(_actor);
      expect(
        tapStages,
        containsAll([
          WalkStage.rise,
          WalkStage.turn,
          WalkStage.walk,
          WalkStage.sit,
        ]),
      );
      expect(tapped.dx, closeTo(leftGrass.dx, .01));
      expect(tapped.dx, lessThan(initial.dx - 100));

      await tester.tap(find.text('过来').hitTestable());
      final callStages = await advanceUntilSitting(tester);
      final called = tester.getCenter(_actor);
      expect(
        callStages,
        containsAll([
          WalkStage.rise,
          WalkStage.turn,
          WalkStage.walk,
          WalkStage.sit,
        ]),
      );
      expect(
        called.dx,
        closeTo(groundPoint(tester, const Offset(.56, .864)).dx, .01),
      );
      expect(called.dx, greaterThan(tapped.dx + 150));

      final automaticStages = await advanceUntilSitting(tester, frames: 520);
      final automatic = tester.getCenter(_actor);
      expect(
        automaticStages,
        containsAll([WalkStage.rise, WalkStage.walk, WalkStage.sit]),
      );
      expect(
        automatic.dx,
        closeTo(groundPoint(tester, const Offset(.38, .87)).dx, .01),
      );
      expect(automatic.dx, lessThan(called.dx - 60));
      expect(await tester.runAsync(() => domain(stock.service)), before);
      expect(tester.takeException(), isNull);
      debugPrint(
        'fox origins in 390×844 logical viewport: home=${initial.dx.toStringAsFixed(2)}, tap=${tapped.dx.toStringAsFixed(2)}, call=${called.dx.toStringAsFixed(2)}, auto=${automatic.dx.toStringAsFixed(2)}',
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.runAsync(stock.reopen);
      final reopened = controllerFor(stock);
      addTearDown(reopened.dispose);
      await openCourtyard(tester, reopened);
      expect(reopened.family?.companion, Companion.fox);
      expect(await tester.runAsync(() => domain(stock.service)), before);
      expect(tester.takeException(), isNull);
      debugPrint(
        'seeded state unchanged across all moves and reopen: score 2, experience 2, stage 1, asset count 1, ledger count 3; revision, rows, and wardrobe match',
      );
    },
  );

  testWidgets(
    'near-vertical grass tap in the real family courtyard reaches both coordinates',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final stock = (await tester.runAsync(
        () => TestFamily.create(pet: Companion.fox),
      ))!;
      final controller = controllerFor(stock);
      addTearDown(() async {
        controller.dispose();
        await stock.dispose();
      });
      await openCourtyard(tester, controller);
      final start = tester.getCenter(_actor);
      final ground = groundPoint(tester, const Offset(.422, .748));
      final normalRest = groundPoint(tester, const Offset(.47, .937));
      await tester.tapAt(ground);
      var sawDepthTravel = false;
      var settled = false;
      for (var frame = 0; frame < 140; frame++) {
        await tester.pump(const Duration(milliseconds: 40));
        final pose = visiblePose(tester);
        if (pose?.stage == WalkStage.walk && math.sin(pose!.yaw) < -.9) {
          sawDepthTravel = true;
        }
        if (sawDepthTravel && pose == null) {
          settled = true;
          break;
        }
      }
      final end = tester.getCenter(_actor);
      expect(sawDepthTravel, isTrue);
      expect(settled, isTrue);
      expect(end.dx, closeTo(ground.dx, .01));
      expect(end.dy - start.dy, closeTo(ground.dy - normalRest.dy, .02));
      expect(controller.family?.experience, 0);
      expect(controller.family?.balance, 0);
      expect(tester.takeException(), isNull);
      debugPrint(
        'depth walk in normal home: displacement (${(end.dx - start.dx).toStringAsFixed(2)}, ${(end.dy - start.dy).toStringAsFixed(2)}), both coordinates matched, settled into seated posture',
      );
    },
  );
}
