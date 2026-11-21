import 'companion_bond.dart';
import 'companions.dart';

enum BadgeKind { evolution, affinity }

class CompanionBadge {
  const CompanionBadge._(this.kind, this.target, this.name);

  static final evolutions = List<CompanionBadge>.unmodifiable([
    for (var stage = 2; stage <= stageNames.length; stage++)
      CompanionBadge._(BadgeKind.evolution, stage, stageNames[stage - 1]),
  ]);

  static final affinities = List<CompanionBadge>.unmodifiable([
    for (final tier in CompanionBond.tiers.skip(1))
      CompanionBadge._(BadgeKind.affinity, tier.threshold, tier.label),
  ]);

  final BadgeKind kind;
  final int target;
  final String name;

  bool isEarned({required int stage, required int affinity}) => switch (kind) {
    BadgeKind.evolution => stage >= target,
    BadgeKind.affinity => affinity >= target,
  };

  static Iterable<CompanionBadge> affinityReached(int before, int after) =>
      affinities.where(
        (badge) => before < badge.target && badge.target <= after,
      );
}
