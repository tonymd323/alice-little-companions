import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

part 'database.g.dart';

const currentSchemaVersion = 3;
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
        await migrator.createTable(windowMathBookmarks);
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
