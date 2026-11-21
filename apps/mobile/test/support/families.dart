import 'dart:io';

import 'package:alice_companions/application/family.dart';
import 'package:alice_companions/data/database.dart';
import 'package:alice_companions/data/device.dart';
import 'package:alice_companions/domain/companions.dart';
import 'package:alice_companions/domain/pin.dart';
import 'package:alice_companions/domain/rules.dart';

const dropAffinityTables =
    'DROP TABLE companion_candies; DROP TABLE companion_affinity_days; '
    'DROP INDEX purchased_once; $legacyPurchaseIndexSql; ';
const dropCompanionTables =
    '${dropAffinityTables}DROP TABLE companion_completions; DROP TABLE owned_companions; ';

class MemorySecureValues implements SecureValues {
  final data = <String, String>{};

  @override
  Future<void> delete(String key) async {
    data.remove(key);
  }

  @override
  Future<String?> read(String key) async => data[key];

  @override
  Future<void> write(String key, String value) async {
    data[key] = value;
  }
}

class TestFamily {
  TestFamily._(this.root, this.device, this.rules, this.service);

  final Directory root;
  final DeviceStore device;
  final Rules rules;
  FamilyService service;
  static final pin = 123456.toString();

  static Future<TestFamily> create({
    DateTime Function()? now,
    Companion pet = Companion.rabbit,
  }) async {
    final root = await Directory.systemTemp.createTemp('alice-family-');
    final device = DeviceStore(root, MemorySecureValues());
    final rules = Rules.decode(
      File('assets/config/rules.json').readAsStringSync(),
      File('assets/config/catalog.json').readAsStringSync(),
      File('assets/config/scene_slots.json').readAsStringSync(),
    );
    final service = await FamilyService.initialize(
      device,
      rules,
      nickname: '测试家庭',
      companion: pet,
      pin: pin,
      recovery: PinGate.newRecoveryCode(),
      clock: now,
    );
    return TestFamily._(root, device, rules, service);
  }

  Future<void> reopen({DateTime Function()? now}) async {
    await service.close();
    service = await FamilyService.load(
      device,
      (await device.activeGeneration())!,
      rules,
      clock: now,
    );
  }

  Future<void> dispose() async {
    await service.close();
    await root.delete(recursive: true);
  }
}
