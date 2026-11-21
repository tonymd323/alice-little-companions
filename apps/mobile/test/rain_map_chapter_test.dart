import 'dart:async';

import 'package:alice_companions/domain/pin.dart';
import 'package:alice_companions/domain/rain_map.dart';
import 'package:alice_companions/features/garden.dart';
import 'package:alice_companions/features/rain_map_chapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

final _stamp = find.byKey(const ValueKey('rain-map-stamp'));
final _target = find.byKey(const ValueKey('rain-map-stamp-target'));
Finder _stone(int index) => find.byKey(ValueKey('rain-map-stone-$index'));
Finder _ink(int mark) => find.byKey(ValueKey('rain-map-art-ink-$mark'));
final _stampArt = find.byKey(const ValueKey('rain-map-art-stamp'));

Future<void> _press(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _mount(
  WidgetTester tester,
  _SavedMap service,
  Size viewport, {
  bool reduceMotion = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = viewport;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    MaterialApp(
      theme: gardenTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(1.3),
          disableAnimations: reduceMotion,
        ),
        child: child!,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: FilledButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => RainMapChapter(
                    initial: service.progress,
                    service: service,
                  ),
                ),
              ),
              child: const Text('打开故事'),
            ),
          ),
        ),
      ),
    ),
  );
  await _press(tester, find.text('打开故事'));
}

void main() {
  testWidgets(
    'route restores the saved stone and accepts one tap while a write is pending',
    (tester) async {
      final service = _SavedMap();
      await _mount(tester, service, const Size(320, 600));
      await _press(tester, find.text('和奶油出发'));

      await _press(tester, _stamp);
      expect(find.textContaining('还差3块石板'), findsOneWidget);
      expect(_ink(1), findsNothing);
      await _press(tester, _stone(2));
      expect(find.textContaining('先踩第一块石板'), findsOneWidget);
      expect(service.actions, ['begin']);

      service.nextStep = Completer<void>();
      await tester.tap(_stone(0));
      await tester.tap(_stone(0));
      await tester.pump();
      expect(service.actions, ['begin', 'step:1:0:0']);
      expect(service.progress.stones, 0);
      expect(find.bySemanticsLabel('第1块石板，下一块'), findsOneWidget);
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .semanticsLabel,
        '正在存档',
      );
      service.nextStep!.completeError(const UserError('存档暂时不可用。'));
      await tester.pumpAndSettle();
      expect(find.text('存档暂时不可用。'), findsOneWidget);
      service.nextStep = null;

      await _press(tester, _stone(0));
      await _press(tester, _stone(1));
      await _press(tester, _stamp);
      expect(find.textContaining('还差1块石板'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await _press(tester, find.text('打开故事'));
      expect(find.bySemanticsLabel('第1块石板，已踩过'), findsOneWidget);
      expect(find.bySemanticsLabel('第2块石板，已踩过'), findsOneWidget);
      expect(find.bySemanticsLabel('第3块石板，下一块'), findsOneWidget);
      await _press(tester, _stone(2));
      await tester.ensureVisible(_target);
      final paper = tester.getRect(
        find.byKey(const ValueKey('rain-map-art-paper')),
      );
      await tester.tapAt(
        Offset(paper.left + paper.width * .84, tester.getCenter(_target).dy),
      );
      await tester.pump();
      expect(service.progress.stamps, 0);
      await tester.tap(_target);
      await tester.pump();
      expect(_stampArt, findsOneWidget);
      expect(_ink(1), findsNothing);
      await tester.pump(const Duration(milliseconds: 145));
      expect(_ink(1), findsOneWidget);
      expect(find.textContaining('三块都走过了'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(_stampArt, findsNothing);
      expect(_ink(2), findsNothing);
      expect(tester.widget<RainMapPaper>(find.byType(RainMapPaper)).stamps, 1);
      expect(find.bySemanticsLabel('第1块石板，下一块'), findsOneWidget);
      expect(service.progress.totalStones, 3);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'four sections reunite the companions, then the child can build the optional shortcut',
    (tester) async {
      final service = _SavedMap();
      await _mount(tester, service, const Size(1024, 768), reduceMotion: true);
      await _press(tester, find.text('和奶油出发'));
      for (var group = 0; group < RainMapProgress.groupCount; group++) {
        for (var stone = 0; stone < RainMapProgress.groupSize; stone++) {
          await _press(tester, _stone(stone));
        }
        await tester.ensureVisible(_stamp);
        await tester.tap(_stamp);
        await tester.pump();
        expect(_stampArt, findsNothing);
        expect(_ink(group + 1), findsOneWidget);
        await tester.pumpAndSettle();
      }
      expect(service.progress.totalStones, 12);
      expect(service.progress.cleared, isTrue);
      expect(service.progress.challengeSolved, isFalse);
      expect(find.textContaining('我沿着你们的爪印找到小家啦'), findsOneWidget);
      expect(find.bySemanticsLabel('地图上有4个爪印，共4个'), findsOneWidget);
      await _press(tester, find.text('帮桃桃铺近路'));
      await _press(tester, find.text('带桃桃过桥'));
      expect(find.textContaining('还有爪印没配满'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('再走一遍'), findsOneWidget);

      await _press(tester, find.text('帮桃桃铺近路'));
      for (var i = 0; i < 10; i++) {
        await _press(tester, find.text('铺一块'));
      }
      expect(find.bySemanticsLabel('已经铺了10块石板'), findsOneWidget);
      await _press(tester, find.text('带桃桃过桥'));
      expect(find.textContaining('收回多出来的石板'), findsOneWidget);
      expect(
        service.actions.where((action) => action.startsWith('solve:')),
        isEmpty,
      );
      await _press(tester, find.text('收回一块'));
      await _press(tester, find.text('带桃桃过桥'));
      expect(service.actions.last, 'solve:9');
      expect(find.textContaining('还学会了走三个爪印的近路'), findsOneWidget);
      await _press(tester, find.text('再走一遍'));
      expect(service.progress.run, 2);
      expect(service.progress.totalStones, 0);
      expect(_ink(1), findsNothing);
      expect(
        service.progress.cleared && service.progress.challengeSolved,
        isTrue,
      );
      expect(find.bySemanticsLabel('第1块石板，下一块'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

class _SavedMap implements RainMapCommands {
  RainMapProgress progress = const RainMapProgress();
  final actions = <String>[];
  Completer<void>? nextStep;

  @override
  Future<RainMapProgress> beginRainMap() async {
    actions.add('begin');
    return progress = const RainMapProgress(run: 1);
  }

  @override
  Future<RainMapProgress> stepRainMapStone({
    required int run,
    required int group,
    required int stone,
  }) async {
    actions.add('step:$run:$group:$stone');
    final wait = nextStep;
    if (wait != null) await wait.future;
    expect(
      (run, group, stone),
      (progress.run, progress.stamps, progress.stones),
    );
    return progress = RainMapProgress(
      run: run,
      stamps: group,
      stones: stone + 1,
      cleared: progress.cleared,
      challengeSolved: progress.challengeSolved,
    );
  }

  @override
  Future<RainMapProgress> stampRainMap({
    required int run,
    required int group,
  }) async {
    actions.add('stamp:$run:$group');
    expect(
      (run, group, progress.canStamp),
      (progress.run, progress.stamps, true),
    );
    return progress = RainMapProgress(
      run: run,
      stamps: group + 1,
      cleared: progress.cleared || group + 1 == RainMapProgress.groupCount,
      challengeSolved: progress.challengeSolved,
    );
  }

  @override
  Future<RainMapProgress> restartRainMap({required int run}) async {
    actions.add('restart:$run');
    expect(run, progress.run);
    return progress = RainMapProgress(
      run: run + 1,
      cleared: progress.cleared,
      challengeSolved: progress.challengeSolved,
    );
  }

  @override
  Future<RainMapProgress> solveRainMapChallenge(int stones) async {
    actions.add('solve:$stones');
    expect(progress.complete, isTrue);
    return progress = RainMapProgress(
      run: progress.run,
      stamps: progress.stamps,
      cleared: true,
      challengeSolved: true,
    );
  }
}
