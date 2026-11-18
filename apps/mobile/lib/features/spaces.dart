import 'package:material_ui/material_ui.dart';

import '../application/controller.dart';
import '../application/family.dart';
import '../domain/companions.dart';
import '../domain/layout_rules.dart';
import '../domain/rules.dart';
import 'common.dart';
import 'garden.dart';
import 'rewards.dart';

class SpacesPage extends StatefulWidget {
  const SpacesPage({super.key, required this.controller});
  final FamilyController controller;

  @override
  State<SpacesPage> createState() => _SpacesPageState();
}

class _SpacesPageState extends State<SpacesPage> {
  FamilyService get service => widget.controller.service!;
  late Future<List<Json>> spaces = service.spaces();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('我的空间')),
    body: PageBody(
      maxWidth: 980,
      child: FutureBuilder(
        future: spaces,
        builder: (context, snapshot) => LayoutBuilder(
          builder: (context, box) {
            final width = box.maxWidth >= 650
                ? (box.maxWidth - 12) / 2
                : box.maxWidth;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final space in snapshot.data ?? <Json>[])
                  SizedBox(
                    width: width,
                    child: GardenCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: AspectRatio(
                              aspectRatio: 1.85,
                              child: Image.asset(
                                space['scene_id'] == 'base_room'
                                    ? 'assets/art/veranda.webp'
                                    : artworkPath(
                                        'painted_${space['scene_id']}',
                                      ),
                                fit: BoxFit.cover,
                                excludeFromSemantics: true,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            space['name'] as String,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () async {
                              await openPage(
                                context,
                                SpacePage(
                                  controller: widget.controller,
                                  id: space['id'] as String,
                                ),
                              );
                              if (mounted) {
                                setState(() => spaces = service.spaces());
                              }
                            },
                            child: Text('进入${space['name']}'),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!snapshot.hasData)
                  const Center(child: CircularProgressIndicator()),
              ],
            );
          },
        ),
      ),
    ),
  );
}

class SpacePage extends StatefulWidget {
  const SpacePage({super.key, required this.controller, required this.id});
  final FamilyController controller;
  final String id;

  @override
  State<SpacePage> createState() => _SpacePageState();
}

class _SpacePageState extends State<SpacePage> {
  FamilyService get service => widget.controller.service!;
  late Future<(Json?, List<Json>, List<Json>)> data = load();

  Future<(Json?, List<Json>, List<Json>)> load() async => (
    (await service.spaces())
        .where((space) => space['id'] == widget.id)
        .singleOrNull,
    await service.furnishings(widget.id),
    await service.wardrobe(widget.controller.family!.companion),
  );

  Future<void> rename(Json space) async {
    final result = await openPage<String>(
      context,
      SpaceNamePage(name: space['name'] as String),
    );
    if (result == null) return;
    await service.renameSpace(
      widget.id,
      space['layout_version'] as int,
      result,
    );
    await widget.controller.refresh();
    if (mounted) setState(() => data = load());
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: data,
    builder: (context, snapshot) {
      final values = snapshot.data;
      final space = values?.$1;
      final family = widget.controller.family!;
      return Scaffold(
        appBar: AppBar(title: Text(space?['name'] as String? ?? '我的空间')),
        body: PageBody(
          maxWidth: 920,
          child: values == null
              ? const Center(child: CircularProgressIndicator())
              : space == null
              ? const GardenCard(child: Text('这个空间已归还。'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GardenScene(
                      view: HomeView.veranda,
                      label: space['name'] as String,
                      companion: family.companion,
                      stage: family.stage,
                      rules: service.rules,
                      scene: SceneDefinition(
                        service.rules,
                        space['scene_id'] as String,
                      ),
                      pieces: values.$2.map(ScenePiece.fromRow).toList(),
                      outfit: outfitFiles(values.$3),
                    ),
                    const SizedBox(height: 12),
                    if (!service.frozen)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.icon(
                            onPressed: () async {
                              await openPage(
                                context,
                                CatalogPage(
                                  controller: widget.controller,
                                  section: CatalogSection.furniture,
                                ),
                              );
                              if (mounted) setState(() => data = load());
                            },
                            icon: const Icon(Icons.chair_outlined),
                            label: const Text('浏览家具'),
                          ),
                          if (space['scene_id'] != 'base_room')
                            ActionButton(
                              label: '修改空间名称',
                              outlined: true,
                              action: () => rename(space),
                            ),
                        ],
                      ),
                  ],
                ),
        ),
      );
    },
  );
}

Map<String, String> outfitFiles(List<Json> rows) => {
  for (final row in rows) row['slot'] as String: row['asset_id'] as String,
};

class SpaceNamePage extends StatefulWidget {
  const SpaceNamePage({super.key, required this.name});
  final String name;

  @override
  State<SpaceNamePage> createState() => _SpaceNamePageState();
}

class _SpaceNamePageState extends State<SpaceNamePage> {
  late final name = TextEditingController(text: widget.name);

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('修改空间名称')),
    body: PageBody(
      child: GardenCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormFieldLabel(label: '空间名称', controller: name, limit: 25),
            ActionButton(
              label: '确认更名',
              action: () async {
                Navigator.pop(
                  context,
                  textValue(name.text, 25, requiredLabel: '空间名称'),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key, required this.controller});
  final FamilyController controller;

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  FamilyService get service => widget.controller.service!;
  late Companion pet = widget.controller.family!.companion;
  late Future<List<Json>> items = service.items();
  late Future<List<Json>> current = service.wardrobe(pet);
  late int revision = widget.controller.family!.revision;
  Map<String, String>? draft;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('伙伴衣橱')),
    body: PageBody(
      maxWidth: 780,
      child: FutureBuilder(
        future: items,
        builder: (context, inventory) => FutureBuilder(
          future: current,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                inventory.data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final clothes = inventory.data!
                .where((item) => item['slot'] != null)
                .toList();
            final available = {
              for (final row in clothes) row['id'] as String: row,
            };
            final selection =
                draft ??
                {
                  for (final row in snapshot.data ?? <Json>[])
                    row['slot'] as String: row['entitlement_id'] as String,
                };
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GardenScene(
                  companion: pet,
                  stage: widget.controller.family!.stage,
                  rules: service.rules,
                  label: '试衣间',
                  focus: true,
                  outfit: {
                    for (final entry in selection.entries)
                      if (available.containsKey(entry.value))
                        entry.key:
                            available[entry.value]!['asset_id'] as String,
                  },
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.checkroom_outlined),
                  label: const Text('试穿衣服和配饰'),
                  onPressed: () async {
                    await openPage(
                      context,
                      CatalogPage(
                        controller: widget.controller,
                        section: CatalogSection.clothes,
                        model: pet,
                      ),
                    );
                    if (!mounted) return;
                    setState(() {
                      items = service.items();
                      current = service.wardrobe(pet);
                      revision = widget.controller.family!.revision;
                      draft = null;
                    });
                  },
                ),
                const SizedBox(height: 12),
                CompanionPicker(
                  selected: pet,
                  stage: widget.controller.family!.stage,
                  onSelected: (value) => setState(() {
                    pet = value;
                    draft = null;
                    current = service.wardrobe(pet);
                  }),
                ),
                const SizedBox(height: 12),
                if (clothes.isNotEmpty)
                  GardenCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (slot, label) in [
                          ('head', '头饰'),
                          ('face', '脸部'),
                          ('neck', '颈部'),
                          ('body', '衣服'),
                        ])
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: DropdownButtonFormField<String>(
                              key: ValueKey((pet, slot, selection[slot])),
                              isExpanded: true,
                              initialValue:
                                  available.containsKey(selection[slot])
                                  ? selection[slot]
                                  : '',
                              decoration: InputDecoration(labelText: label),
                              items: [
                                const DropdownMenuItem(
                                  value: '',
                                  child: Text('空'),
                                ),
                                for (final outfit in clothes.where(
                                  (item) => item['slot'] == slot,
                                ))
                                  DropdownMenuItem(
                                    value: outfit['id'] as String,
                                    child: Text(outfit['name'] as String),
                                  ),
                              ],
                              onChanged: (value) => setState(() {
                                final next = {...selection};
                                if (value == null || value.isEmpty) {
                                  next.remove(slot);
                                } else {
                                  next[slot] = value;
                                }
                                draft = next;
                              }),
                            ),
                          ),
                        ActionButton(
                          label: '保存搭配',
                          enabled: draft != null && !service.frozen,
                          action: () async {
                            await service.saveOutfit(pet, selection, revision);
                            await widget.controller.refresh();
                            if (!mounted) return;
                            revision = widget.controller.family!.revision;
                            setState(() {
                              draft = null;
                              current = service.wardrobe(pet);
                            });
                            if (context.mounted) showNotice(context, '搭配已保存。');
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
