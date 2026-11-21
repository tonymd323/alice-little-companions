import 'package:material_ui/material_ui.dart';

import '../illustration/florist_art.dart';
import 'common.dart';
import 'garden.dart';

class FloristWorkbench extends StatelessWidget {
  const FloristWorkbench({super.key, required this.flowers});

  final ValueNotifier<Set<int>> flowers;

  void _toggle(int hole) {
    final next = {...flowers.value};
    if (!next.remove(hole)) next.add(hole);
    flowers.value = next;
  }

  Widget _row(BuildContext context, String row, int start, Set<int> filled) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(row),
        for (var column = 0; column < 3; column++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _hole(row, column, start + column, filled, colors),
            ),
          ),
      ],
    );
  }

  Widget _hole(
    String row,
    int column,
    int hole,
    Set<int> filled,
    ColorScheme colors,
  ) {
    final planted = filled.contains(hole);
    final action = '$row第${column + 1}孔，${planted ? '取花' : '插花'}';
    return OutlinedButton(
      key: ValueKey('florist-hole-${hole + 1}'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: EdgeInsets.zero,
        backgroundColor: planted ? colors.secondaryContainer : colors.surface,
      ),
      onPressed: () => _toggle(hole),
      child: Icon(planted ? Icons.remove : Icons.add, semanticLabel: action),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('花店工作台')),
    body: PageBody(
      maxWidth: 540,
      child: GardenCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: FloristTray.closeAspectRatio,
              child: FloristTray(flowers: flowers),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder(
              valueListenable: flowers,
              builder: (context, filled, _) => Column(
                children: [
                  _row(context, '后排', 0, filled),
                  const SizedBox(height: 4),
                  _row(context, '前排', 3, filled),
                  const SizedBox(height: 12),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      '${filled.length} 枝花 · ${FloristTray.holeCount - filled.length} 个空孔',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
