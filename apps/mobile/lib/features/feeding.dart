import 'package:material_ui/material_ui.dart';

import '../application/controller.dart';
import '../application/family.dart';
import '../domain/companion_badge.dart';
import '../domain/companion_food.dart';
import '../domain/companions.dart';
import 'common.dart';
import 'food_card.dart';
import 'garden.dart';
import 'growth_bars.dart';
import 'rewards.dart';

class FeedingPage extends StatefulWidget {
  const FeedingPage({super.key, required this.controller});

  final FamilyController controller;

  @override
  State<FeedingPage> createState() => _FeedingPageState();
}

class _FeedingPageState extends State<FeedingPage> {
  FamilyController get controller => widget.controller;
  late final FamilyService service = controller.service!;
  late var inventory = service.availableFood();

  void reload() {
    if (!mounted) return;
    final updated = service.availableFood();
    setState(() {
      inventory = updated;
    });
  }

  Future<void> shop() async {
    await openPage(
      context,
      CatalogPage(controller: controller, section: CatalogSection.food),
    );
    reload();
  }

  Future<void> feed(CompanionFood food, FoodStock stock, Companion pet) async {
    final confirmed = await confirmChoice(
      context,
      '喂给${pet.nickname}一份${food.label}？',
      '亲密度 +${stock.affinity}',
      '确认喂食',
    );
    if (!confirmed || !mounted) return;
    final result = await service.feedFood(stock.id, pet);
    await controller.refresh();
    reload();
    if (!mounted) return;
    final before = result['previous_affinity'] as int?;
    final gained = result['affinity'] as int;
    final badges = before == null
        ? ''
        : CompanionBadge.affinityReached(
            before,
            before + gained,
          ).map((badge) => '「${badge.name}」').join('、');
    showNotice(
      context,
      '${pet.nickname}的亲密度 +$gained${badges.isEmpty ? '' : ' · 获得$badges徽章'}',
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final family = controller.family!;
      final pet = family.companion;
      return Scaffold(
        appBar: AppBar(
          title: const Text('喂食'),
          actions: [
            Center(child: PointsPill(family.balance)),
            const SizedBox(width: 12),
          ],
        ),
        body: PageBody(
          maxWidth: 520,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GardenCard(
                child: Row(
                  children: [
                    Image.asset(
                      pet.artwork(family.stage),
                      width: 82,
                      height: 82,
                      filterQuality: FilterQuality.medium,
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
                          const SizedBox(height: 6),
                          AffinityProgressBar(family.bond),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              FutureBuilder(
                future: inventory,
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Text('暂时无法读取食物。');
                  final stock = snapshot.data;
                  if (stock == null) return const LinearProgressIndicator();
                  if (stock.isEmpty) {
                    return const GardenCard(child: Text('还没有食物。'));
                  }
                  return Column(
                    children: [
                      for (final food in CompanionFood.values)
                        if (stock[food] case final serving?)
                          Padding(
                            key: ValueKey(food),
                            padding: const EdgeInsets.only(bottom: 8),
                            child: FoodCard(
                              food: food,
                              count: serving.count,
                              affinity: serving.affinity,
                              action: ActionButton(
                                label: '喂${food.label}',
                                enabled:
                                    !service.frozen &&
                                    snapshot.connectionState ==
                                        ConnectionState.done,
                                action: () => feed(food, serving, pet),
                              ),
                            ),
                          ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton(onPressed: shop, child: const Text('去兑换食物')),
            ],
          ),
        ),
      );
    },
  );
}
