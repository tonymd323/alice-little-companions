import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/domain/layout_rules.dart';
import 'package:alice_companions/domain/rules.dart';
import 'package:alice_companions/features/garden.dart' show gardenTheme;
import 'package:alice_companions/illustration/companion_walk_art.dart'
    show walkAssets;
import 'package:alice_companions/illustration/living_scene.dart';
import 'package:alice_companions/illustration/puppet.dart';
import 'package:alice_companions/illustration/rain_courtyard.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _capturePath = String.fromEnvironment('RAIN_COURTYARD_FRAMES');
const _captureFont = String.fromEnvironment('ALICE_CJK_FONT');
const _woodPath = 'assets/art/rain-courtyard-wood.webp';
const _width = 768;
const _height = 512;

void _viewport(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Future<void> _loadLayers(
  WidgetTester tester,
  BuildContext context, {
  List<String> also = const [],
}) async {
  await tester.runAsync(() async {
    final bundle = await AssetManifest.loadFromAssetBundle(rootBundle);
    final paths = bundle.listAssets().where(
      (asset) => asset.startsWith('assets/art/rain-courtyard-'),
    );
    expect(paths, hasLength(7));
    await Future.wait([
      for (final path in {...paths, ...also})
        precacheImage(AssetImage(path), context),
    ]);
  });
  await tester.pump();
}

Future<Uint32List> _pixels(
  WidgetTester tester,
  RenderRepaintBoundary boundary, {
  String? filename,
}) async {
  return (await tester.runAsync(() async {
    final image = await boundary.toImage();
    try {
      if (filename != null && _capturePath.isNotEmpty) {
        await Directory(_capturePath).create(recursive: true);
        final png = (await image.toByteData(format: ui.ImageByteFormat.png))!;
        await File('$_capturePath/$filename.png').writeAsBytes(
          png.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes),
        );
      }
      final data = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;
      return data.buffer.asUint32List(
        data.offsetInBytes,
        image.width * image.height,
      );
    } finally {
      image.dispose();
    }
  }))!;
}

Future<List<int>> _opaqueWoodSamples(WidgetTester tester) async {
  final rect = tester.getRect(
    find.byKey(const ValueKey('rain-courtyard-wood')),
  );
  return (await tester.runAsync(() async {
    final data = await rootBundle.load(_woodPath);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
    final art = (await codec.getNextFrame()).image;
    try {
      final rgba = (await art.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      final samples = <int>[];
      for (var y = rect.top.ceil(); y < rect.bottom.floor(); y++) {
        for (var x = rect.left.ceil(); x < rect.right.floor(); x++) {
          final u = ((x + .5 - rect.left) * art.width / rect.width).floor();
          final v = ((y + .5 - rect.top) * art.height / rect.height).floor();
          // Skip translucent edges and the neighboring pixels used for filtering.
          if (u < 3 || v < 3 || u + 3 >= art.width || v + 3 >= art.height)
            continue;
          var opaque = true;
          for (var dy = -3; dy <= 3 && opaque; dy++) {
            for (var dx = -3; dx <= 3 && opaque; dx++) {
              opaque =
                  rgba.getUint8(((v + dy) * art.width + u + dx) * 4 + 3) == 255;
            }
          }
          if (opaque) samples.add(y * _width + x);
        }
      }
      return samples;
    } finally {
      art.dispose();
      codec.dispose();
    }
  }))!;
}

int _changed(Uint32List first, Uint32List next, Rect area) {
  var count = 0;
  for (var y = area.top.toInt(); y < area.bottom.toInt(); y++) {
    for (var x = area.left.toInt(); x < area.right.toInt(); x++) {
      final i = y * _width + x;
      if (first[i] != next[i]) count++;
    }
  }
  return count;
}

void main() {
  testWidgets('125 painted courtyard frames keep all sampled wood steady', (
    tester,
  ) async {
    _viewport(tester, Size(_width.toDouble(), _height.toDouble()));
    final clock = ValueNotifier(0.0);
    addTearDown(clock.dispose);
    final key = GlobalKey();

    Widget picture({required bool still}) => Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(
        key: key,
        child: Stack(
          fit: StackFit.expand,
          children: [
            RainCourtyardArt(
              clock: clock,
              seconds: () => clock.value,
              still: still,
            ),
            RainCourtyardArt(
              clock: clock,
              seconds: () => clock.value,
              still: still,
              foreground: true,
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(picture(still: false));
    await _loadLayers(tester, key.currentContext!);
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(key),
    );
    final wood = await _opaqueWoodSamples(tester);
    expect(wood.length, greaterThan(5000));

    const regions = [
      Rect.fromLTRB(370, 100, 475, 178),
      Rect.fromLTRB(102, 235, 160, 282),
      Rect.fromLTRB(638, 407, 758, 437),
      Rect.fromLTRB(0, 397, 188, 512),
    ];
    final peak = List<int>.filled(regions.length, 0);
    final first = await _pixels(tester, boundary, filename: 'loop-000');
    for (var frame = 1; frame <= 125; frame++) {
      clock.value = frame / 25;
      await tester.pump();
      final next = await _pixels(
        tester,
        boundary,
        filename: frame < 125
            ? 'loop-${frame.toString().padLeft(3, '0')}'
            : null,
      );
      expect(
        wood.any((pixel) => first[pixel] != next[pixel]),
        isFalse,
        reason: 'painted wood at frame $frame',
      );
      for (var region = 0; region < regions.length; region++) {
        final count = _changed(first, next, regions[region]);
        if (count > peak[region]) peak[region] = count;
      }
      if (frame == 125) expect(next, orderedEquals(first));
    }
    expect(peak, everyElement(greaterThan(50)));

    await tester.pumpWidget(picture(still: true));
    final still = await _pixels(tester, boundary);
    clock.value = 1.7;
    await tester.pump();
    expect(await _pixels(tester, boundary), orderedEquals(still));
    if (_capturePath.isNotEmpty) {
      await tester.runAsync(
        () => File('$_capturePath/pixel-check.txt').writeAsString(
          '125 frames sampled 40 ms apart; 5 s loop endpoint compared\n'
          '${wood.length} protected wood samples per frame; changed 0\n'
          'Peak changed pixels for canopy, ladder leaves, ripples, foreground: $peak\n'
          'Reduced-motion capture also remained unchanged\n',
        ),
      );
    }
  });

  testWidgets('rain courtyard uses the original walking boundary', (
    tester,
  ) async {
    _viewport(tester, const Size(768, 576));
    final theme = gardenTheme();
    if (_captureFont.isNotEmpty) {
      await tester.runAsync(() async {
        final bytes = await File(_captureFont).readAsBytes();
        await (FontLoader(
          'CourtyardCaption',
        )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
        await (FontLoader(
          'MaterialIcons',
        )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
      });
    }
    final config = await Future.wait([
      for (final name in ['rules', 'catalog', 'scene_slots'])
        rootBundle.loadString('assets/config/$name.json'),
    ]);
    final rules = Rules.decode(config[0], config[1], config[2]);
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _captureFont.isEmpty
            ? theme
            : theme.copyWith(
                textTheme: theme.textTheme.apply(
                  fontFamily: 'CourtyardCaption',
                ),
              ),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: RepaintBoundary(
              key: key,
              child: GardenScene(
                companion: Companion.fox,
                stage: 1,
                rules: rules,
                scene: SceneDefinition(rules, 'base_room'),
                afterRain: true,
                playable: true,
                height: 567,
                showLabel: false,
              ),
            ),
          ),
        ),
      ),
    );
    await _loadLayers(
      tester,
      key.currentContext!,
      also: [
        Companion.fox.artwork(1),
        'assets/art/leap-fox-1.webp',
        ...walkAssets(Companion.fox, null),
      ],
    );
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(key),
    );
    final court = tester.getRect(
      find.byKey(const ValueKey('rain-courtyard-base')),
    );
    final actor = find.byKey(const ValueKey('home-companion'));
    final pet = find.byType(IllustratedPet);
    const frameStep = Duration(milliseconds: 40);

    Future<void> finishMoving() async {
      await tester.pump(frameStep);
      expect(tester.widget<IllustratedPet>(pet).walkPose?.call(), isNotNull);
      for (var frame = 0; frame < 100; frame++) {
        await tester.pump(frameStep);
      }
      expect(tester.widget<IllustratedPet>(pet).walkPose?.call(), isNull);
    }

    Offset screen(double x, double y) =>
        court.topLeft + Offset(x / 1536 * court.width, y / 1024 * court.height);

    for (final (label, point) in [
      ('far', screen(557, 763)),
      ('near', screen(685, 927)),
    ]) {
      await tester.tapAt(point);
      await finishMoving();
      final shown = tester.getRect(actor);
      expect(shown.center.dx, closeTo(point.dx, .1));
      expect(shown.bottom - shown.width / 6, closeTo(point.dy, .1));
      if (_capturePath.isNotEmpty)
        await _pixels(tester, boundary, filename: label);
    }

    final before = tester.getRect(actor);
    await tester.tapAt(screen(1395, 844));
    await tester.pump();
    expect(
      tester.getRect(actor),
      before,
      reason: 'stream water is not walkable',
    );
    await tester.tap(find.text('过来'));
    await finishMoving();
    expect(tester.getRect(actor), isNot(before));
    expect(tester.takeException(), isNull);
  });
}
