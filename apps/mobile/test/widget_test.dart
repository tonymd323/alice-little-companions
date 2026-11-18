import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('all 18 previews load without changing app state', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(const CompanionsApp());
    await tester.pumpAndSettle();
    for (final companion in Companion.values) {
      await tester.ensureVisible(find.text(companion.label));
      await tester.tap(find.text(companion.label));
      await tester.pumpAndSettle();
      for (var stage = 1; stage <= 6; stage++) {
        await tester.tap(
          find.byTooltip('第 $stage 阶段 · ${stageNames[stage - 1]}'),
        );
        await tester.pumpAndSettle();
        expect(
          find.bySemanticsLabel(
            '${companion.label} · ${stageNames[stage - 1]}',
          ),
          findsOneWidget,
        );
        final scene = tester.widgetList<Image>(find.byType(Image));
        expect(
          scene.any(
            (image) =>
                (image.image as AssetImage).assetName ==
                companion.artwork(stage, reveal: true),
          ),
          isTrue,
        );
      }
    }
    expect(find.text('仅预览外观 · 不计积分'), findsOneWidget);
  });
}
