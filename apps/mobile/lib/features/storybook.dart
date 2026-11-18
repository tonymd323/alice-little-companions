import 'package:material_ui/material_ui.dart';

import '../domain/companions.dart';
import '../domain/garden_stories.dart';
import '../illustration/companion_motion.dart';
import 'common.dart';
import 'garden.dart';

class GardenStorybook extends StatefulWidget {
  const GardenStorybook({super.key, required this.stage, this.initial});
  final int stage;
  final Companion? initial;
  @override
  State<GardenStorybook> createState() => _GardenStorybookState();
}

class _GardenStorybookState extends State<GardenStorybook> {
  late Companion? pet = widget.initial;
  @override
  Widget build(BuildContext context) {
    final friend = pet, entry = companionStories[friend];
    return Scaffold(
      appBar: AppBar(title: const Text('银杏家园手记')),
      body: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final who in <Companion?>[null, ...Companion.values])
                  ChoiceChip(
                    label: Text(who?.nickname ?? '家园'),
                    selected: who == friend,
                    onSelected: (_) => setState(() => pet = who),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (friend == null || entry == null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 2.1,
                  child: Image.asset(
                    'assets/art/garden.webp',
                    fit: BoxFit.cover,
                    semanticLabel: '金色银杏、石桥和溪水',
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text('桥头的一片叶', style: Theme.of(context).textTheme.headlineSmall),
              for (final p in gardenStory) _Paragraph(p),
            ] else ...[
              Row(
                children: [
                  Image.asset(
                    friend.artwork(widget.stage),
                    width: 98,
                    height: 106,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          friend.label,
                          style: const TextStyle(color: mutedInk),
                        ),
                        Text(
                          entry.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _Paragraph('“${entry.greeting}”'),
              _Paragraph(entry.origin),
              _Paragraph(entry.wish),
              const Divider(height: 24),
              Text(
                '第 ${widget.stage} 阶段 · ${stageNames[widget.stage - 1]}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              _Paragraph(entry.stages[widget.stage - 1]),
              TextButton.icon(
                onPressed: () => openPage(
                  context,
                  AppearancePreview(
                    initial: friend,
                    initialStage: widget.stage,
                  ),
                ),
                icon: const Icon(Icons.pets_outlined),
                label: Text('看看${friend.skillName}'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Text(
      text,
      style: const TextStyle(fontSize: 17, height: 1.55, color: ink),
    ),
  );
}
