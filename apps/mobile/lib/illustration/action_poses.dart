import 'dart:ui';

import '../domain/companions.dart';

String actionArtwork(Companion pet, int stage, String? body) {
  final garment = switch (body) {
    'item_single_coat' => '-coat',
    'item_single_apron' => '-apron',
    _ => '',
  };
  return 'assets/art/leap-${pet.name}-$stage$garment.webp';
}

// Anchors on the separate airborne silhouettes. Coordinates are relative to
// the cutout so the same face accessory follows the painted action pose.
(Offset, Offset) actionEyes(Companion pet, int stage) {
  final row = switch (pet) {
    Companion.fox => const [
      (.724, .420, .881, .354),
      (.730, .370, .858, .321),
      (.743, .315, .820, .287),
      (.804, .347, .862, .327),
      (.825, .369, .884, .346),
      (.793, .325, .853, .295),
    ],
    Companion.rabbit => const [
      (.674, .294, .842, .205),
      (.678, .231, .831, .173),
      (.691, .285, .842, .214),
      (.677, .428, .805, .396),
      (.689, .421, .793, .395),
      (.687, .361, .798, .339),
    ],
    Companion.cat => const [
      (.676, .350, .832, .285),
      (.719, .258, .827, .229),
      (.719, .258, .830, .23),
      (.751, .271, .840, .246),
      (.746, .289, .802, .265),
      (.791, .312, .850, .286),
    ],
  }[stage - 1];
  return (Offset(row.$1, row.$2), Offset(row.$3, row.$4));
}
