import 'dart:io';
import 'dart:ui' as ui;

import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/domain/layout_rules.dart';
import 'package:alice_companions/domain/rules.dart';
import 'package:alice_companions/features/garden.dart' show gardenTheme;
import 'package:alice_companions/illustration/living_scene.dart';
import 'package:alice_companions/illustration/puppet.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _width = 480.0, _gardenHeight = 320.0, _pixelRatio = 2.0;
const _interval = Duration(milliseconds: 40);

Future<void> _saveFrame(RenderRepaintBoundary boundary, String path) async {
  final image = await boundary.toImage(pixelRatio: _pixelRatio);
  try {
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
    await File(path).writeAsBytes(bytes.buffer.asUint8List());
  } finally {
    image.dispose();
  }
}

void main() {
  testWidgets('record the three ordinary walks in the home courtyard', (
    tester,
  ) async {
    const output = String.fromEnvironment('COURTYARD_FRAMES');
    if (output.isEmpty) return;
    const font = String.fromEnvironment('ALICE_CJK_FONT');
    const compare = bool.fromEnvironment('COURTYARD_COMPARE_GAIT');
    const gait = bool.fromEnvironment('COURTYARD_RECORD_CONTACTS');
    const companionName = String.fromEnvironment(
      'COURTYARD_COMPANION',
      defaultValue: 'cat',
    );
    final companion = Companion.values.byName(companionName);
    final name = companion.name;
    const wardrobe = String.fromEnvironment('COURTYARD_OUTFIT');
    final outfit = switch (wardrobe) {
      'coat' => {
        'body': 'item_single_coat',
        'head': 'item_accessory_hat',
        'face': 'item_accessory_glasses',
        'neck': 'item_accessory_scarf',
      },
      'apron' => {
        'body': 'item_single_apron',
        'head': 'item_accessory_bow',
        'face': 'item_accessory_glasses',
        'neck': 'item_accessory_scarf',
      },
      _ => <String, String>{},
    };
    const callFrame = compare ? 145 : 100;
    const lastFrame = compare ? 590 : 510;
    const family = 'Courtyard Review';
    await tester.runAsync(() async {
      final bytes = await File(font).readAsBytes();
      await (FontLoader(
        family,
      )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
      await Directory('$output/paws').create(recursive: true);
    });
    final config = await Future.wait(
      [
        'rules',
        'catalog',
        'scene_slots',
      ].map((name) => rootBundle.loadString('assets/config/$name.json')),
    );
    final rules = Rules.decode(config[0], config[1], config[2]);
    final scene = SceneDefinition(rules, 'base_room');
    final screen = GlobalKey();
    final theme = gardenTheme();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(_width, 430);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: theme.copyWith(
          textTheme: theme.textTheme.apply(fontFamily: family),
        ),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: RepaintBoundary(
              key: screen,
              child: GardenScene(
                companion: companion,
                stage: 1,
                rules: rules,
                scene: scene,
                outfit: outfit,
                immersive: true,
                showLabel: false,
                onViewChanged: (_) {},
                height: _gardenHeight + 55,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final context = screen.currentContext!;
      if (!context.mounted) throw StateError('The courtyard was removed');
      await Future.wait([
        for (final path in [
          scene.background,
          scene.foreground,
          'assets/art/$name-1.webp',
          'assets/art/leap-$name-1.webp',
          ...manifest.listAssets().where(
            (path) =>
                path.startsWith('assets/${name}_walk/') ||
                path.contains('fitted-') && path.contains('-$name-') ||
                path.contains('worn_item_accessory_glasses') ||
                path.contains('$name-1-'),
          ),
        ])
          precacheImage(AssetImage(path), context),
      ]);
    });
    await tester.pump();
    final picture = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(screen),
    );
    final actor = find.byType(IllustratedPet);
    final sprite = tester.renderObject<RenderRepaintBoundary>(
      find.descendant(of: actor, matching: find.byType(RepaintBoundary)).first,
    );
    final positions = StringBuffer(
      'frame,time,rootX,rootY,spriteLeft,facing,walking,stage,phase,ink\n',
    );
    final contacts = StringBuffer('frame,leg,x,y,lift,planted\n');
    final destinations = <int, double>{};
    final walkStarts = <int>[];
    var wasWalking = false;
    for (var frame = 0; frame <= lastFrame; frame++) {
      if (frame == 30) {
        await tester.tapAt(const Offset(_width * .23, _gardenHeight * .83));
      }
      if (frame == callFrame) await tester.tap(find.text('过来'));
      await tester.pump(_interval);
      final pet = tester.widget<IllustratedPet>(actor);
      final walking = pet.walking() > 0;
      if (walking && !wasWalking) walkStarts.add(frame);
      wasWalking = walking;
      final origin = sprite.localToGlobal(Offset.zero, ancestor: picture);
      final right = sprite.localToGlobal(
        Offset(sprite.size.width, 0),
        ancestor: picture,
      );
      final center = tester.getCenter(actor);
      final padding = gait ? sprite.size.width / 6 : 0;
      final footY = origin.dy + sprite.size.height - padding;
      // Dynamic only in this tool so the identical camera and input script
      // can also compile against a snapshot before this companion walked.
      final dynamic candidate = pet;
      final dynamic pose = gait ? candidate.walkPose?.call() : null;
      final stage = pose?.stage as Enum?;
      final facing = gait
          ? (candidate.walkFacesLeft?.call() == true ? -1 : 1)
          : (right.dx > origin.dx ? 1 : -1);
      positions.writeln(
        '$frame,${pet.seconds()},${center.dx},$footY,${origin.dx},$facing,$walking,'
        '${stage?.name ?? ''},${pose?.phase ?? ''},${pose?.ink ?? ''}',
      );
      if (pose != null) {
        final worldRoot = pose.root as Offset;
        final paws = pose.paws as List<dynamic>;
        for (final (index, paw) in paws.indexed) {
          final point = paw.ground as Offset;
          final relative = (point - worldRoot) * (_width / 1536);
          contacts.writeln(
            '$frame,$index,${(center.dx + relative.dx) * _pixelRatio},'
            '${(footY + relative.dy) * _pixelRatio},${paw.lift},${paw.planted}',
          );
        }
      }
      if ({0, callFrame - 8, compare ? 265 : 165, lastFrame}.contains(frame)) {
        destinations[frame] = center.dx;
      }
      // Keep the clock running through the unsampled idle wait.
      if (compare ? frame > 395 && frame < 470 : frame > 285 && frame < 425) {
        continue;
      }
      final suffix = frame.toString().padLeft(4, '0');
      await tester.runAsync(() async {
        await _saveFrame(picture, '$output/frame-$suffix.png');
        await _saveFrame(sprite, '$output/paws/frame-$suffix.png');
      });
    }
    await tester.runAsync(
      () => Future.wait([
        File('$output/positions.csv').writeAsString(positions.toString()),
        if (gait)
          File('$output/contacts.csv').writeAsString(contacts.toString()),
      ]),
    );
    expect(walkStarts, hasLength(3));
    expect(walkStarts.take(2), [30, callFrame]);
    expect(walkStarts.last, inInclusiveRange(callFrame + 345, callFrame + 380));
    for (final entry in {
      0: .47,
      callFrame - 8: .23,
      compare ? 265 : 165: .56,
      lastFrame: .38,
    }.entries) {
      expect(destinations[entry.key], closeTo(entry.value * _width, .01));
    }
  }, timeout: const Timeout(Duration(minutes: 6)));
}
