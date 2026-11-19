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
  (4.16, 'reach'),
  (4.62, 'lower'),
  (4.92, 'lower'),
  (5.48, 'push_low'),
  (5.80, 'push_low'),
  (7.06, 'stretch_low'),
  (7.42, 'stretch_low'),
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
  (6.59, 'wavelift'),
  (6.97, 'catch'),
  (7.27, 'guard'),
  (7.61, 'reach'),
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

// Each influence lives in the painted actor's normalized frame.
const _jointRadii = [
  Offset(.18, .16),
  Offset(.16, .15),
  Offset(.22, .18),
  Offset(.28, .23),
  Offset(.27, .23),
  Offset(.15, .16),
  Offset(.24, .20),
];

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
    const width = _WindArt.rabbitWidth;
    final nearPaw = Offset.lerp(
      art.joints['rabbit_${rabbit.from}']!.nearPaw,
      art.joints['rabbit_${rabbit.to}']!.nearPaw,
      rabbit.mix,
    )!;
    final contact = shot.phase == WindPhase.opening && !shot.noMotion
        ? _smooth(_fraction(4.98, 5.46, shot.age)) *
              (1 - _smooth(_fraction(7.42, 7.86, shot.age)))
        : 0.0;
    final rim = basket + art.basketOffset(art.basketRim);
    final pawOffset = art.actorOffset(nearPaw, width);
    final feet = Offset.lerp(art.restingRabbit, rim - pawOffset, contact)!;
    _shadow(canvas, feet.translate(-.003, -.001), .145, .014);
    _actor(canvas, 'rabbit', feet, rabbit, width);
    _basket(canvas, basket);
    if (contact > 0) {
      // The basket wall covers the far paw. The curled end of the near paw
      // crosses the left wicker rim while the basket moves with it.
      canvas.save();
      canvas.clipPath(
        Path()..addOval(
          Rect.fromCenter(
            center: feet + pawOffset + const Offset(-.011, -.005),
            width: .060,
            height: .036,
          ),
        ),
      );
      _actor(canvas, 'rabbit', feet, rabbit, width);
      canvas.restore();
    }
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
    Offset? anchor,
    bool faceLeft = false,
  }) {
    final image = art.images[name]!;
    final height = width * art.aspect * image.height / image.width;
    final pivot = anchor ?? art.ground;
    c.save();
    c.translate(foot.dx, foot.dy);
    if (faceLeft) c.scale(-1.0, 1.0);
    final dest = Rect.fromLTWH(
      -width * pivot.dx,
      -height * pivot.dy,
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
    const finalWidth = .415;
    // On the floor, the fox turns back towards the rabbit and comes within a
    // nose length. The basket remains visible behind the returning animal.
    final rabbitNose =
        art.restingRabbit +
        art.actorOffset(art.joints['rabbit_reach']!.nose, _WindArt.rabbitWidth);
    final foxNose = art.actorOffset(art.joints['fox_arrive']!.nose, finalWidth);
    final home = Offset(
      rabbitNose.dx + foxNose.dx + .007,
      rabbitNose.dy - foxNose.dy,
    );
    final landing = home.translate(.042, .001);
    final feet = run < 1
        ? Offset.lerp(Offset(1.16, art.door.dy), landing, run)!
        : Offset.lerp(landing, home, _smooth(_fraction(6.55, 7.22, t)))!;
    final width = ui.lerpDouble(.33, finalWidth, run)!;
    _shadow(c, feet, .106 * (.8 + .2 * run), .011);
    if (run < 1) {
      _sprite(c, _stride(t - 4.07), feet, width, faceLeft: true);
    } else {
      _actor(
        c,
        'fox',
        feet,
        _Exposure('brake', 'arrive', _smooth(_fraction(6.55, 7.22, t))),
        width,
        faceLeft: true,
      );
    }
  }

  _Exposure _rabbitExposure() {
    if (shot.phase == WindPhase.complete ||
        shot.phase == WindPhase.reunion && shot.noMotion) {
      return const _Exposure.hold('reach');
    }
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
        (.25, 'push'),
        (.51, 'stretch'),
        (.81, 'wavelift'),
        (1.10, 'idle'),
      ], since);
    }
    return const _Exposure.hold('idle');
  }

  void _actor(
    Canvas c,
    String animal,
    Offset foot,
    _Exposure p,
    double width, {
    bool faceLeft = false,
  }) {
    if (p.from == p.to || p.mix < .007 || p.mix > .993) {
      _sprite(
        c,
        '${animal}_${p.mix < .5 ? p.from : p.to}',
        foot,
        width,
        faceLeft: faceLeft,
      );
      return;
    }
    // Warp the marked joints to their common in-between positions.
    // Expose one drawing at a time so the scarf edges stay opaque and legible.
    final first = p.mix < .5;
    final name = '${animal}_${first ? p.from : p.to}';
    final joints = art.joints[name]!.points;
    final other = art.joints['${animal}_${first ? p.to : p.from}']!.points;
    final strength = first ? p.mix : 1 - p.mix;
    final image = art.images[name]!;
    final widthPx = image.width.toDouble(), heightPx = image.height.toDouble();
    final height = width * art.aspect * heightPx / widthPx;
    final origin = Offset(-width * art.ground.dx, -height * art.ground.dy);
    final coordinates = Float32List(2 * (_meshCols + 1) * (_meshRows + 1));
    final texture = Float32List(coordinates.length);
    var n = 0;
    for (var y = 0; y <= _meshRows; y++) {
      for (var x = 0; x <= _meshCols; x++) {
        final u = x / _meshCols, v = y / _meshRows;
        var dx = 0.0, dy = 0.0, weights = 0.0;
        for (var j = 0; j < joints.length; j++) {
          final handle = joints[j], radius = _jointRadii[j];
          final xDist = (u - handle.dx) / radius.dx;
          final yDist = (v - handle.dy) / radius.dy;
          final w = 1 - xDist * xDist - yDist * yDist;
          if (w <= 0) continue;
          weights += w * w;
          dx += (other[j].dx - handle.dx) * w * w;
          dy += (other[j].dy - handle.dy) * w * w;
        }
        final mix = strength / math.max(1.0, weights);
        coordinates[n] = origin.dx + width * (u + dx * mix);
        texture[n++] = u * widthPx;
        coordinates[n] = origin.dy + height * (v + dy * mix);
        texture[n++] = v * heightPx;
      }
    }
    final mesh = ui.Vertices.raw(
      ui.VertexMode.triangles,
      coordinates,
      textureCoordinates: texture,
      indices: _meshTriangles,
    );
    c.save();
    c.translate(foot.dx, foot.dy);
    if (faceLeft) c.scale(-1.0, 1.0);
    c.drawVertices(
      mesh,
      BlendMode.srcOver,
      Paint()
        ..color = const Color(0xffffffff)
        ..shader = art.shader(name),
    );
    c.restore();
    mesh.dispose();
  }

  static const _leafAngles = [-.61, -.19, .65, .41, -.35];

  void _basket(Canvas c, Offset foot) {
    const width = _WindArt.basketWidth;
    _shadow(c, foot.translate(0, -.002), width * .48, .009);
    _sprite(c, 'basket', foot, width, anchor: art.basketGround);
    final remaining = 5 - _count(shot.mask) - (shot.holding ? 1 : 0);
    for (var i = 0; i < remaining; i++) {
      _leaf(
        c,
        foot + art.basketOffset(art.basketLeaves[i]),
        .066,
        _leafAngles[i],
      );
    }
    _sprite(c, 'basket_front', foot, width, anchor: art.basketGround);
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
    final alreadyLanded = shot.phase != WindPhase.opening || shot.noMotion;
    if (!alreadyLanded && shot.age < .60) {
      return;
    }
    final t = alreadyLanded ? 1.0 : _fraction(.60, 4.18, shot.age);
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
    for (final entry in shot.flights.entries) {
      final leaf = entry.value;
      final flight = shot.flight(leaf.start);
      if (flight >= _WindShot.atGlass) continue;
      final t = _smooth(flight / _WindShot.atGlass);
      final end = art.hitPane(entry.key).center;
      final inBasket = basket + art.basketOffset(art.basketLeaves[leaf.leaf]);
      final from = Offset.lerp(inBasket, heldAt, leaf.lifted)!;
      final width = ui.lerpDouble(.066, .087, leaf.lifted)!;
      final angle = ui.lerpDouble(_leafAngles[leaf.leaf], .16, leaf.lifted)!;
      final center =
          Offset.lerp(from, end, t)! +
          const Offset(.045, -.10) * math.sin(t * math.pi);
      _leaf(
        c,
        center,
        ui.lerpDouble(width, .061, t)!,
        angle - .5 * math.sin(t * math.pi),
      );
    }
    if (shot.holding) {
      final t = shot.noMotion
          ? 1.0
          : _smooth(_fraction(0, .48, shot.now - shot.takingAt));
      final picked = (4 - _count(shot.mask)).clamp(0, 4);
      final start = basket + art.basketOffset(art.basketLeaves[picked]);
      final center = Offset.lerp(start, heldAt, t)!;
      _leaf(
        c,
        center,
        ui.lerpDouble(.066, .087, t)!,
        ui.lerpDouble(_leafAngles[picked], .16, t)!,
      );
    }
  }

  @override
  bool shouldRepaint(_WindPainter old) => true;
}
