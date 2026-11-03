import 'dart:async';

/// Some scanner plugins store errors in their state instead of throwing them.
/// A completed Future alone does not prove a camera session is running.
void verifyCameraStarted({required bool running, Object? error}) {
  if (error != null) throw error;
  if (!running) {
    throw StateError('camera.start returned but controller.isRunning is false');
  }
}

abstract interface class CameraSessionPort {
  bool get isRunning;
  Future<void> start();
  Future<void> stop();
  Future<void> dispose();
}

/// One owner for start/stop/dispose, with the latest lifecycle intent winning.
/// A watchdog must not start another camera while a native start is pending.
class CameraSession {
  CameraSession(this.port, {required this.onError});
  final CameraSessionPort port;
  final void Function(Object, StackTrace) onError;
  Future<void> _tail = Future<void>.value();
  Future<void>? _closing;
  bool _desired = false;
  bool _closed = false;

  bool get wantsRunning => _desired && !_closed;

  Future<void> _queue(Future<void> Function() job) {
    _tail = _tail.then((_) async {
      try {
        await job();
      } catch (error, stack) {
        onError(error, stack);
      }
    });
    return _tail;
  }

  Future<void> resume() {
    if (_closed) return _tail;
    _desired = true;
    return _queue(_reconcile);
  }

  Future<void> pause() {
    if (_closed) return _tail;
    _desired = false;
    return _queue(_reconcile);
  }

  Future<void> _reconcile() async {
    if (_closed) return;
    if (_desired) {
      if (!port.isRunning) await port.start();
    } else if (port.isRunning) {
      await port.stop();
    }
  }

  Future<void> retry() {
    if (_closed) return _tail;
    return _queue(() async {
      if (!wantsRunning) return;
      await port.stop();
      if (wantsRunning) await port.start();
    });
  }

  Future<void> action(Future<void> Function() action) => _queue(() async {
        if (!_closed && port.isRunning) await action();
      });

  Future<void> close() {
    if (_closing != null) return _closing!;
    _closed = true;
    _desired = false;
    _closing = _queue(() async {
      try {
        await port.stop();
      } finally {
        await port.dispose();
      }
    });
    return _closing!;
  }
}
