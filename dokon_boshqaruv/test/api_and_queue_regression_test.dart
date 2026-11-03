import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import 'package:dokon_boshqaruv/src/api.dart';
import 'package:dokon_boshqaruv/src/offline.dart';

class _SequenceAdapter implements HttpClientAdapter {
  final List<ResponseBody> _responses;

  _SequenceAdapter(this._responses);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (_responses.isEmpty) {
      throw StateError('No mock response configured for ${options.path}');
    }
    return _responses.removeAt(0);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(int statusCode, {Map<String, dynamic>? body}) =>
    ResponseBody.fromString(
      jsonEncode(body ?? {'ok': statusCode < 400}),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  const secureStorageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  final secureValues = <String, String>{};
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(secureStorageChannel, (call) async {
    switch (call.method) {
      case 'write':
        final key = call.arguments['key'] as String;
        final value = call.arguments['value'] as String?;
        if (value == null) {
          secureValues.remove(key);
        } else {
          secureValues[key] = value;
        }
        return null;
      case 'read':
        return secureValues[call.arguments['key'] as String];
      case 'delete':
        secureValues.remove(call.arguments['key'] as String);
        return null;
      case 'deleteAll':
        secureValues.clear();
        return null;
      default:
        return null;
    }
  });

  group('Api token refresh interceptor', () {
    test('401 refreshes token and retries the original request once', () async {
      final responses = [
        _jsonResponse(401),
        _jsonResponse(200,
            body: {'access': 'new-access', 'refresh': 'new-refresh'}),
        _jsonResponse(200),
      ];

      final api = Api();
      api.dio.httpClientAdapter = _SequenceAdapter(responses);
      await api.secure.write(key: 'access', value: 'old-access');
      await api.secure.write(key: 'refresh', value: 'old-refresh');

      final result = await api.dio.get('/secure-data/');

      expect(result.statusCode, 200);
      expect(result.data['ok'], isTrue);
      expect(await api.secure.read(key: 'access'), 'new-access');
      expect(await api.secure.read(key: 'refresh'), 'new-refresh');
    });

    test('refresh failure clears tokens and invokes logout callback', () async {
      final responses = [
        _jsonResponse(401),
        _jsonResponse(401),
      ];

      final api = Api();
      api.dio.httpClientAdapter = _SequenceAdapter(responses);
      await api.secure.write(key: 'access', value: 'old-access');
      await api.secure.write(key: 'refresh', value: 'old-refresh');
      var loggedOut = false;
      api.onLogout = () => loggedOut = true;

      await expectLater(
        api.dio.get('/secure-data/'),
        throwsA(isA<DioException>()),
      );

      expect(loggedOut, isTrue);
      expect(await api.secure.read(key: 'access'), isNull);
      expect(await api.secure.read(key: 'refresh'), isNull);
    });
  });

  group('OfflineQueue sync', () {
    test('ack flow marks operations complete', () async {
      final queue = OfflineQueue(dbName: 'test_queue_${const Uuid().v4()}.db');
      final ackId = const Uuid().v4();
      await queue.enqueueSale({'items': []}, ackId);

      final api = _FakeSyncApi({
        ackId: {'operation_id': ackId, 'status': 'ack'}
      });
      final result = await queue.syncOnce(api);

      expect(result.acked, 1);
      expect((await queue.pendingOps()).isEmpty, isTrue);
    });

    test('conflict flow keeps the failed op visible and retry requeues it',
        () async {
      final queue = OfflineQueue(dbName: 'test_queue_${const Uuid().v4()}.db');
      final conflictId = const Uuid().v4();
      await queue.enqueueSale({'items': []}, conflictId);

      final api = _FakeSyncApi({
        conflictId: {
          'operation_id': conflictId,
          'status': 'conflict',
          'message': 'Ombor yetarli emas',
        }
      });
      final result = await queue.syncOnce(api);

      expect(result.conflicts, 1);
      expect((await queue.conflictOps()).length, 1);

      await queue.retryOp(conflictId);
      expect(
          (await queue.pendingOps()).any((op) => op.id == conflictId), isTrue);
    });
  });
}

class _FakeSyncApi extends Api {
  final Map<String, Map<String, dynamic>> _responses;

  _FakeSyncApi(this._responses);

  @override
  Future<Map<String, dynamic>> syncPush(
      List<Map<String, dynamic>> operations) async {
    final results = <Map<String, dynamic>>[];
    for (final operation in operations) {
      final id = operation['operation_id'] as String;
      final response = _responses[id] ?? {'operation_id': id, 'status': 'ack'};
      results.add(response);
    }
    return {'results': results};
  }
}
