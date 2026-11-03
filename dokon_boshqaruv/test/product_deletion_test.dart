import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:dokon_boshqaruv/src/api.dart';
import 'package:dokon_boshqaruv/src/app.dart';
import 'package:dokon_boshqaruv/src/offline.dart';
import 'package:dokon_boshqaruv/src/preferences.dart';
import 'package:dokon_boshqaruv/src/l10n/app_strings.dart';
import 'package:dokon_boshqaruv/src/widgets/action_buttons.dart';
import 'package:dokon_boshqaruv/features/products/providers/products_provider.dart';
import 'package:dokon_boshqaruv/features/products/models/product.dart';
import 'package:dokon_boshqaruv/features/products/screens/product_detail_screen.dart';

Map<String, dynamic> row(int id) => {
      'id': id,
      'name': 'Product $id',
      'sku': 'P$id',
      'sale_price': '10',
      'purchase_price': '5',
      'stock': '5',
      'min_stock': '0',
      'unit': 'dona',
      'active': true
    };

class DeleteApi extends Api {
  int? deleted;
  Object? failure;
  Completer<void>? gate;
  List<dynamic> rows = [row(1), row(2)];
  @override
  Future<List<dynamic>> products({String? search}) async => rows;
  @override
  Future<void> deleteProduct(int id) async {
    deleted = id;
    if (gate != null) await gate!.future;
    if (failure != null) throw failure!;
    // Deliberately retain a stale server response to exercise tombstones.
  }

  @override
  Future<Map<String, dynamic>?> getProduct(int id) async => row(id);
}

class DeleteTransport implements HttpClientAdapter {
  RequestOptions? request;
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? stream,
      Future<void>? cancel) async {
    request = options;
    return ResponseBody.fromString('', 204);
  }

  @override
  void close({bool force = false}) {}
}

class WidgetQueue extends OfflineQueue {
  @override
  Future<int> pendingCount() async => 0;
  @override
  Future<Set<int>> removedProductIds() async => {};
  @override
  Future<void> removeConfirmedProduct(int id, {bool tombstone = true}) async {}
}

class WidgetProducts extends ProductsNotifier {
  WidgetProducts(DeleteApi api, OfflineQueue queue) : super(api, queue, (_) {});
  @override
  Future<void> loadProducts({bool forceRefresh = false}) async {
    state = AsyncValue.data([Product.fromJson(row(1))]);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  late OfflineQueue queue;
  late DeleteApi api;
  late ProductsNotifier notifier;
  setUp(() async {
    activeLanguage = 'uz';
    FlutterSecureStorage.setMockInitialValues({});
    queue = OfflineQueue(
        dbName: 'vexo-delete-test-${DateTime.now().microsecondsSinceEpoch}.db');
    api = DeleteApi();
    notifier = ProductsNotifier(api, queue, (_) {});
    await notifier.loadProducts();
  });
  tearDown(() async {
    notifier.dispose();
    final path = (await queue.db).path;
    await queue.close();
    await databaseFactory.deleteDatabase(path);
  });

  test('Api sends DELETE to the correct product URL', () async {
    final realApi = Api();
    final adapter = DeleteTransport();
    realApi.dio.httpClientAdapter = adapter;
    await realApi.deleteProduct(73);
    expect(adapter.request!.method, 'DELETE');
    expect(adapter.request!.uri.path, '/api/v1/products/73/');
    realApi.dio.close();
  });
  test('acknowledged removal survives queue close and app restart', () async {
    await notifier.deleteProduct(1);
    final dbName = queue.dbName;
    notifier.dispose();
    await queue.close();
    queue = OfflineQueue(dbName: dbName);
    notifier = ProductsNotifier(api, queue, (_) {});
    await notifier.loadProducts();
    expect(notifier.state.requireValue.map((p) => p.id), [2]);
    expect(await queue.removedProductIds(), {1});
  });
  test('acknowledged delete removes correct ID from state and durable cache',
      () async {
    await notifier.deleteProduct(1);
    expect(api.deleted, 1);
    expect(notifier.state.requireValue.map((p) => p.id), [2]);
    expect((await queue.cachedProducts()).map((p) => p['id']), [2]);
    expect(await queue.removedProductIds(), {1});
  });
  test('stale refresh and cache writes cannot resurrect an acknowledged delete',
      () async {
    await notifier.deleteProduct(1);
    await notifier.refresh();
    await queue.cacheProducts([row(1), row(2)]);
    expect(notifier.state.requireValue.map((p) => p.id), [2]);
    expect((await queue.cachedProducts()).map((p) => p['id']), [2]);
  });
  test('archiving does not permanently block a later explicit reactivation',
      () async {
    await queue.removeConfirmedProduct(1, tombstone: false);
    expect((await queue.cachedProducts()).map((p) => p['id']), [2]);
    expect(await queue.removedProductIds(), isEmpty);
    await queue.cacheProducts([row(1), row(2)]);
    expect((await queue.cachedProducts()).map((p) => p['id']), [1, 2]);
  });
  test('server failure retains product, cache and no tombstone', () async {
    api.failure = DioException(
        requestOptions: RequestOptions(path: 'products/1/'),
        response: Response(
            requestOptions: RequestOptions(path: 'products/1/'),
            statusCode: 500),
        type: DioExceptionType.badResponse);
    await expectLater(notifier.deleteProduct(1), throwsA(isA<DioException>()));
    expect(notifier.state.requireValue.length, 2);
    expect((await queue.cachedProducts()).length, 2);
    expect(await queue.removedProductIds(), isEmpty);
  });
  test('network failure does not enqueue or claim a completed deletion',
      () async {
    api.failure = DioException(
        requestOptions: RequestOptions(path: 'products/1/'),
        type: DioExceptionType.connectionError);
    await expectLater(notifier.deleteProduct(1), throwsA(isA<DioException>()));
    expect(await queue.pendingCount(), 0);
    expect(await queue.removedProductIds(), isEmpty);
    expect(notifier.state.requireValue.length, 2);
  });
  test('pending offline sales block deletion before HTTP request', () async {
    await queue.enqueueSale({
      'items': [
        {'product_id': 1, 'quantity': '1'}
      ],
      'cash': '10',
      'card': '0'
    });
    await expectLater(notifier.deleteProduct(1), throwsStateError);
    expect(api.deleted, isNull);
    expect(notifier.state.requireValue.length, 2);
  });
  test(
      'double press sends one DELETE and keeps the product until acknowledgement',
      () async {
    api.gate = Completer<void>();
    final first = notifier.deleteProduct(1);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await expectLater(notifier.deleteProduct(1), throwsStateError);
    expect(notifier.state.requireValue.length, 2);
    api.gate!.complete();
    await first;
    expect(notifier.state.requireValue.map((p) => p.id), [2]);
  });

  testWidgets('narrow action buttons wrap text and both handlers work',
      (tester) async {
    tester.view.physicalSize = const Size(320, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var cancel = 0, confirm = 0;
    await tester.pumpWidget(MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Scaffold(
            body: Padding(
                padding: const EdgeInsets.all(16),
                child: ActionButtons(children: [
                  OutlinedButton(
                      onPressed: () => cancel++,
                      child: const Text(
                          'Bekor qilish va oldingi sahifaga qaytish')),
                  FilledButton(
                      onPressed: () => confirm++,
                      child: const Text('Mahsulotni o‘chirishni tasdiqlash'))
                ])))));
    await tester.tap(find.byType(OutlinedButton));
    await tester.tap(find.byType(FilledButton));
    expect(cancel, 1);
    expect(confirm, 1);
    expect(tester.getTopLeft(find.byType(FilledButton)).dy,
        greaterThan(tester.getBottomLeft(find.byType(OutlinedButton)).dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'delete menu uses live screen context; cancel and failure keep detail',
      (tester) async {
    api.failure = DioException(
        requestOptions: RequestOptions(path: 'products/1/'),
        response: Response(
            requestOptions: RequestOptions(path: 'products/1/'),
            statusCode: 500),
        type: DioExceptionType.badResponse);
    await tester.pumpWidget(ProviderScope(
        overrides: [
          apiProvider.overrideWithValue(api),
          queueProvider.overrideWithValue(WidgetQueue()),
          productsProvider
              .overrideWith((ref) => WidgetProducts(api, WidgetQueue())),
        ],
        child: MaterialApp(
            theme: buildAppTheme(Brightness.light),
            home: const ProductDetailScreen(productId: 1))));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text(tr('m312')));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text(tr('m600')));
    await tester.pumpAndSettle();
    expect(api.deleted, isNull);
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text(tr('m312')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(tr('m156')));
    await tester.pumpAndSettle();
    expect(find.text(tr('m442')), findsOneWidget);
    expect(find.byType(ProductDetailScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('delete shows progress, then closes detail only after server ack',
      (tester) async {
    api.gate = Completer<void>();
    await tester.pumpWidget(ProviderScope(
        overrides: [
          apiProvider.overrideWithValue(api),
          queueProvider.overrideWithValue(WidgetQueue()),
          productsProvider
              .overrideWith((ref) => WidgetProducts(api, WidgetQueue())),
        ],
        child: MaterialApp(
            home: Builder(
                builder: (context) => Scaffold(
                    body: FilledButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                                builder: (_) =>
                                    const ProductDetailScreen(productId: 1))),
                        child: const Text('Open product')))))));
    await tester.tap(find.text('Open product'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text(tr('m312')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(tr('m156')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(ProductDetailScreen), findsOneWidget);
    api.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.byType(ProductDetailScreen), findsNothing);
    expect(find.text('Open product'), findsOneWidget);
    expect(api.deleted, 1);
    expect(tester.takeException(), isNull);
  });
}
