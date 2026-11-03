import 'l10n/translations.dart';
import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import 'api.dart';

enum OpStatus { pending, ack, conflict }

class OfflineOp {
  final String id;
  final Map<String, dynamic> payload;
  final OpStatus status;
  final int retries;
  final String? error;

  const OfflineOp({
    required this.id,
    required this.payload,
    required this.status,
    required this.retries,
    this.error,
  });

  factory OfflineOp.fromRow(Map<String, Object?> row) {
    return OfflineOp(
      id: row['id'] as String,
      payload: Map<String, dynamic>.from(
        jsonDecode(row['payload'] as String) as Map,
      ),
      status: switch (row['status']) {
        'ack' => OpStatus.ack,
        'conflict' => OpStatus.conflict,
        _ => OpStatus.pending,
      },
      retries: (row['retries'] as num?)?.toInt() ?? 0,
      error: row['error'] as String?,
    );
  }
}

class SyncResult {
  final int acked;
  final int conflicts;
  final bool networkError;

  const SyncResult({
    required this.acked,
    required this.conflicts,
    required this.networkError,
  });
}

class OfflineQueue {
  final String dbName;

  // App ichida ownerKey va currentOwner beriladi.
  // Testlar uchun ular ixtiyoriy qoldirilgan.
  final String? ownerKey;
  final String? Function()? currentOwner;

  Future<Database>? _opening;
  bool _syncing = false;

  OfflineQueue({
    this.dbName = 'dokon_queue.db',
    this.ownerKey,
    this.currentOwner,
  });

  void _checkOwner() {
    if (ownerKey != null && currentOwner?.call() != ownerKey) {
      throw StateError(
        tr('m17'),
      );
    }
  }

  Future<Database> get db {
    _checkOwner();
    return _opening ??= _open();
  }

  Future<Database> _open() async {
    try {
      final directory = await getDatabasesPath();
      _checkOwner();

      return await openDatabase(
        join(directory, dbName),
        version: 2,
        onCreate: (database, version) async {
          await _createTables(database);
        },
        onUpgrade: (database, oldVersion, newVersion) async {
          await _createTables(database);
        },
      );
    } catch (_) {
      _opening = null;
      rethrow;
    }
  }

  Future<void> _createTables(DatabaseExecutor database) async {
    await database.execute(
      'CREATE TABLE IF NOT EXISTS operations('
      'id TEXT PRIMARY KEY, '
      'payload TEXT NOT NULL, '
      'status TEXT NOT NULL, '
      'retries INTEGER NOT NULL DEFAULT 0, '
      'error TEXT)',
    );

    await database.execute(
      'CREATE TABLE IF NOT EXISTS cache('
      'key TEXT PRIMARY KEY, '
      'payload TEXT NOT NULL)',
    );

    await database.execute(
      'CREATE INDEX IF NOT EXISTS operations_status_idx '
      'ON operations(status)',
    );
  }

  Future<String> enqueueSale(
    Map<String, dynamic> payload, [
    String? operationId,
  ]) async {
    _checkOwner();

    final id = operationId ?? Uuid().v4();
    final encoded = jsonEncode(payload);
    final database = await db;

    await database.transaction((transaction) async {
      _checkOwner();

      final existing = await transaction.query(
        'operations',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        if (existing.first['payload'] != encoded) {
          throw StateError(
            tr('m59'),
          );
        }

        return;
      }

      await transaction.insert(
        'operations',
        {
          'id': id,
          'payload': encoded,
          'status': 'pending',
          'retries': 0,
          'error': null,
        },
      );
    });

    return id;
  }

  Future<List<OfflineOp>> pendingOps() async {
    final database = await db;

    final rows = await database.query(
      'operations',
      where: "status IN ('pending', 'conflict')",
      orderBy: 'rowid ASC',
    );

    _checkOwner();
    return rows.map(OfflineOp.fromRow).toList();
  }

  Future<int> pendingCount() async {
    final database = await db;

    final rows = await database.rawQuery(
      'SELECT COUNT(*) AS count FROM operations '
      "WHERE status IN ('pending', 'conflict')",
    );

    _checkOwner();
    return (rows.first['count'] as num?)?.toInt() ?? 0;
  }

  Future<List<OfflineOp>> conflictOps() async {
    final database = await db;

    final rows = await database.query(
      'operations',
      where: 'status = ?',
      whereArgs: ['conflict'],
      orderBy: 'rowid ASC',
    );

    _checkOwner();
    return rows.map(OfflineOp.fromRow).toList();
  }

  Future<void> retryOp(String id) async {
    if (_syncing) {
      throw StateError(
        tr('m464'),
      );
    }

    final database = await db;
    _checkOwner();

    await database.update(
      'operations',
      {'status': 'pending', 'error': null},
      where: 'id = ? AND status = ?',
      whereArgs: [id, 'conflict'],
    );
  }

  Future<void> cancelOp(String id) async {
    if (_syncing) {
      throw StateError(
        tr('m463'),
      );
    }

    final database = await db;
    _checkOwner();

    // Serverga allaqachon tasdiqlangan operatsiya o‘chirilmaydi.
    await database.delete(
      'operations',
      where: "id = ? AND status IN ('pending', 'conflict')",
      whereArgs: [id],
    );
  }

  Future<SyncResult> sync(Api api) => syncOnce(api);

  Future<SyncResult> syncOnce(Api api) async {
    _checkOwner();

    if (ownerKey != null && api.sessionKey != ownerKey) {
      throw StateError(tr('m470'));
    }

    if (_syncing) {
      return SyncResult(
        acked: 0,
        conflicts: 0,
        networkError: false,
      );
    }

    _syncing = true;

    int acked = 0;
    int conflicts = 0;
    bool networkError = false;

    try {
      final database = await db;

      // Conflict operatsiyalar foydalanuvchi qayta uringuncha
      // avtomatik yuborilmaydi.
      final rows = await database.query(
        'operations',
        where: 'status = ?',
        whereArgs: ['pending'],
        orderBy: 'rowid ASC',
        limit: 50,
      );

      final operations = rows.map(OfflineOp.fromRow).toList();

      if (operations.isEmpty) {
        return SyncResult(
          acked: 0,
          conflicts: 0,
          networkError: false,
        );
      }

      _checkOwner();

      final ids = operations.map((op) => op.id).toSet();

      try {
        final response = await api.syncPush(
          operations
              .map(
                (op) => <String, dynamic>{
                  'operation_id': op.id,
                  'type': 'sale',
                  'payload': op.payload,
                },
              )
              .toList(),
        );

        // So‘rov davomida akkaunt almashgan bo‘lsa
        // eski UI yangi akkaunt bazasini o‘zgartirmaydi.
        _checkOwner();

        final results = response['results'];

        if (results is! List) {
          throw FormatException(
            tr('m462'),
          );
        }

        final handled = <String>{};

        await database.transaction((transaction) async {
          for (final raw in results) {
            if (raw is! Map) continue;

            final id = raw['operation_id']?.toString();

            if (id == null || !ids.contains(id) || !handled.add(id)) {
              continue;
            }

            final status = raw['status']?.toString();

            if (status == 'ack') {
              await transaction.update(
                'operations',
                {'status': 'ack', 'error': null},
                where: 'id = ? AND status = ?',
                whereArgs: [id, 'pending'],
              );

              acked++;
            } else if (status == 'conflict') {
              await transaction.update(
                'operations',
                {
                  'status': 'conflict',
                  'error': raw['message']?.toString() ??
                      raw['error']?.toString() ??
                      tr('m484'),
                },
                where: 'id = ? AND status = ?',
                whereArgs: [id, 'pending'],
              );

              conflicts++;
            } else {
              await transaction.update(
                'operations',
                {
                  'error': tr('m444', [status]),
                },
                where: 'id = ? AND status = ?',
                whereArgs: [id, 'pending'],
              );
            }
          }
        });
      } catch (error) {
        _checkOwner();

        networkError = Api.isNetworkError(error);

        // Xatoda sotuv o‘chmaydi.
        // 401, 403 yoki server xatosida ham navbat saqlanadi.
        await database.transaction((transaction) async {
          for (final op in operations) {
            await transaction.rawUpdate(
              'UPDATE operations '
              'SET retries = retries + 1, error = ? '
              "WHERE id = ? AND status = 'pending'",
              [error.toString(), op.id],
            );
          }
        });
      }
    } finally {
      _syncing = false;
    }

    return SyncResult(
      acked: acked,
      conflicts: conflicts,
      networkError: networkError,
    );
  }

  /// Only call after the server acknowledged DELETE/archive. Per-account DB.
  Future<void> removeConfirmedProduct(int id, {bool tombstone = true}) async {
    final database = await db;
    _checkOwner();
    await database.transaction((tx) async {
      if (tombstone) {
        final rows = await tx.query('cache',
            where: 'key = ?', whereArgs: ['removed_product_ids']);
        final ids = rows.isEmpty
            ? <dynamic>[]
            : List<dynamic>.from(jsonDecode(rows.first['payload'] as String));
        if (!ids.contains(id)) ids.add(id);
        await tx.insert(
            'cache', {'key': 'removed_product_ids', 'payload': jsonEncode(ids)},
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      final cached =
          await tx.query('cache', where: 'key = ?', whereArgs: ['products']);
      if (cached.isNotEmpty) {
        final products =
            List<dynamic>.from(jsonDecode(cached.first['payload'] as String));
        products.removeWhere((raw) => '${raw['id']}' == '$id');
        await tx.update('cache', {'payload': jsonEncode(products)},
            where: 'key = ?', whereArgs: ['products']);
      }
      _checkOwner();
    });
  }

  Future<Set<int>> removedProductIds() async {
    final rows = await (await db)
        .query('cache', where: 'key = ?', whereArgs: ['removed_product_ids']);
    _checkOwner();
    if (rows.isEmpty) return {};
    return (jsonDecode(rows.first['payload'] as String) as List)
        .map((id) => int.parse('$id'))
        .toSet();
  }

  Future<void> cacheProducts(List<dynamic> products) async {
    final database = await db;
    _checkOwner();

    final removed = await removedProductIds();
    final visible = products
        .where((raw) =>
            raw['active'] != false &&
            !removed.contains(int.tryParse('${raw['id']}')))
        .toList();
    await database.insert(
      'cache',
      {
        'key': 'products',
        'payload': jsonEncode(visible),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<dynamic>> cachedProducts() async {
    final database = await db;

    final rows = await database.query(
      'cache',
      where: 'key = ?',
      whereArgs: ['products'],
      limit: 1,
    );

    _checkOwner();

    if (rows.isEmpty) return [];

    final removed = await removedProductIds();
    return List<dynamic>.from(
      jsonDecode(rows.first['payload'] as String) as List,
    )
        .where((raw) =>
            raw['active'] != false &&
            !removed.contains(int.tryParse('${raw['id']}')))
        .toList();
  }

  Future<void> close() async {
    if (_syncing) {
      throw StateError(tr('m461'));
    }

    final opening = _opening;
    if (opening == null) return;

    final database = await opening;
    await database.close();
    _opening = null;
  }
}

class OfflineSyncService {
  final OfflineQueue queue;
  final Api api;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _periodicTimer;
  bool _running = false;

  OfflineSyncService({
    required this.queue,
    required this.api,
  });

  void start() {
    if (_running) return;
    _running = true;

    _connectivitySub = Connectivity().onConnectivityChanged.listen(
      (results) {
        final connected = results.any(
          (result) => result != ConnectivityResult.none,
        );

        if (connected) {
          unawaited(_triggerSync());
        }
      },
      onError: (Object error) {
        // Tarmoq kuzatuvi xatosi sotuvlarni o‘chirmaydi.
      },
    );

    _periodicTimer = Timer.periodic(
      Duration(seconds: 30),
      (_) => unawaited(_triggerSync()),
    );

    unawaited(_triggerSync());
  }

  void stop() {
    _running = false;

    final subscription = _connectivitySub;
    if (subscription != null) {
      unawaited(subscription.cancel());
    }

    _connectivitySub = null;
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  Future<void> _triggerSync() async {
    if (!_running) return;

    try {
      await queue.syncOnce(api);
    } catch (_) {
      // Akkaunt almashganda yoki baza ochilmaganda
      // fon xizmati UI ni buzmaydi.
    }
  }
}
