import 'dart:io';

import 'package:material_ui/material_ui.dart';

import '../application/controller.dart';
import '../application/family.dart';
import '../domain/rules.dart';
import 'backup_pages.dart';
import 'common.dart';
import 'garden.dart';
import 'spaces.dart' show outfitFiles;
import 'parent_access.dart';
import 'rewards.dart';
import 'task_editor.dart';
import 'penalties.dart';
import 'update_page.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task, required this.onTap});
  final TaskEntry task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Material(
      color: cream,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          [
            if (task.projectTitle != null) task.projectTitle!,
            task.stateLabel,
            ?task.actual ?? task.due,
          ].join(' · '),
        ),
        trailing: onTap == null
            ? null
            : const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: outline),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );
}

class TaskTileList extends StatelessWidget {
  const TaskTileList({
    super.key,
    required this.header,
    required this.entries,
    this.onTap,
  });
  final Widget header;
  final List<TaskEntry> entries;
  final void Function(BuildContext, TaskEntry)? onTap;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          itemCount: entries.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return header;
            final entry = entries[index - 1];
            return TaskTile(
              key: ValueKey(entry.id),
              task: entry,
              onTap: onTap == null ? null : () => onTap!(context, entry),
            );
          },
        ),
      ),
    ),
  );
}

class TaskDetails extends StatefulWidget {
  const TaskDetails({
    super.key,
    required this.service,
    required this.task,
    this.readCurrent = false,
  });
  final FamilyService service;
  final TaskEntry task;
  final bool readCurrent;

  bool get canUseSnapshot => !readCurrent && task.detailsLoaded;

  @override
  State<TaskDetails> createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  late Future<TaskEntry>? details = load();

  Future<TaskEntry>? load() => widget.canUseSnapshot
      ? null
      : widget.service.task(widget.task.id);

  @override
  void didUpdateWidget(covariant TaskDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.service != widget.service ||
        oldWidget.task != widget.task ||
        oldWidget.readCurrent != widget.readCurrent) {
      details = load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.canUseSnapshot) return card(context, widget.task);
    return FutureBuilder<TaskEntry>(
      future: details,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const GardenCard(child: LinearProgressIndicator());
        }
        if (snapshot.data case final task?) return card(context, task);
        return GardenCard(
          child: TextButton(
            onPressed: () => setState(() => details = load()),
            child: const Text('重新读取小事详情'),
          ),
        );
      },
    );
  }

  Widget card(BuildContext context, TaskEntry task) => GardenCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (task.projectTitle case final project?)
          Text(project, style: const TextStyle(color: mutedInk)),
        Text(task.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          task.stateLabel,
          style: const TextStyle(
            color: terracotta,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (task.content.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(task.content),
        ],
        const SizedBox(height: 16),
        Text('完成标准', style: Theme.of(context).textTheme.titleMedium),
        Text(task.criteria),
        if (task.due case final due?) ...[
          const SizedBox(height: 8),
          Text('截止日期 $due'),
        ],
        if (task.actual case final actual?) ...[
          const SizedBox(height: 8),
          Text('发生日期 $actual'),
        ],
        if (task.submission case final note? when note.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('申报备注 · $note'),
        ],
        if (task.resolution.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(task.resolution),
        ],
        if (task.feedback case final feedback? when feedback.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('家长反馈', style: Theme.of(context).textTheme.titleMedium),
          Text(feedback),
        ],
        const SizedBox(height: 12),
        Text(
          '确认奖励 ${task.reward} 分',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class ChildTaskPage extends StatefulWidget {
  const ChildTaskPage({
    super.key,
    required this.controller,
    required this.task,
  });
  final FamilyController controller;
  final TaskEntry task;

  @override
  State<ChildTaskPage> createState() => _ChildTaskPageState();
}

class _ChildTaskPageState extends State<ChildTaskPage> {
  final note = TextEditingController();

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final current = widget.controller.currentTasks
          .where((entry) => entry.id == widget.task.id)
          .firstOrNull;
      final task = current ?? widget.task;
      return Scaffold(
        appBar: AppBar(title: const Text('我的小事')),
        body: PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TaskDetails(
                key: current == null
                    ? ValueKey(widget.controller.family?.revision)
                    : null,
                service: widget.controller.service!,
                task: task,
                readCurrent: current == null,
              ),
              if (current?.canSubmit == true &&
                  !widget.controller.service!.frozen) ...[
                const SizedBox(height: 16),
                FormFieldLabel(
                  label: '想留一句话（选填）',
                  controller: note,
                  limit: 500,
                  lines: 2,
                ),
                ActionButton(
                  label: '我完成了',
                  action: () async {
                    FocusScope.of(context).unfocus();
                    await widget.controller.service!.submit(task.id, note.text);
                    await widget.controller.refresh();
                    if (context.mounted) showNotice(context, '已申报，等家长确认。');
                  },
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

class AllTaskEntries extends StatelessWidget {
  const AllTaskEntries({
    super.key,
    required this.controller,
    required this.builder,
    this.loading,
  });
  final FamilyController controller;
  final Widget Function(BuildContext, List<TaskEntry>) builder;
  final Widget? loading;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      // The underlying history page can stay mounted behind the parent route.
      final visible = ModalRoute.of(context)?.isCurrent ?? true;
      return FutureBuilder<List<TaskEntry>>(
        future: visible ? controller.allTaskEntries : null,
        builder: (context, snapshot) {
          if (snapshot.data case final entries?
              when snapshot.connectionState == ConnectionState.done || !visible) {
            return builder(context, entries);
          }
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasError) {
            return PageBody(
              child: ActionButton(
                label: '重新读取小事',
                action: controller.refresh,
              ),
            );
          }
          return loading ?? const Align(
            alignment: Alignment.topCenter,
            child: LinearProgressIndicator(),
          );
        },
      );
    },
  );
}

class TaskList extends StatefulWidget {
  const TaskList({super.key, required this.controller});
  final FamilyController controller;

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  int filter = 0;
  static const filters = ['待完成', '待确认', '已完成'];

  bool includes(TaskEntry task) => switch (filter) {
    0 => task.canSubmit || task.state == 'WAITING',
    1 => task.state == 'SUBMITTED',
    _ => task.state == 'APPROVED' || task.state == 'CORRECTED',
  };

  @override
  Widget build(BuildContext context) {
    if (filter == 2) {
      return AllTaskEntries(
        controller: widget.controller,
        builder: body,
        loading: body(context, const [], loading: true),
      );
    }
    return body(context, widget.controller.currentTasks);
  }

  Widget body(
    BuildContext context,
    List<TaskEntry> tasks, {
    bool loading = false,
  }) {
    final entries = tasks.where(includes).toList(growable: false);
    return TaskTileList(
      entries: entries,
      onTap: (context, entry) => openPage(
        context,
        ChildTaskPage(controller: widget.controller, task: entry),
      ),
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('我的小事', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (var i = 0; i < filters.length; i++)
                ChoiceChip(
                  label: Text(filters[i]),
                  selected: filter == i,
                  onSelected: (_) => setState(() => filter = i),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (loading)
            const LinearProgressIndicator()
          else if (entries.isEmpty)
            GardenCard(
              child: Column(
                children: [
                  Image.asset(
                    widget.controller.family!.companion.artwork(
                      widget.controller.family!.stage,
                    ),
                    width: 100,
                    height: 94,
                    filterQuality: FilterQuality.medium,
                    excludeFromSemantics: true,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    filter == 0 && widget.controller.family!.taskCount == 0
                        ? '家长还没有添加任务。'
                        : '这里还没有${filters[filter]}的小事。',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class ParentHome extends StatelessWidget {
  const ParentHome({super.key, required this.controller});
  final FamilyController controller;

  @override
  Widget build(BuildContext context) => ParentFrame(
    controller: controller,
    title: '家长管理',
    home: true,
    child: ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final waiting = controller.currentTasks.where(
          (task) => task.state == 'SUBMITTED',
        );
        return PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GardenCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${controller.family!.nickname}的小家',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        PointsPill(controller.family!.balance),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if ((controller.family!.latestDay?.compareTo(
                              controller.service!.today,
                            ) ??
                            0) >
                        0)
                      const Text('设备日期早于上次记账日期，请核对时间。'),
                    Text(
                      controller.service!.frozen ? '当前设备只读' : '当前设备可记账',
                      style: const TextStyle(color: mutedInk),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: controller.service!.frozen
                        ? null
                        : () => openPage(
                            context,
                            PublishPage(controller: controller),
                          ),
                    label: const Text('发布小事'),
                    icon: const Icon(Icons.add_rounded),
                  ),
                  OutlinedButton(
                    onPressed: controller.service!.frozen
                        ? null
                        : () => openPage(
                            context,
                            ManageTasksPage(controller: controller),
                          ),
                    child: const Text('小事与计划'),
                  ),
                  OutlinedButton(
                    onPressed: controller.service!.frozen
                        ? null
                        : () => openPage(
                            context,
                            PublishPage(controller: controller, backfill: true),
                          ),
                    child: const Text('补录成果'),
                  ),
                  OutlinedButton(
                    onPressed: () => openPage(
                      context,
                      PenaltiesPage(controller: controller),
                    ),
                    child: const Text('扣分与撤销'),
                  ),
                  OutlinedButton(
                    onPressed: () => openPage(
                      context,
                      CorrectionsPage(controller: controller),
                    ),
                    child: const Text('误奖更正'),
                  ),
                  OutlinedButton(
                    onPressed: () =>
                        openPage(context, DataPage(controller: controller)),
                    child: const Text('备份与迁移'),
                  ),
                  if (Platform.isAndroid)
                    OutlinedButton(
                      onPressed: () =>
                          openPage(context, UpdatePage(controller: controller)),
                      child: const Text('应用更新'),
                    ),
                  OutlinedButton(
                    onPressed: () => openPage(
                      context,
                      PurchaseHistoryPage(controller: controller, parent: true),
                    ),
                    child: const Text('兑换与退款'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        openPage(context, LedgerPage(controller: controller)),
                    label: const Text('积分流水'),
                    icon: const Icon(Icons.receipt_long_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                '待确认 · ${waiting.length}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              if (waiting.isEmpty) const GardenCard(child: Text('当前没有待确认的小事。')),
              for (final entry in waiting)
                TaskTile(
                  task: entry,
                  onTap: () => openPage(
                    context,
                    ApprovePage(controller: controller, task: entry),
                  ),
                ),
            ],
          ),
        );
      },
    ),
  );
}

class TypeChoice extends StatelessWidget {
  const TypeChoice({
    super.key,
    required this.rules,
    required this.value,
    required this.onChanged,
  });
  final Rules rules;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    initialValue: value,
    isExpanded: true,
    decoration: const InputDecoration(labelText: '投入类型'),
    items: [
      for (final type in rules.types)
        DropdownMenuItem(
          value: type.id,
          child: Text('${type.label} · ${type.points} 分'),
        ),
    ],
    onChanged: (value) {
      if (value != null) onChanged(value);
    },
  );
}

class DayChoice extends StatelessWidget {
  const DayChoice({
    super.key,
    required this.label,
    required this.day,
    required this.today,
    required this.onChanged,
    this.future = false,
  });

  final String label;
  final String? day;
  final String today;
  final ValueChanged<String> onChanged;
  final bool future;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: () async {
      final now = parseDay(today);
      final lower = future ? now : DateTime(1);
      final upper = future ? DateTime(now.year + 20) : now;
      final selected = parseDay(day ?? today);
      final initial = selected.isBefore(lower)
          ? lower
          : selected.isAfter(upper)
          ? upper
          : selected;
      final date = await showDatePicker(
        context: context,
        initialDate: initial,
        currentDate: now,
        firstDate: lower,
        lastDate: upper,
      );
      if (date != null && context.mounted) onChanged(dateKey(date));
    },
    icon: const Icon(Icons.calendar_today_outlined),
    label: Text(
      day == null ? label : '$label · $day',
      textAlign: TextAlign.center,
    ),
  );
}

class ApprovePage extends StatefulWidget {
  const ApprovePage({super.key, required this.controller, required this.task});
  final FamilyController controller;
  final TaskEntry task;

  @override
  State<ApprovePage> createState() => _ApprovePageState();
}

class _ApprovePageState extends State<ApprovePage> {
  final feedback = TextEditingController();
  late String date = widget.task.actual ?? widget.controller.service!.today;

  @override
  void dispose() {
    feedback.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ParentFrame(
    controller: widget.controller,
    title: '确认成果',
    child: PageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TaskDetails(service: widget.controller.service!, task: widget.task),
          const SizedBox(height: 16),
          DayChoice(
            label: '实际发生日期',
            day: date,
            today: widget.controller.service!.today,
            onChanged: (value) => setState(() => date = value),
          ),
          const SizedBox(height: 12),
          FormFieldLabel(
            label: '给孩子的反馈（选填）',
            controller: feedback,
            limit: 500,
            lines: 2,
          ),
          ActionButton(
            label: '确认并入账 ${widget.task.reward} 分',
            enabled: !widget.controller.service!.frozen,
            action: () async {
              FocusScope.of(context).unfocus();
              final result = await widget.controller.service!.approve(
                widget.task.id,
                date,
                feedback.text,
                session: widget.controller.session,
              );
              await widget.controller.refresh();
              if (!context.mounted) return;
              if (result['new_stage'] == true) {
                await showEvolution(
                  context,
                  widget.controller.family!.companion,
                  result['previous_stage'] as int,
                  result['stage'] as int,
                  receipt: [
                    widget.task.title,
                    '+${result['delta']} 分 · +1 经验',
                    if (feedback.text.trim().isNotEmpty) feedback.text.trim(),
                  ].join('\n'),
                  outfit: outfitFiles(widget.controller.outfit),
                );
              } else {
                await showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('成果已确认'),
                    scrollable: true,
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.task.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        if (feedback.text.trim().isNotEmpty)
                          Text(feedback.text.trim()),
                        const SizedBox(height: 8),
                        Text(
                          '发生日期 $date · +${result['delta']} 分 · +${result['experience_delta'] ?? 0} 经验',
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('完成'),
                      ),
                    ],
                  ),
                );
              }
              if (context.mounted) Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
          ActionButton(
            label: '退回继续完成',
            outlined: true,
            enabled: !widget.controller.service!.frozen,
            action: () async {
              await widget.controller.service!.returnTask(
                widget.task.id,
                feedback.text,
                session: widget.controller.session,
              );
              await widget.controller.refresh();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}

class LedgerPage extends StatelessWidget {
  const LedgerPage({super.key, required this.controller});
  final FamilyController controller;

  @override
  Widget build(BuildContext context) => ParentFrame(
    controller: controller,
    title: '积分流水',
    child: FutureBuilder(
      future: controller.service!.ledger(),
      builder: (context, snapshot) => PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: PointsPill(controller.family!.balance),
            ),
            const SizedBox(height: 12),
            if (!snapshot.hasData)
              const Center(child: CircularProgressIndicator())
            else if (snapshot.data!.isEmpty)
              const GardenCard(child: Text('还没有积分流水。'))
            else
              for (final row in snapshot.data!)
                ListTile(
                  title: Text(switch (row['kind']) {
                    'reward' => '确认成果',
                    'penalty' => '扣分',
                    'penalty_reversal' => '撤销扣分',
                    'purchase' => '兑换成果',
                    'refund' => '退回兑换',
                    'correction' => '更正奖励',
                    _ => '积分变动',
                  }),
                  subtitle: Text(
                    '${row['posted_day']} · 余额 ${row['balance_after']} 分',
                  ),
                  trailing: Text(
                    '${(row['delta'] as int) >= 0 ? '+' : ''}${row['delta']} 分',
                  ),
                ),
          ],
        ),
      ),
    ),
  );
}
