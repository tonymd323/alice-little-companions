import 'dart:convert';

import 'package:alice_companions/illustration/wind_stage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// These tests exercise shot timing and input independently of the production
// paintings. The device recordings exercise the real asset bundle.
class _TimingBundle extends CachingAssetBundle {
  static final png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAMAAAACCAIAAAASFvFNAAAAFUlEQVR4nGM8'
    '1SLOwMDAwMDAxAADABoJAWmxZMNtAAAAAElFTkSuQmCC',
  );

  @override
  Future<ByteData> load(String key) async {
    final layer = {
      'path': 'scene.png',
      'rect': [0, 0, 1, 1],
    };
    Object? manifest;
    if (key == 'assets/wind/room/room.json') {
      manifest = {
        'size': [3, 4],
        'base': layer,
        'cells': List.filled(12, layer),
        'lights': List.filled(3, layer),
        'rail': layer,
        'bridge': [
          [.16, .59],
          [.49, .55],
          [.82, .59],
        ],
        'actors': {
          'rabbit': [.37, .87],
          'basket': [.62, .875],
          'door': [.94, .82],
        },
      };
    } else if (key == 'assets/wind/actors/poses.json') {
      const names = [
        'rabbit_idle',
        'rabbit_notice',
        'rabbit_listen',
        'rabbit_catch',
        'rabbit_guard',
        'rabbit_reach',
        'rabbit_lower',
        'rabbit_push',
        'rabbit_push_low',
        'rabbit_stretch',
        'rabbit_stretch_low',
        'rabbit_recoil',
        'rabbit_wavelift',
        'rabbit_wave',
        'fox_wait',
        'fox_look',
        'fox_run1',
        'fox_run2',
        'fox_run3',
        'fox_run4',
        'fox_brake',
        'fox_arrive',
      ];
      final markers = {
        for (final marker in [
          'nearPaw',
          'farPaw',
          'nose',
          'nearEarTip',
          'farEarTip',
          'nearEye',
          'knot',
        ])
          marker: [.65, .65],
      };
      manifest = {
        'canvas': [512, 448],
        'ground': [.47, .9],
        'actors': {
          for (final name in names) name: {'markers': markers},
        },
        'props': {
          'basket': {
            'size': [512, 234],
            'ground': [.5, 1],
            'leftRim': [.08, .37],
            'interior': List.filled(5, [.4, .3]),
          },
        },
      };
    }
    final data = manifest == null
        ? png
        : Uint8List.fromList(utf8.encode(jsonEncode(manifest)));
    return ByteData.sublistView(data);
  }
}

class _Harness {
  _Harness(this.phase, this.mask, {this.still = false});
  final bundle = _TimingBundle();
  WindPhase phase;
  int mask;
  final bool still;
  bool holding = false;
  final cues = <String>[];
  int openings = 0, meetings = 0;

  Widget get widget => MaterialApp(
    home: Scaffold(
      body: StatefulBuilder(
        builder: (context, refresh) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: still),
          child: DefaultAssetBundle(
            bundle: bundle,
            child: WindStage(
              phase: phase,
              mask: mask,
              holding: holding,
              onBasket: () => refresh(() => holding = true),
              onPane: (pane) {
                if (!holding || pane < 7 || mask & (1 << (pane - 7)) != 0) {
                  return;
                }
                refresh(() {
                  holding = false;
                  mask |= 1 << (pane - 7);
                  if (mask == 31) phase = WindPhase.reunion;
                });
              },
              onCue: cues.add,
              onOpeningDone: () => refresh(() {
                openings++;
                phase = WindPhase.playing;
              }),
              onReunionDone: () => refresh(() {
                meetings++;
                phase = WindPhase.complete;
              }),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _show(WidgetTester tester, _Harness family) async {
  await tester.pumpWidget(family.widget);
  for (var i = 0; i < 200; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 8)),
    );
    await tester.pump();
    if (find.byKey(const ValueKey('wind-fox-status')).evaluate().isNotEmpty) {
      return;
    }
  }
  fail('The chapter paintings did not decode.');
}

Future<void> _place(WidgetTester tester, int pane) async {
  await tester.tap(find.byKey(const ValueKey('wind-basket')));
  await tester.pump();
  await tester.tap(find.byKey(ValueKey('wind-pane-$pane')));
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets(
    'lighting the far span first cannot bring the fox across the gap',
    (tester) async {
      final family = _Harness(WindPhase.playing, 14);
      await _show(tester, family);
      await _place(tester, 11);
      expect(family.mask, 30);
      await tester.pump(const Duration(seconds: 3));
      expect(family.cues, ['seatLeaf', 'windowLight']);
      expect(find.bySemanticsLabel('奶油望向远处的亮光，仍在第二段桥的缺口等'), findsOneWidget);
      await _place(tester, 7);
      expect(family.phase, WindPhase.reunion);
      await tester.pump(const Duration(seconds: 8));
      await tester.pump();
      expect(family.cues, [
        'seatLeaf',
        'windowLight',
        'seatLeaf',
        'windowLight',
        'footsteps',
        'footsteps',
      ]);
      expect(family.meetings, 1);
      expect(find.bySemanticsLabel('奶油回到暖廊，桃桃在叶篮边等它'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'opening cues occur once and the middle span permits one crossing',
    (tester) async {
      final family = _Harness(WindPhase.opening, 0);
      await _show(tester, family);
      await tester.pump();
      await tester.pump(const Duration(seconds: 11));
      await tester.pump();
      expect(family.openings, 1);
      expect(family.cues, ['wind', 'scarf', 'basket']);
      await _place(tester, 7);
      expect(family.mask, 1);
      await tester.pump(const Duration(seconds: 3));
      expect(family.cues.last, 'footsteps');
      expect(family.cues.where((e) => e == 'footsteps'), hasLength(1));
      expect(find.bySemanticsLabel('奶油在第三段桥的缺口等'), findsOneWidget);
      await tester.pump(const Duration(seconds: 10));
      expect(family.openings, 1);
      expect(family.cues, [
        'wind',
        'scarf',
        'basket',
        'seatLeaf',
        'windowLight',
        'footsteps',
      ]);
    },
  );

  testWidgets(
    'reduced motion exposes the settled chapter and keeps input live',
    (tester) async {
      final family = _Harness(WindPhase.opening, 30, still: true);
      await _show(tester, family);
      await tester.pump();
      expect(family.phase, WindPhase.playing);
      expect(family.cues, isEmpty);
      await _place(tester, 7);
      await tester.pump();
      expect(family.meetings, 1);
      expect(family.cues, ['seatLeaf', 'windowLight']);
      expect(family.phase, WindPhase.complete);
    },
  );

  testWidgets('rapid placements sound on their individual painted frames', (
    tester,
  ) async {
    final family = _Harness(WindPhase.playing, 0);
    await _show(tester, family);
    int painted() => tester
        .widget<ValueListenableBuilder<int>>(
          find.byKey(const ValueKey('wind-painted-glass')),
        )
        .valueListenable
        .value;
    await _place(tester, 8);
    await tester.pump(const Duration(milliseconds: 180));
    await _place(tester, 7);
    await tester.pump(const Duration(milliseconds: 360));
    expect(painted(), 0);
    expect(family.cues, isEmpty);
    await tester.pump(const Duration(milliseconds: 50));
    expect(painted(), 2);
    expect(family.cues, ['seatLeaf']);
    await tester.pump(const Duration(milliseconds: 180));
    expect(painted(), 3);
    expect(family.cues, ['seatLeaf', 'seatLeaf', 'windowLight']);
    await tester.pump(const Duration(seconds: 3));
    expect(family.cues, ['seatLeaf', 'seatLeaf', 'windowLight', 'footsteps']);
  });

  testWidgets('loading or restoring painted glass emits no placement sounds', (
    tester,
  ) async {
    final family = _Harness(WindPhase.playing, 2);
    await _show(tester, family);
    family.mask = 15;
    await tester.pumpWidget(family.widget);
    await tester.pump(const Duration(seconds: 5));
    expect(family.cues, isEmpty);
  });
}
