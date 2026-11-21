const affinityCandyItemId = 'affinity_candy';
const affinityCandyName = '亲密度糖果';

enum CompanionMoment { touch, call }

class CompanionBond {
  const CompanionBond(this.value);

  static const _tiers = [
    (label: '初见', threshold: 0),
    (label: '熟悉', threshold: 1),
    (label: '默契', threshold: 2),
    (label: '相伴', threshold: 8),
    (label: '挚友', threshold: 20),
  ];

  final int value;

  String get label => _tiers.lastWhere((tier) => tier.threshold <= value).label;
  String get summary => '亲密度 $value · $label';

  ({String label, int threshold})? get next =>
      _tiers.where((tier) => tier.threshold > value).firstOrNull;
}
