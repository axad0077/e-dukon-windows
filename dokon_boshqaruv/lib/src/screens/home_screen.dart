import '../adaptive_colors.dart';
import '../l10n/app_strings.dart';
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app.dart';
import '../screens/account_settings.dart';
import '../screens/admin_panel.dart';
import '../screens/change_password.dart';

import '../../features/products/screens/products_screen.dart';
import '../../features/products/providers/products_provider.dart' as products;
import '../../features/pos/screens/pos_screen.dart';
import '../../features/pos/providers/cart_provider.dart';
import '../../features/reports/screens/reports_screen.dart';
import '../../features/debts/screens/debts_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;
  bool _isAdmin = false;
  String? _username;

  int _pendingCount = 0;
  bool _syncing = false;
  bool _leaving = false;
  String? _syncMessage;

  Timer? _timer;
  StreamSubscription<List<ConnectivityResult>>? _connectivity;

  static List<String> get _labels => [
        tr('m255'),
        tr('sales'),
        tr('m162'),
        tr('m103'),
      ];

  static final _icons = [
    Icons.inventory_2_outlined,
    Icons.point_of_sale_outlined,
    Icons.assessment_outlined,
    Icons.menu_book_outlined,
  ];

  static final _selectedIcons = [
    Icons.inventory_2_rounded,
    Icons.point_of_sale_rounded,
    Icons.assessment_rounded,
    Icons.menu_book_rounded,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    unawaited(_loadProfile());
    unawaited(_updatePendingCount());

    _connectivity = Connectivity().onConnectivityChanged.listen(
      (results) {
        if (!mounted || _leaving) return;

        final disconnected = results.every((r) => r == ConnectivityResult.none);

        if (!disconnected) {
          unawaited(_syncNow());
        }
      },
      onError: (Object error) {
        // Ulanish kuzatuvi xatosi sotuvlarni o‘chirmaydi.
      },
    );

    _timer = Timer.periodic(
      Duration(seconds: 30),
      (_) => unawaited(_syncNow()),
    );

    unawaited(_syncNow());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_leaving) {
      unawaited(_syncNow());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopBackgroundTasks();
    super.dispose();
  }

  void _stopBackgroundTasks() {
    _timer?.cancel();
    _timer = null;

    final subscription = _connectivity;
    _connectivity = null;

    if (subscription != null) {
      unawaited(subscription.cancel());
    }
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ref.read(apiProvider).me();

      if (!mounted || _leaving) return;

      setState(() {
        _isAdmin =
            profile['is_superadmin'] == true || profile['superadmin'] == true;
        _username = profile['username']?.toString();
      });
    } catch (_) {
      // Offline profilga ruxsat bo‘lsa Api.me() uni qaytaradi.
      // Bu yerda yangi sessiya yaratilmaydi.
    }
  }

  Future<void> _updatePendingCount() async {
    try {
      final count = await ref.read(queueProvider).pendingCount();

      if (!mounted || _leaving) return;

      setState(() {
        _pendingCount = count;
      });
    } catch (_) {
      // Akkaunt almashishi vaqtida eski ekran yangilanmaydi.
    }
  }

  Future<void> _syncNow({bool manual = false}) async {
    if (!mounted || _leaving || _syncing) return;

    final api = ref.read(apiProvider);
    final owner = api.sessionKey;

    if (owner == null) return;

    setState(() => _syncing = true);

    try {
      final queue = ref.read(queueProvider);
      final result = await queue.syncOnce(api);

      if (!mounted || _leaving || api.sessionKey != owner) {
        return;
      }

      final remaining = await queue.pendingCount();
      String message;

      if (result.networkError) {
        message = tr('m451');
      } else if (result.conflicts > 0) {
        message = tr('m647', [result.conflicts]);
      } else if (result.acked > 0) {
        message = tr('m646', [result.acked]);
      } else if (remaining > 0) {
        message = tr('m645', [remaining]);
      } else {
        message = tr('m603');
      }

      // Barcha lokal sotuvlar tasdiqlangandan keyin
      // serverdagi yangi mahsulot qoldiqlarini olamiz.
      if (result.acked > 0 && remaining == 0) {
        try {
          await ref.read(products.productsProvider.notifier).refresh();
        } catch (_) {
          // Mahsulot yangilanmasligi tasdiqlangan sotuvni
          // qayta yuborishga sabab bo‘lmaydi.
          message += tr('m0');
        }
      }

      if (!mounted || _leaving || api.sessionKey != owner) {
        return;
      }

      setState(() {
        _pendingCount = remaining;
        _syncMessage = message;
      });

      if (manual) {
        _showMessage(message);
      }
    } catch (_) {
      if (mounted && !_leaving) {
        setState(() {
          _syncMessage = tr('m460');
        });

        if (manual) {
          _showMessage(_syncMessage!);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _syncing = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _logout() async {
    if (_leaving) return;

    if (_syncing) {
      _showMessage(tr('m465'));
      return;
    }

    await _updatePendingCount();
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(tr('m20')),
        content: Text(
          _pendingCount > 0 ? tr('m648', [_pendingCount]) : tr('m19'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(tr('m348')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(tr('m97')),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _leaving = true);
    _stopBackgroundTasks();

    final api = ref.read(apiProvider);
    await api.logout();

    if (!mounted) return;

    // Oldingi akkaunt savati yangi akkauntga o‘tmasin.
    ref.read(cartProvider.notifier).clear();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => Login(),
      ),
      (_) => false,
    );
  }

  Future<void> _openAccount() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AccountSettings(),
      ),
    );

    if (mounted && !_leaving) {
      unawaited(_loadProfile());
    }
  }

  void _openPassword() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangePassword(),
      ),
    );
  }

  void _handleMenu(String value) {
    switch (value) {
      case 'profile':
        unawaited(_openAccount());
        break;
      case 'password':
        _openPassword();
        break;
      case 'logout':
        unawaited(_logout());
        break;
    }
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 1:
        return POSScreen();
      case 2:
        return ReportsScreen();
      case 3:
        return DebtsScreen();
      default:
        return ProductsScreen();
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(_username ?? tr('m14')),
              subtitle: Text(
                _isAdmin ? tr('m13') : tr('m142'),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person_outline),
              title: Text(tr('m369')),
              onTap: () {
                Navigator.of(context).pop();
                unawaited(_openAccount());
              },
            ),
            ListTile(
              leading: Icon(Icons.lock_outline),
              title: Text(tr('m365')),
              onTap: () {
                Navigator.of(context).pop();
                _openPassword();
              },
            ),
            if (_isAdmin)
              ListTile(
                leading: Icon(Icons.admin_panel_settings),
                title: Text(tr('m10')),
                onTap: () {
                  Navigator.of(context).pop();

                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AdminPanel(),
                    ),
                  );
                },
              ),
            ListTile(
              leading: Icon(Icons.sync),
              title: Text(tr('m459')),
              onTap: () {
                Navigator.of(context).pop();
                unawaited(_syncNow(manual: true));
              },
            ),
            Spacer(),
            Divider(),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: adaptiveColor(context, Colors.red, foreground: true),
              ),
              title: Text(
                tr('m97'),
                style: TextStyle(
                    color:
                        adaptiveColor(context, Colors.red, foreground: true)),
              ),
              onTap: () {
                Navigator.of(context).pop();
                unawaited(_logout());
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    final mobile = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('m113')),
            if (_username != null)
              Text(
                _username!,
                style: TextStyle(fontSize: 12),
              ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenu,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'profile',
                child: Text(tr('m369')),
              ),
              PopupMenuItem(
                value: 'password',
                child: Text(tr('m365')),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Text(tr('m97')),
              ),
            ],
          ),
        ],
      ),
      drawer: mobile ? _buildDrawer() : null,
      body: Column(
        children: [
          Expanded(
            child: mobile
                ? _buildBody()
                : Row(
                    children: [
                      NavigationRail(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: (index) {
                          setState(() => _selectedIndex = index);
                          unawaited(_updatePendingCount());
                        },
                        labelType: NavigationRailLabelType.all,
                        destinations: List.generate(
                          _labels.length,
                          (index) => NavigationRailDestination(
                            icon: Icon(_icons[index]),
                            selectedIcon: Icon(_selectedIcons[index]),
                            label: Text(_labels[index]),
                          ),
                        ),
                      ),
                      VerticalDivider(width: 1),
                      Expanded(child: _buildBody()),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: mobile
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
                unawaited(_updatePendingCount());
              },
              destinations: List.generate(
                _labels.length,
                (index) => NavigationDestination(
                  icon: Icon(_icons[index]),
                  selectedIcon: Icon(_selectedIcons[index]),
                  label: _labels[index],
                ),
              ),
            )
          : null,
    );
  }
}
