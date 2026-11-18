import 'dart:async';

import 'package:flutter/widgets.dart';

import '../data/device.dart';
import '../domain/companions.dart';
import '../domain/pin.dart';
import '../domain/rules.dart';
import 'family.dart';
import 'transfer.dart';

class FamilyController extends ChangeNotifier with WidgetsBindingObserver {
  FamilyController(this.device, this.rules, {this.assets = const {}});
  final Set<String> assets;
  late final transfer = TransferService(
    device: device,
    rules: rules,
    availableAssets: assets,
    current: () => service,
    repairPin: () => repairGate,
  );

  final DeviceStore device;
  final Rules rules;
  FamilyService? service;
  PinGate? repairGate;
  PinGate? get parentGate => service?.pin ?? repairGate;
  bool get needsRepair => repairGate != null;
  FamilyOverview? family;
  List<TaskEntry> tasks = [];
  Json? baseSpace;
  List<Json> homeLayout = [];
  List<Json> outfit = [];
  Json? wish;
  ParentSession? session;
  Timer? _expiration;
  Timer? _calendar;
  String? _seenDay;
  int _refreshId = 0;

  bool get parentUnlocked => parentGate?.allows(session) ?? false;

  Future<void> open() async {
    final generation = await device.recordedGeneration();
    if (generation != null) {
      try {
        await device.activeGeneration();
        service = await FamilyService.load(device, generation, rules);
        if (await service!.overview() == null) {
          throw const UserError('当前小家存档不完整。');
        }
      } catch (_) {
        await service?.close();
        service = null;
        repairGate = PinGate(
          device.secure,
          generation,
          iterations: rules.pinIterations,
        );
      }
    }
    await refresh();
    _calendar = Timer.periodic(const Duration(minutes: 1), (_) {
      if (service?.today != _seenDay) unawaited(refresh());
    });
  }

  Future<void> create(
    String name,
    Companion pet,
    String pin,
    String recovery,
  ) async {
    service = await FamilyService.initialize(
      device,
      rules,
      nickname: name,
      companion: pet,
      pin: pin,
      recovery: recovery,
    );
    await refresh();
  }

  Future<void> acceptActivation(Activation activated) async {
    if (activated.alreadyRestored) return;
    final previous = service;
    lock();
    service = activated.service;
    repairGate = null;
    await refresh();
    await previous?.close();
  }

  Future<void> unlock(String pin) async {
    session = await parentGate!.unlock(pin);
    _expiration?.cancel();
    _expiration = Timer(const Duration(minutes: 10), lock);
    notifyListeners();
  }

  void lock() {
    parentGate?.lock();
    _expiration?.cancel();
    if (session != null) {
      session = null;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final current = ++_refreshId;
    final active = service;
    await active?.processCalendar();
    _seenDay = active?.today;
    final loaded = await active?.overview();
    final entries = await active?.tasks() ?? <TaskEntry>[];
    final spaces = await active?.spaces() ?? <Json>[];
    final base = spaces
        .where((space) => space['scene_id'] == 'base_room')
        .singleOrNull;
    final placed = base == null
        ? <Json>[]
        : await active!.layout(base['id'] as String);
    final worn = loaded == null
        ? <Json>[]
        : await active!.wardrobe(loaded.companion);
    final desired = await active?.wish();
    if (current != _refreshId) return;
    family = loaded;
    tasks = entries;
    baseSpace = base;
    homeLayout = placed;
    outfit = worn;
    wish = desired;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      lock();
    } else if (service?.today != _seenDay) {
      unawaited(refresh());
    }
  }

  @override
  void dispose() {
    _expiration?.cancel();
    _calendar?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
