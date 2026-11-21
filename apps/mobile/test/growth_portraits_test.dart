import 'dart:io';
import 'dart:ui' as ui;

import 'package:alice_companions/application/controller.dart';
import 'package:alice_companions/application/family.dart';
import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/features/garden.dart' show gardenTheme;
import 'package:alice_companions/features/home.dart';
import 'package:alice_companions/illustration/evolution.dart';
import 'package:alice_companions/illustration/growth_portrait.dart';
import 'package:alice_companions/main.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/families.dart';

const _output = String.fromEnvironment('ALICE_GROWTH_FRAMES');
const _font = String.fromEnvironment('ALICE_CJK_FONT');
const _family = 'Growth Evidence';
const _earlier = TaskDraft('测试成果A', '', '测试标准A', 'challenge');
const _pending = TaskDraft('测试成果B', '', '测试标准B', 'challenge');

Future<void> _wait(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 450 && finder.evaluate().length != 1; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 16)),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
  expect(finder, findsOneWidget);
}

Future<void> _tap(WidgetTester tester, Finder button) async {
  await _wait(tester, button);
  await Scrollable.ensureVisible(tester.element(button), alignment: .5);
  await tester.pump();
  await _wait(tester, button.hitTestable());
  await tester.runAsync(() => tester.tap(button.hitTestable()));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _photo(WidgetTester tester, Finder whole, String name) async {
  if (_output.isEmpty) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(whole);
  await tester.runAsync(() async {
    final shot = await boundary.toImage(pixelRatio: 2);
    try {
      final png = await shot.toByteData(format: ui.ImageByteFormat.png);
      await File('$_output/$name.png').writeAsBytes(png!.buffer.asUint8List());
    } finally {
      shot.dispose();
    }
  });
}

void main() {
  for (final (pet, target) in [
    (Companion.cat, 4),
    (Companion.fox, 5),
    (Companion.rabbit, 6),
    (Companion.otter, 4),
    (Companion.hedgehog, 6),
  ]) {
    testWidgets(
      '${pet.name} uses new art on approval and earned-stage replay',
      (tester) async {
        tester.view.physicalSize = Size(
          pet == Companion.rabbit ? 360 : 390,
          844,
        );
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final stock = (await tester.runAsync(
          () =>
              TestFamily.create(pet: pet.hasGroundSkill ? Companion.cat : pet),
        ))!;
        addTearDown(stock.dispose);
        final controller = FamilyController(stock.device, stock.rules)
          ..service = stock.service;
        addTearDown(controller.dispose);
        final threshold = stock.rules.thresholds[target - 2];
        await tester.runAsync(() async {
          final parent = await stock.service.pin.unlock(TestFamily.pin);
          if (pet.hasGroundSkill) {
            final price = stock.service.rules.companionUnlockPrice;
            for (var earned = 0; earned < price; earned += 5) {
              await stock.service.backfill(
                _earlier,
                stock.service.today,
                '',
                session: parent,
              );
            }
            await stock.service.unlockCompanion(pet);
            await stock.service.selectCompanion(pet);
          }
          for (var i = 0; i < threshold - 1; i++) {
            await stock.service.backfill(
              _earlier,
              stock.service.today,
              '',
              session: parent,
            );
          }
          final task = await stock.service.publish(_pending, session: parent);
          await stock.service.submit(task['instance_id'] as String, '');
          await controller.refresh();
          if (_output.isNotEmpty) {
            await Directory(_output).create(recursive: true);
            await (FontLoader(_family)..addFont(
                  File(_font).readAsBytes().then(ByteData.sublistView),
                ))
                .load();
            await (FontLoader('MaterialIcons')
                  ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
                .load();
          }
        });
        final beginning = controller.family!;
        expect(
          (beginning.stage, beginning.experience),
          (target - 1, threshold - 1),
        );
        final screen = GlobalKey();
        final root = find.byKey(screen);
        final film = find.byType(EvolutionMoment);
        final growth = find.byType(GrowthPage);
        Finder card(Finder inside, int stage, {bool reveal = false}) =>
            find.descendant(
              of: inside,
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is GrowthPortrait &&
                    widget.pet == pet &&
                    widget.stage == stage &&
                    widget.reveal == reveal,
              ),
            );

        final theme = gardenTheme();
        await tester.pumpWidget(
          RepaintBoundary(
            key: screen,
            child: _output.isEmpty
                ? CompanionsApp(controller: controller)
                : MaterialApp(
                    debugShowCheckedModeBanner: false,
                    locale: const Locale('zh', 'CN'),
                    supportedLocales: const [Locale('zh', 'CN')],
                    localizationsDelegates:
                        GlobalMaterialLocalizations.delegates,
                    theme: theme.copyWith(
                      textTheme: theme.textTheme.apply(fontFamily: _family),
                    ),
                    home: ListenableBuilder(
                      listenable: controller,
                      builder: (_, _) => FamilyHome(controller: controller),
                    ),
                  ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 350));
        await _tap(tester, find.text('成长'));
        await _wait(tester, card(growth, target - 1));
        expect(card(growth, target), findsNothing);
        await _tap(tester, find.byTooltip('家长入口'));
        await _wait(tester, find.byType(EditableText));
        await tester.enterText(find.byType(EditableText), TestFamily.pin);
        await _tap(tester, find.text('解锁'));
        await _wait(tester, find.text('返回儿童模式'));
        await _tap(tester, find.text(_pending.title));
        await _tap(tester, find.text('确认并入账 5 分'));
        await _wait(tester, film);
        expect(controller.family!.experience, threshold);
        expect(controller.family!.balance, beginning.balance + 5);
        expect(find.text('${pet.nickname}长大了'), findsOneWidget);
        if (pet == Companion.cat) {
          await _wait(tester, card(film, target));
          await _photo(tester, root, '${pet.name}-folded');
        }
        await _wait(tester, find.text('完成'));
        final open = card(film, target, reveal: true);
        await _wait(tester, open);
        final picture = find.descendant(of: open, matching: find.byType(Image));
        final displayed = tester.widget<Image>(picture).image as AssetImage;
        expect(displayed.assetName, growthArtwork(pet, target, reveal: true));
        await _photo(tester, root, '${pet.name}-awarded');
        await _tap(tester, find.text('完成'));
        await _tap(tester, find.text('返回儿童模式'));
        await _wait(tester, card(growth, target));
        final savedLedger = (await tester.runAsync(stock.service.ledger))!;
        await _photo(tester, root, '${pet.name}-growth');
        await _tap(tester, card(growth, 1));
        await _wait(tester, card(film, 1, reveal: true));
        expect(find.text(stageNames.first), findsOneWidget);
        await _tap(tester, find.text('完成'));
        await _tap(tester, find.text('回看进化'));
        await _wait(tester, find.text('完成'));
        await _wait(tester, card(film, target, reveal: true));
        await _tap(tester, find.text('完成'));
        expect((await tester.runAsync(stock.service.ledger))!, savedLedger);
        expect(
          (controller.family!.stage, controller.family!.experience),
          (target, threshold),
        );
      },
    );
  }
}
