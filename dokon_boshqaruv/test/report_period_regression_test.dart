import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dokon_boshqaruv/src/app.dart';
import 'package:dokon_boshqaruv/src/api.dart';
import 'package:dokon_boshqaruv/src/preferences.dart';
import 'package:dokon_boshqaruv/src/l10n/app_strings.dart';
import 'package:dokon_boshqaruv/features/reports/widgets/report_period_chip.dart';
import 'package:dokon_boshqaruv/features/reports/screens/reports_screen.dart';
import 'localization_auth_regression_test.dart' show AuthAdapter, jsonBody;

num contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return (x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05));
}

void main() {
  setUp(() {
    activeLanguage = 'uz';
    FlutterSecureStorage.setMockInitialValues({'access': 'report-access'});
  });
  tearDown(() {
    activeLanguage = 'uz';
  });
  for (final brightness in Brightness.values) {
    for (final language in ['uz', 'ru', 'en']) {
      testWidgets(
          '$brightness $language report chips have readable enabled selected disabled and interaction states',
          (tester) async {
        activeLanguage = language;
        tester.view.physicalSize = const Size(320, 780);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final base = buildAppTheme(brightness);
        final theme = base.copyWith(
            chipTheme: base.chipTheme.copyWith(
                color: const WidgetStatePropertyAll(Colors.white),
                labelStyle: const TextStyle(color: Colors.white)));
        await tester.pumpWidget(MaterialApp(
            theme: theme,
            home: Scaffold(
                body: MediaQuery(
                    data: const MediaQueryData(
                        textScaler: TextScaler.linear(1.3)),
                    child: Wrap(children: [
                      ReportPeriodChip(
                          label: tr('m85'), selected: false, onPressed: () {}),
                      ReportPeriodChip(
                          label: tr('m6'), selected: true, onPressed: () {}),
                      ReportPeriodChip(label: tr('m421'), selected: false),
                      ReportPeriodChip(label: tr('m82'), selected: true),
                    ])))));
        await tester.pumpAndSettle();
        for (final chip
            in tester.widgetList<ChoiceChip>(find.byType(ChoiceChip))) {
          final core = <WidgetState>{
            if (chip.selected) WidgetState.selected,
            if (chip.onSelected == null) WidgetState.disabled
          };
          for (final interaction in <Set<WidgetState>>[
            {},
            {WidgetState.hovered},
            {WidgetState.pressed},
            {WidgetState.focused}
          ]) {
            final fill = chip.color!.resolve({...core, ...interaction})!;
            expect(fill.a, 1);
            expect(contrast(fill, chip.labelStyle!.color!),
                greaterThanOrEqualTo(4.5));
          }
          expect(chip.chipAnimationStyle!.selectAnimation!.duration,
              Duration.zero);
          expect(chip.surfaceTintColor, Colors.transparent);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets(
      'selection changes label and fill together on the first animation frame',
      (tester) async {
    var selected = false, calls = 0;
    await tester.pumpWidget(MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Scaffold(
            body: StatefulBuilder(
                builder: (context, setState) => ReportPeriodChip(
                    label: '7 дней',
                    selected: selected,
                    onPressed: () => setState(() {
                          selected = !selected;
                          calls++;
                        }))))));
    await tester.tap(find.byType(ChoiceChip));
    await tester.pump(const Duration(milliseconds: 1));
    final chip = tester.widget<ChoiceChip>(find.byType(ChoiceChip));
    expect(chip.selected, isTrue);
    expect(calls, 1);
    expect(
        contrast(
            chip.color!.resolve({WidgetState.selected, WidgetState.pressed})!,
            chip.labelStyle!.color!),
        greaterThanOrEqualTo(4.5));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'day week and remounted reports keep canonical query dates and selected range across locale and theme',
      (tester) async {
    final api = Api();
    final adapter = AuthAdapter((o) async {
      if (o.path == 'reports/summary/') {
        return jsonBody(
            200, {'revenue': 0, 'sales_count': 0, 'cash': 0, 'card': 0});
      }
      return jsonBody(200, []);
    });
    api.dio.httpClientAdapter = adapter;
    final container =
        ProviderContainer(overrides: [apiProvider.overrideWithValue(api)]);
    addTearDown(container.dispose);
    Widget shell() => UncontrolledProviderScope(
        container: container,
        child: Consumer(builder: (context, ref, child) {
          final language = ref.watch(languageProvider);
          final mode = ref.watch(themeModeProvider);
          return MaterialApp(
              locale: Locale(language),
              supportedLocales: const [
                Locale('uz'),
                Locale('ru'),
                Locale('en')
              ],
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              theme: buildAppTheme(Brightness.light),
              darkTheme: buildAppTheme(Brightness.dark),
              themeMode: mode,
              builder: (context, child) =>
                  AppLocaleScope(language: language, child: child!),
              home: const ReportsScreen());
        }));
    await tester.pumpWidget(shell());
    await tester.pumpAndSettle();
    for (final key in ['m85', 'm6']) {
      final chip = find.widgetWithText(ChoiceChip, tr(key));
      await tester.ensureVisible(chip);
      await tester.pumpAndSettle();
      await tester.tap(chip);
      await tester.pumpAndSettle();
    }
    expect(container.read(reportPeriodProvider), 2);
    for (final request in adapter.seen) {
      final query = request['query'] as Map;
      expect(query.keys.toSet(), {'start', 'end'});
      for (final date in query.values) {
        expect(date, matches(r'^[0-9]{4}-[0-9]{2}-[0-9]{2}$'));
      }
    }
    final lastQuery = adapter.seen.last['query'] as Map;
    final start = DateTime.parse('${lastQuery['start']}T00:00:00Z');
    final end = DateTime.parse('${lastQuery['end']}T00:00:00Z');
    expect(end.difference(start).inDays, 6);
    final before = adapter.seen.length;
    expect(
        adapter.seen
            .where((x) => '${x['path']}'.endsWith('/reports/summary/'))
            .length,
        3);
    expect(adapter.seen.where((x) => '${x['path']}'.endsWith('/sales/')).length,
        3);
    await container.read(languageProvider.notifier).select('ru');
    await container.read(themeModeProvider.notifier).select(ThemeMode.dark);
    await tester.pumpAndSettle();
    expect(adapter.seen.length, before);
    expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, tr('m6')))
            .selected,
        isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(shell());
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, tr('m6')))
            .selected,
        isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets(
      'report error view shows a localized 401 instead of a fake network failure',
      (tester) async {
    activeLanguage = 'ru';
    await tester.pumpWidget(ProviderScope(overrides: [
      reportSummaryProvider.overrideWith((ref) async => throw DioException(
          requestOptions: RequestOptions(path: 'reports/summary/'),
          response: Response(
              requestOptions: RequestOptions(path: 'reports/summary/'),
              statusCode: 401),
          type: DioExceptionType.badResponse)),
      reportSalesProvider.overrideWith((ref) async => []),
    ], child: MaterialApp(home: const ReportsScreen())));
    await tester.pumpAndSettle();
    expect(find.text(tr('m452')), findsOneWidget);
    expect(find.text(tr('m441')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
