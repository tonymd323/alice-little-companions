import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:alice_companions/application/controller.dart';
import 'package:alice_companions/application/family.dart';
import 'package:alice_companions/application/transfer.dart';
import 'package:alice_companions/data/device.dart' show uuid;
import 'package:alice_companions/domain/backup_codec.dart';
import 'package:alice_companions/domain/rules.dart';
import 'package:alice_companions/features/backup_pages.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

import 'support/families.dart';

const _password = 'fixture backup passphrase';
const _draft = TaskDraft('测试任务A', '测试内容', '测试标准', 'focus');

Set<String> _assetIds() {
  final paths = jsonDecode(
    File('assets/config/runtime_assets.json').readAsStringSync(),
  ) as Json;
  return {
    for (final MapEntry(:key, :value) in paths.entries)
      if (File(value as String).existsSync()) key,
  };
}

TransferService _transfer(TestFamily family) => TransferService(
  device: family.device,
  rules: family.rules,
  availableAssets: _assetIds(),
  current: () => family.service,
);

Future<void> _expectNoTemporaryFiles(TestFamily family) async {
  final directory = Directory(p.join(family.root.path, 'temporary'));
  expect(await directory.list().toList(), isEmpty);
}

void main() {
  testWidgets('the export page shows a progress bar and can cancel', (
    tester,
  ) async {
    final family = (await tester.runAsync(TestFamily.create))!;
    final controller = FamilyController(
      family.device,
      family.rules,
      assets: _assetIds(),
    )..service = family.service;
    addTearDown(() async {
      controller.dispose();
      await family.dispose();
    });
    await tester.runAsync(() async {
      controller.session = await family.service.pin.unlock(TestFamily.pin);
      await controller.refresh();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: ExportPage(controller: controller, mode: 'migration'),
      ),
    );
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), _password);
    await tester.enterText(fields.at(1), _password);
    final generate = find.text('生成并保存文件');
    await tester.ensureVisible(generate);
    await tester.runAsync(() => tester.tap(generate));
    await tester.pump();
    final progress = find.byType(LinearProgressIndicator);
    expect(progress, findsOneWidget);
    expect(tester.widget<LinearProgressIndicator>(progress).value, isNull);
    final cancel = find.text('取消');
    await tester.ensureVisible(cancel);
    await tester.tap(cancel);

    final cancelled = find.text('已取消备份生成。');
    for (var i = 0; i < 120 && cancelled.evaluate().isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
    expect(cancelled, findsOneWidget);
    expect(progress, findsNothing);
    expect(generate, findsOneWidget);
    expect(tester.widget<TextField>(fields.at(0)).controller!.text, _password);
    expect(family.service.frozen, false);
  });

  test(
    'cancelling migration generation restores the prior backup and control',
    () async {
      final family = await TestFamily.create();
      addTearDown(family.dispose);
      final service = family.service;
      final owner = await service.pin.unlock(TestFamily.pin);
      await service.backfill(_draft, service.today, '', session: owner);
      final transfer = _transfer(family);
      final phases = <TransferPhase>[];
      final backup = await transfer.prepareExport(
        'backup',
        _password,
        owner,
        operation: TransferOperation(phases.add),
      );
      expect(phases, [
        TransferPhase.snapshot,
        TransferPhase.checking,
        TransferPhase.encrypting,
        TransferPhase.readback,
      ]);
      await transfer.finishExport(backup, SaveOutcome.handedToSystem);
      final previous = await transfer.status();
      final previousHash = await fileHash(backup.file);
      final generation = await family.device.activeGeneration();

      var wasFrozen = false;
      late final TransferOperation cancelExport;
      cancelExport = TransferOperation((phase) {
        if (phase == TransferPhase.encrypting) {
          wasFrozen = service.frozen;
          Timer(const Duration(milliseconds: 10), cancelExport.cancel);
        }
      });
      await expectLater(
        transfer.prepareExport(
          'migration',
          _password,
          owner,
          operation: cancelExport,
        ),
        throwsA(isA<TransferCancelled>()),
      );
      expect(wasFrozen, isTrue);
      expect(service.frozen, isFalse);
      expect(await transfer.status(), previous);
      expect(await family.device.activeGeneration(), generation);
      expect((await service.overview())!.balance, 3);
      expect(await service.ledger(), hasLength(1));
      expect(await fileHash(backup.file), previousHash);
      await _expectNoTemporaryFiles(family);

      final retry = await transfer.prepareExport(
        'migration',
        _password,
        owner,
        operation: TransferOperation((_) {}),
      );
      expect(service.frozen, isTrue);
      expect(await retry.file.exists(), isTrue);
      await transfer.finishExport(retry, SaveOutcome.cancelled);
      expect(service.frozen, isFalse);
      expect(await transfer.status(), previous);
      expect(await fileHash(backup.file), previousHash);
      expect(await retry.file.exists(), isFalse);
      await _expectNoTemporaryFiles(family);
    },
  );

  test('reopening an interrupted export preserves the last backup', () async {
    final family = await TestFamily.create();
    addTearDown(family.dispose);
    final generation = family.service.pin.generation;
    final previousId = uuid.v4();
    final draftId = uuid.v4();
    final previous = family.device.outgoingBackup(generation, previousId);
    final abandoned = family.device.outgoingBackup(generation, draftId);
    await previous.parent.create(recursive: true);
    await previous.writeAsString('previous fixture');
    await abandoned.writeAsString('abandoned fixture');
    final control = {
      ...await family.device.control(generation),
      'outgoing_id': previousId,
      'outgoing_mode': 'backup',
      'outgoing_sha256': await fileHash(previous),
      'last_external_status': 'verified',
    };
    await family.device.updateControl(generation, {
      ...control,
      'state': 'EXPORTING',
      'draft_outgoing_id': draftId,
    });

    await family.reopen();
    expect(family.service.frozen, isFalse);
    expect(await family.device.control(generation), control);
    expect(await abandoned.exists(), isFalse);
    expect(await fileHash(previous), control['outgoing_sha256']);
  });

  test('cancelled decryption and validation leave the activation pointer untouched', () async {
    final family = await TestFamily.create();
    addTearDown(family.dispose);
    final service = family.service;
    final owner = await service.pin.unlock(TestFamily.pin);
    await service.backfill(_draft, service.today, '', session: owner);
    final transfer = _transfer(family);
    final backup = await transfer.prepareExport('backup', _password, owner);
    await transfer.finishExport(backup, SaveOutcome.handedToSystem);
    final generation = await family.device.activeGeneration();
    final previous = await transfer.status();
    final originalHash = await fileHash(backup.file);

    late final TransferOperation cancelDecrypt;
    cancelDecrypt = TransferOperation((phase) {
      if (phase == TransferPhase.decrypting) {
        Timer(const Duration(milliseconds: 10), cancelDecrypt.cancel);
      }
    });
    await expectLater(
      transfer.inspect(backup.file, _password, owner, operation: cancelDecrypt),
      throwsA(isA<TransferCancelled>()),
    );
    await _expectNoTemporaryFiles(family);

    late final TransferOperation cancelCheck;
    cancelCheck = TransferOperation((phase) {
      if (phase == TransferPhase.checking) cancelCheck.cancel();
    });
    await expectLater(
      transfer.verifyExternal(
        backup.file,
        _password,
        owner,
        operation: cancelCheck,
      ),
      throwsA(isA<TransferCancelled>()),
    );
    await _expectNoTemporaryFiles(family);
    expect(await transfer.status(), previous);
    expect(await family.device.activeGeneration(), generation);
    expect((await service.overview())!.balance, 3);
    expect(await fileHash(backup.file), originalHash);

    final preview = await transfer.inspect(
      backup.file,
      _password,
      owner,
      operation: TransferOperation((_) {}),
    );
    expect(preview.info.summary['balance'], 3);
    await preview.close();
    final phases = <TransferPhase>[];
    await transfer.verifyExternal(
      backup.file,
      _password,
      owner,
      operation: TransferOperation(phases.add),
    );
    expect(phases, [TransferPhase.decrypting, TransferPhase.checking]);
    expect((await transfer.status())['last_external_status'], 'verified');
    expect(await family.device.activeGeneration(), generation);
    await _expectNoTemporaryFiles(family);
  });

  test('stopping checkpoint protection keeps existing recovery data', () async {
    final family = await TestFamily.create();
    addTearDown(family.dispose);
    final service = family.service;
    final owner = await service.pin.unlock(TestFamily.pin);
    await service.backfill(_draft, service.today, '', session: owner);
    final transfer = _transfer(family);
    final original = (await transfer.protectCurrent(owner))!.checkpoint;
    final generation = await family.device.activeGeneration();
    final originalHash = await fileHash(original);

    late final TransferOperation cancelProtection;
    cancelProtection = TransferOperation((phase) {
      if (phase == TransferPhase.encrypting) cancelProtection.cancel();
    });
    await expectLater(
      transfer.protectCurrent(owner, operation: cancelProtection),
      throwsA(isA<TransferCancelled>()),
    );
    expect((await transfer.checkpoints.files()).map((file) => file.path), [
      original.path,
    ]);
    expect(await fileHash(original), originalHash);
    expect(await family.device.activeGeneration(), generation);
    expect((await service.overview())!.balance, 3);
    await _expectNoTemporaryFiles(family);

    final retry = await transfer.protectCurrent(
      owner,
      operation: TransferOperation((_) {}),
    );
    final preview = await transfer.inspectCheckpoint(
      retry!.checkpoint,
      owner,
      operation: TransferOperation((_) {}),
    );
    expect(preview.info.summary['balance'], 3);
    await preview.close();
    expect(await family.device.activeGeneration(), generation);
    await _expectNoTemporaryFiles(family);
  });
}
