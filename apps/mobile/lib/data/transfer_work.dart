import 'dart:isolate';

import '../domain/pin.dart';

class TransferCancelled extends UserError {
  const TransferCancelled() : super('已取消。');
}

/// Cancellation for one transfer, up to the point it publishes a result.
class TransferWork {
  bool _cancelled = false;
  bool _sealed = false;
  Isolate? _worker;

  bool get canCancel => !_cancelled && !_sealed;

  void cancel() {
    if (!canCancel) return;
    _cancelled = true;
    _worker?.kill(priority: Isolate.immediate);
  }

  void check() {
    if (_cancelled) throw const TransferCancelled();
  }

  void seal() {
    check();
    _sealed = true;
  }

  Future<T> _run<T>(Future<T> Function() task) async {
    check();
    final messages = ReceivePort();
    try {
      final response = messages.first;
      _worker = await Isolate.spawn(_runWorker<T>, (
        task,
        messages.sendPort,
      ), onExit: messages.sendPort);
      if (_cancelled) _worker!.kill(priority: Isolate.immediate);
      final result = await response;
      // When killed, wait for the exit message before removing its files.
      check();
      if (result case (final Object error, final StackTrace stack)) {
        Error.throwWithStackTrace(error, stack);
      }
      if (result case (final T value,)) return value;
      throw StateError('Backup worker exited without a result.');
    } finally {
      _worker = null;
      messages.close();
    }
  }
}

Future<T> runTransferWorker<T>(Future<T> Function() task, TransferWork? work) =>
    work == null ? Isolate.run(task) : work._run(task);

Future<void> _runWorker<T>((Future<T> Function(), SendPort) message) async {
  final (task, destination) = message;
  late final T value;
  try {
    value = await task();
  } catch (error, stack) {
    Isolate.exit(destination, (error, stack));
  }
  Isolate.exit(destination, (value,));
}
