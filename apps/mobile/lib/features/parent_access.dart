import 'package:material_ui/material_ui.dart';

import '../application/controller.dart';
import '../domain/pin.dart';
import 'common.dart';
import 'garden.dart';

class ParentFrame extends StatelessWidget {
  const ParentFrame({
    super.key,
    required this.controller,
    required this.title,
    required this.child,
    this.home = false,
  });

  final FamilyController controller;
  final String title;
  final Widget child;
  final bool home;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final allowed = controller.parentUnlocked;
      return Scaffold(
        appBar: AppBar(
          title: Text(allowed ? title : '家长解锁'),
          actions: home && allowed
              ? [
                  TextButton(
                    onPressed: () {
                      controller.lock();
                      Navigator.of(context).pop();
                    },
                    child: const Text('返回儿童模式'),
                  ),
                ]
              : null,
        ),
        body: Stack(
          children: [
            Visibility(visible: allowed, maintainState: true, child: child),
            if (!allowed) ParentUnlock(controller: controller),
          ],
        ),
      );
    },
  );
}

class ParentUnlock extends StatefulWidget {
  const ParentUnlock({super.key, required this.controller});
  final FamilyController controller;

  @override
  State<ParentUnlock> createState() => _ParentUnlockState();
}

class _ParentUnlockState extends State<ParentUnlock> {
  final pin = TextEditingController();

  @override
  void dispose() {
    pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageBody(
    maxWidth: 440,
    child: GardenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.lock_outline_rounded,
              size: 30,
              color: terracotta,
            ),
          ),
          const SizedBox(height: 12),
          Text('请家长输入 PIN', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          FormFieldLabel(
            label: '家长 PIN',
            controller: pin,
            secret: true,
            limit: 6,
            keyboard: TextInputType.number,
          ),
          ActionButton(
            label: '解锁',
            action: () async {
              FocusScope.of(context).unfocus();
              await widget.controller.unlock(pin.text);
            },
          ),
          TextButton(
            onPressed: () =>
                openPage(context, ResetPinPage(controller: widget.controller)),
            child: const Text('用恢复密钥重设'),
          ),
        ],
      ),
    ),
  );
}

class ResetPinPage extends StatefulWidget {
  const ResetPinPage({super.key, required this.controller});
  final FamilyController controller;

  @override
  State<ResetPinPage> createState() => _ResetPinPageState();
}

class _ResetPinPageState extends State<ResetPinPage> {
  final old = TextEditingController();
  final pin = TextEditingController();
  final repeat = TextEditingController();
  String? recovery;

  @override
  void dispose() {
    old.dispose();
    pin.dispose();
    repeat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('重设家长 PIN')),
    body: PageBody(
      maxWidth: 480,
      child: recovery != null
          ? RecoveryCard(
              code: recovery!,
              label: '重设 PIN',
              onReady: () async {
                await widget.controller.parentGate!.reset(
                  old.text,
                  pin.text,
                  recovery!,
                );
                if (context.mounted) {
                  showNotice(context, '已重设家长 PIN。');
                  Navigator.pop(context);
                }
              },
            )
          : GardenCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FormFieldLabel(label: '原恢复密钥', controller: old, secret: true),
                  FormFieldLabel(
                    label: '新 PIN（6 位数字）',
                    controller: pin,
                    secret: true,
                    limit: 6,
                    keyboard: TextInputType.number,
                  ),
                  FormFieldLabel(
                    label: '再次输入新 PIN',
                    controller: repeat,
                    secret: true,
                    limit: 6,
                    keyboard: TextInputType.number,
                  ),
                  ActionButton(
                    label: '生成新恢复密钥',
                    action: () async {
                      if (old.text.isEmpty ||
                          !PinGate.correctFormat(pin.text) ||
                          pin.text != repeat.text) {
                        throw const UserError('请检查恢复密钥和两次新 PIN。');
                      }
                      setState(() => recovery = PinGate.newRecoveryCode());
                    },
                  ),
                ],
              ),
            ),
    ),
  );
}
