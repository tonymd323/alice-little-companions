import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// The moving pixels come from the room painting itself. Window frames, the
/// bridge, furnishings and the floor stay anchored while the foliage or water moves.
class AnimatedBackdrop extends StatefulWidget {
  const AnimatedBackdrop({
    super.key,
    required this.asset,
    required this.place,
    required this.clock,
    required this.seconds,
  });
  final String asset, place;
  final Listenable clock;
  final double Function() seconds;
  @override
  State<AnimatedBackdrop> createState() => _BackdropState();
}

class _BackdropState extends State<AnimatedBackdrop> {
  ImageStream? stream;
  late final ImageStreamListener listener = ImageStreamListener((info, _) {
    if (!mounted) {
      info.dispose();
      return;
    }
    final previous = mesh, oldImage = image;
    setState(() {
      image = info;
      mesh = _SceneryMesh(info.image, widget.place);
    });
    previous?.shader.dispose();
    oldImage?.dispose();
  });
  ImageInfo? image;
  _SceneryMesh? mesh;
  String? requested;
  void resolve() {
    final key = '${widget.asset}:${widget.place}';
    if (key == requested) return;
    requested = key;
    stream?.removeListener(listener);
    stream = AssetImage(widget.asset)
        .resolve(createLocalImageConfiguration(context));
    stream!.addListener(listener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    resolve();
  }

  @override
  void didUpdateWidget(AnimatedBackdrop old) {
    super.didUpdateWidget(old);
    resolve();
  }

  @override
  void dispose() {
    stream?.removeListener(listener);
    mesh?.shader.dispose();
    image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _SceneryPainter(mesh, widget));
}

class _SceneryMesh {
  _SceneryMesh(ui.Image image, String place)
    : shader = ui.ImageShader(
        image,
        ui.TileMode.clamp,
        ui.TileMode.clamp,
        Matrix4.identity().storage,
        filterQuality: ui.FilterQuality.medium,
      ) {
    for (var y = 0; y <= rows; y++) {
      for (var x = 0; x <= cols; x++) {
        final i = y * (cols + 1) + x, u = x / cols, v = y / rows;
        uv[i * 2] = u * image.width;
        uv[i * 2 + 1] = v * image.height;
        final edge = (math.min(math.min(u, 1 - u), math.min(v, 1 - v)) * 30)
            .clamp(0.0, 1.0);
        double area(double cx, double cy, double rx, double ry) {
          final dx = (u - cx) / rx, dy = (v - cy) / ry;
          final k = (1 - dx * dx - dy * dy).clamp(0.0, 1.0);
          return k * k * (3 - 2 * k) * edge;
        }

        final (leaves, water) = switch (place) {
          'courtyard' => (
            area(.65, .12, .41, .24) + area(.12, .53, .15, .16),
            area(.84, .83, .22, .16),
          ),
          'veranda' => (
            area(.18, .35, .081, .24) +
                area(.47, .33, .072, .18) +
                area(.84, .19, .16, .18),
            area(.90, .57, .11, .09),
          ),
          'garden' => (
            area(.43, .13, .47, .16) + area(.88, .59, .13, .21),
            0.0,
          ),
          'treehouse' => (
            area(.35, .18, .18, .26) + area(.67, .38, .11, .14),
            0.0,
          ),
          'flower_shop' => (
            area(.26, .22, .13, .22) + area(.87, .47, .13, .25),
            0.0,
          ),
          _ => (area(.43, .16, .35, .115) + area(.21, .51, .12, .12), 0.0),
        };
        foliage[i] = leaves;
        ripple[i] = water;
        phase[i] = u * 8 + v * 3;
      }
    }
  }
  static const cols = 38, rows = 28, n = (cols + 1) * (rows + 1);
  final ui.ImageShader shader;
  final uv = Float32List(2 * n),
      xy = Float32List(2 * n),
      foliage = Float32List(n),
      ripple = Float32List(n),
      phase = Float32List(n);
  static final indices = Uint16List.fromList([
    for (var y = 0; y < rows; y++)
      for (var x = 0; x < cols; x++) ...[
        y * (cols + 1) + x,
        (y + 1) * (cols + 1) + x,
        y * (cols + 1) + x + 1,
        y * (cols + 1) + x + 1,
        (y + 1) * (cols + 1) + x,
        (y + 1) * (cols + 1) + x + 1,
      ],
  ]);
  void paint(Canvas c, Size s, double time) {
    for (var i = 0; i < n; i++) {
      final u = (i % (cols + 1)) / cols, v = (i ~/ (cols + 1)) / rows;
      final breeze =
          math.sin(time * 1.32 + phase[i]) +
          .33 * math.sin(time * 2.3 + phase[i] * 1.4);
      xy[i * 2] =
          s.width *
          (u +
              foliage[i] * .009 * breeze +
              ripple[i] * .0045 * math.sin(time * 2.8 + v * 48));
      xy[i * 2 + 1] =
          s.height *
          (v +
              foliage[i] * .0045 * breeze +
              ripple[i] * .004 * math.sin(time * 2 + u * 39));
    }
    final vertices = ui.Vertices.raw(
      ui.VertexMode.triangles,
      xy,
      textureCoordinates: uv,
      indices: indices,
    );
    c.drawVertices(vertices, ui.BlendMode.srcOver, Paint()..shader = shader);
    vertices.dispose();
  }
}

class _SceneryPainter extends CustomPainter {
  _SceneryPainter(this.mesh, this.scene) : super(repaint: scene.clock);
  final _SceneryMesh? mesh;
  final AnimatedBackdrop scene;
  @override
  void paint(Canvas canvas, Size size) =>
      mesh?.paint(canvas, size, scene.seconds());
  @override
  bool shouldRepaint(_SceneryPainter old) =>
      old.mesh != mesh || old.scene != scene;
}
