import 'package:dokon_boshqaruv/src/api.dart';
import 'package:dokon_boshqaruv/src/app.dart';
import 'package:dokon_boshqaruv/src/screens/account_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAccountApi extends Api {
  Map<String, dynamic> profile = {
    'username': 'seller',
    'first_name': 'Ali',
    'last_name': 'Valiyev',
    'email': 'ali@example.test',
    'store': 'Mini Market',
    'store_phone': '+998900000000',
    'is_active': true,
    'is_superadmin': false,
    'date_joined': '2026-01-01T00:00:00Z',
    'subscription': {
      'active': true,
      'status': 'active',
      'plan': 'STANDARD',
      'expires_at': '2026-12-31T00:00:00Z',
    },
  };

  @override
  Future<Map<String, dynamic>> me() async => profile;

  @override
  Future<List<dynamic>> plans() async => [
        {
          'name': 'STANDARD',
          'price': '49000.00',
          'annual_price': '490000.00',
          'currency': 'UZS',
          'user_limit': 2,
          'product_limit': 500,
          'features': ['POS savdo'],
        },
      ];

  @override
  Future<List<dynamic>> payments() async => [];

  @override
  Future<List<dynamic>> subscriptionHistory() async => [];

  @override
  Future<Map<String, dynamic>> changeUsername(String username) async {
    profile = {...profile, 'username': username};
    return {'username': username};
  }
}

void main() {
  testWidgets('account settings displays backend profile and current plan',
      (tester) async {
    final api = FakeAccountApi();
    await tester.pumpWidget(ProviderScope(
      overrides: [apiProvider.overrideWithValue(api)],
      child: const MaterialApp(home: AccountSettings()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('seller'), findsOneWidget);
    expect(find.text('Mini Market'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Joriy tarif'), 250,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Joriy tarif'), findsOneWidget);
    expect(find.text('Tarifni uzaytirish'), findsOneWidget);
  });

  testWidgets('username form posts the new value and refreshes the profile',
      (tester) async {
    final api = FakeAccountApi();
    await tester.pumpWidget(ProviderScope(
      overrides: [apiProvider.overrideWithValue(api)],
      child: const MaterialApp(home: AccountSettings()),
    ));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Username'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Username'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'new-seller');
    await tester.tap(find.text('Saqlash'));
    await tester.pumpAndSettle();

    expect(api.profile['username'], 'new-seller');
    expect(find.text('new-seller'), findsOneWidget);
  });
}
