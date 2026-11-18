import 'package:material_ui/material_ui.dart';

import '../domain/companions.dart';

const paper = Color(0xFFF7F3EA);
const cream = Color(0xFFFFFCF5);
const foliage = Color(0xFF4E6652);
const ink = Color(0xFF2F3B33);
const mutedInk = Color(0xFF59635B);
const faintGreen = Color(0xFFE6EDE2);
const outline = Color(0xFFD9DED3);

ThemeData gardenTheme() {
  final colors = ColorScheme.fromSeed(seedColor: foliage).copyWith(
    primary: foliage,
    onPrimary: Colors.white,
    surface: cream,
    onSurface: ink,
    onSurfaceVariant: mutedInk,
    outlineVariant: outline,
  );
  return ThemeData(
    colorScheme: colors,
    scaffoldBackgroundColor: paper,
    appBarTheme: const AppBarTheme(
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

class GardenScene extends StatelessWidget {
  const GardenScene({
    super.key,
    required this.companion,
    required this.stage,
    this.label = '银杏家园',
    this.reveal = false,
  });

  final Companion companion;
  final int stage;
  final String label;
  final bool reveal;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxWidth * 2 / 3;
        final frame = height * [0.24, 0.27, 0.30, 0.34, 0.36, 0.39][stage - 1];
        final center = constraints.maxWidth * .47;
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/art/garden.webp', fit: BoxFit.cover),
                Positioned(
                  left: center - frame * .37,
                  bottom: height * .045,
                  width: frame * .74,
                  height: frame * .12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(frame),
                      gradient: RadialGradient(
                        colors: [
                          const Color(0x63333B22),
                          const Color(0x00333B22),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: center - frame / 2,
                  bottom: height * .05,
                  width: frame,
                  height: frame,
                  child: Image.asset(
                    companion.artwork(stage, reveal: reveal),
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                    semanticLabel:
                        '${companion.label} · ${stageNames[stage - 1]}',
                  ),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: cream,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
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
  });

  final Companion selected;
  final ValueChanged<Companion> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final pet in Companion.values)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: pet == Companion.cat ? 0 : 8),
              child: Semantics(
                selected: selected == pet,
                button: true,
                child: Material(
                  color: selected == pet ? faintGreen : cream,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: selected == pet ? foliage : outline,
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
                            pet.artwork(1),
                            height: 44,
                            width: 52,
                            excludeFromSemantics: true,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pet.label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class AppearancePreview extends StatefulWidget {
  const AppearancePreview({
    super.key,
    this.initial = Companion.rabbit,
    this.initialStage = 4,
  });

  final Companion initial;
  final int initialStage;

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
                    backgroundColor: stage == value ? foliage : faintGreen,
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
        const Text('仅预览外观 · 不计积分', style: TextStyle(color: mutedInk)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final scene = GardenScene(companion: pet, stage: stage, reveal: true);
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
