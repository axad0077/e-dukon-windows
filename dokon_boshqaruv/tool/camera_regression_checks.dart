// Offline core tests. No Flutter engine, plugin, network or Android device used.
import 'dart:async';
import 'dart:convert';
import 'dart:io' show stdout;
import 'package:dokon_boshqaruv/src/diagnostics/app_diagnostics.dart';
import 'package:dokon_boshqaruv/src/diagnostics/camera_session.dart';

void check(bool condition, String label) {
  if (!condition) throw StateError('FAILED: $label');
}

class FakeCamera implements CameraSessionPort {
  bool running = false;
  int starts = 0, stops = 0, disposals = 0, active = 0, peak = 0;
  Completer<void>? startGate;
  bool failStart = false;
  final entered = Completer<void>();
  @override
  bool get isRunning => running;
  @override
  Future<void> start() async {
    starts++;
    active++;
    if (active > peak) peak = active;
    if (!entered.isCompleted) entered.complete();
    try {
      if (startGate != null) await startGate!.future;
      if (failStart) throw StateError('native camera failed');
      running = true;
    } finally {
      active--;
    }
  }

  @override
  Future<void> stop() async {
    stops++;
    active++;
    if (active > peak) peak = active;
    running = false;
    active--;
  }

  @override
  Future<void> dispose() async {
    disposals++;
  }
}

Future<void> main() async {
  var passed = 0;
  {
    final camera = FakeCamera();
    final errors = <Object>[];
    final session = CameraSession(camera, onError: (e, s) => errors.add(e));
    await Future.wait([session.resume(), session.resume(), session.resume()]);
    check(
      camera.starts == 1 && camera.peak == 1,
      'repeated resume must start once',
    );
    await session.close();
    check(camera.disposals == 1 && errors.isEmpty, 'clean close');
    passed++;
  }
  {
    final camera = FakeCamera()..startGate = Completer<void>();
    final session = CameraSession(camera, onError: (e, s) => throw e);
    final opening = session.resume();
    await camera.entered.future;
    final paused = session.pause();
    check(camera.stops == 0, 'stop must wait for native start');
    camera.startGate!.complete();
    await Future.wait([opening, paused]);
    check(
      !camera.running && camera.peak == 1,
      'pause during startup must end stopped',
    );
    await session.close();
    passed++;
  }
  {
    final camera = FakeCamera()..startGate = Completer<void>();
    final session = CameraSession(camera, onError: (e, s) => throw e);
    final opening = session.resume();
    await camera.entered.future;
    final closing = session.close();
    final secondClose = session.close();
    check(identical(closing, secondClose), 'close must be idempotent');
    camera.startGate!.complete();
    await Future.wait([opening, closing]);
    await session.resume();
    check(
      camera.disposals == 1 && !camera.running && camera.starts == 1,
      'close during startup must release and prohibit restart',
    );
    passed++;
  }
  {
    final camera = FakeCamera()..failStart = true;
    final errors = <Object>[];
    final session = CameraSession(camera, onError: (e, s) => errors.add(e));
    await session.resume();
    check(errors.length == 1, 'failed start must be reported');
    camera.failStart = false;
    await session.retry();
    check(
      camera.running && camera.starts == 2,
      'retry after failure must recover',
    );
    await session.close();
    passed++;
  }
  {
    final camera = FakeCamera()..startGate = Completer<void>();
    final session = CameraSession(camera, onError: (e, s) => throw e);
    final opening = session.resume();
    await camera.entered.future;
    final paused = session.pause();
    final resumed = session.resume();
    camera.startGate!.complete();
    await Future.wait([opening, paused, resumed]);
    check(
      camera.running && camera.starts == 1 && camera.peak == 1,
      'permission-dialog lifecycle burst must honor latest resumed state',
    );
    await session.close();
    passed++;
  }
  {
    final camera = FakeCamera();
    final session = CameraSession(camera, onError: (e, s) => throw e);
    await session.resume();
    await session.pause();
    var actions = 0;
    await session.action(() async {
      actions++;
    });
    check(actions == 0, 'torch action must not run while camera is stopped');
    await session.close();
    passed++;
  }
  {
    final log = AppDiagnostics(capacity: 3);
    for (var i = 0; i < 8; i++) {
      log.record('event.$i');
    }
    final report = jsonDecode(log.report()) as Map;
    final events = report['events'] as List;
    check(
      events.length == 3 && events.first['stage'] == 'event.5',
      'diagnostic ring must be bounded and retain newest events',
    );
    passed++;
  }
  {
    final log = AppDiagnostics();
    log.record(
      'camera.plugin.error',
      error: StateError('native failure'),
      stack: StackTrace.current,
      details: {
        'stage': 'camera.bind_to_lifecycle',
        'cause': 'CameraAccessException',
      },
    );
    final report = jsonDecode(log.report()) as Map;
    final event = (report['events'] as List).single as Map;
    check(
      event['stack'] != null &&
          event['error_type'] == 'StateError' &&
          (event['details'] as Map)['cause'] == 'CameraAccessException',
      'report must retain stage, native cause and stack',
    );
    passed++;
  }
  {
    final original = StateError('CameraX bind failure');
    Object? caught;
    try {
      verifyCameraStarted(running: false, error: original);
    } catch (error) {
      caught = error;
    }
    check(identical(caught, original),
        'controller-stored native failure must not become successful start');
    passed++;
  }
  {
    Object? caught;
    try {
      verifyCameraStarted(running: false);
    } catch (error) {
      caught = error;
    }
    check(caught is StateError,
        'completed native start without running state must be rejected');
    verifyCameraStarted(running: true);
    passed++;
  }
  stdout.writeln('PASS: $passed offline camera regression scenarios.');
}
