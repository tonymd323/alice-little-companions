import 'package:alice_companions/application/controller.dart';
import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/application/family.dart';
import 'package:alice_companions/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/families.dart';

Future<void> _waitFor(WidgetTester tester, Finder target) async {
  for (var attempt = 0; attempt < 40; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump(const Duration(milliseconds: 50));
    if (target.evaluate().isNotEmpty) return;
  }
  expect(target, findsOneWidget);
}

Future<void> _tap(WidgetTester tester, Finder target) async {
  await _waitFor(tester, target);
  await tester.ensureVisible(target);
  await tester.pump();
  expect(target.hitTestable(), findsOneWidget);
  await tester.tap(target);
  await tester.pump(const Duration(milliseconds: 350));
}

void main() {
  testWidgets(
    'current companion entry and unlock dialog at 130% on four viewports',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final family = (await tester.runAsync(
        () => TestFamily.create(pet: Companion.fox),
      ))!;
      final controller = FamilyController(family.device, family.rules)
        ..service = family.service;
      addTearDown(() async {
        controller.dispose();
        await family.dispose();
      });
      await tester.runAsync(() async {
        final session = await family.service.pin.unlock(TestFamily.pin);
        for (var index = 0; index < 6; index++) {
          await family.service.backfill(
            const TaskDraft('测试任务A', '测试内容', '测试标准', 'challenge'),
            family.service.today,
            '',
            session: session,
          );
        }
        await controller.refresh();
      });
      expect(controller.family!.balance, 30);
      for (final (size, platform) in const [
        (Size(360, 780), TargetPlatform.android),
        (Size(390, 844), TargetPlatform.android),
        (Size(820, 1180), TargetPlatform.iOS),
        (Size(1180, 820), TargetPlatform.iOS),
      ]) {
        debugDefaultTargetPlatformOverride = platform;
        tester.view.physicalSize = size;
        await tester.pumpWidget(
          CompanionsApp(key: ValueKey(size), controller: controller),
        );
        await _tap(tester, find.widgetWithText(TextButton, '伙伴'));
        final unlock = find.text('用 30 分解锁').first;
        await _tap(tester, unlock);
        expect(find.text('邀请桃桃入住？'), findsOneWidget);
        expect(find.text('确认解锁').hitTestable(), findsOneWidget);
        await _tap(tester, find.text('返回'));
        expect(find.text('正在陪伴'), findsOneWidget);
        expect(tester.takeException(), isNull);
        expect(controller.family!.balance, 30);
        debugPrint(
          'Viewport ${size.width.toInt()}x${size.height.toInt()} ${platform.name} 130%: entry, unlock dialog, and cancel passed.',
        );
      }
      expect(
        await tester.runAsync(family.service.companionProgress),
        hasLength(1),
      );
      debugDefaultTargetPlatformOverride = null;
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );
}
