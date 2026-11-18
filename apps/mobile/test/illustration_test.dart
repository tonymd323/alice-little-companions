import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/illustration/living_scene.dart';
import 'package:alice_companions/illustration/puppet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('old placement anchors round-trip through a cropped veranda and its hanging mount', () {
    const original = Offset(.267, .846);
    for (final size in [
      const Size(360, 420),
      const Size(390, 260),
      const Size(834, 410),
    ]) {
      for (final pan in [-.4, 0.0, .49]) {
        final space = SceneProjection.fit(size, pan, true);
        final stored = space.toSave(
          space.normalized(space.screen(space.fromSave(original))),
        );
        expect((original - stored).distance, lessThan(1e-9));
        final hook = space.fromSave(const Offset(.36, .27), mount: true);
        expect(space.toSave(hook, mount: true), const Offset(.36, .27));
      }
    }
  });

  testWidgets(
    'each illustrated pet responds to touch, follows a stroke and settles; offstage and reduced motion are quiet',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Future<void> mount(
        Companion pet, {
        bool enabled = true,
        bool reduced = false,
      }) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaQuery(
                data: MediaQueryData(disableAnimations: reduced),
                child: TickerMode(
                  enabled: enabled,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: GardenScene(
                      companion: pet,
                      stage: pet == Companion.cat ? 4 : 1,
                      height: 300,
                      immersive: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 40));
      }

      IllustratedPet actor() =>
          tester.widget<IllustratedPet>(find.byType(IllustratedPet));
      for (final pet in Companion.values) {
        await mount(pet);
        const target = Offset(188, 251);
        await tester.tapAt(target);
        await tester.pump(const Duration(milliseconds: 80));
        expect(
          find.text(switch (pet) {
            Companion.fox => '奶油摇了摇尾巴',
            Companion.rabbit => '桃桃轻轻跳了一下',
            Companion.cat => '团团舒展了云翼',
          }),
          findsOneWidget,
        );
        final finger = await tester.startGesture(target);
        await finger.moveBy(const Offset(26, 0));
        await finger.moveBy(const Offset(22, 0));
        await tester.pump(const Duration(milliseconds: 50));
        expect(actor().gaze().abs(), greaterThan(.2));
        await finger.up();
        for (var i = 0; i < 21; i++) {
          await tester.pump(const Duration(milliseconds: 80));
        }
        expect(actor().reaction(), 1);
      }
      await mount(Companion.cat, enabled: false);
      final stopped = actor().seconds();
      await tester.pump(const Duration(seconds: 4));
      expect(actor().seconds(), stopped);
      await mount(Companion.cat, reduced: true);
      final quiet = actor().seconds();
      await tester.tapAt(const Offset(188, 251));
      await tester.pump(const Duration(milliseconds: 400));
      expect(actor().seconds(), quiet);
      expect(find.text('团团舒展了云翼'), findsOneWidget);
    },
  );
}
