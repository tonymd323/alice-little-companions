import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'illustration/wind_sound.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final mode = PlatformDispatcher.instance.defaultRouteName;
  final caption = ValueNotifier('等待设备 $mode');
  runApp(
    Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: const Color(0xff42382d),
        child: Center(
          child: ValueListenableBuilder<String>(
            valueListenable: caption,
            builder: (context, text, _) => Text(
              text,
              style: const TextStyle(color: Color(0xfffff5de), fontSize: 22),
            ),
          ),
        ),
      ),
    ),
  );
  WidgetsBinding.instance.addPostFrameCallback((_) => run(mode, caption));
}

Future<void> run(String mode, ValueNotifier<String> caption) async {
  void mark(String message) {
    caption.value = message;
    debugPrint('FOLEY_PROBE $message');
  }

  final muted = await WindSound.isMuted();
  mark('$mode initialMuted=$muted');
  if (mode == '/mute' || mode == '/unmute') {
    await WindSound.setMuted(mode == '/mute');
    mark('$mode storedMuted=${await WindSound.isMuted()}');
    return;
  }
  await WindSound.prepare();
  await Future<void>.delayed(const Duration(milliseconds: 1500));
  switch (mode) {
    case '/raw':
      // Deliberately bypass the optional Dart mute cache to exercise native mute.
      await const MethodChannel('alice/wind-sound')
          .invokeMethod('play', 'wind');
      mark('$mode directly requested wind');
    case '/stop':
      await WindSound.play(WindCue.wind);
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await WindSound.stop();
      mark('$mode stopped wind');
    case '/line':
      for (final cue in WindCue.values) {
        await WindSound.play(cue);
        mark('$mode ${cue.name}');
        await Future<void>.delayed(const Duration(milliseconds: 1700));
      }
    default:
      mark('使用 /line /mute /raw /stop 或 /unmute');
  }
  mark('$mode done');
}
