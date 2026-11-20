import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:alice_companions/application/family.dart';
import 'package:alice_companions/application/transfer.dart';
import 'package:alice_companions/data/device.dart';
import 'package:alice_companions/data/snapshot.dart';
import 'package:alice_companions/domain/backup_codec.dart';
import 'package:alice_companions/domain/pin.dart';
import 'package:alice_companions/domain/rules.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/families.dart';

const _password = 'Alice-QA-Fixture-019';
const _fixtureHash =
    '643685960f3204669bfa0d1e8ceb04c59b546fd7790876dcdf8c4439fb599c44';
const _upgradedDigest =
    'f0de750306457d56435a4e79d90b1ef5b4ae08510d91678db42516f69ffe0210';

void _log(String stage, Object details) {
  stdout.writeln('AC40 $stage ${jsonEncode(details)}');
}

Future<void> _cancelDuring<T>(
  String label,
  TransferPhase target,
  Future<T> Function(TransferOperation) start, {
  void Function()? entered,
}) async {
  final phases = <String>[];
  Stopwatch? cancelled;
  Timer? timer;
  late final TransferOperation operation;
  operation = TransferOperation((phase) {
    phases.add(phase.name);
    if (phase != target) return;
    entered?.call();
    timer = Timer(const Duration(seconds: 1), () {
      cancelled = Stopwatch()..start();
      operation.cancel();
    });
  });
  try {
    await expectLater(start(operation), throwsA(isA<TransferCancelled>()));
    expect(cancelled, isNotNull);
    expect(phases.last, target.name);
    _log(label, {
      'phases': phases,
      'one_second_after_phase_started': true,
      'cancel_to_return_ms': cancelled!.elapsedMilliseconds,
    });
  } finally {
    timer?.cancel();
  }
}

void main() {
  test('published 50 MiB family survives cancelling large transfers', () async {
    final fixture = File(Platform.environment['ALICE_QA_INPUT_FILE']!);
    expect(await fileHash(fixture), _fixtureHash);
    final root = await Directory.systemTemp.createTemp('alice-ac40-');
    final device = DeviceStore(root, MemorySecureValues());
    final rules = Rules.decode(
      File('assets/config/rules.json').readAsStringSync(),
      File('assets/config/catalog.json').readAsStringSync(),
      File('assets/config/scene_slots.json').readAsStringSync(),
    );
    final assets =
        (jsonDecode(
              File('assets/config/runtime_assets.json').readAsStringSync(),
            ) as Json).entries
            .where((asset) => File(asset.value as String).existsSync())
            .map((asset) => asset.key)
            .toSet();
    FamilyService? active;
    addTearDown(() async {
      await active?.close();
      await root.delete(recursive: true);
    });
    final transfer = TransferService(
      device: device,
      rules: rules,
      availableAssets: assets,
      current: () => active,
    );
    final firstPreviewClock = Stopwatch()..start();
    final preview = await transfer.inspect(fixture, _password, null);
    final firstPreviewMs = firstPreviewClock.elapsedMilliseconds;
    final activationClock = Stopwatch()..start();
    final restored = await transfer.activate(
      preview,
      TestFamily.pin,
      PinGate.newRecoveryCode(),
      session: null,
      replace: false,
    );
    final activationMs = activationClock.elapsedMilliseconds;
    active = restored.service;
    await preview.close();
    final live = restored.service;
    final owner = await live.pin.unlock(TestFamily.pin);
    final initial = (await live.overview())!;
    expect(initial.balance, 32077);
    expect(initial.experience, 10697);
    final generation = (await device.activeGeneration())!;
    final database = device.databaseFile(generation);
    final baseline = File('${root.path}/baseline.sqlite');
    await vacuumFile(database.path, baseline.path);
    final bytes = await baseline.length();
    expect(bytes, greaterThanOrEqualTo(50 * 1024 * 1024));
    _log('restore_old_fixture', {
      'input_sha256': _fixtureHash,
      'schema': await inspectSchemaVersion(database.path),
      'database_bytes': bytes,
      'preview_ms': firstPreviewMs,
      'activation_ms': activationMs,
    });

    final exportClock = Stopwatch()..start();
    final backup = await transfer.prepareExport(
      'backup',
      _password,
      owner,
      operation: TransferOperation((_) {}),
    );
    final exportMs = exportClock.elapsedMilliseconds;
    final external = await backup.file.copy(
      '${root.path}/preserved.alicebackup',
    );
    await transfer.finishExport(backup, SaveOutcome.handedToSystem);
    final verifyClock = Stopwatch()..start();
    await transfer.verifyExternal(external, _password, owner);
    final readbackMs = verifyClock.elapsedMilliseconds;
    final savedHash = await fileHash(external);
    final priorControl = await transfer.status();
    expect(priorControl['last_external_status'], 'verified');
    _log('save_and_reselect', {
      'export_with_internal_readback_ms': exportMs,
      'local_external_verification_ms': readbackMs,
      'bytes': await external.length(),
      'sha256': savedHash,
    });

    Future<void> unchanged() async {
      expect(await device.activeGeneration(), generation);
      expect(await transfer.status(), priorControl);
      expect(live.frozen, isFalse);
      expect(await fileHash(external), savedHash);
      expect(await fileHash(backup.file), savedHash);
      expect(
        await Directory('${root.path}/temporary').list().toList(),
        isEmpty,
      );
    }

    for (final phase in [TransferPhase.encrypting, TransferPhase.readback]) {
      await _cancelDuring(
        'cancel_migration_${phase.name}',
        phase,
        (operation) => transfer.prepareExport(
          'migration',
          _password,
          owner,
          operation: operation,
        ),
        entered: () => expect(live.frozen, isTrue),
      );
      await unchanged();
    }

    await _cancelDuring(
      'cancel_restore_preview',
      TransferPhase.decrypting,
      (operation) =>
          transfer.inspect(external, _password, owner, operation: operation),
    );
    await unchanged();

    final savedCheckpoint = (await transfer.protectCurrent(owner))!.checkpoint;
    final checkpointHash = await fileHash(savedCheckpoint);
    await _cancelDuring(
      'cancel_restore_protection',
      TransferPhase.encrypting,
      (operation) => transfer.protectCurrent(owner, operation: operation),
    );
    await unchanged();
    expect((await transfer.checkpoints.files()).map((file) => file.path), [
      savedCheckpoint.path,
    ]);
    expect(await fileHash(savedCheckpoint), checkpointHash);

    await live.close();
    active = null;
    active = await FamilyService.load(device, generation, rules);
      final cold = (await active.overview())!;
    expect(cold.balance, 32077);
    expect(cold.experience, 10697);
    final vacuum = File('${root.path}/cold.sqlite');
    await vacuumFile(database.path, vacuum.path);
    final result = await checkSnapshot(
      vacuum.path,
      await transfer.schema,
      rules,
      assets,
    );
    expect(result.businessDigest, _upgradedDigest);
    expect(result.summary['ledger_count'], 10706);
    expect(result.summary['active_companion_experience'], 10697);
    expect(result.schemaVersion, 8);
    expect(await fileHash(fixture), _fixtureHash);
    expect(await fileHash(external), savedHash);
    expect(await device.activeGeneration(), generation);
    expect(await transfer.status(), priorControl);
    _log('cold_restart', {
      'schema': result.schemaVersion,
      'business_sha256': result.businessDigest,
      'summary': result.summary,
      'original_archive_preserved': true,
      'new_archive_and_verified_receipt_preserved': true,
      'previous_checkpoint_preserved': true,
      'same_active_generation': true,
    });
  }, timeout: const Timeout(Duration(minutes: 6)));
}
