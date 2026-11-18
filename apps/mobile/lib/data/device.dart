import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../domain/pin.dart';
import '../domain/rules.dart';
import 'database.dart';

const uuid = Uuid();

class PlatformSecureValues implements SecureValues {
  const PlatformSecureValues();
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.unlocked_this_device,
    ),
  );

  @override
  Future<String?> read(String key) => _storage.read(key: key);
  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class DeviceStore {
  DeviceStore(this.root, this.secure);
  final Directory root;
  final SecureValues secure;

  static Future<DeviceStore> open() async {
    final appDir = await getApplicationSupportDirectory();
    final root = await Directory(p.join(appDir.path, 'alice'))
        .create(recursive: true);
    if (Platform.isIOS) {
      await const MethodChannel('alice/storage')
          .invokeMethod<void>('excludeFromBackup', root.path);
    }
    final device = DeviceStore(root, const PlatformSecureValues());
    final leftover = Directory(p.join(root.path, 'temporary'));
    if (await leftover.exists()) await leftover.delete(recursive: true);
    return device;
  }

  File get pointer => File(p.join(root.path, 'active.json'));
  File databaseFile(String id) =>
      File(p.join(root.path, 'generations', id, 'database.sqlite'));
  File controlFile(String id) =>
      File(p.join(root.path, 'generations', id, 'device.json'));
  String newGeneration() => uuid.v4();

  Future<String?> activeGeneration() async {
    if (!await pointer.exists()) return null;
    final record =
        jsonDecode(await pointer.readAsString()) as Map<String, dynamic>;
    final id = record['active'] as String;
    if (!RegExp(r'^[a-f0-9-]{36}$').hasMatch(id) ||
        !await databaseFile(id).exists()) {
      throw const UserError('无法读取当前存档，请保留应用数据并联系家长。');
    }
    return id;
  }

  Future<FamilyDatabase> openGeneration(String id) async {
    final file = databaseFile(id);
    await file.parent.create(recursive: true);
    return FamilyDatabase.open(file);
  }

  Future<void> activate(String id, {String? previous}) =>
      writeAtomic(pointer, {'active': id, 'previous': previous});

  Future<Directory> temporaryDirectory() async {
    final parent = await Directory(p.join(root.path, 'temporary'))
        .create(recursive: true);
    return parent.createTemp('work-');
  }

  Future<Json> control(String id) async {
    final file = controlFile(id);
    if (await file.exists()) {
      return jsonDecode(await file.readAsString()) as Json;
    }
    final state = {'device_id': uuid.v4(), 'state': 'IDLE'};
    await updateControl(id, state);
    return state;
  }

  Future<void> updateControl(String id, Json state) =>
      writeAtomic(controlFile(id), state);

  Future<void> writeAtomic(File file, Map<String, Object?> data) async {
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.${uuid.v4()}.tmp');
    try {
      await temporary.writeAsString(jsonEncode(data), flush: true);
      await temporary.rename(file.path);
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
  }
}
