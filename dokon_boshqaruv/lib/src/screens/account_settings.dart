import 'dart:async';

import 'package:url_launcher/url_launcher.dart';

import '../widgets/action_buttons.dart';
import '../adaptive_colors.dart';
import '../l10n/app_strings.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app.dart';
import '../preferences.dart';
import 'change_password.dart';

class AccountSettings extends ConsumerStatefulWidget {
  const AccountSettings({super.key});

  @override
  ConsumerState<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends ConsumerState<AccountSettings> {
  Map<String, dynamic>? profile;
  List<dynamic> plans = [];
  List<dynamic> payments = [];
  List<dynamic> subscriptions = [];
  bool loading = true;
  bool _purchasing = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final api = ref.read(apiProvider);
      final values = await Future.wait([
        api.me(),
        api.plans(),
        api.payments(),
        api.subscriptionHistory(),
      ]);
      if (!mounted) return;
      setState(() {
        profile = values[0] as Map<String, dynamic>;
        plans = values[1] as List<dynamic>;
        payments = values[2] as List<dynamic>;
        subscriptions = values[3] as List<dynamic>;
        loading = false;
      });
      if (_pendingPaymentId == null) {
        final pending = payments.whereType<Map>().where(
          (p) =>
              p['provider'] == 'inpay' &&
              p['provider_version'] == 'v2' &&
              p['status'] == 'pending',
        );
        if (pending.isNotEmpty) _watchPayment(pending.last['id'] as int);
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        error = _message(e);
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = tr('m278');
        loading = false;
      });
    }
  }

  String _message(DioException e) => friendlyFailure(e);

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr('m159'))),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error!, textAlign: TextAlign.center),
                  SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _load,
                    icon: Icon(Icons.refresh),
                    label: Text(tr('m383')),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: DropdownButtonFormField<ThemeMode>(
                        isExpanded: true,
                        initialValue: ref.watch(themeModeProvider),
                        decoration: InputDecoration(labelText: tr('m170')),
                        items: [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text(tr('m524')),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text(tr('m602')),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text(tr('m404')),
                          ),
                        ],
                        onChanged: (value) async {
                          if (value == null) return;
                          try {
                            await ref
                                .read(themeModeProvider.notifier)
                                .select(value);
                          } catch (_) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(tr('m274'))),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: ref.watch(languageProvider),
                        decoration: InputDecoration(labelText: tr('language')),
                        items: const [
                          DropdownMenuItem(
                            value: 'uz',
                            child: Text('O‘zbekcha'),
                          ),
                          DropdownMenuItem(value: 'ru', child: Text('Русский')),
                          DropdownMenuItem(value: 'en', child: Text('English')),
                        ],
                        onChanged: (value) async {
                          if (value == null) return;
                          try {
                            await ref
                                .read(languageProvider.notifier)
                                .select(value);
                          } catch (_) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(tr('preferenceSaveError')),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _profileCard(),
                  SizedBox(height: 16),
                  _subscriptionCard(),
                  SizedBox(height: 16),
                  _plansSection(),
                  SizedBox(height: 16),
                  _historySection(
                    tr('m551'),
                    payments,
                    (x) =>
                        '${x['plan_name'] ?? tr('plan')} · ${x['amount']} ${x['currency']} · ${displayStatus(x['status'])}',
                  ),
                  SizedBox(height: 16),
                  _historySection(
                    tr('m331'),
                    subscriptions,
                    (x) =>
                        '${x['plan_name'] ?? tr('plan')} · ${displayStatus(x['status'])} · ${x['ends_at'] ?? '—'}',
                  ),
                ],
              ),
            ),
    );
  }

  Widget _profileCard() {
    final p = profile!;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('m369'), style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 12),
            _row(tr('m564'), p['username']),
            _row(
              tr('m177'),
              '${p['first_name'] ?? ''} ${p['last_name'] ?? ''}'.trim(),
            ),
            _row(tr('m126'), p['email']),
            _row(tr('m114'), p['store']),
            _row(tr('m118'), p['store_phone']),
            _row(
              tr('m413'),
              p['is_superadmin'] == true ? tr('m489') : tr('m142'),
            ),
            _row(tr('m15'), p['is_active'] == true ? tr('m132') : tr('m63')),
            _row(tr('m596'), _date(p['date_joined'])),
            ActionButtons(
              children: [
                OutlinedButton.icon(
                  onPressed: _editProfile,
                  icon: Icon(Icons.person_outline),
                  label: Text(tr('m373')),
                ),
                OutlinedButton.icon(
                  onPressed: _changeUsername,
                  icon: Icon(Icons.edit),
                  label: Text(tr('m564')),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => ChangePassword())),
                  icon: Icon(Icons.lock_outline),
                  label: Text(tr('m365')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _subscriptionCard() {
    final sub = profile?['subscription'] as Map? ?? {};
    return Card(
      child: ListTile(
        leading: Icon(
          sub['active'] == true ? Icons.verified : Icons.warning_amber,
        ),
        title: Text(
          tr('m329', [displayStatus(sub['status'] ?? tr('unknown'))]),
        ),
        subtitle: Text(
          tr('m500', [sub['plan'] ?? '—', _date(sub['expires_at'])]),
        ),
      ),
    );
  }

  Timer? _paymentTimer;
  int? _pendingPaymentId;
  bool _checkingPayment = false;
  String? _paymentMessage;

  @override
  void dispose() {
    _paymentTimer?.cancel();
    super.dispose();
  }

  void _watchPayment(int id) {
    _pendingPaymentId = id;
    _paymentTimer?.cancel();
    var attempts = 0;
    _paymentTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!mounted || ++attempts > 40) {
        timer.cancel();
        return;
      }
      _checkPayment();
    });
    _checkPayment();
  }

  Future<void> _checkPayment() async {
    if (_checkingPayment || _pendingPaymentId == null || !mounted) return;
    _checkingPayment = true;
    try {
      final result = await ref
          .read(apiProvider)
          .dio
          .post('payments/inpay/$_pendingPaymentId/check/');
      if (!mounted) return;
      final status = result.data['status'];
      if (['approved', 'test_paid', 'failed', 'canceled'].contains(status)) {
        _paymentTimer?.cancel();
        setState(
          () => _paymentMessage = status == 'approved'
              ? 'To‘lov tasdiqlandi. Obuna uzaytirildi.'
              : status == 'test_paid'
              ? 'Sinov to‘lovi tasdiqlandi. Jonli obuna o‘zgarmadi.'
              : 'To‘lov amalga oshmadi. Qayta urinib ko‘ring.',
        );
        await _load();
      }
    } on DioException {
      // Temporary network failures leave the existing invoice intact.
    } finally {
      _checkingPayment = false;
    }
  }

  Future<void> _inpay(Map<String, dynamic> plan) async {
    if (_purchasing) return;
    setState(() {
      _purchasing = true;
      _paymentMessage = null;
    });
    try {
      final result = await ref
          .read(apiProvider)
          .dio
          .post(
            'payments/inpay/',
            data: {'plan_id': plan['id'], 'billing_period': 'month'},
          );
      final data = Map<String, dynamic>.from(result.data as Map);
      final uri = Uri.tryParse(data['pay_url']?.toString() ?? '');
      if (uri == null || uri.scheme != 'https' || uri.host != 'inpay.uz') {
        throw StateError('To‘lov havolasi noto‘g‘ri.');
      }
      if (!mounted) return;
      _watchPayment(data['id'] as int);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw StateError('Brauzerni ochib bo‘lmadi. Qayta urinib ko‘ring.');
      }
      if (mounted)
        setState(
          () => _paymentMessage =
              'To‘lov sahifasi ochildi. Natija avtomatik tekshiriladi.',
        );
    } on DioException catch (error) {
      if (mounted)
        setState(
          () => _paymentMessage = error.response?.data is Map
              ? error.response!.data['detail']?.toString() ?? 'To‘lov xatosi.'
              : 'Internet aloqasini tekshiring va qayta urinib ko‘ring.',
        );
    } catch (_) {
      if (mounted)
        setState(
          () => _paymentMessage =
              'To‘lov sahifasini ochib bo‘lmadi. Qayta urinib ko‘ring.',
        );
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Widget _plansSection() => Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('m501'), style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 8),
          const Text('Tarifni tanlang va inPAY orqali xavfsiz to‘lang.'),
          if (_paymentMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _paymentMessage!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ...plans.map((raw) {
            final plan = Map<String, dynamic>.from(raw as Map);
            final features = (plan['features'] as List? ?? []).join(' · ');
            final current = plan['name'] == profile?['subscription']?['plan'];
            return Container(
              margin: EdgeInsets.only(top: 16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: current
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: current
                      ? Theme.of(context).colorScheme.primary
                      : Color(0xFFDCE3E8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.workspace_premium_outlined,
                        color: adaptiveColor(context, Color(0xFF175CD3)),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${plan['name']}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  if (current)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(label: Text(tr('m194'))),
                      ),
                    ),
                  SizedBox(height: 16),
                  Text(
                    '${plan['price']} ${plan['currency']}',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                  Text(tr('m507')),
                  Divider(height: 28),
                  Text(tr('m635', [plan['user_limit'], plan['product_limit']])),
                  if ((plan['description'] ?? '').toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(plan['description'].toString()),
                    ),
                  if (features.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(features),
                    ),
                  SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _purchasing ? null : () => _inpay(plan),
                    icon: const Icon(Icons.payment),
                    label: const Text('inPAY orqali to‘lash'),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ),
  );

  Widget _historySection(
    String title,
    List<dynamic> rows,
    String Function(Map<String, dynamic>) label,
  ) => Card(
    child: ExpansionTile(
      title: Text('$title (${rows.length})'),
      children: rows.isEmpty
          ? [ListTile(title: Text(tr('m168')))]
          : rows
                .map(
                  (raw) => ListTile(
                    title: Text(label(Map<String, dynamic>.from(raw as Map))),
                  ),
                )
                .toList(),
    ),
  );

  Widget _row(String label, Object? value) => Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(
          width: 125,
          child: Text(
            label,
            style: TextStyle(
              color: adaptiveColor(context, Colors.blueGrey, foreground: true),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value?.toString().isNotEmpty == true ? value.toString() : '—',
          ),
        ),
      ],
    ),
  );

  String _date(Object? value) {
    if (value == null) return '—';
    final parsed = DateTime.tryParse(value.toString());
    return parsed == null
        ? value.toString()
        : '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
  }

  Future<void> _changeUsername() async {
    final controller = TextEditingController(
      text: '${profile?['username'] ?? ''}',
    );
    final next = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('m569')),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: tr('m594')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('m57')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(tr('m426')),
          ),
        ],
      ),
    );
    if (next == null || next.isEmpty) return;
    try {
      await ref.read(apiProvider).changeUsername(next);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(tr('m566'))));
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_message(e))));
      }
    }
  }

  Future<void> _editProfile() async {
    final p = profile ?? <String, dynamic>{};
    final first = TextEditingController(text: '${p['first_name'] ?? ''}');
    final last = TextEditingController(text: '${p['last_name'] ?? ''}');
    final email = TextEditingController(text: '${p['email'] ?? ''}');
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('m371')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: first,
              decoration: InputDecoration(labelText: tr('m176')),
            ),
            TextField(
              controller: last,
              decoration: InputDecoration(labelText: tr('m131')),
            ),
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: tr('m126')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr('m57')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr('m426')),
          ),
        ],
      ),
    );
    if (accepted != true) return;
    try {
      await ref.read(apiProvider).updateProfile({
        'first_name': first.text.trim(),
        'last_name': last.text.trim(),
        'email': email.text.trim(),
      });
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(tr('m372'))));
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_message(e))));
      }
    }
  }
}
