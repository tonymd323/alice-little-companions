import 'dart:ui';

import '../domain/companions.dart';
import 'tailoring.dart';

String actionArtwork(
  Companion pet,
  int stage,
  String? body, {
  bool facesLeft = false,
  bool paintedScarf = false,
}) {
  final original = pet.hasGroundSkill
      ? 'assets/art/${pet.name}-$stage-skill.webp'
      : 'assets/art/leap-${pet.name}-$stage.webp';
  if (fittedCoat(pet, stage, body) case final coat?) {
    return coat.on(original, facesLeft: facesLeft, paintedScarf: paintedScarf);
  }
  if (paintedScarf && body == null) return foxScarfArtwork(original);
  final garment = switch (body) {
    'item_single_coat' => '-coat',
    'item_single_apron' => '-apron',
    _ => '',
  };
  return original.replaceFirst('.webp', '$garment.webp');
}

// Anchors on the separate action paintings. Coordinates are relative to
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
    Companion.otter => const [
      (.629, .355, .763, .311),
      (.648, .357, .785, .321),
      (.643, .354, .774, .318),
      (.662, .352, .784, .309),
      (.667, .351, .787, .307),
      (.704, .353, .816, .309),
    ],
    Companion.hedgehog => const [
      (.777, .647, .889, .673),
      (.813, .646, .931, .672),
      (.818, .651, .936, .679),
      (.806, .662, .922, .688),
      (.820, .667, .921, .694),
      (.820, .681, .918, .705),
    ],
  }[stage - 1];
  return (Offset(row.$1, row.$2), Offset(row.$3, row.$4));
}

// The carrying and sniffing drawings turn the head independently of the
// sitting portrait. Neck seams are placed behind the leaf and below the chin.
AccessoryFit? groundActionFit(Companion pet, int stage) {
  final fits = switch (pet) {
    Companion.otter => const [
      (.624, .139, .474, .238, .596, .522, .34),
      (.644, .139, .495, .235, .612, .528, .34),
      (.638, .139, .492, .235, .609, .522, .34),
      (.651, .139, .516, .236, .629, .522, .32),
      (.656, .139, .526, .235, .631, .522, .31),
      (.694, .144, .581, .239, .660, .531, .30),
    ],
    Companion.hedgehog => const [
      (.773, .320, .662, .404, .659, .718, .27),
      (.798, .338, .693, .412, .689, .728, .27),
      (.799, .342, .699, .419, .692, .742, .27),
      (.790, .363, .685, .441, .681, .747, .26),
      (.795, .365, .701, .446, .702, .759, .25),
      (.795, .395, .704, .481, .709, .775, .25),
    ],
    _ => null,
  };
  if (fits == null) return null;
  final (x, y, earX, earY, neckX, neckY, width) = fits[stage - 1];
  return (
    crown: Offset(x, y),
    ear: Offset(earX, earY),
    neck: Offset(neckX, neckY),
    width: width,
  );
}
