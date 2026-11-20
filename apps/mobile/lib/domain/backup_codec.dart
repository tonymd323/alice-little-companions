import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart' as digest;
import 'package:cryptography/cryptography.dart';

import 'pin.dart';
import 'rules.dart';

class BackupCodec {
  const BackupCodec();

  static const magic = 'ALICEBK1';
  static const maxContainer = 256 * 1024 * 1024;
  static const maxPlaintext = 512 * 1024 * 1024;
  static const maxHeader = 4096;
  static const maxManifest = 1024 * 1024;
  static const iterations = 600000;
  static const _tagSize = 16;
  static const _algorithm = 'AES-256-GCM';
  static const _derivation = 'PBKDF2-HMAC-SHA256';

  static void checkPassphrase(String passphrase) {
    if (passphrase.runes.length < 10) {
      throw const UserError('备份口令至少需要 10 个字符。');
    }
  }

  Future<Uint8List> encryptPayload(
    Uint8List payload,
    String passphrase, {
    List<int>? salt,
    List<int>? nonce,
  }) async {
    checkPassphrase(passphrase);
    final actualSalt = salt ?? secureBytes(16);
    final actualNonce = nonce ?? secureBytes(12);
    if (actualSalt.length != 16 || actualNonce.length != 12) {
      throw const FormatException('Invalid salt or nonce size');
    }
    final header = utf8.encode(
      jsonEncode({
        'format_version': 1,
        'kdf': _derivation,
        'iterations': iterations,
        'salt': base64Encode(actualSalt),
        'cipher': _algorithm,
        'nonce': base64Encode(actualNonce),
        'payload_bytes': payload.length,
      }),
    );
    if (12 + header.length + payload.length + _tagSize > maxContainer) {
      throw const UserError('备份超过支持的文件大小。');
    }
    final aad = Uint8List(12 + header.length);
    aad.setAll(0, ascii.encode(magic));
    ByteData.sublistView(aad).setUint32(8, header.length, Endian.big);
    aad.setAll(12, header);
    final key = await _key(passphrase, actualSalt, iterations);
    final box = await AesGcm.with256bits().encrypt(
      payload,
      secretKey: key,
      nonce: actualNonce,
      aad: aad,
    );
    return Uint8List(aad.length + payload.length + box.mac.bytes.length)
      ..setAll(0, aad)
      ..setAll(aad.length, box.cipherText)
      ..setAll(aad.length + payload.length, box.mac.bytes);
  }

  Future<Uint8List> decryptPayload(Uint8List file, String passphrase) async {
    checkPassphrase(passphrase);
    try {
      if (file.length < 12 + _tagSize ||
          file.length > maxContainer ||
          ascii.decode(file.sublist(0, 8), allowInvalid: true) != magic) {
        throw const FormatException();
      }
      final headerLength = ByteData.sublistView(file).getUint32(8, Endian.big);
      final start = 12 + headerLength;
      if (headerLength == 0 ||
          headerLength > maxHeader ||
          start + _tagSize > file.length) {
        throw const FormatException();
      }
      final json = jsonDecode(
        utf8.decode(Uint8List.sublistView(file, 12, start)),
      ) as Json;
      if (json['format_version'] is int && json['format_version'] != 1) {
        throw const UserError('此备份格式需要兼容版本的 App。');
      }
      final count = json['iterations'];
      final length = json['payload_bytes'];
      if (json.length != 7 ||
          json['format_version'] is! int ||
          json['kdf'] != _derivation ||
          json['cipher'] != _algorithm ||
          count is! int ||
          count < iterations ||
          count > 1200000 ||
          length is! int ||
          length < 0 ||
          start + length + _tagSize != file.length) {
        throw const FormatException();
      }
      final salt = base64Decode(json['salt'] as String);
      final nonce = base64Decode(json['nonce'] as String);
      if (salt.length != 16 ||
          nonce.length != 12 ||
          base64Encode(salt) != json['salt'] ||
          base64Encode(nonce) != json['nonce']) {
        throw const FormatException();
      }
      final key = await _key(passphrase, salt, count);
      final data = await AesGcm.with256bits().decrypt(
        SecretBox(
          Uint8List.sublistView(file, start, start + length),
          nonce: nonce,
          mac: Mac(Uint8List.sublistView(file, start + length)),
        ),
        secretKey: key,
        aad: Uint8List.sublistView(file, 0, start),
      );
      return data is Uint8List ? data : Uint8List.fromList(data);
    } on UserError {
      rethrow;
    } catch (_) {
      throw const UserError('口令不正确或文件已损坏。');
    }
  }

  static Future<SecretKey> _key(String passphrase, List<int> salt, int count) =>
      Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: count,
        bits: 256,
      ).deriveKey(secretKey: SecretKey(utf8.encode(passphrase)), nonce: salt);

  /// Seals the archive and returns the digest of its SQLite snapshot.
  Future<String> write(
    File snapshot,
    Json metadata,
    String passphrase,
    File output,
  ) async {
    if (await snapshot.length() > maxPlaintext - maxManifest) {
      throw const UserError('存档超过支持的备份大小。');
    }
    final database = await snapshot.readAsBytes();
    final databaseHash = digest.sha256.convert(database).toString();
    final manifest = utf8.encode(
      jsonEncode({
        ...metadata,
        'database_sha256': databaseHash,
      }),
    );
    if (manifest.length > maxManifest) throw const UserError('备份摘要超过支持的大小。');
    final zip = ZipEncoder().encode(
      Archive()
        ..addFile(ArchiveFile('manifest.json', manifest.length, manifest))
        ..addFile(ArchiveFile('snapshot.sqlite', database.length, database)),
    );
    final file = await encryptPayload(
      zip is Uint8List ? zip : Uint8List.fromList(zip),
      passphrase,
    );
    await output.writeAsBytes(file, flush: true);
    return databaseHash;
  }

  /// Authenticates and validates an archive without writing a SQLite file.
  Future<Json> verify(File input, String passphrase) => _read(input, passphrase);

  Future<Json> extract(File input, String passphrase, File snapshot) =>
      _read(input, passphrase, snapshot: snapshot);

  Future<Json> _read(File input, String passphrase, {File? snapshot}) async {
    final length = await input.length();
    if (length > maxContainer) throw const UserError('备份超过支持的文件大小。');
    final plain = await decryptPayload(await input.readAsBytes(), passphrase);
    try {
      final zip = ZipDirectory();
      final stream = InputMemoryStream(
        plain,
        byteOrder: ByteOrder.littleEndian,
      );
      final headers = zip.headers(stream, verify: true).take(3).toList();
      if (headers.length != 2 ||
          zip.numberOfThisDisk != 0 ||
          zip.diskWithTheStartOfTheCentralDirectory != 0 ||
          zip.totalCentralDirectoryEntries != 2 ||
          headers.map((item) => item.filename).toSet().length != 2 ||
          headers.fold<int>(0, (sum, entry) => sum + entry.uncompressedSize) >
              maxPlaintext) {
        throw const FormatException();
      }
      final metadata = OutputMemoryStream();
      late final String databaseHash;
      for (final header in headers) {
        final fileMode = header.externalFileAttributes >> 16 & 0xf000;
        final limit = switch (header.filename) {
          'manifest.json' => maxManifest,
          'snapshot.sqlite' => maxPlaintext,
          _ => 0,
        };
        if (limit == 0 ||
            header.uncompressedSize <= 0 ||
            header.uncompressedSize > limit ||
            (header.generalPurposeBitFlag & 1) != 0 ||
            (fileMode != 0 && fileMode != 0x8000) ||
            (header.externalFileAttributes & 0x10) != 0 ||
            ![0, 8].contains(header.compressionMethod)) {
          throw const FormatException();
        }
        final entry = header.file!;
        if (entry.filename != header.filename ||
            entry.uncompressedSize != header.uncompressedSize) {
          throw const FormatException();
        }
        entry.verify = true;
        entry.throwOnError = true;
        if (header.filename == 'manifest.json') {
          entry.decompress(metadata);
        } else if (snapshot == null) {
          databaseHash = _entryHash(entry);
        } else {
          final output = OutputFileStream(snapshot.path);
          try {
            entry.decompress(output);
          } finally {
            output.closeSync();
          }
          databaseHash = await fileHash(snapshot);
        }
      }
      final manifest = jsonDecode(utf8.decode(metadata.getBytes())) as Json;
      if (manifest['database_sha256'] != databaseHash) {
        throw const FormatException();
      }
      return manifest;
    } catch (_) {
      throw const UserError('备份文件结构或摘要校验失败。');
    }
  }

  String _entryHash(ZipFile entry) {
    late final digest.Digest hash;
    final output = SinkOutputStream(
      digest.sha256.startChunkedConversion(
        ChunkedConversionSink<digest.Digest>.withCallback(
          (values) => hash = values.single,
        ),
      ),
    );
    try {
      entry.decompress(output);
    } finally {
      output.closeSync();
    }
    return hash.toString();
  }
}

Future<String> fileHash(File file) async =>
    (await digest.sha256.bind(file.openRead()).single).toString();

class CheckpointCodec {
  const CheckpointCodec();
  static final _magic = ascii.encode('ALICECP1');

  Future<void> write(File database, File output, Uint8List key) async {
    final nonce = secureBytes(12);
    final body = await AesGcm.with256bits().encrypt(
      await database.readAsBytes(),
      secretKey: SecretKey(key),
      nonce: nonce,
      aad: _magic,
    );
    final file = await output.open(mode: FileMode.writeOnly);
    try {
      await file.writeFrom(_magic);
      await file.writeFrom(nonce);
      await file.writeFrom(body.cipherText);
      await file.writeFrom(body.mac.bytes);
      await file.flush();
    } finally {
      await file.close();
    }
  }

  Future<void> extract(File input, File database, Uint8List key) async {
    if (await input.length() > BackupCodec.maxPlaintext + 36) {
      throw const UserError('恢复点超过支持的大小。');
    }
    final bytes = await input.readAsBytes();
    if (bytes.length < 36 ||
        ascii.decode(bytes.sublist(0, 8), allowInvalid: true) != 'ALICECP1') {
      throw const UserError('这份设备恢复点无法读取。');
    }
    final tagAt = bytes.length - 16;
    try {
      final data = await AesGcm.with256bits().decrypt(
        SecretBox(
          Uint8List.sublistView(bytes, 20, tagAt),
          nonce: Uint8List.sublistView(bytes, 8, 20),
          mac: Mac(Uint8List.sublistView(bytes, tagAt)),
        ),
        secretKey: SecretKey(key),
        aad: _magic,
      );
      await database.writeAsBytes(data, flush: true);
    } catch (_) {
      throw const UserError('这份设备恢复点无法读取。');
    }
  }
}
