import 'package:material_ui/material_ui.dart';

import '../domain/companions.dart';
import '../illustration/living_scene.dart';
import '../illustration/evolution.dart';
export '../illustration/evolution.dart' show showEvolution;
export '../illustration/living_scene.dart';

const paper = Color(0xFFFAF2E2);
const cream = Color(0xFFFFFBEE);
const terracotta = Color(0xFF90492F);
const ink = Color(0xFF40352E);
const mutedInk = Color(0xFF6C5B4A);
const wheat = Color(0xFFF4E2BF);
const outline = Color(0xFFDECBA8);

ThemeData gardenTheme() {
  final colors = ColorScheme.fromSeed(seedColor: terracotta).copyWith(
    primary: terracotta,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFF1D4A4),
    onPrimaryContainer: ink,
    secondary: const Color(0xFF46667A),
    secondaryContainer: const Color(0xFFF1DDB6),
    onSecondaryContainer: ink,
    surfaceTint: Colors.transparent,
    surface: cream,
    onSurface: ink,
    onSurfaceVariant: mutedInk,
    outlineVariant: outline,
  );
  return ThemeData(
    colorScheme: colors,
    scaffoldBackgroundColor: paper,
    appBarTheme: const AppBarTheme(
      scrolledUnderElevation: 0,
      backgroundColor: paper,
      foregroundColor: ink,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 18),
      bodyMedium: TextStyle(fontSize: 16),
      bodySmall: TextStyle(fontSize: 14),
      titleLarge: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
      titleMedium: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        side: const BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cream,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

class GardenCard extends StatelessWidget {
  const GardenCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: outline),
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class CompanionPicker extends StatelessWidget {
  const CompanionPicker({
    super.key,
    required this.selected,
    required this.onSelected,
    this.stage = 1,
    this.stages = const {},
    this.reveal = false,
    this.choices = Companion.values,
  });

  final Companion selected;
  final ValueChanged<Companion> onSelected;
  final int stage;
  final Map<Companion, int> stages;
  final bool reveal;
  final List<Companion> choices;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final pet in choices)
          SizedBox(
            width: (bounds.maxWidth - 16) / 3,
            child: Semantics(
              selected: selected == pet,
              button: true,
              child: Material(
                color: selected == pet ? wheat : cream,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: selected == pet ? terracotta : outline,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onSelected(pet),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
                    child: Column(
                      children: [
                        Image.asset(
                          pet.artwork(stages[pet] ?? stage, reveal: reveal),
                          filterQuality: FilterQuality.medium,
                          height: 53,
                          width: 65,
                          excludeFromSemantics: true,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pet.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class AppearancePreview extends StatefulWidget {
  const AppearancePreview({
    super.key,
    this.initial = Companion.rabbit,
    this.initialStage = 4,
    this.outfit = const {},
  });

  final Companion initial;
  final int initialStage;
  final Map<String, String> outfit;

  @override
  State<AppearancePreview> createState() => _AppearancePreviewState();
}

class _AppearancePreviewState extends State<AppearancePreview> {
  late Companion pet = widget.initial;
  late int stage = widget.initialStage;

  Widget controls() => GardenCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(pet.nickname, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 2),
        Text('第 $stage 阶段 · ${stageNames[stage - 1]}'),
        const SizedBox(height: 14),
        CompanionPicker(
          selected: pet,
          stage: stage,
          reveal: true,
          onSelected: (value) => setState(() => pet = value),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 4,
          children: [
            for (var value = 1; value <= 6; value++)
              SizedBox.square(
                dimension: 48,
                child: IconButton(
                  tooltip: '第 $value 阶段 · ${stageNames[value - 1]}',
                  style: IconButton.styleFrom(
                    backgroundColor: stage == value ? terracotta : wheat,
                    foregroundColor: stage == value ? Colors.white : ink,
                  ),
                  onPressed: () => setState(() => stage = value),
                  icon: Text(
                    '$value',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => showEvolution(
            context,
            pet,
            stage == 1 ? 1 : stage - 1,
            stage == 1 ? 2 : stage,
            preview: true,
            outfit: pet == widget.initial ? widget.outfit : const {},
          ),
          icon: const Icon(Icons.auto_awesome),
          label: const Text('预演进化'),
        ),
        const SizedBox(height: 6),
        const Text('仅预览外观 · 不计积分', style: TextStyle(color: mutedInk)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final scene = GardenScene(
      companion: pet,
      stage: stage,
      reveal: true,
      focus: true,
      playable: true,
      outfit: pet == widget.initial ? widget.outfit : const {},
      label: "伙伴手记",
    );
    return Scaffold(
      appBar: AppBar(title: const Text('伙伴外观预览')),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: box.maxWidth >= 880
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: scene),
                          const SizedBox(width: 16),
                          Expanded(child: controls()),
                        ],
                      )
                    : Column(
                        children: [
                          scene,
                          const SizedBox(height: 16),
                          controls(),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
