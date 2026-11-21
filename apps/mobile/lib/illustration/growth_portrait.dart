import 'package:flutter/widgets.dart';

import '../domain/companions.dart';

String growthArtwork(Companion pet, int stage, {bool reveal = false}) {
  if (pet == Companion.otter || pet == Companion.hedgehog) {
    return pet.artwork(stage, reveal: reveal);
  }
  final pose = pet == Companion.cat && stage == 4 && !reveal ? '-rest' : '';
  return 'assets/art/growth-${pet.name}-$stage$pose.webp';
}

class GrowthPortrait extends StatelessWidget {
  const GrowthPortrait({
    super.key,
    required this.pet,
    required this.stage,
    this.reveal = false,
  });

  final Companion pet;
  final int stage;
  final bool reveal;

  @override
  Widget build(BuildContext context) => Image.asset(
    growthArtwork(pet, stage, reveal: reveal),
    fit: BoxFit.contain,
    alignment: Alignment.bottomCenter,
    excludeFromSemantics: true,
  );
}
