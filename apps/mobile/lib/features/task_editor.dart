import 'package:material_ui/material_ui.dart';

import '../application/controller.dart';
import '../application/family.dart';
import '../domain/rules.dart';
import 'common.dart';
import 'garden.dart';
import 'parent_access.dart';
import 'tasks.dart' show DayChoice, TaskDetails, TaskTile, TypeChoice;

class PublishPage extends StatefulWidget {
  const PublishPage({
    super.key,
    required this.controller,
    this.template,
    this.schedule,
    this.backfill = false,
    this.correcting,
  });

  final FamilyController controller;
  final Json? template;
  final RepeatSchedule? schedule;
  final bool backfill;
  final String? correcting;

  @override
  State<PublishPage> createState() => _PublishPageState();
}

class _StageFields {
  final title = TextEditingController();
  final criteria = TextEditingController();
  String type = 'light';

  StageDraft get draft => StageDraft(title.text, criteria.text, type);

  void dispose() {
    title.dispose();
    criteria.dispose();
  }
}

class _PublishPageState extends State<PublishPage> {
  late final title = TextEditingController(
    text: widget.template?['title'] as String?,
  );
  late final content = TextEditingController(
    text: widget.template?['content'] as String?,
  );
  late final criteria = TextEditingController(
    text: widget.template?['criteria'] as String?,
  );
  final feedback = TextEditingController();
  late String type = widget.template?['task_type'] as String? ?? 'light';
  late String mode = widget.template == null ? 'once' : 'recurring';
  late String start = widget.schedule?.from ?? today;
  late String end =
      widget.schedule?.until ??
      dateKey(parseDay(today).add(const Duration(days: 6)));
  late Set<int> weekdays =
      widget.schedule?.weekdays.toSet() ?? {1, 2, 3, 4, 5, 6, 7};
  late int count = widget.schedule?.count ?? 1;
  late String actual = today;
  String? due;
  final stages = <_StageFields>[_StageFields(), _StageFields()];

  FamilyService get service => widget.controller.service!;
  String get today => service.today;
  Rules get rules => widget.controller.rules;
  RepeatSchedule get schedule =>
      RepeatSchedule(start, end, count, weekdays: weekdays.toList()..sort());
  bool get editing => widget.template != null;

  @override
  void dispose() {
    title.dispose();
    content.dispose();
    criteria.dispose();
    feedback.dispose();
    for (final stage in stages) {
      stage.dispose();
    }
    super.dispose();
  }

  int get budget {
    if (mode == 'staged') {
      return stages.fold(
        0,
        (sum, stage) => sum + rules.type(stage.type).points,
      );
    }
    final value = rules.type(type).points;
    if (mode != 'recurring') return value;
    final week = dateKey(parseDay(today).add(const Duration(days: 6)));
    return schedule.days(week, starting: today).length * count * value;
  }

  Future<void> save() async {
    FocusScope.of(context).unfocus();
    final draft = mode == 'staged'
        ? TaskDraft(
            title.text,
            content.text,
            stages.first.criteria.text,
            stages.first.type,
            due: due,
          )
        : TaskDraft(title.text, content.text, criteria.text, type, due: due);
    final session = widget.controller.session;
    if (widget.backfill) {
      await service.backfill(
        draft,
        actual,
        feedback.text,
        session: session,
        correcting: widget.correcting,
      );
    } else if (editing) {
      await service.editRecurring(
        widget.template!['id'] as String,
        widget.template!['current_version'] as int,
        draft,
        schedule,
        session: session,
      );
    } else if (mode == 'recurring') {
      await service.publishRecurring(draft, schedule, session: session);
    } else if (mode == 'staged') {
      await service.publishProject(
        draft,
        stages.map((stage) => stage.draft).toList(),
        session: session,
      );
    } else {
      await service.publish(draft, session: session);
    }
    await widget.controller.refresh();
    if (!mounted) return;
    Navigator.pop(context);
    showNotice(
      context,
      widget.backfill
          ? '已补录并确认成果。'
          : editing
          ? '已更新未来计划。'
          : '小事已发布。',
    );
  }

  @override
  Widget build(BuildContext context) => ParentFrame(
    controller: widget.controller,
    title: widget.backfill
        ? '补录真实成果'
        : editing
        ? '编辑重复计划'
        : '发布小事',
    child: PageBody(
      child: GardenCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormFieldLabel(label: '小事名称', controller: title, limit: 40),
            FormFieldLabel(
              label: '内容说明（选填）',
              controller: content,
              limit: 500,
              lines: 2,
            ),
            if (!widget.backfill && !editing) ...[
              DropdownButtonFormField<String>(
                initialValue: mode,
                decoration: const InputDecoration(labelText: '执行方式'),
                items: const [
                  DropdownMenuItem(value: 'once', child: Text('单次')),
                  DropdownMenuItem(value: 'recurring', child: Text('按日期重复')),
                  DropdownMenuItem(value: 'staged', child: Text('分阶段')),
                ],
                onChanged: (value) => setState(() => mode = value!),
              ),
              const SizedBox(height: 14),
            ],
            if (mode != 'staged') ...[
              FormFieldLabel(
                label: '完成标准',
                controller: criteria,
                limit: 300,
                lines: 2,
              ),
              TypeChoice(
                rules: rules,
                value: type,
                onChanged: (value) => setState(() => type = value),
              ),
              const SizedBox(height: 14),
            ],
            if (widget.backfill) ...[
              DayChoice(
                label: '实际发生日期',
                day: actual,
                today: today,
                onChanged: (day) => setState(() => actual = day),
              ),
              const SizedBox(height: 12),
              FormFieldLabel(
                label: '给孩子的反馈（选填）',
                controller: feedback,
                lines: 2,
                limit: 500,
              ),
            ] else if (mode == 'recurring')
              repeatForm()
            else ...[
              DayChoice(
                label: '截止日期（选填）',
                day: due,
                today: today,
                future: true,
                onChanged: (day) => setState(() => due = day),
              ),
              if (due != null)
                TextButton(
                  onPressed: () => setState(() => due = null),
                  child: const Text('清除截止日期'),
                ),
            ],
            if (mode == 'staged') ...[
              for (final (index, stage) in stages.indexed)
                Padding(
                  key: ObjectKey(stage),
                  padding: const EdgeInsets.only(top: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '阶段 ${index + 1}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          if (stages.length > 2)
                            IconButton(
                              tooltip: '移除阶段 ${index + 1}',
                              onPressed: () {
                                setState(() => stages.remove(stage));
                                WidgetsBinding.instance.addPostFrameCallback(
                                  (_) => stage.dispose(),
                                );
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                        ],
                      ),
                      FormFieldLabel(
                        label: '阶段名称',
                        controller: stage.title,
                        limit: 40,
                      ),
                      FormFieldLabel(
                        label: '阶段完成标准',
                        controller: stage.criteria,
                        limit: 300,
                        lines: 2,
                      ),
                      TypeChoice(
                        rules: rules,
                        value: stage.type,
                        onChanged: (value) =>
                            setState(() => stage.type = value),
                      ),
                    ],
                  ),
                ),
              TextButton.icon(
                onPressed: () => setState(() => stages.add(_StageFields())),
                icon: const Icon(Icons.add_rounded),
                label: const Text('增加阶段'),
              ),
            ],
            const SizedBox(height: 14),
            Text(switch (mode) {
              'staged' => '${stages.length} 个阶段 · 逐阶段确认，共 $budget 分',
              'recurring' => '接下来 7 天的计划 · 最多 $budget 分',
              _ => '1 件小事 · 确认得 $budget 分',
            }),
            if (budget > 2 * rules.weeklyReference) ...[
              const SizedBox(height: 6),
              Text(
                '当前计划超过每周 ${rules.weeklyReference} 分定价参照的两倍。',
                style: const TextStyle(color: mutedInk),
              ),
            ],
            const SizedBox(height: 14),
            ActionButton(
              label: widget.backfill
                  ? '确认补录'
                  : editing
                  ? '保存新版本'
                  : '确认发布',
              action: save,
            ),
          ],
        ),
      ),
    ),
  );

  Widget repeatForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      DayChoice(
        label: '开始日期',
        day: start,
        today: today,
        future: true,
        onChanged: (day) => setState(() => start = day),
      ),
      const SizedBox(height: 8),
      DayChoice(
        label: '结束日期',
        day: end,
        today: today,
        future: true,
        onChanged: (day) => setState(() => end = day),
      ),
      const SizedBox(height: 12),
      const Text('计划星期'),
      Wrap(
        spacing: 6,
        children: [
          for (var i = 1; i <= 7; i++)
            FilterChip(
              label: Text('周${'一二三四五六日'[i - 1]}'),
              selected: weekdays.contains(i),
              onSelected: (on) => setState(() {
                if (on) {
                  weekdays.add(i);
                } else {
                  weekdays.remove(i);
                }
              }),
            ),
        ],
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<int>(
        initialValue: count,
        decoration: const InputDecoration(labelText: '每个计划日的次数'),
        items: [
          for (var i = 1; i <= rules.maxPerDay; i++)
            DropdownMenuItem(value: i, child: Text('$i 次')),
        ],
        onChanged: (value) => setState(() => count = value!),
      ),
    ],
  );
}

class ManageTasksPage extends StatefulWidget {
  const ManageTasksPage({super.key, required this.controller});
  final FamilyController controller;

  @override
  State<ManageTasksPage> createState() => _ManageTasksPageState();
}

class _ManageTasksPageState extends State<ManageTasksPage> {
  late Future<List<Json>> plans = service.recurringTemplates();
  FamilyService get service => widget.controller.service!;

  @override
  Widget build(BuildContext context) => ParentFrame(
    controller: widget.controller,
    title: '小事与计划',
    child: PageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('重复计划', style: Theme.of(context).textTheme.titleLarge),
          FutureBuilder(
            future: plans,
            builder: (context, snapshot) => Column(
              children: [
                if (snapshot.data?.isEmpty ?? false)
                  const ListTile(title: Text('当前没有重复计划。')),
                for (final row in snapshot.data ?? <Json>[])
                  ListTile(
                    title: Text(row['title'] as String),
                    subtitle: Text(row['paused'] == 1 ? '已暂停' : '生成中的计划'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await openPage(
                        context,
                        RepeatPlanPage(
                          controller: widget.controller,
                          plan: row,
                        ),
                      );
                      if (mounted) {
                        setState(() => plans = service.recurringTemplates());
                      }
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('小事实例', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) => Column(
              children: [
                for (final entry in widget.controller.tasks)
                  TaskTile(
                    task: entry,
                    onTap: () => openPage(
                      context,
                      ManageInstancePage(
                        controller: widget.controller,
                        task: entry,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class RepeatPlanPage extends StatelessWidget {
  const RepeatPlanPage({
    super.key,
    required this.controller,
    required this.plan,
  });
  final FamilyController controller;
  final Json plan;

  @override
  Widget build(BuildContext context) {
    final paused = plan['paused'] == 1;
    final schedule = repeatConfig(plan['schedule_json'] as String);
    return ParentFrame(
      controller: controller,
      title: '重复计划',
      child: PageBody(
        child: GardenCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                plan['title'] as String,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '${schedule.from} 至 ${schedule.until} · 每个计划日 ${schedule.count} 次',
              ),
              const SizedBox(height: 12),
              ActionButton(
                label: paused ? '恢复未来计划' : '暂停未来计划',
                action: () async {
                  await controller.service!.pauseRecurring(
                    plan['id'] as String,
                    !paused,
                    session: controller.session,
                  );
                  await controller.refresh();
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              OutlinedButton(
                onPressed: () async {
                  await openPage(
                    context,
                    PublishPage(
                      controller: controller,
                      template: plan,
                      schedule: schedule,
                    ),
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('编辑未来计划'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ManageInstancePage extends StatelessWidget {
  const ManageInstancePage({
    super.key,
    required this.controller,
    required this.task,
  });
  final FamilyController controller;
  final TaskEntry task;

  @override
  Widget build(BuildContext context) => ParentFrame(
    controller: controller,
    title: '处理小事',
    child: PageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TaskDetails(task: task),
          const SizedBox(height: 12),
          if (task.state == 'EXPIRED')
            ActionButton(
              label: '重开这件小事',
              action: () async {
                await controller.service!.reopen(
                  task.id,
                  null,
                  session: controller.session,
                );
                await controller.refresh();
                if (context.mounted) Navigator.pop(context);
              },
            ),
          if (['OPEN', 'RETURNED', 'EXPIRED', 'WAITING'].contains(task.state))
            ActionButton(
              label: '取消这件小事',
              outlined: true,
              action: () async {
                final confirmed = await confirmChoice(
                  context,
                  '取消这件小事？',
                  '历史记录会保留。',
                  '确认取消',
                );
                if (!confirmed) return;
                await controller.service!.cancel(
                  task.id,
                  session: controller.session,
                );
                await controller.refresh();
                if (context.mounted) Navigator.pop(context);
              },
            ),
          if (task.state == 'CORRECTED')
            OutlinedButton(
              onPressed: () => openPage(
                context,
                PublishPage(
                  controller: controller,
                  backfill: true,
                  correcting: task.id,
                ),
              ),
              child: const Text('补录并关联这件小事'),
            ),
        ],
      ),
    ),
  );
}
