import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../application/controller.dart';
import '../application/family.dart';
import '../data/device.dart';
import '../domain/pin.dart';
import '../domain/rules.dart';
import 'common.dart';
import 'garden.dart';
import 'parent_access.dart';
import 'tasks.dart' show AllTaskEntries, DayChoice, TaskTileList;

class PenaltiesPage extends StatefulWidget {
  const PenaltiesPage({super.key, required this.controller});
  final FamilyController controller;

  @override
  State<PenaltiesPage> createState() => _PenaltiesPageState();
}

class _PenaltiesPageState extends State<PenaltiesPage> {
  late Future<(List<Json>, List<Json>, int)> snapshot = load();
  FamilyService get service => widget.controller.service!;

  Future<(List<Json>, List<Json>, int)> load() async => (
    await service.penaltyRules(),
    await service.penalties(),
    await service.penaltyUsed(service.today),
  );

  void reload() => setState(() => snapshot = load());

  @override
  Widget build(BuildContext context) => ParentFrame(
    controller: widget.controller,
    title: '扣分与撤销',
    child: FutureBuilder(
      future: snapshot,
      builder: (context, state) {
        final data = state.data;
        return PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: PointsPill(widget.controller.family!.balance),
              ),
              const SizedBox(height: 10),
              if (data == null)
                const Center(child: CircularProgressIndicator()),
              if (data != null) ...[
                Text(
                  '今天已扣 ${data.$3} / ${service.rules.penaltyCap} 分',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                const Text('实扣受余额与当日额度限制。撤销会返还实扣积分，保留当日已用额度。'),
                const SizedBox(height: 14),
                if (!service.frozen)
                  OutlinedButton(
                    onPressed: () async {
                      await openPage(
                        context,
                        PenaltyRulePage(controller: widget.controller),
                      );
                      if (mounted) reload();
                    },
                    child: const Text('添加扣分约定'),
                  ),
                const SizedBox(height: 12),
                Text('事先约定', style: Theme.of(context).textTheme.titleLarge),
                for (final rule in data.$1)
                  ListTile(
                    title: Text(rule['behavior'] as String),
                    subtitle: Text(
                      '${rule['condition_text']} · ${rule['points']} 分',
                    ),
                    trailing: service.frozen
                        ? null
                        : const Icon(Icons.chevron_right),
                    onTap: service.frozen
                        ? null
                        : () async {
                            await openPage(
                              context,
                              ApplyPenaltyPage(
                                controller: widget.controller,
                                rule: rule,
                                used: data.$3,
                              ),
                            );
                            if (mounted) reload();
                          },
                  ),
                if (data.$1.isEmpty)
                  const ListTile(title: Text('家长还没有添加扣分约定。')),
                const SizedBox(height: 14),
                Text('扣分记录', style: Theme.of(context).textTheme.titleLarge),
                for (final event in data.$2)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: GardenCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['behavior'] as String,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(event['fact'] as String),
                          Text(
                            '发生 ${event['actual_date']} · 入账 ${event['posted_day']}',
                          ),
                          Text(
                            '实扣 ${event['deducted']} 分${event['back_id'] == null ? '' : ' · 已撤销'}',
                          ),
                          if (event['back_id'] == null && !service.frozen)
                            ActionButton(
                              label: '撤销这次扣分',
                              outlined: true,
                              action: () async {
                                final ok = await confirmChoice(
                                  context,
                                  '撤销扣分？',
                                  '将返还 ${event['deducted']} 分。',
                                  '确认撤销',
                                );
                                if (!ok) return;
                                await service.reversePenalty(
                                  event['id'] as String,
                                  session: widget.controller.session,
                                );
                                await widget.controller.refresh();
                                if (mounted) reload();
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    ),
  );
}

class PenaltyRulePage extends StatefulWidget {
  const PenaltyRulePage({super.key, required this.controller});
  final FamilyController controller;

  @override
  State<PenaltyRulePage> createState() => _PenaltyRulePageState();
}

class _PenaltyRulePageState extends State<PenaltyRulePage> {
  final behavior = TextEditingController();
  final condition = TextEditingController();
  int amount = 1;

  @override
  void dispose() {
    behavior.dispose();
    condition.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ParentFrame(
    controller: widget.controller,
    title: '添加扣分约定',
    child: PageBody(
      child: GardenCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormFieldLabel(label: '具体行为', controller: behavior, limit: 80),
            FormFieldLabel(
              label: '触发条件',
              controller: condition,
              limit: 300,
              lines: 2,
            ),
            DropdownButtonFormField<int>(
              initialValue: amount,
              decoration: const InputDecoration(labelText: '约定分值'),
              items: [
                for (var i = 1; i <= 3; i++)
                  DropdownMenuItem(value: i, child: Text('$i 分')),
              ],
              onChanged: (value) => setState(() => amount = value!),
            ),
            const SizedBox(height: 14),
            ActionButton(
              label: '保存约定',
              action: () async {
                await widget.controller.service!.definePenalty(
                  behavior.text,
                  condition.text,
                  amount,
                  session: widget.controller.session,
                );
                await widget.controller.refresh();
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class ApplyPenaltyPage extends StatefulWidget {
  const ApplyPenaltyPage({
    super.key,
    required this.controller,
    required this.rule,
    required this.used,
  });
  final FamilyController controller;
  final Json rule;
  final int used;

  @override
  State<ApplyPenaltyPage> createState() => _ApplyPenaltyPageState();
}

class _ApplyPenaltyPageState extends State<ApplyPenaltyPage> {
  final fact = TextEditingController();
  final event = uuid.v4();
  late String actual = widget.controller.service!.today;

  @override
  void dispose() {
    fact.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final balance = widget.controller.family!.balance;
    final planned = widget.rule['points'] as int;
    final cap = widget.controller.rules.penaltyCap;
    final expected = min(planned, min(balance, cap - widget.used));
    return ParentFrame(
      controller: widget.controller,
      title: '记录扣分',
      child: PageBody(
        child: GardenCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.rule['behavior'] as String,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(widget.rule['condition_text'] as String),
              const SizedBox(height: 12),
              Text('约定 $planned 分 · 预计实扣 $expected 分 · 当前余额 $balance 分'),
              const SizedBox(height: 12),
              DayChoice(
                label: '实际发生日期',
                day: actual,
                today: widget.controller.service!.today,
                onChanged: (day) => setState(() => actual = day),
              ),
              const SizedBox(height: 12),
              FormFieldLabel(
                label: '事实说明',
                controller: fact,
                lines: 2,
                limit: 500,
              ),
              ActionButton(
                label: '确认扣分',
                action: () async {
                  final result = await widget.controller.service!.applyPenalty(
                    widget.rule['id'] as String,
                    event,
                    fact.text,
                    actual,
                    session: widget.controller.session,
                  );
                  await widget.controller.refresh();
                  if (context.mounted) {
                    Navigator.pop(context);
                    showNotice(context, '已记录，实扣 ${result['deducted']} 分。');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CorrectionsPage extends StatelessWidget {
  const CorrectionsPage({super.key, required this.controller});
  final FamilyController controller;

  @override
  Widget build(BuildContext context) => ParentFrame(
    controller: controller,
    title: '误奖更正',
    child: AllTaskEntries(
      controller: controller,
      builder: (context, tasks) => TaskTileList(
        entries: tasks.where((task) => task.state == 'APPROVED').toList(),
        onTap: controller.service!.frozen
            ? null
            : (context, task) => openPage(
                context,
                CorrectionPage(controller: controller, task: task),
              ),
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GardenCard(child: Text('选择要更正的成果，再核对可追回积分及拟保留的兑换。')),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ),
  );
}

class CorrectionPage extends StatefulWidget {
  const CorrectionPage({
    super.key,
    required this.controller,
    required this.task,
  });
  final FamilyController controller;
  final TaskEntry task;

  @override
  State<CorrectionPage> createState() => _CorrectionPageState();
}

class _CorrectionPageState extends State<CorrectionPage> {
  final reason = TextEditingController();
  final returns = <String>{};
  bool accepts = false;
  late Future<CorrectionQuote> quote = read();

  Future<CorrectionQuote> read() async =>
      widget.controller.service!.correctionQuote(
        widget.task.id,
        returns.toList(),
        widget.controller.session,
      );

  void reload() => setState(() {
    accepts = false;
    quote = read();
  });

  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ParentFrame(
    controller: widget.controller,
    title: '确认误奖更正',
    child: FutureBuilder(
      future: quote,
      builder: (context, state) {
        final item = state.data;
        return PageBody(
          child: GardenCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.task.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (state.connectionState == ConnectionState.waiting)
                  const LinearProgressIndicator()
                else if (item == null)
                  ActionButton(label: '重新预览', action: () async => reload())
                else ...[
                  const SizedBox(height: 10),
                  Text(
                    '原发 ${item.reward} 分 · 可追回 ${item.recoverable} 分 · 差额 ${item.shortfall} 分',
                  ),
                  const SizedBox(height: 12),
                  if (item.related.isEmpty)
                    const Text('这笔奖励后没有可退回的兑换。')
                  else
                    const Text('勾选需要退回的相关兑换，其他物品会保留。'),
                  for (final purchase in item.related)
                    CheckboxListTile(
                      value: returns.contains(purchase['id']),
                      title: Text(purchase['name'] as String),
                      subtitle: Text('原付 ${purchase['price_paid']} 分'),
                      onChanged: (selected) {
                        final id = purchase['id'] as String;
                        if (selected == true) {
                          returns.add(id);
                        } else {
                          returns.remove(id);
                        }
                        reload();
                      },
                    ),
                  if (item.shortfall > 0)
                    CheckboxListTile(
                      value: accepts,
                      onChanged: (value) =>
                          setState(() => accepts = value ?? false),
                      title: Text('我接受无法追回的 ${item.shortfall} 分'),
                    ),
                  const SizedBox(height: 12),
                  FormFieldLabel(
                    label: '更正说明',
                    controller: reason,
                    lines: 2,
                    limit: 500,
                  ),
                  ActionButton(
                    label: '执行更正',
                    enabled: accepts || item.shortfall == 0,
                    action: () async {
                      try {
                        await widget.controller.service!.correctAward(
                          item,
                          reason.text,
                          accepts,
                          session: widget.controller.session,
                        );
                      } on UserError {
                        if (mounted) reload();
                        rethrow;
                      }
                      await widget.controller.refresh();
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ),
  );
}
