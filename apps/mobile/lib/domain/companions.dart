enum Companion {
  fox('银杏狐', '奶油'),
  rabbit('月牙耳兔', '桃桃'),
  cat('云翼猫', '团团');

  const Companion(this.label, this.nickname);

  final String label;
  final String nickname;

  String artwork(int stage, {bool reveal = false}) {
    final pose = this == cat && stage == 4 && !reveal ? '-rest' : '';
    return 'assets/art/$name-$stage$pose.webp';
  }
}

const stageNames = ['初次见面', '小小成长', '渐渐长大', '暖暖陪伴', '闪闪发光', '满满的爱'];
