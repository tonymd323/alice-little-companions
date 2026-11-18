import 'dart:ui';

import '../domain/layout_rules.dart';
import '../domain/rules.dart';

class ScenePiece {
  const ScenePiece(this.asset, this.name);
  ScenePiece.fromRow(Json row)
    : asset = row['asset_id'] as String,
      name = row['name'] as String;
  final String asset, name;

  static List<ScenePiece> preview(Json product) => [
    for (final part
        in (product['included_items'] as List?)?.cast<Json>() ?? [product])
      if (part['slot'] == null) ScenePiece.fromRow(part),
  ];
}

/// The frame is in the artist's 3:2 canvas, anchored to the sill, beam or
/// floor. Size and depth are independent so a rug never covers an actor.
class RoomLayer {
  const RoomLayer(
    this.art,
    this.name,
    this.frame,
    this.depth, {
    this.shadow = false,
  });
  final String art, name;
  final Rect frame;
  final double depth;
  final bool shadow;
}

const furnishedRooms = {
  'garden': ['part_garden_bench', 'part_garden_planter', 'part_garden_path'],
  'treehouse': [
    'part_treehouse_bench',
    'part_treehouse_shelf',
    'part_treehouse_rug',
  ],
  'pastry_shop': [
    'part_pastry_shop_counter',
    'part_pastry_shop_table',
    'part_pastry_shop_sign',
  ],
  'flower_shop': [
    'part_flower_shop_counter',
    'part_flower_shop_shelf',
    'part_flower_shop_sign',
  ],
};
const _suites = {
  'forest': [
    'part_bundle_forest_chair',
    'part_bundle_forest_table',
    'part_bundle_forest_lamp',
  ],
  'starlight': [
    'part_bundle_starlight_bed',
    'part_bundle_starlight_cabinet',
    'part_bundle_starlight_rug',
  ],
};

class RoomPainting {
  RoomPainting(String scene, List<ScenePiece> pieces) {
    final owned = {for (final piece in pieces) piece.asset: piece.name};
    final isHome = scene == 'base_room';
    final builtIn = furnishedRooms[scene];
    if (builtIn != null && builtIn.every(owned.containsKey)) {
      background = artworkPath('painted_$scene');
      for (final part in builtIn) {
        owned.remove(part);
      }
    }
    for (final entry in _suites.entries) {
      if (entry.value.every(owned.containsKey)) {
        for (final part in entry.value) {
          owned.remove(part);
        }
        owned['suite_${entry.key}'] = entry.key == 'forest' ? '森林阅读角' : '星光卧室';
      }
    }
    for (final entry in owned.entries) {
      final id = entry.key;
      final s = _positions[id];
      if (s == null) continue;
      var (x, y, w, h) = s;
      // Move the larger vignettes apart when a family owns both individual
      // furniture and its neighbouring suite. The lit walkway stays open.
      if (id == 'item_single_armchair' && owned.containsKey('suite_forest')) {
        x = .36;
      }
      if (id == 'item_single_bed' && owned.containsKey('suite_starlight')) {
        x = .63;
      }
      if (id == 'base_bed' && owned.containsKey('item_single_bed')) continue;
      if (id == 'base_bed' && owned.containsKey('suite_starlight')) x = .62;
      if (!isHome && !id.startsWith('part_')) {
        // Keepsakes carried to another room in a legacy save have mounts on
        // its furniture or floor, rather than on the veranda's window seat.
        if (id == 'item_decor_cushion') {
          x = .31;
          y = .86;
        }
        if (id == 'item_decor_vase') {
          x = .68;
          y = .83;
        }
        if (id == 'item_decor_plant') {
          x = .83;
          y = .80;
        }
        if (id == 'item_decor_mobile') {
          x = .37;
          y = .30;
        }
      }
      final flat = id.endsWith('rug') || id.endsWith('_path');
      final elevated =
          id == 'item_decor_mobile' ||
          id == 'item_decor_cushion' ||
          id == 'item_decor_vase';
      final path = id.startsWith('item_') ? 'installed_${id.substring(5)}' : id;
      layers.add(
        RoomLayer(
          artworkPath(path),
          entry.value,
          Rect.fromLTWH(x - w / 2, y - h, w, h),
          flat || elevated ? 0 : y,
          shadow: !flat && id != 'item_decor_mobile',
        ),
      );
    }
    layers.sort((a, b) => a.depth.compareTo(b.depth));
  }
  String? background;
  final layers = <RoomLayer>[];
  Rect? frameFor(List<ScenePiece> requested) {
    final assets = requested.map((p) => p.asset).toSet();
    for (final entry in _suites.entries) {
      if (entry.value.every(assets.contains)) {
        return layers
            .where((p) => p.art == artworkPath('suite_${entry.key}'))
            .firstOrNull
            ?.frame;
      }
    }
    final names = requested.map((p) => p.name).toSet();
    return layers.where((p) => names.contains(p.name)).firstOrNull?.frame;
  }
}

// Bottom-center x/y and silhouette width/height in normalized canvas units.
const _positions = <String, (double, double, double, double)>{
  'base_rug': (.47, .942, .27, .090),
  'base_bed': (.72, .837, .196, .207),
  'item_decor_vase': (.325, .570, .058, .119),
  'item_decor_cushion': (.278, .578, .106, .074),
  'item_decor_plant': (.875, .817, .124, .216),
  'item_decor_mobile': (.658, .372, .094, .280),
  'item_single_armchair': (.263, .841, .201, .312),
  'item_single_bed': (.70, .862, .232, .233),
  'suite_forest': (.155, .821, .273, .325),
  'suite_starlight': (.839, .900, .285, .279),
  'part_bundle_forest_chair': (.20, .81, .15, .225),
  'part_bundle_forest_table': (.30, .84, .105, .135),
  'part_bundle_forest_lamp': (.125, .755, .096, .264),
  'part_bundle_starlight_bed': (.71, .80, .18, .218),
  'part_bundle_starlight_cabinet': (.835, .78, .113, .164),
  'part_bundle_starlight_rug': (.738, .855, .236, .087),
  'part_garden_bench': (.25, .76, .25, .205),
  'part_garden_planter': (.80, .74, .20, .18),
  'part_garden_path': (.60, .93, .23, .15),
  'part_treehouse_bench': (.28, .83, .09, .12),
  'part_treehouse_shelf': (.79, .76, .21, .36),
  'part_treehouse_rug': (.49, .88, .25, .095),
  'part_pastry_shop_counter': (.26, .80, .30, .27),
  'part_pastry_shop_table': (.76, .82, .13, .21),
  'part_pastry_shop_sign': (.84, .85, .09, .16),
  'part_flower_shop_counter': (.24, .80, .29, .25),
  'part_flower_shop_shelf': (.81, .76, .19, .33),
  'part_flower_shop_sign': (.65, .81, .08, .14),
};
