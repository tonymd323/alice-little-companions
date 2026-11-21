enum Companion {
  fox('银杏狐', '奶油'),
  rabbit('月牙耳兔', '桃桃'),
  cat('云翼猫', '团团'),
  otter('溪纹水獭', '小溪'),
  hedgehog('栗蓬刺猬', '栗栗');

  const Companion(this.label, this.nickname);

  final String label;
  final String nickname;

  static const starters = [fox, rabbit, cat];
  bool get hasGroundSkill => this == otter || this == hedgehog;

  String get unlockItemId => 'companion_$name';
  String get firstStageAssetId => 'pet_${name}_1';

  double aspect(int stage, {bool reveal = false}) {
    if (this == cat && stage == 4 && !reveal) return 480 / 451;
    final (width, height) = switch (this) {
      Companion.fox => const [
        (153, 185),
        (184, 231),
        (214, 227),
        (255, 304),
        (265, 299),
        (339, 290),
      ],
      Companion.rabbit => const [
        (156, 141),
        (181, 177),
        (277, 191),
        (242, 274),
        (256, 289),
        (310, 332),
      ],
      Companion.cat => const [
        (144, 170),
        (196, 198),
        (173, 215),
        (232, 214),
        (340, 277),
        (415, 356),
      ],
      Companion.otter => const [
        (442, 305),
        (444, 314),
        (446, 314),
        (500, 329),
        (500, 311),
        (500, 303),
      ],
      Companion.hedgehog => const [
        (418, 303),
        (417, 319),
        (426, 320),
        (426, 329),
        (500, 345),
        (500, 353),
      ],
    }[stage - 1];
    return width / height;
  }

  String artwork(int stage, {bool reveal = false}) {
    final pose = this == cat && stage == 4 && !reveal ? '-rest' : '';
    return 'assets/art/$name-$stage$pose.webp';
  }
}

const stageNames = ['初次见面', '小小成长', '渐渐长大', '暖暖陪伴', '闪闪发光', '满满的爱'];
