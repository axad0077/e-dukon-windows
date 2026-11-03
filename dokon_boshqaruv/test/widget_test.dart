// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dokon_boshqaruv/src/l10n/app_strings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dokon_boshqaruv/src/app.dart';

void main() {
  testWidgets('App boots and renders e-dukon',
      (WidgetTester tester) async {
    activeLanguage = 'uz';
    FlutterSecureStorage.setMockInitialValues({});
    await tester.pumpWidget(
      const ProviderScope(child: DokonApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Foydalanuvchi nomi'), findsOneWidget);
    final username = tester.widget<TextField>(find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.labelText == 'Foydalanuvchi nomi',
    ));
    final password = tester.widget<TextField>(find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'Parol',
    ));
    expect(username.controller?.text, isEmpty);
    expect(password.controller?.text, isEmpty);
  });
}
