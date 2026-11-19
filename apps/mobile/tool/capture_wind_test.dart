// At the repository root, with Flutter on PATH:
// python3 tools/capture_wind_video.py --capture /absolute/output/directory
// Each route uses its own flutter test process and an isolated SQLite family.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:alice_companions/features/garden.dart' show gardenTheme;
import 'package:alice_companions/features/wind_chapter.dart';
import 'package:alice_companions/illustration/wind_sound.dart';
import 'package:alice_companions/illustration/wind_stage.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../test/support/families.dart';

const fps = 15;
const frames = 840;
const scale = 2.0;
const viewport = Size(390, 844);
const pickAt = [214, 314, 400, 510, 646];
const seatAt = [252, 342, 430, 540, 675];

Future<void> loadReviewFonts() async {
  const sans = String.fromEnvironment('ALICE_CJK_FONT');
  const serif = String.fromEnvironment('ALICE_CJK_SERIF');
  if (sans.isEmpty) throw ArgumentError('Provide ALICE_CJK_FONT');
  Future<void> register(String name, String path) async {
    final bytes = await File(path).readAsBytes();
    final loader = FontLoader(name);
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
  }

  final icons = FontLoader('MaterialIcons');
  icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await Future.wait([
    register('Roboto', sans),
    register('serif', serif.isEmpty ? sans : serif),
    icons.load(),
  ]);
}

// Let asynchronous SQLite operations and image decoders complete between shots
// while the Flutter simulation clock stays at exactly the same time.
Future<void> waitFor(WidgetTester tester, bool Function() ready) async {
  final watch = Stopwatch()..start();
  while (!ready()) {
    expect(tester.takeException(), isNull);
    if (watch.elapsed > const Duration(seconds: 30)) {
      fail('The chapter did not reach the expected state.');
    }
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 8)),
    );
    await tester.pump();
  }
}

void main() {
  const target = String.fromEnvironment('ALICE_WIND_OUTPUT');
  for (final farFirst in [true, false]) {
    final name = farFirst ? 'far-first' : 'middle-first';
    final panes = farFirst ? [8, 11, 9, 10, 7] : [7, 11, 8, 10, 9];
    final stills = farFirst
        ? {
            8: 'opening',
            59: 'scarf',
            97: 'basket',
            188: 'window-gaps',
            236: 'leaf-in-hand',
            571: 'far-light-gap',
            710: 'crossing',
            750: 'homecoming',
            810: 'reunion',
          }
        : {
            300: 'middle-path',
            571: 'middle-first-four',
            810: 'middle-first-reunion',
          };

    testWidgets(
      'record production chapter $name',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = viewport;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final stock = (await tester.runAsync(TestFamily.create))!;
        var disposed = false;
        addTearDown(() async {
          if (!disposed) {
            await stock.service.db.close();
            await stock.root.delete(recursive: true);
          }
        });
        final initial = (await tester.runAsync(stock.service.windProgress))!;
        final output = Directory(target);
        final images = Directory('${output.path}/frames');
        final gallery = Directory('${output.path}/stills');
        await tester.runAsync(() async {
          await loadReviewFonts();
          await images.create(recursive: true);
          await gallery.create(recursive: true);
        });

        var frame = 0;
        final events = <Map<String, Object?>>[];
        final taps = <Map<String, Object>>[];
        final markers = <Map<String, Object>>[];
        final messenger = tester.binding.defaultBinaryMessenger;
        const audio = MethodChannel('alice/wind-sound');
        messenger.setMockMethodCallHandler(audio, (call) async {
          if (['play', 'setMuted', 'stop'].contains(call.method)) {
            events.add({
              'frame': frame,
              'method': call.method,
              'argument': call.arguments,
            });
          }
          return call.method == 'isMuted' ? false : null;
        });
        addTearDown(() => messenger.setMockMethodCallHandler(audio, null));

        debugPrint('[$name] assets and SQLite fixture ready');
        final screen = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: screen,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: gardenTheme(),
              locale: const Locale('zh', 'CN'),
              supportedLocales: const [Locale('zh', 'CN')],
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              home: WindChapter(
                service: stock.service,
                initial: initial,
                initialMuted: false,
                hasNotebook: false,
                openNotebook: (_) async {
                  fail('Unexpected navigation');
                },
              ),
            ),
          ),
        );
        // Wait for a decoded painting. Loading and fixture setup are outside the
        // film. The first recorded frame uses the opening shot at time zero.
        await waitFor(
          tester,
          () => find
              .byKey(const ValueKey('wind-fox-status'))
              .evaluate()
              .isNotEmpty,
        );
        debugPrint('[$name] opening is on screen');
        WindStage stage() => tester.widget<WindStage>(find.byType(WindStage));
        final painting = find
            .descendant(
              of: find.byType(WindStage),
              matching: find.byType(RepaintBoundary),
            )
            .first;
        final canvas = tester.getRect(painting);
        if (!farFirst) {
          await tester.tap(find.byTooltip('静音'));
          await tester.pump();
          expect(find.byTooltip('开启声音'), findsOneWidget);
        }
        int micros(int n) => n * 1000000 ~/ fps;
        var mask = 0;
        for (frame = 0; frame < frames; frame++) {
          if (frame > 0) {
            await tester.pump(
              Duration(microseconds: micros(frame) - micros(frame - 1)),
            );
          }
          if (frame % 150 == 0) {
            debugPrint('[$name] frame $frame');
          }
          if (frame == 168) {
            await waitFor(tester, () => stage().phase == WindPhase.playing);
          }
          if (pickAt.contains(frame)) {
            await tester.tap(find.byKey(const ValueKey('wind-basket')));
            await tester.pump();
            expect(stage().holding, isTrue);
            taps.add({'frame': frame, 'target': 'basket', 'mask': mask});
          }
          if (seatAt.contains(frame)) {
            final pane = panes[seatAt.indexOf(frame)];
            debugPrint('[$name] frame $frame placing pane $pane');
            await tester.tap(find.byKey(ValueKey('wind-pane-$pane')));
            mask |= 1 << (pane - 7);
            await waitFor(
              tester,
              () => stage().mask == mask && !stage().holding,
            );
            taps.add({'frame': frame, 'target': 'pane-$pane', 'mask': mask});
          }
          final caption = stills[frame];
          if (farFirst || caption != null) {
            final border =
                screen.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final title = frame.toString().padLeft(4, '0');
            await tester.runAsync(() async {
              final shot = await border.toImage(pixelRatio: scale);
              try {
                final data = await shot.toByteData(
                  format: ui.ImageByteFormat.png,
                );
                final png = data!.buffer.asUint8List(
                  data.offsetInBytes,
                  data.lengthInBytes,
                );
                if (farFirst) {
                  await File('${images.path}/frame-$title.png')
                      .writeAsBytes(png);
                }
                if (caption != null) {
                  await File('${gallery.path}/$caption.png').writeAsBytes(png);
                }
              } finally {
                shot.dispose();
              }
            });
            if (caption != null) {
              markers.add({
                'frame': frame,
                'file': '$caption.png',
                'mask': mask,
                'phase': stage().phase.name,
              });
            }
          }
        }
        expect(stage().phase, WindPhase.complete);
        expect(stage().mask, 31);
        expect(find.text('回暖廊看窗光'), findsOneWidget);
        final played = events
            .where((e) => e['method'] == 'play')
            .map((e) => e['argument']);
        if (farFirst) {
          expect(played.toSet(), WindCue.values.map((e) => e.name).toSet());
          expect(played.where((name) => name == 'seatLeaf'), hasLength(5));
        } else {
          expect(played, isEmpty);
        }
        await tester.runAsync(() async {
          final home = (await stock.service.overview())!;
          expect(
            (home.windowsLit, home.experience, home.balance),
            (true, 0, 0),
          );
          expect(await stock.service.ledger(), isEmpty);
          final report = {
            'route': name,
            'muted': !farFirst,
            'fps': fps,
            'frames': frames,
            'width': (viewport.width * scale).round(),
            'height': (viewport.height * scale).round(),
            'stageRect': [
              for (final v in [
                canvas.left,
                canvas.top,
                canvas.right,
                canvas.bottom,
              ])
                (v * scale).round(),
            ],
            'inputs': taps,
            'audio': events,
            'stills': markers,
            'final': {
              'mask': stage().mask,
              'windowsLit': home.windowsLit,
              'experience': home.experience,
              'balance': home.balance,
            },
          };
          await File('${output.path}/$name.json').writeAsString(
            '${const JsonEncoder.withIndent('  ').convert(report)}\n',
          );
        });
        debugPrint('[$name] progress and cue report saved');
        if (!farFirst) {
          await tester.tap(find.byTooltip('开启声音'));
          await tester.pump();
        }
        await tester.pumpWidget(const SizedBox.shrink());
        debugPrint('[$name] chapter closed');
        // The last database command started inside a fixed-clock frame; drain
        // its serial queue inside the same clock before leaving the widget test.
        final closing = stock.dispose().then((_) => disposed = true);
        await waitFor(tester, () => disposed);
        await closing;
        debugPrint('[$name] capture finished');
      },
      skip: target.isEmpty,
      variant: TargetPlatformVariant.only(TargetPlatform.android),
      timeout: const Timeout(Duration(minutes: 15)),
    );
  }
}
