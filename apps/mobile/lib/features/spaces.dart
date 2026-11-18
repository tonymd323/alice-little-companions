import 'package:material_ui/material_ui.dart';

import '../application/controller.dart';
import '../application/family.dart';
import '../domain/companions.dart';
import '../domain/layout_rules.dart';
import '../domain/pin.dart';
import '../domain/rules.dart';
import 'common.dart';
import 'garden.dart';

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
                                SceneDefinition(
                                  service.rules,
                                  space['scene_id'] as String,
                                ).background,
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
    await service.layout(widget.id),
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
                                LayoutPage(
                                  controller: widget.controller,
                                  space: space,
                                ),
                              );
                              if (mounted) setState(() => data = load());
                            },
                            icon: const Icon(Icons.chair_outlined),
                            label: const Text('布置空间'),
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

class LayoutPage extends StatefulWidget {
  const LayoutPage({super.key, required this.controller, required this.space});
  final FamilyController controller;
  final Json space;

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> {
  FamilyService get service => widget.controller.service!;
  String get space => widget.space['id'] as String;
  late final scene = SceneDefinition(
    service.rules,
    widget.space['scene_id'] as String,
  );
  late final load = prepare();
  final draft = <String, PlacementDraft>{};
  final inventory = <String, Json>{};
  String? selected;
  String? problem;
  List<Json> wardrobe = [];

  Future<bool> prepare() async {
    for (final item in await service.items()) {
      if (item['slot'] == null &&
          (item['bound_space'] == null || item['bound_space'] == space)) {
        inventory[item['id'] as String] = item;
      }
    }
    if (scene.id == 'base_room') {
      for (final free in freeFurnishings.entries) {
        inventory[free.key] = {
          'id': free.key,
          'item_id': free.key,
          'name': free.value,
          'asset_id': free.key,
        };
      }
    }
    for (final place in await service.layout(space)) {
      final entry = PlacementDraft.fromRow(place);
      draft[entry.id] = entry;
    }
    wardrobe = await service.wardrobe(widget.controller.family!.companion);
    return true;
  }

  String asset(String id) => inventory[id]!['asset_id'] as String;
  String name(String id) => inventory[id]!['name'] as String;

  void move(Offset point) {
    final id = selected;
    if (id == null || !draft.containsKey(id)) return;
    final place = scene.snap(
      draft[id]!.at(point.dx.clamp(0, 1), point.dy.clamp(0, 1)),
      asset(id),
    );
    setState(() {
      draft[id] = place;
      try {
        scene.validate(place, asset(id), name(id));
        problem = null;
      } on UserError catch (error) {
        problem = error.message;
      }
    });
  }

  void add(String id) {
    setState(() {
      draft[id] = scene.initialPlacement(id, asset(id), draft.length);
      selected = id;
      problem = null;
    });
  }

  void reorder(int change) {
    final list = draft.values.toList()..sort((a, b) => a.z.compareTo(b.z));
    final index = list.indexWhere((place) => place.id == selected);
    final next = index + change;
    if (index < 0 || next < 0 || next >= list.length) return;
    setState(() {
      final item = list.removeAt(index);
      list.insert(next, item);
      for (final (index, value) in list.indexed) {
        draft[value.id] = value.withOrder(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('布置 · ${widget.space['name']}')),
    body: PageBody(
      maxWidth: 1080,
      child: FutureBuilder(
        future: load,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return snapshot.hasError
                ? const GardenCard(child: Text('暂时无法读取布局。'))
                : const Center(child: CircularProgressIndicator());
          }
          final family = widget.controller.family!;
          final id = selected;
          final picked = id == null ? null : draft[id];
          final layout = draft.values.toList()
            ..sort((a, b) => a.z.compareTo(b.z));
          final canvas = GardenScene(
            companion: family.companion,
            stage: family.stage,
            rules: service.rules,
            scene: scene,
            outfit: outfitFiles(wardrobe),
            pieces: [
              for (final place in layout)
                ScenePiece(place, asset(place.id), name(place.id)),
            ],
            selected: id,
            editing: true,
            onFloor: move,
            onSelect: (id) => setState(() {
              selected = id;
              problem = null;
            }),
          );
          final controls = GardenCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('物品栏', style: Theme.of(context).textTheme.titleLarge),
                Text(
                  picked == null
                      ? '选中一件物品后，可点按或拖动到场景中。'
                      : '正在布置 ${name(picked.id)}',
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (final item in inventory.entries)
                      OutlinedButton(
                        onPressed: () {
                          try {
                            if (draft.containsKey(item.key)) {
                              setState(() {
                                selected = item.key;
                                problem = null;
                              });
                            } else {
                              add(item.key);
                            }
                          } on UserError catch (error) {
                            showNotice(context, error.message);
                          }
                        },
                        child: Text(
                          '${item.value['name']}${draft.containsKey(item.key) ? ' · 在场景' : ''}',
                        ),
                      ),
                  ],
                ),
                if (picked != null) ...[
                  const SizedBox(height: 10),
                  if (picked.mount == null)
                    Wrap(
                      children: [
                        for (final (icon, label, delta) in [
                          (Icons.arrow_back, '左移', const Offset(-.02, 0)),
                          (Icons.arrow_forward, '右移', const Offset(.02, 0)),
                          (Icons.arrow_upward, '上移', const Offset(0, -.02)),
                          (Icons.arrow_downward, '下移', const Offset(0, .02)),
                        ])
                          IconButton(
                            tooltip: label,
                            onPressed: () =>
                                move(Offset(picked.x, picked.y) + delta),
                            icon: Icon(icon),
                          ),
                      ],
                    ),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () =>
                            setState(() => draft[id!] = picked.mirror()),
                        child: const Text('镜像'),
                      ),
                      OutlinedButton(
                        onPressed: () => reorder(1),
                        child: const Text('向前一层'),
                      ),
                      OutlinedButton(
                        onPressed: () => reorder(-1),
                        child: const Text('向后一层'),
                      ),
                      OutlinedButton(
                        onPressed: () => setState(() {
                          draft.remove(id);
                          selected = null;
                          problem = null;
                        }),
                        child: const Text('收回'),
                      ),
                    ],
                  ),
                ],
                if (problem != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      problem!,
                      style: const TextStyle(color: Color(0xFF863A2C)),
                    ),
                  ),
                const SizedBox(height: 10),
                ActionButton(
                  label: '保存布置',
                  enabled: !service.frozen && problem == null,
                  action: () async {
                    await service.saveLayout(
                      widget.space['id'] as String,
                      widget.space['layout_version'] as int,
                      layout,
                    );
                    await widget.controller.refresh();
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消本次修改'),
                ),
              ],
            ),
          );
          return LayoutBuilder(
            builder: (context, box) => box.maxWidth >= 850
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: canvas),
                      const SizedBox(width: 12),
                      Expanded(child: controls),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [canvas, const SizedBox(height: 12), controls],
                  ),
          );
        },
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
  late final Future<List<Json>> items = service.items();
  late Future<List<Json>> current = service.wardrobe(pet);
  late int revision = widget.controller.family!.revision;
  Map<String, String>? draft;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('伙伴换装')),
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
                  outfit: {
                    for (final entry in selection.entries)
                      if (available.containsKey(entry.value))
                        entry.key:
                            available[entry.value]!['asset_id'] as String,
                  },
                ),
                const SizedBox(height: 12),
                CompanionPicker(
                  selected: pet,
                  onSelected: (value) => setState(() {
                    pet = value;
                    draft = null;
                    current = service.wardrobe(pet);
                  }),
                ),
                const SizedBox(height: 12),
                GardenCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (clothes.isEmpty) const Text('还没有配饰或衣服。可在成果兑换中先试穿。'),
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
                            initialValue: available.containsKey(selection[slot])
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
