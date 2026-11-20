import 'dart:convert';
import 'dart:io';

import 'package:alice_companions/application/controller.dart';
import 'package:alice_companions/domain/backup_codec.dart';
import 'package:alice_companions/features/tasks.dart';
import 'package:alice_companions/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/families.dart';

class TimedController extends FamilyController {
  TimedController(super.device, super.rules);

  final refreshMicros = <int>[];
  Stopwatch? confirmation;
  int? refreshStart;
  int? refreshEnd;

  @override
  Future<void> refresh() async {
    final activeConfirmation = confirmation;
    final start = activeConfirmation?.elapsedMicroseconds;
    final clock = Stopwatch()..start();
    await super.refresh();
    refreshMicros.add(clock.elapsedMicroseconds);
    if (activeConfirmation != null && confirmation == activeConfirmation) {
      refreshStart = start;
      refreshEnd = activeConfirmation.elapsedMicroseconds;
    }
  }
}

Future<void> pumpUntil(WidgetTester tester, Finder target) async {
  final timeout = Stopwatch()..start();
  while (!tester.any(target) && timeout.elapsed < const Duration(seconds: 20)) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 5)),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
  expect(target, findsOneWidget);
}

Future<void> finishNavigation(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Finder parentList() => find.descendant(
  of: find.byType(ParentHome),
  matching: find.byType(Scrollable),
);

Future<void> topOfParentList(WidgetTester tester) async {
  final scrollable = parentList();
  expect(scrollable, findsOneWidget);
  final position = tester.state<ScrollableState>(scrollable).position;
  if (position.pixels != position.minScrollExtent) {
    position.jumpTo(position.minScrollExtent);
    await tester.pump();
  }
}

int p95(List<int> samples) => (samples.toList()..sort())[18];

void main() {
  testWidgets('AC-39 host startup and normal approval with 10706 ledger rows', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final stock = (await tester.runAsync(TestFamily.create))!;
    addTearDown(() => stock.root.delete(recursive: true));
    await tester.runAsync(() async {
      final path = stock.device.databaseFile(stock.service.pin.generation).path;
      await stock.service.close();
      final input = File(Platform.environment['ALICE_UI_PROBE_FILE']!);
      if (input.path.endsWith('.alicebackup')) {
        await const BackupCodec().extract(
          input,
          'Alice-QA-Fixture-019',
          File(path),
        );
      } else {
        await input.copy(path);
      }
    });
    int? upgradeMicros;
    final schema = int.tryParse(
      Platform.environment['ALICE_UI_PROBE_UPGRADE_SCHEMA'] ?? '',
    );
    if (schema != null) {
      upgradeMicros = await tester.runAsync(() async {
        final controller = TimedController(stock.device, stock.rules);
        try {
          final clock = Stopwatch()..start();
          await controller.open();
          clock.stop();
          expect(controller.family?.balance, 32077);
          expect(controller.family?.experience, 10697);
          expect(
            await controller.service!.db.value('PRAGMA user_version'),
            schema,
          );
          return clock.elapsedMicroseconds;
        } finally {
          controller.dispose();
          await controller.service?.close();
        }
      });
    }
    final boots = <int>[];
    final confirms = <int>[];
    final reloads = <int>[];
    final beforeRefresh = <int>[];
    final afterRefresh = <int>[];
    int? initialRows;
    for (var repeat = 0; repeat < 10; repeat++) {
      final controller = TimedController(stock.device, stock.rules);
      final boot = Stopwatch()..start();
      await tester.runAsync(controller.open);
      await tester.pumpWidget(CompanionsApp(controller: controller));
      expect(find.byTooltip('家长入口'), findsOneWidget);
      expect(find.text('32077 分'), findsOneWidget);
      expect(controller.family!.experience, 10697);
      boot.stop();
      boots.add(boot.elapsedMicroseconds);

      if (repeat == 9) {
        await tester.tap(find.byTooltip('家长入口'));
        await finishNavigation(tester);
        expect(find.text('家长解锁'), findsOneWidget);
        await tester.runAsync(() => controller.unlock(TestFamily.pin));
        await tester.pump();
        expect(find.text('待确认 · 21'), findsOneWidget);
        initialRows = find.byType(TaskTile).evaluate().length;
        for (var index = 0; index < 20; index++) {
          final pending = find.text(
            '测试待确认 ${(index + 1).toString().padLeft(2, '0')}',
          );
          final visiblePending = pending.hitTestable();
          if (!tester.any(visiblePending)) {
            await tester.scrollUntilVisible(
              visiblePending,
              200,
              scrollable: parentList(),
            );
          }
          await tester.ensureVisible(pending);
          await tester.pump();
          expect(visiblePending, findsOneWidget);
          await tester.tap(visiblePending);
          await finishNavigation(tester);
          final confirm = find.text('确认并入账 2 分');
          await tester.ensureVisible(confirm);
          await tester.pump();
          expect(confirm.hitTestable(), findsOneWidget);
          final clock = Stopwatch()..start();
          controller.confirmation = clock;
          controller.refreshStart = null;
          controller.refreshEnd = null;
          await tester.runAsync(() => tester.tap(confirm));
          await pumpUntil(tester, find.textContaining('· +2 分 · +1 经验'));
          clock.stop();
          controller.confirmation = null;
          confirms.add(clock.elapsedMicroseconds);
          reloads.add(controller.refreshMicros.last);
          beforeRefresh.add(controller.refreshStart!);
          afterRefresh.add(clock.elapsedMicroseconds - controller.refreshEnd!);
          expect(find.text('成果已确认'), findsOneWidget);
          expect(controller.family!.balance, 32079 + index * 2);
          expect(controller.family!.experience, 10698 + index);
          await tester.pump(const Duration(milliseconds: 400));
          await tester.runAsync(() => tester.tap(find.text('完成')));
          await pumpUntil(tester, find.text('家长管理'));
          await tester.pumpAndSettle();
          expect(find.byType(ApprovePage), findsNothing);
          await topOfParentList(tester);
          expect(find.text('待确认 · ${20 - index}'), findsOneWidget);
        }
        final ledgerCount = await tester.runAsync(
          () => controller.service!.db.value(
            'SELECT COUNT(*) FROM ledger_entries',
          ),
        );
        expect(ledgerCount, 10726);
      }

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
      await tester.runAsync(() => controller.service!.close());
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    }
    final record = {
      'run': Platform.environment['ALICE_UI_PROBE_LABEL'],
      'ledger_at_start': 10706,
      'upgrade_and_open_us': ?upgradeMicros,
      'initial_pending_widgets': initialRows,
      'boot_us': boots,
      'confirm_us': confirms,
      'before_refresh_us': beforeRefresh,
      'refresh_us': reloads,
      'after_refresh_us': afterRefresh,
      'slowest_boot_us': (boots.toList()..sort()).last,
      'confirm_p95_us': p95(confirms),
      'before_refresh_p95_us': p95(beforeRefresh),
      'refresh_p95_us': p95(reloads),
      'after_refresh_p95_us': p95(afterRefresh),
    };
    stdout.writeln('AC39 ${jsonEncode(record)}');
  }, timeout: const Timeout(Duration(minutes: 6)));
}
