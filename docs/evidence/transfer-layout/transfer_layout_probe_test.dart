import 'dart:convert';
import 'dart:io';

import 'package:alice_companions/application/controller.dart';
import 'package:alice_companions/application/family.dart';
import 'package:alice_companions/data/device.dart';
import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/main.dart';
import 'package:file_picker/file_picker.dart';
// Use the locked file picker's Apple-platform file representation in this probe.
// ignore: depend_on_referenced_packages
import 'package:file_picker_darwin/file_picker_darwin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/families.dart';

const _password = 'Synthetic-Layout-Export-0212';
final _assets = (jsonDecode(
  File('assets/config/runtime_assets.json').readAsStringSync(),
) as Map<String, Object?>).keys.toSet();

class LayoutPicker extends FilePickerPlatform {
  LayoutPicker(this.file, this.suspend);

  final File file;
  final VoidCallback suspend;
  bool cancelSave = true;
  bool cancelPick = false;
  int saves = 0;
  int picks = 0;

  @override
  Future<Uri?> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? dialogTitle,
    String? initialDirectory,
    Function(FilePickerStatus)? onFileSaving,
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    expect(fileName, endsWith('.alicebackup'));
    expect(mimeType, 'application/octet-stream');
    saves++;
    suspend();
    if (cancelSave) return null;
    await file.writeAsBytes(bytes, flush: true);
    return Uri.parse('content://synthetic-test/transferred.alicebackup');
  }

  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    picks++;
    suspend();
    if (cancelPick) return null;
    return DarwinPlatformFile(
      name: 'transferred.alicebackup',
      uri: file.uri,
      bytesLength: await file.length(),
    );
  }
}

void main() {
  const viewports = [
    (Size(360, 800), 300.0, TargetPlatform.android),
    (Size(390, 844), 312.0, TargetPlatform.android),
    (Size(834, 1194), 350.0, TargetPlatform.iOS),
    (Size(1194, 834), 360.0, TargetPlatform.iOS),
  ];

  for (final (size, keyboard, platform) in viewports) {
    testWidgets(
      'transfer at ${size.width.toInt()}x${size.height.toInt()} with 130% text',
      (tester) async {
        final stock = (await tester.runAsync(
          () => TestFamily.create(pet: Companion.cat),
        ))!;
        final source = FamilyController(
          stock.device,
          stock.rules,
          assets: _assets,
        )..service = stock.service;
        final fileRoot = (await tester.runAsync(
          () => Directory.systemTemp.createTemp('alice-layout-fixture-'),
        ))!;
        final target = FamilyController(
          DeviceStore(
            Directory('${fileRoot.path}/target'),
            MemorySecureValues(),
          ),
          stock.rules,
          assets: _assets,
        );
        await tester.runAsync(() async {
          final parent = await stock.service.pin.unlock(TestFamily.pin);
          for (var i = 0; i < 7; i++) {
            await stock.service.backfill(
              const TaskDraft('测试任务A', '测试内容', '测试标准A', 'challenge'),
              stock.service.today,
              '',
              session: parent,
            );
          }
          stock.service.pin.lock();
          await source.refresh();
        });

        debugDefaultTargetPlatformOverride = platform;
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        const insets = FakeViewPadding(top: 24, bottom: 20);
        tester.view.viewPadding = insets;
        tester.view.padding = insets;
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(disableAnimations: true);
        final realPicker = FilePickerPlatform.instance;
        final picker = LayoutPicker(
          File('${fileRoot.path}/transferred.alicebackup'),
          () {
            tester.binding.handleAppLifecycleStateChanged(
              AppLifecycleState.inactive,
            );
            tester.binding.handleAppLifecycleStateChanged(
              AppLifecycleState.resumed,
            );
          },
        );
        FilePickerPlatform.instance = picker;
        tester.binding.addObserver(source);
        tester.binding.addObserver(target);
        addTearDown(() async {
          FilePickerPlatform.instance = realPicker;
          debugDefaultTargetPlatformOverride = null;
          tester.view.resetDevicePixelRatio();
          tester.view.resetPhysicalSize();
          tester.view.resetViewPadding();
          tester.view.resetPadding();
          tester.view.resetViewInsets();
          tester.platformDispatcher.clearTextScaleFactorTestValue();
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
          source.dispose();
          target.dispose();
          await stock.dispose();
          await target.service?.close();
          await fileRoot.delete(recursive: true);
        });

        Future<void> settle() async {
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          expect(tester.takeException(), isNull);
        }

        Future<void> keyInset(bool open) async {
          tester.view.viewInsets = open
              ? FakeViewPadding(bottom: keyboard)
              : const FakeViewPadding();
          tester.view.padding = open ? const FakeViewPadding(top: 24) : insets;
          await settle();
        }

        Future<void> waitFor(Finder target) async {
          final deadline = Stopwatch()..start();
          while (!tester.any(target) &&
              deadline.elapsed < const Duration(seconds: 16)) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 20)),
            );
            await tester.pump(const Duration(milliseconds: 16));
          }
          expect(target, findsOneWidget);
          await settle();
        }

        Finder field(String name) => find.byWidgetPredicate(
          (widget) =>
              widget is TextField && widget.decoration?.labelText == name,
        );

        Future<void> expose(Finder target) async {
          expect(target, findsOneWidget);
          await tester.ensureVisible(target);
          await settle();
          expect(target.hitTestable(), findsOneWidget);
        }

        Future<void> type(String label, String value) async {
          final input = field(label);
          await expose(input);
          await tester.enterText(input, value);
          await keyInset(true);
          await expose(input);
          expect(
            tester.getRect(input).center.dy,
            lessThan(size.height - keyboard),
          );
        }

        Future<void> tap(Finder target) async {
          await expose(target);
          final paragraph = tester.element(target).renderObject;
          if (paragraph is RenderParagraph) {
            expect(paragraph.didExceedMaxLines, isFalse);
          }
          final keyboardWasOpen = tester.view.viewInsets.bottom > 0;
          await tester.runAsync(() => tester.tap(target));
          if (keyboardWasOpen) await keyInset(false);
          await settle();
        }

        Future<void> text(String value) => tap(find.text(value));

        Future<void> unlock(String destination) async {
          await waitFor(find.text('家长解锁'));
          await type('家长 PIN', TestFamily.pin);
          await text('解锁');
          await waitFor(find.text(destination));
        }

        await tester.pumpWidget(CompanionsApp(controller: source));
        await settle();
        expect(source.family!.balance, 35);
        await tap(find.widgetWithText(TextButton, '伙伴'));
        await waitFor(find.text('正在陪伴'));
        expect(find.text('带回小家'), findsNothing);
        expect(find.text('用 30 分解锁'), findsNWidgets(2));
        await tap(find.text('用 30 分解锁').first);
        await text('确认解锁');
        await waitFor(find.text('1 级 · 0 经验'));
        expect(find.text('操作未完成，请重试。'), findsNothing);
        expect(source.family!.balance, 5);
        expect(source.family!.experience, 7);
        expect(find.text('用 30 分解锁'), findsNothing);
        await text('带回小家');
        await waitFor(find.byTooltip('家长入口'));
        expect(source.family!.companion, Companion.fox);
        expect(source.family!.experience, 0);
        await tap(find.byTooltip('家长入口'));
        await unlock('家长管理');
        await text('备份与迁移');
        await waitFor(find.text('外部加密备份'));
        await text('迁移到新设备');
        await type('备份口令（至少 10 个字符）', _password);
        await type('确认备份口令', _password);
        await text('生成并保存文件');
        await unlock('迁移到新设备');
        await waitFor(find.text('已取消文件保存。').first);
        expect(picker.saves, 1);
        expect(stock.service.frozen, isFalse);
        expect(picker.file.existsSync(), isFalse);
        for (final label in ['备份口令（至少 10 个字符）', '确认备份口令']) {
          expect(
            tester.widget<TextField>(field(label)).controller!.text.length,
            _password.length,
          );
        }

        picker.cancelSave = false;
        await text('生成并保存文件');
        await unlock('迁移到新设备');
        await waitFor(find.text('请确认文件已保存，再从数据页回读验证。').first);
        expect(picker.saves, 2);
        expect(stock.service.frozen, isTrue);
        expect(picker.file.existsSync(), isTrue);
        var control = (await tester.runAsync(source.transfer.status))!;
        expect(control['state'], 'AWAITING_FILE_VERIFICATION');
        expect(control['last_external_status'], 'unverified');
        await tap(find.byType(BackButton));
        await waitFor(find.text('回读验证导出文件'));
        await text('回读验证导出文件');
        await waitFor(find.text('选择备份文件'));

        picker.cancelPick = true;
        await text('选择备份文件');
        await unlock('回读验证');
        expect(find.text('transferred.alicebackup'), findsNothing);
        expect(
          (await tester.runAsync(
            source.transfer.status,
          ))!['last_external_status'],
          'unverified',
        );
        picker.cancelPick = false;
        await text('选择备份文件');
        await unlock('回读验证');
        await waitFor(find.text('transferred.alicebackup'));
        await type('原备份口令', _password);
        await text('验证文件');
        await waitFor(find.text('已验证外部文件。'));
        control = (await tester.runAsync(source.transfer.status))!;
        expect(control['state'], 'MIGRATION_PENDING');
        expect(control['last_external_status'], 'verified');

        await tester.pumpWidget(
          CompanionsApp(key: const ValueKey('target'), controller: target),
        );
        await settle();
        await text('从备份恢复');
        await text('选择备份文件');
        await waitFor(find.text('transferred.alicebackup'));
        await type('原备份口令', _password);
        await text('验证并预览');
        await waitFor(find.text('待恢复的小家'));
        expect(find.text('奶油 · 1 级 · 0 经验'), findsOneWidget);
        await type('新家长 PIN（6 位数字）', TestFamily.pin);
        await type('确认新家长 PIN', TestFamily.pin);
        await text('下一步');
        await text('我已妥善保存');
        await text('激活恢复后的存档');
        await waitFor(find.byTooltip('家长入口'));
        expect(target.family!.companion, Companion.fox);
        expect(target.family!.balance, 5);
        expect(target.family!.experience, 0);
        expect(target.family!.validCompletionCount, 7);
        expect((await tester.runAsync(target.service!.ledger))!.length, 8);
        final progress = (await tester.runAsync(
          target.service!.companionProgress,
        ))!;
        expect(
          (progress[Companion.cat]!.stage, progress[Companion.cat]!.experience),
          (2, 7),
        );
        expect(
          (progress[Companion.fox]!.stage, progress[Companion.fox]!.experience),
          (1, 0),
        );
        expect(progress[Companion.rabbit], isNull);
        expect(picker.picks, 3);

        await tester.pumpWidget(
          CompanionsApp(key: const ValueKey('source'), controller: source),
        );
        await settle();
        await tap(find.byTooltip('家长入口'));
        await unlock('家长管理');
        await text('备份与迁移');
        await waitFor(find.text('归档旧设备'));
        await text('归档旧设备');
        await text('确认归档');
        await waitFor(find.text('这台设备已归档，可查看原有成果。'));
        expect(
          (await tester.runAsync(source.transfer.status))!['state'],
          'ARCHIVED',
        );
        expect(stock.service.frozen, isTrue);
        expect(tester.takeException(), isNull);
        stdout.writeln(
          'AC36 ${size.width.toInt()}x${size.height.toInt()} ${platform.name} text=130% keyboard=${keyboard.toInt()} logical px. Unlocked Cream at level 1 and 0 XP for 30 points. Save and pick cancelled, parent reauthenticated, readback verified, seven completions and two independent companion levels restored, source archived.',
        );
        debugDefaultTargetPlatformOverride = null;
        await tester.pumpWidget(const SizedBox.shrink());
        await settle();
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );
  }
}
