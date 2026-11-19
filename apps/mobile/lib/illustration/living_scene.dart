import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/companions.dart';
import '../domain/layout_rules.dart';
import '../domain/rules.dart';
import 'puppet.dart';
import 'animated_backdrop.dart';
import 'cat_walk.dart';
import 'companion_motion.dart';

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
    this.playable = false,
    this.chapterButton,
    this.windowsLit = false,
  });
  final Companion companion;
  final Widget? chapterButton;
  final bool windowsLit;
  final int stage;
  final String label;
  final bool reveal, immersive, focus, showLabel, playable;
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
  bool _stroking = false, _left = false;
  PetAction _action = PetAction.rest;
  CatWalkPlan? _catPlan;
  CatWalkPose? _catPose;
  double _actionStart = -20, _actionLength = 1, _nextIdle = 5.8;
  int _idleTurn = 0;
  bool get _playable => widget.playable || widget.onViewChanged != null;
  bool get _hasCatWalk =>
      _playable &&
      widget.companion == Companion.cat &&
      widget.stage == 1 &&
      !widget.reveal;
  PetMotion get _motion {
    if (_still || _time.seconds < _actionStart) return const PetMotion.rest();
    final k = ((_time.seconds - _actionStart) / _actionLength).clamp(0.0, 1.0);
    return k >= 1 ? const PetMotion.rest() : PetMotion(_action, k);
  }

  void _play(PetAction action, double seconds, {double? after}) {
    _action = action;
    _actionStart = after ?? _time.seconds;
    _actionLength = seconds;
    _nextIdle = _actionStart + seconds + 5.8;
  }

  void _restRoutine() {
    if (!_playable ||
        _stroking ||
        _catPlan != null ||
        _time.seconds < _nextIdle) {
      return;
    }
    switch (_idleTurn++ % 4) {
      case 0:
        _play(PetAction.look, 1.8);
      case 1:
      case 3:
        final dx = _foot.dx > _rest.dx - .02 ? -.09 : .06;
        _walk(Offset(_rest.dx + dx, _veranda ? .86 : .87));
      case 2:
        _play(PetAction.stretch, 2.2);
    }
    _nextIdle = _time.seconds + 7;
  }

  void _notice(String text) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(milliseconds: 1150),
      ),
    );
  }

  void _nuzzle() {
    final ready = _stopWalking();
    _hello = -20;
    _play(PetAction.nuzzle, 1.85 + ready - _time.seconds);
    if (_still) _notice('${widget.companion.nickname}蹭了蹭你的手');
    _time.tick(0);
  }

  void _skill() {
    final ready = _stopWalking();
    _hello = -20;
    _play(PetAction.skill, 2.85, after: ready);
    if (_still) {
      _notice('${widget.companion.nickname}使出了${widget.companion.skillName}');
    }
    _time.tick(0);
  }

  void _call(SceneProjection map) {
    final left =
        _foot.dx > map.normalized(Offset(map.viewport.width / 2, 0)).dx;
    final target = map
        .normalized(Offset(map.viewport.width * (left ? .31 : .67), 0))
        .dx;
    _walk(
      Offset(target.clamp(_outdoor ? .23 : .15, _outdoor ? .56 : .82), .864),
    );
    if (_still) _notice('${widget.companion.nickname}来到你身边');
  }

  double _gaze = 0;
  bool get _base => widget.scene == null || widget.scene!.id == 'base_room';
  bool get _veranda =>
      _base && (widget.view == HomeView.veranda || widget.focus);
  bool get _outdoor => _base ? !_veranda : widget.scene!.id == 'garden';
  double get _reaction => _time.seconds < _hello
      ? 1
      : ((_time.seconds - _hello) / 1.35).clamp(0, 1);
  double get _step =>
      ((_time.seconds - _walkStart) / _walkDuration).clamp(0, 1);
  Offset get _foot => _catPose != null
      ? _catNormalized(_catPose!.root)
      : Offset.lerp(_start, _end, Curves.easeInOut.transform(_step))!;

  Offset _catWorld(Offset point) =>
      Offset(point.dx * catWalkWorld.width, point.dy * catWalkWorld.height);

  Offset _catNormalized(Offset point) =>
      Offset(point.dx / catWalkWorld.width, point.dy / catWalkWorld.height);

  void _advanceCat(double time) {
    final plan = _catPlan;
    if (plan == null) return;
    final pose = plan.at(time);
    _left = pose.left;
    if (time >= plan.end) {
      _catPlan = null;
      _catPose = null;
    } else {
      _catPose = pose;
    }
  }

  double _stopWalking() {
    _start = _end = _foot;
    _walkStart = -20;
    if (_catPose case final pose?) {
      final plan = CatWalkPlan.stop(_time.seconds, pose);
      _catPlan = plan;
      _advanceCat(_time.seconds);
      return plan.end;
    }
    return _time.seconds;
  }

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
      _restRoutine();
      final dt = previous == null
          ? 0.0
          : math.min(.35, (elapsed - previous).inMicroseconds / 1e6);
      _advanceCat(_time.seconds + dt);
      _time.tick(dt);
    });
  }

  @override
  void didUpdateWidget(GardenScene old) {
    super.didUpdateWidget(old);
    if (old.view != widget.view ||
        old.scene?.id != widget.scene?.id ||
        old.companion != widget.companion ||
        old.stage != widget.stage ||
        old.focus != widget.focus ||
        old.reveal != widget.reveal) {
      _start = _end = _rest;
      _hello = _walkStart = -20;
      _pan = 0;
      _stroking = false;
      _gaze = 0;
      _action = PetAction.rest;
      _left = false;
      _catPlan = null;
      _catPose = null;
      _idleTurn = 0;
      _nextIdle = _time.seconds + 5.8;
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
    if (_still && _catPlan != null) {
      _catPlan = null;
      _catPose = null;
    }
    if (run && !_ticker.isActive) {
      _last = null;
      _ticker.start();
    } else if (!run && _ticker.isActive) {
      _ticker.stop();
      _last = null;
      if (!_hasCatWalk) _start = _end;
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
    final ready = _stopWalking();
    _action = PetAction.rest;
    _nextIdle = ready + 6.5;
    _hello = ready;
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
    _action = PetAction.rest;
    _hello = -20;
    _nextIdle = _time.seconds + 7;
    if (_hasCatWalk) {
      if (_catPlan != null && p == _end) return;
      final world = _catWorld(p);
      final from =
          _catPose ??
          CatWalkPose.seated(
            _catWorld(_foot),
            _left,
            catWalkWorld.height * _petFactor / catWalkOrigin.dy,
          );
      if ((world - from.root).distance < 1) return;
      _start = _end = p;
      if (_still) {
        _left = p.dx < _catNormalized(from.root).dx;
      } else {
        _catPlan = CatWalkPlan.to(_time.seconds, from, world);
        _advanceCat(_time.seconds);
      }
      _time.tick(0);
      return;
    }
    _start = _foot;
    _left = p.dx < _start.dx;
    _end = p;
    _walkStart = _time.seconds;
    _walkDuration = (.63 + (_end - _start).distance * 3.6).clamp(.63, 1.8);
    if (_still) _start = _end;
    _time.tick(0);
  }

  double get _petFactor =>
      (widget.focus
          ? .58
          : widget.immersive
          ? .343
          : .338) +
      (widget.stage - 1) * .023;

  Rect _petBox(SceneProjection map) {
    final foot = map.screen(_foot);
    final side = map.world.height * _petFactor;
    return Rect.fromLTWH(foot.dx - side / 2, foot.dy - side, side, side);
  }

  bool _touchesPet(Offset point, SceneProjection map, {double padding = 0}) {
    final box = _petBox(map);
    if (!_hasCatWalk) return box.inflate(padding).contains(point);
    // Let taps outside the painted head, body and tail reach the grass.
    final p = (point - box.topLeft) / box.width;
    final margin = padding / box.width;
    final pose = _catPose;
    final side = pose == null ? (_left ? -1.0 : 1.0) : math.cos(pose.yaw);
    final standing = pose == null ? 0.0 : (1 - pose.crouch) * pose.ink;
    bool oval(double x, double y, double rx, double ry) {
      final dx = (p.dx - x) / (rx + margin);
      final dy = (p.dy - y) / (ry + margin);
      return dx * dx + dy * dy <= 1;
    }

    return oval(.5 + side * (.12 + standing * .16), .31, .30, .33) ||
        oval(.5 - side * standing * .07, .74, .26 + standing * .12, .26) ||
        oval(
          .5 - side * (.31 + standing * .12),
          .80 - standing * .13,
          .14,
          .19,
        );
  }

  void _tap(Offset point, SceneProjection map) {
    if (_touchesPet(point, map) || widget.focus) {
      _greet();
      return;
    }
    _walk(map.normalized(point));
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final natural = box.maxWidth * 2 / 3;
      final available = widget.height;
      final artHeight = available == null
          ? natural
          : math.max(120.0, available - (_playable ? 55.0 : 0));
      // A furnished room is composed as one canvas; both side walls stay in view.
      final h = _playable && _veranda && !widget.focus
          ? math.min(artHeight, natural)
          : artHeight;
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
        walking: () =>
            _hasCatWalk ? (_catPose == null ? 0 : 1) : (_step < 1 ? 1 : 0),
        still: _still,
        actionPoses: _playable,
        motion: () => _motion,
        catWalk: _hasCatWalk ? () => _catPose : null,
        catFacesLeft: _hasCatWalk ? () => _left : null,
      );
      final back = Positioned.fromRect(
        rect: frame,
        child: RepaintBoundary(
          child: _playable && !_still
              ? AnimatedBackdrop(
                  asset: painting.background ?? _back,
                  place: _base
                      ? (_veranda ? 'veranda' : 'courtyard')
                      : widget.scene!.id,
                  clock: _time,
                  seconds: () => _time.seconds,
                )
              : Image.asset(
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
      final paintingView = ClipRRect(
        borderRadius: BorderRadius.circular(widget.immersive ? 0 : 20),
        child: SizedBox(
          width: size.width,
          height: h,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              back,
              if (widget.windowsLit && _veranda)
                Positioned.fromRect(
                  rect: frame,
                  child: IgnorePointer(
                    child: Semantics(
                      image: true,
                      label: '三扇彩窗已经点亮',
                      child: Image.asset(
                        'assets/wind/room/home-restored.webp',
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.medium,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                ),
              AnimatedBuilder(
                animation: _time,
                child: pet,
                builder: (context, child) {
                  final rect = _petBox(map), foot = map.screen(_foot);
                  bool behind(RoomLayer layer) =>
                      layer.depth <= _foot.dy + .015;
                  final motion = _motion;
                  final lift = motion.height(widget.companion),
                      travel =
                          motion.travel(widget.companion) * (_left ? -1 : 1);
                  final actorRect = rect.shift(
                    Offset(rect.width * travel, -rect.height * lift),
                  );
                  final catPose = _catPose;
                  final showSkill = motion.action == PetAction.skill;
                  Widget effects(bool front) => Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _SkillPaint(
                          widget.companion,
                          foot,
                          rect.width,
                          motion.progress,
                          front,
                          _left,
                        ),
                      ),
                    ),
                  );
                  final contactWidth =
                      (1 - lift * .85) *
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
                      if (catPose != null && catPose.ink > 0)
                        for (final paw in catPose.paws)
                          Positioned.fromRect(
                            rect: Rect.fromCenter(
                              center: map.screen(_catNormalized(paw.ground)),
                              width: rect.width * .082,
                              height: rect.height * .031,
                            ),
                            child: Opacity(
                              opacity:
                                  catPose.ink *
                                  (1 - paw.lift / catPose.scale / 30).clamp(
                                    0.0,
                                    1.0,
                                  ),
                              child: CustomPaint(
                                painter: _ContactShadow(
                                  _outdoor
                                      ? const Color(0x9c313C26)
                                      : const Color(0x94573B2C),
                                ),
                              ),
                            ),
                          ),
                      if (showSkill) effects(false),
                      Positioned.fromRect(
                        key: const ValueKey('home-companion'),
                        rect: _hasCatWalk
                            ? actorRect.inflate(rect.width / 4)
                            : actorRect,
                        child: Transform.flip(
                          flipX: !_hasCatWalk && _left,
                          child: child!,
                        ),
                      ),
                      if (showSkill) effects(true),
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
                      painter: _Air(
                        _time,
                        map,
                        _outdoor,
                        _still,
                        _base && !_veranda,
                        _playable,
                      ),
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
                    onLongPressStart: (d) {
                      if (_touchesPet(d.localPosition, map)) _nuzzle();
                    },
                    onHorizontalDragStart: (d) {
                      _stroking = _touchesPet(d.localPosition, map, padding: 4);
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
                      if (_stroking) _nuzzle();
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
      if (!_playable) return paintingView;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          paintingView,
          SizedBox(
            width: box.maxWidth,
            child: ColoredBox(
              color: const Color(0xfffaf2e2),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    ?widget.chapterButton,
                    _PlayButton('过来', Icons.pets_outlined, () => _call(map)),
                    _PlayButton(
                      widget.companion.skillName,
                      Icons.auto_awesome_outlined,
                      _skill,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );

  Widget _layer(RoomLayer layer, SceneProjection map) {
    final r = layer.frame;
    final image = Image.asset(
      layer.art,
      alignment: Alignment.bottomCenter,
      fit: layer.flat ? BoxFit.fill : BoxFit.contain,
      semanticLabel: layer.name,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
    );
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
            if (_playable && !_still && layer.art.endsWith('decor_mobile.webp'))
              AnimatedBuilder(
                animation: _time,
                child: image,
                builder: (context, child) => Transform.rotate(
                  angle: math.sin(_time.seconds * 1.7) * .065,
                  alignment: Alignment.topCenter,
                  child: child,
                ),
              )
            else
              image,
          ],
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton(this.label, this.icon, this.press);
  final String label;
  final IconData icon;
  final VoidCallback press;
  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: press,
    icon: Icon(icon, size: 17),
    label: Text(label),
    style: TextButton.styleFrom(
      minimumSize: const Size(48, 44),
      tapTargetSize: MaterialTapTargetSize.padded,
      foregroundColor: const Color(0xff54402f),
      backgroundColor: const Color(0xedfff5de),
      shape: const StadiumBorder(side: BorderSide(color: Color(0xffba9b6d))),
    ),
  );
}

class _SkillPaint extends CustomPainter {
  const _SkillPaint(
    this.pet,
    this.foot,
    this.side,
    this.t,
    this.front,
    this.left,
  );
  final Companion pet;
  final Offset foot;
  final double side, t;
  final bool front, left;
  @override
  void paint(Canvas canvas, Size size) => CompanionEffects.skill(
    canvas,
    pet,
    foot,
    side,
    t,
    front: front,
    left: left,
  );
  @override
  bool shouldRepaint(_SkillPaint old) => true;
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
  _Air(
    this.clock,
    this.map,
    this.outdoor,
    this.still,
    this.river,
    this.playable,
  ) : super(repaint: clock);
  final _SceneTime clock;
  final SceneProjection map;
  final bool outdoor, still, river, playable;
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
    if (playable && !outdoor) {
      // Drifting light through the open right window across the veranda floor.
      final start = map.screen(Offset(.79 + .012 * math.sin(t * .47), .15));
      final end = map.screen(Offset(.43 + .035 * math.sin(t * .48), .95));
      final radius = map.world.width * .055;
      final ray = Path()
        ..moveTo(start.dx - radius * .15, start.dy)
        ..lineTo(start.dx + radius * .2, start.dy)
        ..lineTo(end.dx + radius * 1.7, end.dy)
        ..lineTo(end.dx - radius, end.dy)
        ..close();
      c.drawPath(
        ray,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              const Color(0x00ffefb0),
              Color.fromRGBO(255, 236, 171, .115 + .065 * math.sin(t * .66)),
              const Color(0x00ffefb0),
            ],
          ).createShader(ray.getBounds()),
      );
    }
    if (playable && outdoor) {
      for (var b = 0; b < 2; b++) {
        final u = (t * .07 + b * .49) % 1;
        final p = map.screen(
          Offset(
            .24 + u * .55,
            .53 + .086 * math.sin(u * 8 + b) + .025 * math.sin(t * 2.2 + b),
          ),
        );
        final flutter = math.sin(t * 12 + b).abs() * .85 + .15;
        c.save();
        c.translate(p.dx, p.dy);
        c.rotate(-.31 + .14 * math.sin(t * 2.2));
        c.scale(map.world.height / 370);
        final wing = Paint()
          ..color = Color.fromRGBO(
            b == 0 ? 253 : 240,
            b == 0 ? 199 : 245,
            b == 0 ? 103 : 210,
            pulse(u, 0, 1) * .89,
          );
        c.drawOval(
          Rect.fromCenter(
            center: Offset(-2.7 * flutter, -1),
            width: 6 * flutter,
            height: 6,
          ),
          wing,
        );
        c.drawOval(
          Rect.fromCenter(
            center: Offset(2.5 * flutter, -2),
            width: 5 * flutter,
            height: 7,
          ),
          wing,
        );
        c.drawLine(
          const Offset(0, -1),
          const Offset(.8, 3),
          Paint()
            ..strokeWidth = .85
            ..color = const Color(0xff7d623d),
        );
        c.restore();
      }
    }
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
    if (river) {
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
