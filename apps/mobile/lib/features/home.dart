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
  late HomeView view = widget.controller.homeLayout.isEmpty
      ? HomeView.courtyard
      : HomeView.veranda;
  FamilyController get controller => widget.controller;
  FamilyOverview get family => controller.family!;
  Future<void> parentMode() async {
    await openPage(context, ParentHome(controller: controller));
    controller.lock();
  }

  void preview() => openPage(
    context,
    AppearancePreview(initial: family.companion, initialStage: family.stage),
  );
  Future<void> decorate() async {
    final base = controller.baseSpace;
    if (base == null) return;
    setState(() => view = HomeView.veranda);
    await openPage(context, LayoutPage(controller: controller, space: base));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      toolbarHeight: 64,
      titleSpacing: 14,
      title: Row(
        children: [
          const GinkgoSeal(),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              switch (tab) {
                0 => '银杏家园',
                1 => '小事手账',
                _ => '成长手记',
              },
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Center(child: PointsPill(family.balance)),
        IconButton(
          tooltip: '家长入口',
          onPressed: parentMode,
          icon: const Icon(Icons.key_rounded),
        ),
        const SizedBox(width: 4),
      ],
    ),
    body: switch (tab) {
      0 => garden(),
      1 => TaskList(controller: controller),
      _ => GrowthPage(controller: controller),
    },
    bottomNavigationBar: DecoratedBox(
      decoration: const BoxDecoration(
        color: cream,
        border: Border(top: BorderSide(color: outline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            children: [
              for (final entry in const [
                (Icons.cottage_outlined, '小家'),
                (Icons.menu_book_rounded, '小事'),
                (Icons.auto_stories_outlined, '成长'),
              ].indexed)
                Expanded(
                  child: Semantics(
                    selected: tab == entry.$1,
                    child: TextButton.icon(
                      onPressed: () => setState(() => tab = entry.$1),
                      icon: Icon(entry.$2.$1, size: 22),
                      label: Text(entry.$2.$2),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        foregroundColor: tab == entry.$1
                            ? terracotta
                            : mutedInk,
                        backgroundColor: tab == entry.$1 ? wheat : null,
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: tab == entry.$1
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(19),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget garden() {
    final pending = controller.tasks.where((task) => task.canSubmit).length;
    final waiting = controller.tasks
        .where((task) => task.state == 'SUBMITTED')
        .length;
    final frozen = controller.service!.frozen;
    final journal = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 11, 10, 6),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 9,
                      children: [
                        Text(
                          family.companion.nickname,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            color: ink,
                          ),
                        ),
                        Text(
                          family.companion.label,
                          style: const TextStyle(color: mutedInk, fontSize: 15),
                        ),
                      ],
                    ),
                    Text(
                      '${stageNames[family.stage - 1]} · 第 ${family.stage} 阶段',
                      style: const TextStyle(fontSize: 14, color: mutedInk),
                    ),
                  ],
                ),
              ),
              TextButton(onPressed: preview, child: const Text('外观预览')),
              TextButton(
                onPressed: frozen
                    ? null
                    : () => openPage(
                        context,
                        SwitchCompanion(controller: controller),
                      ),
                child: const Text('换伙伴'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WorkshopAction(
                '换装',
                Icons.checkroom_outlined,
                const Color(0xFFF0DBCE),
                const Color(0xFF925347),
                () => openPage(context, WardrobePage(controller: controller)),
              ),
              _WorkshopAction(
                '布置',
                Icons.chair_outlined,
                const Color(0xFFF1DFB5),
                const Color(0xFF835A2E),
                frozen ? null : decorate,
              ),
              _WorkshopAction(
                '空间',
                Icons.cottage_outlined,
                const Color(0xFFDCE7E9),
                const Color(0xFF476A7C),
                () => openPage(context, SpacesPage(controller: controller)),
              ),
              _WorkshopAction(
                '成果兑换',
                Icons.redeem_rounded,
                const Color(0xFFE9DFE9),
                const Color(0xFF785C77),
                () => openPage(context, CatalogPage(controller: controller)),
              ),
            ],
          ),
        ),
        if (frozen)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Text('这台设备等待迁移，可查看小家和成果。'),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Material(
            color: cream,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: outline),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.bookmark_outline_rounded,
                color: terracotta,
              ),
              title: const Text(
                '我的小事',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                pending + waiting == 0
                    ? (controller.tasks.isEmpty ? '家长还没有添加任务。' : '暂时没有待完成的小事。')
                    : [
                        if (pending > 0) '$pending 件待完成',
                        if (waiting > 0) '$waiting 件待家长确认',
                      ].join(' · '),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => setState(() => tab = 1),
            ),
          ),
        ),
        if (controller.wish case final wish?)
          TextButton.icon(
            icon: const Icon(Icons.bookmark_rounded),
            label: Text(
              '心愿 · ${controller.rules.catalog[wish['item_id']]?['name']}',
            ),
            onPressed: () {
              final product = controller.rules.catalog[wish['item_id']];
              if (product != null) {
                openPage(
                  context,
                  RewardPage(controller: controller, product: product),
                );
              }
            },
          ),
      ],
    );
    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= 840;
        final scene = GardenScene(
          companion: family.companion,
          stage: family.stage,
          rules: controller.rules,
          scene: SceneDefinition(controller.rules, 'base_room'),
          pieces: controller.homeLayout.map(ScenePiece.fromRow).toList(),
          outfit: outfitFiles(controller.outfit),
          view: view,
          onViewChanged: (v) => setState(() => view = v),
          immersive: true,
          height: wide
              ? box.maxHeight
              : (box.maxHeight * .63).clamp(285.0, 625.0),
        );
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 7, child: scene),
              Expanded(flex: 4, child: SingleChildScrollView(child: journal)),
            ],
          );
        }
        return ListView(children: [scene, journal]);
      },
    );
  }
}

class _WorkshopAction extends StatelessWidget {
  const _WorkshopAction(
    this.label,
    this.icon,
    this.fill,
    this.color,
    this.action,
  );
  final String label;
  final IconData icon;
  final Color fill, color;
  final VoidCallback? action;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      button: true,
      enabled: action != null,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: action,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Container(
                width: 49,
                height: 39,
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: const BorderRadius.all(
                    Radius.elliptical(18, 15),
                  ),
                ),
                child: Icon(
                  icon,
                  color: action == null ? mutedInk : color,
                  size: 25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: ink,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
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
            stage: widget.controller.family!.stage,
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
                        Row(
                          children: [
                            Image.asset(
                              family.companion.artwork(family.stage),
                              height: 74,
                              width: 74,
                              filterQuality: FilterQuality.medium,
                              excludeFromSemantics: true,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                '成长记录',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ],
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
