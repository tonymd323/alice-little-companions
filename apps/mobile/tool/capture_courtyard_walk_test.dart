import 'dart:io';
import 'dart:ui' as ui;

import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/domain/layout_rules.dart';
import 'package:alice_companions/domain/rules.dart';
import 'package:alice_companions/features/garden.dart' show gardenTheme;
import 'package:alice_companions/illustration/action_poses.dart';
import 'package:alice_companions/illustration/companion_hops.dart';
import 'package:alice_companions/illustration/companion_motion.dart';
import 'package:alice_companions/illustration/companion_turns.dart';
import 'package:alice_companions/illustration/companion_walk_art.dart';
import 'package:alice_companions/illustration/living_scene.dart';
import 'package:alice_companions/illustration/puppet.dart';
import 'package:alice_companions/illustration/tailoring.dart';
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
    const deep = bool.fromEnvironment('COURTYARD_DEEP_APPROACH');
    const short = deep || bool.fromEnvironment('COURTYARD_SHORT_APPROACH');
    const skill = bool.fromEnvironment('COURTYARD_RECORD_SKILL');
    const shortCall = bool.fromEnvironment('COURTYARD_SHORT_CALL');
    const backTurn = bool.fromEnvironment('COURTYARD_TURN_BACK');
    const veranda = bool.fromEnvironment('COURTYARD_VERANDA');
    const returnForward =
        backTurn && bool.fromEnvironment('COURTYARD_RETURN_FORWARD');
    const single = short || skill || shortCall || backTurn;
    const stageNumber = int.fromEnvironment('COURTYARD_STAGE', defaultValue: 1);
    const companionName = String.fromEnvironment(
      'COURTYARD_COMPANION',
      defaultValue: 'cat',
    );
    final companion = Companion.values.byName(companionName);
    final name = companion.name;
    final wideHedgehog = stageNumber == 6 && companion == Companion.hedgehog;
    final rearTarget = wideHedgehog ? .53 : .375;
    final rearStop = wideHedgehog ? 282 : 246;
    final turnBackTowardsUs = rearStop + 6;
    const wardrobe = String.fromEnvironment('COURTYARD_OUTFIT');
    final outfit = switch (wardrobe) {
      'vest-alone' => {'body': 'item_single_coat'},
      'scarf-alone' => {'neck': 'item_accessory_scarf'},
      'coat-with-scarf' => {
        'body': 'item_single_coat',
        'neck': 'item_accessory_scarf',
      },
      'coat-with-bow' => {
        'body': 'item_single_coat',
        'head': 'item_accessory_bow',
        'face': 'item_accessory_glasses',
        'neck': 'item_accessory_scarf',
      },
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
    final coat = fittedCoat(companion, stageNumber, outfit['body']);
    final paintedScarf =
        companion == Companion.fox &&
        stageNumber == 1 &&
        outfit['neck'] == 'item_accessory_scarf' &&
        (outfit['body'] == null || coat == FittedCoat.mapVest);
    const callFrame = compare ? 145 : 100;
    final lastFrame = returnForward
        ? turnBackTowardsUs + 103
        : backTurn
        ? rearStop
        : skill
        ? 112
        : short || shortCall
        ? 136
        : compare
        ? 590
        : 510;
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
                stage: stageNumber,
                rules: rules,
                scene: scene,
                view: veranda ? HomeView.veranda : HomeView.courtyard,
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
          if (veranda) 'assets/art/veranda.webp' else scene.background,
          scene.foreground,
          portraitArtwork(
            companion,
            stageNumber,
            false,
            outfit['body'],
            paintedScarf: paintedScarf,
          ),
          actionArtwork(
            companion,
            stageNumber,
            outfit['body'],
            paintedScarf: paintedScarf,
          ),
          if (companion == Companion.rabbit && stageNumber == 1) ...[
            rabbitShortHopArt,
            rabbitLandingArt,
          ],
          if (companion == Companion.cat && stageNumber == 4) ...[
            for (final picture in [
              cloudBraceArt,
              cloudFlightArt,
              cloudLandingArt,
              cloudRearBraceArt,
              cloudRearFlightArt,
              cloudRearLandingArt,
            ])
              coat?.on(picture) ?? picture,
          ],
          if (stageNumber == 1 &&
              (companion == Companion.fox ||
                  companion == Companion.cat ||
                  companion.hasGroundSkill))
            ...walkAssets(
              companion,
              outfit['body'],
              paintedScarf: paintedScarf,
            ),
          for (final view in turnFits(companion, stageNumber).keys)
            turnArtwork(companion, stageNumber, view, outfit['body']),
          for (final item in outfit.entries)
            if (item.key != 'body') ...[
              fittedAccessory(item.value, companion),
              fittedAccessory(item.value, companion, airborne: true),
            ],
          ...manifest.listAssets().where(
            (path) =>
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
      'frame,time,rootX,rootY,spriteLeft,facing,walking,stage,phase,ink,lift,away,yaw\n',
    );
    final contacts = StringBuffer('frame,leg,x,y,lift,planted\n');
    final destinations = <int, double>{};
    final walkStarts = <int>[];
    var wasWalking = false;
    var rearFlight = false;
    for (var frame = 0; frame <= lastFrame; frame++) {
      if (frame == 30) {
        if (skill) {
          await tester.tap(find.text(companion.skillName));
        } else if (shortCall) {
          await tester.tap(find.text('过来'));
        } else if (short || backTurn) {
          await tester.tapAt(
            const Offset(_width * .30, _gardenHeight * (deep ? .745 : .92)),
          );
        } else {
          await tester.tapAt(const Offset(_width * .23, _gardenHeight * .83));
        }
      }
      if (backTurn && frame == 143) {
        await tester.tapAt(Offset(_width * rearTarget, _gardenHeight * .745));
      }
      if (returnForward && frame == turnBackTowardsUs) {
        await tester.tapAt(Offset(_width * rearTarget, _gardenHeight * .92));
      }
      if (!single && frame == callFrame) {
        await tester.tap(find.text('过来'));
      }
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
      final padding = pet.walkPose != null ? sprite.size.width / 6 : 0;
      final footY = origin.dy + sprite.size.height - padding;
      final pose = gait ? pet.walkPose?.call() : null;
      final hop = pet.hop?.call();
      final away = hop?.facesAway == true;
      rearFlight |= away && hop?.airborne == true;
      final stage =
          pose?.stage.name ??
          (hop == null
              ? ''
              : hop.airborne
              ? 'flight'
              : 'support');
      final facing = (pet.walkFacesLeft?.call() ?? right.dx < origin.dx)
          ? -1
          : 1;
      final lift =
          (hop?.lift ?? 0) + (pet.motion?.call().height(companion) ?? 0);
      positions.writeln(
        '$frame,${pet.seconds()},${center.dx},$footY,${origin.dx},$facing,$walking,'
        '$stage,${pose?.phase ?? ''},${pose?.ink ?? ''},$lift,$away,${pose?.yaw ?? ''}',
      );
      if (pose != null) {
        for (final (index, paw) in pose.paws.indexed) {
          final relative = (paw.ground - pose.root) * (_width / 1536);
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
      if (!single &&
          (compare ? frame > 395 && frame < 470 : frame > 285 && frame < 425)) {
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
    if (single) {
      if (deep) expect(rearFlight, isTrue);
      expect(
        tester.getCenter(actor).dx,
        closeTo(
          _width *
              (skill
                  ? (veranda ? .58 : .47)
                  : shortCall
                  ? .56
                  : backTurn
                  ? rearTarget
                  : .30),
          .01,
        ),
      );
      if (backTurn) {
        expect(walkStarts, [30, 143, if (returnForward) turnBackTowardsUs]);
        expect(
          sprite.localToGlobal(Offset.zero, ancestor: picture).dy +
              sprite.size.height -
              sprite.size.width / 6,
          closeTo(_gardenHeight * (returnForward ? .92 : .745), .01),
        );
      }
      expect(tester.widget<IllustratedPet>(actor).walking(), 0);
      return;
    }
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
