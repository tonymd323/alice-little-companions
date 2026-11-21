import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../domain/companions.dart';
import 'accessory_poses.dart';
import 'tailoring.dart';
import 'companion_motion.dart';
import 'companion_turns.dart';
import 'action_poses.dart';
import 'companion_walk.dart';
import 'companion_walk_art.dart';
import 'painted_walk.dart';
import 'companion_hops.dart';

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
      Companion.otter => const [
        [.724, .258, .887, .225, .16, .83, .52, .19],
        [.730, .253, .890, .222, .16, .83, .52, .18],
        [.729, .250, .887, .218, .15, .83, .52, .18],
        [.713, .273, .884, .245, .15, .84, .51, .19],
        [.726, .280, .894, .245, .14, .84, .53, .20],
        [.748, .276, .888, .243, .14, .83, .54, .19],
      ],
      Companion.hedgehog => const [
        [.769, .469, .904, .408, .14, .44, .39, .23],
        [.782, .493, .913, .441, .13, .43, .38, .24],
        [.781, .499, .906, .440, .14, .43, .37, .22],
        [.786, .515, .908, .461, .13, .41, .40, .23],
        [.782, .509, .906, .446, .11, .54, .41, .22],
        [.796, .550, .918, .481, .12, .57, .44, .23],
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
  _Mesh(
    this.image,
    this.rig,
    this.pet,
    this.bodySize,
    this.padding, {
    List<PaintedLeg>? pads,
    bool facesLeft = false,
  }) {
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
        farPaw[n] = weight(
          u,
          v,
          Offset(rig.leftEye.dx > .48 ? .29 : .70, .86),
          .24,
          .30,
        );
        upper[n] = math.pow(math.max(0.0, 1 - v), 1.28).toDouble();
      }
    }
    if (pads != null) {
      skin = _PawSkin(pads, facesLeft, base, count);
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
  _PawSkin? skin;
  late final ui.ImageShader shader;
  final base = Float32List(count * 2),
      uv = Float32List(count * 2),
      xy = Float32List(count * 2);
  final limb = Float32List(count),
      other = Float32List(count),
      left = Float32List(count),
      right = Float32List(count),
      upper = Float32List(count),
      farPaw = Float32List(count);

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

  void paintDrawing(Canvas canvas, Rect rect, {double lean = 0}) {
    final scaleX = rect.width / bodySize.width;
    final scaleY = rect.height / bodySize.height;
    final source =
        Offset.zero & Size(image.width.toDouble(), image.height.toDouble());
    final target = Rect.fromLTWH(
      rect.left - padding.dx * scaleX,
      rect.top - padding.dy * scaleY,
      image.width * scaleX,
      image.height * scaleY,
    );
    canvas.save();
    canvas.translate(rect.bottomCenter.dx, rect.bottomCenter.dy);
    canvas.rotate(lean);
    canvas.translate(-rect.bottomCenter.dx, -rect.bottomCenter.dy);
    canvas.drawImageRect(
      image,
      source,
      target,
      Paint()..filterQuality = FilterQuality.medium,
    );
    canvas.restore();
  }

  void paint(
    Canvas canvas,
    Rect rect,
    double time,
    double reaction,
    double gaze,
    bool still,
    PetMotion motion, {
    CompanionHopPose? hop,
    WalkPose? planted,
    bool? mirrored,
    Offset load = Offset.zero,
  }) {
    final t = still ? 0.0 : time;
    final wave = math.sin(reaction * math.pi),
        swing = wave * math.sin(reaction * math.pi * 3.6);
    final breath = math.sin(t * 2.1) * .018 + wave * .010;
    final tilt = math.sin(t * 1.02) * .005 + swing * .019 + gaze * .043;
    final phase = t % 4.1;
    final blink = phase > 3.69 && phase < 3.91
        ? math.sin((phase - 3.69) / .22 * math.pi)
        : 0.0;
    final tip =
        math.sin(t * 1.78) * .024 +
        motion.lean * .065 +
        motion.curl * .09 +
        (hop?.earLag ?? 0) +
        swing * (pet == Companion.fox ? .113 : .072);
    final lift = wave * (pet == Companion.rabbit ? .083 : .021);
    final curl = motion.curl, lean = motion.lean + (hop?.lean ?? 0) * .48;
    final compression = hop?.compression ?? 0;
    final stillOffset = still ? 0.0 : 1.0;
    final support = planted == null
        ? null
        : skin?.at(planted, rect, mirrored: mirrored);
    for (var n = 0; n < count; n++) {
      final u = base[n * 2], v = base[n * 2 + 1];
      final l = limb[n], r = other[n], h = upper[n];
      var x =
          u +
          stillOffset *
              ((tilt + lean * .10 + load.dx / walkOrigin.dy) * h -
                  curl * .05 * h +
                  tip * l * (.62 - v + rig.limb.dy) -
                  tip * r * (pet == Companion.rabbit ? .74 : .50) +
                  compression * .20 * (u - .5) * (1 - v));
      var y =
          v +
          stillOffset *
              ((-breath + curl * .16) * h -
                  lift +
                  (compression + load.dy / walkOrigin.dy) * (1 - v) -
                  (hop?.hindLift ?? 0) * farPaw[n] +
                  tip * .27 * l -
                  tip * .23 * r +
                  blink *
                      ((rig.leftEye.dy - v) * left[n] +
                          (rig.rightEye.dy - v) * right[n]) *
                      .96);
      if (support != null) {
        final (shift, offsets) = support;
        x = u + shift.dx;
        y = v + shift.dy;
        for (var i = 0; i < offsets.length; i++) {
          final strength = skin!.influence[i][n];
          x += offsets[i].dx * strength;
          y += offsets[i].dy * strength;
        }
      }
      xy[n * 2] = rect.left + x * rect.width;
      xy[n * 2 + 1] = rect.top + y * rect.height;
    }
    if (support != null &&
        !meshKeepsShape(
          xy,
          indices,
          rect.width * rect.height / (columns * rows) * .24,
        )) {
      final shift = support.$1;
      paintDrawing(
        canvas,
        rect.shift(Offset(shift.dx * rect.width, shift.dy * rect.height)),
      );
      return;
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
        ..color = const ui.Color(0xffffffff)
        ..shader = shader
        ..isAntiAlias = true,
    );
    mesh.dispose();
  }
}

class _PawSkin {
  _PawSkin(this.legs, this.facesLeft, Float32List vertices, int count)
    : influence = List.generate(legs.length, (_) => Float32List(count)) {
    for (final (index, leg) in legs.indexed) {
      if (!leg.visible) continue;
      final separation = legs
          .where((other) => other != leg && other.visible)
          .map((other) => (leg.pad.dx - other.pad.dx).abs())
          .reduce(math.min);
      for (var n = 0; n < count; n++) {
        final x = vertices[n * 2], y = vertices[n * 2 + 1];
        final down = ((y - leg.shoulder.dy) / (leg.pad.dy - leg.shoulder.dy))
            .clamp(0.0, 1.0);
        final line = ui.lerpDouble(leg.shoulder.dx, leg.pad.dx, down)!;
        final radius = ui.lerpDouble(.125, separation.clamp(.062, .148), down)!;
        final core = ui.lerpDouble(
          0.0,
          separation.clamp(.050, .108) * .38,
          down,
        )!;
        final across = ((radius - (x - line).abs()) / (radius - core)).clamp(
          0.0,
          1.0,
        );
        influence[index][n] =
            easeMotion(((down - .53) / .40).clamp(0.0, 1.0)) *
            easeMotion(across);
      }
    }
  }

  final List<PaintedLeg> legs;
  final bool facesLeft;
  final List<Float32List> influence;

  (Offset, List<Offset>) at(WalkPose pose, Rect rect, {bool? mirrored}) {
    // Follow the support pads with the whole drawing. The local correction
    // stays below the ankle and is bounded by the painted foot.
    final facing = (mirrored ?? (pose.left != facesLeft)) ? -1.0 : 1.0;
    final units = rect.height / walkOrigin.dy / pose.scale;
    final offsets = <Offset>[];
    var body = Offset.zero;
    var load = 0.0;
    for (final (index, leg) in legs.indexed) {
      final paw = pose.paws[index];
      final target = (paw.ground - pose.root - Offset(0, paw.lift)) * units;
      final delta = Offset(
        target.dx / rect.width * facing - (leg.pad.dx - .5),
        target.dy / rect.height - (leg.pad.dy - 1),
      );
      offsets.add(delta);
      if (!leg.visible) continue;
      final pressure =
          (WalkLeg.values[index].near ? 1.7 : .7) /
          (1 + 12 * paw.lift / pose.scale / walkOrigin.dy);
      body += delta * pressure;
      load += pressure;
    }
    final average = body / load;
    final shift = Offset(
      average.dx.clamp(-.060, .060),
      average.dy.clamp(-.024, .026),
    );
    return (
      shift,
      [
        for (final point in offsets)
          Offset(
            (point.dx - shift.dx).clamp(-.028, .028),
            (point.dy - shift.dy).clamp(-.025, .025),
          ),
      ],
    );
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
    this.motion,
    this.drawnMotion,
    this.actionPoses = false,
    this.walkPose,
    this.walkFacesLeft,
    this.hop,
    this.paintedWalk,
  });
  final Companion pet;
  final int stage;
  final bool reveal, still, actionPoses;
  final PetMotion Function()? motion;
  final PetMotion Function()? drawnMotion;
  final WalkPose? Function()? walkPose;
  final bool Function()? walkFacesLeft;
  final CompanionHopPose? Function()? hop;
  final PaintedWalk? paintedWalk;
  final Map<String, String> outfit;
  final Listenable clock;
  final double Function() seconds, reaction, walking, gaze;
  @override
  State<IllustratedPet> createState() => _IllustratedPetState();
}

class _CloudHopArt {
  const _CloudHopArt(this.brace, this.flight, this.landing);

  final (_Mesh, ui.Image?) brace, flight, landing;

  void dispose() {
    for (final (mesh, composite) in [brace, flight, landing]) {
      mesh.shader.dispose();
      composite?.dispose();
    }
  }
}

const _cloudHops = [
  (cloudBraceArt, Offset(.786, .356), Offset(.930, .312)),
  (cloudFlightArt, Offset(.802, .349), Offset(.931, .276)),
  (cloudLandingArt, Offset(.811, .350), Offset(.940, .312)),
];
const _cloudRearHops = [
  (cloudRearBraceArt, Offset(.690, .37), Offset(.850, .32)),
  (cloudRearFlightArt, Offset(.685, .33), Offset(.843, .29)),
  (cloudRearLandingArt, Offset(.727, .37), Offset(.880, .32)),
];

class _IllustratedPetState extends State<IllustratedPet> {
  final _streams = <String, (ImageStream, ImageStreamListener)>{};
  final _images = <String, ImageInfo>{};
  _Mesh? mesh, leftMesh, leapMesh, leftLeapMesh, tuckMesh, landingMesh;
  ui.Image? _dressed, _leftDressed, _leapDressed, _leftLeapDressed;
  _CloudHopArt? _cloudHop, _cloudHopRear;
  WalkArt? _walkArt;
  final _turnArt = <(TurnView, bool), (_Mesh, ui.Image?)>{};
  Map<AccessoryPose, Map<String, ({String path, bool registered})>> _fits =
      const {};
  List<String> get _walkAssets =>
      widget.walkPose == null || widget.paintedWalk != null
      ? const []
      : walkAssets(widget.pet, widget.outfit['body'], paintedScarf: _foxScarf);
  Map<TurnView, TurnFit> get _turnFits =>
      widget.walkPose == null ? const {} : turnFits(widget.pet, widget.stage);

  String _turnPath(TurnView view) =>
      turnArtwork(widget.pet, widget.stage, view, widget.outfit['body']);
  bool get _paintedScarf =>
      widget.pet == Companion.rabbit &&
      widget.stage == 3 &&
      widget.outfit['neck'] == 'item_accessory_scarf';
  String _costume(String artwork) => _paintedScarf
      ? artwork.replaceFirst('assets/art/', 'assets/wind/wardrobe/')
      : artwork;
  Iterable<MapEntry<String, String>> get _accessories =>
      widget.outfit.entries.where(
        (entry) =>
            entry.key != 'body' &&
            !((_paintedScarf || _foxScarf) && entry.key == 'neck'),
      );
  bool get _rightEarBow =>
      widget.pet == Companion.fox &&
      widget.stage == 1 &&
      widget.outfit['head'] == 'item_accessory_bow';
  bool get _turnedBow =>
      _turnFits.isNotEmpty && widget.outfit['head'] == 'item_accessory_bow';
  FittedCoat? get _coat =>
      fittedCoat(widget.pet, widget.stage, widget.outfit['body']);
  bool get _foxScarf =>
      widget.pet == Companion.fox &&
      widget.stage == 1 &&
      widget.outfit['neck'] == 'item_accessory_scarf' &&
      (widget.outfit['body'] == null || _coat == FittedCoat.mapVest);
  bool get _leftFits =>
      (_rightEarBow || _turnedBow || _coat == FittedCoat.mapVest) &&
      widget.walkFacesLeft != null;
  bool get _hasTuck =>
      widget.hop != null &&
      widget.pet == Companion.rabbit &&
      widget.stage == 1 &&
      widget.outfit.isEmpty;
  bool get _hasCloudHop =>
      widget.hop != null &&
      widget.pet == Companion.cat &&
      widget.stage == 4 &&
      (widget.outfit['body'] == null || _coat == FittedCoat.wingCape);
  String _cloudFit(String artwork) => _coat?.on(artwork) ?? artwork;
  List<AccessoryPose> get _walkLooks => _walkAssets.isEmpty
      ? const []
      : [
          AccessoryPose.walkSide,
          if (_rightEarBow) AccessoryPose.walkLeft,
          AccessoryPose.walkFront,
          AccessoryPose.walkBack,
        ];
  Iterable<AccessoryPose> get _looks => [
    AccessoryPose.seated,
    if (_leftFits) AccessoryPose.seatedLeft,
    if (widget.actionPoses) AccessoryPose.airborne,
    if (widget.actionPoses && _leftFits) AccessoryPose.airborneLeft,
    ..._walkLooks,
  ];
  String _leapPath({bool facesLeft = false}) => _costume(
    actionArtwork(
      widget.pet,
      widget.stage,
      widget.outfit['body'],
      facesLeft: facesLeft,
      paintedScarf: _foxScarf,
    ),
  );
  String? _requested;
  String _portraitPath({bool facesLeft = false}) => _costume(
    portraitArtwork(
      widget.pet,
      widget.stage,
      widget.reveal,
      widget.outfit['body'],
      facesLeft: facesLeft,
      paintedScarf: _foxScarf,
    ),
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
    final body = _images[_portraitPath()]?.image;
    final seated = _loadedFit(AccessoryPose.seated);
    if (body == null || seated == null) return;
    final rig = PetRig.forPose(widget.pet, widget.stage, widget.reveal);
    _disposeTextures();
    final (restMesh, restImage) = _makeTexture(body, rig, seated);
    mesh = restMesh;
    _dressed = restImage;
    if ((
          _images[_portraitPath(facesLeft: true)]?.image,
          _loadedFit(AccessoryPose.seatedLeft),
        )
        case (final leftBody?, final left?)) {
      final (variant, image) = _makeTexture(
        leftBody,
        rig,
        left,
        mirrored: _turnedBow,
      );
      leftMesh = variant;
      _leftDressed = image;
    }
    final leap = _images[_leapPath()]?.image;
    final flight = _loadedFit(AccessoryPose.airborne);
    if (leap != null && flight != null) {
      final (near, far) = actionEyes(widget.pet, widget.stage);
      final winged = widget.pet == Companion.cat && widget.stage >= 4;
      final actionRig = PetRig(
        near,
        far,
        winged ? const Offset(.23, .20) : const Offset(.18, .38),
        winged ? const Offset(.81, .16) : const Offset(.64, .13),
      );
      final (airborne, airborneImage) = _makeTexture(
        leap,
        actionRig,
        flight,
        flying: true,
      );
      leapMesh = airborne;
      _leapDressed = airborneImage;
      if ((
            _images[_leapPath(facesLeft: true)]?.image,
            _loadedFit(AccessoryPose.airborneLeft),
          )
          case (final leftLeap?, final left?)) {
        final (variant, image) = _makeTexture(
          leftLeap,
          actionRig,
          left,
          flying: true,
          mirrored: _turnedBow,
        );
        leftLeapMesh = variant;
        _leftLeapDressed = image;
      }
    }
    if (_images[rabbitShortHopArt]?.image case final tuck? when _hasTuck) {
      tuckMesh = _Mesh(
        tuck,
        const PetRig(
          Offset(.68, .30),
          Offset(.89, .19),
          Offset(.21, .25),
          Offset(.43, .12),
        ),
        widget.pet,
        Size(tuck.width.toDouble(), tuck.height.toDouble()),
        Offset.zero,
      );
    }
    if (_images[rabbitLandingArt]?.image case final landing? when _hasTuck) {
      landingMesh = _Mesh(
        landing,
        const PetRig(
          Offset(.71, .35),
          Offset(.92, .26),
          Offset(.31, .25),
          Offset(.42, .14),
        ),
        widget.pet,
        Size(landing.width.toDouble(), landing.height.toDouble()),
        Offset.zero,
      );
    }
    if (_hasCloudHop && flight != null) {
      _cloudHop = _buildCloudHop(_cloudHops, flight);
      _cloudHopRear = _buildCloudHop(_cloudRearHops, (
        generic: {if (flight.generic['head'] case final hat?) 'head': hat},
        registered: const {},
      ));
    }
    _buildWalkArt();
    _buildTurnArt(seated);
  }

  _CloudHopArt? _buildCloudHop(
    List<(String, Offset, Offset)> anchors,
    AccessoryTextures clothes,
  ) {
    if (!anchors.every((card) => _images.containsKey(_cloudFit(card.$1)))) {
      return null;
    }
    final frames = [
      for (final (path, near, far) in anchors)
        _makeTexture(
          _images[_cloudFit(path)]!.image,
          PetRig(near, far, const Offset(.35, .34), const Offset(.69, .30)),
          clothes,
          flying: true,
        ),
    ];
    return _CloudHopArt(frames[0], frames[1], frames[2]);
  }

  (_Mesh, ui.Image?) _makeTexture(
    ui.Image body,
    PetRig rig,
    AccessoryTextures clothes, {
    bool flying = false,
    (TurnView, TurnFit)? turn,
    bool mirrored = false,
  }) {
    final groundFit = flying ? groundActionFit(widget.pet, widget.stage) : null;
    final direction = turn?.$1, turnFit = turn?.$2;
    final anchors = turnFit?.head ?? groundFit;
    final rear = direction?.behind ?? false;
    final distantEar = mirrored
        ? turnFit == null && widget.pet == Companion.otter && widget.stage == 6
              ? (flying ? const Offset(.811, .131) : const Offset(.886, .151))
              : turnFit?.farEar
        : null;
    final hideBow =
        _turnedBow &&
        (turnFit?.earHidden == true || mirrored && distantEar == null);
    final fabric = rear || hideBow
        ? {
            for (final entry in clothes.generic.entries)
              if (!(entry.key == 'face' &&
                      rear &&
                      turnFit?.temples == null &&
                      turnFit?.profileEye != true) &&
                  !(entry.key == 'head' && hideBow))
                entry.key: entry.value,
          }
        : clothes.generic;
    final dressed = fabric.isNotEmpty || clothes.registered.isNotEmpty
        ? applyAccessories(
            body,
            widget.pet,
            widget.stage,
            flying || widget.reveal,
            rig.leftEye,
            rig.rightEye,
            fabric,
            widget.outfit['head'],
            airborne: flying && groundFit == null,
            fit: anchors,
            scarfFit: anchors == null
                ? null
                : (center: anchors.neck, span: anchors.width * .67, back: rear),
            rearTemples: turnFit?.temples,
            headOn: direction == TurnView.front,
            nearLensOnly: turnFit?.profileEye == true,
            distantBowEar: distantEar,
            registered: clothes.registered,
          )
        : null;
    return (
      _Mesh(
        dressed?.image ?? body,
        rig,
        widget.pet,
        Size(body.width.toDouble(), body.height.toDouble()),
        dressed?.padding ?? Offset.zero,
        pads: turnFit != null
            ? [
                for (final pad in turnFit.pads)
                  if (pad == null)
                    const PaintedLeg(Offset.zero, Offset.zero, visible: false)
                  else
                    PaintedLeg(pad - const Offset(0, .16), pad),
              ]
            : flying
            ? null
            : widget.paintedWalk?.legs,
        facesLeft: turnFit == null && (widget.paintedWalk?.facesLeft ?? false),
      ),
      dressed?.image,
    );
  }

  void _buildTurnArt(AccessoryTextures clothes) {
    final fits = _turnFits;
    if (_turnArt.isNotEmpty ||
        fits.isEmpty ||
        !fits.keys.every((view) => _images.containsKey(_turnPath(view)))) {
      return;
    }
    for (final MapEntry(key: view, value: fit) in fits.entries) {
      final body = _images[_turnPath(view)]!.image;
      final (near, far) = fit.eyes;
      final rig = PetRig(near, far, Offset.zero, Offset.zero);
      _turnArt[(view, false)] = _makeTexture(
        body,
        rig,
        clothes,
        turn: (view, fit),
      );
      if (_turnedBow && !view.axial) {
        _turnArt[(view, true)] = _makeTexture(
          body,
          rig,
          clothes,
          turn: (view, fit),
          mirrored: true,
        );
      }
    }
  }

  void _disposeTurnArt() {
    for (final (mesh, composite) in _turnArt.values) {
      mesh.shader.dispose();
      composite?.dispose();
    }
    _turnArt.clear();
  }

  AccessoryTextures? _loadedFit(AccessoryPose pose) {
    final layers = _fits[pose];
    if (layers == null) return null;
    final generic = <String, ui.Image>{}, registered = <String, ui.Image>{};
    for (final entry in layers.entries) {
      final image = _images[entry.value.path]?.image;
      if (image == null) return null;
      (entry.value.registered ? registered : generic)[entry.key] = image;
    }
    return (generic: generic, registered: registered);
  }

  void _buildWalkArt() {
    final paths = _walkAssets;
    if (_walkArt != null ||
        paths.isEmpty ||
        !paths.every(_images.containsKey)) {
      return;
    }
    final clothes = <AccessoryPose, AccessoryTextures>{};
    for (final pose in _walkLooks) {
      final loaded = _loadedFit(pose);
      if (loaded == null) return;
      clothes[pose] = loaded;
    }
    _walkArt = WalkArt(
      widget.pet,
      {for (final path in paths) path: _images[path]!.image},
      widget.outfit['body'],
      clothes,
      widget.outfit['head'],
      paintedScarf: _foxScarf,
    );
  }

  void _disposeTextures() {
    mesh?.shader.dispose();
    mesh = null;
    leftMesh?.shader.dispose();
    leftMesh = null;
    leapMesh?.shader.dispose();
    leapMesh = null;
    leftLeapMesh?.shader.dispose();
    leftLeapMesh = null;
    tuckMesh?.shader.dispose();
    tuckMesh = null;
    landingMesh?.shader.dispose();
    landingMesh = null;
    _dressed?.dispose();
    _dressed = null;
    _leftDressed?.dispose();
    _leftDressed = null;
    _leapDressed?.dispose();
    _leapDressed = null;
    _leftLeapDressed?.dispose();
    _leftLeapDressed = null;
    _cloudHop?.dispose();
    _cloudHop = null;
    _cloudHopRear?.dispose();
    _cloudHopRear = null;
  }

  Map<String, ({String path, bool registered})> _layers(AccessoryPose pose) {
    final art = <String, ({String path, bool registered})>{};
    // The map vest shares the original character canvas. The stock coat has
    // a larger flight canvas and its registered layers are shifted to match.
    final garment = _coat == FittedCoat.mapVest ? null : widget.outfit['body'];
    for (final entry in _accessories) {
      final fitted = registeredAccessory(
        entry.value,
        widget.pet,
        widget.stage,
        pose,
        garment,
      );
      if (fitted != null) {
        art[entry.key] = (path: fitted, registered: true);
      } else if (pose != AccessoryPose.walkBack ||
          entry.key != 'face' ||
          widget.pet == Companion.fox) {
        art[entry.key] = (
          path: fittedAccessory(entry.value, widget.pet, airborne: pose.flying),
          registered: false,
        );
      }
    }
    return art;
  }

  void _resolve() {
    _fits = {for (final pose in _looks) pose: _layers(pose)};
    final needed = {
      _portraitPath(),
      if (_leftFits) _portraitPath(facesLeft: true),
      if (widget.actionPoses) ...[
        _leapPath(),
        if (_leftFits) _leapPath(facesLeft: true),
      ],
      if (_hasTuck) rabbitShortHopArt,
      if (_hasTuck) rabbitLandingArt,
      if (_hasCloudHop)
        for (final (pose, _, _) in [..._cloudHops, ..._cloudRearHops])
          _cloudFit(pose),
      ..._walkAssets,
      for (final view in _turnFits.keys) _turnPath(view),
      for (final layers in _fits.values)
        for (final layer in layers.values) layer.path,
    };
    final keyset = (needed.toList()..sort()).join('|');
    if (_requested == keyset) return;
    _requested = keyset;
    _disposeTextures();
    _walkArt?.dispose();
    _walkArt = null;
    _disposeTurnArt();
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
    _disposeTextures();
    _walkArt?.dispose();
    _disposeTurnArt();
    for (final info in _images.values) {
      info.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      painter: _PetPainter(
        widget,
        mesh,
        leftMesh,
        leapMesh,
        leftLeapMesh,
        tuckMesh,
        landingMesh,
        _cloudHop,
        _cloudHopRear,
        _walkArt,
        _turnArt,
      ),
    ),
  );
}

class _PetPainter extends CustomPainter {
  _PetPainter(
    this.actor,
    this.mesh,
    this.leftMesh,
    this.leapMesh,
    this.leftLeapMesh,
    this.tuckMesh,
    this.landingMesh,
    this.cloudHop,
    this.cloudHopRear,
    this.walkArt,
    this.turnArt,
  ) : super(repaint: actor.clock);
  final IllustratedPet actor;
  final _Mesh? mesh, leftMesh, leapMesh, leftLeapMesh, tuckMesh, landingMesh;
  final _CloudHopArt? cloudHop, cloudHopRear;
  final WalkArt? walkArt;
  final Map<(TurnView, bool), (_Mesh, ui.Image?)> turnArt;
  @override
  void paint(Canvas canvas, Size size) {
    final facesLeft = actor.walkFacesLeft?.call() ?? false;
    final pace = actor.still ? null : actor.hop?.call();
    final seated = facesLeft ? leftMesh ?? mesh : mesh;
    if (seated == null || size.isEmpty) return;
    final bounds = actor.walkPose == null
        ? Offset.zero & size
        : (Offset.zero & size).deflate(size.width / 6);
    final pose = actor.still ? null : actor.walkPose?.call();
    final motion = actor.still
        ? const PetMotion.rest()
        : actor.drawnMotion?.call() ??
              actor.motion?.call() ??
              const PetMotion.rest();
    if (pose != null && pose.ink > 0 && walkArt != null) {
      walkArt!.paint(canvas, bounds, pose);
      return;
    }
    final view = pose != null && pose.ink > 0 && turnArt.isNotEmpty
        ? TurnView.at(pose.yaw, actor.pet)
        : null;
    if (pose != null && view != null) {
      final mirrored = !view.axial && pose.left;
      if ((turnArt[(view, mirrored)] ?? turnArt[(view, false)]) case (
        final drawing,
        _,
      )) {
        final dest = applyBoxFit(BoxFit.contain, drawing.bodySize, bounds.size);
        final rect = Alignment.bottomCenter.inscribe(dest.destination, bounds);
        canvas.save();
        if (mirrored) {
          canvas.translate(size.width, 0);
          canvas.scale(-1, 1);
        }
        drawing.paint(
          canvas,
          rect,
          0,
          0,
          0,
          true,
          const PetMotion.rest(),
          planted: pose,
          mirrored: mirrored,
        );
        canvas.restore();
        return;
      }
    }
    final foxSkill =
        actor.pet == Companion.fox &&
        walkArt != null &&
        motion.action == PetAction.skill;
    if (foxSkill &&
        !motion.usesAirborneArt(actor.pet) &&
        (motion.progress > .13 && motion.progress < .28 ||
            motion.progress > .75 && motion.progress < .95)) {
      walkArt!.paintSkillSupport(canvas, bounds, facesLeft, motion.progress);
      return;
    }

    final hop =
        actor.pet == Companion.rabbit && motion.action == PetAction.skill
        ? rabbitSkillRecovery(motion)
        : pace;
    final leap = facesLeft ? leftLeapMesh ?? leapMesh : leapMesh;
    final groundSkill = motion.usesGroundArt(actor.pet) ? leap : null;
    final cloudCat = actor.pet == Companion.cat && actor.stage == 4;
    final back = hop?.facesAway == true;
    final cloud = back ? cloudHopRear ?? cloudHop : cloudHop;
    final flight =
        cloud?.flight.$1 ?? (pace?.airborne == true ? tuckMesh ?? leap : leap);
    final landing = hop?.forepawPose == true
        ? cloud?.landing.$1 ?? landingMesh
        : null;
    final brace = hop?.bracePose == true ? cloud?.brace.$1 : null;
    final flying =
        landing == null &&
        flight != null &&
        (pace?.airborne == true || motion.usesAirborneArt(actor.pet));
    final drawing =
        landing ?? brace ?? groundSkill ?? (flying ? flight : seated);
    final extent = flying
        ? (pace?.airborne == true || foxSkill ? 1.02 : 1.16)
        : 1.0;
    final dest = applyBoxFit(
      BoxFit.contain,
      drawing.bodySize,
      bounds.size * extent,
    ).destination;
    final planted = Alignment.bottomCenter.inscribe(dest, bounds);
    final rest = applyBoxFit(
      BoxFit.contain,
      seated.bodySize,
      bounds.size,
    ).destination;
    final recovery = hop?.recovery ?? 0;
    final height = landing == null
        ? dest.height
        : ui.lerpDouble(dest.height, rest.height * .96, recovery)!;
    // Both drawings keep the near forepaw over the same patch as the body
    // comes upright. The ears and haunch can finish after the pad touches.
    final rect = Rect.fromCenter(
      center: Offset(
        planted.center.dx +
            (landing == null
                ? 0
                : cloudCat
                ? .254 * rest.width - (back ? .313 : .30) * dest.width
                : .039 * rest.width - .205 * dest.width),
        bounds.bottom - height / 2,
      ),
      width: dest.width * height / dest.height * (hop?.width ?? 1),
      height: height,
    );
    canvas.save();
    final painted = actor.paintedWalk;
    final reverse =
        facesLeft !=
        (!flying &&
            groundSkill == null &&
            landing == null &&
            (painted?.facesLeft ?? false));
    if (reverse) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    final activePicture =
        flying || groundSkill != null || landing != null || brace != null;
    if (activePicture) {
      drawing.paintDrawing(canvas, rect, lean: (hop?.lean ?? 0) * .036);
    } else if (actor.pet.hasGroundSkill && (pose == null || pose.ink == 0)) {
      drawing.paintDrawing(canvas, rect, lean: motion.lean * .024);
    } else {
      drawing.paint(
        canvas,
        rect,
        actor.seconds(),
        actor.still ? 0 : actor.reaction(),
        actor.gaze(),
        actor.still,
        motion,
        hop: hop,
        planted: painted == null ? null : pose,
        load: painted == null ? pose?.load ?? Offset.zero : Offset.zero,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PetPainter old) => true;
}
