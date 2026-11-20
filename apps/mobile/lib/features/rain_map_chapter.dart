import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../domain/companions.dart';
import '../domain/pin.dart';
import '../domain/rain_map.dart';
import 'common.dart';
import 'garden.dart';

class RainMapChapter extends StatefulWidget {
  const RainMapChapter({
    super.key,
    required this.initial,
    required this.service,
  });

  final RainMapProgress initial;
  final RainMapCommands service;

  @override
  State<RainMapChapter> createState() => _RainMapChapterState();
}

class _RainMapChapterState extends State<RainMapChapter> {
  static const _legLines = [
    '奶油：先穿过浅滩。第一块石板离我们最近。',
    '奶油：沿着树影往前，再踩过这一段石板。',
    '奶油：听见了吗？桃桃在桥的另一边。',
    '奶油：看见小家的屋檐了！还差最后一段。',
  ];
  static const _ordinals = ['一', '二', '三'];
  static const _maxShortcutStones =
      RainMapProgress.groupSize * RainMapProgress.groupCount;

  late RainMapProgress _progress = widget.initial;
  bool _saving = false;
  bool _onShortcut = false;
  int _shortcutStones = 0;
  String? _hint;

  bool get _onTrail => _progress.started && !_progress.complete;

  Future<void> _save(Future<RainMapProgress> Function() action) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final saved = await action();
      if (!mounted) return;
      setState(() {
        _progress = saved;
        _hint = null;
        if (saved.challengeSolved) _onShortcut = false;
      });
    } on UserError catch (error) {
      if (mounted) setState(() => _hint = error.message);
    } catch (_) {
      if (mounted) setState(() => _hint = '这一步没存好。再试一次吧。');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _stepStone(int stone) {
    if (_saving || !_onTrail) return;
    if (_progress.canStamp) {
      setState(() => _hint = '三块都踩过了。在地图上盖下这段的爪印吧。');
      return;
    }
    final next = _progress.stones;
    if (stone != next) {
      final action = '踩第${_ordinals[next]}块石板。';
      setState(
        () => _hint = stone < next ? '这块已经踩过了。接着$action' : '由近到远，先$action',
      );
      return;
    }
    _save(
      () => widget.service.stepRainMapStone(
        run: _progress.run,
        group: _progress.stamps,
        stone: stone,
      ),
    );
  }

  void _stamp() {
    if (_saving || !_onTrail) return;
    if (!_progress.canStamp) {
      final remaining = RainMapProgress.groupSize - _progress.stones;
      setState(() => _hint = '还差$remaining块石板。踩完这一段，再盖爪印。');
      return;
    }
    _save(
      () => widget.service.stampRainMap(
        run: _progress.run,
        group: _progress.stamps,
      ),
    );
  }

  void _showShortcut(bool open) {
    if (_saving) return;
    if (open && (!_progress.complete || _progress.challengeSolved)) return;
    setState(() {
      _onShortcut = open;
      _shortcutStones = 0;
      _hint = null;
    });
  }

  void _changeShortcutStones(int delta) {
    final count = _shortcutStones + delta;
    if (_saving || !_onShortcut || count < 0 || count > _maxShortcutStones) {
      return;
    }
    setState(() {
      _shortcutStones = count;
      _hint = null;
    });
  }

  void _tryShortcut() {
    if (_saving || !_onShortcut) return;
    const answer = RainMapProgress.challengeAnswer;
    if (_shortcutStones != answer) {
      setState(
        () => _hint = _shortcutStones < answer
            ? '还有爪印没配满。每个爪印都铺三块，再请桃桃过桥。'
            : '每个爪印的三块都铺齐了。收回多出来的石板吧。',
      );
      return;
    }
    _save(() => widget.service.solveRainMapChallenge(_shortcutStones));
  }

  String get _line {
    if (!_progress.started) {
      return '奶油：雨把路上的脚印冲掉了。我跟着落叶走，竟然绕回了桥边！咱们每走过三块石板，就在地图上盖一个爪印，留给桃桃认路。';
    }
    if (_progress.complete) {
      return _progress.challengeSolved
          ? '桃桃：我循着四个爪印回了家，还学会了走三个爪印的近路。谢谢你们！'
          : '桃桃：我沿着你们的爪印找到小家啦！四个爪印领我走过了十二块石板。我们一起进屋听雨吧。';
    }
    if (_progress.canStamp) return '奶油：三块都走过了。把爪印盖在地图上吧。';
    if (_progress.stones == 0) return _legLines[_progress.stamps];
    return '奶油：接着踩第${_ordinals[_progress.stones]}块石板。';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_onShortcut,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _onShortcut) _showShortcut(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(rainMapTitle),
          leading: _onShortcut
              ? BackButton(onPressed: () => _showShortcut(false))
              : null,
        ),
        body: PageBody(
          key: ValueKey(_onShortcut),
          maxWidth: _onShortcut ? 560 : 820,
          child: _onShortcut ? _buildShortcut() : _buildRoute(),
        ),
      ),
    );
  }

  Widget _buildRoute() {
    final scene = _RainScene(
      progress: _progress,
      onStone: _onTrail && !_saving ? _stepStone : null,
    );
    final story = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ChapterLine(line: _line, hint: _hint, saving: _saving),
        const SizedBox(height: 12),
        if (!_progress.started)
          FilledButton(
            onPressed: _saving
                ? null
                : () => _save(widget.service.beginRainMap),
            child: const Text('和奶油出发'),
          )
        else if (_onTrail)
          _StampButton(progress: _progress, onPressed: _saving ? null : _stamp)
        else ...[
          RainMapPaper(stamps: _progress.stamps),
          const SizedBox(height: 12),
          if (!_progress.challengeSolved) ...[
            FilledButton(
              onPressed: _saving ? null : () => _showShortcut(true),
              child: const Text('帮桃桃铺近路'),
            ),
            const SizedBox(height: 8),
          ],
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: _saving
                    ? null
                    : () => _save(
                        () => widget.service.restartRainMap(run: _progress.run),
                      ),
                child: const Text('再走一遍'),
              ),
              OutlinedButton(
                onPressed: _saving ? null : () => Navigator.pop(context),
                child: const Text('回小家'),
              ),
            ],
          ),
        ],
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 680) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: scene),
              const SizedBox(width: 16),
              Expanded(child: story),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [scene, const SizedBox(height: 12), story],
        );
      },
    );
  }

  Widget _buildShortcut() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ChapterLine(
          line: '桃桃：地图画了三个爪印的近路。每个爪印要走三块石板。你能铺好近路，带我过桥吗？',
          hint: _hint,
          saving: _saving,
        ),
        const SizedBox(height: 12),
        Semantics(
          label: '已经铺了$_shortcutStones块石板',
          liveRegion: true,
          child: AspectRatio(
            aspectRatio: 2.25,
            child: CustomPaint(
              painter: _PaperTrail(
                stamps: RainMapProgress.challengeStamps,
                laidStones: _shortcutStones,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: _saving || _shortcutStones == 0
                  ? null
                  : () => _changeShortcutStones(-1),
              child: const Text('收回一块'),
            ),
            OutlinedButton(
              onPressed: _saving || _shortcutStones == _maxShortcutStones
                  ? null
                  : () => _changeShortcutStones(1),
              child: const Text('铺一块'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _saving ? null : _tryShortcut,
          child: const Text('带桃桃过桥'),
        ),
      ],
    );
  }
}

class _ChapterLine extends StatelessWidget {
  const _ChapterLine({
    required this.line,
    required this.hint,
    required this.saving,
  });

  final String line;
  final String? hint;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Semantics(
          liveRegion: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(line, style: style.bodyLarge?.copyWith(height: 1.45)),
              if (hint != null) ...[
                const SizedBox(height: 6),
                Text(
                  hint!,
                  style: style.bodyMedium?.copyWith(
                    color: terracotta,
                    height: 1.4,
                  ),
                ),
              ],
              if (saving) ...[
                const SizedBox(height: 8),
                const LinearProgressIndicator(semanticsLabel: '正在存档'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RainScene extends StatelessWidget {
  const _RainScene({required this.progress, required this.onStone});

  final RainMapProgress progress;
  final ValueChanged<int>? onStone;

  static const _stoneHeights = [
    [.81, .75, .70],
    [.78, .73, .77],
    [.84, .77, .71],
    [.82, .76, .70],
  ];

  @override
  Widget build(BuildContext context) {
    final home = progress.complete;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 1.5,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final stoneWidth = math.max(54.0, width * .23);
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/art/${home ? 'veranda' : 'garden'}.webp',
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
                if (!home)
                  const IgnorePointer(
                    child: CustomPaint(painter: _RainGlaze()),
                  ),
                _companion(
                  Companion.fox,
                  width * (home ? .39 : .29 + progress.stamps * .095),
                  height * (home ? .87 : .64),
                  height * .29,
                ),
                if (home || progress.stamps >= 2)
                  _companion(
                    Companion.rabbit,
                    width * (home ? .61 : .84),
                    height * (home ? .87 : .56),
                    height * (home ? .25 : .18),
                  ),
                if (progress.started && !home)
                  for (
                    int stone = 0;
                    stone < RainMapProgress.groupSize;
                    stone++
                  )
                    Positioned(
                      left: width * (.22 + .28 * stone) - stoneWidth / 2,
                      top: height * _stoneHeights[progress.stamps][stone] - 24,
                      width: stoneWidth,
                      height: 48,
                      child: _RiverStone(
                        stone: stone,
                        crossed: stone < progress.stones,
                        next: stone == progress.stones,
                        onTap: onStone == null ? null : () => onStone!(stone),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _companion(Companion companion, double x, double feet, double height) {
    final width = height * companion.aspect(1);
    return Positioned(
      left: x - width / 2,
      top: feet - height,
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              widthFactor: .9,
              heightFactor: .12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(color: Color(0x66492C21), blurRadius: 5),
                  ],
                ),
              ),
            ),
          ),
          Image.asset(
            companion.artwork(1),
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ],
      ),
    );
  }
}

class _RainGlaze extends CustomPainter {
  const _RainGlaze();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0x47506986),
    );
    final rain = Paint()
      ..color = const Color(0xBFE1E9E7)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;
    for (var i = 0; i < 36; i++) {
      final offset = Offset(
        size.width * (i * .237 % 1),
        size.height * (i * .319 % 1),
      );
      canvas.drawLine(
        offset,
        offset + Offset(-size.height * .02, size.height * .051),
        rain,
      );
    }
  }

  @override
  bool shouldRepaint(_RainGlaze oldDelegate) => false;
}

class _RiverStone extends StatelessWidget {
  const _RiverStone({
    required this.stone,
    required this.crossed,
    required this.next,
    required this.onTap,
  });

  final int stone;
  final bool crossed;
  final bool next;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: ValueKey('rain-map-stone-$stone'),
      label:
          '第${stone + 1}块石板${crossed
              ? '，已踩过'
              : next
              ? '，下一块'
              : ''}',
      button: true,
      enabled: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: CustomPaint(
        painter: _StoneShape(crossed: crossed, next: next),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Center(
              child: crossed
                  ? const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF463829),
                      size: 23,
                    )
                  : Text(
                      '${stone + 1}',
                      style: const TextStyle(
                        color: Color(0xFF211F1F),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StoneShape extends CustomPainter {
  const _StoneShape({required this.crossed, required this.next});

  final bool crossed;
  final bool next;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final top = Path()
      ..moveTo(.06 * w, .45 * h)
      ..quadraticBezierTo(.10 * w, .10 * h, .30 * w, .09 * h)
      ..lineTo(.70 * w, .07 * h)
      ..quadraticBezierTo(.88 * w, .10 * h, .95 * w, .44 * h)
      ..quadraticBezierTo(.97 * w, .64 * h, .79 * w, .72 * h)
      ..quadraticBezierTo(.42 * w, .83 * h, .21 * w, .75 * h)
      ..quadraticBezierTo(.04 * w, .68 * h, .06 * w, .45 * h)
      ..close();
    canvas.drawPath(
      top.shift(Offset(0, .13 * h)),
      Paint()..color = const Color(0xB7434B46),
    );
    final colors = crossed
        ? const [Color(0xFFECDDAB), Color(0xFFA69C72)]
        : const [Color(0xFFE3EBE9), Color(0xFFA2B3AF)];
    canvas.drawPath(
      top,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ).createShader(top.getBounds()),
    );
    canvas.drawPath(
      top,
      Paint()
        ..color = next ? const Color(0xFFFFE3A8) : const Color(0xCC61756D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = next ? 2.7 : .9,
    );
  }

  @override
  bool shouldRepaint(_StoneShape oldDelegate) =>
      crossed != oldDelegate.crossed || next != oldDelegate.next;
}

class _StampButton extends StatelessWidget {
  const _StampButton({required this.progress, required this.onPressed});

  final RainMapProgress progress;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '地图上有${progress.stamps}个爪印，共${RainMapProgress.groupCount}个。盖爪印',
      button: true,
      enabled: onPressed != null,
      onTap: onPressed,
      excludeSemantics: true,
      child: Material(
        key: const ValueKey('rain-map-stamp'),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RainMapPaper(stamps: progress.stamps),
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 4),
                child: Text(
                  '盖爪印',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: progress.canStamp ? terracotta : mutedInk,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The trail drawn in the rain chapter and retained in the growth journal.
class RainMapPaper extends StatelessWidget {
  const RainMapPaper({super.key, required this.stamps})
    : assert(stamps >= 0 && stamps <= RainMapProgress.groupCount);

  final int stamps;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '地图上有$stamps个爪印，共${RainMapProgress.groupCount}个',
      image: true,
      child: AspectRatio(
        aspectRatio: 3.15,
        child: CustomPaint(painter: _PaperTrail(stamps: stamps)),
      ),
    );
  }
}

class _PaperTrail extends CustomPainter {
  const _PaperTrail({required this.stamps, this.laidStones});

  final int stamps;
  final int? laidStones;

  @override
  void paint(Canvas canvas, Size size) {
    final area = Offset.zero & size;
    final sheet = RRect.fromRectAndRadius(
      area.deflate(1),
      const Radius.circular(17),
    );
    canvas.drawRRect(
      sheet,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFF5D7), Color(0xFFF3DCAD), Color(0xFFFFEDC6)],
        ).createShader(area),
    );
    canvas.drawRRect(
      sheet,
      Paint()
        ..color = const Color(0xFFC7A270)
        ..style = PaintingStyle.stroke,
    );
    final w = size.width;
    final stones = laidStones;
    final h = size.height * (stones == null ? 1 : .66);
    final stops = stones == null
        ? RainMapProgress.groupCount
        : RainMapProgress.challengeStamps;
    final centers = [
      for (int i = 0; i < stops; i++)
        Offset(w * (.16 + .68 * i / (stops - 1)), h * (i.isEven ? .59 : .42)),
    ];
    final trail = Path()..moveTo(w * .04, h * .71);
    var lastX = w * .04;
    for (final center in centers) {
      final arc = center.dy > .5 * h ? -.18 : .20;
      trail.quadraticBezierTo(
        lastX + .03 * w,
        center.dy + arc * h,
        center.dx,
        center.dy,
      );
      lastX = center.dx;
    }
    trail.quadraticBezierTo(.91 * w, .39 * h, .96 * w, .32 * h);
    final guide = Paint()
      ..color = const Color(0xFFA68051)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    for (final segment in trail.computeMetrics()) {
      for (double distance = 0; distance < segment.length; distance += 7) {
        canvas.drawPath(
          segment.extractPath(distance, math.min(distance + 2, segment.length)),
          guide,
        );
      }
    }
    final radius = math.min(w / 12, h * .26);
    for (var i = 0; i < centers.length; i++) {
      final filled = i < stamps;
      final center = centers[i];
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = filled ? const Color(0xFFDDB07B) : const Color(0xFFFAECCD),
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = const Color(0xFFAA845C)
          ..style = PaintingStyle.stroke,
      );
      if (filled) _drawPaw(canvas, center, radius / 2.4);
    }
    if (stones != null) {
      _drawShortcutStones(canvas, size, centers, radius, stones);
    }
  }

  void _drawPaw(Canvas canvas, Offset center, double span) {
    final paw = Paint()..color = terracotta;
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, span * .53),
        width: span * 1.92,
        height: span * 1.42,
      ),
      paw,
    );
    for (var toe = 0; toe < 4; toe++) {
      final outer = toe == 0 || toe == 3;
      canvas.drawOval(
        Rect.fromCenter(
          center: center.translate(
            span * (toe - 1.5) * .79,
            span * (outer ? -.29 : -.94),
          ),
          width: span * .61,
          height: span * .78,
        ),
        paw,
      );
    }
  }

  void _drawShortcutStones(
    Canvas canvas,
    Size size,
    List<Offset> centers,
    double radius,
    int stones,
  ) {
    const perPrint = RainMapProgress.groupSize;
    const paired = RainMapProgress.challengeAnswer;
    final slotSize = Size(size.width * .069, size.height * .14);
    final rowY = size.height * .69;
    final guide = Paint()..color = const Color(0xFFB7966F);
    for (int mark = 0; mark < centers.length; mark++) {
      final center = centers[mark];
      canvas.drawLine(
        center.translate(0, radius + 2),
        Offset(center.dx, rowY - slotSize.height * .55),
        guide,
      );
      for (int slot = 0; slot < perPrint; slot++) {
        final x = center.dx + (slot - 1) * slotSize.width * 1.15;
        _drawSlot(
          canvas,
          Offset(x, rowY),
          slotSize,
          filled: mark * perPrint + slot < stones,
        );
      }
    }
    final extraCount = stones - paired;
    for (int extra = 0; extra < extraCount; extra++) {
      final x =
          size.width * .5 +
          (extra - (extraCount - 1) / 2) * slotSize.width * 1.15;
      _drawSlot(canvas, Offset(x, size.height * .88), slotSize, filled: true);
    }
  }

  void _drawSlot(
    Canvas canvas,
    Offset center,
    Size size, {
    required bool filled,
  }) {
    final slot = Rect.fromCenter(
      center: center,
      width: size.width,
      height: size.height,
    );
    if (filled) {
      canvas.save();
      canvas.translate(slot.left, slot.top);
      const _StoneShape(crossed: true, next: false).paint(canvas, size);
      canvas.restore();
    } else {
      canvas.drawOval(
        slot.deflate(2),
        Paint()
          ..color = const Color(0xFFB7966F)
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_PaperTrail oldDelegate) =>
      stamps != oldDelegate.stamps || laidStones != oldDelegate.laidStones;
}
