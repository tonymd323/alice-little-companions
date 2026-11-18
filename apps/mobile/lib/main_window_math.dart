import 'dart:convert';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'data/device.dart';
import 'features/garden.dart';
import 'features/window_math.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final directory = await getApplicationSupportDirectory();
  final store = DeviceStore(directory, const PlatformSecureValues());
  final file = File(path.join(directory.path, 'window-chapter.json'));
  final bookmark = await readWindowBookmark(file);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '暖廊的彩窗',
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: gardenTheme(),
      home: WindowMathChapter(
        initialPage: bookmark.page,
        initialPattern: bookmark.pattern,
        save: (page, pattern) => store.writeAtomic(file, {
          'page': page.name,
          'five_leaf_panes': pattern.toList()..sort(),
        }),
      ),
    ),
  );
}

/// Stores only the chapter bookmark in the preview app's private directory.
Future<({WindowPage page, Set<int> pattern})> readWindowBookmark(
  File file,
) async {
  const first = (page: WindowPage.count, pattern: <int>{});
  if (!await file.exists()) return first;
  try {
    final record = jsonDecode(await file.readAsString());
    if (record is! Map || record['page'] is! String) return first;
    final page = WindowPage.values.asNameMap()[record['page']];
    if (page == null) return first;
    if (page != WindowPage.finished) return (page: page, pattern: <int>{});
    final panes = record['five_leaf_panes'];
    if (panes is! List ||
        panes.length != 2 ||
        !panes.every((i) => i is int && i >= 0 && i < 5)) {
      return first;
    }
    final pattern = panes.cast<int>().toSet();
    return pattern.length == 2 ? (page: page, pattern: pattern) : first;
  } on FormatException {
    return first;
  } on FileSystemException {
    return first;
  }
}
