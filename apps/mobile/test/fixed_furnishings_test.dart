import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:alice_companions/application/family.dart';
import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/domain/layout_rules.dart'
    show PlacementDraft, artworkPath;
import 'package:alice_companions/illustration/puppet.dart';
import 'package:alice_companions/illustration/room_painting.dart';
import 'package:alice_companions/illustration/tailoring.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/families.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'all catalogue previews and the starter room at zero balance are read-only',
    () async {
      final f = await TestFamily.create();
      addTearDown(f.dispose);
      final s = f.service, base = (await s.spaces()).single['id'] as String;
      final revision = (await s.overview())!.revision;
      final pieces = (await s.furnishings(base))
          .map(ScenePiece.fromRow)
          .toList();
      expect(pieces.map((p) => p.asset), ['base_bed', 'base_rug']);
      for (final product in f.rules.catalog.values) {
        if (product['slot'] != null) {
          final asset = product['asset_id'] as String;
          final image = product['slot'] == 'body'
              ? portraitArtwork(Companion.rabbit, 1, false, asset)
              : wornArtwork(asset);
          expect(File(image).existsSync(), isTrue);
          continue;
        }
        final space = product['space_id'] as String?;
        final look = ScenePiece.preview(product);
        final room = RoomPainting(space ?? 'base_room', [
          if (space == null) ...pieces,
          ...look,
        ]);
        if (space == null) {
          expect(
            room.frameFor(look),
            isNotNull,
            reason: product['id'] as String,
          );
          for (final layer in room.layers) {
            expect(File(layer.art).existsSync(), isTrue);
          }
        } else {
          expect(room.background, artworkPath('painted_$space'));
          expect(File(room.background!).existsSync(), isTrue);
        }
      }
      expect((await s.overview())!.revision, revision);
      expect((await s.overview())!.balance, 0);
      expect(await s.ledger(), isEmpty);
      expect(await s.purchases(), isEmpty);
      expect(await s.wardrobe(Companion.rabbit), isEmpty);
    },
  );

  test('new and legacy furniture, auto wear, retry, refund and reopening share one ledger', () async {
    final f = await TestFamily.create();
    addTearDown(f.dispose);
    var s = f.service;
    var parent = await s.pin.unlock(TestFamily.pin);
    for (var i = 0; i < 34; i++) {
      await s.backfill(
        const TaskDraft('测试任务A', '', '测试标准', 'challenge'),
        s.today,
        '',
        session: parent,
      );
    }
    final base = (await s.spaces()).single['id'] as String;
    final coat = await s.purchase('single_coat', commandId: 'wear-once');
    expect(await s.purchase('single_coat', commandId: 'wear-once'), coat);
    expect(
      (await s.wardrobe(Companion.rabbit)).single['asset_id'],
      'item_single_coat',
    );
    await s.purchase('single_apron', wearOn: Companion.fox);
    expect(
      (await s.wardrobe(Companion.fox)).single['asset_id'],
      'item_single_apron',
    );
    expect(
      (await s.wardrobe(Companion.rabbit)).single['asset_id'],
      'item_single_coat',
    );
    final vase = await s.purchase('decor_vase');
    expect((await s.furnishings(base)).last['name'], '小花瓶');
    final garden = await s.purchase('garden');
    final room =
        (await s.spaces()).singleWhere((r) => r['scene_id'] == 'garden')['id']
            as String;
    final old =
        (await s.items()).singleWhere((r) => r['item_id'] == 'decor_vase')['id']
            as String;
    await s.saveLayout(room, 0, [
      ...(await s.layout(room)).map(PlacementDraft.fromRow),
      PlacementDraft(old, .51, .86, 3),
    ]);
    final prior = (await s.overview())!;
    await f.reopen();
    s = f.service;
    expect((await s.overview())!.balance, prior.balance);
    expect((await s.displayRoom(vase['id'] as String))!['id'], room);
    expect(
      (await s.furnishings(room)).map((r) => r['item_id']),
      contains('decor_vase'),
    );
    expect(
      (await s.furnishings(base)).map((r) => r['item_id']),
      isNot(contains('decor_vase')),
    );
    expect(
      (await s.wardrobe(Companion.rabbit)).single['asset_id'],
      'item_single_coat',
    );
    parent = await s.pin.unlock(TestFamily.pin);
    await s.refund(garden['id'] as String, session: parent);
    expect(
      (await s.furnishings(base)).map((r) => r['item_id']),
      contains('decor_vase'),
    );
    await s.refund(coat['id'] as String, session: parent);
    await s.refund(coat['id'] as String, session: parent);
    expect(await s.wardrobe(Companion.rabbit), isEmpty);
    expect(
      (await s.wardrobe(Companion.fox)).single['asset_id'],
      'item_single_apron',
    );
    expect((await s.overview())!.balance, 170 - 25 - 6);
    await s.verifyAccounting();
  });

  test('38 fitted portraits and an accessory are resolved through the same 19 animated poses', () async {
    Future<ui.Image> decode(String path) async {
      final codec = await ui.instantiateImageCodec(
        await File(path).readAsBytes(),
      );
      final image = (await codec.getNextFrame()).image;
      codec.dispose();
      return image;
    }

    final scarf = await decode(wornArtwork('item_accessory_scarf'));
    addTearDown(scarf.dispose);
    final resolved = <String>{};
    for (final pet in Companion.values) {
      for (var stage = 1; stage <= 6; stage++) {
        for (final reveal in [
          false,
          if (pet == Companion.cat && stage == 4) true,
        ]) {
          final plain = pet.artwork(stage, reveal: reveal);
          expect(portraitArtwork(pet, stage, reveal, null), plain);
          final body = await decode(plain);
          final rig = PetRig.forPose(pet, stage, reveal);
          for (final item in ['item_single_coat', 'item_single_apron']) {
            final path = portraitArtwork(pet, stage, reveal, item);
            expect(resolved.add(path), isTrue);
            final look = await decode(path);
            expect((look.width, look.height), (body.width, body.height));
            final raw = (await look.toByteData())!.buffer.asUint8List();
            final dressed = applyAccessories(
              look,
              pet,
              stage,
              reveal,
              rig.leftEye,
              rig.rightEye,
              {'neck': scarf},
              null,
            );
            final pixels = (await dressed.image.toByteData())!.buffer
                .asUint8List();
            final dx = dressed.padding.dx.toInt(),
                dy = dressed.padding.dy.toInt();
            int index(int x, int y) =>
                ((y + dy) * dressed.image.width + x + dx) * 4;
            int difference(Uint8List a, int i, Uint8List b, int j) =>
                (a[i] - b[j]).abs() +
                (a[i + 1] - b[j + 1]).abs() +
                (a[i + 2] - b[j + 2]).abs();
            var solid = 0, clear = 0, partial = 0, scarfPixels = 0;
            for (var y = 0; y < look.height; y += 2) {
              for (var x = 0; x < look.width; x += 2) {
                final i = (y * look.width + x) * 4, alpha = raw[i + 3];
                if (alpha == 255) {
                  solid++;
                } else if (alpha == 0) {
                  clear++;
                } else {
                  partial++;
                }
                if (difference(raw, i, pixels, index(x, y)) > 35) scarfPixels++;
              }
            }
            expect(solid, greaterThan(2000));
            expect(clear, greaterThan(1000));
            expect(partial, greaterThan(100));
            expect(scarfPixels, greaterThan(90), reason: path);
            for (final eye in [rig.leftEye, rig.rightEye]) {
              final x = (eye.dx * look.width).round(),
                  y = (eye.dy * look.height).round();
              expect(
                difference(raw, (y * look.width + x) * 4, pixels, index(x, y)),
                lessThan(4),
                reason: path,
              );
            }
            dressed.image.dispose();
            look.dispose();
          }
          body.dispose();
        }
      }
    }
    expect(resolved, hasLength(38));
  });
}
