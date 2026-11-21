import 'dart:io';
import 'dart:ui' as ui;

import 'package:alice_companions/application/controller.dart';
import 'package:alice_companions/application/family.dart';
import 'package:alice_companions/domain/layout_rules.dart';
import 'package:alice_companions/features/garden.dart' show gardenTheme;
import 'package:alice_companions/features/home.dart';
import 'package:alice_companions/illustration/animated_backdrop.dart';
import 'package:alice_companions/illustration/florist_art.dart';
import 'package:alice_companions/illustration/puppet.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/families.dart';

const _frames = String.fromEnvironment('FLORIST_FRAMES');
const _captureFont = String.fromEnvironment('ALICE_CJK_FONT');
final _shopTray = _key('florist-shop-tray');
final _worktop = _key('florist-worktop');
final _closeTray = _key('florist-close-tray');

Finder _key(String label) => find.byKey(ValueKey(label));

Finder _image(String path) => find.byWidgetPredicate(
  (widget) =>
      widget is Image &&
      widget.image is AssetImage &&
      (widget.image as AssetImage).assetName == path,
);

Future<void> _show(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 40 && !tester.any(finder); attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(finder, findsOneWidget);
}

Future<void> _capture(WidgetTester tester, GlobalKey root, String label) async {
  if (_frames.isEmpty) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(root));
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    try {
      final png = (await image.toByteData(format: ui.ImageByteFormat.png))!;
      await Directory(_frames).create(recursive: true);
      await File('$_frames/$label.png').writeAsBytes(
        png.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes),
      );
    } finally {
      image.dispose();
    }
  });
}

void main() {
  testWidgets('the owned flower shop opens a six-hole workbench in play', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final stock = (await tester.runAsync(TestFamily.create))!;
    addTearDown(stock.dispose);
    final controller = FamilyController(stock.device, stock.rules)
      ..service = stock.service;
    addTearDown(controller.dispose);
    final root = GlobalKey();
    var theme = gardenTheme();
    await tester.runAsync(() async {
      await controller.refresh();
      if (_captureFont.isEmpty) return;
      final bytes = await File(_captureFont).readAsBytes();
      await (FontLoader(
        'FloristCaption',
      )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
      theme = theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamily: 'FloristCaption'),
        filledButtonTheme: FilledButtonThemeData(
          style: theme.filledButtonTheme.style!.copyWith(
            textStyle: const WidgetStatePropertyAll(
              TextStyle(
                fontFamily: 'FloristCaption',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
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
          home: ListenableBuilder(
            listenable: controller,
            builder: (context, _) => FamilyHome(controller: controller),
          ),
        ),
      ),
    );

    Future<void> openSpaces() async {
      final spaces = find.text('空间');
      await Scrollable.ensureVisible(tester.element(spaces), alignment: .5);
      await tester.pump();
      await _show(tester, spaces.hitTestable());
      await tester.runAsync(() => tester.tap(spaces.hitTestable()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    Future<void> back() async {
      await tester.tap(find.byType(BackButton).hitTestable());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump();
    }

    Future<void> tapWorkbench(Finder trigger) async {
      await tester.tap(trigger.hitTestable());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(_closeTray, findsOneWidget);
    }

    void expectFlowers(String view, Set<int> planted) {
      for (var hole = 1; hole <= 6; hole++) {
        expect(
          _key('florist-$view-flower-$hole'),
          planted.contains(hole) ? findsOneWidget : findsNothing,
        );
      }
    }

    final entry = find.text('进入花店');
    await openSpaces();
    await _show(tester, find.textContaining('进入'));
    expect(entry, findsNothing);
    await back();

    final ledger = await tester.runAsync(() async {
      final session = await stock.service.pin.unlock(TestFamily.pin);
      for (var task = 0; task < 24; task++) {
        await stock.service.backfill(
          const TaskDraft('测试任务A', '', '测试标准A', 'challenge'),
          stock.service.today,
          '',
          session: session,
        );
      }
      await stock.service.purchase('flower_shop');
      await controller.refresh();
      return stock.service.ledger();
    });
    expect(controller.family!.balance, 0);
    final experience = controller.family!.experience;
    await tester.pump();
    await openSpaces();
    await _show(tester, entry);

    Future<void> enterShop() async {
      await Scrollable.ensureVisible(tester.element(entry), alignment: .5);
      await tester.pump();
      await tester.runAsync(() => tester.tap(entry.hitTestable()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await _show(tester, _shopTray);
    }

    await enterShop();
    final background = find.byWidgetPredicate(
      (widget) =>
          widget is AnimatedBackdrop &&
          widget.asset == 'assets/art/florist-room.webp',
    );
    expect(background, findsOneWidget);
    await tester.runAsync(() async {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final paths = manifest.listAssets().where(
        (path) => path.startsWith('assets/art/florist-'),
      );
      expect(paths, hasLength(19));
      final context = tester.element(_shopTray);
      await Future.wait([
        for (final path in paths) precacheImage(AssetImage(path), context),
      ]);
    });
    await tester.pump();
    expect(tester.getSize(_worktop).height, greaterThanOrEqualTo(48));
    expectFlowers('shop', {});
    await _capture(tester, root, 'phone-shop-empty');

    final rack = _image(FloristRack.art);
    final shadow = _image(FloristRack.shadow);
    final actor = _key('home-companion');
    Offset spot(double x, double y) {
      final scene = tester.getRect(background);
      return scene.topLeft + Offset(x * scene.width, y * scene.height);
    }

    Future<void> walkTo(Offset floor) async {
      await tester.tapAt(floor);
      final companion = find.byType(IllustratedPet);
      for (var frame = 0; frame < 160; frame++) {
        await tester.pump(const Duration(milliseconds: 40));
        if (tester.widget<IllustratedPet>(companion).walking() == 0) return;
      }
      fail('The companion did not settle after the tap.');
    }

    int displayOrder(Finder target) {
      final children = tester
          .widget<Stack>(
            find.ancestor(of: actor, matching: find.byType(Stack)).first,
          )
          .children;
      final node = target == actor
          ? actor
          : find.ancestor(of: target, matching: find.byType(Positioned)).first;
      final index = children.indexOf(tester.widget<Positioned>(node));
      expect(index, isNonNegative);
      return index;
    }

    final behind = spot(.8, .835);
    await walkTo(behind);
    expect(tester.getRect(actor).bottom, closeTo(behind.dy, .5));
    expect(displayOrder(shadow), lessThan(displayOrder(actor)));
    expect(displayOrder(actor), lessThan(displayOrder(rack)));
    await _capture(tester, root, 'phone-rack-behind');

    final front = spot(.8, .947);
    await walkTo(front);
    expect(tester.getRect(actor).bottom, closeTo(behind.dy, .5));
    final aisle = spot(.54, .932);
    await walkTo(aisle);
    expect(tester.getRect(actor).center.dx, closeTo(aisle.dx, .5));
    await walkTo(front);
    expect(tester.getRect(actor).bottom, closeTo(front.dy, .5));
    expect(displayOrder(rack), lessThan(displayOrder(actor)));
    expect(displayOrder(shadow), lessThan(displayOrder(actor)));
    await _capture(tester, root, 'phone-rack-front');

    await walkTo(aisle);
    await walkTo(spot(.75, .901));
    expect(tester.getRect(actor).bottom, closeTo(aisle.dy, .5));
    expect(tester.getRect(actor).center.dx, closeTo(aisle.dx, .5));

    await tapWorkbench(_worktop);
    expect(find.text('0 枝花 · 6 个空孔'), findsOneWidget);
    await _capture(tester, root, 'phone-workbench-0');
    for (final hole in [4, 5, 6, 1, 2, 3]) {
      final control = _key('florist-hole-$hole');
      final size = tester.getSize(control);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      await tester.tap(control.hitTestable());
      await tester.pump();
      if (hole == 6) {
        expectFlowers('close', {4, 5, 6});
        expect(find.text('3 枝花 · 3 个空孔'), findsOneWidget);
        await _capture(tester, root, 'phone-workbench-3');
      }
    }
    expectFlowers('close', {1, 2, 3, 4, 5, 6});
    expect(find.text('6 枝花 · 0 个空孔'), findsOneWidget);
    await _capture(tester, root, 'phone-workbench-6');
    await tester.tap(_key('florist-hole-6').hitTestable());
    await tester.pump();
    expectFlowers('close', {1, 2, 3, 4, 5});
    expect(find.text('5 枝花 · 1 个空孔'), findsOneWidget);
    await _capture(tester, root, 'phone-workbench-5');

    await back();
    expectFlowers('shop', {1, 2, 3, 4, 5});
    await _capture(tester, root, 'phone-shop-five');
    await tapWorkbench(find.text('分束'));
    expect(find.text('5 枝花 · 1 个空孔'), findsOneWidget);
    tester.view.physicalSize = const Size(1024, 768);
    await tester.pump();
    await _capture(tester, root, 'tablet-workbench-5');
    expect(_key('florist-hole-6').hitTestable(), findsOneWidget);
    await back();
    await back();
    await enterShop();
    expectFlowers('shop', {});

    final after = await tester.runAsync(stock.service.overview);
    expect((after?.balance, after?.experience), (0, experience));
    expect(await tester.runAsync(stock.service.ledger), ledger);

    // A saved shop can already contain furniture placed there by older apps.
    await back();
    await back();
    final oldFurniture = await tester.runAsync(() async {
      final service = stock.service;
      final session = await service.pin.unlock(TestFamily.pin);
      const extras = ['decor_plant', 'single_bed', 'bundle_starlight'];
      final price = extras.fold<int>(
        0,
        (total, item) => total + (stock.rules.catalog[item]!['price'] as int),
      );
      for (var points = 0; points < price; points += 5) {
        await service.backfill(
          const TaskDraft('测试任务B', '', '测试标准B', 'challenge'),
          service.today,
          '',
          session: session,
        );
      }
      for (final item in extras) {
        await service.purchase(item);
      }
      final shop = (await service.spaces()).singleWhere(
        (room) => room['scene_id'] == 'flower_shop',
      );
      final shopId = shop['id'] as String;
      final priorLayout = await service.layout(shopId);
      const furniture = {
        'decor_plant',
        'single_bed',
        'bundle_starlight_bed',
        'bundle_starlight_cabinet',
        'bundle_starlight_rug',
      };
      await service.saveLayout(shopId, shop['layout_version'] as int, [
        ...priorLayout.map(PlacementDraft.fromRow),
        for (final (index, item) in (await service.items()).indexed)
          if (furniture.contains(item['item_id']))
            PlacementDraft(
              item['id'] as String,
              .72,
              .86,
              index + priorLayout.length,
            ),
      ]);
      final saved = await service.layout(shopId);
      await stock.reopen();
      controller.service = stock.service;
      await controller.refresh();
      expect(await stock.service.layout(shopId), saved);
      return saved;
    });
    expect(oldFurniture, hasLength(8));
    await tester.pump();
    await openSpaces();
    await _show(tester, entry);
    await enterShop();
    expect(rack, findsOneWidget);
    final furniturePaths = [
      'assets/art/installed_decor_plant.webp',
      'assets/art/installed_single_bed.webp',
      'assets/art/suite_starlight.webp',
    ];
    final rackFrame = tester.getRect(rack);
    for (final path in furniturePaths) {
      final item = _image(path);
      expect(item, findsOneWidget);
      expect(rackFrame.overlaps(tester.getRect(item)), isFalse, reason: path);
    }
    await tester.runAsync(
      () => Future.wait([
        for (final path in furniturePaths)
          precacheImage(AssetImage(path), tester.element(rack)),
      ]),
    );
    await tester.pump();
    await walkTo(spot(.245, .938));
    await _capture(tester, root, 'tablet-shop-with-legacy-furniture');
    await tester.pumpWidget(const SizedBox());
  });
}
