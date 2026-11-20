import 'dart:io';

import 'package:alice_companions/application/app_update.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MaterialApp(home: InstallerProbe()));

class InstallerProbe extends StatefulWidget {
  const InstallerProbe({super.key});
  @override
  State<InstallerProbe> createState() => _InstallerProbeState();
}

class _InstallerProbeState extends State<InstallerProbe> {
  static const bridge = AndroidInstaller();
  String result = 'Waiting for install test';
  late final installed = bridge.installed();

  Future<void> run(String filename, int code) async {
    try {
      final folder = await bridge.cache();
      final result = await bridge.install(File('${folder.path}/$filename'), code);
      if (mounted) setState(() => this.result = result.name);
    } on PlatformException catch (error) {
      if (mounted) setState(() => result = error.code);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Android update verification')),
    body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      FutureBuilder(future: installed, builder: (context, state) =>
        Text(state.data == null ? 'Reading installed build' : 'Installed ${state.data!.code}')),
      Text(result),
      FilledButton(onPressed: () => run('older.apk', 15), child: const Text('Check old APK')),
      FilledButton(onPressed: () => run('family-update.apk', 16), child: const Text('Install signed update')),
    ])),
  );
}
