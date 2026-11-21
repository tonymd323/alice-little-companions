import 'package:material_ui/material_ui.dart';

import '../application/controller.dart';
import '../application/family.dart';
import '../domain/companion_badge.dart';
import '../domain/companions.dart';
import '../illustration/achievement_medal.dart';
import 'common.dart';
import 'garden.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key, required this.controller});

  final FamilyController controller;

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  late final _progress = widget.controller.service!.companionProgress();
  late Companion _pet = widget.controller.family!.companion;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('成就')),
    body: FutureBuilder<Map<Companion, CompanionProgress>>(
      future: _progress,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('暂时无法读取成就。'));
        }
        final owned = snapshot.data;
        if (owned == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final progress = owned[_pet]!;
        final evolutions = CompanionBadge.evolutions;
        final affinities = CompanionBadge.affinities;
        final earned = evolutions
            .followedBy(affinities)
            .where((badge) => _earned(badge, progress))
            .length;
        final total = evolutions.length + affinities.length;
        return PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GardenCard(
                child: Row(
                  children: [
                    Image.asset(
                      _pet.artwork(progress.stage),
                      width: 66,
                      height: 66,
                      excludeFromSemantics: true,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: owned.length == 1
                          ? Text(
                              _pet.nickname,
                              style: Theme.of(context).textTheme.titleLarge,
                            )
                          : Wrap(
                              spacing: 6,
                              children: [
                                for (final pet in Companion.values)
                                  if (owned.containsKey(pet))
                                    ChoiceChip(
                                      label: Text(pet.nickname),
                                      selected: _pet == pet,
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() => _pet = pet);
                                        }
                                      },
                                    ),
                              ],
                            ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$earned / $total',
                      semanticsLabel: '已获得 $earned 枚徽章，共 $total 枚',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _BadgeGroup('进化', evolutions, progress),
              const SizedBox(height: 16),
              _BadgeGroup('亲密度', affinities, progress),
            ],
          ),
        );
      },
    ),
  );
}

bool _earned(CompanionBadge badge, CompanionProgress progress) =>
    badge.isEarned(stage: progress.stage, affinity: progress.bond.value);

class _BadgeGroup extends StatelessWidget {
  const _BadgeGroup(this.title, this.badges, this.progress);

  final String title;
  final List<CompanionBadge> badges;
  final CompanionProgress progress;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      LayoutBuilder(
        builder: (context, box) {
          const gap = 8.0;
          final minWidth = MediaQuery.textScalerOf(context).scale(16) * 6.4;
          final columns = ((box.maxWidth + gap) / (minWidth + gap))
              .floor()
              .clamp(1, badges.length);
          final width = (box.maxWidth - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final badge in badges)
                SizedBox(
                  width: width,
                  child: _BadgeTile(badge, earned: _earned(badge, progress)),
                ),
            ],
          );
        },
      ),
    ],
  );
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile(this.badge, {required this.earned});

  final CompanionBadge badge;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final evolution = badge.kind == BadgeKind.evolution;
    final requirement = evolution ? '${badge.target} 级' : '${badge.target} 点';
    final description = evolution ? requirement : '亲密度 $requirement';
    return Semantics(
      label: '${badge.name}，$description，${earned ? '已获得' : '未获得'}',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: earned ? cream : const Color(0xFFF7EDDF),
          border: Border.all(color: outline),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AchievementMedal(badge, earned: earned),
                  if (!earned)
                    const Positioned(
                      right: -3,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: cream,
                        child: Icon(
                          Icons.lock_outline_rounded,
                          size: 12,
                          color: mutedInk,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                badge.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: earned ? ink : mutedInk,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                requirement,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: mutedInk),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
