import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/illustration/companion_walk.dart';
import 'package:alice_companions/illustration/living_scene.dart';
import 'package:alice_companions/illustration/puppet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final pet in [Companion.cat, Companion.fox]) {
    testWidgets('${pet.name} grown forms use contacts or an airborne arc', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(480, 430);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final actor = find.byType(IllustratedPet);
      IllustratedPet companion() => tester.widget<IllustratedPet>(actor);
      const target = Offset(480 * .30, 320 * .92);
      for (var stage = 2; stage <= 6; stage++) {
        final hasPaws = stage <= (pet == Companion.cat ? 3 : 5);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GardenScene(
                companion: pet,
                stage: stage,
                height: 375,
                playable: true,
                outfit: const {'body': 'item_single_coat'},
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 40));
        await tester.tapAt(target);
        await tester.pump(const Duration(milliseconds: 40));
        expect(companion().walking(), 1, reason: 'stage $stage');
        var changedFoot = false, lifted = false;
        WalkPose? previous;
        for (var frame = 0; frame < 100 && companion().walking() > 0; frame++) {
          final current = companion().walkPose?.call();
          if (current != null && previous != null) {
            for (final leg in WalkLeg.values) {
              final a = previous.paws[leg.index];
              final b = current.paws[leg.index];
              if (a.planted && b.planted) {
                expect(b.ground, a.ground);
              }
              if (!a.planted && b.planted && a.ground != b.ground) {
                changedFoot = true;
              }
            }
          }
          previous = current;
          lifted |= (companion().hop?.call()?.lift ?? 0) > .05;
          await tester.pump(const Duration(milliseconds: 40));
        }
        expect(
          (changedFoot, lifted),
          (hasPaws, !hasPaws),
          reason: 'stage $stage',
        );
        expect(companion().walking(), 0);
        final rect = tester.getRect(actor);
        expect(rect.center.dx, closeTo(target.dx, .01));
        final pad = hasPaws ? rect.height / 6 : 0;
        expect(rect.bottom - pad, closeTo(target.dy, .01));
      }
    });
  }
}
