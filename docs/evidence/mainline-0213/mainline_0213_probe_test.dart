import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:alice_companions/application/controller.dart';
import 'package:alice_companions/application/family.dart';
import 'package:alice_companions/application/transfer.dart';
import 'package:alice_companions/data/device.dart';
import 'package:alice_companions/data/snapshot.dart';
import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/domain/pin.dart';
import 'package:alice_companions/domain/rain_map.dart';
import 'package:alice_companions/features/home.dart';
import 'package:alice_companions/features/rain_map_chapter.dart';
import 'package:alice_companions/main.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/families.dart';

final evidence = Directory(Platform.environment['ALICE_STORY_EVIDENCE']!);
final fonts = Directory(Platform.environment['ALICE_STORY_FONTS']!);
final scenes = GlobalKey();

void main() {
  testWidgets(
    'family mainline keeps two companions’ accounting through both endings and replay',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final assets = (jsonDecode(
        File('assets/config/runtime_assets.json').readAsStringSync(),
      ) as Map).keys.cast<String>().toSet();
      final household = (await tester.runAsync(
        () => TestFamily.create(pet: Companion.rabbit),
      ))!;
      var controller = FamilyController(
        household.device,
        household.rules,
        assets: assets,
      )..service = household.service;
      addTearDown(() async {
        controller.dispose();
        await household.dispose();
      });
      final events = <String>[];
      void observed(String text) {
        events.add(text);
        stdout.writeln('PLAY $text');
      }

      await tester.runAsync(() async {
        final auth = await household.service.pin.unlock(TestFamily.pin);
        const funding = TaskDraft('测试任务A', '', '测试标准A', 'challenge');
        for (var i = 0; i < 6; i++) {
          await household.service.backfill(
            funding,
            household.service.today,
            '',
            session: auth,
          );
        }
        await household.service.unlockCompanion(Companion.cat);
        await household.service.selectCompanion(Companion.cat);
        await household.service.backfill(
          const TaskDraft('测试任务B', '', '测试标准B', 'focus'),
          household.service.today,
          '测试反馈',
          session: auth,
        );
        await controller.refresh();
        final icons = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await icons.load();
        for (final family in [
          'FlutterTest',
          'Ahem',
          'Arial',
          'Ubuntu',
          'Adwaita Sans',
          'Cantarell',
          'DejaVu Sans',
          'Liberation Sans',
          'sans-serif',
        ]) {
          final loader = FontLoader(family);
          for (final weight in ['Regular', 'Bold']) {
            final bytes = await File('${fonts.path}/qa-$weight.otf')
                .readAsBytes();
            loader.addFont(Future.value(ByteData.sublistView(bytes)));
          }
          await loader.load();
        }
        for (final name in ['Roboto', 'serif']) {
          final bytes = await File(
            '/usr/share/fonts/opentype/noto/Noto${name == 'Roboto' ? 'Sans' : 'Serif'}CJK-Regular.ttc',
          ).readAsBytes();
          final loader = FontLoader(name)
            ..addFont(Future.value(ByteData.sublistView(bytes)));
          await loader.load();
        }
      });
      Future<Map<String, Object>> accounting([FamilyService? restored]) async {
        final service = restored ?? household.service;
        final home = (await service.overview())!;
        final ledger = await service.ledger();
        final progress = await service.companionProgress();
        return {
          'balance': home.balance,
          'active': home.companion.name,
          'ledger_entries': ledger.length,
          'ledger_sha256': sha256
              .convert(utf8.encode(jsonEncode(ledger)))
              .toString(),
          'progress': {
            for (final entry in progress.entries)
              entry.key.name: {
                'level': entry.value.stage,
                'experience': entry.value.experience,
              },
          },
        };
      }

      final before = (await tester.runAsync(accounting))!;
      expect(before['balance'], 3);
      expect(before['ledger_entries'], 8);
      expect(before['active'], 'cat');
      expect(before['progress'], {
        'cat': {'level': 1, 'experience': 1},
        'rabbit': {'level': 2, 'experience': 6},
      });

      Future<Map<String, Object>> restoreRecordedPlay() async {
        final source = household.service;
        final password = '剧情复测-${DateTime.now().microsecondsSinceEpoch}';
        final session = await source.pin.unlock(TestFamily.pin);
        final transfer = controller.transfer;
        final ticket = await transfer.prepareExport(
          'backup',
          password,
          session,
        );
        final archive = await ticket.file.copy(
          '${household.root.path}/story.alicebackup',
        );
        final archiveDigest = (await sha256.bind(archive.openRead()).single)
            .toString();
        await transfer.finishExport(ticket, SaveOutcome.handedToSystem);
        await transfer.verifyExternal(archive, password, session);
        expect(source.frozen, isFalse);
        expect(await accounting(), before);

        final targetDevice = DeviceStore(
          Directory('${household.root.path}/restored'),
          MemorySecureValues(),
        );
        FamilyService? targetFamily;
        final target = TransferService(
          device: targetDevice,
          rules: household.rules,
          availableAssets: assets,
          current: () => targetFamily,
        );
        final preview = await target.inspect(archive, password, null);
        try {
          final restored = (await target.activate(
            preview,
            '${int.parse(TestFamily.pin) + 1}',
            PinGate.newRecoveryCode(),
            session: null,
            replace: false,
          )).service;
          targetFamily = restored;
          final home = (await restored.overview())!;
          final rain = await restored.rainMapProgress();
          final wind = await restored.windProgress();
          expect(
            (home.windowsLit, home.rainMapCleared, home.bond.label),
            (true, true, '默契'),
          );
          expect(wind.complete, isTrue);
          expect(
            (
              rain.run,
              rain.stamps,
              rain.stones,
              rain.cleared,
              rain.challengeSolved,
            ),
            (2, 0, 1, true, true),
          );
          expect(await accounting(restored), before);
          final snapshot = await checkSnapshot(
            targetDevice.databaseFile(restored.pin.generation).path,
            await target.schema,
            household.rules,
            assets,
          );
          expect(snapshot.businessDigest, preview.info.businessDigest);
          await restored.selectCompanion(Companion.rabbit);
          expect((await restored.overview())!.bond.label, '初见');
          await restored.selectCompanion(Companion.cat);
          expect((await restored.overview())!.bond.label, '默契');
          return {
            'archive_sha256': archiveDigest,
            'business_sha256': snapshot.businessDigest,
            'replay_run': rain.run,
            'replay_stone': rain.stones,
            'windows_lit': home.windowsLit,
            'shortcut_solved': rain.challengeSolved,
            'active_bond': home.bond.label,
            'other_bond': '初见',
            'accounting': await accounting(restored),
          };
        } finally {
          await targetFamily?.close();
          await preview.close();
        }
      }

      Future<void> frames() async {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 40));
      }

      Future<void> mount() async {
        await tester.pumpWidget(
          RepaintBoundary(
            key: scenes,
            child: CompanionsApp(controller: controller),
          ),
        );
        await frames();
      }

      Future<void> awaitTarget(Finder f) async {
        for (int i = 0; i < 160 && f.evaluate().isEmpty; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 25)),
          );
          await tester.pump(const Duration(milliseconds: 20));
        }
        expect(f, findsOneWidget);
      }

      Future<void> press(Finder f, {bool scroll = false}) async {
        await awaitTarget(f);
        if (scroll) await tester.ensureVisible(f);
        await frames();
        expect(f.hitTestable(), findsOneWidget);
        await tester.runAsync(() async {
          await tester.tap(f);
          await household.service.db.value('SELECT 1');
          await household.service.serial.run(() async {});
          await Future<void>.delayed(const Duration(milliseconds: 8));
        });
        await frames();
      }

      Future<void> snap(String name) async {
        await tester.runAsync(() async {
          final ctx = scenes.currentContext!;
          await Future.wait(
            find
                .byType(Image)
                .evaluate()
                .map(
                  (element) =>
                      precacheImage((element.widget as Image).image, ctx),
                ),
          );
        });
        await frames();
        final boundary =
            scenes.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          final buf = await image.toByteData(format: ui.ImageByteFormat.png);
          image.dispose();
          await File('${evidence.path}/$name.png')
              .writeAsBytes(buf!.buffer.asUint8List(), flush: true);
        });
      }

      Future<void> rainFromHome() async {
        final home = find.text('主线');
        await awaitTarget(home);
        expect(home.hitTestable(), findsOneWidget);
        final button = find.ancestor(
          of: home,
          matching: find.byWidgetPredicate(
            (w) => w is TextButton && w.onPressed != null,
          ),
        );
        await awaitTarget(button);
        await press(home);
        await awaitTarget(find.text('风过暖廊'));
        await frames();
        expect(find.text('风过暖廊').hitTestable(), findsOneWidget);
        await press(find.text(rainMapTitle));
        await awaitTarget(find.byType(RainMapChapter));
      }

      Future<void> restartController() async {
        await tester.pumpWidget(const SizedBox());
        await frames();
        controller.dispose();
        await tester.runAsync(() async {
          await household.service.close();
          controller = FamilyController(
            household.device,
            household.rules,
            assets: assets,
          );
          await controller.open();
          household.service = controller.service!;
        });
        await mount();
      }

      Future<void> stone(int zeroBased) async {
        final target = find.bySemanticsLabel('第${zeroBased + 1}块石板，下一块');
        await press(target);
        await awaitTarget(find.bySemanticsLabel('第${zeroBased + 1}块石板，已踩过'));
      }

      Future<void> stamp(int number) async {
        await press(find.text('盖爪印'), scroll: true);
        if (number == 4) {
          await awaitTarget(find.textContaining('四个爪印领我走过了十二块石板'));
        } else {
          await awaitTarget(find.bySemanticsLabel('地图上有$number个爪印，共4个。盖爪印'));
        }
      }

      Future<void> dataCheck(
        int stamps,
        int stones, {
        bool challenge = false,
      }) async {
        await tester.runAsync(() async {
          final progress = await household.service.rainMapProgress();
          expect(
            (progress.stamps, progress.stones, progress.challengeSolved),
            (stamps, stones, challenge),
          );
          expect(await accounting(), before);
        });
      }

      await mount();
      expect(find.byType(FamilyHome), findsOneWidget);
      expect(find.text('3 分'), findsOneWidget);
      await press(find.text('摸摸团团'));
      await press(find.text('过来'));
      final bond = await tester.runAsync(
        () async => (await household.service.overview())!.bond,
      );
      expect(bond?.label, '默契');
      expect(await tester.runAsync(accounting), before);
      observed('团团通过小家的触摸和呼唤获得两件回忆，余额和两位伙伴的经验一致。');
      expect(find.text('主线 · 风过暖廊').hitTestable(), findsOneWidget);
      await press(find.text('主线 · 风过暖廊'));
      await press(find.text('直接去窗边'));
      final basket = find.byKey(const ValueKey('wind-basket'));
      for (final i in [7, 8, 9, 10, 11]) {
        await press(basket);
        await press(find.byKey(ValueKey('wind-pane-$i')));
      }
      await press(find.text('看团聚结果'));
      await press(find.text('回暖廊看窗光'));
      await awaitTarget(find.text('主线'));
      observed('从正式家庭首页完成前章五次取叶嵌窗，返回小家后主线开放两章。');
      await rainFromHome();
      await awaitTarget(find.text('和奶油出发'));
      expect(find.textContaining('雨把路上的脚印冲掉了'), findsOneWidget);
      await press(find.text('和奶油出发'));
      await awaitTarget(find.text('盖爪印'));
      await press(find.text('盖爪印'), scroll: true);
      expect(find.textContaining('还差3块石板'), findsOneWidget);
      await press(find.bySemanticsLabel('第3块石板'));
      expect(find.textContaining('先踩第一块石板'), findsOneWidget);
      await stone(0);
      await stone(1);
      await dataCheck(0, 2);
      await press(find.byType(BackButton));
      await rainFromHome();
      expect(find.bySemanticsLabel('第3块石板，下一块'), findsOneWidget);
      await restartController();
      await rainFromHome();
      await awaitTarget(find.bySemanticsLabel('第3块石板，下一块'));
      await dataCheck(0, 2);
      await snap('rain-resumed');
      observed('少石请求盖章、先点第3块都给可执行提示。第一段前两块分别在退出章节和重开同一 SQLite 家庭后保留。');
      await stone(2);
      await stamp(1);
      for (int group = 2; group <= 4; group++) {
        for (int i = 0; i < 3; i++) {
          await stone(i);
        }
        await stamp(group);
      }
      await dataCheck(4, 0);
      expect(find.bySemanticsLabel('地图上有4个爪印，共4个'), findsOneWidget);
      observed('四段各踩3块并手动盖印。第4印显示12块的团聚结局。');
      await press(find.text('帮桃桃铺近路'), scroll: true);
      for (int i = 0; i < 8; i++) {
        await press(find.text('铺一块'));
      }
      await press(find.text('带桃桃过桥'));
      expect(find.textContaining('还有爪印没配满'), findsOneWidget);
      await press(find.text('铺一块'));
      expect(find.bySemanticsLabel('已经铺了9块石板'), findsOneWidget);
      await press(find.text('铺一块'));
      await press(find.text('带桃桃过桥'));
      expect(find.textContaining('收回多出来的石板'), findsOneWidget);
      await press(find.text('收回一块'));
      await press(find.text('带桃桃过桥'));
      await awaitTarget(find.textContaining('还学会了走三个爪印的近路'));
      await dataCheck(4, 0, challenge: true);
      observed('近路8块和10块均只能纠正。减回9块后桃桃过桥，出现近路结局。');
      await press(find.text('回小家'), scroll: true);
      await restartController();
      await press(find.text('成长'));
      await press(find.text('伙伴回忆'), scroll: true);
      await awaitTarget(find.text(rainMapTitle));
      expect(find.text('暖廊的三扇彩窗'), findsOneWidget);
      expect(find.text('第一次摸摸团团'), findsOneWidget);
      expect(find.text('第一次叫团团过来'), findsOneWidget);
      expect(find.bySemanticsLabel('地图上有4个爪印，共4个'), findsOneWidget);
      await snap('companion-memories');
      await dataCheck(4, 0, challenge: true);
      await press(find.byType(BackButton));
      await press(find.text('小家'));
      await rainFromHome();
      await awaitTarget(find.textContaining('还学会了走三个爪印的近路'));
      expect(find.text('帮桃桃铺近路'), findsNothing);
      observed('重开后在成长的伙伴回忆看到两章、团团的两件回忆及四印地图，主线保留近路结局。');
      await press(find.text('再走一遍'), scroll: true);
      await awaitTarget(find.bySemanticsLabel('第1块石板，下一块'));
      await stone(0);
      await restartController();
      await rainFromHome();
      await awaitTarget(find.bySemanticsLabel('第2块石板，下一块'));
      await dataCheck(0, 1, challenge: true);
      final resumed = (await tester.runAsync(
        household.service.rainMapProgress,
      ))!;
      expect(
        (resumed.run, resumed.cleared, resumed.challengeSolved),
        (2, true, true),
      );
      final after = (await tester.runAsync(accounting))!;
      expect(after, before);
      await snap('rain-replay');
      observed('重玩第二轮第一块石板在重开后保留，原结局和近路已完成。全程保留3分、8条流水、团团1经验与桃桃6经验。');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await frames();
      final backup = (await tester.runAsync(restoreRecordedPlay))!;
      observed('加密备份在独立测试档恢复后，两章结局、近路、重玩书签、亲密度及各自经验均读回。');
      final report = const JsonEncoder.withIndent('  ').convert({
        'before': before,
        'after': after,
        'replay': {
          'run': resumed.run,
          'stamps': resumed.stamps,
          'stones': resumed.stones,
          'cleared': resumed.cleared,
          'challenge_solved': resumed.challengeSolved,
        },
        'restored_backup': backup,
        'observations': events,
      });
      await tester.runAsync(
        () =>
            File('${evidence.path}/verification.json')
                .writeAsString('$report\n'),
      );
    },
    timeout: const Timeout(Duration(minutes: 6)),
  );
}
