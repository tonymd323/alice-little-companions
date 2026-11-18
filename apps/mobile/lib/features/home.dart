import 'package:material_ui/material_ui.dart';

import '../application/controller.dart';
import '../application/family.dart';
import '../domain/companions.dart';
import '../domain/layout_rules.dart';
import 'common.dart';
import 'garden.dart';
import 'rewards.dart';
import 'spaces.dart';
import 'tasks.dart';

class FamilyHome extends StatefulWidget {
  const FamilyHome({super.key, required this.controller});
  final FamilyController controller;

  @override
  State<FamilyHome> createState() => _FamilyHomeState();
}

class _FamilyHomeState extends State<FamilyHome> {
  int tab = 0;
  FamilyController get controller => widget.controller;
  FamilyOverview get family => controller.family!;

  Future<void> parentMode() async {
    await openPage(context, ParentHome(controller: controller));
    controller.lock();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: faintGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.energy_savings_leaf_rounded,
              color: foliage,
            ),
          ),
          const SizedBox(width: 10),
          const Flexible(
            child: Text('小小伙伴', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
      actions: [
        Center(child: PointsPill(family.balance)),
        const SizedBox(width: 4),
        IconButton(
          tooltip: '家长入口',
          onPressed: parentMode,
          icon: const Icon(Icons.admin_panel_settings_outlined),
        ),
        const SizedBox(width: 4),
      ],
    ),
    body: switch (tab) {
      0 => garden(),
      1 => TaskList(controller: controller),
      _ => GrowthPage(controller: controller),
    },
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (value) => setState(() => tab = value),
      backgroundColor: cream,
      indicatorColor: faintGreen,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.cottage_outlined),
          selectedIcon: Icon(Icons.cottage_rounded),
          label: '小家',
        ),
        NavigationDestination(
          icon: Icon(Icons.checklist_outlined),
          label: '小事',
        ),
        NavigationDestination(
          icon: Icon(Icons.spa_outlined),
          selectedIcon: Icon(Icons.spa_rounded),
          label: '成长',
        ),
      ],
    ),
  );

  Widget garden() {
    final available = controller.tasks
        .where((task) => task.canSubmit)
        .toList(growable: false);
    final waiting = controller.tasks
        .where((task) => task.state == 'SUBMITTED')
        .length;
    final scene = GardenScene(
      companion: family.companion,
      stage: family.stage,
      rules: controller.rules,
      scene: SceneDefinition(controller.rules, 'base_room'),
      pieces: controller.homeLayout.map(ScenePiece.fromRow).toList(),
      outfit: outfitFiles(controller.outfit),
    );
    final controls = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (controller.service!.frozen)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: GardenCard(child: Text('这台设备等待迁移，可查看小家和成果。')),
          ),
        GardenCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                family.companion.nickname,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                '${family.companion.label} · ${stageNames[family.stage - 1]}',
                style: const TextStyle(color: mutedInk),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: controller.service!.frozen
                        ? null
                        : () => openPage(
                            context,
                            SwitchCompanion(controller: controller),
                          ),
                    child: const Text('换伙伴'),
                  ),
                  TextButton(
                    onPressed: () => openPage(
                      context,
                      AppearancePreview(
                        initial: family.companion,
                        initialStage: family.stage,
                      ),
                    ),
                    child: const Text('外观预览'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GardenCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () =>
                        openPage(context, CatalogPage(controller: controller)),
                    icon: const Icon(Icons.redeem_outlined),
                    label: const Text('成果兑换'),
                  ),
                  OutlinedButton(
                    onPressed: () =>
                        openPage(context, WardrobePage(controller: controller)),
                    child: const Text('换装'),
                  ),
                  OutlinedButton(
                    onPressed: () =>
                        openPage(context, SpacesPage(controller: controller)),
                    child: const Text('空间'),
                  ),
                  if (controller.baseSpace != null &&
                      !controller.service!.frozen)
                    OutlinedButton(
                      onPressed: () => openPage(
                        context,
                        LayoutPage(
                          controller: controller,
                          space: controller.baseSpace!,
                        ),
                      ),
                      child: const Text('布置'),
                    ),
                ],
              ),
              if (controller.wish case final wish?)
                TextButton(
                  onPressed: () {
                    final product = controller.rules.catalog[wish['item_id']];
                    if (product != null) {
                      openPage(
                        context,
                        RewardPage(controller: controller, product: product),
                      );
                    }
                  },
                  child: Text(
                    '心愿 · ${controller.rules.catalog[wish['item_id']]?['name']}',
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GardenCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('我的小事', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              if (available.isEmpty && waiting == 0)
                Text(controller.tasks.isEmpty ? '家长还没有添加任务。' : '暂时没有待完成的小事。'),
              if (available.isNotEmpty) Text('${available.length} 件待完成'),
              if (waiting > 0) Text('$waiting 件待家长确认'),
              if (available.isNotEmpty || waiting > 0) ...[
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () => setState(() => tab = 1),
                  child: const Text('查看小事'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, box) => PageBody(
        maxWidth: 1160,
        child: box.maxWidth >= 880
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: scene),
                  const SizedBox(width: 16),
                  Expanded(child: controls),
                ],
              )
            : Column(children: [scene, const SizedBox(height: 14), controls]),
      ),
    );
  }
}

class SwitchCompanion extends StatefulWidget {
  const SwitchCompanion({super.key, required this.controller});
  final FamilyController controller;

  @override
  State<SwitchCompanion> createState() => _SwitchCompanionState();
}

class _SwitchCompanionState extends State<SwitchCompanion> {
  late Companion selected = widget.controller.family!.companion;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('选择伙伴')),
    body: PageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GardenScene(
            companion: selected,
            stage: widget.controller.family!.stage,
          ),
          const SizedBox(height: 14),
          CompanionPicker(
            selected: selected,
            onSelected: (value) => setState(() => selected = value),
          ),
          const SizedBox(height: 14),
          ActionButton(
            label: '和它一起长大',
            action: () async {
              await widget.controller.service!.selectCompanion(selected);
              await widget.controller.refresh();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}

class GrowthPage extends StatelessWidget {
  const GrowthPage({super.key, required this.controller});
  final FamilyController controller;

  @override
  Widget build(BuildContext context) {
    final family = controller.family!;
    final records = controller.tasks.where(
      (task) => task.state == 'APPROVED' || task.state == 'CORRECTED',
    );
    final next = family.stage < 6
        ? controller.rules.thresholds[family.stage - 1]
        : null;
    final history = records.toList(growable: false);
    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            itemCount: history.length + 1,
            itemBuilder: (context, index) {
              if (index > 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TaskDetails(task: history[index - 1]),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GardenCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '成长记录',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${family.companion.nickname} · ${stageNames[family.stage - 1]}',
                        ),
                        Text(
                          '已有 ${family.days} 个成果日${next == null ? '' : ' · 下个外观 $next 天'}',
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => openPage(
                            context,
                            AppearancePreview(
                              initial: family.companion,
                              initialStage: family.stage,
                            ),
                          ),
                          child: const Text('外观预览'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (history.isEmpty)
                    const GardenCard(child: Text('家长确认的小事会留在这里。')),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
