import 'package:material_ui/material_ui.dart';

import '../domain/pin.dart';
import 'garden.dart';

class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.child, this.maxWidth = 720});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    ),
  );
}

class ActionButton extends StatefulWidget {
  const ActionButton({
    super.key,
    required this.label,
    required this.action,
    this.icon,
    this.enabled = true,
    this.outlined = false,
  });

  final String label;
  final Future<void> Function() action;
  final IconData? icon;
  final bool enabled;
  final bool outlined;

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool busy = false;

  Future<void> run() async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await widget.action();
    } on UserError catch (error) {
      if (mounted) showNotice(context, error.message);
    } catch (_) {
      if (mounted) showNotice(context, '操作未完成，请重试。');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final VoidCallback? press = busy || !widget.enabled ? null : run;
    final label = Text(
      busy ? '请稍候…' : widget.label,
      textAlign: TextAlign.center,
    );
    final icon = widget.icon;
    if (widget.outlined) return OutlinedButton(onPressed: press, child: label);
    return icon == null
        ? FilledButton(onPressed: press, child: label)
        : FilledButton.icon(onPressed: press, icon: Icon(icon), label: label);
  }
}

void showNotice(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

Future<T?> openPage<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute<T>(builder: (_) => page));

class FormFieldLabel extends StatelessWidget {
  const FormFieldLabel({
    super.key,
    required this.label,
    required this.controller,
    this.limit,
    this.lines = 1,
    this.secret = false,
    this.keyboard,
  });

  final String label;
  final TextEditingController controller;
  final int? limit;
  final int lines;
  final bool secret;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextField(
      controller: controller,
      obscureText: secret,
      enableSuggestions: !secret,
      autocorrect: !secret,
      maxLines: lines,
      maxLength: limit,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: lines > 1,
      ),
    ),
  );
}

class PointsPill extends StatelessWidget {
  const PointsPill(this.points, {super.key});
  final int points;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xFFF3E6BA),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.energy_savings_leaf_outlined, size: 18, color: ink),
          const SizedBox(width: 5),
          Text(
            '$points 分',
            style: const TextStyle(color: ink, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    ),
  );
}

class RecoveryCard extends StatefulWidget {
  const RecoveryCard({
    super.key,
    required this.code,
    required this.onReady,
    this.label = '进入小家',
  });
  final String code;
  final String label;
  final Future<void> Function() onReady;

  @override
  State<RecoveryCard> createState() => _RecoveryCardState();
}

class _RecoveryCardState extends State<RecoveryCard> {
  bool saved = false;

  @override
  Widget build(BuildContext context) => GardenCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('保存恢复密钥', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text('忘记家长 PIN 时可用它重设。请抄下并单独保管。'),
        const SizedBox(height: 16),
        SelectableText(
          widget.code,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: saved,
          onChanged: (value) => setState(() => saved = value ?? false),
          title: const Text('我已妥善保存'),
        ),
        ActionButton(
          label: widget.label,
          action: widget.onReady,
          enabled: saved,
        ),
      ],
    ),
  );
}

Future<bool> confirmChoice(
  BuildContext context,
  String title,
  String description,
  String action,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('返回'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;
