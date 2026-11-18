import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../domain/companions.dart';
import 'tailoring.dart';

/// Coordinates in the tightly cropped illustration. The pupil and appendage
/// anchors differ even between growth stages of the same companion.
class PetRig {
  const PetRig(this.leftEye, this.rightEye, this.limb, this.otherLimb);
  final Offset leftEye, rightEye, limb, otherLimb;

  static PetRig forPose(Companion pet, int stage, bool reveal) {
    if (pet == Companion.cat && stage == 4 && !reveal) {
      return const PetRig(
        Offset(.75, .27),
        Offset(.88, .24),
        Offset(.14, .75),
        Offset(.32, .5),
      );
    }
    final row = switch (pet) {
      Companion.fox => const [
        [0.58, 0.43, 0.84, 0.38, .15, .74, .68, .08],
        [0.33, 0.37, 0.5, 0.35, .84, .40, .16, .12],
        [0.3, 0.25, 0.44, 0.23, .85, .34, .13, .10],
        [0.32, 0.45, 0.42, 0.41, .77, .22, .56, .08],
        [0.45, 0.44, 0.51, 0.41, .84, .30, .33, .12],
        [0.65, 0.4, 0.72, 0.37, .23, .44, .41, .17],
      ],
      Companion.rabbit => const [
        [0.487, 0.28, 0.74, 0.213, .14, .66, .88, .58],
        [0.447, 0.187, 0.667, 0.14, .15, .69, .86, .62],
        [0.513, 0.227, 0.653, 0.16, .13, .60, .87, .46],
        [0.533, 0.48, 0.667, 0.433, .16, .22, .85, .16],
        [0.56, 0.46, 0.66, 0.43, .15, .21, .86, .16],
        [0.533, 0.347, 0.615, 0.33, .17, .16, .84, .13],
      ],
      Companion.cat => const [
        [0.553, 0.4, 0.82, 0.34, .13, .71, .74, .09],
        [0.7, 0.26, 0.847, 0.233, .16, .29, .57, .10],
        [0.66, 0.24, 0.847, 0.193, .21, .49, .32, .34],
        [0.793, 0.207, 0.916, 0.186, .19, .29, .32, .74],
        [0.64, 0.233, 0.723, 0.211, .19, .28, .87, .22],
        [0.667, 0.293, 0.733, 0.273, .20, .24, .87, .15],
      ],
    }[stage - 1];
    return PetRig(
      Offset(row[0], row[1]),
      Offset(row[2], row[3]),
      Offset(row[4], row[5]),
      Offset(row[6], row[7]),
    );
  }
}

class _Mesh {
  _Mesh(this.image, this.rig, this.pet, this.bodySize, this.padding) {
    shader = ui.ImageShader(
      image,
      ui.TileMode.clamp,
      ui.TileMode.clamp,
      Matrix4.identity().storage,
      filterQuality: ui.FilterQuality.medium,
    );
    for (var j = 0; j <= rows; j++) {
      for (var i = 0; i <= columns; i++) {
        final n = j * (columns + 1) + i;
        uv[n * 2] = i / columns * image.width;
        uv[n * 2 + 1] = j / rows * image.height;
        final u = base[n * 2] = (uv[n * 2] - padding.dx) / bodySize.width;
        final v = base[n * 2 + 1] =
            (uv[n * 2 + 1] - padding.dy) / bodySize.height;
        limb[n] = weight(
          u,
          v,
          rig.limb,
          pet == Companion.fox ? .34 : .255,
          .34,
        );
        other[n] = weight(u, v, rig.otherLimb, .23, .31);
        left[n] = weight(u, v, rig.leftEye, .082, .095);
        right[n] = weight(u, v, rig.rightEye, .066, .082);
        upper[n] = math.pow(math.max(0.0, 1 - v), 1.28).toDouble();
      }
    }
  }
  static const columns = 40, rows = 44, count = (columns + 1) * (rows + 1);
  static final indices = Uint16List.fromList([
    for (var j = 0; j < rows; j++)
      for (var i = 0; i < columns; i++) ...[
        j * (columns + 1) + i,
        (j + 1) * (columns + 1) + i,
        j * (columns + 1) + i + 1,
        j * (columns + 1) + i + 1,
        (j + 1) * (columns + 1) + i,
        (j + 1) * (columns + 1) + i + 1,
      ],
  ]);
  final ui.Image image;
  final Size bodySize;
  final Offset padding;
  final PetRig rig;
  final Companion pet;
  late final ui.ImageShader shader;
  final base = Float32List(count * 2),
      uv = Float32List(count * 2),
      xy = Float32List(count * 2);
  final limb = Float32List(count),
      other = Float32List(count),
      left = Float32List(count),
      right = Float32List(count),
      upper = Float32List(count);

  static double weight(
    double u,
    double v,
    Offset center,
    double rx,
    double ry,
  ) {
    final x = (u - center.dx) / rx, y = (v - center.dy) / ry;
    final distance = (1 - x * x - y * y).clamp(0.0, 1.0);
    return distance * distance * (3 - 2 * distance);
  }

  void paint(
    Canvas canvas,
    Rect rect,
    double time,
    double reaction,
    double walking,
    double gaze,
    bool still,
  ) {
    final t = still ? 0.0 : time;
    final wave = math.sin(reaction * math.pi),
        swing = wave * math.sin(reaction * math.pi * 3.6);
    final breath = math.sin(t * 2.1) * .010 + wave * .010;
    final tilt = math.sin(t * 1.02) * .005 + swing * .019 + gaze * .043;
    final phase = t % 4.1;
    final blink = phase > 3.69 && phase < 3.91
        ? math.sin((phase - 3.69) / .22 * math.pi)
        : 0.0;
    final tip =
        math.sin(t * 1.78) * .007 +
        swing * (pet == Companion.fox ? .113 : .072);
    final lift =
        math.sin(time * 10).abs() * walking * .04 +
        wave * (pet == Companion.rabbit ? .083 : .021);
    final stillOffset = still ? 0.0 : 1.0;
    for (var n = 0; n < count; n++) {
      final u = base[n * 2], v = base[n * 2 + 1];
      final l = limb[n], r = other[n], h = upper[n];
      final x =
          u +
          stillOffset *
              (tilt * h +
                  tip * l * (.62 - v + rig.limb.dy) -
                  tip * r * (pet == Companion.rabbit ? .74 : .50));
      final y =
          v +
          stillOffset *
              (-breath * h -
                  lift +
                  tip * .27 * l -
                  tip * .23 * r +
                  blink *
                      ((rig.leftEye.dy - v) * left[n] +
                          (rig.rightEye.dy - v) * right[n]) *
                      .96);
      xy[n * 2] = rect.left + x * rect.width;
      xy[n * 2 + 1] = rect.top + y * rect.height;
    }
    final mesh = ui.Vertices.raw(
      ui.VertexMode.triangles,
      xy,
      textureCoordinates: uv,
      indices: indices,
    );
    canvas.drawVertices(
      mesh,
      ui.BlendMode.srcOver,
      Paint()
        ..shader = shader
        ..isAntiAlias = true,
    );
    mesh.dispose();
  }
}

class IllustratedPet extends StatefulWidget {
  const IllustratedPet({
    super.key,
    required this.pet,
    required this.stage,
    required this.reveal,
    required this.outfit,
    required this.clock,
    required this.seconds,
    required this.reaction,
    required this.walking,
    required this.gaze,
    required this.still,
  });
  final Companion pet;
  final int stage;
  final bool reveal, still;
  final Map<String, String> outfit;
  final Listenable clock;
  final double Function() seconds, reaction, walking, gaze;
  @override
  State<IllustratedPet> createState() => _IllustratedPetState();
}

class _IllustratedPetState extends State<IllustratedPet> {
  final _streams = <String, (ImageStream, ImageStreamListener)>{};
  final _images = <String, ImageInfo>{};
  _Mesh? mesh;
  ui.Image? _dressed;
  String? _requested;
  String get path => portraitArtwork(
    widget.pet,
    widget.stage,
    widget.reveal,
    widget.outfit['body'],
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(IllustratedPet oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resolve();
  }

  void _rebuildTexture() {
    final body = _images[path]?.image;
    if (body == null) return;
    final clothes = <String, ui.Image>{};
    for (final entry in widget.outfit.entries) {
      if (entry.key == 'body') continue;
      final image = _images[wornArtwork(entry.value)]?.image;
      if (image == null) return;
      clothes[entry.key] = image;
    }
    final rig = PetRig.forPose(widget.pet, widget.stage, widget.reveal);
    final dressed = clothes.isEmpty
        ? null
        : applyAccessories(
            body,
            widget.pet,
            widget.stage,
            widget.reveal,
            rig.leftEye,
            rig.rightEye,
            clothes,
            widget.outfit['head'],
          );
    mesh?.shader.dispose();
    _dressed?.dispose();
    _dressed = dressed?.image;
    mesh = _Mesh(
      _dressed ?? body,
      rig,
      widget.pet,
      Size(body.width.toDouble(), body.height.toDouble()),
      dressed?.padding ?? Offset.zero,
    );
  }

  void _resolve() {
    final needed = {
      path,
      for (final entry in widget.outfit.entries)
        if (entry.key != 'body') wornArtwork(entry.value),
    };
    final keyset = (needed.toList()..sort()).join('|');
    if (_requested == keyset) return;
    _requested = keyset;
    mesh?.shader.dispose();
    mesh = null;
    _dressed?.dispose();
    _dressed = null;
    for (final key
        in _streams.keys.where((key) => !needed.contains(key)).toList()) {
      final (stream, listener) = _streams.remove(key)!;
      stream.removeListener(listener);
      _images.remove(key)?.dispose();
    }
    var subscribing = true;
    for (final key in needed.where((k) => !_streams.containsKey(k))) {
      final stream = AssetImage(key)
          .resolve(createLocalImageConfiguration(context));
      final listener = ImageStreamListener((info, synchronous) {
        if (!mounted) {
          info.dispose();
          return;
        }
        _images.remove(key)?.dispose();
        _images[key] = info;
        if (!subscribing) setState(_rebuildTexture);
      });
      _streams[key] = (stream, listener);
      stream.addListener(listener);
    }
    subscribing = false;
    _rebuildTexture();
  }

  @override
  void dispose() {
    for (final pair in _streams.values) {
      pair.$1.removeListener(pair.$2);
    }
    mesh?.shader.dispose();
    _dressed?.dispose();
    for (final info in _images.values) {
      info.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      RepaintBoundary(child: CustomPaint(painter: _PetPainter(widget, mesh)));
}

class _PetPainter extends CustomPainter {
  _PetPainter(this.actor, this.mesh) : super(repaint: actor.clock);
  final IllustratedPet actor;
  final _Mesh? mesh;
  @override
  void paint(Canvas canvas, Size size) {
    final m = mesh;
    if (m == null || size.isEmpty) return;
    final source = m.bodySize;
    final dest = applyBoxFit(BoxFit.contain, source, size).destination;
    final rect = Alignment.bottomCenter.inscribe(dest, Offset.zero & size);
    final t = actor.seconds(),
        reaction = actor.still ? 0.0 : actor.reaction(),
        walking = actor.still ? 0.0 : actor.walking();
    m.paint(canvas, rect, t, reaction, walking, actor.gaze(), actor.still);
  }

  @override
  bool shouldRepaint(_PetPainter old) => true;
}
