part of 'wind_stage.dart';

class _Patch {
  _Patch.fromJson(Map<String, dynamic> json)
    : path = json['path'] as String,
      rect = _rect(json['rect'] as List);

  final String path;
  final Rect rect;
}

Rect _rect(List values) => Rect.fromLTRB(
  (values[0] as num).toDouble(),
  (values[1] as num).toDouble(),
  (values[2] as num).toDouble(),
  (values[3] as num).toDouble(),
);

Offset _point(List values) =>
    Offset((values[0] as num).toDouble(), (values[1] as num).toDouble());

class _WindArt {
  _WindArt._(Map<String, dynamic> json)
    : base = _Patch.fromJson(json['base'] as Map<String, dynamic>),
      panes = [
        for (final cell in json['cells'] as List)
          _Patch.fromJson(cell as Map<String, dynamic>),
      ],
      lights = [
        for (final layer in json['lights'] as List)
          _Patch.fromJson(layer as Map<String, dynamic>),
      ],
      rail = _Patch.fromJson(json['rail'] as Map<String, dynamic>),
      bridge = [for (final p in json['bridge'] as List) _point(p as List)],
      rabbit = _point(json['actors']['rabbit'] as List),
      basket = _point(json['actors']['basket'] as List),
      door = _point(json['actors']['door'] as List),
      aspect = (json['size'][0] as num) / (json['size'][1] as num);

  static const _actors = 'assets/wind/actors/';
  static const _sprites = [
    'rabbit_idle',
    'rabbit_notice',
    'rabbit_listen',
    'rabbit_catch',
    'rabbit_guard',
    'rabbit_reach',
    'rabbit_lower',
    'rabbit_push',
    'rabbit_stretch',
    'rabbit_recoil',
    'rabbit_wavelift',
    'rabbit_wave',
    'fox_wait',
    'fox_look',
    'fox_run1',
    'fox_run2',
    'fox_run3',
    'fox_run4',
    'fox_brake',
    'fox_arrive',
    'basket',
    'basket_front',
    'leaf',
  ];

  final double aspect;
  final _Patch base, rail;
  final List<_Patch> panes, lights;
  final Offset rabbit, basket, door;
  final List<Offset> bridge;
  final images = <String, ui.Image>{};
  final _shaders = <String, ui.ImageShader>{};

  ui.ImageShader shader(String name) => _shaders.putIfAbsent(
    name,
    () => ui.ImageShader(
      images[name]!,
      ui.TileMode.clamp,
      ui.TileMode.clamp,
      Matrix4.identity().storage,
      filterQuality: FilterQuality.medium,
    ),
  );

  static Future<_WindArt> load(AssetBundle bundle) async {
    final json = jsonDecode(
      await bundle.loadString('assets/wind/room/room.json'),
    ) as Map<String, dynamic>;
    final art = _WindArt._(json);
    if (art.panes.length != 12 ||
        art.lights.length != 3 ||
        art.bridge.length < 2) {
      throw const FormatException('暖廊缺少窗格、光路或石桥画位');
    }
    final keys = <String, String>{
      for (final p in [art.base, ...art.panes, ...art.lights, art.rail])
        p.path: p.path,
      for (final sprite in _sprites) sprite: '$_actors$sprite.webp',
    }.entries.toList();
    try {
      // Limit simultaneous full-resolution decoder allocations on small devices.
      for (var i = 0; i < keys.length; i += 6) {
        await Future.wait(
          keys.skip(i).take(6).map((entry) async {
            final bytes = await bundle.loadBuffer(entry.value);
            final codec = await ui.instantiateImageCodecWithSize(bytes);
            try {
              art.images[entry.key] = (await codec.getNextFrame()).image;
            } finally {
              codec.dispose();
            }
          }),
        );
      }
    } catch (_) {
      art.dispose();
      rethrow;
    }
    return art;
  }

  // Cropped paint patches include brushwork past the lead lines. Hit the
  // glazing itself, following the six actual columns in the original painting.
  static const _columns = [
    (.096, .207),
    (.222, .335),
    (.388, .497),
    (.512, .624),
    (.673, .782),
    (.799, .904),
  ];
  Rect hitPane(int pane) {
    final col = _columns[(pane ~/ 4) * 2 + pane % 2];
    final top = pane % 4 < 2;
    return Rect.fromLTRB(
      col.$1 - .004,
      top ? .207 : .332,
      col.$2 + .004,
      top ? .33 : .458,
    );
  }

  Offset bridgeAt(double fraction) {
    // Catmull–Rom interpolates the artist's foot placements along the arch.
    final t = fraction.clamp(0.0, 1.0) * (bridge.length - 1);
    final i = t.floor().clamp(0, bridge.length - 2);
    final u = t - i, u2 = u * u, u3 = u2 * u;
    final a = bridge[math.max(0, i - 1)], b = bridge[i];
    final c = bridge[i + 1], d = bridge[math.min(bridge.length - 1, i + 2)];
    return (b * 2 +
            (c - a) * u +
            (a * 2 - b * 5 + c * 4 - d) * u2 +
            (b * 3 - a - c * 3 + d) * u3) *
        .5;
  }

  void dispose() {
    for (final shader in _shaders.values) {
      shader.dispose();
    }
    for (final image in images.values) {
      image.dispose();
    }
    images.clear();
  }
}

double _fraction(double from, double to, double value) =>
    ((value - from) / (to - from)).clamp(0.0, 1.0);

double _smooth(double t) => t * t * (3 - 2 * t);

class _WindShot extends ChangeNotifier {
  static const openingLength = 10.3, reunionLength = 7.7;
  // The fox's four paws travel on the arch. Each stop is at the end of the
  // continuous part of the road, regardless of the order Alice filled the glass.
  static const firstStop = .30, secondStop = .68;
  static const flightLength = .63, stepLength = 2.2;
  static const never = -10000.0;

  WindPhase phase = WindPhase.opening;
  int mask = 0;
  bool holding = false, noMotion = false;
  double now = 0, phaseAt = 0, movingUntil = 0;
  double takingAt = never, seatingAt = never, stepAt = never, lookAt = never;
  double stepFrom = firstStop, reunionFrom = firstStop;
  int? flyingPane;
  double? footfallDue;
  double get age => now - phaseAt;
  final glazing = ValueNotifier<int>(0);

  @override
  void dispose() {
    glazing.dispose();
    super.dispose();
  }

  void reset(WindPhase next, int leaves, bool held) {
    phase = next;
    mask = leaves;
    holding = held;
    phaseAt = now;
    takingAt = seatingAt = stepAt = lookAt = never;
    stepFrom = reunionFrom = leaves & 1 != 0 ? secondStop : firstStop;
    movingUntil = now;
    flyingPane = null;
    footfallDue = null;
    glazing.value = visibleMask;
  }

  void update(WindPhase next, int leaves, bool held, bool reduced) {
    noMotion = reduced;
    if (leaves & mask != mask || next == WindPhase.opening && next != phase) {
      reset(next, leaves, held);
      return;
    }
    final foxBefore = bridgeFraction;
    final changed = mask ^ leaves;
    if (phase == WindPhase.playing && changed != 0 && !reduced) {
      if (changed & (changed - 1) == 0) {
        flyingPane = 7 + changed.bitLength - 1;
        seatingAt = now;
        movingUntil = math.max(movingUntil, now + 1.12);
      }
      if (changed & 1 != 0 && next == WindPhase.playing) {
        stepFrom = foxBefore;
        stepAt = now + flightLength;
        footfallDue = stepAt + .22;
        movingUntil = math.max(movingUntil, stepAt + stepLength + .32);
      } else if (leaves & 30 == 30 && leaves & 1 == 0) {
        lookAt = now + flightLength;
        movingUntil = math.max(movingUntil, lookAt + 2.3);
      }
    }
    if (held && !holding && !reduced) {
      takingAt = now;
      movingUntil = math.max(movingUntil, now + .48);
    }
    if (phase != next) {
      phaseAt = now;
      if (next == WindPhase.reunion) {
        reunionFrom = foxBefore;
        footfallDue = null;
      }
    }
    phase = next;
    mask = leaves;
    holding = held;
    glazing.value = visibleMask;
  }

  void settle() {
    final changed = !noMotion || flyingPane != null || footfallDue != null;
    noMotion = true;
    flyingPane = null;
    footfallDue = null;
    stepAt = takingAt = seatingAt = lookAt = never;
    movingUntil = now;
    glazing.value = visibleMask;
    if (changed) notifyListeners();
  }

  void advance(double dt) {
    noMotion = false;
    now += dt;
    glazing.value = visibleMask;
    notifyListeners();
  }

  double get flight => _fraction(seatingAt, seatingAt + flightLength, now);
  int get visibleMask {
    final pane = flyingPane;
    if (pane != null && flight < .91 && !noMotion) {
      return mask & ~(1 << (pane - 7));
    }
    return mask;
  }

  double get bridgeFraction {
    if (mask & 1 == 0) return firstStop;
    if (stepAt == never || noMotion) return secondStop;
    return ui.lerpDouble(
      stepFrom,
      secondStop,
      _smooth(_fraction(stepAt, stepAt + stepLength, now)),
    )!;
  }

  Offset basketAt(_WindArt art) {
    final slide = phase == WindPhase.opening && !noMotion
        ? _smooth(_fraction(5.36, 7.23, age))
        : 1.0;
    return art.basket.translate((slide - 1) * .085, (slide - 1) * .004);
  }
}
