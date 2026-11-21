import 'dart:io';
import 'dart:ui' as ui;

import 'package:alice_companions/application/controller.dart';
import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/domain/rain_map.dart';
import 'package:alice_companions/domain/wind_progress.dart';
import 'package:alice_companions/features/garden.dart' show gardenTheme;
import 'package:alice_companions/features/home.dart';
import 'package:alice_companions/illustration/reading_veranda.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/families.dart';

const _frames = String.fromEnvironment('READING_VERANDA_FRAMES');
const _captionFont = String.fromEnvironment('ALICE_CJK_FONT');

Finder _paint(String path) => find.byWidgetPredicate(
  (widget) =>
      widget is Image &&
      widget.image is AssetImage &&
      (widget.image as AssetImage).assetName == path,
);

void main() {
  testWidgets(
    'the veranda light and reading stool follow real story progress',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final stock = (await tester.runAsync(
        () => TestFamily.create(pet: Companion.cat),
      ))!;
      addTearDown(stock.dispose);
      final controller = FamilyController(stock.device, stock.rules)
        ..service = stock.service;
      addTearDown(controller.dispose);
      final root = GlobalKey();
      var theme = gardenTheme();
      await tester.runAsync(() async {
        await controller.refresh();
        if (_captionFont.isEmpty) return;
        final data = ByteData.sublistView(
          await File(_captionFont).readAsBytes(),
        );
        await (FontLoader(
          'VerandaCaption',
        )..addFont(Future.value(data))).load();
        await (FontLoader('serif')..addFont(Future.value(data))).load();
        await (FontLoader(
          'MaterialIcons',
        )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
        theme = theme.copyWith(
          textTheme: theme.textTheme.apply(fontFamily: 'VerandaCaption'),
        );
      });
      await tester.pumpWidget(
        RepaintBoundary(
          key: root,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            locale: const Locale('zh', 'CN'),
            supportedLocales: const [Locale('zh', 'CN')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
            home: ListenableBuilder(
              listenable: controller,
              builder: (context, _) => FamilyHome(controller: controller),
            ),
          ),
        ),
      );
      final veranda = find.text('暖廊').hitTestable();
      await tester.tap(veranda);
      await tester.pump();
      final gold = _paint(ReadingVeranda.gold);
      final stained = _paint(ReadingVeranda.stained);
      final windows = _paint(ReadingVeranda.windows);
      final room = _paint(ReadingVeranda.room);
      final stool = _paint(ReadingVeranda.stool.art);
      final scroll = _paint(ReadingVeranda.rolledMap.art);
      final read = find.text('看地图');
      expect(room, findsOneWidget);
      expect(gold, findsOneWidget);
      expect(windows, findsNothing);
      expect(stool, findsNothing);
      expect(read, findsNothing);

      await tester.runAsync(() async {
        final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
        final paths = manifest.listAssets().where(
          (path) =>
              path.startsWith('assets/art/reading-veranda-') ||
              path.startsWith('assets/art/rain-map-'),
        );
        final context = tester.element(room);
        await Future.wait([
          for (final path in [...paths, Companion.cat.artwork(1)])
            precacheImage(AssetImage(path), context),
        ]);
      });
      await tester.pump();

      Future<void> capture(String name) async {
        if (_frames.isEmpty) return;
        final frame = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(root),
        );
        await tester.runAsync(() async {
          final image = await frame.toImage();
          try {
            final png = (await image.toByteData(
              format: ui.ImageByteFormat.png,
            ))!;
            await Directory(_frames).create(recursive: true);
            await File('$_frames/$name.png').writeAsBytes(
              png.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes),
            );
          } finally {
            image.dispose();
          }
        });
      }

      await capture('phone-day');
      await tester.runAsync(() async {
        final opened = await stock.service.beginWindStory();
        await stock.service.placeWindLeaf(0, run: opened.run);
        await controller.refresh();
      });
      await tester.pump();
      expect(gold, findsOneWidget);
      expect(stained, findsNothing);
      await tester.runAsync(() async {
        final current = await stock.service.windProgress();
        for (var slot = 1; slot < WindProgress.slots; slot++) {
          await stock.service.placeWindLeaf(slot, run: current.run);
        }
        await controller.refresh();
      });
      await tester.pump();
      expect(gold, findsNothing);
      expect(stained, findsOneWidget);
      expect(windows, findsOneWidget);
      expect(stool, findsNothing);
      await capture('phone-restored');

      await tester.runAsync(() async {
        final journey = await stock.service.beginRainMap();
        for (var group = 0; group < RainMapProgress.groupCount; group++) {
          for (var stone = 0; stone < RainMapProgress.groupSize; stone++) {
            await stock.service.stepRainMapStone(
              run: journey.run,
              group: group,
              stone: stone,
            );
          }
          await stock.service.stampRainMap(run: journey.run, group: group);
        }
        await stock.reopen();
        controller.service = stock.service;
        await controller.refresh();
      });
      await tester.pump();
      expect(stool, findsOneWidget);
      expect(scroll, findsOneWidget);
      expect(read.hitTestable(), findsOneWidget);

      final rect = tester.getRect(room);
      Offset screen(Offset point) =>
          rect.topLeft + Offset(point.dx * rect.width, point.dy * rect.height);
      await tester.tapAt(screen(const Offset(.30, .87)));
      await tester.pump();
      await capture('phone-stool');
      await tester.tapAt(screen(ReadingVeranda.mapCenter));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 430));
      expect(stool, findsOneWidget);
      expect(scroll, findsNothing);
      for (var stamp = 1; stamp <= 4; stamp++) {
        expect(find.byKey(ValueKey('rain-map-art-ink-$stamp')), findsOneWidget);
      }
      await capture('phone-unrolled');
      await tester.tapAt(const Offset(14, 30));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump();
      expect(scroll, findsOneWidget);
      tester.view.physicalSize = const Size(1024, 768);
      await tester.pump();
      await tester.tap(read.hitTestable());
      await tester.pump();
      expect(find.byKey(const ValueKey('rain-map-art-ink-4')), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 430));
      await capture('tablet-unrolled');

      final summary = await tester.runAsync(stock.service.overview);
      expect((summary?.balance, summary?.experience), (0, 0));
      expect(await tester.runAsync(stock.service.ledger), isEmpty);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
