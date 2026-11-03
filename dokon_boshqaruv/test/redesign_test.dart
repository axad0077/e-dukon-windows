import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dokon_boshqaruv/src/preferences.dart';
import 'package:dokon_boshqaruv/src/l10n/app_strings.dart';
import 'package:dokon_boshqaruv/src/l10n/catalog.dart';
import 'package:dokon_boshqaruv/src/app.dart';
import 'package:dokon_boshqaruv/src/screens/account_settings.dart';
import 'package:dokon_boshqaruv/features/pos/widgets/cart_panel.dart';
import 'package:dokon_boshqaruv/features/pos/providers/cart_provider.dart';
import 'package:dokon_boshqaruv/features/products/models/product.dart';
import 'package:dokon_boshqaruv/features/products/widgets/product_card.dart';
import 'package:dokon_boshqaruv/features/products/widgets/barcode_scanner_dialog.dart';

import 'account_settings_test.dart' show FakeAccountApi;

import 'package:dokon_boshqaruv/src/screens/admin_panel.dart';
import 'package:dokon_boshqaruv/features/reports/screens/reports_screen.dart';
import 'package:dokon_boshqaruv/features/debts/screens/debts_screen.dart';
import 'package:dokon_boshqaruv/features/products/screens/add_product_screen.dart';
import 'package:dokon_boshqaruv/features/products/screens/edit_product_screen.dart';
import 'package:dokon_boshqaruv/features/products/providers/products_provider.dart';

class FakeAdminApi extends FakeAccountApi {
  @override
  Future<Map<String, dynamic>> adminDashboard({
    String? start,
    String? end,
  }) async => {};
  @override
  Future<Map<String, dynamic>> adminUsers({
    int page = 1,
    String? q,
    bool? active,
  }) async => {'results': [], 'pages': 1, 'count': 0};
}

void main() {
  setUp(() {
    activeLanguage = 'uz';
    FlutterSecureStorage.setMockInitialValues({});
  });
  tearDown(() {
    activeLanguage = 'uz';
  });
  test('all catalog languages and placeholders match', () {
    for (final row in messages.values) {
      expect(row.keys.toSet(), {'uz', 'ru', 'en'});
      final expected = RegExp(r'\{\d+\}')
          .allMatches(row['uz']!)
          .map((m) => m[0])
          .toSet();
      for (final value in row.values) {
        expect(value, isNotEmpty);
        expect(
          RegExp(r'\{\d+\}').allMatches(value).map((m) => m[0]).toSet(),
          expected,
        );
      }
    }
    activeLanguage = 'en';
    expect(tr('m639', ['User {0} product']), 'User {0} product added to cart');
  });
  test('preferences restore without changing account or cart', () async {
    final first = ProviderContainer();
    await first.read(themeModeProvider.notifier).select(ThemeMode.dark);
    await first.read(languageProvider.notifier).select('ru');
    first.dispose();
    final next = ProviderContainer();
    next.read(themeModeProvider);
    next.read(languageProvider);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(next.read(themeModeProvider), ThemeMode.dark);
    expect(next.read(languageProvider), 'ru');
    next.dispose();
  });
  testWidgets('changing language and theme preserves typed login and cart', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const DokonApp()),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).first,
      'unchanged-user-input',
    );
    container
        .read(cartProvider.notifier)
        .addProduct(
          Product(
            id: 2,
            name: 'Unchanged product',
            sku: 'P2',
            purchasePrice: '1',
            salePrice: '2',
            stock: '5',
            unit: 'dona',
            minStock: '1',
          ),
        );
    await container.read(languageProvider.notifier).select('ru');
    await container.read(themeModeProvider.notifier).select(ThemeMode.dark);
    await tester.pumpAndSettle();
    expect(find.text('Войти'), findsOneWidget);
    expect(find.text('unchanged-user-input'), findsOneWidget);
    expect(container.read(cartProvider).single.quantity, 1);
    expect(container.read(cartProvider).single.name, 'Unchanged product');
    expect(tester.takeException(), isNull);
  });
  for (final language in ['uz', 'ru', 'en']) {
    for (final brightness in Brightness.values) {
      testWidgets(
        '$language $brightness compact login, product and cart layout',
        (tester) async {
          await initializeDateFormatting(language);
          activeLanguage = language;
          tester.view.physicalSize = const Size(360, 780);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final container = ProviderContainer();
          addTearDown(container.dispose);
          Widget shell(Widget screen) => UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              locale: Locale(language),
              supportedLocales: const [
                Locale('uz'),
                Locale('ru'),
                Locale('en'),
              ],
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              theme: buildAppTheme(brightness),
              builder: (_, child) =>
                  AppLocaleScope(language: language, child: child!),
              home: screen,
            ),
          );
          await tester.pumpWidget(shell(const Login()));
          await tester.pumpAndSettle();
          expect(find.text(tr('m217')), findsOneWidget);
          expect(tester.takeException(), isNull);
          final product = Product(
            id: 1,
            name: 'Customer product unchanged',
            sku: 'TEST-1',
            purchasePrice: '1',
            salePrice: '1.01',
            stock: '5',
            unit: 'dona',
            minStock: '1',
          );
          await tester.pumpWidget(
            shell(
              Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 240,
                    height: 360,
                    child: ProductCard(product: product, onTap: () {}),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text(product.name), findsOneWidget);
          expect(tester.takeException(), isNull);
          container.read(cartProvider.notifier).addProduct(product);
          await tester.pumpWidget(
            shell(Scaffold(body: CartPanel(onCheckout: () {}))),
          );
          await tester.pumpAndSettle();
          expect(find.text(product.name), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
      testWidgets('$language $brightness reports, debts and product forms', (
        tester,
      ) async {
        await initializeDateFormatting(language);
        activeLanguage = language;
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        Widget shell(Widget screen) => ProviderScope(
          overrides: [
            apiProvider.overrideWithValue(FakeAccountApi()),
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
            categoriesProvider.overrideWith((ref) async => []),
          ],
          child: MaterialApp(
            locale: Locale(language),
            supportedLocales: const [Locale('uz'), Locale('ru'), Locale('en')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: buildAppTheme(brightness),
            builder: (_, child) =>
                AppLocaleScope(language: language, child: child!),
            home: screen,
          ),
        );
        for (final screen in <Widget>[
          const ReportsScreen(),
          const DebtsScreen(),
          const AddProductScreen(),
          EditProductScreen(
            product: Product(
              id: 1,
              name: 'Product unchanged',
              sku: 'T-1',
              purchasePrice: '1',
              salePrice: '2',
              stock: '3',
              unit: 'dona',
              minStock: '1',
            ),
          ),
        ]) {
          await tester.pumpWidget(shell(screen));
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: screen.runtimeType.toString(),
          );
        }
      });
      testWidgets('$language $brightness admin dashboard layout', (
        tester,
      ) async {
        activeLanguage = language;
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [apiProvider.overrideWithValue(FakeAdminApi())],
            child: MaterialApp(
              locale: Locale(language),
              supportedLocales: const [
                Locale('uz'),
                Locale('ru'),
                Locale('en'),
              ],
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              theme: buildAppTheme(brightness),
              builder: (_, child) =>
                  AppLocaleScope(language: language, child: child!),
              home: const AdminPanel(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
      testWidgets('$language $brightness account and plan layout', (
        tester,
      ) async {
        activeLanguage = language;
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [apiProvider.overrideWithValue(FakeAccountApi())],
            child: MaterialApp(
              locale: Locale(language),
              supportedLocales: const [
                Locale('uz'),
                Locale('ru'),
                Locale('en'),
              ],
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              theme: buildAppTheme(brightness),
              builder: (_, child) =>
                  AppLocaleScope(language: language, child: child!),
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
        expect(find.text('inPAY orqali to‘lash'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('scanner denied permission shows a finite fallback', (
    tester,
  ) async {
    const channel = MethodChannel('flutter.baseflow.com/permissions/methods');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'requestPermissions') return <int, int>{1: 0};
          return 0;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BarcodeScannerDialog())),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(tr('m201')), findsOneWidget);
    expect(find.text(tr('m381')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
