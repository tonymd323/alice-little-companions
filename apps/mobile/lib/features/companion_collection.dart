import 'package:material_ui/material_ui.dart';

import '../application/controller.dart';
import '../application/family.dart';
import '../domain/companions.dart';
import 'common.dart';
import 'garden.dart';

class CompanionCollection extends StatefulWidget {
  const CompanionCollection({super.key, required this.controller});
  final FamilyController controller;

  @override
  State<CompanionCollection> createState() => _CompanionCollectionState();
}

class _CompanionCollectionState extends State<CompanionCollection> {
  FamilyService get service => widget.controller.service!;
  FamilyOverview get family => widget.controller.family!;
  late var progress = service.companionProgress();

  Future<void> unlock(Companion pet) async {
    final price = service.rules.companionUnlockPrice;
    final confirmed = await confirmChoice(
      context,
      '邀请${pet.nickname}入住？',
      '花费 $price 分永久解锁。${pet.nickname}会从 1 级、0 经验开始成长。',
      '确认解锁',
    );
    if (!confirmed || !mounted) return;
    await service.unlockCompanion(pet);
    await widget.controller.refresh();
    if (!mounted) return;
    final updated = service.companionProgress();
    setState(() {
      progress = updated;
    });
  }

  Future<void> select(Companion pet) async {
    await service.selectCompanion(pet);
    await widget.controller.refresh();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('伙伴'),
      actions: [
        Center(child: PointsPill(family.balance)),
        const SizedBox(width: 12),
      ],
    ),
    body: PageBody(
      maxWidth: 520,
      child: FutureBuilder(
        future: progress,
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Text('暂时无法读取伙伴。');
          final owned = snapshot.data;
          if (owned == null) return const LinearProgressIndicator();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final pet in Companion.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _card(pet, owned[pet]),
                ),
            ],
          );
        },
      ),
    ),
  );

  Widget _card(Companion pet, CompanionProgress? state) {
    final current = pet == family.companion;
    final price = service.rules.companionUnlockPrice;
    final shortfall = price - family.balance;
    return GardenCard(
      child: Row(
        children: [
          Image.asset(
            pet.artwork(state?.stage ?? 1),
            height: 80,
            width: 80,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.nickname,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (state != null)
                  Text('${state.stage} 级 · ${state.experience} 经验'),
                if (current)
                  const Text('正在陪伴', style: TextStyle(color: mutedInk))
                else if (state != null)
                  ActionButton(label: '带回小家', action: () => select(pet))
                else
                  ActionButton(
                    label: shortfall > 0 ? '解锁还差 $shortfall 分' : '用 $price 分解锁',
                    outlined: true,
                    enabled: shortfall <= 0,
                    action: () => unlock(pet),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
