import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dokon_boshqaruv/src/api.dart';
import 'package:dokon_boshqaruv/src/app.dart';
import 'package:dokon_boshqaruv/src/preferences.dart';
import 'package:dokon_boshqaruv/src/l10n/app_strings.dart';
import 'package:dokon_boshqaruv/src/diagnostics/app_diagnostics.dart';
import 'package:dokon_boshqaruv/features/products/models/product.dart';
import 'package:dokon_boshqaruv/features/pos/providers/cart_provider.dart';
import 'package:dokon_boshqaruv/src/screens/admin_panel.dart';
import 'package:dokon_boshqaruv/features/debts/screens/debts_screen.dart';
import 'package:dokon_boshqaruv/features/reports/screens/reports_screen.dart';

ResponseBody jsonBody(int status, Object data) =>
    ResponseBody.fromString(jsonEncode(data), status, headers: {
      Headers.contentTypeHeader: ['application/json']
    });

class AuthAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions) respond;
  final List<Map<String, Object?>> seen = [];
  AuthAdapter(this.respond);
  @override
  Future<ResponseBody> fetch(
      RequestOptions options, Stream<List<int>>? body, Future<void>? cancel) {
    seen.add({
      'path': options.uri.path,
      'method': options.method,
      'headers': Map<String, dynamic>.from(options.headers),
      'query': Map<String, dynamic>.from(options.queryParameters),
      'data': options.data
    });
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

final probeProduct = Product(
    id: 1,
    name: 'Existing cart item',
    sku: 'ONE',
    purchasePrice: '1',
    salePrice: '2',
    stock: '5',
    unit: 'dona',
    minStock: '0');

class SignedInApi extends Api {
  int restores = 0, profiles = 0;
  bool temporaryFailure = false;
  @override
  Future<bool> restore() async {
    restores++;
    if (temporaryFailure) {
      throw DioException(
          requestOptions: RequestOptions(path: 'auth/token/refresh/'),
          response: Response(
              requestOptions: RequestOptions(path: 'auth/token/refresh/'),
              statusCode: 503),
          type: DioExceptionType.badResponse);
    }
    return true;
  }

  @override
  Future<Map<String, dynamic>> me() async {
    profiles++;
    return {'id': 7, 'is_superadmin': true};
  }

  @override
  Future<Map<String, dynamic>> adminDashboard(
          {String? start, String? end}) async =>
      {};
  @override
  Future<Map<String, dynamic>> adminUsers(
          {int page = 1, String? q, bool? active}) async =>
      {'results': [], 'pages': 1, 'count': 0};
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    activeLanguage = 'uz';
    FlutterSecureStorage.setMockInitialValues({
      'access': 'access-test-secret-29',
      'refresh': 'refresh-test-secret-29',
      'ui_language_v1': 'uz'
    });
  });
  tearDown(() {
    activeLanguage = 'uz';
  });

  test('uz ru uz preserves API URL identity queue owner tokens and cart',
      () async {
    final api = Api();
    final base = api.dio.options.baseUrl;
    final adapter = AuthAdapter((options) async {
      expect(options.headers['Authorization'], 'Bearer access-test-secret-29');
      expect(options.headers.containsKey('Авторизация'), isFalse);
      if (options.path == 'me/') {
        return jsonBody(
            200, {'id': 7, 'username': 'same-owner', 'is_active': true});
      }
      if (options.path == 'subscription/status/') {
        return jsonBody(200, {
          'active': true,
          'expires_at': DateTime.now()
              .toUtc()
              .add(const Duration(days: 1))
              .toIso8601String()
        });
      }
      return jsonBody(200, []);
    });
    api.dio.httpClientAdapter = adapter;
    final container =
        ProviderContainer(overrides: [apiProvider.overrideWithValue(api)]);
    addTearDown(container.dispose);
    await api.me();
    final owner = api.sessionKey;
    final queue = container.read(queueProvider);
    container.read(cartProvider.notifier).addProduct(probeProduct);
    for (final locale in ['ru', 'uz']) {
      await container.read(languageProvider.notifier).select(locale);
      await container.read(apiProvider).products();
      await api.me();
      expect(identical(container.read(apiProvider), api), isTrue);
      expect(identical(container.read(queueProvider), queue), isTrue);
      expect(api.sessionKey, owner);
      expect(api.dio.options.baseUrl, base);
      expect(container.read(cartProvider).single.name, probeProduct.name);
      expect(await api.secure.read(key: 'access'), 'access-test-secret-29');
      expect(await api.secure.read(key: 'refresh'), 'refresh-test-secret-29');
    }
    expect(
        adapter.seen.where((x) => '${x['path']}'.contains('refresh')), isEmpty);
  });

  test('Russian 401 refresh uses canonical headers and retries once', () async {
    activeLanguage = 'ru';
    final api = Api();
    var refreshes = 0;
    api.dio.httpClientAdapter = AuthAdapter((o) async {
      if (o.path == 'auth/token/refresh/') {
        refreshes++;
        expect(o.headers.containsKey('Authorization'), isFalse);
        expect(o.data, {'refresh': 'refresh-test-secret-29'});
        return jsonBody(
            200, {'access': 'new-access', 'refresh': 'new-refresh'});
      }
      return o.headers['Authorization'] == 'Bearer new-access'
          ? jsonBody(200, [])
          : jsonBody(401, {});
    });
    expect(await api.products(), isEmpty);
    expect(refreshes, 1);
    expect(await api.secure.read(key: 'refresh'), 'new-refresh');
  });

  test(
      '401 image upload replays a fresh multipart body without translating fields',
      () async {
    activeLanguage = 'ru';
    final api = Api();
    final body = FormData.fromMap({
      'name': 'Сахар',
      'image': MultipartFile.fromBytes([1, 2, 3], filename: 'sample.jpg')
    });
    var posts = 0;
    api.dio.httpClientAdapter = AuthAdapter((o) async {
      if (o.path == 'auth/token/refresh/') {
        return jsonBody(
            200, {'access': 'multipart-fresh', 'refresh': 'multipart-next'});
      }
      posts++;
      if (posts == 1) return jsonBody(401, {});
      expect(identical(o.data, body), isFalse);
      expect((o.data as FormData).fields.single.value, 'Сахар');
      return jsonBody(201, {'id': 1});
    });
    final response = await api.dio.post('products/', data: body);
    expect(response.statusCode, 201);
    expect(posts, 2);
  });

  test(
      'parallel rejected refresh clears tokens and logs out once without deleting language',
      () async {
    final api = Api();
    final gate = Completer<ResponseBody>();
    var refreshes = 0, logouts = 0;
    api.onLogout = () => logouts++;
    api.dio.httpClientAdapter = AuthAdapter((o) async {
      if (o.path == 'auth/token/refresh/') {
        refreshes++;
        return gate.future;
      }
      return jsonBody(401, {});
    });
    Future<Object?> attempt() async {
      try {
        await api.products();
        return null;
      } catch (e) {
        return e;
      }
    }

    final first = attempt(), second = attempt();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    gate.complete(jsonBody(401, {'code': 'token_not_valid'}));
    final results = await Future.wait([first, second]);
    expect(results.every((e) => e is DioException), isTrue);
    expect(refreshes, 1);
    expect(logouts, 1);
    expect(await api.secure.read(key: 'access'), isNull);
    expect(await api.secure.read(key: 'refresh'), isNull);
    expect(await api.secure.read(key: 'ui_language_v1'), 'uz');
  });

  for (final status in [403, 429, 500, 503]) {
    test(
        'refresh HTTP $status remains distinguishable and does not erase tokens',
        () async {
      final api = Api();
      var logouts = 0;
      api.onLogout = () => logouts++;
      api.dio.httpClientAdapter = AuthAdapter((o) async =>
          jsonBody(o.path == 'auth/token/refresh/' ? status : 401, {}));
      DioException? caught;
      try {
        await api.products();
      } on DioException catch (e) {
        caught = e;
      }
      expect(caught?.response?.statusCode, status);
      expect(logouts, 0);
      expect(await api.secure.read(key: 'refresh'), 'refresh-test-secret-29');
      expect(friendlyFailure(caught), isNot(tr('m452')));
    });
  }

  test(
      'refresh timeout keeps account and is not mislabeled as invalid credentials',
      () async {
    final api = Api();
    api.dio.httpClientAdapter = AuthAdapter((o) async {
      if (o.path == 'auth/token/refresh/') {
        throw DioException(
            requestOptions: o, type: DioExceptionType.receiveTimeout);
      }
      return jsonBody(401, {});
    });
    DioException? caught;
    try {
      await api.products();
    } on DioException catch (e) {
      caught = e;
    }
    expect(caught?.type, DioExceptionType.receiveTimeout);
    expect(friendlyFailure(caught), tr('requestTimeout'));
    expect(await api.secure.read(key: 'refresh'), 'refresh-test-secret-29');
  });

  test(
      'late old-token 401 reuses the current access token without a second rotation',
      () async {
    final api = Api();
    final late = Completer<ResponseBody>();
    var oldGets = 0, refreshes = 0;
    api.dio.httpClientAdapter = AuthAdapter((o) async {
      if (o.path == 'auth/token/refresh/') {
        refreshes++;
        return jsonBody(200, {'access': 'fresh', 'refresh': 'rotated'});
      }
      if (o.headers['Authorization'] == 'Bearer fresh') {
        return jsonBody(200, []);
      }
      oldGets++;
      return oldGets == 2 ? late.future : jsonBody(401, {});
    });
    final first = api.products(), second = api.products();
    await first;
    late.complete(jsonBody(401, {}));
    await second;
    expect(refreshes, 1);
  });

  test(
      'a refresh response arriving after explicit logout cannot restore tokens',
      () async {
    final api = Api();
    final gate = Completer<ResponseBody>();
    final started = Completer<void>();
    api.dio.httpClientAdapter = AuthAdapter((o) async {
      if (o.path == 'auth/token/refresh/') {
        started.complete();
        return gate.future;
      }
      if (o.path == 'auth/logout/') return ResponseBody.fromString('', 204);
      return jsonBody(401, {});
    });
    final attempt = api
        .products()
        .then<Object?>((value) => value, onError: (Object e) => e);
    await started.future;
    await api.logout();
    gate.complete(jsonBody(
        200, {'access': 'must-not-store', 'refresh': 'must-not-store'}));
    await attempt;
    expect(await api.secure.read(key: 'access'), isNull);
    expect(await api.secure.read(key: 'refresh'), isNull);
  });

  test('cold restore transient failure retains tokens and exposes actual error',
      () async {
    final api = Api();
    api.dio.httpClientAdapter = AuthAdapter((o) async => jsonBody(503, {}));
    await expectLater(
        api.restore(),
        throwsA(isA<DioException>()
            .having((e) => e.response?.statusCode, 'HTTP', 503)));
    expect(await api.secure.read(key: 'refresh'), 'refresh-test-secret-29');
  });

  test('API diagnostics contain status and kind but no bearer or refresh token',
      () async {
    final api = Api();
    api.dio.httpClientAdapter = AuthAdapter((o) async => jsonBody(503, {}));
    try {
      await api.products();
    } catch (_) {}
    final report = AppDiagnostics.instance.report();
    expect(report, contains('api.failure'));
    expect(report, contains('503'));
    expect(report, isNot(contains('access-test-secret-29')));
    expect(report, isNot(contains('refresh-test-secret-29')));
  });

  test(
      'error categories remain localized and unit labels never replace protocol IDs',
      () {
    for (final language in ['uz', 'ru', 'en']) {
      activeLanguage = language;
      final values = <String>{};
      for (final type in [
        DioExceptionType.connectionError,
        DioExceptionType.receiveTimeout,
        DioExceptionType.cancel,
        DioExceptionType.badCertificate,
        DioExceptionType.unknown
      ]) {
        values.add(friendlyFailure(DioException(
            requestOptions: RequestOptions(path: 'products/'), type: type)));
      }
      expect(values.length, 5);
      expect(unitLabel('dona'), isNotEmpty);
      final product = Product.fromJson({
        'id': 1,
        'name': 'Existing',
        'sku': '1',
        'unit': 'dona',
        'sale_price': '2'
      });
      expect(product.unit, 'dona');
    }
  });

  test('forced logout clears the in-memory cart across account boundaries', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(sessionGuardProvider);
    final api = container.read(apiProvider);
    container.read(cartProvider.notifier).addProduct(probeProduct);
    api.onLogout!();
    expect(container.read(cartProvider), isEmpty);
  });

  test('session invalidation discards a previously loaded debt result',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(sessionGuardProvider);
    final api = container.read(apiProvider);
    var party = 'First account fixture';
    api.dio.httpClientAdapter = AuthAdapter((o) async => jsonBody(200, [
          {'id': 1, 'party_name': party}
        ]));
    final provider = debtsProvider(jsonEncode(['', '', '', '', '', '', '']));
    final subscription = container.listen(provider, (previous, next) {});
    addTearDown(subscription.close);
    expect((await container.read(provider.future)).single['party_name'], party);
    party = 'Next account fixture';
    api.onLogout!();
    expect((await container.read(provider.future)).single['party_name'], party);
  });

  test('debt search with a separator remains one JSON query value', () async {
    final api = _DebtApi();
    final container =
        ProviderContainer(overrides: [apiProvider.overrideWithValue(api)]);
    addTearDown(container.dispose);
    final key = jsonEncode(
        ['customer', 'Иван | Ali', 'open', '', '', '2026-10-01', '2026-10-29']);
    await container.read(debtsProvider(key).future);
    expect(api.search, 'Иван | Ali');
    expect(api.start, '2026-10-01');
  });

  testWidgets(
      'expired session on active reports navigates once without refresh loop',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final api = container.read(apiProvider);
    var expired = false, refreshes = 0;
    api.dio.httpClientAdapter = AuthAdapter((o) async {
      if (o.path == 'auth/token/refresh/') {
        refreshes++;
        return expired
            ? jsonBody(401, {})
            : jsonBody(200,
                {'access': 'session-access', 'refresh': 'session-refresh'});
      }
      if (expired) return jsonBody(401, {});
      if (o.path == 'me/') {
        return jsonBody(200, {'id': 7, 'is_superadmin': true});
      }
      if (o.path == 'admin/users/') {
        return jsonBody(200, {'results': [], 'pages': 1, 'count': 0});
      }
      if (o.path == 'sales/') return jsonBody(200, []);
      if (o.path == 'reports/summary/') {
        return jsonBody(
            200, {'revenue': 0, 'sales_count': 0, 'cash': 0, 'card': 0});
      }
      return jsonBody(200, {});
    });
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container, child: const DokonApp()));
    await tester.pumpAndSettle();
    expect(find.byType(AdminPanel), findsOneWidget);
    appNavigatorKey.currentState!
        .push(MaterialPageRoute<void>(builder: (_) => const ReportsScreen()));
    await tester.pumpAndSettle();
    container.read(cartProvider.notifier).addProduct(probeProduct);
    expired = true;
    await tester.tap(find.byTooltip(tr('m595')));
    await tester.pumpAndSettle();
    expect(find.byType(Login), findsOneWidget);
    expect(container.read(authLogoutEpochProvider), 1);
    expect(refreshes, 2);
    expect(container.read(cartProvider), isEmpty);
    expect(await api.secure.read(key: 'refresh'), isNull);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
      'authenticated MaterialApp locale switches preserve screen API cart and startup Future',
      (tester) async {
    final api = SignedInApi();
    final container =
        ProviderContainer(overrides: [apiProvider.overrideWithValue(api)]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container, child: const DokonApp()));
    await tester.pumpAndSettle();
    container.read(cartProvider.notifier).addProduct(probeProduct);
    for (final language in ['ru', 'uz']) {
      await container.read(languageProvider.notifier).select(language);
      await tester.pumpAndSettle();
      expect(find.byType(AdminPanel), findsOneWidget);
      expect(find.byType(Login), findsNothing);
      expect(container.read(cartProvider).single.name, probeProduct.name);
      expect(identical(container.read(apiProvider), api), isTrue);
    }
    expect(api.restores, 1);
    expect(api.profiles, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
      'startup 503 shows retry while retaining tokens instead of forcing Login',
      (tester) async {
    final api = SignedInApi()..temporaryFailure = true;
    await tester.pumpWidget(ProviderScope(
        overrides: [apiProvider.overrideWithValue(api)],
        child: const DokonApp()));
    await tester.pumpAndSettle();
    expect(find.byType(Login), findsNothing);
    expect(find.text(tr('m446', [503])), findsOneWidget);
    expect(await api.secure.read(key: 'refresh'), 'refresh-test-secret-29');
    api.temporaryFailure = false;
    await tester.tap(find.widgetWithText(FilledButton, tr('m381')));
    await tester.pumpAndSettle();
    expect(find.byType(AdminPanel), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _DebtApi extends Api {
  String? search, start;
  @override
  Future<List<dynamic>> debts(
      {String? direction,
      String? search,
      String? status,
      String? due,
      String? sort,
      String? start,
      String? end}) async {
    this.search = search;
    this.start = start;
    return [];
  }
}
