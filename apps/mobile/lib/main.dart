import 'package:material_ui/material_ui.dart';

import 'features/garden.dart';

void main() {
  runApp(const CompanionsApp());
}

class CompanionsApp extends StatelessWidget {
  const CompanionsApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: '小小伙伴',
    locale: const Locale('zh', 'CN'),
    supportedLocales: const [Locale('zh', 'CN')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: gardenTheme(),
    home: const AppearancePreview(),
  );
}
