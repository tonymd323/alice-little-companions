enum CompanionMoment { touch, call }

class CompanionBond {
  const CompanionBond(this.value);

  static const tiers = [
    (label: '初见', threshold: 0),
    (label: '熟悉', threshold: 1),
    (label: '默契', threshold: 2),
    (label: '相伴', threshold: 8),
    (label: '挚友', threshold: 20),
  ];

  final int value;

  String get label => tiers.lastWhere((tier) => tier.threshold <= value).label;

  ({String label, int threshold})? get next =>
      tiers.where((tier) => tier.threshold > value).firstOrNull;
}
