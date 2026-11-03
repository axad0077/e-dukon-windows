import '../widgets/action_buttons.dart';
import '../adaptive_colors.dart';
import '../l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../app.dart';

class AdminPanel extends ConsumerStatefulWidget {
  const AdminPanel({super.key});

  @override
  ConsumerState<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends ConsumerState<AdminPanel>
    with SingleTickerProviderStateMixin {
  int selectedTab = 0;
  List<dynamic> users = [];
  List<dynamic> sectionRows = [];
  Map<String, dynamic> dashboard = {};
  Map<String, dynamic> systemStatus = {};
  int page = 1;
  int pages = 1;
  String search = '';
  bool sectionLoading = false;
  bool dashboardLoading = false;
  String? dashboardError;
  DateTime? dashboardStart;
  DateTime? dashboardEnd;
  bool? activeFilter;
  String? paymentStatus;
  String? subscriptionStatus;
  DateTime? paymentStart;
  DateTime? paymentEnd;
  bool loading = true;
  String? error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    loadDashboard();
    loadUsers();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadUsers() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await ref
          .read(apiProvider)
          .adminUsers(page: page, q: search, active: activeFilter);
      if (mounted) {
        setState(() {
          users = result['results'] as List<dynamic>;
          pages = result['pages'] as int;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = friendlyFailure(e);
          loading = false;
        });
      }
    }
  }

  Future<void> loadDashboard() async {
    if (mounted) {
      setState(() {
        dashboardLoading = true;
        dashboardError = null;
      });
    }
    try {
      final data = await ref.read(apiProvider).adminDashboard(
          start: dashboardStart == null
              ? null
              : DateFormat('yyyy-MM-dd').format(dashboardStart!),
          end: dashboardEnd == null
              ? null
              : DateFormat('yyyy-MM-dd').format(dashboardEnd!));
      if (mounted) {
        setState(() {
          dashboard = data;
          dashboardLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          dashboardError = tr('m106');
          dashboardLoading = false;
        });
      }
    }
  }

  Future<void> loadSection(int tab) async {
    if (tab == 0 || tab == 1) return;
    setState(() {
      sectionLoading = true;
      error = null;
    });
    try {
      final api = ref.read(apiProvider);
      dynamic result;
      if (tab == 2) {
        result =
            await api.adminStores(page: page, q: search, active: activeFilter);
      }
      if (tab == 3) result = await api.adminPlans();
      if (tab == 4) {
        result =
            await api.adminSubscriptions(status: subscriptionStatus, q: search);
      }
      if (tab == 5) {
        result = await api.adminPayments(
            page: page,
            status: paymentStatus,
            start: paymentStart == null
                ? null
                : DateFormat('yyyy-MM-dd').format(paymentStart!),
            end: paymentEnd == null
                ? null
                : DateFormat('yyyy-MM-dd').format(paymentEnd!));
      }
      if (tab == 6) result = await api.adminAudit(page: page, q: search);
      if (tab == 7) result = await api.adminSystemStatus();
      if (!mounted) return;
      setState(() {
        if (tab == 7) {
          systemStatus = result as Map<String, dynamic>;
        } else if (result is Map<String, dynamic>) {
          sectionRows = result['results'] as List<dynamic>;
          pages = result['pages'] as int;
        } else {
          sectionRows = result as List<dynamic>;
        }
        sectionLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          error = friendlyFailure(e);
          sectionLoading = false;
        });
      }
    }
  }

  void selectTab(int index) {
    setState(() {
      selectedTab = index;
      page = 1;
      search = '';
    });
    if (index == 0) loadDashboard();
    if (index == 1) loadUsers();
    if (index > 1) loadSection(index);
  }

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: adaptiveColor(context, Colors.grey[50]!),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: adaptiveColor(context, Colors.white, foreground: true),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('m8'),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              isMobile ? tr('m76') : tr('m522'),
              style: TextStyle(
                  fontSize: 12,
                  color:
                      adaptiveColor(context, Colors.white70, foreground: true)),
            ),
          ],
        ),
        actions: [
          if (!isMobile)
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Center(
                child: Chip(
                  avatar: Icon(Icons.admin_panel_settings,
                      size: 18, color: adaptiveColor(context, Colors.white)),
                  label: Text(
                    tr('m489'),
                    style: TextStyle(
                        color: adaptiveColor(context, Colors.white,
                            foreground: true),
                        fontSize: 12),
                  ),
                  backgroundColor: adaptiveColor(context, Colors.orange[700]!),
                ),
              ),
            ),
          IconButton(
            icon: Icon(Icons.refresh_rounded),
            onPressed: () {
              if (selectedTab == 0) {
                loadDashboard();
              } else if (selectedTab == 1) {
                loadUsers();
              } else {
                loadSection(selectedTab);
              }
            },
            tooltip: tr('m595'),
          ),
          IconButton(
            icon: Icon(Icons.logout_rounded),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(tr('m97')),
                  content: Text(tr('m12')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(tr('m600')),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                          backgroundColor: adaptiveColor(context, Colors.red)),
                      child: Text(tr('m155')),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && mounted) {
                await ref.read(apiProvider).logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => Login()),
                    (route) => false,
                  );
                }
              }
            },
            tooltip: tr('m97'),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
      ),
      floatingActionButton: selectedTab == 1 || selectedTab == 3
          ? FloatingActionButton.extended(
              onPressed: selectedTab == 1
                  ? _showCreateUserDialog
                  : () => _showPlanDialog(),
              icon: Icon(
                  selectedTab == 1 ? Icons.person_add_rounded : Icons.add_card),
              label: Text(selectedTab == 1
                  ? (isMobile ? tr('m593') : tr('m580'))
                  : tr('m592')),
              backgroundColor: Theme.of(context).colorScheme.primary,
            )
          : null,
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: adaptiveColor(context, Colors.white),
            boxShadow: [
              BoxShadow(
                color: adaptiveColor(
                    context, Colors.black.withValues(alpha: 0.05)),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 60,
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: List.generate(8, (i) {
                final labels = [
                  tr('m105'),
                  tr('m563'),
                  tr('m120'),
                  tr('m501'),
                  tr('m330'),
                  tr('m550'),
                  tr('m37'),
                  tr('m521')
                ];
                final icons = [
                  Icons.dashboard_outlined,
                  Icons.people_outline,
                  Icons.store_outlined,
                  Icons.sell_outlined,
                  Icons.card_membership_outlined,
                  Icons.payments_outlined,
                  Icons.history,
                  Icons.monitor_heart_outlined
                ];
                return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                        avatar: Icon(icons[i], size: 18),
                        label: Text(labels[i]),
                        selected: selectedTab == i,
                        onSelected: (_) => selectTab(i)));
              }))),
        ),
        Expanded(
          child: _buildSelectedTab(),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: selectedTab,
          onDestinationSelected: selectTab,
          extended: MediaQuery.of(context).size.width > 800,
          backgroundColor: adaptiveColor(context, Colors.white),
          indicatorColor: Theme.of(context).colorScheme.primaryContainer,
          labelType: NavigationRailLabelType.none,
          destinations: [
            NavigationRailDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: Text(tr('m70')),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded),
              label: Text(tr('m563')),
            ),
            NavigationRailDestination(
                icon: Icon(Icons.store_outlined),
                selectedIcon: Icon(Icons.store),
                label: Text(tr('m120'))),
            NavigationRailDestination(
                icon: Icon(Icons.sell_outlined),
                selectedIcon: Icon(Icons.sell),
                label: Text(tr('m501'))),
            NavigationRailDestination(
                icon: Icon(Icons.card_membership_outlined),
                selectedIcon: Icon(Icons.card_membership),
                label: Text(tr('m330'))),
            NavigationRailDestination(
                icon: Icon(Icons.payments_outlined),
                selectedIcon: Icon(Icons.payments),
                label: Text(tr('m550'))),
            NavigationRailDestination(
                icon: Icon(Icons.history),
                selectedIcon: Icon(Icons.history),
                label: Text(tr('m38'))),
            NavigationRailDestination(
                icon: Icon(Icons.monitor_heart_outlined),
                selectedIcon: Icon(Icons.monitor_heart),
                label: Text(tr('m523'))),
          ],
        ),
        VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: _buildSelectedTab(),
        ),
      ],
    );
  }

  Widget _buildDashboard() {
    if (dashboardLoading && dashboard.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    if (dashboardError != null && dashboard.isEmpty) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(dashboardError!),
        FilledButton.icon(
            onPressed: loadDashboard,
            icon: Icon(Icons.refresh),
            label: Text(tr('m381')))
      ]));
    }
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ActionButtons(children: [
            OutlinedButton.icon(
                onPressed: () async {
                  final d = await showDatePicker(
                      context: context,
                      initialDate: dashboardStart ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now());
                  if (d != null) setState(() => dashboardStart = d);
                  loadDashboard();
                },
                icon: Icon(Icons.calendar_month),
                label: Text(dashboardStart == null
                    ? tr('m74')
                    : DateFormat('dd.MM.yyyy').format(dashboardStart!))),
            OutlinedButton.icon(
                onPressed: () async {
                  final d = await showDatePicker(
                      context: context,
                      initialDate: dashboardEnd ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now());
                  if (d != null) setState(() => dashboardEnd = d);
                  loadDashboard();
                },
                icon: Icon(Icons.event),
                label: Text(dashboardEnd == null
                    ? tr('m558')
                    : DateFormat('dd.MM.yyyy').format(dashboardEnd!))),
            IconButton(
                onPressed: () {
                  setState(() {
                    dashboardStart = null;
                    dashboardEnd = null;
                  });
                  loadDashboard();
                },
                icon: Icon(Icons.clear))
          ]),
          _DashboardCard(
            gradient: LinearGradient(
              colors: [Colors.blue[600]!, Colors.blue[400]!],
            ),
            icon: Icons.admin_panel_settings_rounded,
            title: tr('m9'),
            subtitle: tr('m526'),
          ),
          SizedBox(height: 16),

          // Statistics Cards
          Text(
            tr('m487'),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: isSmall
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 12) / 2,
                    child: _StatCard(
                      icon: Icons.people_rounded,
                      title: tr('m146'),
                      value: '${dashboard['users']?['total'] ?? '—'}',
                      color: adaptiveColor(context, Colors.purple),
                    ),
                  ),
                  SizedBox(
                    width: isSmall
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 12) / 2,
                    child: _StatCard(
                      icon: Icons.store_rounded,
                      title: tr('m112'),
                      value: '${dashboard['stores']?['total'] ?? '—'}',
                      color: adaptiveColor(context, Colors.green),
                    ),
                  ),
                  SizedBox(
                    width: isSmall
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 12) / 2,
                    child: _StatCard(
                      icon: Icons.verified_user_rounded,
                      title: tr('m137'),
                      value: '${dashboard['subscriptions']?['active'] ?? '—'}',
                      color: adaptiveColor(context, Colors.orange),
                    ),
                  ),
                  SizedBox(
                    width: isSmall
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 12) / 2,
                    child: _StatCard(
                      icon: Icons.person_rounded,
                      title: tr('m138'),
                      value: '${dashboard['users']?['active'] ?? '—'}',
                      color: adaptiveColor(context, Colors.blue),
                    ),
                  ),
                ],
              );
            },
          ),

          SizedBox(height: 24),

          // Quick Actions
          Text(
            tr('m518'),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),

          _QuickActionCard(
            icon: Icons.person_add_rounded,
            title: tr('m580'),
            subtitle: tr('m525'),
            onTap: () => _showCreateUserDialog(),
          ),
          SizedBox(height: 8),
          _StatCard(
              icon: Icons.block,
              title: tr('m65'),
              value: '${dashboard['users']?['blocked'] ?? '—'}',
              color: adaptiveColor(context, Colors.red)),
          SizedBox(height: 8),
          _StatCard(
              icon: Icons.store_mall_directory,
              title: tr('m133'),
              value:
                  '${dashboard['stores']?['active'] ?? '—'} / ${dashboard['stores']?['blocked'] ?? '—'}',
              color: adaptiveColor(context, Colors.indigo)),
          SizedBox(height: 8),
          _StatCard(
              icon: Icons.hourglass_bottom,
              title: tr('m555'),
              value:
                  '${dashboard['subscriptions']?['trial'] ?? '—'} / ${dashboard['subscriptions']?['expired'] ?? '—'}',
              color: adaptiveColor(context, Colors.deepOrange)),
          SizedBox(height: 8),
          _StatCard(
              icon: Icons.payments,
              title: tr('m509'),
              value: tr('m652', [
                dashboard['payments']?['approved_count'] ?? '—',
                dashboard['payments']?['approved_total'] ?? '—'
              ]),
              color: adaptiveColor(context, Colors.teal)),
          SizedBox(height: 8),
          _QuickActionCard(
            icon: Icons.people_rounded,
            title: tr('m147'),
            subtitle: tr('m51'),
            onTap: () => selectTab(1),
          ),
          SizedBox(height: 20),
          Text(tr('m486'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...((dashboard['recent_actions'] as List? ?? []).map((a) => ListTile(
              dense: true,
              leading: Icon(Icons.history),
              title: Text('${a['action']} · ${a['target']}'),
              subtitle: Text('${a['actor']} · ${a['timestamp']}')))),
        ],
      ),
    );
  }

  Widget _buildSelectedTab() {
    if (selectedTab == 0) return _buildDashboard();
    if (selectedTab == 1) return _buildUsersTab();
    return _buildAdminSection();
  }

  Widget _buildAdminSection() {
    if (sectionLoading) return Center(child: CircularProgressIndicator());
    if (error != null) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(error!, textAlign: TextAlign.center),
        SizedBox(height: 12),
        FilledButton.icon(
            onPressed: () => loadSection(selectedTab),
            icon: Icon(Icons.refresh),
            label: Text(tr('m381')))
      ]));
    }
    if (selectedTab == 7) {
      return ListView(padding: EdgeInsets.all(20), children: [
        Text(tr('m523'), style: Theme.of(context).textTheme.headlineSmall),
        SizedBox(height: 16),
        _statusTile(tr('m45'), systemStatus['api']),
        _statusTile(tr('m277'), systemStatus['database']),
        _statusTile(
            tr('m46'),
            systemStatus['backup']?['available'] == true
                ? 'mavjud'
                : systemStatus['backup']?['message'] ?? tr('m620')),
        ListTile(
            title: Text(tr('m513')),
            subtitle: Text('${systemStatus['checked_at'] ?? '—'}'))
      ]);
    }
    if (selectedTab == 3) return _buildPlans();
    if (selectedTab == 4) return _buildSubscriptions();
    return _buildAdminRows();
  }

  Widget _statusTile(String label, dynamic value) => Card(
      child: ListTile(
          leading: Icon(value == 'ok' ? Icons.check_circle : Icons.info_outline,
              color: value == 'ok' ? Colors.green : Colors.orange),
          title: Text(label),
          subtitle: Text('$value')));

  Widget _buildAdminRows() {
    final title =
        ['', '', tr('m120'), '', '', tr('m550'), tr('m38')][selectedTab];
    return Column(children: [
      Padding(
          padding: EdgeInsets.all(16),
          child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                if (selectedTab == 2 || selectedTab == 6)
                  SizedBox(
                      width: 200,
                      child: TextField(
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: tr('m387'),
                              border: OutlineInputBorder()),
                          onSubmitted: (v) {
                            search = v;
                            page = 1;
                            loadSection(selectedTab);
                          })),
                if (selectedTab == 2)
                  SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<bool?>(
                          isExpanded: true,
                          initialValue: activeFilter,
                          decoration: InputDecoration(labelText: tr('m163')),
                          items: [
                            DropdownMenuItem(
                                value: null, child: Text(tr('m53'))),
                            DropdownMenuItem(
                                value: true, child: Text(tr('m132'))),
                            DropdownMenuItem(
                                value: false, child: Text(tr('m63')))
                          ],
                          onChanged: (v) {
                            activeFilter = v;
                            page = 1;
                            loadSection(2);
                          })),
                if (selectedTab == 5)
                  SizedBox(
                      width: 170,
                      child: DropdownButtonFormField<String?>(
                          isExpanded: true,
                          initialValue: paymentStatus,
                          decoration: InputDecoration(labelText: tr('m540')),
                          items: [
                            DropdownMenuItem(
                                value: null, child: Text(tr('m53'))),
                            DropdownMenuItem(
                                value: 'pending', child: Text(tr('m231'))),
                            DropdownMenuItem(
                                value: 'approved', child: Text(tr('m508'))),
                            DropdownMenuItem(
                                value: 'failed', child: Text(tr('m297')))
                          ],
                          onChanged: (v) {
                            paymentStatus = v;
                            page = 1;
                            loadSection(5);
                          })),
                if (selectedTab == 5)
                  IconButton(
                      tooltip: tr('m74'),
                      onPressed: () async {
                        final d = await showDatePicker(
                            context: context,
                            initialDate: paymentStart ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now());
                        if (d != null) {
                          paymentStart = d;
                          page = 1;
                          loadSection(5);
                        }
                      },
                      icon: Icon(paymentStart == null
                          ? Icons.calendar_month
                          : Icons.event_available)),
                if (selectedTab == 5)
                  IconButton(
                      tooltip: tr('m558'),
                      onPressed: () async {
                        final d = await showDatePicker(
                            context: context,
                            initialDate: paymentEnd ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now());
                        if (d != null) {
                          paymentEnd = d;
                          page = 1;
                          loadSection(5);
                        }
                      },
                      icon: Icon(paymentEnd == null
                          ? Icons.event
                          : Icons.event_available))
              ])),
      Expanded(
          child: sectionRows.isEmpty
              ? Center(child: Text(tr('m276')))
              : ListView.builder(
                  itemCount: sectionRows.length,
                  itemBuilder: (context, i) {
                    final row =
                        Map<String, dynamic>.from(sectionRows[i] as Map);
                    if (selectedTab == 2) {
                      return Card(
                          child: ListTile(
                              leading: Icon(Icons.store),
                              title: Text('${row['name']}'),
                              subtitle: Text(tr('m125', [
                                row['owner'],
                                row['subscription_status'],
                                row['id'],
                                row['created_at']
                              ])),
                              isThreeLine: true,
                              onTap: () => _showStoreDetails(row),
                              trailing: Switch(
                                  value: row['is_active'] == true,
                                  onChanged: (v) => _toggleStore(row, v))));
                    }
                    if (selectedTab == 5) {
                      return Card(
                          child: ListTile(
                              leading: Icon(Icons.payments),
                              title: Text(
                                  '${row['store']} · ${row['amount']} ${row['currency'] ?? ''}'),
                              subtitle: Text(tr('m654', [
                                displayStatus(row['provider'] ?? 'manual'),
                                row['plan'],
                                displayStatus(row['billing_period'] ?? 'month'),
                                displayStatus(row['status']),
                                row['provider_transaction_id'] ?? '—',
                                row['submitted_at']
                              ])),
                              isThreeLine: true,
                              trailing: row['status'] == 'pending'
                                  ? IconButton(
                                      tooltip: tr('m511'),
                                      icon: Icon(Icons.check_circle,
                                          color: adaptiveColor(
                                              context, Colors.green,
                                              foreground: true)),
                                      onPressed: () => _approvePayment(row))
                                  : null));
                    }
                    return Card(
                        child: ListTile(
                            leading: Icon(Icons.history),
                            title: Text('${row['action']} · ${row['target']}'),
                            subtitle:
                                Text('${row['actor']} · ${row['timestamp']}'),
                            onTap: () => showDialog<void>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                        title: Text(tr('m39')),
                                        content: SelectableText(
                                            '${row['metadata']}'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              child: Text(tr('m601')))
                                        ]))));
                  })),
      if (pages > 1) _pagination()
    ]);
  }

  Widget _buildPlans() => ListView(padding: EdgeInsets.all(12), children: [
        if (sectionRows.isEmpty)
          Padding(padding: EdgeInsets.all(24), child: Text(tr('m502'))),
        ...sectionRows.map((raw) {
          final row = Map<String, dynamic>.from(raw as Map);
          return Card(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('${row['name']}',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text(tr('m650', [
                          row['price'],
                          row['currency'] ?? 'UZS',
                          row['annual_price'] ?? '—',
                          row['currency'] ?? 'UZS',
                          row['user_limit'],
                          row['product_limit'],
                          row['trial_days'] ?? 0
                        ])),
                        const SizedBox(height: 12),
                        Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Switch(
                                  value: row['active'] == true,
                                  onChanged: (v) async {
                                    try {
                                      await ref.read(apiProvider).saveAdminPlan(
                                          {...row, 'active': v},
                                          id: row['id']);
                                      await loadSection(3);
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content:
                                                    Text(friendlyFailure(e))));
                                      }
                                    }
                                  }),
                              OutlinedButton.icon(
                                  icon: const Icon(Icons.edit),
                                  label: Text(tr('m495')),
                                  onPressed: () => _showPlanDialog(plan: row))
                            ]),
                      ])));
        })
      ]);

  Widget _buildSubscriptions() =>
      ListView(padding: EdgeInsets.all(12), children: [
        DropdownButtonFormField<String?>(
          isExpanded: true,
          initialValue: subscriptionStatus,
          decoration: InputDecoration(labelText: tr('m324')),
          items: [
            DropdownMenuItem(value: null, child: Text(tr('m53'))),
            DropdownMenuItem(value: 'active', child: Text(tr('m132'))),
            DropdownMenuItem(value: 'trial', child: Text(tr('m554'))),
            DropdownMenuItem(value: 'expired', child: Text(tr('m557'))),
            DropdownMenuItem(value: 'cancelled', child: Text(tr('m56'))),
          ],
          onChanged: (value) {
            subscriptionStatus = value;
            loadSection(4);
          },
        ),
        if (sectionRows.isEmpty)
          Padding(padding: EdgeInsets.all(24), child: Text(tr('m327'))),
        ...sectionRows.map((raw) {
          final row = Map<String, dynamic>.from(raw as Map);
          return Card(
              child: ListTile(
                  leading: Icon(Icons.card_membership),
                  title:
                      Text('${row['store']} · ${displayStatus(row['status'])}'),
                  subtitle: Text(tr('m124', [
                    row['owner'],
                    row['plan'] ?? '—',
                    row['billing_period'] ?? '',
                    row['trial_end'] ?? '—',
                    row['paid_until'] ?? '—'
                  ])),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                      onSelected: (v) => _subscriptionAction(row, v),
                      itemBuilder: (_) => [
                            PopupMenuItem(
                                value: 'extend', child: Text(tr('m295'))),
                            PopupMenuItem(
                                value: 'cancel', child: Text(tr('m332')))
                          ])));
        })
      ]);

  Widget _pagination() => Padding(
      padding: EdgeInsets.all(12),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(
            onPressed: page > 1
                ? () {
                    page--;
                    if (selectedTab == 1) {
                      loadUsers();
                    } else {
                      loadSection(selectedTab);
                    }
                  }
                : null,
            icon: Icon(Icons.chevron_left)),
        Text('$page / $pages'),
        IconButton(
            onPressed: page < pages
                ? () {
                    page++;
                    if (selectedTab == 1) {
                      loadUsers();
                    } else {
                      loadSection(selectedTab);
                    }
                  }
                : null,
            icon: Icon(Icons.chevron_right))
      ]));

  bool _subscriptionBusy = false;

  Future<void> _subscriptionAction(
      Map<String, dynamic> row, String action) async {
    if (_subscriptionBusy || !mounted) return;
    if (action != 'extend' && action != 'cancel') return;
    final storeId = int.tryParse('${row['store_id']}');
    if (storeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('m115'))),
      );
      return;
    }
    _subscriptionBusy = true;
    try {
      final form = GlobalKey<FormState>();
      var months = 1;
      var reason = '';
      final accepted = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(action == 'cancel' ? tr('m332') : tr('m333')),
          content: SingleChildScrollView(
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('m119', [row['store']])),
                  SizedBox(height: 8),
                  Text(tr('m169', [row['paid_until'] ?? '—'])),
                  SizedBox(height: 12),
                  if (action == 'extend') ...[
                    TextFormField(
                      initialValue: '1',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: tr('m572'),
                        helperText: tr('m3'),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final parsed = int.tryParse(value ?? '');
                        if (parsed == null || parsed < 1 || parsed > 36) {
                          return tr('m4');
                        }
                        return null;
                      },
                      onSaved: (value) => months = int.parse(value!),
                    ),
                    SizedBox(height: 12),
                    Text(tr('m136')),
                    SizedBox(height: 12),
                  ] else ...[
                    Text(tr('m325')),
                    SizedBox(height: 12),
                  ],
                  TextFormField(
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 300,
                    decoration: InputDecoration(
                      labelText: tr('m417'),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value ?? '').trim().isEmpty ? tr('m28') : null,
                    onSaved: (value) => reason = (value ?? '').trim(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(tr('m348')),
            ),
            FilledButton(
              onPressed: () {
                if (form.currentState?.validate() != true) return;
                form.currentState!.save();
                Navigator.of(ctx).pop(<String, dynamic>{
                  'months': months,
                  'reason': reason,
                });
              },
              child: Text(tr('m511')),
            ),
          ],
        ),
      );
      if (accepted == null || !mounted) return;
      final result = await ref.read(apiProvider).adminSubscriptionAction(
            storeId,
            action,
            months: accepted['months'] as int,
            reason: accepted['reason'] as String,
          );
      if (!mounted) return;
      final expiry = DateTime.tryParse('${result['paid_until'] ?? ''}');
      final message = action == 'cancel'
          ? tr('m323')
          : tr('m328', [
              accepted['months'],
              expiry == null
                  ? ''
                  : ' Tugash sanasi: ${DateFormat('dd.MM.yyyy HH:mm').format(expiry.toLocal())}.'
            ]);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      await loadSection(4);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('m29'))),
        );
      }
    } finally {
      _subscriptionBusy = false;
    }
  }

  Future<void> _approvePayment(Map<String, dynamic> payment) async {
    final reason = TextEditingController();
    final accepted = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Text(tr('m553')),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(tr('m634', [
                    payment['store'],
                    payment['amount'],
                    payment['currency'] ?? '',
                    payment['billing_period'] ?? ''
                  ])),
                  SizedBox(height: 12),
                  TextField(
                      controller: reason,
                      decoration: InputDecoration(labelText: tr('m515'))),
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(tr('m55'))),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx, reason.text.trim()),
                      child: Text(tr('m511')))
                ]));
    if (accepted == null || accepted.isEmpty) return;
    try {
      await ref
          .read(apiProvider)
          .adminApprovePayment(payment['id'] as int, accepted);
      await loadSection(5);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(friendlyFailure(e))));
      }
    }
  }

  Future<void> _toggleStore(Map<String, dynamic> row, bool active) async {
    final reason = TextEditingController();
    final accepted = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Text(active ? tr('m122') : tr('m121')),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(tr('m633', [row['name']])),
                  if (!active)
                    TextField(
                        controller: reason,
                        decoration: InputDecoration(labelText: tr('m67')))
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(tr('m55'))),
                  FilledButton(
                      onPressed: () {
                        if (!active && reason.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(tr('m68'))));
                          return;
                        }
                        Navigator.pop(ctx, true);
                      },
                      child: Text(tr('m511')))
                ]));
    if (accepted != true) return;
    try {
      await ref
          .read(apiProvider)
          .adminStore(row['id'] as int, active, reason.text);
      await loadSection(2);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(friendlyFailure(e))));
      }
    }
  }

  void _showStoreDetails(Map<String, dynamic> store) {
    showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Text('${store['name']}'),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                          icon: Icons.tag,
                          label: 'ID',
                          value: '${store['id']}'),
                      _DetailRow(
                          icon: Icons.person,
                          label: tr('m123'),
                          value: '${store['owner']}'),
                      _DetailRow(
                          icon: Icons.calendar_month,
                          label: tr('m414'),
                          value: '${store['created_at']}'),
                      _DetailRow(
                          icon: Icons.verified_user,
                          label: tr('m163'),
                          value: store['is_active'] == true
                              ? tr('m132')
                              : tr('m63')),
                      _DetailRow(
                          icon: Icons.card_membership,
                          label: tr('m322'),
                          value: '${store['subscription_status']}'),
                      _DetailRow(
                          icon: Icons.event,
                          label: tr('m542'),
                          value: '${store['paid_until'] ?? '—'}'),
                      _DetailRow(
                          icon: Icons.people,
                          label: tr('m69'),
                          value: '${store['staff_count']}')
                    ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(tr('m601')))
                ]));
  }

  Future<void> _showPlanDialog({Map<String, dynamic>? plan}) async {
    final name = TextEditingController(text: '${plan?['name'] ?? ''}');
    final months = TextEditingController(text: '${plan?['months'] ?? 1}');
    final price = TextEditingController(text: '${plan?['price'] ?? ''}');
    final annualPrice =
        TextEditingController(text: '${plan?['annual_price'] ?? ''}');
    final userLimit =
        TextEditingController(text: '${plan?['user_limit'] ?? 2}');
    final productLimit =
        TextEditingController(text: '${plan?['product_limit'] ?? 500}');
    final trialDays =
        TextEditingController(text: '${plan?['trial_days'] ?? 0}');
    final description =
        TextEditingController(text: '${plan?['description'] ?? ''}');
    final features = TextEditingController(
        text: ((plan?['features'] as List?) ?? []).join('\n'));
    final discount =
        TextEditingController(text: '${plan?['discount_percent'] ?? 0}');
    final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Text(plan == null ? tr('m592') : tr('m503')),
                content: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: name,
                      decoration: InputDecoration(labelText: tr('m498'))),
                  TextField(
                      controller: months,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: tr('m290'))),
                  TextField(
                      controller: price,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: tr('m305'))),
                  TextField(
                      controller: annualPrice,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: tr('m599'))),
                  TextField(
                      controller: userLimit,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: tr('m562'))),
                  TextField(
                      controller: productLimit,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: tr('m135'))),
                  TextField(
                      controller: trialDays,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: tr('m556'))),
                  TextField(
                      controller: description,
                      decoration: InputDecoration(labelText: tr('m512'))),
                  TextField(
                      controller: features,
                      maxLines: 3,
                      decoration: InputDecoration(labelText: tr('m171'))),
                  TextField(
                      controller: discount,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: tr('m90')))
                ])),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(tr('m55'))),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(tr('m426')))
                ]));
    if (ok != true) return;
    final m = int.tryParse(months.text),
        users = int.tryParse(userLimit.text),
        products = int.tryParse(productLimit.text),
        trial = int.tryParse(trialDays.text),
        p = double.tryParse(price.text.replaceAll(',', '.')),
        ap = double.tryParse(annualPrice.text.replaceAll(',', '.')),
        d = double.tryParse(discount.text.replaceAll(',', '.'));
    if (name.text.trim().isEmpty ||
        m == null ||
        m < 1 ||
        p == null ||
        p < 0 ||
        ap == null ||
        ap < 0 ||
        users == null ||
        users < 1 ||
        products == null ||
        products < 1 ||
        trial == null ||
        trial < 0 ||
        d == null ||
        d < 0 ||
        d > 100) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(tr('m497'))));
      }
      return;
    }
    try {
      await ref.read(apiProvider).saveAdminPlan({
        'name': name.text.trim(),
        'months': m,
        'price': p.toStringAsFixed(2),
        'annual_price': ap.toStringAsFixed(2),
        'user_limit': users,
        'product_limit': products,
        'trial_days': trial,
        'description': description.text.trim(),
        'features': features.text
            .split('\n')
            .map((x) => x.trim())
            .where((x) => x.isNotEmpty)
            .toList(),
        if (plan?['code'] != null) 'code': plan!['code'],
        'currency': plan?['currency'] ?? 'UZS',
        'discount_percent': d.toStringAsFixed(2),
        'active': plan?['active'] ?? true
      }, id: plan?['id'] as int?);
      await loadSection(3);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(friendlyFailure(e))));
      }
    }
  }

  Widget _buildUsersTab() {
    if (loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(tr('m605')),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 64, color: adaptiveColor(context, Colors.red[300]!)),
              SizedBox(height: 16),
              Text(
                error!,
                style: TextStyle(
                    color:
                        adaptiveColor(context, Colors.red, foreground: true)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              FilledButton.icon(
                onPressed: loadUsers,
                icon: Icon(Icons.refresh_rounded),
                label: Text(tr('m381')),
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: [
      Padding(
        padding: EdgeInsets.all(12),
        child: Row(children: [
          Expanded(
              child: TextField(
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: tr('m567'),
                border: OutlineInputBorder()),
            onSubmitted: (v) {
              search = v;
              page = 1;
              loadUsers();
            },
          )),
          SizedBox(width: 8),
          SizedBox(
              width: 145,
              child: DropdownButtonFormField<bool?>(
                isExpanded: true,
                initialValue: activeFilter,
                decoration: InputDecoration(labelText: tr('m163')),
                items: [
                  DropdownMenuItem(value: null, child: Text(tr('m53'))),
                  DropdownMenuItem(value: true, child: Text(tr('m132'))),
                  DropdownMenuItem(value: false, child: Text(tr('m63')))
                ],
                onChanged: (v) {
                  activeFilter = v;
                  page = 1;
                  loadUsers();
                },
              )),
        ]),
      ),
      if (users.isEmpty)
        Expanded(child: Center(child: Text(tr('m389'))))
      else
        Expanded(
            child: ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = Map<String, dynamic>.from(users[index] as Map);
            final isSuperuser = user['is_superuser'] == true;

            return Card(
              elevation: 0,
              margin: EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showUserDetailsDialog(user),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'user_${user['id']}',
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isSuperuser
                                  ? [Colors.orange[400]!, Colors.orange[600]!]
                                  : [Colors.blue[400]!, Colors.blue[600]!],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isSuperuser ? Colors.orange : Colors.blue)
                                        .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              user['username'][0].toUpperCase(),
                              style: TextStyle(
                                color: adaptiveColor(context, Colors.white,
                                    foreground: true),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    user['username'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isSuperuser) ...[
                                  SizedBox(width: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: adaptiveColor(
                                          context, Colors.orange[100]!),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.star_rounded,
                                            size: 12,
                                            color: adaptiveColor(
                                                context, Colors.orange[700]!)),
                                        SizedBox(width: 4),
                                        Text(
                                          tr('m7'),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: adaptiveColor(
                                                context, Colors.orange[700]!,
                                                foreground: true),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.store_rounded,
                                    size: 14,
                                    color: adaptiveColor(
                                        context, Colors.grey[600]!)),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    user['store_name'] ?? tr('m110'),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: adaptiveColor(
                                          context, Colors.grey[600]!,
                                          foreground: true),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 3),
                            Text(
                              tr('m164', [
                                user['is_active'] == true
                                    ? tr('m132')
                                    : (user['has_password'] == true
                                        ? tr('m63')
                                        : tr('activationPending'))
                              ]),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: user['is_active'] == true
                                      ? Colors.green[700]
                                      : Colors.orange[800]),
                            ),
                          ],
                        ),
                      ),
                      if (!isSuperuser &&
                          (user['is_active'] == true ||
                              user['has_password'] == true))
                        IconButton(
                            icon: Icon(user['is_active'] == true
                                ? Icons.block
                                : Icons.check_circle_outline),
                            onPressed: () =>
                                _toggleUser(user, user['is_active'] != true),
                            tooltip: user['is_active'] == true
                                ? tr('m66')
                                : tr('m139')),
                      IconButton(
                          icon: Icon(Icons.vpn_key_rounded),
                          onPressed: () => _issueActivationCode(user),
                          tooltip: tr('m24'),
                          style: IconButton.styleFrom(
                              backgroundColor:
                                  adaptiveColor(context, Colors.blue[50]!),
                              foregroundColor: adaptiveColor(
                                  context, Colors.blue[700]!,
                                  foreground: true))),
                    ],
                  ),
                ),
              ),
            );
          },
        )),
      if (pages > 1) _pagination()
    ]);
  }

  Future<void> _toggleUser(Map<String, dynamic> user, bool active) async {
    final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Text(active ? tr('m571') : tr('m570')),
                content: Text(tr('m636', [
                  user['username'],
                  active ? 'faollashtiriladi' : 'bloklanadi'
                ])),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(tr('m55'))),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(tr('m511')))
                ]));
    if (ok != true) return;
    try {
      await ref.read(apiProvider).adminUser(user['id'] as int, active);
      await loadUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(friendlyFailure(e))));
      }
    }
  }

  void _showUserDetailsDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: user['is_superuser'] == true
                      ? [Colors.orange[400]!, Colors.orange[600]!]
                      : [Colors.blue[400]!, Colors.blue[600]!],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  user['username'][0].toUpperCase(),
                  style: TextStyle(
                    color:
                        adaptiveColor(context, Colors.white, foreground: true),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                user['username'],
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(
              icon: Icons.badge_rounded,
              label: 'ID',
              value: user['id'].toString(),
            ),
            _DetailRow(
                icon: Icons.calendar_today,
                label: tr('m414'),
                value: '${user['date_joined']}'),
            _DetailRow(
              icon: Icons.store_rounded,
              label: tr('m109'),
              value: user['store_name'] ?? tr('m271'),
            ),
            _DetailRow(
              icon: Icons.admin_panel_settings_rounded,
              label: tr('m413'),
              value: user['is_superuser'] == true ? tr('m489') : tr('m142'),
            ),
            _DetailRow(
                icon: Icons.verified_user_outlined,
                label: tr('m163'),
                value: user['is_active'] == true ? tr('m132') : tr('m64')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('m601')),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _issueActivationCode(user);
            },
            icon: Icon(Icons.vpn_key_rounded),
            label: Text(tr('m223')),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateUserDialog() async {
    final usernameController = TextEditingController();
    final storeNameController = TextEditingController();
    bool busy = false;
    String? dialogError;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: adaptiveColor(context, Colors.blue[50]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.person_add_rounded,
                        color: adaptiveColor(context, Colors.blue[700]!,
                            foreground: true)),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(tr('m580'), style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: tr('m144'),
                          hintText: 'user123',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        autofocus: true,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: storeNameController,
                        decoration: InputDecoration(
                          labelText: tr('m111'),
                          hintText: tr('m181'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon: Icon(Icons.store_outlined),
                        ),
                      ),
                      if (dialogError != null)
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: adaptiveColor(context, Colors.red[50]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline_rounded,
                                    color: adaptiveColor(
                                        context, Colors.red[700]!),
                                    size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    dialogError!,
                                    style: TextStyle(
                                        color: adaptiveColor(
                                            context, Colors.red[700]!,
                                            foreground: true),
                                        fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: busy ? null : () => Navigator.pop(context),
                  child: Text(tr('m57')),
                ),
                FilledButton.icon(
                  onPressed: busy
                      ? null
                      : () async {
                          if (usernameController.text.trim().isEmpty) {
                            setDialogState(() {
                              dialogError = tr('m565');
                            });
                            return;
                          }

                          setDialogState(() {
                            busy = true;
                            dialogError = null;
                          });

                          try {
                            final result =
                                await ref.read(apiProvider).createAdminUser(
                                      usernameController.text.trim(),
                                      storeNameController.text.trim(),
                                    );

                            if (context.mounted) {
                              Navigator.pop(context);
                              await loadUsers();

                              // Show success dialog
                              if (context.mounted) {
                                _showSuccessDialog(result);
                              }
                            }
                          } catch (e) {
                            setDialogState(() {
                              busy = false;
                              dialogError = e.toString();
                            });
                          }
                        },
                  icon: busy
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: adaptiveColor(context, Colors.white)),
                        )
                      : Icon(Icons.check_rounded),
                  label: Text(busy ? tr('m597') : tr('m598')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: adaptiveColor(context, Colors.green[50]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.check_circle_rounded,
                  color: adaptiveColor(context, Colors.green[700]!,
                      foreground: true),
                  size: 28),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(tr('m296'), style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(
              icon: Icons.person_rounded,
              label: tr('m564'),
              value: result['username'],
            ),
            _DetailRow(
              icon: Icons.store_rounded,
              label: tr('m109'),
              value: result['store_name'],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: adaptiveColor(context, Colors.blue[50]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: adaptiveColor(context, Colors.blue[700]!),
                      size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tr('m145'),
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('m216')),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Find the user in the list and issue activation code
              final newUser = users.firstWhere(
                (u) => u['username'] == result['username'],
                orElse: () => result,
              );
              _issueActivationCode(newUser);
            },
            icon: Icon(Icons.vpn_key_rounded),
            label: Text(tr('m223')),
          ),
        ],
      ),
    );
  }

  Future<void> _issueActivationCode(Map<String, dynamic> user) async {
    try {
      final result = await ref.read(apiProvider).issueCredential(
            user['id'],
            'activation',
          );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: adaptiveColor(context, Colors.orange[50]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.vpn_key_rounded,
                      color: adaptiveColor(context, Colors.orange[700]!,
                          foreground: true)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(tr('m24'), style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DetailRow(
                  icon: Icons.person_rounded,
                  label: tr('m142'),
                  value: user['username'],
                ),
                SizedBox(height: 16),
                Text(
                  tr('m58'),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        adaptiveColor(context, Colors.grey[100]!),
                        adaptiveColor(context, Colors.grey[200]!)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          result['one_time_code'],
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy_rounded),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: result['one_time_code']),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                      color:
                                          adaptiveColor(context, Colors.white)),
                                  SizedBox(width: 8),
                                  Text(tr('m224')),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor:
                                  adaptiveColor(context, Colors.green),
                            ),
                          );
                        },
                        style: IconButton.styleFrom(
                          backgroundColor:
                              adaptiveColor(context, Colors.blue[700]!),
                          foregroundColor: adaptiveColor(context, Colors.white,
                              foreground: true),
                        ),
                        tooltip: tr('m311'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: adaptiveColor(context, Colors.orange[50]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: adaptiveColor(context, Colors.orange[700]!),
                          size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          result['warning'] ?? tr('m227'),
                          style: TextStyle(
                            color: adaptiveColor(context, Colors.orange[900]!,
                                foreground: true),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.check_rounded),
                label: Text(tr('m559')),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_rounded,
                    color: adaptiveColor(context, Colors.white)),
                SizedBox(width: 8),
                Expanded(child: Text(friendlyFailure(e))),
              ],
            ),
            backgroundColor: adaptiveColor(context, Colors.red),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// Helper Widgets

class _DashboardCard extends StatelessWidget {
  final Gradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;

  const _DashboardCard({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: adaptiveColor(context, Colors.blue.withValues(alpha: 0.3)),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  adaptiveColor(context, Colors.white.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon,
                size: 40,
                color: adaptiveColor(context, Colors.white, foreground: true)),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color:
                        adaptiveColor(context, Colors.white, foreground: true),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: adaptiveColor(
                        context, Colors.white.withValues(alpha: 0.9),
                        foreground: true),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: adaptiveColor(context, Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                  child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ))),
            ],
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color:
                  adaptiveColor(context, Colors.grey[700]!, foreground: true),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: adaptiveColor(context, Colors.blue[50]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon,
                    color: adaptiveColor(context, Colors.blue[700]!,
                        foreground: true)),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: adaptiveColor(context, Colors.grey[600]!,
                            foreground: true),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 18, color: adaptiveColor(context, Colors.grey[400]!)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon,
              size: 20, color: adaptiveColor(context, Colors.grey[600]!)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: adaptiveColor(context, Colors.grey[600]!,
                        foreground: true),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
