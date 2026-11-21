import 'package:material_ui/material_ui.dart';

import '../application/controller.dart';
import '../application/family.dart';
import '../domain/companion_bond.dart';
import '../domain/companions.dart';
import 'common.dart';
import 'garden.dart';

class AffinityCandyPage extends StatefulWidget {
  const AffinityCandyPage({super.key, required this.controller});

  final FamilyController controller;

  @override
  State<AffinityCandyPage> createState() => _AffinityCandyPageState();
}

class _AffinityCandyPageState extends State<AffinityCandyPage> {
  FamilyController get controller => widget.controller;
  late final FamilyService service = controller.service!;
  late var inventory = service.availableAffinityCandy();

  Future<void> reload() async {
    await controller.refresh();
    if (!mounted) return;
    final updated = service.availableAffinityCandy();
    setState(() {
      inventory = updated;
    });
  }

  Future<void> redeem() async {
    final confirmed = await confirmChoice(
      context,
      '兑换一颗亲密度糖果？',
      '花费 ${service.rules.affinityCandyPrice} 分，喂食后增加 ${service.rules.affinityPerCandy} 亲密度。',
      '确认兑换',
    );
    if (!confirmed || !mounted) return;
    await service.redeemAffinityCandy();
    await reload();
  }

  Future<void> feed(String id, int affinity, Companion pet) async {
    final confirmed = await confirmChoice(
      context,
      '喂给${pet.nickname}？',
      '用掉一颗糖果，增加 $affinity 亲密度。',
      '确认喂食',
    );
    if (!confirmed || !mounted) return;
    await service.feedAffinityCandy(id, pet);
    await reload();
    if (mounted) showNotice(context, '${pet.nickname}的亲密度 +$affinity');
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final family = controller.family!;
      final pet = family.companion;
      final price = service.rules.affinityCandyPrice;
      final shortfall = price - family.balance;
      return Scaffold(
        appBar: AppBar(
          title: const Text(affinityCandyName),
          actions: [
            Center(child: PointsPill(family.balance)),
            const SizedBox(width: 12),
          ],
        ),
        body: PageBody(
          maxWidth: 520,
          child: GardenCard(
            child: FutureBuilder(
              future: inventory,
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Text('暂时无法读取糖果。');
                final candy = snapshot.data;
                final ready = snapshot.connectionState == ConnectionState.done;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          pet.artwork(family.stage),
                          width: 82,
                          height: 82,
                          excludeFromSemantics: true,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pet.nickname,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(family.bond.summary),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (ready)
                      Text('糖果 ${candy?.count ?? 0} 颗')
                    else
                      const LinearProgressIndicator(),
                    const SizedBox(height: 8),
                    if (candy != null)
                      ActionButton(
                        label: '喂给${pet.nickname} · +${candy.affinity}',
                        enabled: ready && !service.frozen,
                        action: () => feed(candy.id, candy.affinity, pet),
                      ),
                    ActionButton(
                      label: shortfall > 0
                          ? '兑换还差 $shortfall 分'
                          : '用 $price 分兑换',
                      enabled: ready && !service.frozen && shortfall <= 0,
                      outlined: candy != null,
                      action: redeem,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );
}
