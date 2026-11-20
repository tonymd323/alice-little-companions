import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:alice_companions/application/family.dart';
import 'package:alice_companions/application/transfer.dart';
import 'package:alice_companions/data/snapshot.dart';
import 'package:alice_companions/domain/pin.dart';
import 'package:alice_companions/domain/rules.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'support/families.dart';

const _mib = 1024 * 1024;
const _draft = TaskDraft('测试任务A', '测试内容', '测试标准', 'focus');
final _date = DateTime.utc(2026, 11, 18);

void _log(String key, Object data) {
  // Synthetic counts and hashes only. Do not print credentials or row content.
  print('AC40 $key ${jsonEncode(data)}');
}

Set<String> _runtimeAssets() =>
    (jsonDecode(File('assets/config/runtime_assets.json').readAsStringSync())
            as Json)
        .entries
        .where((entry) => File(entry.value as String).existsSync())
        .map((entry) => entry.key)
        .toSet();

TransferService _transfer(TestFamily family, Set<String> assets) =>
    TransferService(
      device: family.device,
      rules: family.rules,
      availableAssets: assets,
      current: () => family.service,
    );

// Reuse the published 37-point fixture before expanding the stress data.
Future<void> _seedHistory(TestFamily source, ParentSession owner) async {
  final vector = jsonDecode(
    File('../../fixtures/migration_roundtrip.json').readAsStringSync(),
  ) as Json;
  final fixture = vector['domain_fixture'] as Json;
  for (final day in (fixture['reward_days'] as List).cast<Json>()) {
    for (final type in (day['approved_task_types'] as List).cast<String>()) {
      await source.service.backfill(
        TaskDraft('测试任务A', '测试内容', '测试标准', type),
        day['actual_date'] as String,
        '测试反馈',
        session: owner,
      );
    }
  }
  for (final item
      in (fixture['purchased_catalog_ids'] as List).cast<String>()) {
    await source.service.purchase(item);
  }
  await source.service.setWish(fixture['selected_wish'] as String);
  final initial = (await source.service.overview())!;
  expect(initial.balance, 37);
  for (var i = initial.experience; i < source.rules.thresholds.last; i++) {
    await source.service.backfill(
      _draft,
      source.service.today,
      '',
      session: owner,
    );
  }
}

String _syntheticText(Random random, String prefix, int count) =>
    '$prefix${String.fromCharCodes(List.generate(count, (_) => 0x4e00 + random.nextInt(2048)))}';

String _fixtureId(int record, int kind) =>
    '00000000-0000-4000-b000-${(record * 6 + kind).toString().padLeft(12, '0')}';

// Generate complete backfill records in an isolated test database. Keep the
// same task/version/instance/completion/ledger/command relationships as backfill.
void _expandHistory(String path, int start, int count, int stage, int reward) {
  final db = sqlite3.open(path);
  try {
    db.execute('PRAGMA foreign_keys = ON');
    final family = db.select('SELECT id, rules_version FROM households').single;
    final account = db.select('SELECT id, balance FROM accounts').single;
    final statements = <PreparedStatement>[];
    PreparedStatement insert(String sql) {
      final statement = db.prepare(sql);
      statements.add(statement);
      return statement;
    }

    final template = insert('''
      INSERT INTO task_templates(id, family_id, mode) VALUES (?, ?, 'once')
    ''');
    final version = insert('''
      INSERT INTO task_versions(id, template_id, version, title, content,
        criteria, task_type, reward, rules_version, schedule_json)
      VALUES (?, ?, 1, ?, ?, ?, 'focus', ?, ?, '{}')
    ''');
    final task = insert('''
      INSERT INTO task_instances(id, instance_key, template_id, version_id,
        planned_day, state, actual_date, approved_at)
      VALUES (?, ?, ?, ?, ?, 'APPROVED', ?, ?)
    ''');
    final completion = insert('''
      INSERT INTO completions(id, instance_id, actual_date, feedback,
        approval_command_id) VALUES (?, ?, ?, ?, ?)
    ''');
    final ledger = insert('''
      INSERT INTO ledger_entries(id, account_id, delta, balance_after, kind,
        source_key, actual_date, posted_day, created_at, command_id)
      VALUES (?, ?, ?, ?, 'reward', ?, ?, ?, ?, ?)
    ''');
    final command = insert('''
      INSERT INTO processed_commands(id, payload_hash, result_json, created_at)
      VALUES (?, ?, ?, ?)
    ''');
    var balance = account['balance'] as int;
    final posted = dateKey(_date);
    db.execute('BEGIN IMMEDIATE');
    try {
      for (var i = start; i < start + count; i++) {
        final random = Random(20261120 + i);
        final draft = TaskDraft(
          '测试任务A',
          _syntheticText(random, '测试内容', 470),
          _syntheticText(random, '测试标准', 280),
          'focus',
        );
        final feedback = _syntheticText(random, '测试反馈', 460);
        final actual = dateKey(_date.subtract(Duration(days: 1 + i ~/ 6)));
        final time = _date.millisecondsSinceEpoch + i;
        final templateId = _fixtureId(i, 0);
        final versionId = _fixtureId(i, 1);
        final taskId = _fixtureId(i, 2);
        final completionId = _fixtureId(i, 3);
        final ledgerId = _fixtureId(i, 4);
        final commandId = _fixtureId(i, 5);
        balance += reward;
        template.execute([templateId, family['id']]);
        version.execute([
          versionId,
          templateId,
          draft.title,
          draft.content,
          draft.criteria,
          reward,
          family['rules_version'],
        ]);
        task.execute([
          taskId,
          taskId,
          templateId,
          versionId,
          actual,
          actual,
          time,
        ]);
        completion.execute([completionId, taskId, actual, feedback, commandId]);
        ledger.execute([
          ledgerId,
          account['id'],
          reward,
          balance,
          'reward:$taskId',
          actual,
          posted,
          time,
          commandId,
        ]);
        final hash = sha256
            .convert(
              utf8.encode(
                jsonEncode([
                  'backfill',
                  family['id'],
                  [draft.encode(), actual, feedback, null],
                ]),
              ),
            )
            .toString();
        command.execute([
          commandId,
          hash,
          jsonEncode({
            'id': ledgerId,
            'balance': balance,
            'delta': reward,
            'experience_delta': 1,
            'previous_stage': stage,
            'new_stage': false,
            'stage': stage,
            'instance_id': taskId,
          }),
          time,
        ]);
      }
      db.execute('UPDATE accounts SET balance = ?', [balance]);
      db.execute(
        'UPDATE households SET domain_revision = domain_revision + ?',
        [count],
      );
      db.execute('COMMIT');
    } catch (_) {
      db.execute('ROLLBACK');
      rethrow;
    } finally {
      for (final statement in statements) {
        statement.close();
      }
    }
  } finally {
    db.close();
  }
}

Future<void> _expandInWorker(
  String dbPath,
  int start,
  int count,
  int stage,
  int reward,
) => Isolate.run(() => _expandHistory(dbPath, start, count, stage, reward));

Future<int> _fillFixture(TestFamily source, File snapshot) async {
  var rows = 0;
  var nextBatch = 5000;
  var previousBytes = 0;
  final dbPath = source.device.databaseFile(source.service.pin.generation).path;
  final stage = 1 + source.rules.thresholds.length;
  final reward = source.rules.type('focus').points;
  while (true) {
    await source.service.serial.run(() async {
      final start = rows;
      final count = nextBatch;
      await _expandInWorker(dbPath, start, count, stage, reward);
      if (await snapshot.exists()) await snapshot.delete();
      await source.service.db.customStatement('VACUUM INTO ?', [snapshot.path]);
    });
    rows += nextBatch;
    final bytes = await snapshot.length();
    _log('calibration', {'generated_rows': rows, 'snapshot_bytes': bytes});
    if (bytes >= 50 * _mib - (_mib ~/ 4)) {
      expect(bytes, lessThanOrEqualTo(50 * _mib + (_mib ~/ 4)));
      return rows;
    }
    final perRow = (bytes - previousBytes) / nextBatch;
    previousBytes = bytes;
    nextBatch = ((50 * _mib - bytes) / perRow).floor().clamp(1, 2000);
  }
}

class _Timing {
  final _clock = Stopwatch()..start();
  final _starts = <({String phase, int millis})>[];

  late final operation = TransferOperation((phase) {
    _starts.add((phase: phase.name, millis: _clock.elapsedMilliseconds));
  });

  Json finish() {
    _clock.stop();
    final total = _clock.elapsedMilliseconds;
    return {
      'total_ms': total,
      'preparing_ms': _starts.isEmpty ? total : _starts.first.millis,
      'phases_ms': {
        for (var i = 0; i < _starts.length; i++)
          _starts[i].phase:
              (i + 1 == _starts.length ? total : _starts[i + 1].millis) -
              _starts[i].millis,
      },
    };
  }
}

void main() {
  test(
    'AC-40 Linux baseline for a 50 MiB encrypted backup and restoration',
    () async {
      final source = await TestFamily.create(now: () => _date);
      addTearDown(source.dispose);
      final target = await TestFamily.create(now: () => _date);
      addTearDown(target.dispose);
      expect(source.root.path, isNot(target.root.path));
      final targetBefore = await target.device.activeGeneration();
      final sourceOwner = (await source.service.pin.unlock(TestFamily.pin))!;
      final targetOwner = await target.service.pin.unlock(TestFamily.pin);
      await _seedHistory(source, sourceOwner);
      await target.service.backfill(
        _draft,
        target.service.today,
        '',
        session: targetOwner,
      );

      final assets = _runtimeAssets();
      final exporter = _transfer(source, assets);
      final importer = _transfer(target, assets);
      final transit = await Directory.systemTemp.createTemp(
        'alice-50m-benchmark-',
      );
      addTearDown(() async => transit.delete(recursive: true));
      final preflight = File(p.join(transit.path, 'preflight.sqlite'));
      final syntheticCount = await _fillFixture(source, preflight);
      final sourceBytes = await preflight.length();
      final original = await checkSnapshot(
        preflight.path,
        await exporter.schema,
        source.rules,
        assets,
      );
      final sqlite = sqlite3.open(preflight.path, mode: OpenMode.readOnly);
      final sqliteVersion = sqlite
          .select('SELECT sqlite_version() as version')
          .single['version']!;
      sqlite.close();
      await preflight.delete();
      _log('fixture', {
        'sqlite': sqliteVersion,
        'dart': Platform.version,
        'snapshot_bytes': sourceBytes,
        'schema': original.schemaVersion,
        'revision': original.revision,
        'seeded_backfill_extensions': syntheticCount,
        'summary': original.summary,
        'digest': original.businessDigest,
      });

      final passphrase = PinGate.newRecoveryCode();
      final exportTime = _Timing();
      final ticket = await exporter.prepareExport(
        'backup',
        passphrase,
        sourceOwner,
        operation: exportTime.operation,
      );
      final exported = exportTime.finish();
      _log('export', exported);
      final handoff = Stopwatch()..start();
      final external = await ticket.file.copy(
        p.join(transit.path, ticket.name),
      );
      await exporter.finishExport(ticket, SaveOutcome.handedToSystem);
      handoff.stop();
      _log('handoff', {
        'local_copy_and_receipt_ms': handoff.elapsedMilliseconds,
        'container_bytes': await external.length(),
      });

      final restoreTotal = Stopwatch()..start();
      final inspectTime = _Timing();
      final preview = await importer.inspect(
        external,
        passphrase,
        targetOwner,
        operation: inspectTime.operation,
      );
      addTearDown(preview.close);
      final inspected = inspectTime.finish();
      final protectionTime = _Timing();
      final protection = await importer.protectCurrent(
        targetOwner,
        operation: protectionTime.operation,
      );
      final protected = protectionTime.finish();
      final activateTime = Stopwatch()..start();
      final activation = await importer.activate(
        preview,
        TestFamily.pin,
        PinGate.newRecoveryCode(),
        session: targetOwner,
        replace: true,
        protection: protection,
      );
      activateTime.stop();
      restoreTotal.stop();
      addTearDown(activation.service.close);
      _log('restore', {
        'total_ms': restoreTotal.elapsedMilliseconds,
        'preview': inspected,
        'protect_target': protected,
        'activate_ms': activateTime.elapsedMilliseconds,
      });

      final targetAfter = (await target.device.activeGeneration())!;
      expect(targetAfter, isNot(targetBefore));
      final restored = await checkSnapshot(
        target.device.databaseFile(targetAfter).path,
        await importer.schema,
        target.rules,
        assets,
      );
      expect(await preview.database.length(), sourceBytes);
      expect(preview.info.summary, original.summary);
      expect(restored.summary, original.summary);
      expect(restored.businessDigest, original.businessDigest);
      expect(preview.info.businessDigest, original.businessDigest);
      expect(
        (await source.service.overview())!.balance,
        original.summary['balance'],
      );
      await activation.service.verifyAccounting();
      _log('verification', {
        'restored_snapshot_bytes': await preview.database.length(),
        'activated_target_digest': restored.businessDigest,
        'same_summary': true,
        'same_business_digest': true,
        'target_generation_switched': true,
        'source_balance_preserved': true,
      });
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
