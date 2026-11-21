import 'dart:io';
import 'dart:ui' as ui;

import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/illustration/action_poses.dart';
import 'package:alice_companions/illustration/puppet.dart';
import 'package:alice_companions/illustration/tailoring.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _CostumeBundle extends CachingAssetBundle {
  final textures = <String>{};

  @override
  Future<ByteData> load(String key) => rootBundle.load(key);

  @override
  Future<ui.ImmutableBuffer> loadBuffer(String key) {
    textures.add(key);
    return rootBundle.loadBuffer(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'the home portrait and jump wear the scarf painted into each third-stage rabbit costume',
    (tester) async {
      final clock = ValueNotifier(0);
      addTearDown(clock.dispose);
      final bundle = _CostumeBundle();
      Future<void> wear(String? garment, {required bool scarf}) async {
        final outfit = {
          if (garment != null) 'body': 'item_single_$garment',
          if (scarf) 'neck': 'item_accessory_scarf',
          'face': 'item_accessory_glasses',
        };
        await tester.pumpWidget(
          DefaultAssetBundle(
            bundle: bundle,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: IllustratedPet(
                pet: Companion.rabbit,
                stage: 3,
                reveal: false,
                outfit: outfit,
                clock: clock,
                seconds: () => 0,
                reaction: () => 0,
                walking: () => 0,
                gaze: () => 0,
                still: true,
                actionPoses: true,
              ),
            ),
          ),
        );
        for (var i = 0; i < 30; i++) {
          final suffix = garment == null ? '' : '-$garment';
          final directory = scarf ? 'wind/wardrobe' : 'art';
          final required = [
            'assets/$directory/rabbit-3$suffix.webp',
            'assets/$directory/leap-rabbit-3$suffix.webp',
            'assets/art/worn_accessory_glasses.webp',
          ];
          if (bundle.textures.containsAll(required)) break;
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 20)),
          );
          await tester.pump();
          if (i == 29) expect(bundle.textures, containsAll(required));
        }
      }

      await wear(null, scarf: true);
      await wear('coat', scarf: true);
      await wear('apron', scarf: true);
      expect(
        bundle.textures.where((key) => key.contains('fitted-scarf')),
        isEmpty,
      );
      await wear('apron', scarf: false);
    },
  );
  test('four fitted accessories share the 19 resting and 18 airborne paintings, also when wearing a coat or apron', () async {
    const captures = String.fromEnvironment('ALICE_ACCESSORY_EVIDENCE');
    final images = <String, ui.Image>{};
    Future<ui.Image> read(String path) async {
      if (images[path] case final img?) return img;
      final codec = await ui.instantiateImageCodec(
        await File(path).readAsBytes(),
      );
      final image = (await codec.getNextFrame()).image;
      codec.dispose();
      images[path] = image;
      return image;
    }

    addTearDown(() {
      for (final image in images.values) {
        image.dispose();
      }
    });
    var renders = 0;
    for (final pet in Companion.values) {
      for (var stage = 1; stage <= 6; stage++) {
        for (final mode in [
          'rest',
          'flight',
          if (pet == Companion.cat && stage == 4) 'unfold',
        ]) {
          final flying = mode == 'flight', reveal = mode != 'rest';
          final garment = [
            null,
            'item_single_coat',
            'item_single_apron',
          ][(stage - 1) % 3];
          final body = await read(
            flying
                ? actionArtwork(pet, stage, garment)
                : portraitArtwork(pet, stage, reveal, garment),
          );
          final rig = PetRig.forPose(pet, stage, reveal);
          final eyes = flying
              ? actionEyes(pet, stage)
              : (rig.leftEye, rig.rightEye);
          final raw = (await body.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!.buffer.asUint8List();
          for (final head in ['hat', 'bow']) {
            final headId = 'item_accessory_$head';
            final worn = {
              for (final entry in {
                'head': headId,
                'face': 'item_accessory_glasses',
                'neck': 'item_accessory_scarf',
              }.entries)
                entry.key: await read(
                  fittedAccessory(entry.value, pet, airborne: flying),
                ),
            };
            final look = applyAccessories(
              body,
              pet,
              stage,
              reveal,
              eyes.$1,
              eyes.$2,
              worn,
              headId,
              airborne: flying,
            );
            final pixels = (await look.image.toByteData(
              format: ui.ImageByteFormat.rawRgba,
            ))!.buffer.asUint8List();
            final dx = look.padding.dx.round(), dy = look.padding.dy.round();
            var changed = 0;
            for (var y = 0; y < body.height; y += 3) {
              for (var x = 0; x < body.width; x += 3) {
                final a = (y * body.width + x) * 4,
                    b = ((y + dy) * look.image.width + x + dx) * 4;
                if ((raw[a] - pixels[b]).abs() +
                        (raw[a + 1] - pixels[b + 1]).abs() +
                        (raw[a + 2] - pixels[b + 2]).abs() >
                    40) {
                  changed++;
                }
              }
            }
            expect(changed, greaterThan(35), reason: '$pet $stage $mode $head');
            for (final eye in [eyes.$1, eyes.$2]) {
              final x = (eye.dx * body.width).round(),
                  y = (eye.dy * body.height).round();
              final i = (y * body.width + x) * 4,
                  j = ((y + dy) * look.image.width + x + dx) * 4;
              final dif =
                  (raw[i] - pixels[j]).abs() +
                  (raw[i + 1] - pixels[j + 1]).abs() +
                  (raw[i + 2] - pixels[j + 2]).abs();
              expect(
                dif,
                lessThan(60),
                reason: '$pet $stage $mode $head covers pupil',
              );
            }
            if (captures.isNotEmpty) {
              final bytes = (await look.image.toByteData(
                format: ui.ImageByteFormat.png,
              ))!;
              await File('$captures/${pet.name}-$stage-$mode-$head.png')
                  .writeAsBytes(bytes.buffer.asUint8List());
            }
            look.image.dispose();
            renders++;
          }
        }
      }
    }
    expect(renders, (Companion.values.length * 12 + 1) * 2);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
