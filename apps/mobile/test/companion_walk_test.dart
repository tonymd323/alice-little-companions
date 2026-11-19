import 'dart:math' as math;

import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/illustration/companion_walk.dart';
import 'package:alice_companions/illustration/companion_walk_art.dart';
import 'package:alice_companions/illustration/living_scene.dart';
import 'package:alice_companions/illustration/puppet.dart';
import 'package:alice_companions/illustration/tailoring.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const root = Offset(700, 880);
  const scale = .8;
  for (final (pet, rig) in const [
    (Companion.cat, WalkRig.cat),
    (Companion.fox, WalkRig.fox),
  ]) {
    final seated = WalkPose.seated(rig, root, false, scale);

    test(
      '${pet.name}: every support interval is stationary as phase follows travel',
      () {
        for (final delta in const [
          Offset(390, 0),
          Offset(-290, -101),
          Offset(0, -130),
          Offset(5, 110),
          Offset(12, -3),
        ]) {
          final plan = WalkPlan.to(0, seated, root + delta);
          final stages = <WalkStage>{};
          final firstLandings = <WalkLeg>[];
          var previous = plan.at(0);
          for (var time = 0.0; time < plan.end; time += 1 / 240) {
            final next = plan.at(time);
            stages.add(next.stage);
            expect(
              next.paws.where((paw) => paw.planted).length,
              greaterThanOrEqualTo(2),
            );
            for (final leg in WalkLeg.values) {
              final a = previous.paws[leg.index], b = next.paws[leg.index];
              if (a.planted && b.planted) {
                expect((a.ground - b.ground).distance, lessThan(1e-8));
              }
              if (previous.stage == WalkStage.walk &&
                  !a.planted &&
                  b.planted &&
                  !firstLandings.contains(leg)) {
                firstLandings.add(leg);
              }
            }
            if (previous.stage == WalkStage.walk &&
                next.stage == WalkStage.walk) {
              final yaw = math.atan2(delta.dy / .58, delta.dx);
              final calibration =
                  scale *
                  (rig.sideStride -
                      (rig.sideStride - rig.depthStride) * math.sin(yaw).abs());
              expect(
                next.phase - previous.phase,
                closeTo(
                  (next.root - previous.root).distance /
                      math.min(delta.distance, calibration),
                  1e-9,
                ),
              );
            }
            previous = next;
          }
          expect(
            stages,
            containsAll([WalkStage.rise, WalkStage.walk, WalkStage.sit]),
          );
          expect(firstLandings, WalkLeg.values);
          expect(plan.at(plan.end).root, root + delta);
          expect(plan.at(plan.end).ink, 0);
        }
      },
    );

    test(
      '${pet.name}: redirect and stroke stop start from the visible world pose',
      () {
        final outward = WalkPlan.to(0, seated, root + const Offset(340, 0));
        final sample = outward.at(1.0);
        expect(sample.stage, WalkStage.walk);
        final reversing = WalkPlan.to(0, seated, root - const Offset(280, 0));
        if (pet == Companion.fox) {
          final midpoint = reversing.at(rig.rise + .53 * .65);
          expect(midpoint.yaw, closeTo(math.pi / 2, 1e-8));
          expect(midpoint.paws.every((paw) => paw.planted), isTrue);
        }
        final inFlight = Iterable.generate(240, (i) => reversing.at(i / 240))
            .firstWhere(
              (pose) =>
                  pose.stage == WalkStage.turn &&
                  pose.paws.where((paw) => !paw.planted).length == 2,
            );
        final secondTurn = WalkPlan.to(
          1,
          inFlight,
          root + const Offset(200, 35),
        );
        final redirected = WalkPlan.to(
          1,
          sample,
          root + const Offset(-180, -38),
        );
        final stroked = WalkPlan.stop(1, sample);
        for (final next in [redirected, stroked]) {
          final first = next.at(1);
          expect(first.root, sample.root);
          expect(first.yaw, sample.yaw);
          for (final leg in WalkLeg.values) {
            expect(first.paws[leg.index].ground, sample.paws[leg.index].ground);
            expect(first.paws[leg.index].lift, sample.paws[leg.index].lift);
          }
        }
        expect(
          redirected.at(redirected.end).root,
          root + const Offset(-180, -38),
        );
        expect(stroked.at(stroked.end).root, sample.root);
        for (
          var time = secondTurn.start;
          time < secondTurn.end;
          time += 1 / 240
        ) {
          expect(
            secondTurn.at(time).paws.where((paw) => paw.planted).length,
            greaterThanOrEqualTo(2),
          );
        }
      },
    );

    testWidgets(
      '${pet.name}: courtyard depth tap and reduced motion use the same destinations',
      (tester) async {
        tester.view.physicalSize = const Size(480, 430);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        Widget home({required bool reduced}) => MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: reduced),
            child: Scaffold(
              body: GardenScene(
                companion: pet,
                stage: 1,
                showLabel: false,
                immersive: true,
                height: 375,
                onViewChanged: (_) {},
              ),
            ),
          ),
        );

        await tester.pumpWidget(home(reduced: false));
        await tester.pump(const Duration(milliseconds: 40));
        final actor = find.byType(IllustratedPet);
        WalkPose? pose() => tester.widget<IllustratedPet>(actor).walkPose!();
        const grass = Offset(480 * .398, 320 * .75);
        await tester.tapAt(grass);
        await tester.pump(const Duration(milliseconds: 40));
        expect(pose()?.stage, WalkStage.rise);
        for (var frame = 0; frame < 100; frame++) {
          await tester.pump(const Duration(milliseconds: 40));
        }
        expect(tester.getCenter(actor).dx, closeTo(grass.dx, .01));
        expect(pose(), isNull);

        await tester.pumpWidget(home(reduced: true));
        await tester.tap(find.text('过来'));
        await tester.pump();
        expect(tester.getCenter(actor).dx, closeTo(480 * .56, .01));
        expect(pose(), isNull);
        expect(find.text('${pet.nickname}来到你身边'), findsOneWidget);
      },
    );

    test(
      '${pet.name}: all 36 existing costume combinations resolve to bundled walk layers',
      () async {
        final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
        final bundled = manifest.listAssets().toSet();
        const bodies = [null, 'item_single_coat', 'item_single_apron'];
        const heads = [null, 'item_accessory_hat', 'item_accessory_bow'];
        const faces = [null, 'item_accessory_glasses'];
        const necks = [null, 'item_accessory_scarf'];
        var combinations = 0;
        for (final body in bodies) {
          for (final head in heads) {
            for (final face in faces) {
              for (final neck in necks) {
                final layers = [
                  ...walkAssets(pet, body),
                  for (final accessory in [head, face, neck].nonNulls)
                    fittedAccessory(accessory, pet),
                ];
                expect(bundled, containsAll(layers));
                combinations++;
              }
            }
          }
        }
        expect(combinations, 36);
      },
    );
  }
}
