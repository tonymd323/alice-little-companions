import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

import '../application/controller.dart';
import '../application/transfer.dart';
import '../domain/backup_codec.dart';
import '../domain/pin.dart';
import '../domain/rules.dart';
import 'common.dart';
import 'garden.dart';
import 'parent_access.dart';

class DataPage extends StatefulWidget {
  const DataPage({super.key, required this.controller});
  final FamilyController controller;

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  TransferService get transfer => widget.controller.transfer;
  late Future<(Json, List<File>)> states = load();

  Future<(Json, List<File>)> load() async =>
      (await transfer.status(), await transfer.checkpoints.files());

  Future<void> visit(Widget page) async {
    await openPage(context, page);
    if (mounted) setState(() => states = load());
  }

  @override
  Widget build(BuildContext context) => ParentFrame(
    controller: widget.controller,
    title: '备份与迁移',
    child: PageBody(
      child: FutureBuilder(
        future: states,
        builder: (context, state) {
          final data = state.data;
          if (data == null) {
            return state.hasError
                ? const GardenCard(child: Text('暂时无法读取设备备份状态。'))
                : const Center(child: CircularProgressIndicator());
          }
          final control = data.$1;
          final kind = control['state'];
          final frozen = kind != 'IDLE';
          final last = control['last_verified_at'] as String?;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GardenCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '外部加密备份',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      last == null
                          ? '还没有回读验证过外部备份。'
                          : '上次外部验证 ${localTime(last)}',
                    ),
                    if (control['last_external_status'] == 'unverified' ||
                        control['last_external_status'] == 'pending')
                      const Text('最近导出的文件等待回读验证。'),
                    if (kind == 'AWAITING_FILE_VERIFICATION')
                      const Text('迁移文件待验证。这台设备暂时只读。'),
                    if (kind == 'MIGRATION_PENDING')
                      const Text('迁移文件已验证。这台设备只读，可在新设备恢复。'),
                    if (kind == 'ARCHIVED') const Text('这台设备已归档，可查看原有成果。'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (!frozen)
                FilledButton.icon(
                  onPressed: () => visit(
                    ExportPage(controller: widget.controller, mode: 'backup'),
                  ),
                  icon: const Icon(Icons.file_upload_outlined),
                  label: const Text('导出备份'),
                ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => visit(
                  ExportPage(controller: widget.controller, mode: 'migration'),
                ),
                child: Text(frozen ? '再次保存同一迁移文件' : '迁移到新设备'),
              ),
              if (control['outgoing_id'] != null)
                OutlinedButton(
                  onPressed: () => visit(
                    RestorePage(
                      controller: widget.controller,
                      verifyOnly: true,
                    ),
                  ),
                  child: const Text('回读验证导出文件'),
                ),
              OutlinedButton(
                onPressed: () =>
                    visit(RestorePage(controller: widget.controller)),
                child: const Text('从外部备份恢复'),
              ),
              if (kind == 'MIGRATION_PENDING')
                ActionButton(
                  label: '归档旧设备',
                  outlined: true,
                  action: () => endMigration(archive: true),
                ),
              if (frozen)
                ActionButton(
                  label: '取消迁移并恢复写入',
                  outlined: true,
                  action: () => endMigration(archive: false),
                ),
              const SizedBox(height: 20),
              Text('内部恢复点', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('恢复点保存在这台设备内。请另行导出一份外部备份，以便换机或卸载后恢复。'),
              if (data.$2.isEmpty) const ListTile(title: Text('目前没有内部恢复点。')),
              for (final file in data.$2)
                ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(checkpointTime(file)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => visit(
                    RestorePage(
                      controller: widget.controller,
                      checkpoint: file,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    ),
  );

  Future<void> endMigration({required bool archive}) async {
    final ok = await confirmChoice(
      context,
      archive ? '归档这台旧设备？' : '在这台设备继续记账？',
      archive ? '请先确认新设备已恢复成功。旧设备将保留已有数据供查看。' : '请确认目标设备未继续使用这个迁移存档，之后在这台设备记账。',
      archive ? '确认归档' : '确认恢复写入',
    );
    if (!ok) return;
    await transfer.endMigration(
      archive: archive,
      session: widget.controller.session,
    );
    await widget.controller.refresh();
    if (mounted) setState(() => states = load());
  }
}

String localTime(String time) {
  final local = DateTime.parse(time).toLocal();
  return '${dateKey(local)} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}

String checkpointTime(File file) {
  final value = int.tryParse(p.basename(file.path).split('-').first);
  return value == null
      ? '设备恢复点'
      : localTime(
          DateTime.fromMicrosecondsSinceEpoch(
            value,
            isUtc: true,
          ).toIso8601String(),
        );
}

mixin _TransferFeedback<T extends StatefulWidget> on State<T> {
  TransferOperation? _operation;
  TransferPhase? _phase;
  bool _cancelling = false;

  bool get transferBusy => _operation != null;

  Future<R> runTransfer<R>(Future<R> Function(TransferOperation) action) async {
    final operation = TransferOperation((phase) {
      if (mounted) setState(() => _phase = phase);
    });
    setState(() => _operation = operation);
    try {
      return await action(operation);
    } finally {
      if (mounted) {
        setState(() {
          _operation = null;
          _phase = null;
          _cancelling = false;
        });
      }
    }
  }

  Widget transferAction(Widget action) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Offstage(offstage: transferBusy, child: action),
      if (transferBusy) _transferFeedback(),
    ],
  );

  Widget _transferFeedback() {
    final label = _cancelling
        ? '正在取消…'
        : switch (_phase) {
            null => '正在准备…',
            TransferPhase.snapshot => '正在整理当前存档…',
            TransferPhase.checking => '正在检查存档…',
            TransferPhase.encrypting => '正在加密存档…',
            TransferPhase.readback => '正在回读验证…',
            TransferPhase.decrypting => '正在读取并解密…',
          };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Semantics(liveRegion: true, child: Text(label))),
            TextButton(
              onPressed: _operation?.canCancel != true
                  ? null
                  : () {
                      final operation = _operation;
                      if (operation == null || !operation.canCancel) return;
                      operation.cancel();
                      setState(() => _cancelling = true);
                    },
              child: const Text('取消'),
            ),
          ],
        ),
        const LinearProgressIndicator(),
      ],
    );
  }

  @override
  void dispose() {
    _operation?.cancel();
    super.dispose();
  }
}

class ExportPage extends StatefulWidget {
  const ExportPage({super.key, required this.controller, required this.mode});
  final FamilyController controller;
  final String mode;

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage>
    with _TransferFeedback<ExportPage> {
  final password = TextEditingController();
  final repeated = TextEditingController();
  String? status;
  bool get migrating => widget.mode == 'migration';

  @override
  void dispose() {
    password.dispose();
    repeated.dispose();
    super.dispose();
  }

  Future<void> export() async {
    if (password.text != repeated.text) throw const UserError('两次输入的备份口令不一致。');
    BackupCodec.checkPassphrase(password.text);
    FocusScope.of(context).unfocus();
    setState(() => status = null);
    final controller = widget.controller;
    final transfer = controller.transfer;
    late final ExportTicket ticket;
    try {
      ticket = await runTransfer(
        (operation) => transfer.prepareExport(
          widget.mode,
          password.text,
          controller.session,
          operation: operation,
        ),
      );
    } on TransferCancelled {
      if (mounted) setState(() => status = '已取消备份生成。');
      return;
    }
    if (!mounted) {
      await transfer.finishExport(ticket, SaveOutcome.cancelled);
      return;
    }
    setState(() => status = '请选择 App 外的保存位置。');
    late final SaveOutcome outcome;
    try {
      outcome = await _saveExternal(ticket);
    } catch (_) {
      await transfer.finishExport(ticket, SaveOutcome.cancelled);
      rethrow;
    }
    await transfer.finishExport(ticket, outcome);
    if (!mounted) return;
    await controller.refresh();
    if (!mounted) return;
    if (outcome != SaveOutcome.cancelled) {
      password.clear();
      repeated.clear();
    }
    final message = switch (outcome) {
      SaveOutcome.cancelled => '已取消文件保存。',
      SaveOutcome.handedToSystem => '请确认文件已保存，再从数据页回读验证。',
      SaveOutcome.externallyVerified => '外部文件已保存并验证。',
    };
    setState(() => status = message);
    showNotice(context, message);
  }

  Future<SaveOutcome> _saveExternal(ExportTicket ticket) async {
    final bytes = await ticket.file.readAsBytes();
    if (!mounted) return SaveOutcome.cancelled;
    try {
      final location = await FilePicker.saveFile(
        fileName: ticket.name,
        bytes: bytes,
        mimeType: 'application/octet-stream',
      );
      if (location == null) return SaveOutcome.cancelled;
      if (location.scheme == 'file') {
        final external = File.fromUri(location);
        if (await external.exists() &&
            await fileHash(external) == await fileHash(ticket.file)) {
          return SaveOutcome.externallyVerified;
        }
      }
    } catch (_) {
      // A provider can stop responding after a write. Keep the receipt pending for readback.
    }
    return SaveOutcome.handedToSystem;
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.controller.family!;
    return ParentFrame(
      controller: widget.controller,
      title: migrating ? '迁移到新设备' : '导出备份',
      child: PageBody(
        maxWidth: 520,
        child: GardenCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '余额 ${summary.balance} 分 · ${summary.taskCount} 件小事',
              ),
              const SizedBox(height: 8),
              Text(
                migrating
                    ? '生成迁移文件后，这台设备将暂时只读。请在新设备恢复后继续使用。'
                    : '备份包含成果、积分流水、拥有的物品和家园布置。请把文件保存到 App 外。',
              ),
              const SizedBox(height: 14),
              FormFieldLabel(
                label: '备份口令（至少 10 个字符）',
                controller: password,
                secret: true,
              ),
              FormFieldLabel(
                label: '确认备份口令',
                controller: repeated,
                secret: true,
              ),
              transferAction(ActionButton(label: '生成并保存文件', action: export)),
              if (status != null) ...[const SizedBox(height: 8), Text(status!)],
            ],
          ),
        ),
      ),
    );
  }
}

class RestorePage extends StatefulWidget {
  const RestorePage({
    super.key,
    required this.controller,
    this.verifyOnly = false,
    this.checkpoint,
  });
  final FamilyController controller;
  final bool verifyOnly;
  final File? checkpoint;

  @override
  State<RestorePage> createState() => _RestorePageState();
}

class _RestorePageState extends State<RestorePage>
    with _TransferFeedback<RestorePage> {
  final password = TextEditingController();
  final pin = TextEditingController();
  final repeated = TextEditingController();
  PlatformFile? selected;
  RestorePreview? preview;
  RestoreProtection? protection;
  String? recovery;
  String? status;

  FamilyController get controller => widget.controller;
  TransferService get transfer => controller.transfer;

  @override
  void dispose() {
    unawaited(preview?.close());
    password.dispose();
    pin.dispose();
    repeated.dispose();
    super.dispose();
  }

  Future<void> choose() async {
    final result = await FilePicker.pickFile(dialogTitle: '选择 .alicebackup 文件');
    if (result == null) {
      if (mounted) showNotice(context, '已取消文件选择。');
      return;
    }
    if (result.path == null ||
        await File(result.path!).length() > BackupCodec.maxContainer) {
      throw const UserError('无法读取文件或文件超过支持大小。');
    }
    if (mounted) {
      setState(() {
        selected = result;
        status = null;
      });
    }
  }

  Future<void> inspect() async {
    FocusScope.of(context).unfocus();
    if (widget.checkpoint == null && selected == null) {
      throw const UserError('请先选择备份文件。');
    }
    setState(() => status = null);
    try {
      await inspectSelected();
    } on TransferCancelled {
      if (mounted) setState(() => status = '已取消文件检查。');
    }
  }

  Future<void> inspectSelected() async {
    if (widget.verifyOnly) {
      await runTransfer(
        (operation) => transfer.verifyExternal(
          File(selected!.path!),
          password.text,
          controller.session,
          operation: operation,
        ),
      );
      if (!mounted) return;
      password.clear();
      setState(() => status = '已验证外部文件。');
      return;
    }
    final data = await runTransfer(
      (operation) => widget.checkpoint == null
          ? transfer.inspect(
              File(selected!.path!),
              password.text,
              controller.session,
              operation: operation,
            )
          : transfer.inspectCheckpoint(
              widget.checkpoint!,
              controller.session,
              operation: operation,
            ),
    );
    if (!mounted) {
      await data.close();
      return;
    }
    password.clear();
    final control = await transfer.status();
    if (!mounted) {
      await data.close();
      return;
    }
    if (data.backupId != null &&
        control['last_import_id'] == data.backupId &&
        control['last_import_revision'] == controller.family?.revision) {
      await data.close();
      if (mounted) setState(() => status = '这份备份已经恢复。');
      return;
    }
    setState(() => preview = data);
  }

  Future<void> prepare() async {
    if (!PinGate.correctFormat(pin.text) || pin.text != repeated.text) {
      throw const UserError('请输入并确认 6 位数字新 PIN。');
    }
    FocusScope.of(context).unfocus();
    if (controller.family != null) {
      setState(() => status = null);
      try {
        protection = await runTransfer(
          (operation) =>
              transfer.protectCurrent(controller.session, operation: operation),
        );
      } on TransferCancelled {
        if (mounted) setState(() => status = '已取消建立恢复点。');
        return;
      }
      if (!mounted) return;
      final ok = await confirmChoice(
        context,
        '替换这台设备的小家？',
        '已建立内部恢复点。确认后将整体恢复到所选备份的时间点。',
        '确认替换',
      );
      if (!ok) return;
    }
    if (controller.needsRepair) {
      if (!mounted) return;
      final ok = await confirmChoice(
        context,
        '恢复小家存档？',
        '原存档文件会保留。激活后从选定的恢复点继续。',
        '确认恢复',
      );
      if (!ok) return;
    }
    if (mounted) setState(() => recovery = PinGate.newRecoveryCode());
  }

  Future<void> activateRestore() async {
    final result = await transfer.activate(
      preview!,
      pin.text,
      recovery!,
      session: controller.session,
      replace: controller.family != null || controller.needsRepair,
      protection: protection,
    );
    await controller.acceptActivation(result);
    if (!mounted) return;
    final message = result.alreadyRestored ? '这份备份已经恢复。' : '存档已恢复到这台设备。';
    Navigator.of(context).popUntil((route) => route.isFirst);
    showNotice(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.verifyOnly
        ? '回读验证'
        : widget.checkpoint != null
        ? '恢复设备内存档'
        : '从备份恢复';
    final body = PageBody(
      maxWidth: 650,
      child: recovery != null
          ? RecoveryCard(
              code: recovery!,
              label: '激活恢复后的存档',
              onReady: activateRestore,
            )
          : preview != null
          ? previewForm()
          : selectForm(),
    );
    return controller.family == null && !controller.needsRepair
        ? Scaffold(
            appBar: AppBar(title: Text(title)),
            body: body,
          )
        : ParentFrame(controller: controller, title: title, child: body);
  }

  Widget selectForm() => GardenCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.checkpoint == null) ...[
          OutlinedButton.icon(
            onPressed: transferBusy
                ? null
                : () async {
                    try {
                      await choose();
                    } on UserError catch (error) {
                      if (mounted) showNotice(context, error.message);
                    } catch (_) {
                      if (mounted) showNotice(context, '系统暂时无法读取文件。');
                    }
                  },
            label: const Text('选择备份文件'),
            icon: const Icon(Icons.folder_open_outlined),
          ),
          if (selected != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: Text(
                selected!.name,
                style: const TextStyle(color: mutedInk),
              ),
            ),
          FormFieldLabel(label: '原备份口令', controller: password, secret: true),
        ] else ...[
          Text(checkpointTime(widget.checkpoint!)),
          const SizedBox(height: 12),
        ],
        transferAction(
          ActionButton(
            label: widget.verifyOnly ? '验证文件' : '验证并预览',
            action: inspect,
          ),
        ),
        if (status != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(status!),
          ),
      ],
    ),
  );

  Widget previewForm() {
    final data = preview!;
    final summary = data.info.summary;
    final current = controller.family;
    final experience = summary['valid_completion_count'] as int;
    final originalStage = summary['max_growth_stage'] as int;
    final earned = controller.rules.earnedStage(experience);
    final restoredStage = earned > originalStage ? earned : originalStage;
    final time = data.manifest['created_at_utc'] as String?;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, box) {
            final incoming = GardenCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '待恢复的小家',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(data.info.nickname),
                  if (time != null) Text(localTime(time)),
                  Text(
                    '${summary['balance']} 分 · ${summary['valid_completion_count']} 份有效成果',
                  ),
                  Text(
                    '${summary['ledger_count']} 条流水 · ${summary['owned_item_count']} 件物品',
                  ),
                  Text(
                    '${summary['space_count']} 个空间 · $experience 经验 · 恢复后第 $restoredStage 阶段',
                  ),
                ],
              ),
            );
            if (current == null) return incoming;
            final existing = GardenCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('当前小家', style: Theme.of(context).textTheme.titleMedium),
                  Text(current.nickname),
                  Text(
                    '${current.balance} 分 · ${current.experience} 份有效成果',
                  ),
                  Text('${current.experience} 经验 · 伙伴阶段 ${current.stage}'),
                ],
              ),
            );
            return box.maxWidth >= 530
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: existing),
                      const SizedBox(width: 10),
                      Expanded(child: incoming),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [existing, const SizedBox(height: 10), incoming],
                  );
          },
        ),
        const SizedBox(height: 14),
        GardenCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('请为这台设备设置新家长 PIN。'),
              const SizedBox(height: 10),
              FormFieldLabel(
                label: '新家长 PIN（6 位数字）',
                controller: pin,
                limit: 6,
                secret: true,
                keyboard: TextInputType.number,
              ),
              FormFieldLabel(
                label: '确认新家长 PIN',
                controller: repeated,
                limit: 6,
                secret: true,
                keyboard: TextInputType.number,
              ),
              transferAction(
                ActionButton(
                  label: current == null ? '下一步' : '保护当前数据并确认',
                  action: prepare,
                ),
              ),
              if (status != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(status!),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class RepairHome extends StatelessWidget {
  const RepairHome({super.key, required this.controller});
  final FamilyController controller;

  @override
  Widget build(BuildContext context) => ParentFrame(
    controller: controller,
    title: '恢复小家',
    child: PageBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const GardenCard(child: Text('当前存档无法读取。原文件已保留，请选择可验证的恢复点。')),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () =>
                openPage(context, RestorePage(controller: controller)),
            child: const Text('从外部备份恢复'),
          ),
          FutureBuilder(
            future: controller.transfer.checkpoints.files(),
            builder: (context, result) => Column(
              children: [
                for (final file in result.data ?? <File>[])
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(checkpointTime(file)),
                    onTap: () => openPage(
                      context,
                      RestorePage(controller: controller, checkpoint: file),
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
