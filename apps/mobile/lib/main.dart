import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'application/controller.dart';
import 'data/device.dart';
import 'domain/rules.dart';
import 'features/first_run.dart';
import 'features/garden.dart';
import 'features/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final data = await Future.wait(
      [
        'rules',
        'catalog',
        'scene_slots',
      ].map((name) => rootBundle.loadString('assets/config/$name.json')),
    );
    final controller = FamilyController(
      await DeviceStore.open(),
      Rules.decode(data[0], data[1], data[2]),
    );
    await controller.open();
    WidgetsBinding.instance.addObserver(controller);
    runApp(CompanionsApp(controller: controller));
  } catch (_) {
    runApp(const CompanionsApp(bootFailed: true));
  }
}

class CompanionsApp extends StatelessWidget {
  const CompanionsApp({super.key, this.controller, this.bootFailed = false});
  final FamilyController? controller;
  final bool bootFailed;

  @override
  Widget build(BuildContext context) {
    final model = controller;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '小小伙伴',
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: gardenTheme(),
      home: bootFailed
          ? const Scaffold(
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('暂时无法打开小家。请保留这台设备上的应用数据。'),
                  ),
                ),
              ),
            )
          : model == null
          ? const AppearancePreview()
          : ListenableBuilder(
              listenable: model,
              builder: (context, _) => model.family == null
                  ? FirstRunPage(controller: model)
                  : FamilyHome(controller: model),
            ),
    );
  }
}
