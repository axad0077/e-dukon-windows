import '../features/debts/screens/debts_screen.dart' show debtsProvider;
import '../features/reports/screens/reports_screen.dart'
    show
        reportRangeProvider,
        reportPeriodProvider,
        reportSummaryProvider,
        reportSalesProvider;
import '../features/pos/screens/sales_history_screen.dart'
    show salesHistoryProvider;
import 'l10n/app_strings.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api.dart';
import 'preferences.dart';
import '../features/pos/providers/cart_provider.dart';
import 'offline.dart';
import 'screens/activate_account.dart';
import 'screens/admin_panel.dart';
import 'screens/change_password.dart';
import 'screens/home_screen.dart';

import '../features/products/providers/products_provider.dart' as products;

final appNavigatorKey = GlobalKey<NavigatorState>();

final authLogoutEpochProvider = StateProvider<int>((ref) => 0);

// A separate coordinator invalidates dependants of apiProvider. Doing this
// from apiProvider's own Ref would create a Riverpod circular dependency.
final sessionGuardProvider = Provider<void>((ref) {
  ref.listen<int>(authLogoutEpochProvider, (previous, next) {
    ref.invalidate(cartProvider);
    ref.invalidate(debtsProvider);
    ref.invalidate(reportRangeProvider);
    ref.invalidate(reportPeriodProvider);
    ref.invalidate(reportSummaryProvider);
    ref.invalidate(reportSalesProvider);
    ref.invalidate(salesHistoryProvider);
    ref.invalidate(products.productsProvider);
    ref.invalidate(products.categoriesProvider);
    ref.invalidate(products.productProvider);
    ref.invalidate(products.productsStaleProvider);
    ref.invalidate(products.productFiltersProvider);
    ref.invalidate(queueProvider);
    appNavigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => Login(),
      ),
      (_) => false,
    );
  });
});

final Provider<Api> apiProvider = Provider<Api>((ref) {
  final api = Api();

  api.onLogout = () {
    ref.read(authLogoutEpochProvider.notifier).state++;
  };

  ref.onDispose(() {
    api.onLogout = null;
  });

  return api;
});

final Provider<OfflineQueue> queueProvider = Provider<OfflineQueue>((ref) {
  final api = ref.watch(apiProvider);
  final owner = api.sessionKey;

  if (owner == null) {
    throw StateError(
      tr('m334'),
    );
  }

  return OfflineQueue(
    dbName: 'dokon_queue_$owner.db',
    ownerKey: owner,
    currentOwner: () => api.sessionKey,
  );
});

void _resetAccountProviders(WidgetRef ref) {
  ref.invalidate(cartProvider);
  ref.invalidate(debtsProvider);
  ref.invalidate(reportRangeProvider);
  ref.invalidate(reportPeriodProvider);
  ref.invalidate(reportSummaryProvider);
  ref.invalidate(reportSalesProvider);
  ref.invalidate(salesHistoryProvider);
  ref.invalidate(products.productsProvider);
  ref.invalidate(products.categoriesProvider);
  ref.invalidate(products.productProvider);
  ref.invalidate(products.productFiltersProvider);
  ref.invalidate(products.productsStaleProvider);
  ref.invalidate(queueProvider);
}

Widget _screenForProfile(Map<String, dynamic> profile) {
  final changePassword = profile['needs_password_change'] == true ||
      profile['force_password_change'] == true;

  if (changePassword) {
    return ChangePassword(isFirstTime: true);
  }

  final isAdmin =
      profile['is_superadmin'] == true || profile['superadmin'] == true;

  return isAdmin ? AdminPanel() : HomeScreen();
}

class DokonApp extends ConsumerWidget {
  const DokonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLocaleScope.of(context);
    ref.watch(sessionGuardProvider);
    final language = ref.watch(languageProvider);
    return MaterialApp(
      locale: Locale(language),
      supportedLocales: const [Locale('uz'), Locale('ru'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => AppLocaleScope(
          language: language, child: child ?? const SizedBox.shrink()),
      navigatorKey: appNavigatorKey,
      title: tr('m113'),
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: ref.watch(themeModeProvider),
      home: Startup(),
    );
  }
}

class Startup extends ConsumerStatefulWidget {
  const Startup({super.key});

  @override
  ConsumerState<Startup> createState() => _StartupState();
}

class _StartupState extends ConsumerState<Startup> {
  late Future<Map<String, dynamic>?> _startup;

  @override
  void initState() {
    super.initState();
    _startup = _restore();
  }

  Future<Map<String, dynamic>?> _restore() async {
    final api = ref.read(apiProvider);
    if (!await api.restore()) return null;
    final profile = api.sessionProfile ?? await api.me();
    if (!mounted) return null;
    _resetAccountProviders(ref);
    return profile;
  }

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    return FutureBuilder<Map<String, dynamic>?>(
      future: _startup,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(tr('m18')),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
              body: SafeArea(
                  child: Center(
                      child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text(friendlyFailure(snapshot.error),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: Text(tr('m381')),
                  onPressed: () => setState(() {
                        _startup = _restore();
                      })),
              TextButton(
                  onPressed: () async {
                    await ref.read(apiProvider).logout();
                    if (!mounted) return;
                    _resetAccountProviders(ref);
                    setState(() {
                      _startup = Future.value(null);
                    });
                  },
                  child: Text(tr('m217'))),
            ]),
          ))));
        }

        final profile = snapshot.data;

        if (profile == null) {
          return Login();
        }

        return _screenForProfile(profile);
      },
    );
  }
}

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  final user = TextEditingController();
  final pass = TextEditingController();

  bool busy = false;
  String? error;

  @override
  void dispose() {
    user.dispose();
    pass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (busy) return;

    if (user.text.trim().isEmpty || pass.text.isEmpty) {
      setState(() {
        error = tr('m233');
      });
      return;
    }

    setState(() {
      busy = true;
      error = null;
    });

    try {
      final api = ref.read(apiProvider);

      await api.login(user.text, pass.text);
      final profile = await api.me();

      if (!mounted) return;

      _resetAccountProviders(ref);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => _screenForProfile(profile),
        ),
        (_) => false,
      );
    } on DioException catch (e) {
      if (!mounted) return;

      setState(() => error = friendlyFailure(e));
    } catch (_) {
      if (!mounted) return;

      setState(() {
        error = tr('m218');
      });
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 420),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.storefront,
                      size: 64,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 16),
                    Text(
                      tr('m113'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 28),
                    TextField(
                      controller: user,
                      enabled: !busy,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      autofillHints: [
                        AutofillHints.username,
                      ],
                      decoration: InputDecoration(
                        labelText: tr('m143'),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: pass,
                      enabled: !busy,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: [
                        AutofillHints.password,
                      ],
                      onSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        labelText: tr('m356'),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (error != null)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        child: Text(
                          error!,
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    SizedBox(height: 20),
                    FilledButton(
                      onPressed: busy ? null : _login,
                      child: Text(
                        busy ? tr('m514') : tr('m217'),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextButton(
                      onPressed: busy
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => ActivateAccount(),
                                ),
                              );
                            },
                      child: Text(
                        tr('m161'),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      tr('m60'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Eski koddagi Home() chaqiruvlari bilan moslik.
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    return HomeScreen();
  }
}
