import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:alice_companions/application/app_update.dart';
import 'package:alice_companions/application/controller.dart';
import 'package:alice_companions/features/update_page.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/families.dart';

class _LoopbackHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.findProxy = (url) {
      expect(url.host, InternetAddress.loopbackIPv4.address);
      return 'DIRECT';
    };
    return client;
  }
}

class _TemporaryInstaller extends AndroidInstaller {
  const _TemporaryInstaller(this.directory);

  final Directory directory;

  @override
  Future<Directory> cache() async => directory;
}

Future<void> _waitFor(WidgetTester tester, Finder target) async {
  final elapsed = Stopwatch()..start();
  while (!tester.any(target) && elapsed.elapsed < const Duration(seconds: 40)) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 15)),
    );
    await tester.pump(const Duration(milliseconds: 20));
  }
  expect(target, findsOneWidget);
}

Future<void> _tap(WidgetTester tester, String label) async {
  final target = find.text(label);
  await _waitFor(tester, target);
  await tester.ensureVisible(target);
  await tester.runAsync(() => tester.tap(target));
  await tester.pump();
}

void main() {
  testWidgets(
    'published signed APK streams through the family update flow and is reused after permission',
    (tester) async {
      final previousHttpOverride = HttpOverrides.current;
      HttpOverrides.global = _LoopbackHttpOverrides();
      addTearDown(() => HttpOverrides.global = previousHttpOverride);
      final fixture = Directory(
        Platform.environment['ALICE_UPDATE_FIXTURE_DIR']!,
      );
      final manifestFile = File('${fixture.path}/github-latest.json');
      final archive = File('${fixture.path}/github-0211.apk');
      final manifest = manifestFile.readAsBytesSync();
      final release = AndroidRelease.read(jsonDecode(utf8.decode(manifest)));
      expect(release.version, '0.21.1');
      expect(release.versionCode, 20);
      expect(archive.lengthSync(), release.sizeBytes);

      const apiPath =
          '/repos/tonymd323/alice-little-companions/contents/downloads';
      const token = 'fixture_read_only';
      final requests = <(String path, String? branch, bool authorized)>[];
      final hasExpectedHeaders = <bool>[];
      final server = (await tester.runAsync(
        () => HttpServer.bind(InternetAddress.loopbackIPv4, 0),
      ))!;
      addTearDown(() => server.close(force: true));
      await tester.runAsync(() async {
        server.listen((request) async {
          final authorized =
              request.headers.value(HttpHeaders.authorizationHeader) ==
              'Bearer $token';
          requests.add((
            request.uri.path,
            request.uri.queryParameters['ref'],
            authorized,
          ));
          hasExpectedHeaders.add(
            request.headers.value(HttpHeaders.acceptHeader) ==
                    'application/vnd.github.raw+json' &&
                request.headers.value('X-GitHub-Api-Version') == '2022-11-28',
          );
          final response = request.response;
          if (!authorized ||
              request.uri.queryParameters['ref'] != 'android-downloads') {
            response.statusCode = HttpStatus.notFound;
          } else if (request.uri.path == '$apiPath/latest.json') {
            response.contentLength = manifest.length;
            response.add(manifest);
          } else if (request.uri.path == '$apiPath/${release.file}') {
            response.contentLength = release.sizeBytes;
            await response.addStream(archive.openRead());
          } else {
            response.statusCode = HttpStatus.notFound;
          }
          await response.close();
        });
      });

      final family = (await tester.runAsync(TestFamily.create))!;
      final controller = FamilyController(family.device, family.rules)
        ..service = family.service;
      addTearDown(() async {
        controller.dispose();
        await family.dispose();
      });
      await tester.runAsync(() => controller.unlock(TestFamily.pin));

      final cache = Directory('${family.root.path}/update-cache');
      const channel = MethodChannel('alice/update');
      final mock =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      int installRequests = 0;
      mock.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'installed') {
          return {'versionName': '0.21.0', 'versionCode': 19};
        }
        expect(call.method, 'install');
        expect(call.arguments['versionCode'], 20);
        final file = File(call.arguments['path'] as String);
        expect(file.parent.path, cache.path);
        expect(await file.length(), release.sizeBytes);
        expect(
          (await sha256.bind(file.openRead()).single).toString(),
          release.hash,
        );
        installRequests++;
        return installRequests == 1 ? 'permission' : 'launched';
      });
      addTearDown(() => mock.setMockMethodCallHandler(channel, null));
      final updater = GitHubUpdates(api: Uri.http('127.0.0.1:${server.port}'));
      await tester.pumpWidget(
        MaterialApp(
          home: UpdatePage(
            controller: controller,
            updates: updater,
            installer: _TemporaryInstaller(cache),
          ),
        ),
      );
      await _waitFor(tester, find.text('当前版本 0.21.0'));
      await _tap(tester, '检查更新');
      await _waitFor(tester, find.text('GitHub 只读令牌'));
      await tester.enterText(find.byType(TextField), token);
      await _tap(tester, '保存令牌');
      await _waitFor(tester, find.text('更换令牌'));

      await _tap(tester, '检查更新');
      await _waitFor(tester, find.text('可更新到 0.21.1'));
      await _tap(tester, '下载并安装');
      await _waitFor(tester, find.textContaining('允许此应用安装更新后'));
      expect(installRequests, 1);

      controller.lock();
      await _waitFor(tester, find.text('家长解锁'));
      await tester.runAsync(() => controller.unlock(TestFamily.pin));
      await _tap(tester, '安装更新');
      await _waitFor(tester, find.text('请在系统安装界面确认更新。'));
      expect(installRequests, 2);
      final files = await tester.runAsync(() => cache.list().toList());
      expect(files!.map((entry) => entry.path), [
        '${cache.path}/family-update.apk',
      ]);
      expect(requests, [
        ('$apiPath/latest.json', 'android-downloads', false),
        ('$apiPath/latest.json', 'android-downloads', true),
        ('$apiPath/${release.file}', 'android-downloads', true),
      ]);
      expect(hasExpectedHeaders, everyElement(isTrue));
      final alreadyUpdated = await tester.runAsync(
        () => updater.check(20, token),
      );
      expect(alreadyUpdated, isNull);

      stdout.writeln(
        'APK-UPDATE ${jsonEncode({'version_code': release.versionCode, 'apk_bytes': release.sizeBytes, 'sha256': release.hash, 'raw_api_headers_verified': true, 'unauthenticated_prompt_verified': true, 'apk_get_requests': 1, 'installer_channel_requests': installRequests, 'cache_reused_after_parent_unlock': true, 'already_installed_version_ignored': true})}',
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
