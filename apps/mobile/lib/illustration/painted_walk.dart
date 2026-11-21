import 'dart:ui';

import '../domain/companions.dart';
import 'companion_walk.dart';

class PaintedLeg {
  const PaintedLeg(this.shoulder, this.pad, {this.visible = true});

  final Offset shoulder, pad;
  final bool visible;
}

/// Registers the paws to each original resting painting, including its coat
/// and apron editions. The cutouts share the same canvas within each form.
class PaintedWalk {
  PaintedWalk._(
    this.facesLeft,
    this.legs,
    double aspect,
    bool fox, {
    double? sideStride,
    double? depthStride,
    double? speed,
  }) : rig = WalkRig.painted(
         [
           for (final leg in legs)
             walkOrigin +
                 Offset(
                       (leg.pad.dx - .5) * aspect * (facesLeft ? -1 : 1),
                       leg.pad.dy - 1,
                     ) *
                     walkOrigin.dy,
         ],
         sideStride: sideStride ?? (fox ? 81 : 83),
         depthStride: depthStride ?? (fox ? 63 : 65),
         speed: speed ?? (fox ? 224 : 205),
       );

  final bool facesLeft;
  final List<PaintedLeg> legs;
  final WalkRig rig;

  static PaintedWalk? forPose(Companion pet, int stage) =>
      _forms[pet]?[stage] ?? _grownGroundForms[pet]?[stage];

  // The low body on later growth paintings keeps the same set of support
  // points. Tail lobes and spines stay in the full painted silhouette.
  static const _groundPads = {
    Companion.otter: [
      [
        Offset(.316, .974),
        Offset(.629, .987),
        Offset(.409, .950),
        Offset(.791, .973),
      ],
      [
        Offset(.323, .974),
        Offset(.629, .989),
        Offset(.415, .950),
        Offset(.804, .975),
      ],
      [
        Offset(.377, .974),
        Offset(.663, .989),
        Offset(.477, .951),
        Offset(.815, .975),
      ],
      [
        Offset(.397, .975),
        Offset(.687, .989),
        Offset(.493, .950),
        Offset(.827, .974),
      ],
      [
        Offset(.429, .975),
        Offset(.687, .989),
        Offset(.505, .950),
        Offset(.837, .976),
      ],
    ],
    Companion.hedgehog: [
      [
        Offset(.155, .978),
        Offset(.565, .988),
        Offset(.318, .958),
        Offset(.793, .977),
      ],
      [
        Offset(.154, .976),
        Offset(.559, .989),
        Offset(.316, .959),
        Offset(.793, .978),
      ],
      [
        Offset(.160, .979),
        Offset(.569, .989),
        Offset(.328, .957),
        Offset(.804, .978),
      ],
      [
        Offset(.167, .975),
        Offset(.579, .986),
        Offset(.335, .955),
        Offset(.814, .977),
      ],
      [
        Offset(.180, .978),
        Offset(.590, .989),
        Offset(.347, .956),
        Offset(.829, .977),
      ],
    ],
  };
  static final _grownGroundForms = {
    for (final entry in _groundPads.entries)
      entry.key: {
        for (final (index, paws) in entry.value.indexed)
          index + 2: PaintedWalk._(
            false,
            [
              for (final (leg, pad) in paws.indexed)
                PaintedLeg(
                  Offset(pad.dx - .035, .73),
                  pad,
                  visible:
                      entry.key != Companion.otter ||
                      leg != WalkLeg.farHind.index,
                ),
            ],
            entry.key.aspect(index + 2),
            false,
            sideStride: entry.key == Companion.otter ? 78 : 64,
            depthStride: entry.key == Companion.otter ? 62 : 49,
            speed: entry.key == Companion.otter ? 181 : 154,
          ),
      },
  };

  static final _forms = {
    Companion.cat: {
      2: PaintedWalk._(
        false,
        const [
          PaintedLeg(Offset(.35, .67), Offset(.195, .959)),
          PaintedLeg(Offset(.641, .679), Offset(.661, .992)),
          PaintedLeg(Offset(.407, .72), Offset(.480, .948)),
          PaintedLeg(Offset(.693, .674), Offset(.667, .903), visible: false),
        ],
        442 / 443,
        false,
      ),
      3: PaintedWalk._(
        false,
        const [
          PaintedLeg(Offset(.342, .698), Offset(.162, .972)),
          PaintedLeg(Offset(.622, .663), Offset(.693, .988)),
          PaintedLeg(Offset(.397, .753), Offset(.444, .947)),
          PaintedLeg(Offset(.728, .670), Offset(.720, .895), visible: false),
        ],
        357 / 450,
        false,
      ),
    },
    Companion.fox: {
      2: PaintedWalk._(
        true,
        const [
          PaintedLeg(Offset(.637, .690), Offset(.770, .977)),
          PaintedLeg(Offset(.423, .664), Offset(.391, .992)),
          PaintedLeg(Offset(.585, .728), Offset(.506, .954)),
          PaintedLeg(Offset(.268, .685), Offset(.195, .985)),
        ],
        354 / 450,
        true,
      ),
      3: PaintedWalk._(
        true,
        const [
          PaintedLeg(Offset(.541, .649), Offset(.709, .954)),
          PaintedLeg(Offset(.335, .625), Offset(.190, .986)),
          PaintedLeg(Offset(.446, .665), Offset(.348, .944)),
          PaintedLeg(Offset(.185, .622), Offset(.117, .956)),
        ],
        422 / 451,
        true,
      ),
      4: PaintedWalk._(
        true,
        const [
          PaintedLeg(Offset(.495, .746), Offset(.701, .981)),
          PaintedLeg(Offset(.289, .709), Offset(.179, .993)),
          PaintedLeg(Offset(.438, .757), Offset(.385, .965)),
          PaintedLeg(Offset(.169, .703), Offset(.055, .969)),
        ],
        380 / 455,
        true,
      ),
      5: PaintedWalk._(
        true,
        const [
          PaintedLeg(Offset(.577, .739), Offset(.753, .967)),
          PaintedLeg(Offset(.377, .713), Offset(.301, .994)),
          PaintedLeg(Offset(.509, .738), Offset(.490, .958)),
          PaintedLeg(Offset(.293, .707), Offset(.219, .970)),
        ],
        407 / 452,
        true,
      ),
    },
  };
}
