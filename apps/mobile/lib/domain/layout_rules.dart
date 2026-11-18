import 'companions.dart';
import 'pin.dart';
import 'rules.dart';

const freeFurnishings = {'base_bed': '午休小床', 'base_rug': '编织小毯'};

String artworkPath(String id) => 'assets/art/$id.webp';

class PlacementDraft {
  const PlacementDraft(
    this.id,
    this.x,
    this.y,
    this.z, {
    this.flipped = false,
    this.mount,
  });
  final String id;
  final double x;
  final double y;
  final int z;
  final bool flipped;
  final String? mount;

  factory PlacementDraft.fromRow(Json row) => PlacementDraft(
    row['entitlement_id'] as String,
    (row['x'] as num).toDouble(),
    (row['y'] as num).toDouble(),
    row['z'] as int,
    flipped: row['flipped'] == 1,
    mount: row['mount_id'] as String?,
  );

  PlacementDraft at(double x, double y, {String? mount}) =>
      PlacementDraft(id, x, y, z, flipped: flipped, mount: mount);

  PlacementDraft withOrder(int z) =>
      PlacementDraft(id, x, y, z, flipped: flipped, mount: mount);

  PlacementDraft mirror() =>
      PlacementDraft(id, x, y, z, flipped: !flipped, mount: mount);

  Json encode() => {
    'id': id,
    'x': x,
    'y': y,
    'z': z,
    'flipped': flipped,
    'mount': mount,
  };
}

class SceneDefinition {
  const SceneDefinition(this.rules, this.id);

  final Rules rules;
  final String id;

  Json get data => rules.scenes[id] ?? (throw const UserError('空间未解锁。'));
  List<(double, double)> get floor => (data['floor_polygon'] as List)
      .map((v) => ((v[0] as num).toDouble(), (v[1] as num).toDouble()))
      .toList(growable: false);

  List<Json> get mounts =>
      (data['hanging_mounts'] as List?)?.cast<Json>() ?? [];

  String get background => id == 'base_room'
      ? 'assets/art/garden.webp'
      : artworkPath('scene_${id}_background');

  String get foreground => artworkPath('scene_${id}_foreground');

  PlacementDraft snap(PlacementDraft draft, String asset) {
    if (asset != 'item_decor_mobile') return draft;
    for (final mount in mounts) {
      final xy = mount['position'] as List;
      final x = (xy[0] as num).toDouble();
      final y = (xy[1] as num).toDouble();
      if ((draft.x - x).abs() <= .12 && (draft.y - y).abs() <= .12) {
        return draft.at(x, y, mount: mount['id'] as String);
      }
    }
    return draft;
  }

  PlacementDraft initialPlacement(String id, String asset, int z) {
    if (asset == 'item_decor_mobile') {
      if (mounts.isEmpty) throw const UserError('这里没有可用的挂点。');
      final first = mounts.first;
      final xy = first['position'] as List;
      return PlacementDraft(
        id,
        (xy[0] as num).toDouble(),
        (xy[1] as num).toDouble(),
        z,
        mount: first['id'] as String,
      );
    }
    return PlacementDraft(
      id,
      this.id == 'base_room' ? .27 : .42,
      this.id == 'base_room' ? .86 : .85,
      z,
    );
  }

  void validate(PlacementDraft placement, String asset, String name) {
    if (!placement.x.isFinite ||
        !placement.y.isFinite ||
        placement.z < 0 ||
        placement.x < 0 ||
        placement.x > 1 ||
        placement.y < 0 ||
        placement.y > 1) {
      throw UserError('$name的位置超出画面。');
    }
    if (asset == 'item_decor_mobile') {
      final mount = mounts
          .where((m) => m['id'] == placement.mount)
          .singleOrNull;
      final xy = mount?['position'] as List?;
      if (xy == null ||
          (placement.x - (xy[0] as num)).abs() > .00001 ||
          (placement.y - (xy[1] as num)).abs() > .00001) {
        throw UserError('请把$name挂在标出的屋檐挂点。');
      }
      return;
    }
    if (placement.mount != null) throw UserError('$name需要摆在地面。');
    final footprint = itemWidth(asset) * .46;
    const depth = .022;
    final canPlace = [
      (placement.x - footprint, placement.y),
      (placement.x + footprint, placement.y),
      (placement.x - footprint, placement.y - depth),
      (placement.x + footprint, placement.y - depth),
    ].every((point) => contains(floor, point.$1, point.$2));
    final petLeft = placement.x + footprint < .415;
    final petRight = placement.x - footprint > .525;
    if (!canPlace ||
        (id == 'base_room' && placement.y > .92 && !petLeft && !petRight)) {
      throw UserError('请把$name完整移到可摆放区域内。');
    }
  }
}

bool contains(List<(double, double)> polygon, double x, double y) {
  var inside = false;
  for (var i = 0, prev = polygon.length - 1; i < polygon.length; prev = i++) {
    final (ax, ay) = polygon[i];
    final (bx, by) = polygon[prev];
    if ((ay > y) != (by > y) && x < (bx - ax) * (y - ay) / (by - ay) + ax) {
      inside = !inside;
    }
  }
  return inside;
}

double itemWidth(String asset) => switch (asset) {
  'item_decor_mobile' => .075,
  'item_decor_vase' || 'item_decor_plant' => .095,
  'item_decor_cushion' => .12,
  'base_bed' || 'item_single_bed' || 'part_bundle_starlight_bed' => .20,
  'part_pastry_shop_counter' || 'part_flower_shop_counter' => .22,
  'base_rug' || 'part_treehouse_rug' || 'part_bundle_starlight_rug' => .20,
  _ => .15,
};

List<double> wearPoint(Rules rules, Companion pet, int stage, String slot) {
  final coordinates = ((rules.wearAnchors[pet.name] as List)[stage - 1] as List)
      .cast<num>();
  final x = coordinates[0] / 100;
  final eyes = coordinates[1] / 100;
  final neck = coordinates[2] / 100;
  return switch (slot) {
    'head' => [x, eyes - .115, .34],
    'face' => [x, eyes, .32],
    'neck' => [x, neck, .32],
    _ => [(x + .5) / 2, neck + .105, .47],
  };
}
