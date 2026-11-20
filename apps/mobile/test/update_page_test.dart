import 'dart:async';
import 'dart:io';

import 'package:alice_companions/application/app_update.dart';
import 'package:alice_companions/application/controller.dart';
import 'package:alice_companions/features/update_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/families.dart';

final _candidate = AndroidRelease.read({
  'schema': 1,
  'version': '0.18.0',
  'versionCode': 16,
  'file': 'alice-0.18.0-android.apk',
  'sha256': '1' * 64,
  'sizeBytes': 100,
});

class _ProbeUpdates extends GitHubUpdates {
  final checkedTokens = <String?>[];
  int downloads = 0;
  bool private = false;

  @override
  Future<AndroidRelease?> check(int installed, [String? token]) async {
    checkedTokens.add(token);
    if (private && token == null) throw const UpdateAuthorizationRequired();
    return _candidate;
  }

  @override
  Future<File> download(
    AndroidRelease release,
    Directory cache,
    String? token, {
    required void Function(int, int) onProgress,
  }) async {
    downloads++;
    return File('${cache.path}/family-update.apk');
  }
}

class _ProbeInstaller extends AndroidInstaller {
  Future<Directory>? pendingCache;
  int launches = 0;

  @override
  Future<Directory> cache() async =>
      await pendingCache ?? Directory('/fixture');

  @override
  Future<({String name, int code})> installed() async =>
      (name: '0.17.0', code: 15);

  @override
  Future<InstallHandoff> install(File file, int versionCode) async {
    expect(versionCode, 16);
    launches++;
    if (launches == 1) return InstallHandoff.permission;
    if (launches == 2) {
      throw PlatformException(code: 'update_path', message: '更新包已清理，请重新下载。');
    }
    return InstallHandoff.launched;
  }
}

Future<void> _open(
  WidgetTester tester,
  _ProbeInstaller installer,
  _ProbeUpdates updates,
) async {
  final stock = (await tester.runAsync(TestFamily.create))!;
  final controller = FamilyController(stock.device, stock.rules)
    ..service = stock.service;
  addTearDown(() async {
    controller.dispose();
    await stock.dispose();
  });
  await tester.runAsync(() async {
    controller.session = await stock.service.pin.unlock(TestFamily.pin);
  });
  await tester.pumpWidget(
    MaterialApp(
      home: UpdatePage(
        controller: controller,
        installer: installer,
        updates: updates,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _press(
  WidgetTester tester,
  String label, {
  bool settle = true,
}) async {
  final target = find.text(label);
  await tester.ensureVisible(target);
  await tester.tap(target);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

void main() {
  testWidgets(
    'public check is explicit and cancelling before cache selection prevents a request',
    (tester) async {
      final cache = Completer<Directory>();
      final installer = _ProbeInstaller()..pendingCache = cache.future;
      final updates = _ProbeUpdates();
      await _open(tester, installer, updates);
      expect(updates.checkedTokens, isEmpty);
      expect(find.text('当前版本 0.17.0'), findsOneWidget);
      await _press(tester, '检查更新');
      expect(updates.checkedTokens, [null]);
      await _press(tester, '下载并安装', settle: false);
      await _press(tester, '取消下载', settle: false);
      cache.complete(Directory('/fixture'));
      await tester.pumpAndSettle();
      expect(find.text('已取消下载。'), findsOneWidget);
      expect(updates.downloads, 0);
      expect(installer.launches, 0);
    },
  );

  testWidgets(
    'private access prompts for local credentials after the anonymous check',
    (tester) async {
      final updates = _ProbeUpdates()..private = true;
      await _open(tester, _ProbeInstaller(), updates);
      expect(find.byType(TextField), findsNothing);
      await _press(tester, '检查更新');
      await tester.enterText(find.byType(TextField), 'fixture_read_only');
      await _press(tester, '保存令牌');
      await _press(tester, '检查更新');
      expect(updates.checkedTokens, [null, 'fixture_read_only']);
      expect(find.text('可更新到 0.18.0'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    },
  );

  testWidgets(
    'missing cached APK after permission leaves the download action available',
    (tester) async {
      final installer = _ProbeInstaller();
      final updates = _ProbeUpdates();
      await _open(tester, installer, updates);
      await _press(tester, '检查更新');
      await _press(tester, '下载并安装');
      expect(find.text('安装更新'), findsOneWidget);
      await _press(tester, '安装更新');
      expect(find.text('更新包已清理，请重新下载。'), findsOneWidget);
      await _press(tester, '下载并安装');
      expect(find.text('请在系统安装界面确认更新。'), findsOneWidget);
      expect(updates.downloads, 2);
    },
  );
}
