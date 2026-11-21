import 'package:material_ui/material_ui.dart';

import '../domain/companion_badge.dart';

class AchievementMedal extends StatelessWidget {
  const AchievementMedal(
    this.badge, {
    super.key,
    this.earned = true,
    this.size = 58,
  });

  final CompanionBadge badge;
  final bool earned;
  final double size;

  IconData get _symbol => switch (badge.kind) {
    BadgeKind.evolution => switch (badge.target) {
      2 => Icons.eco_rounded,
      3 => Icons.local_florist_rounded,
      4 => Icons.wb_sunny_rounded,
      5 => Icons.auto_awesome_rounded,
      _ => Icons.star_rounded,
    },
    BadgeKind.affinity => switch (badge.target) {
      1 => Icons.favorite_border_rounded,
      2 => Icons.favorite_rounded,
      8 => Icons.volunteer_activism_rounded,
      _ => Icons.diversity_1_rounded,
    },
  };

  @override
  Widget build(BuildContext context) {
    final rose = badge.kind == BadgeKind.affinity;
    final rim = earned ? const Color(0xFFC4823E) : const Color(0xFFCFBFA6);
    final sheen = earned ? const Color(0xFFFFFFDC) : const Color(0xFFF9F3E8);
    final enamel = !earned
        ? const Color(0xFFE4D8C8)
        : rose
        ? const Color(0xFFF0B5AF)
        : const Color(0xFFF3CA79);
    final symbol = !earned
        ? const Color(0xFF807160)
        : rose
        ? const Color(0xFF8D3948)
        : const Color(0xFF78451E);
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: rim, width: 2),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [sheen, enamel],
          ),
          boxShadow: earned
              ? const [
                  BoxShadow(
                    color: Color(0x2A97501E),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(size * .105),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: sheen),
            ),
            child: Center(
              child: Icon(_symbol, size: size * .48, color: symbol),
            ),
          ),
        ),
      ),
    );
  }
}
