import 'dart:async';

import 'package:flutter/widgets.dart';

import '../data/device.dart';
import '../domain/companions.dart';
import '../domain/pin.dart';
import '../domain/rules.dart';
import 'family.dart';

class FamilyController extends ChangeNotifier with WidgetsBindingObserver {
  FamilyController(this.device, this.rules);

  final DeviceStore device;
  final Rules rules;
  FamilyService? service;
  FamilyOverview? family;
  List<TaskEntry> tasks = [];
  ParentSession? session;
  Timer? _expiration;
  int _refreshId = 0;

  bool get parentUnlocked => service?.pin.allows(session) ?? false;

  Future<void> open() async {
    final generation = await device.activeGeneration();
    if (generation != null) {
      service = await FamilyService.load(device, generation, rules);
    }
    await refresh();
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

  Future<void> unlock(String pin) async {
    session = await service!.pin.unlock(pin);
    _expiration?.cancel();
    _expiration = Timer(const Duration(minutes: 10), lock);
    notifyListeners();
  }

  void lock() {
    service?.pin.lock();
    _expiration?.cancel();
    if (session != null) {
      session = null;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final current = ++_refreshId;
    final active = service;
    final loaded = await active?.overview();
    final entries = await active?.tasks() ?? <TaskEntry>[];
    if (current != _refreshId) return;
    family = loaded;
    tasks = entries;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) lock();
  }

  @override
  void dispose() {
    _expiration?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
