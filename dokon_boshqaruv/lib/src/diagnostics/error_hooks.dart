import 'package:flutter/foundation.dart';
import 'app_diagnostics.dart';

bool _installed = false;

/// Keep Flutter's existing error handling; add a local, bounded report.
void installDiagnosticErrorHooks() {
  if (_installed) return;
  _installed = true;
  final flutterHandler = FlutterError.onError;
  FlutterError.onError = (details) {
    AppDiagnostics.instance.record(
      'flutter.framework.error',
      error: details.exception,
      stack: details.stack,
    );
    if (flutterHandler != null) {
      flutterHandler(details);
    } else {
      FlutterError.presentError(details);
    }
  };
  final platformHandler = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stack) {
    AppDiagnostics.instance.record(
      'flutter.unhandled.error',
      error: error,
      stack: stack,
    );
    return platformHandler?.call(error, stack) ?? false;
  };
}
