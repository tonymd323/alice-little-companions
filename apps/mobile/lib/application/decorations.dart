part of 'family.dart';

extension FamilyDecorations on FamilyService {
  /// Ownership drives the painting. Older placements still determine the room
  /// of an unbound item, even when the family restores a pre-0.12 backup.
  Future<List<Json>> furnishings(String space) async {
    final room = await db.row('SELECT scene_id FROM spaces WHERE id = ?', [
      space,
    ]);
    if (room == null) return [];
    final rows = await db.rows(
      '''
      SELECT e.item_id, e.asset_id, e.name FROM entitlements e
      LEFT JOIN placements p ON p.entitlement_id = e.id
      WHERE e.revoked = 0 AND e.slot IS NULL AND
        COALESCE(e.bound_space, p.space_id,
          (SELECT id FROM spaces WHERE scene_id = 'base_room')) = ?
      ORDER BY e.item_id
      ''',
      [space],
    );
    return [
      if (room['scene_id'] == 'base_room')
        for (final free in freeFurnishings.entries)
          {'item_id': free.key, 'asset_id': free.key, 'name': free.value},
      ...rows,
    ];
  }

  Future<Json?> displayRoom(String purchase) => db.row(
    '''SELECT s.* FROM entitlements e
       LEFT JOIN placements p ON p.entitlement_id = e.id
       JOIN spaces s ON s.id = COALESCE(e.bound_space, p.space_id,
         (SELECT id FROM spaces WHERE scene_id = 'base_room'))
       WHERE e.purchase_id = ? AND e.revoked = 0
       ORDER BY CASE WHEN s.scene_id = 'base_room' THEN 0 ELSE 1 END, e.item_id LIMIT 1''',
    [purchase],
  );

  Future<List<Json>> layout(String space) => db.rows(
    '''
    SELECT p.*, e.item_id, e.asset_id, e.name FROM placements p
    JOIN entitlements e ON e.id = p.entitlement_id WHERE p.space_id = ?
    UNION ALL
    SELECT id, space_id, x, y, 0, flipped, z, NULL, id, id, '' FROM base_furnishings
    WHERE space_id = ?
    ORDER BY z
    ''',
    [space, space],
  );

  Future<List<Json>> wardrobe(Companion pet) => db.rows(
    '''
    SELECT s.slot, s.entitlement_id, e.asset_id, e.name FROM pet_state s
    JOIN entitlements e ON e.id = s.entitlement_id
    WHERE s.pet_id = ?
    ''',
    [pet.name],
  );

  Future<Json> saveOutfit(
    Companion pet,
    Map<String, String> slots,
    int revision, {
    String? commandId,
  }) => _command('outfit', [pet.name, slots, revision], commandId, (
    _,
    family,
  ) async {
    if (family.revision != revision) throw const UserError('搭配数据已变化，请重新打开后保存。');
    for (final pair in slots.entries) {
      final owned = await db.row(
        'SELECT slot FROM entitlements WHERE id = ? AND revoked = 0',
        [pair.value],
      );
      if (owned == null || owned['slot'] != pair.key) {
        throw const UserError('请使用物品栏中适合此位置的衣饰。');
      }
    }
    await db.customStatement('DELETE FROM pet_state WHERE pet_id = ?', [
      pet.name,
    ]);
    for (final pair in slots.entries) {
      await db.insertRow('pet_state', {
        'pet_id': pet.name,
        'slot': pair.key,
        'entitlement_id': pair.value,
      });
    }
    return {'pet': pet.name};
  });

  Future<Json> renameSpace(
    String space,
    int version,
    String name, {
    String? commandId,
  }) =>
      _command('rename-space', [space, version, name], commandId, (_, _) async {
        final selected = await _spaceVersion(space, version);
        if (selected['scene_id'] == 'base_room') {
          throw const UserError('银杏家园使用固定名称。');
        }
        final title = textValue(name, 25, requiredLabel: '空间名称');
        await db.customStatement(
          'UPDATE spaces SET name = ?, layout_version = layout_version + 1 WHERE id = ?',
          [title, space],
        );
        return {'version': version + 1};
      });

  Future<Json> _spaceVersion(String space, int version) async {
    final saved = await db.row('SELECT * FROM spaces WHERE id = ?', [space]);
    if (saved == null) throw const UserError('找不到这个空间。');
    if (saved['layout_version'] != version) {
      throw const UserError('布局已变化，请重新打开后保存。');
    }
    return saved;
  }

  Future<Json> saveLayout(
    String space,
    int version,
    List<PlacementDraft> draft, {
    String? commandId,
  }) => _command(
    'layout',
    [space, version, draft.map((p) => p.encode()).toList()],
    commandId,
    (_, _) async {
      final selected = await _spaceVersion(space, version);
      final scene = SceneDefinition(rules, selected['scene_id'] as String);
      final owned = {
        for (final item in await items()) item['id'] as String: item,
      };
      if (draft.map((p) => p.id).toSet().length != draft.length ||
          draft
                  .where((p) => p.mount != null)
                  .map((p) => p.mount)
                  .toSet()
                  .length !=
              draft.where((p) => p.mount != null).length) {
        throw const UserError('每件物品和每个挂点只占一个位置。');
      }
      final moved = <String>{};
      for (final place in draft) {
        final item = owned[place.id];
        if (item == null) {
          final name = freeFurnishings[place.id];
          if (scene.id != 'base_room' || name == null) {
            throw const UserError('选中的物品已不在物品栏中。');
          }
          scene.validate(place, place.id, name);
        } else {
          if (item['slot'] != null ||
              (item['bound_space'] != null && item['bound_space'] != space)) {
            throw UserError('${item['name']} 只能在对应位置使用。');
          }
          final behavior = rules.catalog[item['item_id']];
          if (place.flipped && behavior?['supports_horizontal_flip'] == false) {
            throw UserError('${item['name']} 暂不支持镜像。');
          }
          scene.validate(
            place,
            item['asset_id'] as String,
            item['name'] as String,
          );
          final earlier = await db.value(
            'SELECT space_id FROM placements WHERE entitlement_id = ?',
            [place.id],
          ) as String?;
          if (earlier != null && earlier != space) moved.add(earlier);
        }
      }
      await db.customStatement('DELETE FROM placements WHERE space_id = ?', [
        space,
      ]);
      await db.customStatement(
        'DELETE FROM base_furnishings WHERE space_id = ?',
        [space],
      );
      for (final place in draft) {
        final row = {
          'space_id': space,
          'x': place.x,
          'y': place.y,
          'flipped': place.flipped ? 1 : 0,
          'z': place.z,
        };
        if (freeFurnishings.containsKey(place.id)) {
          await db.insertRow('base_furnishings', {...row, 'id': place.id});
        } else {
          await db.customStatement(
            'DELETE FROM placements WHERE entitlement_id = ?',
            [place.id],
          );
          await db.insertRow('placements', {
            ...row,
            'entitlement_id': place.id,
            'mount_id': place.mount,
          });
        }
      }
      for (final changed in {space, ...moved}) {
        await db.customStatement(
          'UPDATE spaces SET layout_version = layout_version + 1 WHERE id = ?',
          [changed],
        );
      }
      return {'version': version + 1};
    },
  );
}
