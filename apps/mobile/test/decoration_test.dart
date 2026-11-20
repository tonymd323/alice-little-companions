import 'dart:convert';
import 'dart:io';

import 'package:alice_companions/application/family.dart';
import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/domain/layout_rules.dart';
import 'package:alice_companions/domain/pin.dart';
import 'package:alice_companions/domain/rules.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/families.dart';

const task = TaskDraft('测试任务A', '', '测试标准A', 'challenge');

void main() {
  test('AC-16/19/20 18 products, 5 independent spaces, layout and refund without income', () async {
    final fixture = await TestFamily.create();
    addTearDown(fixture.dispose);
    final service = fixture.service;
    final parent = await service.pin.unlock(TestFamily.pin);
    expect((await service.spaces()).single['scene_id'], 'base_room');
    expect((await service.overview())!.balance, 0);
    final cost = fixture.rules.catalog.values.fold(
      0,
      (sum, row) => sum + (row['price'] as int),
    );
    final companionPrice = fixture.rules.companionUnlockPrice;
    final confirmed = ((cost + companionPrice) / 5).ceil();
    for (var count = 0; count < confirmed; count++) {
      await service.backfill(task, service.today, '测试反馈', session: parent);
    }
    for (final product in fixture.rules.catalog.values) {
      final id = product['id'] as String;
      final first = await service.purchase(id);
      expect(first['charged'], product['price']);
      final duplicate = await service.purchase(id);
      expect(duplicate['id'], first['id']);
      expect(duplicate['charged'], 0);
    }
    expect(await service.purchases(), hasLength(18));
    final spaces = await service.spaces();
    expect(spaces.map((s) => s['scene_id']).toSet(), {
      'base_room',
      'garden',
      'treehouse',
      'flower_shop',
      'pastry_shop',
    });
    for (final space in spaces.where((s) => s['scene_id'] != 'base_room')) {
      expect(await service.layout(space['id'] as String), hasLength(3));
    }
    final base =
        spaces.singleWhere((s) => s['scene_id'] == 'base_room')['id'] as String;
    final unlocked =
        spaces.singleWhere((s) => s['scene_id'] == 'garden')['id'] as String;
    final planning = await service.items();
    String owned(String id) =>
        planning.singleWhere((row) => row['item_id'] == id)['id'] as String;
    final plant = owned('decor_plant');
    final mobile = owned('decor_mobile');
    final scarf = owned('accessory_scarf');
    final floor = SceneDefinition(service.rules, 'base_room');
    final hanging = floor.snap(
      PlacementDraft(mobile, .34, .25, 1),
      'item_decor_mobile',
    );
    expect(hanging.mount, 'porch_eave');
    await expectLater(
      service.saveLayout(base, 0, [PlacementDraft(plant, .82, .86, 0)]),
      throwsA(isA<UserError>()),
    );
    await expectLater(
      service.saveLayout(base, 0, [PlacementDraft(mobile, .29, .85, 0)]),
      throwsA(isA<UserError>()),
    );
    await service.saveLayout(base, 0, [
      PlacementDraft(plant, .30, .82, 0),
      hanging,
      const PlacementDraft('base_rug', .25, .89, 2),
    ]);
    expect(await service.layout(base), hasLength(3));
    final installed = (await service.layout(unlocked))
        .map(PlacementDraft.fromRow)
        .toList();
    await service.saveLayout(unlocked, 0, [
      ...installed,
      PlacementDraft(plant, .51, .86, 3),
    ]);
    expect(
      (await service.layout(base)).where((x) => x['entitlement_id'] == plant),
      isEmpty,
    );
    expect(
      (await service.layout(unlocked))
          .where((x) => x['entitlement_id'] == plant),
      hasLength(1),
    );
    await expectLater(
      service.saveLayout(base, 2, [
        const PlacementDraft('base_bed', .2, .49, 0),
      ]),
      throwsA(isA<UserError>()),
    );
    await service.renameSpace(unlocked, 1, '测试空间');
    for (final companion in Companion.values) {
      await service.saveOutfit(companion, {
        'neck': scarf,
      }, (await service.overview())!.revision);
    }
    await service.unlockCompanion(Companion.cat);
    await service.selectCompanion(Companion.cat);
    final before = (await service.overview())!;
    expect(before.balance, confirmed * 5 - cost - companionPrice);
    await service.processCalendar();
    await fixture.reopen();
    final restored = fixture.service;
    for (final pet in Companion.values) {
      expect((await restored.wardrobe(pet)).single['entitlement_id'], scarf);
    }
    expect((await restored.overview())!.companion, Companion.cat);
    expect(
      (await restored.spaces()).singleWhere((s) => s['id'] == unlocked)['name'],
      '测试空间',
    );
    expect(await restored.layout(unlocked), hasLength(4));
    expect(await restored.layout(base), hasLength(2));
    expect((await restored.overview())!.balance, before.balance);
    final purchase = (await restored.purchases()).singleWhere(
      (row) => row['item_id'] == 'garden',
    );
    final buyId = purchase['id'] as String;
    await expectLater(restored.refund(buyId), throwsA(isA<UserError>()));
    final administrator = await restored.pin.unlock(TestFamily.pin);
    await restored.refund(buyId, session: administrator);
    await restored.refund(buyId, session: administrator);
    expect(await restored.layout(unlocked), isEmpty);
    expect((await restored.items()).any((i) => i['id'] == plant), isTrue);
    expect(
      (await restored.items()).any((i) => i['item_id'] == 'garden_bench'),
      isFalse,
    );
    expect((await restored.overview())!.balance, before.balance + 90);
    await restored.verifyAccounting();
  }, timeout: const Timeout(Duration(minutes: 4)));

  test(
    'AC-16 child can undo the original charge once in the current session',
    () async {
      final fixture = await TestFamily.create();
      addTearDown(fixture.dispose);
      final service = fixture.service;
      final parent = await service.pin.unlock(TestFamily.pin);
      for (var i = 0; i < 2; i++) {
        await service.backfill(task, service.today, '', session: parent);
      }
      final id = (await service.purchase('decor_vase'))['id'] as String;
      expect(service.canChildUndo(id), isTrue);
      await service.refund(id);
      await service.refund(id);
      expect((await service.overview())!.balance, 10);
      expect(await service.items(), isEmpty);
      expect(await service.ledger(), hasLength(4));
    },
  );

  test('AC-35 all catalog assets, 19 companion poses and five layered scenes are bundled', () {
    final packaged = jsonDecode(
      File('assets/config/runtime_assets.json').readAsStringSync(),
    ) as Json;
    final manifest = jsonDecode(
      File('../../design/asset_manifest.json').readAsStringSync(),
    ) as Json;
    final production = (manifest['production_assets'] as List).cast<Json>();
    expect(packaged, hasLength(production.length));
    for (final item in production) {
      final file = File(packaged[item['id']] as String);
      expect(file.existsSync(), isTrue, reason: item['id'] as String);
      expect(sha256.convert(file.readAsBytesSync()).toString(), item['sha256']);
    }
    expect(Companion.cat.artwork(4), endsWith('cat-4-rest.webp'));
    expect(Companion.cat.artwork(4, reveal: true), endsWith('cat-4.webp'));
  });
}
