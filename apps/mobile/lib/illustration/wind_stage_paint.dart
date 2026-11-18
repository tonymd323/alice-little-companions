part of 'wind_stage.dart';

Rect _whole(ui.Image image) =>
    Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());

final _ink = Paint()
  ..color = const Color(0xffffffff)
  ..filterQuality = FilterQuality.medium
  ..isAntiAlias = true;

void _patch(Canvas canvas, _WindArt art, _Patch patch) {
  final image = art.images[patch.path]!;
  canvas.drawImageRect(image, _whole(image), patch.rect, _ink);
}

class _RoomPainter extends CustomPainter {
  const _RoomPainter(this.art, this.mask);
  final _WindArt art;
  final int mask;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width, size.height);
    _patch(canvas, art, art.base);
    for (var i = 0; i < art.panes.length; i++) {
      if (_filled(i, mask)) _patch(canvas, art, art.panes[i]);
    }
    _patch(canvas, art, art.lights[0]);
    if (mask & 1 != 0) _patch(canvas, art, art.lights[1]);
    if (mask & 30 == 30) _patch(canvas, art, art.lights[2]);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RoomPainter old) => old.art != art || old.mask != mask;
}

// Exposures specify drawn changes of silhouette; consecutive equal names hold
// an expression long enough to read it on a phone. Time is in real seconds.
typedef _KeyPose = (double, String);

const _opening = <_KeyPose>[
  (0, 'idle'),
  (.72, 'idle'),
  (1.13, 'notice'),
  (1.65, 'listen'),
  (2.26, 'listen'),
  (2.54, 'catch'),
  (2.96, 'guard'),
  (3.72, 'guard'),
  (4.19, 'reach'),
  (4.67, 'lower'),
  (5.05, 'lower'),
  (5.62, 'push'),
  (6.08, 'push'),
  (6.97, 'stretch'),
  (7.42, 'stretch'),
  (7.92, 'recoil'),
  (8.43, 'idle'),
  (8.96, 'wavelift'),
  (9.28, 'wave'),
  (9.72, 'wavelift'),
  (10.19, 'idle'),
];

const _reunion = <_KeyPose>[
  (0, 'listen'),
  (.75, 'listen'),
  (1.22, 'notice'),
  (1.8, 'idle'),
  (3.68, 'idle'),
  (4.11, 'notice'),
  (4.55, 'listen'),
  (5.21, 'wavelift'),
  (5.55, 'wave'),
  (5.91, 'wavelift'),
  (6.30, 'wave'),
  (6.72, 'wavelift'),
  (7.16, 'recoil'),
  (7.62, 'idle'),
];

class _Exposure {
  const _Exposure(this.from, this.to, this.mix);
  const _Exposure.hold(String pose) : this(pose, pose, 0);
  final String from, to;
  final double mix;

  static _Exposure at(List<_KeyPose> roll, double time) {
    for (var i = 1; i < roll.length; i++) {
      if (time < roll[i].$1) {
        final last = roll[i - 1], next = roll[i];
        return _Exposure(
          last.$2,
          next.$2,
          _smooth(_fraction(last.$1, next.$1, time)),
        );
      }
    }
    return _Exposure.hold(roll.last.$2);
  }
}

// Letterboxed sprite space. Separate handles follow the ears, face and near
// forepaw between the painted poses. Hind paws remain planted at the baseline.
typedef _Joints = ({Offset ear, Offset face, Offset paw});

const _rabbitJoints = <String, _Joints>{
  'idle': (
    ear: Offset(.39, .24),
    face: Offset(.55, .48),
    paw: Offset(.59, .75),
  ),
  'notice': (
    ear: Offset(.36, .21),
    face: Offset(.55, .46),
    paw: Offset(.59, .73),
  ),
  'listen': (
    ear: Offset(.38, .17),
    face: Offset(.58, .44),
    paw: Offset(.60, .72),
  ),
  'catch': (
    ear: Offset(.40, .23),
    face: Offset(.57, .50),
    paw: Offset(.63, .63),
  ),
  'guard': (
    ear: Offset(.40, .27),
    face: Offset(.57, .53),
    paw: Offset(.61, .61),
  ),
  'reach': (
    ear: Offset(.40, .24),
    face: Offset(.62, .51),
    paw: Offset(.68, .66),
  ),
  'lower': (
    ear: Offset(.39, .28),
    face: Offset(.65, .55),
    paw: Offset(.73, .74),
  ),
  'push': (
    ear: Offset(.35, .29),
    face: Offset(.65, .57),
    paw: Offset(.78, .74),
  ),
  'stretch': (
    ear: Offset(.32, .32),
    face: Offset(.68, .57),
    paw: Offset(.84, .74),
  ),
  'recoil': (
    ear: Offset(.41, .23),
    face: Offset(.56, .48),
    paw: Offset(.64, .69),
  ),
  'wavelift': (
    ear: Offset(.39, .22),
    face: Offset(.55, .46),
    paw: Offset(.65, .62),
  ),
  'wave': (
    ear: Offset(.38, .22),
    face: Offset(.56, .46),
    paw: Offset(.70, .51),
  ),
};

const _meshCols = 14, _meshRows = 15;
final _meshTriangles = Uint16List.fromList([
  for (var j = 0; j < _meshRows; j++)
    for (var i = 0; i < _meshCols; i++) ...[
      j * (_meshCols + 1) + i,
      (j + 1) * (_meshCols + 1) + i,
      j * (_meshCols + 1) + i + 1,
      j * (_meshCols + 1) + i + 1,
      (j + 1) * (_meshCols + 1) + i,
      (j + 1) * (_meshCols + 1) + i + 1,
    ],
]);

class _WindPainter extends CustomPainter {
  _WindPainter(this.art, this.shot) : super(repaint: shot);
  final _WindArt art;
  final _WindShot shot;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width, size.height);
    _bridgeActor(canvas);
    final basket = shot.basketAt(art);
    final rabbit = _rabbitExposure();
    const rabbitWidth = .50;
    final feet = _rabbitFeet(basket, rabbit, rabbitWidth);
    _shadow(canvas, feet.translate(-.003, -.001), .145, .014);
    _basket(canvas, basket);
    _rabbit(canvas, feet, rabbit, rabbitWidth);
    _nearFox(canvas);
    _windblownLeaf(canvas);
    _carriedLeaf(canvas, basket);
    canvas.restore();
  }

  void _sprite(
    Canvas c,
    String name,
    Offset foot,
    double width, {
    Offset anchor = const Offset(.47, .90),
    bool faceLeft = false,
  }) {
    final image = art.images[name]!;
    final height = width * art.aspect * image.height / image.width;
    c.save();
    c.translate(foot.dx, foot.dy);
    if (faceLeft) c.scale(-1.0, 1.0);
    final dest = Rect.fromLTWH(
      -width * anchor.dx,
      -height * anchor.dy,
      width,
      height,
    );
    c.drawImageRect(image, _whole(image), dest, _ink);
    c.restore();
  }

  void _shadow(Canvas c, Offset foot, double width, double height) {
    c.save();
    c.translate(foot.dx, foot.dy);
    c.scale(width, height);
    const rect = Rect.fromLTRB(-1, -1, 1, 1);
    c.drawOval(
      rect,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x725a301f), Color(0x4255341f), Color(0x0055341f)],
          stops: [0, .52, 1],
        ).createShader(rect),
    );
    c.restore();
  }

  String _stride(double time) => 'fox_run${(time * 7.2).floor() % 4 + 1}';

  void _bridgeActor(Canvas c) {
    if (shot.phase == WindPhase.complete ||
        shot.phase == WindPhase.reunion && (shot.noMotion || shot.age > 3.95)) {
      return;
    }
    var point = art.bridgeAt(shot.bridgeFraction);
    var frame = 'fox_wait';
    if (shot.phase == WindPhase.reunion) {
      final progress = _fraction(.59, 3.91, shot.age);
      if (progress < .77) {
        final along = ui.lerpDouble(
          shot.reunionFrom,
          1.0,
          _smooth(_fraction(0, .77, progress)),
        )!;
        point = art.bridgeAt(along);
      } else {
        final atExit = _smooth(_fraction(.77, 1, progress));
        point = Offset.lerp(
          art.bridge.last,
          Offset(1.12, art.bridge.last.dy + .026),
          atExit,
        )!;
      }
      frame = progress == 0 ? 'fox_look' : _stride(shot.age - .59);
    } else if (shot.stepAt != _WindShot.never && !shot.noMotion) {
      final walking = shot.now - shot.stepAt;
      if (walking >= 0 && walking < _WindShot.stepLength) {
        frame = _stride(walking);
      } else if (walking >= _WindShot.stepLength &&
          walking < _WindShot.stepLength + .3) {
        frame = 'fox_brake';
      }
    }
    if (shot.phase == WindPhase.playing &&
        shot.mask & 30 == 30 &&
        shot.mask & 1 == 0 &&
        (shot.noMotion || shot.now >= shot.lookAt)) {
      frame = 'fox_look';
    }
    c.save();
    // The fox disappears behind the near post on the right. The actual bridge
    // rail is repainted over its feet for every position on the arched deck.
    c.clipRect(const Rect.fromLTRB(.075, .427, .905, .66));
    _shadow(c, point, .048, .005);
    _sprite(c, frame, point, .215);
    c.clipRect(Rect.fromCenter(center: point, width: .24, height: .19));
    _patch(c, art, art.rail);
    c.restore();
  }

  void _nearFox(Canvas c) {
    if (shot.phase != WindPhase.complete && shot.phase != WindPhase.reunion) {
      return;
    }
    final settle = shot.phase == WindPhase.complete || shot.noMotion;
    final t = settle ? _WindShot.reunionLength : shot.age;
    if (t < 4.07) return;
    final run = _smooth(_fraction(4.07, 6.45, t));
    final finalFoot = Offset(art.basket.dx + .152, art.rabbit.dy + .015);
    final feet = Offset.lerp(Offset(1.16, art.door.dy), finalFoot, run)!;
    final width = ui.lerpDouble(.33, .415, run)!;
    _shadow(c, feet, .106 * (.8 + .2 * run), .011);
    final frame = run < 1
        ? _stride(t - 4.07)
        : t < 6.97
        ? 'fox_brake'
        : 'fox_arrive';
    _sprite(c, frame, feet, width, faceLeft: true);
  }

  _Exposure _rabbitExposure() {
    if (shot.noMotion) return const _Exposure.hold('idle');
    if (shot.phase == WindPhase.opening) {
      return _Exposure.at(_opening, shot.age);
    }
    if (shot.phase == WindPhase.reunion) {
      return _Exposure.at(_reunion, shot.age);
    }
    if (shot.holding) {
      return _Exposure.at(const [
        (0, 'idle'),
        (.22, 'notice'),
        (.46, 'listen'),
      ], shot.now - shot.takingAt);
    }
    final since = shot.now - shot.seatingAt;
    if (since < 1.1) {
      return _Exposure.at(const [
        (0, 'listen'),
        (.30, 'wavelift'),
        (.55, 'wave'),
        (.80, 'wavelift'),
        (1.10, 'idle'),
      ], since);
    }
    return const _Exposure.hold('idle');
  }

  Offset _rabbitFeet(Offset basket, _Exposure p, double width) {
    if (shot.phase != WindPhase.opening || shot.noMotion) return art.rabbit;
    final contact =
        _smooth(_fraction(4.22, 5.32, shot.age)) *
        (1 - _smooth(_fraction(7.32, 8.18, shot.age)));
    final paw = Offset.lerp(
      _rabbitJoints[p.from]!.paw,
      _rabbitJoints[p.to]!.paw,
      p.mix,
    )!;
    final basketEdge = basket.dx - .115;
    final target = basketEdge - (paw.dx - .47) * width;
    return Offset(
      ui.lerpDouble(art.rabbit.dx, target, contact)!,
      art.rabbit.dy,
    );
  }

  void _rabbit(Canvas c, Offset foot, _Exposure p, double width) {
    if (p.from == p.to || p.mix < .007 || p.mix > .993) {
      _sprite(c, 'rabbit_${p.mix < .5 ? p.from : p.to}', foot, width);
      return;
    }
    // Warp the ear, face and front paw to their common in-between positions.
    // Expose one drawing at a time so the scarf edges stay opaque and legible.
    final first = p.mix < .5;
    final name = 'rabbit_${first ? p.from : p.to}';
    final joints = _rabbitJoints[first ? p.from : p.to]!;
    final other = _rabbitJoints[first ? p.to : p.from]!;
    final strength = first ? p.mix : 1 - p.mix;
    final image = art.images[name]!;
    final widthPx = image.width.toDouble(), heightPx = image.height.toDouble();
    final height = width * art.aspect * heightPx / widthPx;
    final origin = foot - Offset(width * .47, height * .90);
    final coordinates = Float32List(2 * (_meshCols + 1) * (_meshRows + 1));
    final texture = Float32List(coordinates.length);
    var n = 0;
    for (var y = 0; y <= _meshRows; y++) {
      for (var x = 0; x <= _meshCols; x++) {
        final u = x / _meshCols, v = y / _meshRows;
        double influence(Offset joint, double rx, double ry) {
          final dx = (u - joint.dx) / rx, dy = (v - joint.dy) / ry;
          final w = (1 - dx * dx - dy * dy).clamp(0.0, 1.0);
          return w * w;
        }

        final shift =
            (other.ear - joints.ear) * influence(joints.ear, .33, .25) +
            (other.face - joints.face) * influence(joints.face, .31, .24) +
            (other.paw - joints.paw) * influence(joints.paw, .24, .17);
        coordinates[n] = origin.dx + width * (u + shift.dx * strength);
        texture[n++] = u * widthPx;
        coordinates[n] = origin.dy + height * (v + shift.dy * strength);
        texture[n++] = v * heightPx;
      }
    }
    final mesh = ui.Vertices.raw(
      ui.VertexMode.triangles,
      coordinates,
      textureCoordinates: texture,
      indices: _meshTriangles,
    );
    c.drawVertices(
      mesh,
      BlendMode.srcOver,
      Paint()
        ..color = const Color(0xffffffff)
        ..shader = art.shader(name),
    );
    mesh.dispose();
  }

  static const _leafFan = <(double, double, double)>[
    (-.32, -.02, -.6),
    (-.12, -.11, -.36),
    (.14, -.06, .48),
    (.32, -.03, .67),
    (.02, -.12, .08),
  ];

  void _basket(Canvas c, Offset foot) {
    const width = .278;
    final image = art.images['basket']!;
    final height = width * art.aspect * image.height / image.width;
    _shadow(c, foot.translate(0, -.002), width * .48, .009);
    _sprite(c, 'basket', foot, width, anchor: const Offset(.5, 1));
    final remaining = 5 - _count(shot.mask) - (shot.holding ? 1 : 0);
    for (var i = 0; i < remaining; i++) {
      final (x, y, angle) = _leafFan[i];
      _leaf(c, foot.translate(x * width, (-.64 + y) * height), .060, angle);
    }
    _sprite(c, 'basket_front', foot, width, anchor: const Offset(.5, 1));
  }

  void _leaf(
    Canvas c,
    Offset center,
    double width,
    double radians, {
    double face = 1,
  }) {
    final image = art.images['leaf']!;
    final height = width * image.height / image.width;
    // Rotate in physical-pixel proportions rather than in portrait UV space.
    c.save();
    c.translate(center.dx, center.dy);
    c.scale(1.0, art.aspect);
    c.rotate(radians);
    c.scale(face, 1.0);
    c.drawImageRect(
      image,
      _whole(image),
      Rect.fromCenter(center: Offset.zero, width: width, height: height),
      _ink,
    );
    c.restore();
  }

  void _windblownLeaf(Canvas c) {
    if (shot.phase != WindPhase.opening || shot.noMotion || shot.age < .60) {
      return;
    }
    final t = _fraction(.60, 4.18, shot.age);
    final s = _smooth(t);
    final x =
        ui.lerpDouble(.91, .53, s)! +
        math.sin(t * math.pi * 2.7) * math.sin(math.pi * t) * .13;
    final y =
        ui.lerpDouble(.40, .907, t)! +
        math.sin(t * math.pi * 4.4) * math.sin(math.pi * t) * .033;
    final scale = ui.lerpDouble(.036, .068, s)!;
    _leaf(
      c,
      Offset(x, y),
      scale,
      -.25 + 2.03 * math.sin(t * math.pi * 2.3),
      face: .48 + .52 * math.cos(t * math.pi * 3.4).abs(),
    );
  }

  void _carriedLeaf(Canvas c, Offset basket) {
    final heldAt = basket.translate(.023, -.17);
    if (shot.holding) {
      final t = shot.noMotion
          ? 1.0
          : _smooth(_fraction(0, .48, shot.now - shot.takingAt));
      final center = Offset.lerp(basket.translate(0, -.06), heldAt, t)!;
      _leaf(c, center, .087, ui.lerpDouble(-.42, .16, t)!);
      return;
    }
    if (shot.noMotion || shot.flyingPane == null || shot.flight >= .91) return;
    final t = _smooth(shot.flight / .91);
    final end = art.hitPane(shot.flyingPane!).center;
    final center =
        Offset.lerp(heldAt, end, t)! +
        Offset(.045, -.10) * math.sin(t * math.pi);
    _leaf(
      c,
      center,
      ui.lerpDouble(.087, .061, t)!,
      .16 - .5 * math.sin(t * math.pi),
    );
  }

  @override
  bool shouldRepaint(_WindPainter old) => true;
}
