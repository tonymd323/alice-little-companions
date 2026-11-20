import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:alice_companions/application/app_update.dart';
import 'package:alice_companions/domain/pin.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const token = 'fixture_read_only';
  final apkBytes = List<int>.generate(8192, (value) => value % 256);
  final releaseData = <String, Object>{
    'schema': 1,
    'version': '0.18.0',
    'versionCode': 16,
    'file': 'alice-0.18.0-android.apk',
    'sha256': sha256.convert(apkBytes).toString(),
    'sizeBytes': apkBytes.length,
  };
  final release = AndroidRelease.read(releaseData);

  test(
    'checks the private download branch and offers only a newer build',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      final requests = <(String path, String? branch, String? bearer)>[];
      server.listen((request) async {
        requests.add((
          request.uri.path,
          request.uri.queryParameters['ref'],
          request.headers.value(HttpHeaders.authorizationHeader),
        ));
        request.response.write(jsonEncode(releaseData));
        await request.response.close();
      });
      final updater = GitHubUpdates(
        api: Uri.parse('http://127.0.0.1:${server.port}'),
      );
      expect((await updater.check(15, token))?.versionCode, 16);
      expect(await updater.check(16, token), isNull);
      expect(await updater.check(17, token), isNull);
      expect((await updater.check(15))?.versionCode, 16);
      expect(requests, [
        ...List.filled(3, (
          '/repos/tonymd323/alice-little-companions/contents/downloads/latest.json',
          'android-downloads',
          'Bearer $token',
        )),
        (
          '/repos/tonymd323/alice-little-companions/contents/downloads/latest.json',
          'android-downloads',
          null,
        ),
      ]);
      expect(
        () => AndroidRelease.read({...releaseData, 'file': '../test.apk'}),
        throwsA(isA<UserError>()),
      );
    },
  );

  test('only publishes a complete download with an exact digest and reuses that file', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    var downloads = 0;
    server.listen((request) async {
      downloads++;
      request.response.contentLength = apkBytes.length;
      request.response.add(apkBytes);
      await request.response.close();
    });
    final updater = GitHubUpdates(
      api: Uri.parse('http://127.0.0.1:${server.port}'),
    );
    final cache = await Directory.systemTemp.createTemp('alice-update-');
    addTearDown(() => cache.delete(recursive: true));
    final progress = <int>[];
    final result = await updater.download(
      release,
      cache,
      token,
      onProgress: (received, _) => progress.add(received),
    );
    expect(await result.readAsBytes(), apkBytes);
    expect(progress.last, apkBytes.length);
    expect(await cache.list().toList(), hasLength(1));
    expect(
      (await updater.download(
        release,
        cache,
        token,
        onProgress: (_, _) {},
      )).path,
      result.path,
    );
    expect(downloads, 1);

    final wrong = AndroidRelease.read({...releaseData, 'sha256': '1' * 64});
    await expectLater(
      updater.download(wrong, cache, token, onProgress: (_, _) {}),
      throwsA(isA<UserError>()),
    );
    expect(await result.readAsBytes(), apkBytes);
    expect(await cache.list().toList(), hasLength(1));
  });

  test(
    'blocks redirects to other origins before sending the credential',
    () async {
      final source = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final other = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => source.close(force: true));
      addTearDown(() => other.close(force: true));
      var accessToOther = 0;
      other.listen((request) async {
        accessToOther++;
        await request.response.close();
      });
      source.listen((request) async {
        request.response.statusCode = 302;
        request.response.headers.set(
          HttpHeaders.locationHeader,
          'http://127.0.0.1:${other.port}/redirected',
        );
        await request.response.close();
      });
      final updater = GitHubUpdates(
        api: Uri.parse('http://127.0.0.1:${source.port}'),
      );
      await expectLater(updater.check(15, token), throwsA(isA<UserError>()));
      expect(accessToOther, 0);
    },
  );

  test('cancel closes the stream and removes the partial APK', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final finish = Completer<void>();
    server.listen((request) async {
      try {
        request.response.bufferOutput = false;
        request.response.contentLength = apkBytes.length;
        request.response.add(apkBytes.sublist(0, 2048));
        await request.response.flush();
        await finish.future;
        request.response.add(apkBytes.sublist(2048));
        await request.response.close();
      } on HttpException {
        // The caller closes its side of this deliberately unfinished response.
      }
    });
    final updater = GitHubUpdates(
      api: Uri.parse('http://127.0.0.1:${server.port}'),
    );
    final cache = await Directory.systemTemp.createTemp('alice-update-cancel-');
    addTearDown(() => cache.delete(recursive: true));
    try {
      await expectLater(
        updater.download(
          release,
          cache,
          token,
          onProgress: (_, _) => updater.cancel(),
        ),
        throwsA(
          isA<UserError>().having(
            (error) => error.message,
            'message',
            '已取消下载。',
          ),
        ),
      );
      expect(await cache.list().toList(), isEmpty);
    } finally {
      finish.complete();
    }
  });
}
