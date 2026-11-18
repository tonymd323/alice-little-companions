import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum WindCue { wind, scarf, basket, takeLeaf, seatLeaf, windowLight, footsteps }

/// Short, offline sounds for the veranda. The scene owns the timing and mute UI.
abstract final class WindSound {
  static const _channel = MethodChannel('alice/wind-sound');
  static bool _muted = false;
  static int _preferenceRevision = 0;

  static Future<void> prepare() async {
    if (!_muted) await _send<void>('prepare');
  }

  static Future<void> play(WindCue cue) async {
    if (!_muted) await _send<void>('play', cue.name);
  }

  static Future<bool> isMuted() async {
    final revision = _preferenceRevision;
    final stored = await _send<bool>('isMuted');
    if (stored != null && revision == _preferenceRevision) _muted = stored;
    return _muted;
  }

  static Future<void> setMuted(bool value) async {
    _preferenceRevision++;
    _muted = value;
    await _send<void>('setMuted', value);
  }

  static Future<void> stop() async {
    await _send<void>('stop');
  }

  static Future<T?> _send<T>(String command, [Object? argument]) async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return null;
    }
    try {
      return await _channel.invokeMethod<T>(command, argument);
    } on MissingPluginException {
      // A widget test or preview can exercise the complete scene without audio.
    } on PlatformException catch (error) {
      debugPrint('Veranda sound unavailable: ${error.code}');
    }
    return null;
  }
}
