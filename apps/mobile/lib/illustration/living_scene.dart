import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/companions.dart';
import '../domain/layout_rules.dart';
import '../domain/rules.dart';
import 'puppet.dart';

import 'room_painting.dart';
export 'room_painting.dart';

enum HomeView { courtyard, veranda }

/// Maps the original save coordinates to the illustrated veranda, and back.
/// The older garden-shaped placement boundary remains valid for existing saves.
class SceneProjection {
  const SceneProjection(this.viewport, this.world, this.origin, this.veranda);
  final Size viewport, world;
  final Offset origin;
  final bool veranda;
  factory SceneProjection.fit(Size viewport, double pan, bool veranda) {
    final w = math.max(viewport.width, viewport.height * 1.5);
    final size = Size(w, w / 1.5);
    final fraction = (.456 + pan).clamp(0.0, 1.0);
    return SceneProjection(
      viewport,
      size,
      Offset(
        -(w - viewport.width) * fraction,
        -(size.height - viewport.height) * .54,
      ),
      veranda,
    );
  }
  Offset screen(Offset source) =>
      origin + Offset(source.dx * world.width, source.dy * world.height);
  Offset normalized(Offset screen) => Offset(
    (screen.dx - origin.dx) / world.width,
    (screen.dy - origin.dy) / world.height,
  );
  Offset fromSave(Offset point, {bool mount = false}) {
    if (!veranda) return point;
    if (mount) return const Offset(.315, .305);
    return Offset(
      .51 + (point.dx - .384) * 1.62,
      .765 + (point.dy - .831) * 1.25,
    );
  }

  Offset toSave(Offset point, {bool mount = false}) {
    if (!veranda) return point;
    if (mount && (point - const Offset(.315, .305)).distance < .1) {
      return const Offset(.36, .27);
    }
    return Offset(
      (point.dx - .51) / 1.62 + .384,
      (point.dy - .765) / 1.25 + .831,
    );
  }
}

class GardenScene extends StatefulWidget {
  const GardenScene({
    super.key,
    required this.companion,
    required this.stage,
    this.label = '银杏家园',
    this.reveal = false,
    this.rules,
    this.scene,
    this.pieces = const [],
    this.outfit = const {},
    this.detailFrame,
    this.view = HomeView.courtyard,
    this.immersive = false,
    this.focus = false,
    this.height,
    this.showLabel = true,
    this.onViewChanged,
  });
  final Companion companion;
  final int stage;
  final String label;
  final bool reveal, immersive, focus, showLabel;
  final double? height;
  final Rules? rules;
  final SceneDefinition? scene;
  final List<ScenePiece> pieces;
  final Map<String, String> outfit;
  final Rect? detailFrame;
  final HomeView view;
  final ValueChanged<HomeView>? onViewChanged;
  @override
  State<GardenScene> createState() => _GardenSceneState();
}

class _SceneTime extends ChangeNotifier {
  double seconds = 0;
  void tick(double dt) {
    seconds += dt;
    notifyListeners();
  }
}

class _GardenSceneState extends State<GardenScene>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _time = _SceneTime();
  late final Ticker _ticker;
  Duration? _last;
  bool _still = false, _active = true, _route = true;
  double _pan = 0, _hello = -20, _walkStart = -20, _walkDuration = 1;
  Offset _start = const Offset(.47, .932), _end = const Offset(.47, .932);
  bool _stroking = false;
  double _gaze = 0;
  bool get _base => widget.scene == null || widget.scene!.id == 'base_room';
  bool get _veranda =>
      _base && (widget.view == HomeView.veranda || widget.focus);
  bool get _outdoor => _base ? !_veranda : widget.scene!.id == 'garden';
  double get _reaction => ((_time.seconds - _hello) / 1.35).clamp(0, 1);
  double get _step =>
      ((_time.seconds - _walkStart) / _walkDuration).clamp(0, 1);
  Offset get _foot =>
      Offset.lerp(_start, _end, Curves.easeInOut.transform(_step))!;
  Offset get _rest => widget.focus
      ? const Offset(.508, .938)
      : _veranda
      ? const Offset(.58, .916)
      : _base
      ? const Offset(.47, .937)
      : const Offset(.54, .929);
  String get _back => _veranda
      ? 'assets/art/veranda.webp'
      : widget.scene?.background ?? 'assets/art/garden.webp';
  String get _greeting => switch (widget.companion) {
    Companion.fox => '奶油摇了摇尾巴',
    Companion.rabbit => '桃桃轻轻跳了一下',
    Companion.cat => widget.stage >= 4 ? '团团舒展了云翼' : '团团晃了晃小尾巴',
  };

  @override
  void initState() {
    super.initState();
    _start = _end = _rest;
    WidgetsBinding.instance.addObserver(this);
    _active =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _ticker = createTicker((elapsed) {
      final previous = _last;
      if (previous != null && (elapsed - previous).inMicroseconds < 33000) {
        return;
      }
      _last = elapsed;
      if (!_stroking) _gaze *= .81;
      _time.tick(
        previous == null
            ? 0
            : math.min(.09, (elapsed - previous).inMicroseconds / 1e6),
      );
    });
  }

  @override
  void didUpdateWidget(GardenScene old) {
    super.didUpdateWidget(old);
    if (old.view != widget.view ||
        old.scene?.id != widget.scene?.id ||
        old.companion != widget.companion ||
        old.stage != widget.stage) {
      _start = _end = _rest;
      _hello = _walkStart = -20;
      _pan = 0;
      _stroking = false;
      _gaze = 0;
    }
    _sync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still =
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context);
    _route = TickerMode.valuesOf(context).enabled;
    _sync();
  }

  void _sync() {
    final run = !_still && _active && _route;
    if (run && !_ticker.isActive) {
      _last = null;
      _ticker.start();
    } else if (!run && _ticker.isActive) {
      _ticker.stop();
      _last = null;
      _start = _end;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    _sync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _time.dispose();
    super.dispose();
  }

  void _greet() {
    _start = _end = _foot;
    _walkStart = -20;
    _hello = _time.seconds;
    if (_still) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(_greeting),
          duration: const Duration(milliseconds: 1200),
        ),
      );
    }
    _time.tick(0);
  }

  void _walk(Offset p) {
    final floor = _base && !_veranda
        ? (widget.scene?.floor ??
              const [
                (.13, .73),
                (.54, .73),
                (.635, .82),
                (.57, .93),
                (.41, .96),
                (.12, .925),
              ])
        : null;
    final onFloor = floor == null
        ? p.dx > .09 && p.dx < .91 && p.dy > .66 && p.dy < .965
        : contains(floor, p.dx, p.dy);
    if (!onFloor) return;
    _start = _foot;
    _end = p;
    _walkStart = _time.seconds;
    _walkDuration = (.45 + (_end - _start).distance * 2).clamp(.45, 1.25);
    if (_still) _start = _end;
    _time.tick(0);
  }

  Rect _petBox(SceneProjection map) {
    final foot = map.screen(_foot);
    final factor = widget.focus
        ? .58
        : widget.immersive
        ? .343
        : .338;
    final side = map.world.height * (factor + (widget.stage - 1) * .023);
    return Rect.fromLTWH(foot.dx - side / 2, foot.dy - side, side, side);
  }

  void _tap(Offset point, SceneProjection map) {
    if (_petBox(map).contains(point) || widget.focus) {
      _greet();
      return;
    }
    _walk(map.normalized(point));
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final h = widget.height ?? box.maxWidth * 2 / 3;
      final size = Size(box.maxWidth, h);
      var map = SceneProjection.fit(size, _pan, _veranda);
      final detail = widget.detailFrame;
      if (detail != null) {
        final zoom = (.46 / detail.width).clamp(1.20, 2.25);
        final world = map.world * zoom;
        final dx = (size.width / 2 - detail.center.dx * world.width).clamp(
          size.width - world.width,
          0.0,
        );
        final dy = (size.height / 2 - detail.center.dy * world.height).clamp(
          size.height - world.height,
          0.0,
        );
        map = SceneProjection(size, world, Offset(dx, dy), _veranda);
      }
      final painting = RoomPainting(
        widget.scene?.id ?? 'base_room',
        _base && !_veranda ? const [] : widget.pieces,
      );
      final frame = map.origin & map.world;
      final pet = IllustratedPet(
        pet: widget.companion,
        stage: widget.stage,
        reveal: widget.reveal,
        outfit: widget.outfit,
        clock: _time,
        seconds: () => _time.seconds,
        reaction: () => _reaction,
        gaze: () => _gaze,
        walking: () => _step < 1 ? 1 : 0,
        still: _still,
      );
      final back = Positioned.fromRect(
        rect: frame,
        child: RepaintBoundary(
          child: Image.asset(
            painting.background ?? _back,
            fit: BoxFit.fill,
            excludeFromSemantics: true,
            filterQuality: FilterQuality.medium,
            gaplessPlayback: true,
          ),
        ),
      );
      final foreground =
          widget.scene != null && !_veranda && painting.background == null
          ? Positioned.fromRect(
              rect: frame,
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: Image.asset(
                    widget.scene!.foreground,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.medium,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            )
          : null;
      final images = {
        for (final layer in painting.layers) layer: _layer(layer, map),
      };
      final actorLabel =
          '${widget.companion.label} · ${stageNames[widget.stage - 1]}';
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.immersive ? 0 : 20),
        child: SizedBox(
          width: size.width,
          height: h,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              back,
              AnimatedBuilder(
                animation: _time,
                child: pet,
                builder: (context, child) {
                  final rect = _petBox(map), foot = map.screen(_foot);
                  bool behind(RoomLayer layer) =>
                      layer.depth <= _foot.dy + .015;
                  final contactWidth =
                      rect.width *
                      (widget.companion == Companion.rabbit ? .50 : .60);
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (final layer in painting.layers.where(behind))
                        images[layer]!,
                      Positioned(
                        left: foot.dx - contactWidth / 2,
                        top: foot.dy - rect.height * .043,
                        width: contactWidth,
                        height: rect.height * .075,
                        child: CustomPaint(
                          painter: _ContactShadow(
                            _outdoor
                                ? const Color(0x80313C26)
                                : const Color(0x79573B2C),
                          ),
                        ),
                      ),
                      Positioned.fromRect(rect: rect, child: child!),
                      for (final layer in painting.layers.where(
                        (p) => !behind(p),
                      ))
                        images[layer]!,
                      if (!_still && _reaction < 1)
                        Positioned(
                          left: (foot.dx - 65).clamp(
                            5.0,
                            math.max(5.0, size.width - 144),
                          ),
                          top: math.max(10, rect.top - 29),
                          child: IgnorePointer(child: _Speech(text: _greeting)),
                        ),
                    ],
                  );
                },
              ),
              ?foreground,
              Positioned.fill(
                child: IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _Air(_time, map, _outdoor, _still),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Semantics(
                  label: actorLabel,
                  hint: '点按伙伴打招呼',
                  button: true,
                  onTap: _greet,
                  child: GestureDetector(
                    excludeFromSemantics: true,
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (d) => _tap(d.localPosition, map),
                    onHorizontalDragStart: (d) {
                      _stroking = _petBox(map)
                          .inflate(4)
                          .contains(d.localPosition);
                    },
                    onHorizontalDragUpdate: (d) {
                      if (_stroking) {
                        final face = _petBox(map);
                        _gaze =
                            ((d.localPosition.dx - face.center.dx) /
                                    (face.width * .35))
                                .clamp(-1.0, 1.0);
                      } else if (widget.immersive &&
                          map.world.width > size.width + 1) {
                        setState(
                          () => _pan =
                              (_pan -
                                      d.delta.dx /
                                          (map.world.width - size.width))
                                  .clamp(-.456, .544),
                        );
                      }
                    },
                    onHorizontalDragEnd: (_) {
                      if (_stroking) _greet();
                      _stroking = false;
                    },
                    onHorizontalDragCancel: () {
                      _stroking = false;
                    },
                  ),
                ),
              ),
              if (widget.onViewChanged != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: TextButton.icon(
                    onPressed: _greet,
                    icon: const Icon(Icons.back_hand_outlined, size: 17),
                    label: Text('摸摸${widget.companion.nickname}'),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      foregroundColor: const Color(0xFF513C2D),
                      backgroundColor: const Color(0xF2FFF8E8),
                      shape: const StadiumBorder(
                        side: BorderSide(color: Color(0xB794794D)),
                      ),
                    ),
                  ),
                ),
              if (widget.onViewChanged != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: _PlaceSwitch(
                    value: widget.view,
                    change: widget.onViewChanged!,
                  ),
                )
              else if (widget.showLabel)
                Positioned(
                  left: 12,
                  top: 12,
                  child: _Speech(text: widget.label),
                ),
            ],
          ),
        ),
      );
    },
  );

  Widget _layer(RoomLayer layer, SceneProjection map) {
    final r = layer.frame;
    return Positioned.fromRect(
      rect: Rect.fromPoints(map.screen(r.topLeft), map.screen(r.bottomRight)),
      child: RepaintBoundary(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (layer.shadow)
              const Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  widthFactor: .9,
                  heightFactor: .085,
                  child: CustomPaint(
                    painter: _ContactShadow(Color(0x785A391C)),
                  ),
                ),
              ),
            Image.asset(
              layer.art,
              fit: BoxFit.fill,
              semanticLabel: layer.name,
              filterQuality: FilterQuality.medium,
              gaplessPlayback: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactShadow extends CustomPainter {
  const _ContactShadow(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width, size.height);
    const unit = Rect.fromLTWH(0, 0, 1, 1);
    final gradient = RadialGradient(
      colors: [
        color,
        color.withValues(alpha: color.a * .61),
        color.withValues(alpha: 0),
      ],
      stops: const [0, .50, 1],
    );
    canvas.drawOval(unit, Paint()..shader = gradient.createShader(unit));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ContactShadow old) => old.color != color;
}

class _Speech extends StatelessWidget {
  const _Speech({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xF7FFF8E8),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xCAB99B70)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF483A2D),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class _PlaceSwitch extends StatelessWidget {
  const _PlaceSwitch({required this.value, required this.change});
  final HomeView value;
  final ValueChanged<HomeView> change;
  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xF7FFF8E8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: const BorderSide(color: Color(0xB794794D)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final v in HomeView.values)
          Semantics(
            selected: value == v,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => change(v),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48, minWidth: 58),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: value == v ? const Color(0xFFEED3A0) : null,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      v == HomeView.courtyard ? '庭院' : '暖廊',
                      style: TextStyle(
                        fontWeight: value == v
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: const Color(0xFF4E3A2C),
                      ),
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

class _Air extends CustomPainter {
  _Air(this.clock, this.map, this.outdoor, this.still) : super(repaint: clock);
  final _SceneTime clock;
  final SceneProjection map;
  final bool outdoor, still;
  static final _leaf = Path()
    ..moveTo(0, 2)
    ..quadraticBezierTo(-3.8, 1, -4.4, -1.7)
    ..quadraticBezierTo(-4.1, -4, -1.1, -3.4)
    ..lineTo(0, -2.4)
    ..quadraticBezierTo(2, -4.6, 4.1, -2.7)
    ..quadraticBezierTo(5.4, -.8, 0, 2)
    ..close();
  @override
  void paint(Canvas c, Size size) {
    if (still) return;
    final t = clock.seconds;
    for (var i = 0; i < (outdoor ? 5 : 9); i++) {
      final k = (t * (outdoor ? .076 : .034) + i * .217) % 1;
      final p = map.screen(
        Offset(
          (.05 + i * .197 + .07 * math.sin(k * 6.28 + i)) % 1,
          .12 + k * (outdoor ? .82 : .69),
        ),
      );
      final fade = math.sin(k * math.pi);
      c.save();
      c.translate(p.dx, p.dy);
      c.rotate(i + t * .54);
      if (outdoor) {
        c.scale((.54 + fade * .31) * math.cos(k * 4 + i), .58 + fade * .33);
        c.drawPath(
          _leaf,
          Paint()..color = Color.fromRGBO(255, 211, 75, .78 * fade),
        );
      } else {
        c.drawCircle(
          Offset.zero,
          .8 + i % 3 * .47,
          Paint()..color = Color.fromRGBO(255, 246, 205, fade * .76),
        );
      }
      c.restore();
    }
    if (outdoor) {
      for (var i = 0; i < 5; i++) {
        final x = .73 + i * .051,
            y = .764 + i % 3 * .043,
            k = (.5 + .5 * math.sin(t * 1.6 + i * 2.7));
        final p = map.screen(Offset(x, y));
        final pen = Paint()
          ..color = Color.fromRGBO(255, 251, 222, k * .71)
          ..strokeWidth = 1.25
          ..strokeCap = StrokeCap.round;
        c.drawLine(p - Offset(k * 4, 0), p + Offset(k * 6, 0), pen);
      }
    }
  }

  @override
  bool shouldRepaint(_Air old) => true;
}
