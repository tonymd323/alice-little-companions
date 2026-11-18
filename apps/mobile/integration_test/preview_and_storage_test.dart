import 'package:alice_companions/application/controller.dart';
import 'package:alice_companions/data/device.dart';
import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/domain/pin.dart';
import 'package:alice_companions/domain/rules.dart';
import 'package:alice_companions/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'platform store, secure PIN, all stage previews preserve snapshot',
    (tester) async {
      final files = await Future.wait(
        [
          'rules',
          'catalog',
          'scene_slots',
        ].map((name) => rootBundle.loadString('assets/config/$name.json')),
      );
      final real = await DeviceStore.open();
      final root = await real.root.createTemp('probe-');
      final isolated = DeviceStore(root, real.secure);
      final controller = FamilyController(
        isolated,
        Rules.decode(files[0], files[1], files[2]),
      );
      addTearDown(() async {
        final id = await isolated.activeGeneration();
        if (id != null) await real.secure.delete('alice.pin.$id');
        await controller.service?.close();
        controller.dispose();
        await root.delete(recursive: true);
      });
      final testPin = 123456.toString();
      await controller.create(
        '测试家庭',
        Companion.rabbit,
        testPin,
        PinGate.newRecoveryCode(),
      );
      final parent = await controller.service!.pin.unlock(testPin);
      expect(controller.service!.pin.allows(parent), isTrue);
      final before = (await controller.service!.overview())!;
      await tester.pumpWidget(CompanionsApp(controller: controller));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('外观预览'));
      await tester.tap(find.text('外观预览'));
      await tester.pumpAndSettle();
      for (final pet in Companion.values) {
        await tester.ensureVisible(find.text(pet.label));
        await tester.tap(find.text(pet.label));
        await tester.pumpAndSettle();
        for (var stage = 1; stage <= 6; stage++) {
          final button = find.byTooltip(
            '第 $stage 阶段 · ${stageNames[stage - 1]}',
          );
          await tester.ensureVisible(button);
          await tester.tap(button);
          await tester.pumpAndSettle();
          expect(
            find.text('第 $stage 阶段 · ${stageNames[stage - 1]}'),
            findsOneWidget,
          );
        }
      }
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      final after = (await controller.service!.overview())!;
      expect(
        (
          after.balance,
          after.stage,
          after.companion,
          after.days,
          after.revision,
        ),
        (
          before.balance,
          before.stage,
          before.companion,
          before.days,
          before.revision,
        ),
      );
      expect(await controller.service!.ledger(), isEmpty);
      expect(
        await isolated
            .databaseFile((await isolated.activeGeneration())!)
            .exists(),
        isTrue,
      );
    },
  );
}
