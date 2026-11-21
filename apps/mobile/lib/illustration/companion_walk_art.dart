import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../domain/companions.dart';
import 'accessory_poses.dart';
import 'companion_motion.dart';
import 'companion_walk.dart';
import 'tailoring.dart';

enum _View {
  brace,
  stand,
  reach,
  follow,
  gather,
  front,
  back,
  turnFront,
  turnBack,
  frontReach,
  frontFollow,
  backReach,
  backFollow,
  nearBackLeft;

  bool get frontView =>
      this == front || this == frontReach || this == frontFollow;
  bool get backView =>
      this == back ||
      this == backReach ||
      this == backFollow ||
      this == nearBackLeft;
  bool get side => !frontView && !backView;
  bool get backOfHead => backView || this == turnBack;
}

Iterable<_View> _views(Companion pet, String? garment) {
  if (pet == Companion.fox) {
    return garment == 'item_single_apron'
        ? _View.values.take(_View.nearBackLeft.index)
        : _View.values;
  }
  final end = pet.hasGroundSkill ? _View.turnBack : _View.back;
  return _View.values.take(end.index + 1);
}

String _folder(Companion pet) => 'assets/${pet.name}_walk/';
String _path(Companion pet, _View view) {
  final pose = pet.hasGroundSkill && view == _View.gather ? _View.brace : view;
  return '${_folder(pet)}full-${pose.name}.webp';
}

String? _style(String? garment) => switch (garment) {
  'item_single_coat' => 'coat',
  'item_single_apron' => 'apron',
  _ => null,
};

List<String> walkAssets(
  Companion pet,
  String? garment, {
  bool paintedScarf = false,
}) {
  final coat = fittedCoat(pet, 1, garment);
  return [
    for (final view in _views(pet, garment)) ...[
      _walkArtwork(pet, view, garment, coat, paintedScarf),
      if (coat == FittedCoat.mapVest && view.side)
        FittedCoat.mapVest.on(
          _path(pet, view),
          facesLeft: true,
          paintedScarf: paintedScarf,
        ),
    ],
    if (!pet.hasGroundSkill && coat == null && _style(garment) != null)
      for (final view in ['side', 'front', 'away'])
        '${_folder(pet)}cloth-$view-${_style(garment)}.webp',
  ];
}

String _walkArtwork(
  Companion pet,
  _View view,
  String? garment,
  FittedCoat? coat,
  bool paintedScarf,
) {
  final original = _path(pet, view);
  if (_style(garment) case final cloth? when pet.hasGroundSkill) {
    return original.replaceFirst('.webp', '-$cloth.webp');
  }
  return coat?.on(original, paintedScarf: paintedScarf) ??
      (paintedScarf ? foxScarfArtwork(original) : original);
}

class WalkArt {
  WalkArt(
    this.pet,
    Map<String, ui.Image> images,
    String? garment,
    Map<AccessoryPose, AccessoryTextures> clothes,
    String? headAsset, {
    bool paintedScarf = false,
  }) {
    final coat = fittedCoat(pet, 1, garment);
    final fabric = coat == null && !pet.hasGroundSkill ? _style(garment) : null;
    for (final view in _views(pet, garment)) {
      final fit = _fits[pet]![view.index];
      final profile = view.frontView
          ? 'front'
          : view.backOfHead
          ? 'away'
          : 'side';
      final material = images['${_folder(pet)}cloth-$profile-$fabric.webp'];
      final pose = view.frontView
          ? AccessoryPose.walkFront
          : view.backOfHead
          ? AccessoryPose.walkBack
          : AccessoryPose.walkSide;
      final path = _path(pet, view);
      final original =
          images[_walkArtwork(pet, view, garment, coat, paintedScarf)]!;
      final originalFitting = _headFrames[pet]?[profile] ?? fit;
      _cards[view] = _assemble(
        original,
        pet,
        view,
        fit,
        material,
        clothes[pose],
        headAsset,
        originalFitting,
      );
      final leftBody =
          images[coat?.on(path, facesLeft: true, paintedScarf: paintedScarf)];
      final leftClothes = view == _View.turnBack
          ? clothes[pose]
          : clothes[AccessoryPose.walkLeft];
      if (view.side && (leftBody != null || leftClothes != null)) {
        _leftCards[view] = _assemble(
          leftBody ?? original,
          pet,
          view,
          fit,
          material,
          leftClothes ?? clothes[pose],
          headAsset,
          originalFitting,
          left: true,
        );
      }
    }
  }

  final Companion pet;
  final _cards = <_View, _PaintedCard>{};
  final _leftCards = <_View, _PaintedCard>{};

  void dispose() {
    for (final card in [..._cards.values, ..._leftCards.values]) {
      card.dispose();
    }
  }

  void paint(Canvas canvas, Rect box, WalkPose pose) {
    final side = math.cos(pose.yaw);
    final depth = math.sin(pose.yaw);
    final facing = side.abs();
    final frontOrBack = depth < 0 ? _View.back : _View.front;
    final quarter = depth < 0 ? _View.turnBack : _View.turnFront;
    final phase = pose.phase % 1;
    bool swinging(WalkLeg leg) => pose.paws[leg.index].lift > 4 * pose.scale;
    // The low silhouettes lift different paws in their authored step poses.
    final (reach, follow) = switch (pet) {
      Companion.otter => (
        swinging(WalkLeg.nearFront),
        swinging(WalkLeg.farFront),
      ),
      Companion.hedgehog => (
        swinging(WalkLeg.farFront),
        swinging(WalkLeg.nearHind),
      ),
      _ => (phase >= .09 && phase < .37, phase >= .57 && phase < .82),
    };
    final fox = pet == Companion.fox;
    final view = switch (pose.stage) {
      WalkStage.turn || WalkStage.gather
          when _cards.containsKey(_View.nearBackLeft) &&
              depth < 0 &&
              side < -.32 &&
              side > -.62 =>
        _View.nearBackLeft,
      WalkStage.walk when fox && facing < .58 => switch ((
        depth < 0,
        reach,
        follow,
      )) {
        (true, true, _) => _View.backReach,
        (true, _, true) => _View.backFollow,
        (false, true, _) => _View.frontReach,
        (false, _, true) => _View.frontFollow,
        _ => frontOrBack,
      },
      WalkStage.turn ||
      WalkStage.gather ||
      WalkStage.walk when facing < .58 => frontOrBack,
      WalkStage.turn || WalkStage.gather
          when (fox || pet.hasGroundSkill) && facing < .83 =>
        quarter,
      WalkStage.rise when pose.crouch > .90 => _View.gather,
      WalkStage.rise when pose.crouch > .74 => _View.brace,
      WalkStage.sit when pose.crouch > .35 => _View.gather,
      WalkStage.walk when reach => _View.reach,
      WalkStage.walk when follow => _View.follow,
      _ => _View.stand,
    };
    final lateral = view.side;
    final mirror = lateral && side < 0;
    final card = (mirror ? _leftCards[view] : null) ?? _cards[view]!;
    // Keep the intermediate painting registered to the hips as the head
    // swings from the rear quarter to the centre of the back view.
    final rearPivotX = view == _View.nearBackLeft ? (.43 - facing) * 180 : 0.0;
    _place(canvas, box);
    card.paint(canvas, pose, mirror, rearPivotX: rearPivotX);
    canvas.restore();
  }

  void paintSkillSupport(Canvas canvas, Rect box, bool left, double progress) {
    final view = switch (progress) {
      < .18 => _View.gather,
      < .5 => _View.brace,
      < .84 => _View.reach,
      < .89 => _View.stand,
      _ => _View.gather,
    };
    final card = (left ? _leftCards[view] : null) ?? _cards[view]!;
    _place(canvas, box);
    card.paintStill(canvas, left);
    canvas.restore();
  }

  void _place(Canvas canvas, Rect box) {
    canvas.save();
    canvas.translate(box.center.dx, box.bottom);
    canvas.scale(box.height / walkOrigin.dy);
    canvas.translate(-walkOrigin.dx, -walkOrigin.dy);
  }
}

class _Fit {
  const _Fit(this.near, this.far, this.ear, this.pads);
  final Offset near, far, ear;
  final List<Offset> pads;

  Offset get eyes => (near + far) / 2;
}

final _fits = {
  Companion.cat: [
    _Fit(Offset(274, 192), Offset(367, 172), Offset(155, 154), [
      Offset(218, 436),
      Offset(283, 438),
      Offset(242, 422),
      Offset(347, 435),
    ]),
    _Fit(Offset(309, 193), Offset(402, 173), Offset(180, 153), [
      Offset(176, 436),
      Offset(304, 438),
      Offset(223, 419),
      Offset(363, 435),
    ]),
    _Fit(Offset(320, 193), Offset(418, 165), Offset(192, 152), [
      Offset(137, 435),
      Offset(306, 438),
      Offset(222, 422),
      Offset(403, 406),
    ]),
    _Fit(Offset(348, 193), Offset(447, 168), Offset(211, 151), [
      Offset(149, 438),
      Offset(357, 438),
      Offset(251, 420),
      Offset(446, 406),
    ]),
    _Fit(Offset(296, 198), Offset(392, 179), Offset(161, 159), [
      Offset(192, 434),
      Offset(293, 438),
      Offset(232, 421),
      Offset(351, 434),
    ]),
    _Fit(Offset(260, 210), Offset(364, 199), Offset(172, 148), [
      Offset(139, 428),
      Offset(272, 438),
      Offset(207, 426),
      Offset(344, 428),
    ]),
    _Fit(Offset(204, 195), Offset(302, 195), Offset(336, 150), [
      Offset(193, 435),
      Offset(144, 423),
      Offset(339, 436),
      Offset(264, 425),
    ]),
  ],
  Companion.fox: [
    _Fit(Offset(335, 267), Offset(416, 274), Offset(248, 216), [
      Offset(202, 436),
      Offset(274, 438),
      Offset(222, 421),
      Offset(324, 433),
    ]),
    _Fit(Offset(368, 265), Offset(470, 265), Offset(246, 212), [
      Offset(164, 435),
      Offset(275, 438),
      Offset(231, 416),
      Offset(364, 431),
    ]),
    _Fit(Offset(379, 266), Offset(474, 266), Offset(246, 213), [
      Offset(134, 433),
      Offset(286, 438),
      Offset(221, 419),
      Offset(395, 409),
    ]),
    _Fit(Offset(382, 260), Offset(473, 260), Offset(245, 208), [
      Offset(162, 431),
      Offset(335, 438),
      Offset(266, 419),
      Offset(408, 400),
    ]),
    _Fit(Offset(348, 229), Offset(436, 219), Offset(233, 183), [
      Offset(203, 432),
      Offset(268, 438),
      Offset(236, 419),
      Offset(338, 432),
    ]),
    _Fit(Offset(242, 211), Offset(349, 201), Offset(147, 165), [
      Offset(167, 433),
      Offset(267, 439),
      Offset(204, 421),
      Offset(343, 434),
    ]),
    _Fit(Offset(204, 195), Offset(302, 195), Offset(339, 167), [
      Offset(231, 437),
      Offset(182, 427),
      Offset(352, 433),
      Offset(295, 418),
    ]),
    _Fit(Offset(354, 239), Offset(427, 236), Offset(245, 209), [
      Offset(171, 434),
      Offset(300, 438),
      Offset(242, 420),
      Offset(360, 432),
    ]),
    _Fit(Offset(287, 213), Offset(381, 210), Offset(390, 206), [
      Offset(192, 438),
      Offset(343, 437),
      Offset(163, 421),
      Offset(258, 424),
    ]),
    _Fit(Offset(249, 215), Offset(351, 213), Offset(168, 181), [
      Offset(206, 420),
      Offset(259, 406),
      Offset(321, 414),
      Offset(320, 437),
    ]),
    _Fit(Offset(251, 215), Offset(353, 213), Offset(169, 181), [
      Offset(203, 418),
      Offset(257, 437),
      Offset(289, 418),
      Offset(325, 407),
    ]),
    _Fit(Offset(204, 180), Offset(302, 181), Offset(329, 161), [
      Offset(212, 437),
      Offset(169, 404),
      Offset(276, 416),
      Offset(338, 421),
    ]),
    _Fit(Offset(204, 180), Offset(302, 181), Offset(329, 161), [
      Offset(198, 412),
      Offset(155, 403),
      Offset(259, 437),
      Offset(337, 422),
    ]),
    _Fit(Offset(177, 185), Offset(277, 186), Offset(314, 153), [
      Offset(201, 438),
      Offset(145, 416),
      Offset(282, 426),
      Offset(232, 415),
    ]),
  ],
  Companion.otter: [
    _Fit(Offset(397, 282), Offset(443, 275), Offset(321, 270), [
      Offset(193, 436),
      Offset(343, 439),
      Offset(230, 430),
      Offset(375, 436),
    ]),
    _Fit(
      Offset(406, 238),
      Offset(448, 242),
      Offset(332, 219),
      WalkRig.otter.standingPads,
    ),
    _Fit(Offset(400, 232), Offset(444, 234), Offset(326, 223), [
      Offset(166, 439),
      Offset(398, 415),
      Offset(225, 427),
      Offset(339, 438),
    ]),
    _Fit(Offset(406, 235), Offset(448, 238), Offset(330, 226), [
      Offset(169, 438),
      Offset(343, 438),
      Offset(234, 431),
      Offset(403, 414),
    ]),
    _Fit(Offset(397, 282), Offset(443, 275), Offset(321, 270), [
      Offset(193, 436),
      Offset(343, 439),
      Offset(230, 430),
      Offset(375, 436),
    ]),
    _Fit(
      Offset(227, 219),
      Offset(308, 218),
      Offset(187, 185),
      WalkRig.otter.front!,
    ),
    _Fit(
      Offset(187, 209),
      Offset(329, 209),
      Offset(328, 197),
      WalkRig.otter.away!,
    ),
    _Fit(
      Offset(341, 219),
      Offset(407, 209),
      Offset(271, 207),
      WalkRig.otter.standingPads,
    ),
    _Fit(Offset(292, 200), Offset(393, 190), Offset(391, 202), [
      Offset(179, 438),
      Offset(380, 438),
      Offset(256, 430),
      Offset(364, 430),
    ]),
  ],
  Companion.hedgehog: [
    _Fit(Offset(374, 307), Offset(420, 290), Offset(299, 254), [
      Offset(116, 435),
      Offset(292, 439),
      Offset(168, 428),
      Offset(361, 435),
    ]),
    _Fit(
      Offset(373, 277),
      Offset(421, 272),
      Offset(298, 239),
      WalkRig.hedgehog.standingPads,
    ),
    _Fit(Offset(369, 271), Offset(411, 264), Offset(290, 235), [
      Offset(111, 438),
      Offset(284, 439),
      Offset(173, 434),
      Offset(390, 407),
    ]),
    _Fit(Offset(364, 279), Offset(411, 262), Offset(298, 243), [
      Offset(128, 416),
      Offset(278, 439),
      Offset(181, 434),
      Offset(339, 437),
    ]),
    _Fit(Offset(374, 307), Offset(420, 290), Offset(299, 254), [
      Offset(116, 435),
      Offset(292, 439),
      Offset(168, 428),
      Offset(361, 435),
    ]),
    _Fit(
      Offset(222, 281),
      Offset(299, 280),
      Offset(184, 242),
      WalkRig.hedgehog.front!,
    ),
    _Fit(
      Offset(173, 224),
      Offset(329, 224),
      Offset(329, 231),
      WalkRig.hedgehog.away!,
    ),
    _Fit(
      Offset(357, 276),
      Offset(412, 261),
      Offset(293, 230),
      WalkRig.hedgehog.standingPads,
    ),
    _Fit(Offset(297, 237), Offset(382, 235), Offset(353, 235), [
      Offset(120, 437),
      Offset(363, 439),
      Offset(166, 428),
      Offset(338, 433),
    ]),
  ],
};

const _foxFarEar = {
  _View.brace: Offset(397, 159),
  _View.stand: Offset(439, 155),
  _View.reach: Offset(443, 152),
  _View.follow: Offset(447, 150),
  _View.gather: Offset(410, 136),
  _View.turnFront: Offset(408, 165),
  _View.turnBack: Offset(252, 165),
};

const _headFrames = {
  Companion.cat: {
    'side': _Fit(Offset(338, 166), Offset(431, 142), Offset(274, 134), []),
    'front': _Fit(Offset(207, 179), Offset(306, 179), Offset(161, 111), []),
    'away': _Fit(Offset(207, 179), Offset(306, 179), Offset(161, 111), []),
  },
  Companion.fox: {
    'side': _Fit(Offset(358, 190), Offset(448, 176), Offset(257, 135), []),
    'front': _Fit(Offset(210, 192), Offset(301, 190), Offset(171, 133), []),
    'away': _Fit(Offset(210, 192), Offset(301, 190), Offset(337, 122), []),
  },
};

Offset _normalized(Offset point) =>
    Offset(point.dx / walkCanvas.width, point.dy / walkCanvas.height);

_PaintedCard _assemble(
  ui.Image original,
  Companion pet,
  _View view,
  _Fit fit,
  ui.Image? cloth,
  AccessoryTextures? clothes,
  String? headAsset,
  _Fit old, {
  bool left = false,
}) {
  if (cloth == null && (clothes == null || !hasAccessories(clothes))) {
    return _PaintedCard(original.clone(), fit, Offset.zero);
  }
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final brush = Paint()..filterQuality = FilterQuality.medium;
  canvas.drawImage(original, Offset.zero, brush);
  if (cloth != null) {
    final rear = fit.pads[0].dx, chest = fit.pads[1].dx;
    final frontal = view == _View.front || view == _View.back;
    final frame = Rect.fromCenter(
      center: Offset(
        frontal ? (fit.pads[0].dx + fit.pads[3].dx) / 2 : (rear + chest) / 2,
        356,
      ),
      width: frontal ? 114 : (chest - rear).abs() * 1.02,
      height: view == _View.brace || view == _View.gather ? 82 : 91,
    );
    canvas.drawImageRect(
      cloth,
      Offset.zero & Size(cloth.width.toDouble(), cloth.height.toDouble()),
      frame,
      brush,
    );
  }
  if (clothes != null) {
    for (final entry in clothes.registered.entries) {
      final head = entry.key == 'head';
      final farBow = head && left && pet == Companion.fox
          ? _foxFarEar[view]
          : null;
      final target = head ? farBow ?? fit.ear : fit.eyes;
      final anchor = head
          ? farBow != null && view != _View.turnBack
                ? const Offset(447, 108)
                : old.ear
          : old.eyes;
      final drawnAxis = fit.far - fit.near;
      final originalAxis = old.far - old.near;
      final zoom = (drawnAxis.distance / originalAxis.distance).clamp(
        .78,
        1.17,
      );
      canvas.save();
      canvas.translate(target.dx, target.dy);
      if (!head) {
        canvas.rotate(
          math.atan2(drawnAxis.dy, drawnAxis.dx) -
              math.atan2(originalAxis.dy, originalAxis.dx),
        );
      }
      final bowScale = switch (view) {
        _View.turnBack when farBow != null => .57,
        _View.nearBackLeft when head => .78,
        _ => 1.0,
      };
      canvas.scale(zoom * bowScale);
      canvas.drawImage(entry.value, -anchor, brush);
      canvas.restore();
    }
  }
  final picture = recorder.endRecording();
  final body = picture.toImageSync(
    walkCanvas.width.toInt(),
    walkCanvas.height.toInt(),
  );
  picture.dispose();
  if (clothes == null || clothes.generic.isEmpty) {
    return _PaintedCard(body, fit, Offset.zero);
  }
  final groundSpecies = pet.hasGroundSkill;
  final neck = groundSpecies
      ? view.frontView || view.backOfHead
            ? fit.eyes + const Offset(0, 83)
            : fit.near + const Offset(-34, 76)
      : fit.eyes + const Offset(0, 100);
  final headWidth = groundSpecies
      ? (pet == Companion.otter ? 139.0 : 125.0)
      : (fit.far - fit.near).distance * 1.9;
  final fitted = applyAccessories(
    body,
    pet,
    1,
    false,
    _normalized(fit.near),
    _normalized(fit.far),
    clothes.generic,
    headAsset,
    scarfFit: groundSpecies
        ? (
            center: _normalized(neck),
            span: headWidth * .82 / walkCanvas.width,
            back: view.backOfHead,
          )
        : _foxScarf(pet, view),
    rearTemples: switch (view) {
      _View.back when pet == Companion.fox => (
        _normalized(const Offset(164, 198)),
        _normalized(const Offset(347, 201)),
      ),
      _View.nearBackLeft => (
        _normalized(const Offset(126, 200)),
        _normalized(const Offset(321, 203)),
      ),
      _View.turnBack => (
        _normalized(const Offset(228, 211)),
        _normalized(const Offset(417, 235)),
      ),
      _View.backReach || _View.backFollow => (
        _normalized(const Offset(123, 195)),
        _normalized(const Offset(326, 196)),
      ),
      _ => null,
    },
    fit: (
      crown: _normalized(
        groundSpecies
            ? fit.near - const Offset(26, 54)
            : fit.eyes - const Offset(8, 115),
      ),
      ear: _normalized(fit.ear),
      neck: _normalized(neck),
      width: headWidth / walkCanvas.width,
    ),
  );
  body.dispose();
  return _PaintedCard(fitted.image, fit, fitted.padding);
}

ScarfFit? _foxScarf(Companion pet, _View view) {
  if (pet != Companion.fox) return null;
  final (center, width) = switch (view) {
    _View.brace => (const Offset(275, 319), 118.0),
    _View.stand => (const Offset(317, 311), 123.0),
    _View.reach => (const Offset(337, 310), 124.0),
    _View.follow => (const Offset(360, 307), 119.0),
    _View.gather => (const Offset(310, 299), 124.0),
    _View.front => (const Offset(262, 311), 140.0),
    _View.back => (const Offset(243, 294), 111.0),
    _View.turnFront => (const Offset(328, 323), 128.0),
    _View.turnBack => (const Offset(316, 304), 139.0),
    _View.frontReach || _View.frontFollow => (const Offset(288, 300), 135.0),
    _View.backReach || _View.backFollow => (const Offset(230, 264), 119.0),
    _View.nearBackLeft => (const Offset(220, 296), 119.0),
  };
  return (
    center: _normalized(center),
    span: width / walkCanvas.width,
    back: view.backOfHead,
  );
}

class _PaintedCard {
  _PaintedCard(this.image, this.fit, this.padding) {
    shader = ui.ImageShader(
      image,
      ui.TileMode.clamp,
      ui.TileMode.clamp,
      Matrix4.identity().storage,
      filterQuality: ui.FilterQuality.medium,
    );
    for (var row = 0; row <= rows; row++) {
      for (var col = 0; col <= cols; col++) {
        final i = row * (cols + 1) + col;
        final x = col * image.width / cols;
        final y = row * image.height / rows;
        uv[2 * i] = x;
        uv[2 * i + 1] = y;
        final point = Offset(x, y) - padding;
        points.add(point);
        final distances = [
          for (final pad in fit.pads) (point - pad).distanceSquared,
        ];
        final proximity = [
          for (final distance in distances)
            1 / ((distance + 100) * (distance + 100)),
        ];
        final total = proximity.reduce((a, b) => a + b);
        final closest = math.sqrt(distances.reduce(math.min));
        final support = easeMotion(((79 - closest) / 64).clamp(0.0, 1.0));
        for (final (leg, pad) in fit.pads.indexed) {
          final down = ((point.dy - 372) / math.max(36, pad.dy - 372)).clamp(
            0.0,
            1.0,
          );
          weights[leg][i] = proximity[leg] / total * support * easeMotion(down);
        }
      }
    }
  }

  static const cols = 29, rows = 30, count = (cols + 1) * (rows + 1);
  static final triangles = Uint16List.fromList([
    for (var y = 0; y < rows; y++)
      for (var x = 0; x < cols; x++) ...[
        y * (cols + 1) + x,
        (y + 1) * (cols + 1) + x,
        y * (cols + 1) + x + 1,
        y * (cols + 1) + x + 1,
        (y + 1) * (cols + 1) + x,
        (y + 1) * (cols + 1) + x + 1,
      ],
  ]);

  final ui.Image image;
  final _Fit fit;
  final Offset padding;
  late final ui.ImageShader shader;
  final points = <Offset>[];
  final uv = Float32List(count * 2), xy = Float32List(count * 2);
  final weights = List.generate(4, (_) => Float32List(count));

  void paintStill(Canvas canvas, bool mirror, [Offset shift = Offset.zero]) {
    canvas.save();
    if (mirror) {
      canvas.translate(walkOrigin.dx * 2, 0);
      canvas.scale(-1, 1);
    }
    canvas.drawImage(
      image,
      shift - padding,
      Paint()..filterQuality = FilterQuality.medium,
    );
    canvas.restore();
  }

  void paint(
    Canvas canvas,
    WalkPose pose,
    bool mirror, {
    double rearPivotX = 0,
  }) {
    final facing = mirror ? -1.0 : 1.0;
    final offsets = <Offset>[];
    var supported = Offset.zero;
    var weight = 0.0;
    for (final (leg, point) in fit.pads.indexed) {
      final paw = pose.paws[leg];
      final target =
          (paw.ground - pose.root - Offset(0, paw.lift)) / pose.scale;
      final from = point - walkOrigin;
      final delta = Offset(target.dx * facing - from.dx, target.dy - from.dy);
      final pressure =
          (WalkLeg.values[leg].near ? 2.0 : .6) /
          (1 + paw.lift / pose.scale * .5);
      supported += delta * pressure;
      weight += pressure;
      offsets.add(delta);
    }
    // Move the painted torso as one piece. Only the soles have local
    // corrections, small enough to preserve the ankle and the sleeve.
    final sideWalk =
        pose.stage == WalkStage.walk && math.cos(pose.yaw).abs() > .83;
    final fore = WalkLeg.nearFront.index;
    final footPressure = sideWalk
        ? 1 -
              easeMotion(
                (pose.paws[fore].lift / (18 * pose.scale)).clamp(0.0, 1.0),
              )
        : 0.0;
    final adjustment = Offset.lerp(
      supported / weight,
      offsets[fore],
      .74 * footPressure * pose.effort,
    )!;
    final strideRoom = 20 + 24 * footPressure;
    final shift = Offset(
      adjustment.dx.clamp(-strideRoom, strideRoom) +
          pose.load.dx * .14 +
          rearPivotX,
      adjustment.dy.clamp(-7, 8) + pose.load.dy * .10,
    );
    for (var leg = 0; leg < offsets.length; leg++) {
      final residual = offsets[leg] - shift;
      offsets[leg] = Offset(
        residual.dx.clamp(-11, 11),
        residual.dy.clamp(-9, 9),
      );
    }
    for (var i = 0; i < count; i++) {
      final point = points[i];
      var dx = point.dx - walkOrigin.dx + shift.dx;
      var dy = point.dy + shift.dy;
      for (var leg = 0; leg < offsets.length; leg++) {
        final w = weights[leg][i];
        dx += offsets[leg].dx * w;
        dy += offsets[leg].dy * w;
      }
      xy[i * 2] = walkOrigin.dx + facing * dx;
      xy[i * 2 + 1] = dy;
    }
    final areaFloor = image.width * image.height / (cols * rows) * .30;
    if (!meshKeepsShape(xy, triangles, areaFloor, facing: facing)) {
      paintStill(canvas, mirror, shift);
      return;
    }
    final posed = ui.Vertices.raw(
      ui.VertexMode.triangles,
      xy,
      textureCoordinates: uv,
      indices: triangles,
    );
    canvas.drawVertices(posed, BlendMode.srcOver, Paint()..shader = shader);
    posed.dispose();
  }

  void dispose() {
    shader.dispose();
    image.dispose();
  }
}
