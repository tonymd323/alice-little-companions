import 'dart:math' as math;
import 'dart:ui';

import '../domain/companions.dart';
import 'tailoring.dart';

enum TurnView {
  towards('towards'),
  nearFront('near-front'),
  front('front'),
  rearProfile('rear-profile'),
  shallowRear('shallow-rear'),
  openingRear('opening-rear'),
  away('away'),
  middleRear('middle-rear'),
  nearRear('near-rear'),
  rear('rear');

  const TurnView(this.filename);
  final String filename;

  bool get axial => this == front || this == rear;
  bool get behind => index >= rearProfile.index;

  static TurnView? at(double yaw, Companion pet) {
    final depth = math.asin(math.sin(yaw)) / (math.pi / 2);
    final angle = depth.abs();
    if (depth < 0) {
      final intermediate = switch (pet) {
        Companion.otter => switch (angle) {
          >= .08 && < .21 => rearProfile,
          >= .335 && < .50 => openingRear,
          >= .50 && < .64 => middleRear,
          _ => null,
        },
        Companion.hedgehog => switch (angle) {
          >= .075 && < .145 => rearProfile,
          >= .145 && < .265 => shallowRear,
          >= .265 && < .335 => openingRear,
          _ => null,
        },
        _ => null,
      };
      if (intermediate != null) return intermediate;
    }
    if (angle < .21) return null;
    if (depth > 0) {
      return angle < .54
          ? towards
          : angle < .85
          ? nearFront
          : front;
    }
    return angle < .50
        ? away
        : angle < .83
        ? nearRear
        : rear;
  }
}

String turnArtwork(Companion pet, int stage, TurnView view, String? garment) {
  final suffix = switch (garment) {
    'item_single_coat' => '-coat',
    'item_single_apron' => '-apron',
    _ => '',
  };
  return 'assets/${pet.name}_walk/$stage-${view.filename}$suffix.webp';
}

class TurnFit {
  const TurnFit(
    this.eyes,
    this.head,
    this.pads, {
    this.temples,
    this.farEar,
    this.earHidden = false,
    this.profileEye = false,
  });

  final (Offset, Offset) eyes;
  final AccessoryFit head;
  final List<Offset?> pads;
  final (Offset, Offset)? temples;
  final Offset? farEar;
  final bool earHidden;
  final bool profileEye;
}

// Normalized anchors are measured on the finished paintings. Hidden feet
// have no skin weight. The frontal and rear drawings have fixed handedness.
const _otter = {
  TurnView.towards: TurnFit(
    (Offset(.676, .254), Offset(.811, .221)),
    (
      crown: Offset(.675, .103),
      ear: Offset(.528, .185),
      neck: Offset(.657, .533),
      width: .371,
    ),
    [Offset(.430, .973), Offset(.643, .990), null, Offset(.795, .971)],
    farEar: Offset(.775, .151),
  ),
  TurnView.nearFront: TurnFit(
    (Offset(.557, .269), Offset(.701, .219)),
    (
      crown: Offset(.550, .108),
      ear: Offset(.395, .182),
      neck: Offset(.541, .535),
      width: .386,
    ),
    [Offset(.348, .973), Offset(.514, .991), null, Offset(.668, .974)],
    farEar: Offset(.683, .146),
  ),
  TurnView.front: TurnFit(
    (Offset(.439, .251), Offset(.593, .247)),
    (
      crown: Offset(.507, .108),
      ear: Offset(.354, .166),
      neck: Offset(.514, .529),
      width: .391,
    ),
    [
      Offset(.322, .960),
      Offset(.413, .987),
      Offset(.684, .958),
      Offset(.594, .987),
    ],
  ),
  TurnView.rearProfile: TurnFit(
    (Offset(.795, .248), Offset(.916, .240)),
    (
      crown: Offset(.677, .126),
      ear: Offset(.606, .249),
      neck: Offset(.701, .512),
      width: .368,
    ),
    [Offset(.440, .966), Offset(.677, .973), null, Offset(.789, .951)],
    profileEye: true,
  ),
  TurnView.openingRear: TurnFit(
    (Offset(.831, .314), Offset(.891, .315)),
    (
      crown: Offset(.636, .110),
      ear: Offset(.759, .148),
      neck: Offset(.651, .450),
      width: .367,
    ),
    [Offset(.577, .947), Offset(.741, .911), null, null],
    farEar: Offset(.505, .154),
  ),
  TurnView.away: TurnFit(
    (Offset(.894, .327), Offset(.905, .327)),
    (
      crown: Offset(.675, .096),
      ear: Offset(.813, .200),
      neck: Offset(.681, .445),
      width: .375,
    ),
    [Offset(.565, .977), Offset(.754, .955), null, null],
    farEar: Offset(.518, .190),
  ),
  TurnView.middleRear: TurnFit(
    (Offset(.869, .335), Offset(.919, .335)),
    (
      crown: Offset(.603, .090),
      ear: Offset(.700, .151),
      neck: Offset(.582, .419),
      width: .371,
    ),
    [Offset(.552, .928), Offset(.687, .897), null, null],
    farEar: Offset(.448, .146),
  ),
  TurnView.nearRear: TurnFit(
    (Offset(.807, .315), Offset(.820, .315)),
    (
      crown: Offset(.505, .099),
      ear: Offset(.660, .190),
      neck: Offset(.505, .462),
      width: .380,
    ),
    [Offset(.452, .968), Offset(.633, .945), null, null],
    farEar: Offset(.358, .197),
  ),
  TurnView.rear: TurnFit(
    (Offset(.851, .309), Offset(.904, .309)),
    (
      crown: Offset(.492, .094),
      ear: Offset(.662, .176),
      neck: Offset(.498, .461),
      width: .386,
    ),
    [Offset(.657, .944), null, Offset(.357, .945), null],
    temples: (Offset(.323, .230), Offset(.678, .227)),
  ),
};

const _hedgehog = {
  TurnView.towards: TurnFit(
    (Offset(.699, .529), Offset(.844, .486)),
    (
      crown: Offset(.651, .285),
      ear: Offset(.565, .410),
      neck: Offset(.649, .748),
      width: .301,
    ),
    [
      Offset(.284, .972),
      Offset(.553, .989),
      Offset(.419, .948),
      Offset(.721, .973),
    ],
    farEar: Offset(.842, .350),
  ),
  TurnView.nearFront: TurnFit(
    (Offset(.610, .500), Offset(.761, .476)),
    (
      crown: Offset(.584, .275),
      ear: Offset(.490, .393),
      neck: Offset(.572, .723),
      width: .326,
    ),
    [Offset(.348, .973), Offset(.514, .991), null, Offset(.667, .978)],
    farEar: Offset(.786, .320),
  ),
  TurnView.front: TurnFit(
    (Offset(.424, .543), Offset(.602, .542)),
    (
      crown: Offset(.513, .287),
      ear: Offset(.358, .409),
      neck: Offset(.511, .747),
      width: .344,
    ),
    [null, Offset(.397, .989), null, Offset(.605, .987)],
  ),
  TurnView.rearProfile: TurnFit(
    (Offset(.785, .477), Offset(.909, .481)),
    (
      crown: Offset(.741, .277),
      ear: Offset(.652, .383),
      neck: Offset(.702, .721),
      width: .303,
    ),
    [
      Offset(.308, .972),
      Offset(.568, .987),
      Offset(.432, .950),
      Offset(.698, .981),
    ],
    farEar: Offset(.821, .311),
    profileEye: true,
  ),
  TurnView.shallowRear: TurnFit(
    (Offset(.754, .522), Offset(.897, .494)),
    (
      crown: Offset(.711, .293),
      ear: Offset(.604, .411),
      neck: Offset(.667, .733),
      width: .294,
    ),
    [
      Offset(.306, .970),
      Offset(.557, .987),
      Offset(.420, .951),
      Offset(.697, .976),
    ],
    farEar: Offset(.824, .335),
    profileEye: true,
  ),
  TurnView.openingRear: TurnFit(
    (Offset(.806, .441), Offset(.870, .455)),
    (
      crown: Offset(.745, .255),
      ear: Offset(.728, .361),
      neck: Offset(.703, .679),
      width: .284,
    ),
    [Offset(.509, .980), Offset(.674, .967), Offset(.350, .966), null],
    profileEye: true,
  ),
  TurnView.away: TurnFit(
    (Offset(.877, .531), Offset(.890, .531)),
    (
      crown: Offset(.728, .279),
      ear: Offset(.808, .349),
      neck: Offset(.744, .707),
      width: .293,
    ),
    [Offset(.495, .986), Offset(.681, .972), Offset(.320, .967), null],
  ),
  TurnView.nearRear: TurnFit(
    (Offset(.857, .489), Offset(.866, .489)),
    (
      crown: Offset(.691, .267),
      ear: Offset(.783, .327),
      neck: Offset(.706, .706),
      width: .294,
    ),
    [Offset(.491, .989), Offset(.646, .972), Offset(.346, .974), null],
  ),
  TurnView.rear: TurnFit(
    (Offset(.639, .547), Offset(.660, .547)),
    (
      crown: Offset(.502, .269),
      ear: Offset(.355, .374),
      neck: Offset(.500, .714),
      width: .307,
    ),
    [Offset(.630, .989), null, Offset(.364, .987), null],
    earHidden: true,
  ),
};

Map<TurnView, TurnFit> turnFits(Companion pet, int stage) =>
    switch ((pet, stage)) {
      (Companion.otter, 6) => _otter,
      (Companion.hedgehog, 6) => _hedgehog,
      _ => const {},
    };
