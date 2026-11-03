import 'catalog.dart';
import 'dart:async';
import 'package:dio/dio.dart';

String activeLanguage = 'uz';
String tr(String key, [List<Object?> args = const []]) {
  final item = messages[key];
  var value = item?[activeLanguage] ?? item?['uz'] ?? '';
  // A single pass prevents user-entered text containing {1} from being interpreted again.
  return value.replaceAllMapped(RegExp(r'\{(\d+)\}'), (match) {
    final index = int.parse(match[1]!);
    return index < args.length ? '${args[index] ?? ''}' : '';
  });
}

/// Displays stable, localized application errors without exposing native traces.
String friendlyFailure(Object? error) {
  if (error is TimeoutException) return tr('requestTimeout');
  if (error is DioException) {
    final data = error.response?.data;
    final code =
        data is Map && data['error'] is Map ? data['error']['code'] : null;
    if (code == 'subscription_expired') return tr('m326');
    if (code == 'product_has_history') return tr('m252');
    if (code == 'invalid_credentials') return tr('m234');
    final status = error.response?.statusCode;
    if (status == null) {
      return switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          tr('requestTimeout'),
        DioExceptionType.connectionError => tr('m447'),
        DioExceptionType.badCertificate => tr('certificateError'),
        DioExceptionType.cancel => tr('requestCancelled'),
        _ => tr('requestFailed'),
      };
    }
    if (status == 401) return tr('m452');
    if (status == 403) return tr('m79');
    if (status == 404) return tr('m276');
    if (status == 429) return tr('m228');
    if (status == 400 || status == 422) return tr('m222');
    return tr('m446', [status]);
  }
  if (error is StateError) return error.message;
  return tr('m575');
}

String displayStatus(Object? value) {
  final text = value?.toString() ?? '';
  const known = {
    'active',
    'pending',
    'expired',
    'cancelled',
    'rejected',
    'approved',
    'month',
    'year'
  };
  if (known.contains(text)) return tr(text);
  if (text == 'trial') return tr('m554');
  if (text == 'manual') return tr('m47');
  return text;
}

/// Display only: never use translated labels as API unit IDs.
String unitLabel(String code) {
  const known = <String>{
    "dona",
    "kg",
    "gramm",
    "litr",
    "ml",
    "metr",
    "m²",
    "m³",
    "quti",
    "paket",
    "pachka",
    "butilka"
  };
  return known.contains(code) ? tr('unit_$code') : code;
}
