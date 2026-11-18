import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;

import '../data/checkpoints.dart';
import '../data/device.dart';
import '../data/snapshot.dart';
import '../domain/backup_codec.dart';
import '../domain/pin.dart';
import '../domain/rules.dart';
import 'family.dart';

enum SaveOutcome { cancelled, handedToSystem, externallyVerified }

class ExportTicket {
  const ExportTicket(this.id, this.file, this.mode, {this.retry = false});
  final String id;
  final File file;
  final String mode;
  final bool retry;
  String get name => 'alice-$id.alicebackup';
  bool get migration => mode == 'migration';
}

class RestorePreview {
  RestorePreview._(this.folder, this.database, this.manifest, this.info);

  final Directory folder;
  final File database;
  final Json manifest;
  final Snapshot info;

  String? get backupId => manifest['backup_id'] as String?;
  bool get isCheckpoint => backupId == null;

  Future<void> close() => cleanDirectory(folder);
}

class RestoreProtection {
  RestoreProtection._(this.generation, this.revision, this.checkpoint);
  final String generation;
  final int revision;
  final File checkpoint;
}

class Activation {
  const Activation(this.service, {this.alreadyRestored = false});
  final FamilyService service;
  final bool alreadyRestored;
}

class TransferService {
  TransferService({
    required this.device,
    required this.rules,
    required this.availableAssets,
    required this.current,
    this.fault,
    this.repairPin,
  });

  final DeviceStore device;
  final Rules rules;
  final Set<String> availableAssets;
  final FamilyService? Function() current;
  final PinGate? Function()? repairPin;
  final void Function(String phase)? fault;
  final _noFamily = SerialWork();

  Future<List<Json>>? _schema;
  Future<List<Json>> get schema => _schema ??= expectedSchema();
  CheckpointStore get checkpoints => CheckpointStore(device);

  Future<Json> status() async {
    final generation = await device.recordedGeneration();
    return generation == null ? {} : device.control(generation);
  }

  Future<Snapshot> _read(File file) async =>
      checkSnapshot(file.path, await schema, rules, availableAssets);

  File _outgoing(String generation, String id) =>
      File(p.join(device.root.path, 'outgoing', generation, '$id.alicebackup'));

  Future<ExportTicket> prepareExport(
    String mode,
    String password,
    ParentSession? session,
  ) {
    final family = current();
    if (family == null) return Future.error(const UserError('请先创建小家。'));
    return family.serial.run(() async {
      family.checkParent(session);
      BackupCodec.checkPassphrase(password);
      if (mode != 'backup' && mode != 'migration') {
        throw const UserError('请选择备份或迁移。');
      }
      final id = family.pin.generation;
      final control = await device.control(id);
      if (family.frozen) {
        final previous = control['outgoing_id'] as String?;
        if (mode != 'migration' || previous == null) {
          throw const UserError('这台设备当前只读。请处理现有迁移。');
        }
        final existing = _outgoing(id, previous);
        if (!await existing.exists()) throw const UserError('请回读之前保存的迁移文件。');
        final check = await device.temporaryDirectory();
        try {
          await _unpack(
            existing.path,
            password,
            p.join(check.path, 'snapshot.sqlite'),
          );
        } finally {
          await cleanDirectory(check);
        }
        return ExportTicket(previous, existing, mode, retry: true);
      }
      final bid = uuid.v4();
      final destination = _outgoing(id, bid);
      final folder = await device.temporaryDirectory();
      final migration = mode == 'migration';
      try {
        if (migration) {
          await device.updateControl(id, {
            ...control,
            'state': 'EXPORTING',
            'outgoing_id': bid,
          });
          family.frozen = true;
        }
        final snapshot = File(p.join(folder.path, 'snapshot.sqlite'));
        await family.db.customStatement('VACUUM INTO ?', [snapshot.path]);
        final info = await _read(snapshot);
        final manifest = {
          'backup_id': bid,
          'mode': mode,
          'format_version': 1,
          'schema_version': info.schemaVersion,
          'created_at_utc': DateTime.now().toUtc().toIso8601String(),
          'family_timezone': info.family['timezone'],
          'family_id': info.family['id'],
          'child_id': info.family['child_id'],
          'source_device_id': control['device_id'],
          'lineage_id': info.family['lineage_id'],
          'snapshot_revision': info.revision,
          'rules_version': info.family['rules_version'],
          'catalog_version': info.family['catalog_version'],
          'required_asset_ids': info.assets.toList()..sort(),
          'summary': info.summary,
        };
        final encrypted = File(p.join(folder.path, 'outgoing.alicebackup'));
        await _pack(snapshot.path, manifest, password, encrypted.path);
        final readback = File(p.join(folder.path, 'verified.sqlite'));
        final verified = await _unpack(encrypted.path, password, readback.path);
        if (verified['backup_id'] != bid ||
            await fileHash(snapshot) != verified['database_sha256']) {
          throw const UserError('生成的备份未通过回读校验。');
        }
        family.checkParent(session);
        await destination.parent.create(recursive: true);
        await encrypted.rename(destination.path);
        final next = {
          ...control,
          'outgoing_id': bid,
          'outgoing_mode': mode,
          'outgoing_sha256': await fileHash(destination),
          'state': migration ? 'AWAITING_FILE_VERIFICATION' : 'IDLE',
          'last_external_status': 'pending',
        };
        await device.updateControl(id, next);
        if (control['outgoing_id'] case final String old when old != bid) {
          final file = _outgoing(id, old);
          if (await file.exists()) await file.delete();
        }
        return ExportTicket(bid, destination, mode);
      } catch (_) {
        if (migration) {
          await device.updateControl(id, control);
          family.frozen = false;
        }
        if (await destination.exists()) await destination.delete();
        rethrow;
      } finally {
        await cleanDirectory(folder);
      }
    });
  }

  Future<void> finishExport(ExportTicket ticket, SaveOutcome outcome) async {
    final family = current();
    if (family == null) return;
    await family.serial.run(() async {
      final id = family.pin.generation;
      final control = await device.control(id);
      if (control['outgoing_id'] != ticket.id) return;
      if (outcome == SaveOutcome.cancelled) {
        if (ticket.retry) return;
        await device.updateControl(id, {
          ...control,
          'state': 'IDLE',
          'outgoing_id': null,
          'outgoing_mode': null,
          'outgoing_sha256': null,
          'last_external_status': 'cancelled',
        });
        family.frozen = false;
        if (await ticket.file.exists()) await ticket.file.delete();
      } else if (outcome == SaveOutcome.externallyVerified) {
        await _markExternalVerified(family, control, ticket.migration);
      } else if (control['state'] != 'MIGRATION_PENDING' &&
          control['state'] != 'ARCHIVED') {
        await device.updateControl(id, {
          ...control,
          'last_external_status': 'unverified',
        });
      }
    });
  }

  Future<void> _markExternalVerified(
    FamilyService service,
    Json control,
    bool migration,
  ) async {
    await device.updateControl(service.pin.generation, {
      ...control,
      'last_verified_at': DateTime.now().toUtc().toIso8601String(),
      'last_external_status': 'verified',
      'state': migration && control['state'] == 'AWAITING_FILE_VERIFICATION'
          ? 'MIGRATION_PENDING'
          : control['state'],
    });
  }

  Future<void> verifyExternal(
    File file,
    String password,
    ParentSession? session,
  ) async {
    final family = current();
    if (family == null) throw const UserError('请先创建小家。');
    final preview = await inspect(file, password, session);
    try {
      await family.serial.run(() async {
        family.checkParent(session);
        final control = await device.control(family.pin.generation);
        if (preview.backupId != control['outgoing_id'] ||
            await fileHash(file) != control['outgoing_sha256']) {
          throw const UserError('请重新选择这台设备刚导出的文件。');
        }
        await _markExternalVerified(
          family,
          control,
          preview.manifest['mode'] == 'migration',
        );
      });
    } finally {
      await preview.close();
    }
  }

  Future<void> endMigration({
    required bool archive,
    required ParentSession? session,
  }) async {
    final family = current();
    if (family == null) throw const UserError('请先创建小家。');
    await family.serial.run(() async {
      family.checkParent(session);
      final id = family.pin.generation;
      final control = await device.control(id);
      if (!family.frozen ||
          (archive && control['state'] != 'MIGRATION_PENDING')) {
        throw const UserError('请先回读迁移文件。');
      }
      await device.updateControl(id, {
        ...control,
        'state': archive ? 'ARCHIVED' : 'IDLE',
      });
      family.frozen = archive;
    });
  }

  Future<RestorePreview> inspect(
    File selected,
    String password,
    ParentSession? session,
  ) async {
    _allowPreview(session);
    final folder = await device.temporaryDirectory();
    try {
      final database = File(p.join(folder.path, 'snapshot.sqlite'));
      final manifest = await _unpack(selected.path, password, database.path);
      final info = await _read(database);
      _verifyManifest(manifest, info);
      return RestorePreview._(folder, database, manifest, info);
    } catch (_) {
      await cleanDirectory(folder);
      rethrow;
    }
  }

  Future<RestorePreview> inspectCheckpoint(
    File selected,
    ParentSession? session,
  ) async {
    _allowPreview(session, requireExisting: true);
    final folder = await device.temporaryDirectory();
    try {
      final database = File(p.join(folder.path, 'snapshot.sqlite'));
      await checkpoints.extract(selected, database);
      final info = await _read(database);
      return RestorePreview._(folder, database, {
        'database_sha256': await fileHash(database),
      }, info);
    } catch (_) {
      await cleanDirectory(folder);
      rethrow;
    }
  }

  void _allowPreview(ParentSession? session, {bool requireExisting = false}) {
    final family = current();
    if (family != null) {
      family.checkParent(session);
      return;
    }
    final guard = repairPin?.call();
    if ((guard != null || requireExisting) &&
        !(guard?.allows(session) ?? false)) {
      throw const UserError('请先验证此设备的家长 PIN。');
    }
  }

  void _verifyManifest(Json manifest, Snapshot info) {
    const fields = {
      'backup_id',
      'mode',
      'format_version',
      'schema_version',
      'created_at_utc',
      'family_timezone',
      'family_id',
      'child_id',
      'source_device_id',
      'lineage_id',
      'snapshot_revision',
      'rules_version',
      'catalog_version',
      'required_asset_ids',
      'database_sha256',
      'summary',
    };
    bool isId(Object? value) =>
        value is String &&
        RegExp(r'^[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}$')
            .hasMatch(value);
    if (manifest['schema_version'] is int &&
        (manifest['schema_version'] as int) > 2) {
      throw const UserError('备份需要更新版本的 App。');
    }
    final assets = manifest['required_asset_ids'];
    final summary = manifest['summary'];
    final time = manifest['created_at_utc'];
    if (!fields.every(manifest.containsKey) ||
        manifest.length != fields.length ||
        !['backup', 'migration'].contains(manifest['mode']) ||
        manifest['format_version'] is! int ||
        manifest['format_version'] != 1 ||
        manifest['schema_version'] != info.schemaVersion ||
        !isId(manifest['backup_id']) ||
        !isId(manifest['source_device_id']) ||
        time is! String ||
        !time.endsWith('Z') ||
        DateTime.tryParse(time) == null ||
        manifest['family_timezone'] != info.family['timezone'] ||
        manifest['family_id'] != info.family['id'] ||
        manifest['child_id'] != info.family['child_id'] ||
        manifest['lineage_id'] != info.family['lineage_id'] ||
        manifest['snapshot_revision'] != info.revision ||
        manifest['rules_version'] != info.family['rules_version'] ||
        manifest['catalog_version'] != info.family['catalog_version'] ||
        assets is! List ||
        assets.length != info.assets.length ||
        !assets.toSet().containsAll(info.assets) ||
        summary is! Map ||
        summary.length != info.summary.length ||
        !info.summary.entries.every(
          (value) =>
              summary[value.key] is int && summary[value.key] == value.value,
        )) {
      throw const UserError('备份摘要与数据不一致，原数据保留。');
    }
  }

  Future<RestoreProtection?> protectCurrent(ParentSession? session) {
    final family = current();
    if (family == null) return Future.value(null);
    return family.serial.run(() async {
      family.checkParent(session);
      final current = (await family.overview())!;
      final folder = await device.temporaryDirectory();
      try {
        final snapshot = File(p.join(folder.path, 'snapshot.sqlite'));
        await family.db.customStatement('VACUUM INTO ?', [snapshot.path]);
        await _read(snapshot);
        final protection = await checkpoints.protect(snapshot);
        return RestoreProtection._(
          family.pin.generation,
          current.revision,
          protection,
        );
      } finally {
        await cleanDirectory(folder);
      }
    });
  }

  Future<Activation> activate(
    RestorePreview preview,
    String pin,
    String recovery, {
    required ParentSession? session,
    required bool replace,
    RestoreProtection? protection,
  }) {
    final active = current();
    return (active?.serial ?? _noFamily).run(() async {
      active?.checkParent(session);
      final previous = await device.recordedGeneration();
      final guard = repairPin?.call();
      if (active == null && previous != null) {
        if (guard == null ||
            guard.generation != previous ||
            !guard.allows(session) ||
            !replace) {
          throw const UserError('请验证家长 PIN 并确认恢复。');
        }
      } else if (previous != active?.pin.generation) {
        throw const UserError('当前存档已变化，请重新预览。');
      }
      if (active != null) {
        final control = await device.control(previous!);
        final state = (await active.overview())!;
        if (preview.backupId != null &&
            control['last_import_id'] == preview.backupId &&
            control['last_import_revision'] == state.revision) {
          return Activation(active, alreadyRestored: true);
        }
        if (!replace ||
            protection == null ||
            protection.generation != previous ||
            protection.revision != state.revision ||
            !await protection.checkpoint.exists()) {
          throw const UserError('请先保护当前数据并再次确认完整替换。');
        }
      }
      if (preview.manifest['database_sha256'] !=
          await fileHash(preview.database)) {
        throw const UserError('待恢复文件已变化，请重新选择。');
      }
      final next = device.newGeneration();
      final destination = device.databaseFile(next);
      await destination.parent.create(recursive: true);
      var switched = false;
      FamilyService? nextService;
      try {
        await preview.database.copy(destination.path);
        fault?.call('database');
        nextService = await FamilyService.load(
          device,
          next,
          rules,
          protectUpgrade: false,
        );
        await nextService.pin.configure(pin, recovery);
        if (await device.secure.read('alice.pin.$next') == null) {
          throw const UserError('新家长凭据未能保存。');
        }
        fault?.call('credentials');
        final verified = await _read(destination);
        if (verified.businessDigest != preview.info.businessDigest) {
          throw const UserError('恢复后的存档校验失败。');
        }
        await device.updateControl(next, {
          'device_id': uuid.v4(),
          'state': 'IDLE',
          'last_import_id': preview.backupId,
          'last_import_revision': verified.revision,
        });
        _allowPreview(session);
        fault?.call('before_pointer');
        await device.activate(next, previous: previous);
        switched = true;
        if (active != null) active.frozen = true;
        fault?.call('after_pointer');
        return Activation(nextService);
      } catch (_) {
        await nextService?.close();
        if (!switched) {
          await device.secure.delete('alice.pin.$next');
          await cleanDirectory(destination.parent);
        }
        rethrow;
      }
    });
  }
}

Future<Json> _unpack(String input, String password, String output) =>
    Isolate.run(
      () => const BackupCodec().extract(File(input), password, File(output)),
    );

Future<void> _pack(
  String input,
  Json manifest,
  String password,
  String output,
) => Isolate.run(
  () =>
      const BackupCodec().write(File(input), manifest, password, File(output)),
);
