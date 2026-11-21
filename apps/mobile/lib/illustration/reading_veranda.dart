import 'dart:ui';

import 'room_painting.dart';

abstract final class ReadingVeranda {
  static const room = 'assets/art/reading-veranda-room.webp';
  static const gold = 'assets/art/reading-veranda-gold-light.webp';
  static const stained = 'assets/art/reading-veranda-stained-light.webp';
  static const windows = 'assets/art/reading-veranda-restored-windows.webp';
  static const lightFrame = Rect.fromLTRB(
    136 / 1536,
    704 / 1024,
    1068 / 1536,
    968 / 1024,
  );
  static const windowFrame = Rect.fromLTRB(
    218 / 1536,
    200 / 1024,
    1472 / 1536,
    592 / 1024,
  );
  static const stoolFrame = Rect.fromLTRB(
    712 / 1536,
    647 / 1024,
    879 / 1536,
    808 / 1024,
  );
  static const mapCenter = Offset(804 / 1536, 685 / 1024);
  static const stoolDepth = 795 / 1024;

  static const stoolShadow = RoomLayer(
    'assets/art/reading-veranda-stool-shadow.webp',
    '',
    stoolFrame,
    0,
  );
  static const stool = RoomLayer(
    'assets/art/reading-veranda-stool.webp',
    '矮凳',
    stoolFrame,
    stoolDepth,
  );
  static const rolledMap = RoomLayer(
    'assets/art/reading-veranda-rolled-map.webp',
    '卷图',
    stoolFrame,
    stoolDepth + .000001,
  );
}
