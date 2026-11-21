import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

part 'database.g.dart';

const companionSchemaVersion = 8;
const affinitySchemaVersion = 9;
const currentSchemaVersion = affinitySchemaVersion;
const legacyPurchaseIndexSql =
    'CREATE UNIQUE INDEX purchased_once ON purchases (item_id) WHERE refunded_at IS NULL';
const v2Indexes = [
  'ledger_day_kind_idx',
  'purchase_ledger_idx',
  'base_furnishings',
  'sqlite_autoindex_base_furnishings_1',
];

@DriftDatabase(include: {'schema.drift'})
class FamilyDatabase extends _$FamilyDatabase {
  FamilyDatabase(super.executor);

  factory FamilyDatabase.open(File file) => FamilyDatabase(
    NativeDatabase.createInBackground(file, setup: configureDatabase),
  );

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 1 || from >= to || to != currentSchemaVersion) {
        throw StateError('Unsupported SQLite upgrade');
      }
      await transaction(() async {
        if (from == 1) {
          await migrator.createIndex(ledgerDayKindIdx);
          await migrator.createIndex(purchaseLedgerIdx);
          await migrator.createTable(baseFurnishings);
        }
        if (from < 3) await migrator.createTable(windowMathBookmarks);
        // Version 4 derives experience from existing, verified completions.
        if (from < 5) await migrator.createTable(windowStoryMilestones);
        if (from < 6) await migrator.createTable(windStoryRuns);
        if (from < 7) {
          await migrator.createTable(rainMapRuns);
          await migrator.createTable(companionMemories);
        }
        if (from < companionSchemaVersion) {
          await migrator.createTable(ownedCompanions);
          await migrator.createIndex(oneStarterCompanion);
          await migrator.createTable(companionCompletions);
          await migrator.createIndex(companionCompletionPetIdx);
          // Old saves share one progress record. Keep it with the active pet.
          await customStatement('''
            INSERT INTO owned_companions(child_id, pet_id, retained_stage)
            SELECT c.id, c.active_pet_id, COALESCE(MAX(g.stage), 1)
            FROM child_profiles c LEFT JOIN growth_awards g ON g.child_id = c.id
            GROUP BY c.id
            ''');
          await customStatement('''
            INSERT INTO companion_completions(completion_id, child_id, pet_id)
            SELECT x.id, c.id, c.active_pet_id FROM completions x
            JOIN task_instances i ON i.id = x.instance_id
            JOIN task_templates t ON t.id = i.template_id
            JOIN child_profiles c ON c.family_id = t.family_id
            ''');
        }
        if (from < affinitySchemaVersion) {
          await migrator.createTable(companionAffinityDays);
          await migrator.createTable(companionCandies);
          await migrator.createIndex(candyRecipientIdx);
          await customStatement('DROP INDEX purchased_once');
          await migrator.createIndex(purchasedOnce);
          // Preserve the starting value from first memories without dating them.
          await customStatement('''
            INSERT INTO companion_affinity_days(child_id, pet_id, moment, local_day)
            SELECT m.child_id, m.pet_id, m.moment, '' FROM companion_memories m
            JOIN owned_companions p ON p.child_id = m.child_id AND p.pet_id = m.pet_id
            ''');
        }
      });
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<List<Map<String, Object?>>> rows(
    String sql, [
    List<Object?> parameters = const [],
  ]) async {
    final result = await customSelect(
      sql,
      variables: parameters.map((value) => Variable(value)).toList(),
    ).get();
    return result.map((row) => row.data).toList(growable: false);
  }

  Future<Map<String, Object?>?> row(
    String sql, [
    List<Object?> parameters = const [],
  ]) async {
    final result = await rows(sql, parameters);
    return result.singleOrNull;
  }

  Future<Object?> value(
    String sql, [
    List<Object?> parameters = const [],
  ]) async => (await row(sql, parameters))?.values.single;

  Future<void> insertRow(String table, Map<String, Object?> values) =>
      customStatement(
        'INSERT INTO $table (${values.keys.join(', ')}) VALUES '
        '(${List.filled(values.length, '?').join(', ')})',
        values.values.toList(),
      );
}

void configureDatabase(sqlite.Database database) {
  database.execute('PRAGMA trusted_schema = OFF');
  database.execute('PRAGMA foreign_keys = ON');
  database.execute('PRAGMA journal_mode = WAL');
  database.execute('PRAGMA synchronous = FULL');
}
