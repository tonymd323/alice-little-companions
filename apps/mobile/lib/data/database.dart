import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

part 'database.g.dart';

@DriftDatabase(include: {'schema.drift'})
class FamilyDatabase extends _$FamilyDatabase {
  FamilyDatabase(super.executor);

  factory FamilyDatabase.open(File file) => FamilyDatabase(
    NativeDatabase.createInBackground(file, setup: configureDatabase),
  );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
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
