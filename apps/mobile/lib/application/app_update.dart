import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/pin.dart';

class AndroidRelease {
  const AndroidRelease._(
    this.version,
    this.versionCode,
    this.file,
    this.hash,
    this.sizeBytes,
  );

  final String version, file, hash;
  final int versionCode, sizeBytes;

  static const maxBytes = 100 * 1024 * 1024;

  static AndroidRelease read(Object? input) {
    if (input is Map<String, dynamic>) {
      final version = input['version'];
      final build = input['versionCode'];
      final file = input['file'];
      final hash = input['sha256'];
      final bytes = input['sizeBytes'];
      if (input['schema'] == 1 &&
          version is String &&
          RegExp(r'^\d{1,5}\.\d{1,5}\.\d{1,5}$').hasMatch(version) &&
          build is int &&
          build > 0 &&
          build <= 2100000000 &&
          file is String &&
          file == 'alice-$version-android.apk' &&
          hash is String &&
          RegExp(r'^[a-f0-9]{64}$').hasMatch(hash) &&
          bytes is int &&
          bytes > 0 &&
          bytes <= maxBytes) {
        return AndroidRelease._(version, build, file, hash, bytes);
      }
    }
    throw const UserError('GitHub 更新记录的格式无效。');
  }
}

enum InstallHandoff { permission, launched }

class AndroidInstaller {
  const AndroidInstaller();

  static const _channel = MethodChannel('alice/update');

  Future<({String name, int code})> installed() async {
    final build = await _channel.invokeMapMethod<String, Object?>('installed');
    if (build case {
      'versionName': final String name,
      'versionCode': final int code,
    }) {
      return (name: name, code: code);
    }
    throw const UserError('暂时无法读取已安装版本。');
  }

  Future<Directory> cache() async =>
      Directory(p.join((await getTemporaryDirectory()).path, 'alice-updates'));

  Future<InstallHandoff> install(File file, int versionCode) async {
    return switch (await _channel.invokeMethod<String>('install', {
      'path': file.path,
      'versionCode': versionCode,
    })) {
      'permission' => InstallHandoff.permission,
      'launched' => InstallHandoff.launched,
      _ => throw const UserError('暂时无法打开系统安装界面。'),
    };
  }

  Future<void> openDownloads() => _channel.invokeMethod<void>('openDownloads');
}

class GitHubUpdates {
  GitHubUpdates({Uri? api}) : _api = api ?? Uri.https('api.github.com');

  final Uri _api;
  HttpClient? _active;
  bool _cancelled = false;

  static const _timeout = Duration(seconds: 30);
  static const _manifestLimit = 8192;
  static const _branch = 'android-downloads';
  static const _downloadHosts = {
    'raw.githubusercontent.com',
    'objects.githubusercontent.com',
    'release-assets.githubusercontent.com',
  };

  static String tokenValue(String input) {
    final token = input.trim();
    if (token.isEmpty ||
        token.length > 512 ||
        !RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(token)) {
      throw const UserError('请输入有效的 GitHub 只读令牌。');
    }
    return token;
  }

  void cancel() {
    final active = _active;
    if (active == null) return;
    _cancelled = true;
    active.close(force: true);
  }

  Future<AndroidRelease?> check(int installed, String token) =>
      _withConnection(token, (client, token) async {
        final response = await _read(client, 'latest.json', token);
        final bytes = BytesBuilder(copy: false);
        await for (final chunk in response.timeout(_timeout)) {
          if (bytes.length + chunk.length > _manifestLimit) {
            throw const UserError('GitHub 更新记录的格式无效。');
          }
          bytes.add(chunk);
        }
        final AndroidRelease release;
        try {
          release = AndroidRelease.read(
            jsonDecode(utf8.decode(bytes.takeBytes())),
          );
        } on FormatException {
          throw const UserError('GitHub 更新记录的格式无效。');
        }
        return release.versionCode > installed ? release : null;
      });

  Future<File> download(
    AndroidRelease release,
    Directory cache,
    String token, {
    required void Function(int received, int total) onProgress,
  }) => _withConnection(token, (client, token) async {
    await cache.create(recursive: true);
    final file = File(p.join(cache.path, 'family-update.apk'));
    if (await file.exists() &&
        await file.length() == release.sizeBytes &&
        (await sha256.bind(file.openRead()).single).toString() ==
            release.hash) {
      _checkCancellation();
      return file;
    }

    final draft = await cache.createTemp('downloading-');
    try {
      final response = await _read(client, release.file, token);
      if (response.contentLength >= 0 &&
          response.contentLength != release.sizeBytes) {
        throw const UserError('安装包大小与更新记录不一致。');
      }
      final partial = File(p.join(draft.path, 'update.part'));
      final output = await partial.open(mode: FileMode.write);
      final checksum = _UpdateDigest();
      final digest = sha256.startChunkedConversion(checksum);
      var received = 0;
      try {
        await for (final chunk in response.timeout(_timeout)) {
          _checkCancellation();
          received += chunk.length;
          if (received > release.sizeBytes) {
            throw const UserError('安装包大小与更新记录不一致。');
          }
          await output.writeFrom(chunk);
          digest.add(chunk);
          onProgress(received, release.sizeBytes);
        }
        await output.flush();
      } finally {
        digest.close();
        await output.close();
      }
      _checkCancellation();
      if (received != release.sizeBytes || checksum.value != release.hash) {
        throw const UserError('安装包完整性校验失败，请重新下载。');
      }
      return await partial.rename(file.path);
    } on FileSystemException {
      throw const UserError('暂时无法保存更新包，请检查设备剩余空间。');
    } finally {
      try {
        await draft.delete(recursive: true);
      } on FileSystemException {
        // The OS can clear an abandoned download from the app cache.
      }
    }
  });

  Future<T> _withConnection<T>(
    String token,
    Future<T> Function(HttpClient, String token) operation,
  ) async {
    if (_active != null) throw const UserError('已有更新操作正在进行。');
    final credential = tokenValue(token);
    final client = HttpClient()..connectionTimeout = _timeout;
    _active = client;
    _cancelled = false;
    try {
      return await operation(client, credential);
    } on IOException {
      _checkCancellation();
      throw const UserError('暂时无法连接 GitHub，请检查网络后重试。');
    } on TimeoutException {
      _checkCancellation();
      throw const UserError('GitHub 响应超时，请稍后重试。');
    } finally {
      client.close(force: true);
      _active = null;
    }
  }

  void _checkCancellation() {
    if (_cancelled) throw const UserError('已取消下载。');
  }

  Future<HttpClientResponse> _read(
    HttpClient client,
    String file,
    String token,
  ) async {
    var url = _api.replace(
      path: '/repos/tonymd323/alice-little-companions/contents/downloads/$file',
      queryParameters: {'ref': _branch},
    );
    for (var attempt = 0; attempt < 4; attempt++) {
      _checkCancellation();
      final request = await client.getUrl(url).timeout(_timeout);
      request.followRedirects = false;
      request.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');
      if (url.origin == _api.origin) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
        request.headers.set(
          HttpHeaders.acceptHeader,
          'application/vnd.github.raw+json',
        );
        request.headers.set('X-GitHub-Api-Version', '2022-11-28');
      }
      final response = await request.close().timeout(_timeout);
      if (response.statusCode == 200) return response;
      if ([301, 302, 303, 307, 308].contains(response.statusCode)) {
        final location = response.headers.value(HttpHeaders.locationHeader);
        await response.drain<void>().timeout(_timeout);
        final parsed = location == null ? null : Uri.tryParse(location);
        if (parsed == null) break;
        final next = url.resolveUri(parsed);
        if (!next.hasAuthority ||
            next.userInfo.isNotEmpty ||
            (next.origin != _api.origin &&
                (next.scheme != 'https' ||
                    next.port != 443 ||
                    !_downloadHosts.contains(next.host)))) {
          break;
        }
        url = next;
        continue;
      }
      if ([401, 403, 404].contains(response.statusCode)) {
        throw const UserError('GitHub 未开放此文件，请核对令牌的仓库读取权限。');
      }
      throw const UserError('GitHub 暂时无法提供更新，请稍后重试。');
    }
    throw const UserError('GitHub 更新地址无法确认。');
  }
}

class _UpdateDigest implements Sink<Digest> {
  String? value;

  @override
  void add(Digest data) => value = data.toString();

  @override
  void close() {}
}
