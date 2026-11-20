import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../domain/backup_codec.dart';
import '../domain/pin.dart';
import 'device.dart';
import 'snapshot.dart';
import 'transfer_work.dart';

class CheckpointStore {
  const CheckpointStore(this.device);
  final DeviceStore device;
  static const _key = 'alice.checkpoint.key';

  Directory get _path => Directory(p.join(device.root.path, 'checkpoints'));

  Future<List<File>> files() async {
    if (!await _path.exists()) return [];
    final files = await _path
        .list()
        .where((entry) => entry is File && entry.path.endsWith('.checkpoint'))
        .cast<File>()
        .toList();
    files.sort((a, b) => b.path.compareTo(a.path));
    return files;
  }

  Future<Uint8List> _deviceKey({bool create = false}) async {
    final stored = await device.secure.read(_key);
    if (stored != null) {
      final key = base64Decode(stored);
      if (key.length != 32) throw const UserError('内部恢复密钥无法使用。');
      return key;
    }
    if (!create) throw const UserError('这台设备缺少内部恢复密钥。');
    final key = Uint8List.fromList(secureBytes(32));
    await device.secure.write(_key, base64Encode(key));
    return key;
  }

  Future<File> protect(File snapshot, {TransferWork? work}) async {
    work?.check();
    if (await snapshot.length() > BackupCodec.maxPlaintext) {
      throw const UserError('数据太大，无法建立内部恢复点。');
    }
    await _path.create(recursive: true);
    final time = DateTime.now().microsecondsSinceEpoch;
    final name = '$time-${uuid.v4()}';
    final result = File(p.join(_path.path, '$name.checkpoint'));
    final folder = await device.temporaryDirectory();
    final temp = File(p.join(folder.path, 'checkpoint.tmp'));
    try {
      await _write(
        snapshot.path,
        temp.path,
        await _deviceKey(create: true),
        work,
      );
      work?.seal();
      await temp.rename(result.path);
      final saved = await files();
      for (final old in saved.skip(5)) {
        await old.delete();
      }
      return result;
    } finally {
      await cleanDirectory(folder);
    }
  }

  Future<void> protectDatabase(File source) async {
    final temp = await device.temporaryDirectory();
    try {
      final file = File(p.join(temp.path, 'snapshot.sqlite'));
      await vacuumFile(source.path, file.path);
      await protect(file);
    } finally {
      await cleanDirectory(temp);
    }
  }

  Future<void> extract(
    File file,
    File destination, {
    TransferWork? work,
  }) async {
    if (!(await files()).any((saved) => saved.path == file.path)) {
      throw const UserError('找不到所选内部恢复点。');
    }
    await _extract(file.path, destination.path, await _deviceKey(), work);
  }
}

Future<void> _write(
  String snapshot,
  String output,
  Uint8List key,
  TransferWork? work,
) => runTransferWorker(
  () => const CheckpointCodec().write(File(snapshot), File(output), key),
  work,
);

Future<void> _extract(
  String source,
  String output,
  Uint8List key,
  TransferWork? work,
) => runTransferWorker(
  () => const CheckpointCodec().extract(File(source), File(output), key),
  work,
);
