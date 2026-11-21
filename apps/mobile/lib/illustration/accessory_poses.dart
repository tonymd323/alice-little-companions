import '../domain/companions.dart';

enum AccessoryPose {
  seated,
  seatedLeft,
  airborne,
  airborneLeft,
  walkSide,
  walkLeft,
  walkFront,
  walkBack;

  bool get flying => this == airborne || this == airborneLeft;
}

String? _fittedPart(String asset, Companion pet, int stage) =>
    switch ((pet, stage, asset)) {
      (Companion.fox, 1, 'item_accessory_bow') => 'fox-bow',
      (Companion.cat, 1, 'item_accessory_glasses') => 'cat-glasses',
      (Companion.rabbit, 1, 'item_accessory_scarf') => 'rabbit-neckerchief',
      _ => null,
    };

String? fittedAccessoryThumbnail(String asset, Companion pet, int stage) {
  final part = _fittedPart(asset, pet, stage);
  return part == null ? null : 'assets/art/wardrobe-$part-thumbnail.webp';
}

String? registeredAccessory(
  String asset,
  Companion pet,
  int stage,
  AccessoryPose pose,
  String? garment,
) {
  final part = _fittedPart(asset, pet, stage);
  if (part == null) return null;
  if (pet == Companion.rabbit &&
      pose != AccessoryPose.seated &&
      pose != AccessoryPose.seatedLeft &&
      !pose.flying) {
    return null;
  }

  final view = switch (pose) {
    AccessoryPose.seated => 'seated',
    AccessoryPose.seatedLeft => pet == Companion.fox ? 'seated-left' : 'seated',
    AccessoryPose.airborne => 'airborne',
    AccessoryPose.airborneLeft =>
      pet == Companion.fox ? 'airborne-left' : 'airborne',
    AccessoryPose.walkSide => 'walk-side',
    AccessoryPose.walkLeft => pet == Companion.fox ? 'walk-left' : 'walk-side',
    AccessoryPose.walkFront => 'walk-front',
    AccessoryPose.walkBack => 'walk-back',
  };
  final costume =
      pose.flying ||
          pose == AccessoryPose.seated ||
          pose == AccessoryPose.seatedLeft
      ? switch (garment) {
          'item_single_apron' => '-apron',
          'item_single_coat' => '-coat',
          _ => '',
        }
      : '';
  return 'assets/art/wardrobe-$part-$view$costume.webp';
}
