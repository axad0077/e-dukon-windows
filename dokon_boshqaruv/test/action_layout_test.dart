import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dokon_boshqaruv/src/app.dart';
import 'package:dokon_boshqaruv/src/offline.dart';
import 'package:dokon_boshqaruv/src/preferences.dart';
import 'package:dokon_boshqaruv/src/l10n/app_strings.dart';
import 'package:dokon_boshqaruv/features/products/providers/products_provider.dart';
import 'package:dokon_boshqaruv/features/products/models/product.dart';
import 'package:dokon_boshqaruv/features/products/screens/products_screen.dart';
import 'package:dokon_boshqaruv/features/products/screens/add_product_screen.dart';
import 'package:dokon_boshqaruv/features/products/screens/edit_product_screen.dart';
import 'package:dokon_boshqaruv/features/pos/screens/pos_screen.dart';
import 'package:dokon_boshqaruv/features/pos/screens/sales_history_screen.dart';
import 'package:dokon_boshqaruv/features/pos/widgets/payment_dialog.dart';
import 'package:dokon_boshqaruv/features/pos/widgets/cart_panel.dart';
import 'package:dokon_boshqaruv/features/pos/providers/cart_provider.dart';
import 'package:dokon_boshqaruv/features/reports/screens/reports_screen.dart';
import 'package:dokon_boshqaruv/features/debts/screens/debts_screen.dart';
import 'package:dokon_boshqaruv/src/screens/admin_panel.dart';
import 'package:dokon_boshqaruv/src/screens/account_settings.dart';

import 'account_settings_test.dart' show FakeAccountApi;
import 'redesign_test.dart' show FakeAdminApi;

final sample = Product(
  id: 1,
  name: 'Long product name to inspect on a small mobile screen',
  sku: 'TEST',
  salePrice: '1234567.89',
  purchasePrice: '1',
  stock: '20',
  unit: 'dona',
  minStock: '0',
);

class StaticProducts extends ProductsNotifier {
  StaticProducts() : super(FakeAccountApi(), OfflineQueue(), (_) {});
  @override
  Future<void> loadProducts({bool forceRefresh = false}) async {
    state = AsyncValue.data([sample]);
  }
}

class UiAdminApi extends FakeAdminApi {
  int planSaves = 0;
  bool enabled = true;
  @override
  Future<Map<String, dynamic>> adminStores({
    int page = 1,
    String? q,
    bool? active,
  }) async => {'results': [], 'pages': 1, 'count': 0};
  @override
  Future<List<dynamic>> adminPlans() async => [
    {
      'id': 17,
      'name': 'STANDARD long plan title',
      'price': '49000',
      'annual_price': '490000',
      'currency': 'UZS',
      'user_limit': 2,
      'product_limit': 500,
      'active': enabled,
    },
  ];
  @override
  Future<List<dynamic>> adminSubscriptions({String? status, String? q}) async =>
      [];
  @override
  Future<Map<String, dynamic>> adminPayments({
    int page = 1,
    String? status,
    String? start,
    String? end,
  }) async => {'results': [], 'pages': 1, 'count': 0};
  @override
  Future<Map<String, dynamic>> adminAudit({int page = 1, String? q}) async => {
    'results': [],
    'pages': 1,
    'count': 0,
  };
  @override
  Future<Map<String, dynamic>> adminSystemStatus() async => {
    'api': 'ok',
    'database': 'ok',
  };
  @override
  Future<Map<String, dynamic>> saveAdminPlan(
    Map<String, dynamic> data, {
    int? id,
  }) async {
    planSaves++;
    enabled = data['active'] as bool;
    return data;
  }
}

class BillingApi extends FakeAccountApi {
  @override
  Future<List<dynamic>> plans() async => [
    for (final plan in await super.plans())
      {...plan as Map<String, dynamic>, 'id': 17},
  ];
}

class BillingTransport implements HttpClientAdapter {
  RequestOptions? request;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? stream,
    Future<void>? cancel,
  ) async {
    request = options;
    return ResponseBody.fromString(
      '{}',
      201,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  for (final lang in ['uz', 'ru', 'en']) {
    testWidgets('$lang important screens fit 320px with enlarged text', (
      tester,
    ) async {
      final previousError = FlutterError.onError;
      FlutterError.onError = (details) {
        debugPrint(details.toString());
        previousError?.call(details);
      };
      addTearDown(() => FlutterError.onError = previousError);
      activeLanguage = lang;
      FlutterSecureStorage.setMockInitialValues({});
      await initializeDateFormatting(lang);
      tester.view.physicalSize = const Size(320, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final adminApi = UiAdminApi();
      final container = ProviderContainer(
        overrides: [
          apiProvider.overrideWithValue(adminApi),
          productsProvider.overrideWith((ref) => StaticProducts()),
          categoriesProvider.overrideWith((ref) async => []),
          salesHistoryProvider.overrideWith((ref) async => []),
          reportSummaryProvider.overrideWith(
            (ref) async => {
              'revenue': 0,
              'sales_count': 0,
              'cash': 0,
              'card': 0,
            },
          ),
          reportSalesProvider.overrideWith((ref) async => []),
          debtsProvider.overrideWith((ref, key) async => []),
        ],
      );
      addTearDown(container.dispose);
      Widget shell(Widget screen) => UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildAppTheme(Brightness.light),
          locale: Locale(lang),
          supportedLocales: const [Locale('uz'), Locale('ru'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(1.3)),
            child: AppLocaleScope(language: lang, child: child!),
          ),
          home: screen,
        ),
      );
      for (final screen in <Widget>[
        const Login(),
        const ProductsScreen(),
        const POSScreen(),
        const SalesHistoryScreen(),
        const ReportsScreen(),
        const DebtsScreen(),
        const AdminPanel(),
        const AccountSettings(),
        const AddProductScreen(),
        EditProductScreen(product: sample),
      ]) {
        await tester.pumpWidget(shell(screen));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: screen.runtimeType.toString(),
        );
        if (screen is AdminPanel) {
          for (final key in [
            'm563',
            'm120',
            'm501',
            'm330',
            'm550',
            'm37',
            'm521',
          ]) {
            final chip = find.widgetWithText(ChoiceChip, tr(key));
            await tester.ensureVisible(chip);
            await tester.pumpAndSettle();
            await tester.tap(chip);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: 'admin $key');
            if (key == 'm501') {
              await tester.tap(find.byType(Switch));
              await tester.pumpAndSettle();
              expect(adminApi.planSaves, 1);
              await tester.tap(find.widgetWithText(OutlinedButton, tr('m495')));
              await tester.pumpAndSettle();
              expect(find.byType(AlertDialog), findsOneWidget);
              expect(tester.takeException(), isNull, reason: 'plan edit');
              await tester.binding.handlePopRoute();
              await tester.pumpAndSettle();
            }
          }
        }
        if (screen is POSScreen) {
          await tester.tap(find.byTooltip(tr('m481')));
          await tester.pumpAndSettle();
          expect(find.byType(SalesHistoryScreen), findsOneWidget);
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
        }
        if (screen is ReportsScreen) {
          await tester.tap(find.widgetWithText(ChoiceChip, tr('m85')));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      }
      container.read(cartProvider.notifier).addProduct(sample);
      await tester.pumpWidget(
        shell(Scaffold(body: CartPanel(onCheckout: () {}))),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'cart');
      await tester.tap(find.byTooltip(tr('quantity_increase')));
      await tester.pump();
      expect(container.read(cartProvider).single.quantity, 2);
      await tester.tap(find.byTooltip(tr('quantity_decrease')));
      await tester.pump();
      expect(container.read(cartProvider).single.quantity, 1);
      await tester.pumpWidget(shell(const Scaffold(body: PaymentDialog())));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'payment');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  }
  testWidgets('plan offers only hosted inPAY payment and no manual receipt', (
    tester,
  ) async {
    activeLanguage = 'uz';
    FlutterSecureStorage.setMockInitialValues({});
    final api = BillingApi();
    final adapter = BillingTransport();
    api.dio.httpClientAdapter = adapter;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [apiProvider.overrideWithValue(api)],
        child: MaterialApp(
          theme: buildAppTheme(Brightness.light),
          home: const AccountSettings(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('inPAY orqali to‘lash'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.widgetWithText(FilledButton, 'inPAY orqali to‘lash'),
      findsOneWidget,
    );
    expect(find.text(tr('m506')), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
    expect(adapter.request, isNull);
    expect(tester.takeException(), isNull);
  });
}
