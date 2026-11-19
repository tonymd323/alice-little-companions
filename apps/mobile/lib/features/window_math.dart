import 'package:material_ui/material_ui.dart';

import '../domain/companions.dart';
import '../domain/window_page.dart';
import 'garden.dart';

export '../domain/window_page.dart' show WindowPage;

class WindowMathChapter extends StatefulWidget {
  const WindowMathChapter({
    super.key,
    required this.initialPage,
    this.initialPattern = const {},
    required this.save,
    this.companion = Companion.rabbit,
    this.verandaBuilder,
    this.courtyardBuilder,
    this.mainStory = false,
    this.openWithStory = false,
    this.backLabel = '回到小家',
  });

  final WindowPage initialPage;
  final Set<int> initialPattern;
  final Future<void> Function(WindowPage page, Set<int> fiveLeafPanes) save;
  final Companion companion;
  final Widget Function(double height)? verandaBuilder, courtyardBuilder;
  final bool mainStory, openWithStory;
  final String backLabel;

  @override
  State<WindowMathChapter> createState() => _WindowMathChapterState();
}

class _WindowMathChapterState extends State<WindowMathChapter> {
  late WindowPage page = widget.initialPage;
  late bool opening = widget.mainStory && widget.openWithStory;
  late final marked = {...widget.initialPattern};
  int? answer;
  bool hint = false;
  bool saving = false;
  String feedback = '';
  final scroll = ScrollController();
  String get friend => widget.companion.nickname;

  static const countPerWindow = 4;
  static const countWindows = 3;
  static const basket = 7;
  static const bigPattern = 5;
  static const littlePattern = 3;
  static const puzzleWindows = 5;
  static const target = 19;
  static const totalLeaves = countWindows * countPerWindow;
  static const missingLeaves = totalLeaves - basket;

  bool get counting => page == WindowPage.count;
  bool get question => counting || page == WindowPage.missing;
  bool get isPuzzle => page == WindowPage.puzzle;
  bool get solved =>
      question && answer == (counting ? totalLeaves : missingLeaves);
  int get laid =>
      puzzleWindows * littlePattern +
      marked.length * (bigPattern - littlePattern);
  bool get lit => !question;

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  Future<void> turn(WindowPage next) async {
    if (saving) return;
    setState(() => saving = true);
    try {
      final pattern = next == WindowPage.finished
          ? Set<int>.of(marked)
          : <int>{};
      await widget.save(next, pattern);
      if (!mounted) return;
      setState(() {
        page = next;
        opening = false;
        marked
          ..clear()
          ..addAll(pattern);
        answer = null;
        hint = false;
        feedback = '';
      });
      if (scroll.hasClients) scroll.jumpTo(0);
    } catch (_) {
      if (mounted) setState(() => feedback = '这一页暂时没存好，可以再试一次。');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void choose(int choice) {
    if (solved || saving) return;
    final correct = choice == (counting ? totalLeaves : missingLeaves);
    setState(() {
      answer = choice;
      feedback = correct
          ? (counting
                ? '4 ＋ 4 ＋ 4 ＝ 12。三扇窗一共要 12 片。'
                : '7 ＋ 5 ＝ 12。再补 5 片，窗花就齐了！')
          : (counting
                ? '$friend轻轻敲了敲窗框。点一扇数一组，再把三组加起来。'
                : '看看窗格里的空叶印，它们正等着金叶。');
    });
  }

  void touchPane(int index) {
    if (saving || solved) return;
    setState(() {
      if (!marked.remove(index)) marked.add(index);
      if (isPuzzle) feedback = '';
    });
  }

  void checkPattern() {
    if (laid == target) {
      turn(WindowPage.finished);
      return;
    }
    setState(() {
      final remaining = (target - laid).abs();
      feedback = laid < target
          ? '还差 $remaining 片。试试把一格三叶窗花换成五叶。'
          : '多了 $remaining 片。试试把一格五叶窗花换回三叶。';
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: Navigator.canPop(context)
        ? AppBar(
            leading: IconButton(
              tooltip: widget.backLabel,
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: Text(widget.mainStory ? '主线第一章 · 暖廊的彩窗' : '暖廊的彩窗'),
          )
        : null,
    body: SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, box) {
          final wide = box.maxWidth >= 820;
          final sceneHeight = wide
              ? box.maxHeight
              : (box.maxWidth * .58).clamp(175.0, 268.0);
          if (opening) {
            return ListView(
              controller: scroll,
              children: [
                widget.courtyardBuilder?.call(sceneHeight) ??
                    GardenScene(
                      companion: widget.companion,
                      stage: 1,
                      height: sceneHeight,
                    ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '石桥边的约定',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '一阵风吹跑了窗花。原本约好在石桥见面的伙伴们，正等着桥面上那三朵金色的影子。$friend把落叶篮推到你面前。',
                        style: const TextStyle(fontSize: 18, height: 1.46),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '“我们把金叶嵌回三扇窗，大家就知道可以回家啦。”',
                        style: const TextStyle(fontSize: 17, height: 1.46),
                      ),
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: saving ? null : () => turn(WindowPage.count),
                        child: const Text('去暖廊修好彩窗'),
                      ),
                      if (feedback.isNotEmpty) _Notice(feedback),
                    ],
                  ),
                ),
              ],
            );
          }
          final scene = _Room(
            height: sceneHeight,
            lit: lit,
            showTitle: !Navigator.canPop(context),
            veranda:
                widget.verandaBuilder?.call(sceneHeight) ??
                GardenScene(
                  companion: widget.companion,
                  stage: 1,
                  view: HomeView.veranda,
                  height: sceneHeight,
                  immersive: true,
                  showLabel: false,
                ),
          );
          final story = SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    switch (page) {
                      WindowPage.count => '一起数窗花',
                      WindowPage.missing => '还差几片叶子？',
                      WindowPage.sunny => '彩窗亮起来了',
                      WindowPage.puzzle => '刚好用完十九片',
                      WindowPage.finished => '两种花纹，一扇彩窗',
                    },
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(color: ink, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    switch (page) {
                      WindowPage.count =>
                        '$friend想给暖廊的 3 扇小窗做窗花。每扇要用 4 片金叶，一共要用几片？',
                      WindowPage.missing =>
                        '三扇窗一共要 12 片，$friend已经嵌好了 7 片。还要从篮子里拿几片？',
                      WindowPage.sunny =>
                        widget.mainStory
                            ? '第三扇窗亮了。桥面上出现三朵金花！奶油沿石径跑来，桃桃数着光影，团团已经趴在窗座上等你。大家都赶上了暖廊的约定。'
                            : '$friend把最后一片金叶嵌好。阳光穿过窗花，在地板上画出了三朵金花。',
                      WindowPage.puzzle =>
                        '还有 5 格小窗，每格可以嵌 3 片或 5 片。点窗格换花纹，把 19 片金叶刚好用完。',
                      WindowPage.finished =>
                        '3 格三叶窗花用了 9 片，2 格五叶窗花用了 10 片。9 ＋ 10 ＝ 19，正正好！',
                    },
                    style: const TextStyle(
                      color: ink,
                      fontSize: 18,
                      height: 1.46,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (question || isPuzzle) ...[
                    _board(),
                    if (counting && marked.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _Notice(
                        '已点亮 ${marked.length} 扇，共 ${marked.length * countPerWindow} 片。',
                      ),
                    ],
                    if (isPuzzle) ...[
                      const SizedBox(height: 7),
                      _Notice('已用 $laid 片，共有 $target 片。'),
                    ],
                    const SizedBox(height: 13),
                    if (question)
                      _answers()
                    else
                      FilledButton(
                        onPressed: saving ? null : checkPattern,
                        child: const Text('试着装上窗花'),
                      ),
                    if (feedback.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _Notice(feedback),
                    ],
                    if (solved) ...[
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: saving
                            ? null
                            : () => turn(
                                counting
                                    ? WindowPage.missing
                                    : WindowPage.sunny,
                              ),
                        child: Text(counting ? '和$friend一起补叶片' : '看看阳光下的彩窗'),
                      ),
                    ] else ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => setState(() => hint = !hint),
                          icon: const Icon(Icons.lightbulb_outline, size: 18),
                          label: Text(hint ? '收起提示' : '看看$friend的提示'),
                        ),
                      ),
                      if (hint)
                        _Notice(switch (page) {
                          WindowPage.count => '把每扇窗当作一组，从左往右数到 4、8……再加 4 是多少？',
                          WindowPage.missing => '先把第二扇补满，再看看第三扇有几个空叶印。',
                          _ => '如果每格先放 3 片，一共是 15 片。把一格换成 5 片，会多用几片？',
                        }),
                      if (isPuzzle)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: saving
                                ? null
                                : () => turn(WindowPage.sunny),
                            child: const Text('回到已经点亮的彩窗'),
                          ),
                        ),
                    ],
                  ] else ...[
                    _WindowStrip(
                      windows: page == WindowPage.finished ? 5 : 3,
                      capacity: (index) => page == WindowPage.finished
                          ? (marked.contains(index) ? 5 : 3)
                          : 4,
                      filled: (index) => page == WindowPage.finished
                          ? (marked.contains(index) ? 5 : 3)
                          : 4,
                      highlighted: (_) => true,
                    ),
                    const SizedBox(height: 18),
                    if (widget.mainStory)
                      FilledButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.cottage_outlined),
                        label: const Text('回家看窗花'),
                      ),
                    FilledButton(
                      onPressed: saving ? null : () => turn(WindowPage.puzzle),
                      child: Text(
                        page == WindowPage.finished
                            ? '试试另一种排法'
                            : '多想一步 · 挑战十九片',
                      ),
                    ),
                    TextButton(
                      onPressed: saving ? null : () => turn(WindowPage.count),
                      child: const Text('从第一扇窗重玩'),
                    ),
                    if (feedback.isNotEmpty) _Notice(feedback),
                  ],
                ],
              ),
            ),
          );
          if (wide) {
            return Row(
              children: [
                Expanded(flex: 6, child: scene),
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    controller: scroll,
                    child: story,
                  ),
                ),
              ],
            );
          }
          return ListView(controller: scroll, children: [scene, story]);
        },
      ),
    ),
  );

  Widget _board() => _WindowStrip(
    windows: isPuzzle ? puzzleWindows : countWindows,
    capacity: (i) => isPuzzle
        ? (marked.contains(i) ? bigPattern : littlePattern)
        : countPerWindow,
    filled: (i) {
      if (isPuzzle) return marked.contains(i) ? bigPattern : littlePattern;
      if (counting) return countPerWindow;
      return (basket - i * countPerWindow).clamp(0, countPerWindow);
    },
    highlighted: (i) => marked.contains(i),
    onTap: counting || isPuzzle ? touchPane : null,
  );

  Widget _answers() {
    final choices = counting ? const [8, 12, 16] : const [4, 5, 7];
    return Row(
      children: [
        for (final value in choices) ...[
          if (value != choices.first) const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () => choose(value),
              style: OutlinedButton.styleFrom(
                backgroundColor: answer == value ? wheat : cream,
                side: BorderSide(color: answer == value ? terracotta : outline),
              ),
              child: Text(
                '$value 片',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Room extends StatelessWidget {
  const _Room({
    required this.height,
    required this.lit,
    required this.showTitle,
    required this.veranda,
  });
  final double height;
  final bool lit, showTitle;
  final Widget veranda;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: Stack(
      fit: StackFit.expand,
      children: [
        veranda,
        if (lit)
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0x7CFFE598),
                    Color(0x20FFD36D),
                    Color(0x00FFEFAC),
                  ],
                ),
              ),
            ),
          ),
        if (showTitle)
          Positioned(
            top: 14,
            left: 15,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xF7FFF6E3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Text(
                    '暖廊的彩窗',
                    style: TextStyle(
                      fontSize: 20,
                      color: ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _Notice extends StatelessWidget {
  const _Notice(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Text(
      text,
      style: const TextStyle(color: mutedInk, fontSize: 16, height: 1.4),
    ),
  );
}

class _WindowStrip extends StatelessWidget {
  const _WindowStrip({
    required this.windows,
    required this.capacity,
    required this.filled,
    required this.highlighted,
    this.onTap,
  });
  final int windows;
  final int Function(int) capacity, filled;
  final bool Function(int) highlighted;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final width = ((box.maxWidth - (windows - 1) * 6) / windows).clamp(
        48.0,
        106.0,
      );
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 6,
        runSpacing: 7,
        children: [
          for (var i = 0; i < windows; i++)
            Semantics(
              container: true,
              excludeSemantics: true,
              button: onTap != null,
              onTap: onTap == null ? null : () => onTap!(i),
              label: '第 ${i + 1} 格，${filled(i)} 片金叶',
              hint: onTap == null
                  ? null
                  : (windows == 5 ? '点一下换花纹' : '点一下标记这组'),
              child: SizedBox(
                width: width,
                height: width * 1.13,
                child: InkWell(
                  onTap: onTap == null ? null : () => onTap!(i),
                  borderRadius: BorderRadius.circular(12),
                  child: CustomPaint(
                    painter: _GlassPane(capacity(i), filled(i), highlighted(i)),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

class _GlassPane extends CustomPainter {
  const _GlassPane(this.capacity, this.filled, this.lit);
  final int capacity, filled;
  final bool lit;

  static const patterns = {
    3: [Offset(50, 34), Offset(31, 72), Offset(69, 72)],
    4: [Offset(32, 37), Offset(68, 37), Offset(32, 75), Offset(68, 75)],
    5: [
      Offset(30, 34),
      Offset(70, 34),
      Offset(50, 56),
      Offset(30, 80),
      Offset(70, 80),
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 113);
    final window = Path()
      ..moveTo(5, 105)
      ..lineTo(5, 35)
      ..cubicTo(6, 15, 28, 5, 50, 3)
      ..cubicTo(72, 5, 94, 15, 95, 35)
      ..lineTo(95, 105)
      ..close();
    final brush = Paint()..isAntiAlias = true;
    brush.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: lit
          ? const [Color(0xFFFFEDAE), Color(0xFFE8C66E)]
          : const [Color(0xFFDEEBE8), Color(0xFFBCD3CF)],
    ).createShader(const Rect.fromLTWH(0, 0, 100, 110));
    canvas.drawPath(window, brush);
    brush
      ..shader = null
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF6E513E)
      ..strokeWidth = 3.8;
    canvas.drawPath(window, brush);
    brush
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF9E7754);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(1, 103, 98, 6),
        const Radius.circular(2),
      ),
      brush,
    );
    final points = patterns[capacity]!;
    for (var i = 0; i < points.length; i++) {
      canvas.save();
      canvas.translate(points[i].dx, points[i].dy);
      canvas.rotate(i.isEven ? -.13 : .13);
      final leaf = Path()
        ..moveTo(0, 8)
        ..quadraticBezierTo(-12, 4, -16, -6)
        ..quadraticBezierTo(-13, -13, -5, -13)
        ..lineTo(-1, -9)
        ..lineTo(2, -14)
        ..quadraticBezierTo(11, -17, 16, -8)
        ..quadraticBezierTo(14, 0, 0, 8)
        ..close();
      brush
        ..style = PaintingStyle.fill
        ..color = i < filled
            ? const Color(0xFFF3BC47)
            : const Color(0xFFE6F0E9);
      canvas.drawPath(leaf, brush);
      brush
        ..style = PaintingStyle.stroke
        ..strokeWidth = i < filled ? 1.8 : 1.3
        ..color = i < filled
            ? const Color(0xFF916032)
            : const Color(0xFF789491);
      canvas.drawPath(leaf, brush);
      canvas.drawLine(const Offset(0, 8), const Offset(2, 15), brush);
      if (i < filled) {
        brush
          ..strokeWidth = 1
          ..color = const Color(0xFFB78034);
        for (final tip in const [
          Offset(-11, -7),
          Offset(-5, -9),
          Offset(6, -11),
          Offset(12, -7),
        ]) {
          canvas.drawLine(const Offset(0, 7), tip, brush);
        }
      }
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlassPane old) =>
      old.capacity != capacity || old.filled != filled || old.lit != lit;
}
