import 'package:material_ui/material_ui.dart';

import '../application/controller.dart';
import '../domain/companions.dart';
import '../domain/pin.dart';
import 'backup_pages.dart';
import 'common.dart';
import 'garden.dart';
import '../domain/garden_stories.dart';
import 'storybook.dart';

class FirstRunPage extends StatefulWidget {
  const FirstRunPage({super.key, required this.controller});
  final FamilyController controller;

  @override
  State<FirstRunPage> createState() => _FirstRunPageState();
}

class _FirstRunPageState extends State<FirstRunPage> {
  final name = TextEditingController();
  final pin = TextEditingController();
  final repeated = TextEditingController();
  Companion pet = Companion.fox;
  int step = 0;
  String? recovery;

  @override
  void dispose() {
    name.dispose();
    pin.dispose();
    repeated.dispose();
    super.dispose();
  }

  Future<void> prepare() async {
    if (name.text.trim().isEmpty) throw const UserError('请填写孩子称呼。');
    if (!PinGate.correctFormat(pin.text)) {
      throw const UserError('请输入 6 位数字 PIN。');
    }
    if (pin.text != repeated.text) throw const UserError('两次输入的 PIN 不一致。');
    FocusScope.of(context).unfocus();
    setState(() {
      recovery = PinGate.newRecoveryCode();
      step = 2;
    });
  }

  Widget welcome(BuildContext context) {
    final choice = Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '一起住进银杏家园',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontFamily: 'serif', fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            '${pet.nickname}说：“${companionStories[pet]!.greeting}”',
            style: const TextStyle(color: mutedInk),
          ),
          const SizedBox(height: 12),
          CompanionPicker(
            selected: pet,
            onSelected: (p) => setState(() => pet = p),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => setState(() => step = 1),
            child: const Text('和它一起长大'),
          ),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () =>
                    openPage(context, GardenStorybook(stage: 1, initial: pet)),
                child: const Text('认识伙伴'),
              ),
              TextButton(
                onPressed: () => openPage(
                  context,
                  AppearancePreview(initial: pet, initialStage: 1),
                ),
                child: const Text('外观预览'),
              ),
              TextButton(
                onPressed: () => openPage(
                  context,
                  RestorePage(controller: widget.controller),
                ),
                child: const Text('从备份恢复'),
              ),
            ],
          ),
        ],
      ),
    );
    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= 840;
        final scene = GardenScene(
          companion: pet,
          stage: 1,
          label: '初次见面',
          immersive: true,
          height: wide
              ? box.maxHeight
              : (box.maxHeight * .54).clamp(240.0, 600.0),
        );
        if (wide) {
          return Row(
            children: [
              Expanded(flex: 3, child: scene),
              Expanded(flex: 2, child: SingleChildScrollView(child: choice)),
            ],
          );
        }
        return ListView(children: [scene, choice]);
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: step > 0
          ? BackButton(onPressed: () => setState(() => step--))
          : null,
      title: step == 0
          ? const Row(
              children: [
                GinkgoSeal(),
                SizedBox(width: 9),
                Text(
                  '小小伙伴',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            )
          : const Text('小小伙伴'),
    ),
    body: step == 0
        ? welcome(context)
        : PageBody(
            maxWidth: 710,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (step == 1)
                  GardenCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '家长设置',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text('家长 PIN 用于发布小事和确认成果。'),
                        const SizedBox(height: 16),
                        FormFieldLabel(
                          label: '孩子称呼',
                          controller: name,
                          limit: 30,
                        ),
                        FormFieldLabel(
                          label: '家长 PIN（6 位数字）',
                          controller: pin,
                          secret: true,
                          limit: 6,
                          keyboard: TextInputType.number,
                        ),
                        FormFieldLabel(
                          label: '再次输入 PIN',
                          controller: repeated,
                          secret: true,
                          limit: 6,
                          keyboard: TextInputType.number,
                        ),
                        ActionButton(label: '下一步', action: prepare),
                      ],
                    ),
                  ),
                if (step == 2)
                  RecoveryCard(
                    code: recovery!,
                    onReady: () => widget.controller.create(
                      name.text,
                      pet,
                      pin.text,
                      recovery!,
                    ),
                  ),
              ],
            ),
          ),
  );
}
