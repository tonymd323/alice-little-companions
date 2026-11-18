import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:crypto/crypto.dart' as crypto;

abstract interface class SecureValues {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class ParentSession {
  ParentSession._(this._generation, this._until);
  final String _generation;
  final int _until;
}

class UserError implements Exception {
  const UserError(this.message);
  final String message;
  @override
  String toString() => message;
}

class PinGate {
  PinGate(
    this.values,
    this.generation, {
    required this.iterations,
    DateTime Function()? now,
    Stopwatch? clock,
  }) : _now = now ?? DateTime.now,
       _clock = clock ?? (Stopwatch()..start());

  final SecureValues values;
  final String generation;
  final int iterations;
  final DateTime Function() _now;
  final Stopwatch _clock;
  ParentSession? _session;
  bool _checking = false;
  int _lockCount = 0;

  String get _key => 'alice.pin.$generation';

  static bool correctFormat(String pin) => RegExp(r'^[0-9]{6}$').hasMatch(pin);

  static String newRecoveryCode() {
    final digits = secureBytes(16)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();
    return [
      for (var i = 0; i < digits.length; i += 4) digits.substring(i, i + 4),
    ].join('-');
  }

  Future<void> configure(String pin, String recovery) async {
    if (!correctFormat(pin)) throw const UserError('请输入 6 位数字 PIN。');
    final normalized = _normalizeRecovery(recovery);
    if (!RegExp(r'^[0-9A-F]{32}$').hasMatch(normalized)) {
      throw const UserError('恢复密钥格式不正确。');
    }
    final salt = secureBytes(16);
    final digest = await _derive(pin, salt, iterations);
    await values.write(
      _key,
      jsonEncode({
        'salt': base64Encode(salt),
        'digest': base64Encode(digest),
        'iterations': iterations,
        'recovery': _recoveryDigest(normalized),
        'failures': 0,
        'blocked_until': 0,
      }),
    );
    lock();
  }

  Future<ParentSession> unlock(String pin) => _verify(
    (record) async =>
        correctFormat(pin) &&
        _equal(
          await _derive(
            pin,
            base64Decode(record['salt'] as String),
            record['iterations'] as int,
          ),
          base64Decode(record['digest'] as String),
        ),
  );

  Future<void> reset(
    String oldRecovery,
    String newPin,
    String newRecovery,
  ) async {
    await _verify(
      (record) async => _equal(
        ascii.encode(_recoveryDigest(_normalizeRecovery(oldRecovery))),
        ascii.encode(record['recovery'] as String),
      ),
    );
    lock();
    await configure(newPin, newRecovery);
  }

  bool allows(ParentSession? session) =>
      session != null &&
      identical(session, _session) &&
      session._generation == generation &&
      _clock.elapsedMilliseconds < session._until;

  void lock() {
    _lockCount++;
    _session = null;
  }

  Future<ParentSession> _verify(
    Future<bool> Function(Map<String, dynamic>) matches,
  ) async {
    if (_checking) throw const UserError('正在验证，请稍候。');
    _checking = true;
    final lockCount = _lockCount;
    try {
      final saved = await values.read(_key);
      if (saved == null) throw const UserError('此设备缺少家长凭据。');
      final record = jsonDecode(saved) as Map<String, dynamic>;
      final now = _now().millisecondsSinceEpoch;
      final until = record['blocked_until'] as int;
      if (now < until) {
        throw UserError('请在 ${((until - now) / 1000).ceil()} 秒后重试。');
      }
      if (!await matches(record)) {
        final failures = (record['failures'] as int) + 1;
        final delay = failures < 5
            ? 0
            : min(900, 60 * (1 << min(failures - 5, 4)));
        record['failures'] = failures;
        record['blocked_until'] = _now().millisecondsSinceEpoch + delay * 1000;
        await values.write(_key, jsonEncode(record));
        throw UserError(delay == 0 ? '凭据不正确。' : '凭据不正确，请在 $delay 秒后重试。');
      }
      record['failures'] = 0;
      record['blocked_until'] = 0;
      await values.write(_key, jsonEncode(record));
      if (lockCount != _lockCount) throw const UserError('请重新验证家长身份。');
      return _session = ParentSession._(
        generation,
        _clock.elapsedMilliseconds + 600000,
      );
    } finally {
      _checking = false;
    }
  }

  static String _normalizeRecovery(String value) =>
      value.replaceAll(RegExp(r'[-\s]'), '').toUpperCase();

  static String _recoveryDigest(String value) =>
      crypto.sha256.convert(utf8.encode(value)).toString();

  static bool _equal(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var difference = 0;
    for (var i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }
    return difference == 0;
  }
}

Future<List<int>> _derive(String password, List<int> salt, int count) =>
    Isolate.run(() async {
      final key = await Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: count,
        bits: 256,
      ).deriveKeyFromPassword(password: password, nonce: salt);
      return key.extractBytes();
    });

List<int> secureBytes(int length) {
  final random = Random.secure();
  return List.generate(length, (_) => random.nextInt(256));
}
