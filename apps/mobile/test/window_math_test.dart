import 'dart:convert';
import 'dart:io';

import 'package:alice_companions/features/garden.dart';
import 'package:alice_companions/features/window_math.dart';
import 'package:alice_companions/main_window_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> startChapter(
  WidgetTester tester, {
  WindowPage page = WindowPage.count,
  Set<int> pattern = const {},
  Size viewport = const Size(360, 800),
  double scale = 1,
  Future<void> Function(WindowPage, Set<int>)? save,
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
          disableAnimations: true,
          textScaler: TextScaler.linear(scale),
        ),
        child: child!,
      ),
      home: WindowMathChapter(
        initialPage: page,
        initialPattern: pattern,
        save: save ?? (page, pattern) async {},
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> press(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'child completes both opening puzzles, explores hints and solves the optional window in their own arrangement',
    (tester) async {
      final bookmarks = <WindowPage>[];
      Set<int>? finalPattern;
      await startChapter(
        tester,
        scale: 1.3,
        save: (page, pattern) async {
          bookmarks.add(page);
          finalPattern = pattern;
        },
      );
      await press(tester, find.text('8 片'));
      expect(find.textContaining('点一扇数一组'), findsOneWidget);
      await press(tester, find.text('看看桃桃的提示'));
      await press(tester, find.bySemanticsLabel('第 1 格，4 片金叶'));
      expect(find.text('已点亮 1 扇，共 4 片。'), findsOneWidget);
      expect(bookmarks, isEmpty);
      await press(tester, find.text('12 片'));
      await press(tester, find.text('和桃桃一起补叶片'));
      await press(tester, find.text('7 片'));
      expect(find.textContaining('空叶印'), findsOneWidget);
      await press(tester, find.text('5 片'));
      await press(tester, find.text('看看阳光下的彩窗'));
      expect(find.text('彩窗亮起来了'), findsOneWidget);
      await press(tester, find.text('多想一步 · 挑战十九片'));
      await press(tester, find.text('试着装上窗花'));
      expect(find.textContaining('还差 4 片'), findsOneWidget);
      for (final index in [1, 3, 5]) {
        await press(tester, find.bySemanticsLabel('第 $index 格，3 片金叶'));
      }
      await press(tester, find.text('试着装上窗花'));
      expect(find.textContaining('多了 2 片'), findsOneWidget);
      await press(tester, find.bySemanticsLabel('第 3 格，5 片金叶'));
      expect(find.text('已用 19 片，共有 19 片。'), findsOneWidget);
      await press(tester, find.text('试着装上窗花'));
      expect(bookmarks, [
        WindowPage.missing,
        WindowPage.sunny,
        WindowPage.puzzle,
        WindowPage.finished,
      ]);
      expect(finalPattern, {0, 4});
      expect(find.bySemanticsLabel('第 1 格，5 片金叶'), findsOneWidget);
      expect(find.bySemanticsLabel('第 5 格，5 片金叶'), findsOneWidget);
      for (var first = 1; first <= 4; first++) {
        for (var second = first + 1; second <= 5; second++) {
          await press(tester, find.text('试试另一种排法'));
          await press(tester, find.bySemanticsLabel('第 $first 格，3 片金叶'));
          await press(tester, find.bySemanticsLabel('第 $second 格，3 片金叶'));
          await press(tester, find.text('试着装上窗花'));
          expect(find.text('两种花纹，一扇彩窗'), findsOneWidget);
          expect(finalPattern, {first - 1, second - 1});
        }
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'another session can stop after the basic story, return from the stretch puzzle or replay',
    (tester) async {
      await startChapter(
        tester,
        page: WindowPage.sunny,
        viewport: const Size(1194, 834),
      );
      expect(find.text('彩窗亮起来了'), findsOneWidget);
      await press(tester, find.text('多想一步 · 挑战十九片'));
      await press(tester, find.text('回到已经点亮的彩窗'));
      await press(tester, find.text('从第一扇窗重玩'));
      expect(find.text('一起数窗花'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  test('saved stage and exact finished panes reload; invalid progress opens the first puzzle', () async {
    final dir = await Directory.systemTemp.createTemp('alice-window-');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/window-chapter.json');
    expect((await readWindowBookmark(file)).page, WindowPage.count);
    for (final page in [
      WindowPage.missing,
      WindowPage.sunny,
      WindowPage.puzzle,
    ]) {
      await file.writeAsString(jsonEncode({'page': page.name}));
      expect((await readWindowBookmark(file)).page, page);
    }
    await file.writeAsString(
      jsonEncode({
        'page': 'finished',
        'five_leaf_panes': [1, 3],
      }),
    );
    final done = await readWindowBookmark(file);
    expect(done.page, WindowPage.finished);
    expect(done.pattern, {1, 3});
    for (final malformed in [
      '{',
      '{"page":"future"}',
      '{"page":"finished","five_leaf_panes":[1,1]}',
    ]) {
      await file.writeAsString(malformed);
      expect((await readWindowBookmark(file)).page, WindowPage.count);
    }
  });
}
