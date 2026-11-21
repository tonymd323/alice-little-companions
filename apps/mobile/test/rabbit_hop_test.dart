import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/illustration/companion_hops.dart';
import 'package:alice_companions/illustration/companion_motion.dart';
import 'package:alice_companions/illustration/living_scene.dart';
import 'package:alice_companions/illustration/puppet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('rabbit braces on the same spot and travels only between contacts', () {
    const start = Offset(.47, .937), end = Offset(.30, .92);
    const style = HopStyle.rabbit;
    final hop = CompanionHopPlan(style, 0, start, end, false);
    expect(hop.hops, 2);
    expect(hop.at(.07).ground, start);
    expect(hop.at(.07).left, isFalse);
    expect(hop.at(.14).left, isTrue);
    expect(hop.at(.14).pose.width, lessThan(1));
    for (var n = 0; n < hop.hops; n++) {
      final time = hop.pivot + n * style.beat;
      final from = Offset.lerp(start, end, n / hop.hops)!;
      final to = Offset.lerp(start, end, (n + 1) / hop.hops)!;
      final load = hop.at(time + .15);
      final air = hop.at(time + style.prepare + style.flight / 2);
      final land = hop.at(time + style.prepare + style.flight + .05);
      expect(load.ground, from);
      expect(load.pose.compression, greaterThan(.05));
      expect(load.pose.airborne, isFalse);
      expect(air.ground.dx, lessThan(from.dx));
      expect(air.ground.dx, greaterThan(to.dx));
      expect(air.pose.airborne, isTrue);
      expect(air.pose.lift, greaterThan(.08));
      expect((land.ground, land.pose.lift, land.pose.airborne), (to, 0, false));
      expect(land.pose.forepawPose, isTrue);
      expect(land.pose.hindLift, greaterThan(0));
      expect(land.pose.earLag, lessThan(0));
    }
    expect(hop.at(hop.end).ground, end);
    expect(hop.at(hop.end).pose.compression, 0);
    expect(hop.nextRest(.52), closeTo(hop.pivot + style.beat, 1e-8));
  });

  test('the two skill jumps have a visible planted interval between them', () {
    const first = PetMotion(PetAction.skill, .31);
    const land = PetMotion(PetAction.skill, .48);
    const second = PetMotion(PetAction.skill, .66);
    expect(first.height(Companion.rabbit), greaterThan(.38));
    expect(second.height(Companion.rabbit), greaterThan(.24));
    expect(first.usesAirborneArt(Companion.rabbit), isTrue);
    expect(second.usesAirborneArt(Companion.rabbit), isTrue);
    expect(
      (land.height(Companion.rabbit), land.travel(Companion.rabbit)),
      (0, 0),
    );
    expect(land.usesAirborneArt(Companion.rabbit), isFalse);
  });

  testWidgets('all rabbit stages reach the actual courtyard tap by hopping', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(480, 440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Widget scene(int stage, {bool reduced = false}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Scaffold(
          body: GardenScene(
            companion: Companion.rabbit,
            stage: stage,
            playable: true,
            height: 375,
            showLabel: false,
          ),
        ),
      ),
    );

    final pet = find.byType(IllustratedPet);
    const goal = Offset(144, 294.4);
    for (var stage = 1; stage <= 6; stage++) {
      await tester.pumpWidget(scene(stage));
      await tester.pump(const Duration(milliseconds: 40));
      await tester.tapAt(goal);
      var inAir = false;
      var landed = false;
      for (var frame = 0; frame < 70; frame++) {
        await tester.pump(const Duration(milliseconds: 40));
        final hop = tester.widget<IllustratedPet>(pet).hop!.call();
        if (hop?.airborne == true) inAir = true;
        if (inAir && hop?.airborne == false) landed = true;
        if (inAir && hop == null) break;
      }
      expect((inAir, landed), (true, true), reason: 'stage $stage');
      expect(tester.getRect(pet).bottomCenter, goal);
    }
    await tester.pumpWidget(scene(1, reduced: true));
    await tester.tapAt(goal);
    await tester.pump();
    expect(tester.widget<IllustratedPet>(pet).hop!.call(), isNull);
    expect(tester.getRect(pet).bottomCenter, goal);
  });
}
