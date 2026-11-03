import 'dart:convert';

/// Bounded local diagnostics. Never pass passwords, tokens, barcodes or API bodies.
class AppDiagnostics {
  AppDiagnostics({this.capacity = 80}) : assert(capacity > 0);

  static final instance = AppDiagnostics();
  final int capacity;
  final List<Map<String, Object?>> _events = [];

  void record(
    String stage, {
    String? message,
    Object? error,
    StackTrace? stack,
    Map<String, Object?>? details,
  }) {
    String limit(Object value) {
      String text;
      try {
        text = value.toString();
      } catch (_) {
        text = '<unprintable ${value.runtimeType}>';
      }
      return text.length > 6000
          ? '${text.substring(0, 6000)} [truncated]'
          : text;
    }

    _events.add({
      'time_utc': DateTime.now().toUtc().toIso8601String(),
      'stage': stage,
      if (message != null) 'message': limit(message),
      if (error != null) 'error_type': error.runtimeType.toString(),
      if (error != null) 'error': limit(error),
      if (stack != null) 'stack': limit(stack),
      if (details != null)
        'details': details.map(
          (key, value) => MapEntry(key, value == null ? null : limit(value)),
        ),
    });
    if (_events.length > capacity) _events.removeAt(0);
  }

  String report() => const JsonEncoder.withIndent('  ').convert({
        'schema': 'dokon-camera-diagnostics-v1',
        'patch': 'camera-fix-2026-10-26-v1',
        'scanner': 'mobile_scanner 7.4.2 + local native error details',
        'generated_utc': DateTime.now().toUtc().toIso8601String(),
        'events': _events,
      });
}
