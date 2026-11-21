import 'package:material_ui/material_ui.dart';

import '../domain/companion_bond.dart';
import 'garden.dart';

class CompanionProgressBars extends StatelessWidget {
  const CompanionProgressBars({
    super.key,
    required this.stage,
    required this.experience,
    required this.thresholds,
    required this.bond,
  });

  final int stage;
  final int experience;
  final List<int> thresholds;
  final CompanionBond bond;

  @override
  Widget build(BuildContext context) {
    final target = stage <= thresholds.length ? thresholds[stage - 1] : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProgressBar(
          label: target == null ? '经验 · 满级' : '经验',
          amount: experience,
          target: target,
          color: terracotta,
          track: wheat,
        ),
        const SizedBox(height: 8),
        AffinityProgressBar(bond),
      ],
    );
  }
}

class AffinityProgressBar extends StatelessWidget {
  const AffinityProgressBar(this.bond, {super.key});

  final CompanionBond bond;

  @override
  Widget build(BuildContext context) => _ProgressBar(
    label: '亲密度 · ${bond.label}',
    amount: bond.value,
    target: bond.next?.threshold,
    color: const Color(0xFF925567),
    track: const Color(0xFFF1DDE1),
  );
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.label,
    required this.amount,
    required this.target,
    required this.color,
    required this.track,
  });

  final String label;
  final int amount;
  final int? target;
  final Color color;
  final Color track;

  @override
  Widget build(BuildContext context) {
    final goal = target;
    final count = goal == null ? '$amount' : '$amount / $goal';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(count, style: const TextStyle(color: mutedInk)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: goal == null ? 1.0 : (amount / goal).clamp(0.0, 1.0),
          minHeight: 7,
          borderRadius: BorderRadius.circular(8),
          trackGap: 0,
          stopIndicatorRadius: 0,
          color: color,
          backgroundColor: track,
          semanticsLabel: '$label $count',
        ),
      ],
    );
  }
}
