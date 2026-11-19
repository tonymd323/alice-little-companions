import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

part 'wind_stage_art.dart';
part 'wind_stage_paint.dart';

enum WindPhase { opening, playing, reunion, complete }

/// The window numbers refer to glass panes, in reading order within each sash.
/// The seven original leaves occupy panes 0–6. Placing pane 7 repairs the
/// middle span; panes 8–11 repair the last span in any order.
class WindStage extends StatefulWidget {
  const WindStage({
    super.key,
    required this.phase,
    required this.mask,
    required this.holding,
    required this.onBasket,
    required this.onPane,
    required this.onOpeningDone,
    required this.onReunionDone,
    required this.onCue,
  }) : assert(mask >= 0 && mask <= 31);

  final WindPhase phase;
  final int mask;
  final bool holding;
  final VoidCallback onBasket, onOpeningDone, onReunionDone;
  final ValueChanged<int> onPane;
  final ValueChanged<String> onCue;

  @override
  State<WindStage> createState() => _WindStageState();
}

class _WindStageState extends State<WindStage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final shot = _WindShot();
  late final Ticker ticker;
  _WindArt? paintings;
  AssetBundle? bundle;
  bool failed = false, foreground = true, visible = true, still = false;
  bool finished = false, deferred = false;
  int request = 0, nextCue = 0;
  int tappedLeaves = 0, pendingSeatSounds = 0, shownLeaves = 0, run = 0;
  Duration last = Duration.zero;

  static const openingCues = [
    (at: .65, name: 'wind'),
    (at: 2.65, name: 'scarf'),
    (at: 5.82, name: 'basket'),
  ];
  static const reunionCues = [
    (at: .85, name: 'footsteps'),
    (at: 4.2, name: 'footsteps'),
  ];

  @override
  void initState() {
    super.initState();
    ticker = createTicker(_tick);
    WidgetsBinding.instance.addObserver(this);
    final state = WidgetsBinding.instance.lifecycleState;
    foreground = state == null || state == AppLifecycleState.resumed;
    shot.reset(widget.phase, widget.mask, widget.holding);
    shownLeaves = shot.glazing.value;
    shot.glazing.addListener(_glazingChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    still =
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context);
    visible = TickerMode.valuesOf(context).enabled;
    final source = DefaultAssetBundle.of(context);
    if (bundle != source) {
      bundle = source;
      _load(source);
    }
    _deferSync();
  }

  Future<void> _load(AssetBundle source) async {
    final token = ++request;
    try {
      final art = await _WindArt.load(source);
      if (!mounted || token != request) {
        art.dispose();
        return;
      }
      final old = paintings;
      setState(() {
        paintings = art;
        failed = false;
      });
      // A painter from the last frame can still be attached before rebuild.
      if (old != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
      }
      _deferSync();
    } catch (error, stack) {
      if (!mounted || token != request) return;
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: '风过暖廊',
          context: ErrorDescription('while decoding the chapter artwork'),
        ),
      );
      setState(() => failed = true);
    }
  }

  @override
  void didUpdateWidget(WindStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final gained = widget.mask & ~oldWidget.mask;
    var placed = 0;
    if (widget.mask & oldWidget.mask != oldWidget.mask ||
        widget.phase == WindPhase.opening && widget.phase != oldWidget.phase) {
      tappedLeaves = pendingSeatSounds = 0;
      run++;
    } else if (oldWidget.phase == WindPhase.playing &&
        oldWidget.holding &&
        !widget.holding) {
      placed = tappedLeaves & gained;
      pendingSeatSounds |= placed;
      tappedLeaves = 0;
    }
    shot.update(
      widget.phase,
      widget.mask,
      widget.holding,
      still,
      placed: placed != 0,
    );
    if (oldWidget.phase != widget.phase) {
      finished = false;
      nextCue = 0;
    }
    _deferSync();
  }

  void _tapPane(int pane) {
    if (widget.holding && pane >= 7 && !_filled(pane, widget.mask)) {
      tappedLeaves |= 1 << (pane - 7);
    }
    widget.onPane(pane);
  }

  void _glazingChanged() {
    final prior = shownLeaves, now = shot.glazing.value;
    shownLeaves = now;
    final seated = pendingSeatSounds & now & ~prior;
    if (seated == 0) return;
    pendingSeatSounds &= ~seated;
    final generation = run;
    // Restored glass is silent. Only a confirmed tap that has actually reached
    // the leaded glass can sound, including the last tap that starts the reunion.
    void play() {
      if (!mounted || !foreground || !visible || generation != run) return;
      for (var i = 0; i < _count(seated); i++) {
        widget.onCue('seatLeaf');
      }
      if (seated & 1 != 0) widget.onCue('windowLight');
      if (seated & 30 != 0 && prior & 30 != 30 && now & 30 == 30) {
        widget.onCue('windowLight');
      }
    }

    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => play());
    } else {
      play();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    foreground = state == AppLifecycleState.resumed;
    _sync();
  }

  void _deferSync() {
    if (deferred) return;
    deferred = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      deferred = false;
      if (mounted) _sync();
    });
  }

  bool get isFilm =>
      widget.phase == WindPhase.opening || widget.phase == WindPhase.reunion;

  void _sync() {
    final available = paintings != null && foreground && visible;
    if (available && still) {
      shot.settle();
      if (isFilm && !finished) _finish();
    }
    final moving =
        available &&
        !still &&
        ((isFilm && !finished) || shot.now < shot.movingUntil);
    if (moving && !ticker.isActive) {
      last = Duration.zero;
      ticker.start();
    } else if (!moving && ticker.isActive) {
      ticker.stop();
    }
  }

  void _tick(Duration elapsed) {
    final delta = (elapsed - last).inMicroseconds / 1e6;
    last = elapsed;
    if (delta <= 0) return;
    shot.advance(delta);
    if (isFilm && !finished) {
      final cues = widget.phase == WindPhase.opening
          ? openingCues
          : reunionCues;
      while (nextCue < cues.length && cues[nextCue].at <= shot.age) {
        widget.onCue(cues[nextCue++].name);
      }
      final end = widget.phase == WindPhase.opening
          ? _WindShot.openingLength
          : _WindShot.reunionLength;
      if (shot.age >= end) _finish();
    } else if (widget.phase == WindPhase.playing &&
        shot.footfallDue != null &&
        shot.now >= shot.footfallDue!) {
      shot.footfallDue = null;
      widget.onCue('footsteps');
    }
    _sync();
  }

  void _finish() {
    finished = true;
    if (widget.phase == WindPhase.opening) widget.onOpeningDone();
    if (widget.phase == WindPhase.reunion) widget.onReunionDone();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ticker.dispose();
    shot.glazing.removeListener(_glazingChanged);
    shot.dispose();
    paintings?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final art = paintings;
    if (art == null) {
      return Center(
        child: failed
            ? TextButton(
                onPressed: () {
                  setState(() => failed = false);
                  _load(bundle!);
                },
                child: const Text('重新打开暖廊'),
              )
            : Semantics(
                label: '正在打开暖廊',
                child: const SizedBox.square(
                  dimension: 26,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
      );
    }
    final interactive = widget.phase == WindPhase.playing;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(
          constraints.maxWidth,
          constraints.maxHeight * art.aspect,
        );
        final size = Size(width, width / art.aspect);
        Rect project(Rect r) => Rect.fromLTRB(
          r.left * size.width,
          r.top * size.height,
          r.right * size.width,
          r.bottom * size.height,
        );
        final basket = shot.basketAt(art);
        final foxLabel = switch (widget.phase) {
          WindPhase.complete => '奶油回到暖廊，桃桃在叶篮边等它',
          WindPhase.reunion => '奶油沿连通的光路回家',
          _ when widget.mask & 1 != 0 => '奶油在第三段桥的缺口等',
          _ when widget.mask & 30 == 30 => '奶油望向远处的亮光，仍在第二段桥的缺口等',
          _ => '奶油在第二段桥的缺口等',
        };
        return Center(
          child: SizedBox.fromSize(
            size: size,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: ValueListenableBuilder<int>(
                      key: const ValueKey('wind-painted-glass'),
                      valueListenable: shot.glazing,
                      builder: (context, mask, _) =>
                          CustomPaint(painter: _RoomPainter(art, mask)),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(painter: _WindPainter(art, shot)),
                  ),
                ),
                Positioned(
                  top: size.height * .51,
                  left: size.width * .18,
                  child: Semantics(
                    key: const ValueKey('wind-fox-status'),
                    image: true,
                    label: foxLabel,
                    child: const SizedBox.square(dimension: 1),
                  ),
                ),
                if (interactive) ...[
                  for (var pane = 0; pane < art.panes.length; pane++)
                    Positioned.fromRect(
                      rect: project(art.hitPane(pane)),
                      child: _StageTarget(
                        key: ValueKey('wind-pane-$pane'),
                        label:
                            '第 ${pane ~/ 4 + 1} 扇窗，第 ${pane % 4 + 1} 格，'
                            '${_filled(pane, widget.mask) ? '已有金叶' : '空叶槽'}',
                        onTap: () => _tapPane(pane),
                      ),
                    ),
                  Positioned.fromRect(
                    rect: project(
                      Rect.fromCenter(
                        center: basket.translate(0, -.048),
                        width: _WindArt.basketWidth,
                        height: .15,
                      ),
                    ),
                    child: _StageTarget(
                      key: const ValueKey('wind-basket'),
                      label:
                          '叶篮，${5 - _count(widget.mask) - (widget.holding ? 1 : 0)} 片金叶',
                      onTap: widget.onBasket,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StageTarget extends StatelessWidget {
  const _StageTarget({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: true,
    onTap: onTap,
    child: ExcludeSemantics(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          splashColor: const Color(0x22fff0bb),
          highlightColor: const Color(0x11fff0bb),
          focusColor: const Color(0x66ffe4a5),
        ),
      ),
    ),
  );
}

bool _filled(int pane, int mask) => pane < 7 || (mask & (1 << (pane - 7))) != 0;

int _count(int mask) {
  var count = 0;
  for (var i = 0; i < 5; i++) {
    if (mask & (1 << i) != 0) count++;
  }
  return count;
}
