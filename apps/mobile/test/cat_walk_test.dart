import 'dart:math' as math;

import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/illustration/cat_walk.dart';
import 'package:alice_companions/illustration/cat_walk_art.dart';
import 'package:alice_companions/illustration/tailoring.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const root = Offset(700, 880);
  const scale = .8;
  final seated = CatWalkPose.seated(root, false, scale);

  test('every support interval is stationary as phase follows travel', () {
    for (final delta in const [
      Offset(390, 0),
      Offset(-290, -101),
      Offset(0, -130),
      Offset(5, 110),
      Offset(12, -3),
    ]) {
      final plan = CatWalkPlan.to(0, seated, root + delta);
      final stages = <CatWalkStage>{};
      final firstLandings = <CatLeg>[];
      var previous = plan.at(0);
      for (var time = 0.0; time < plan.end; time += 1 / 240) {
        final next = plan.at(time);
        stages.add(next.stage);
        expect(
          next.paws.where((paw) => paw.planted).length,
          greaterThanOrEqualTo(2),
        );
        for (final leg in CatLeg.values) {
          final a = previous.paws[leg.index], b = next.paws[leg.index];
          if (a.planted && b.planted) {
            expect((a.ground - b.ground).distance, lessThan(1e-8));
          }
          if (previous.stage == CatWalkStage.walk &&
              !a.planted &&
              b.planted &&
              !firstLandings.contains(leg)) {
            firstLandings.add(leg);
          }
        }
        if (previous.stage == CatWalkStage.walk &&
            next.stage == CatWalkStage.walk) {
          final yaw = math.atan2(delta.dy / .58, delta.dx);
          final calibration = scale * (132 - 42 * math.sin(yaw).abs());
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
        containsAll([CatWalkStage.rise, CatWalkStage.walk, CatWalkStage.sit]),
      );
      expect(firstLandings, CatLeg.values);
      expect(plan.at(plan.end).root, root + delta);
      expect(plan.at(plan.end).ink, 0);
    }
  });

  test('redirect and stroke stop start from the visible world pose', () {
    final outward = CatWalkPlan.to(0, seated, root + const Offset(340, 0));
    final sample = outward.at(1.0);
    expect(sample.stage, CatWalkStage.walk);
    final redirected = CatWalkPlan.to(
      1,
      sample,
      root + const Offset(-180, -38),
    );
    final stroked = CatWalkPlan.stop(1, sample);
    for (final next in [redirected, stroked]) {
      final first = next.at(1);
      expect(first.root, sample.root);
      expect(first.yaw, sample.yaw);
      for (final leg in CatLeg.values) {
        expect(first.paws[leg.index].ground, sample.paws[leg.index].ground);
        expect(first.paws[leg.index].lift, sample.paws[leg.index].lift);
      }
    }
    expect(redirected.at(redirected.end).root, root + const Offset(-180, -38));
    expect(stroked.at(stroked.end).root, sample.root);
  });

  test(
    'all 36 existing costume combinations resolve to bundled walk layers',
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
                ...catWalkAssets(body),
                for (final accessory in [head, face, neck].nonNulls)
                  fittedAccessory(accessory, Companion.cat),
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
