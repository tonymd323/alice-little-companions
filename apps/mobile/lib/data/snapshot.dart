import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';

import '../domain/companion_food.dart';
import '../domain/companions.dart';
import '../domain/layout_rules.dart';
import '../domain/pin.dart';
import '../domain/rules.dart';
import 'database.dart';

const schemaQuery = '''
  SELECT type, name, tbl_name, sql FROM sqlite_schema ORDER BY type, name
''';
const _v7Tables = {'rain_map_runs', 'companion_memories'};
const _v8Tables = {'owned_companions', 'companion_completions'};
const _v9Tables = {'companion_affinity_days', 'companion_candies'};

class SnapshotInfo {
  const SnapshotInfo({
    required this.schemaVersion,
    required this.family,
    required this.summary,
    required this.assets,
  });

  final int schemaVersion;
  final Json family;
  final Json summary;
  final Set<String> assets;

  String get nickname => family['nickname'] as String;
  int get revision => family['domain_revision'] as int;
}

class Snapshot extends SnapshotInfo {
  Snapshot(SnapshotInfo info, this.businessDigest)
    : super(
        schemaVersion: info.schemaVersion,
        family: info.family,
        summary: info.summary,
        assets: info.assets,
      );

  final String businessDigest;
}

Future<List<Json>> expectedSchema() async {
  final database = FamilyDatabase(NativeDatabase.memory());
  try {
    return await database.rows(schemaQuery);
  } finally {
    await database.close();
  }
}

Future<int> inspectSchemaVersion(String path) => Isolate.run(() {
  final db = sqlite3.open(path, mode: OpenMode.readOnly);
  try {
    db.execute('PRAGMA trusted_schema = OFF');
    return db.userVersion;
  } finally {
    db.close();
  }
});

Future<void> vacuumFile(String original, String output) => Isolate.run(() {
  final db = sqlite3.open(original, mode: OpenMode.readOnly);
  try {
    db.execute('PRAGMA trusted_schema = OFF');
    db.execute('VACUUM INTO ?', [output]);
  } finally {
    db.close();
  }
});

/// Checks the SQLite schema and business rules before packaging a snapshot.
Future<SnapshotInfo> validateSnapshot(
  String path,
  List<Json> schema,
  Rules rules,
  Set<String> available,
) => Isolate.run(
  () => _check(path, schema, rules, available, (_, _, info) => info),
);

Future<Snapshot> checkSnapshot(
  String path,
  List<Json> schema,
  Rules rules,
  Set<String> available, {
  int compareWithSchemaVersion = currentSchemaVersion,
}) => Isolate.run(
  () => _check(
    path,
    schema,
    rules,
    available,
    (db, tables, info) =>
        Snapshot(info, _businessDigest(db, tables, compareWithSchemaVersion)),
    compareLegacyCompanions: compareWithSchemaVersion < companionSchemaVersion,
  ),
);

T _check<T>(
  String path,
  List<Json> schema,
  Rules rules,
  Set<String> available,
  T Function(Database db, List<Json> schema, SnapshotInfo info) finish, {
  bool compareLegacyCompanions = false,
}) {
  final db = sqlite3.open(path, mode: OpenMode.readOnly);
  try {
    db.execute('PRAGMA trusted_schema = OFF');
    db.execute('PRAGMA query_only = ON');
    db.execute('PRAGMA foreign_keys = ON');
    final version = db.userVersion;
    if (version < 1 || version > currentSchemaVersion) {
      throw const UserError('此存档结构需要兼容版本的 App。');
    }
    final expected = schema
        .where(
          (row) =>
              version >= affinitySchemaVersion ||
              !_v9Tables.contains(row['tbl_name']),
        )
        .where(
          (row) =>
              version >= companionSchemaVersion ||
              !_v8Tables.contains(row['tbl_name']),
        )
        .where((row) => version >= 7 || !_v7Tables.contains(row['tbl_name']))
        .where((row) => version >= 6 || row['tbl_name'] != 'wind_story_runs')
        .where(
          (row) => version >= 5 || row['tbl_name'] != 'window_story_milestones',
        )
        .where((row) => version != 1 || !v2Indexes.contains(row['name']))
        .where(
          (row) => version >= 3 || row['tbl_name'] != 'window_math_bookmarks',
        )
        .map((row) {
          if (version < foodSchemaVersion && row['name'] == 'purchased_once') {
            return {
              ...row,
              'sql': version < affinitySchemaVersion
                  ? legacyPurchaseIndexSql
                  : candyPurchaseIndexSql,
            };
          }
          final sql = row['sql'];
          if (version >= expandedRosterSchemaVersion ||
              sql is! String ||
              !sql.contains(expandedCompanionCheck)) {
            return row;
          }
          return {
            ...row,
            'sql': sql.replaceAll(
              expandedCompanionCheck,
              originalCompanionCheck,
            ),
          };
        })
        .toList();
    final actual = db
        .select(schemaQuery)
        .map((row) => Map<String, Object?>.from(row))
        .toList();
    if (jsonEncode(actual) != jsonEncode(expected)) {
      throw const UserError('存档结构不符合支持的版本。');
    }
    if (db
                .select('PRAGMA integrity_check')
                .map((r) => r.values.single)
                .join() !=
            'ok' ||
        db.select('PRAGMA foreign_key_check').isNotEmpty) {
      throw const UserError('存档完整性校验失败。');
    }
    Object? scalar(String sql) => db.select(sql).single.values.single;
    bool invalid(String sql) => db.select(sql).isNotEmpty;

    if (version >= 6 &&
        invalid('''
          SELECT 1 FROM wind_story_runs w
          WHERE (w.leaf_mask = 31 OR w.run_number > 1) AND NOT EXISTS (
            SELECT 1 FROM window_story_milestones m WHERE m.child_id = w.child_id
          )
        ''')) {
      throw const UserError('暖廊的修复记录与窗格进度不一致。');
    }
    if (version >= 7 &&
        invalid("""
          SELECT 1 FROM rain_map_runs r
          WHERE NOT EXISTS (
            SELECT 1 FROM window_story_milestones m WHERE m.child_id = r.child_id
          ) AND NOT EXISTS (
            SELECT 1 FROM window_math_bookmarks b
            WHERE b.child_id = r.child_id AND b.page IN ('sunny','puzzle','finished')
          )
        """)) {
      throw const UserError('雨天地图缺少前一章的修窗记录。');
    }

    final parent = db.select('''
      SELECT h.*, c.id AS child_id, c.nickname, c.active_pet_id, a.balance FROM households h
      JOIN child_profiles c ON c.family_id = h.id JOIN accounts a ON a.child_id = c.id
      ''');
    if (parent.length != 1) throw const UserError('存档必须包含一份完整家庭。');
    final family = Map<String, Object?>.from(parent.single);
    if (family['rules_version'] != rules.version ||
        family['catalog_version'] != rules.catalogVersion ||
        family['timezone'] != rules.timezone) {
      throw const UserError('备份使用的规则或目录需要兼容版本。');
    }
    final Iterable<Json> companions = version < companionSchemaVersion
        ? <Json>[]
        : db.select('''
          SELECT p.*, COUNT(x.completion_id) AS assigned,
            COUNT(CASE WHEN a.is_valid = 1 THEN 1 END) AS experience
          FROM owned_companions p
          LEFT JOIN companion_completions x ON x.child_id = p.child_id AND x.pet_id = p.pet_id
          LEFT JOIN completions a ON a.id = x.completion_id
          GROUP BY p.child_id, p.pet_id
          ''');
    final companionPurchases = {
      for (final companion in companions)
        if (companion['purchase_id'] != null)
          companion['purchase_id']: rules.companion(
            companion['pet_id'] as String,
          ),
    };
    final foodPurchases = {
      if (version >= affinitySchemaVersion)
        for (final food in db.select('SELECT * FROM companion_candies'))
          food['purchase_id']: food,
    };

    var balance = 0;
    var ledgerCount = 0;
    for (final row in db.select(
      'SELECT delta, balance_after, kind FROM ledger_entries ORDER BY rowid',
    )) {
      final change = row['delta'] as int;
      balance += change;
      ledgerCount++;
      final validSign = switch (row['kind']) {
        'reward' || 'refund' => change > 0,
        'purchase' => change < 0,
        'penalty' || 'correction' => change <= 0,
        'penalty_reversal' => change >= 0,
        _ => false,
      };
      if (!validSign || balance < 0 || balance != row['balance_after']) {
        throw const UserError('积分流水校验失败。');
      }
    }
    if (balance != family['balance']) throw const UserError('积分余额与流水不一致。');

    if (invalid("""
      SELECT i.id
      FROM task_instances i
      JOIN task_versions v ON v.id = i.version_id
      LEFT JOIN project_stages g ON g.id = i.stage_id
      LEFT JOIN completions c ON c.instance_id = i.id
      LEFT JOIN ledger_entries l ON l.source_key = 'reward:' || i.id AND l.kind = 'reward'
      LEFT JOIN correction_records r ON r.instance_id = i.id
      WHERE v.template_id != i.template_id OR (g.id IS NOT NULL AND g.version_id != i.version_id)
        OR (i.state IN ('APPROVED','CORRECTED') AND
            (c.id IS NULL OR l.id IS NULL OR l.delta != COALESCE(g.reward, v.reward)
             OR c.actual_date != i.actual_date OR l.actual_date != i.actual_date
             OR (i.state = 'APPROVED' AND (c.is_valid != 1 OR r.instance_id IS NOT NULL))
             OR (i.state = 'CORRECTED' AND (c.is_valid != 0 OR r.instance_id IS NULL OR r.original_reward_id != l.id
                  OR r.recovered + r.shortfall != l.delta))))
        OR (i.state NOT IN ('APPROVED','CORRECTED') AND (c.id IS NOT NULL OR l.id IS NOT NULL))
      LIMIT 1
      """) ||
        invalid("""
      SELECT p.id FROM purchases p JOIN ledger_entries l ON l.id = p.ledger_id
      LEFT JOIN ledger_entries r ON r.reversal_of = l.id
      WHERE l.delta != -p.price_paid OR l.kind != 'purchase'
        OR (p.refunded_at IS NULL AND r.id IS NOT NULL)
        OR (p.refunded_at IS NOT NULL AND (r.id IS NULL OR r.kind != 'refund' OR r.delta != p.price_paid))
      LIMIT 1
      """) ||
        invalid("""
      SELECT e.id FROM entitlements e JOIN purchases p ON p.id = e.purchase_id
      LEFT JOIN spaces s ON s.id = e.bound_space
      WHERE (e.revoked = 0) != (p.refunded_at IS NULL)
        OR (s.id IS NOT NULL AND s.purchase_id != e.purchase_id)
      LIMIT 1
      """) ||
        invalid("""
      SELECT x.entitlement_id FROM placements x JOIN entitlements e ON e.id = x.entitlement_id
      WHERE e.revoked != 0 OR e.slot IS NOT NULL
        OR (e.bound_space IS NOT NULL AND e.bound_space != x.space_id)
      LIMIT 1
      """) ||
        invalid("""
      SELECT p.entitlement_id FROM pet_state p JOIN entitlements e ON e.id = p.entitlement_id
      WHERE e.revoked != 0 OR e.slot IS NULL OR e.slot != p.slot
      LIMIT 1
      """) ||
        invalid("""
      SELECT e.id FROM penalty_events e JOIN ledger_entries l ON l.id = e.ledger_id
      LEFT JOIN penalty_day_usage u ON u.posted_day = e.posted_day
      WHERE l.kind != 'penalty' OR l.delta != -e.deducted OR l.posted_day != e.posted_day OR u.used IS NULL
      LIMIT 1
      """) ||
        invalid("""
      SELECT u.posted_day FROM penalty_day_usage u
      WHERE used != COALESCE((SELECT SUM(deducted) FROM penalty_events e WHERE e.posted_day = u.posted_day), 0)
      LIMIT 1
      """) ||
        invalid("""
      SELECT id FROM ledger_entries l WHERE
      (l.kind = 'reward' AND l.source_key NOT IN (
        SELECT 'reward:' || c.instance_id FROM completions c
      ))
      OR (l.kind = 'purchase' AND NOT EXISTS (SELECT 1 FROM purchases p WHERE p.ledger_id = l.id))
      OR (l.kind = 'penalty' AND NOT EXISTS (SELECT 1 FROM penalty_events p WHERE p.ledger_id = l.id))
      OR (l.kind = 'correction' AND NOT EXISTS (SELECT 1 FROM correction_records c
          WHERE c.original_reward_id = l.reversal_of AND l.delta = -c.recovered))
      OR (l.kind = 'refund' AND NOT EXISTS (SELECT 1 FROM purchases p WHERE p.ledger_id = l.reversal_of AND p.refunded_at IS NOT NULL))
      OR (l.kind = 'penalty_reversal' AND NOT EXISTS (SELECT 1 FROM penalty_events e
          WHERE e.ledger_id = l.reversal_of AND e.deducted = l.delta))
      LIMIT 1
      """)) {
      throw const UserError('存档的成果、兑换或布置关联校验失败。');
    }

    final assets = <String>{
      for (final pet
          in version >= expandedRosterSchemaVersion
              ? Companion.values
              : Companion.starters)
        for (var stage = 1; stage <= 6; stage++) 'pet_${pet.name}_$stage',
      'pet_cat_4_rest',
    };
    for (final place in db.select('SELECT scene_id, purchase_id FROM spaces')) {
      final name = place['scene_id'] as String;
      if (!rules.scenes.containsKey(name) ||
          (name == 'base_room') != (place['purchase_id'] == null)) {
        throw const UserError('备份中的空间需要兼容的目录。');
      }
      assets.add('scene_${name}_background');
      // v1 and early v2 backup containers do not list optional foreground art.
    }
    if (scalar("SELECT COUNT(*) FROM spaces WHERE scene_id = 'base_room'") !=
        1) {
      throw const UserError('备份缺少基础家园。');
    }
    for (final purchase in db.select('SELECT * FROM purchases')) {
      final owned = db.select(
        'SELECT * FROM entitlements WHERE purchase_id = ?',
        [purchase['id']],
      );
      final spaces = db.select(
        'SELECT scene_id FROM spaces WHERE purchase_id = ?',
        [purchase['id']],
      );
      final companion = companionPurchases[purchase['id']];
      final food = CompanionFood.forItem(purchase['item_id']);
      if (food != null) {
        final serving = foodPurchases.remove(purchase['id']);
        if (serving == null ||
            (version < foodSchemaVersion && food != CompanionFood.candy) ||
            serving['child_id'] != family['child_id'] ||
            purchase['asset_id'] != food.itemId ||
            (serving['pet_id'] != null && purchase['refunded_at'] != null) ||
            owned.isNotEmpty ||
            spaces.isNotEmpty ||
            companion != null) {
          throw const UserError('备份的食物记录有误。');
        }
        continue;
      }
      if (companion != null) {
        if (purchase['item_id'] != companion.unlockItemId ||
            purchase['asset_id'] != companion.firstStageAssetId ||
            purchase['refunded_at'] != null ||
            owned.isNotEmpty ||
            spaces.isNotEmpty) {
          throw const UserError('备份的伙伴兑换有误。');
        }
        continue;
      }
      final item = rules.catalog[purchase['item_id']];
      if (item == null || purchase['asset_id'] != item['asset_id']) {
        throw const UserError('备份中的兑换需要兼容的目录。');
      }
      assets.add(item['asset_id'] as String);
      final parts = (item['included_items'] as List?)?.cast<Json>() ?? [item];
      if (owned.length != parts.length ||
          (purchase['refunded_at'] == null && item['space_id'] != null
              ? spaces.length != 1 ||
                    spaces.single['scene_id'] != item['space_id']
              : spaces.isNotEmpty)) {
        throw const UserError('备份的兑换组件或空间数量有误。');
      }
      for (final part in owned) {
        final found = parts
            .where((p) => p['id'] == part['item_id'])
            .singleOrNull;
        if (found == null ||
            found['asset_id'] != part['asset_id'] ||
            found['slot'] != part['slot'] ||
            (part['revoked'] == 0 &&
                found['bound_to_container'] == true &&
                part['bound_space'] == null)) {
          throw const UserError('备份的物品清单有误。');
        }
        assets.add(part['asset_id'] as String);
      }
    }
    if (foodPurchases.isNotEmpty) {
      throw const UserError('备份的食物关联有误。');
    }
    for (final row in db.select("""
      SELECT x.*, s.scene_id, e.asset_id, e.name FROM placements x
      JOIN entitlements e ON e.id = x.entitlement_id JOIN spaces s ON s.id = x.space_id
      """)) {
      final place = Map<String, Object?>.from(row);
      final scene = SceneDefinition(rules, row['scene_id'] as String);
      if (row['rotation'] != 0) throw const UserError('备份包含当前版本无法显示的物品方向。');
      scene.validate(
        PlacementDraft.fromRow(place),
        row['asset_id'] as String,
        row['name'] as String,
      );
    }
    if (version >= 2) {
      for (final row in db.select(
        'SELECT f.id, s.scene_id FROM base_furnishings f JOIN spaces s ON s.id = f.space_id',
      )) {
        if (row['scene_id'] != 'base_room') {
          throw const UserError('免费家具应保留在银杏家园。');
        }
        assets.add(row['id'] as String);
      }
    }
    if (!available.containsAll(assets)) {
      throw const UserError('当前版本缺少备份所需素材，原数据保留。');
    }
    for (final wish in db.select('SELECT item_id FROM wishes')) {
      if (!rules.catalog.containsKey(wish['item_id'])) {
        throw const UserError('备份的心愿缺少目录条目。');
      }
    }
    final growth = db.select(
      'SELECT threshold, stage FROM growth_awards ORDER BY stage',
    );
    for (final (index, award) in growth.indexed) {
      if (index >= rules.thresholds.length ||
          award['stage'] != index + 2 ||
          award['threshold'] != rules.thresholds[index]) {
        throw const UserError('备份的伙伴成长有误。');
      }
    }
    final validCompletions =
        scalar('SELECT COUNT(*) FROM completions WHERE is_valid = 1') as int;
    final recordedStage = 1 + growth.length;
    final summary = <String, Object?>{
      'balance': balance,
      'ledger_count': ledgerCount,
      'valid_completion_count': validCompletions,
      'owned_item_count': scalar(
        'SELECT COUNT(*) FROM entitlements WHERE revoked = 0',
      ),
      'space_count': scalar('SELECT COUNT(*) FROM spaces'),
      'max_growth_stage': version >= 4
          ? max(recordedStage, rules.earnedStage(validCompletions))
          : recordedStage,
    };
    if (version >= companionSchemaVersion) {
      final starters = companions.where((pet) => pet['purchase_id'] == null);
      final active = companions
          .where((pet) => pet['pet_id'] == family['active_pet_id'])
          .singleOrNull;
      final assigned = companions.fold(
        0,
        (count, pet) => count + (pet['assigned'] as int),
      );
      if (starters.length != 1 ||
          !Companion.starters.contains(
            rules.companion(starters.single['pet_id'] as String),
          ) ||
          active == null ||
          assigned != scalar('SELECT COUNT(*) FROM completions') ||
          starters.single['retained_stage'] as int < recordedStage ||
          (compareLegacyCompanions &&
              (companions.length != 1 ||
                  active['retained_stage'] != recordedStage))) {
        throw const UserError('备份的伙伴归属或成长记录有误。');
      }
      for (final pet in companions) {
        final legacyStage = pet['purchase_id'] == null ? recordedStage : 1;
        if (pet['child_id'] != family['child_id'] ||
            pet['retained_stage'] as int >
                max(legacyStage, rules.earnedStage(pet['assigned'] as int))) {
          throw const UserError('备份的伙伴成长有误。');
        }
      }
      final experience = active['experience'] as int;
      summary['active_companion_experience'] = experience;
      summary['owned_companion_count'] = companions.length;
      summary['max_growth_stage'] = max(
        active['retained_stage'] as int,
        rules.earnedStage(experience),
      );
    }

    return finish(
      db,
      actual,
      SnapshotInfo(
        schemaVersion: version,
        family: family,
        summary: summary,
        assets: assets,
      ),
    );
  } on UserError {
    rethrow;
  } catch (_) {
    throw const UserError('存档无法通过 SQLite 校验。');
  } finally {
    db.close();
  }
}

String _businessDigest(
  Database db,
  List<Json> schema,
  int compareWithSchemaVersion,
) {
  // Feed each row separately to avoid keeping a second copy of the database.
  final sink = _DigestResult();
  final content = sha256.startChunkedConversion(sink);
  for (final row in schema.where((row) => row['type'] == 'table')) {
    final table = row['name'] as String;
    if (compareWithSchemaVersion < affinitySchemaVersion &&
        _v9Tables.contains(table)) {
      continue;
    }
    if (compareWithSchemaVersion < companionSchemaVersion &&
        _v8Tables.contains(table)) {
      continue;
    }
    final records = db.select('SELECT * FROM "$table" ORDER BY rowid');
    if (records.isEmpty &&
        (table == 'base_furnishings' ||
            table == 'window_math_bookmarks' ||
            table == 'window_story_milestones' ||
            table == 'wind_story_runs' ||
            _v7Tables.contains(table))) {
      continue;
    }
    content.add(utf8.encode('$table\n'));
    for (final record in records) {
      content.add(utf8.encode('${jsonEncode(record)}\n'));
    }
  }
  content.close();
  return sink.digest.toString();
}

class _DigestResult implements Sink<Digest> {
  late Digest digest;
  @override
  void add(Digest data) => digest = data;
  @override
  void close() {}
}

Future<void> cleanDirectory(Directory directory) async {
  if (await directory.exists()) await directory.delete(recursive: true);
}
