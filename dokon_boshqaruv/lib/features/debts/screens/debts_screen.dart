import 'dart:convert';
import '../../../src/widgets/action_buttons.dart';
import '../../../src/adaptive_colors.dart';
import '../../../src/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../src/app.dart';

final debtsProvider =
    FutureProvider.autoDispose.family<List<dynamic>, String>((ref, key) {
  final f = List<String>.from(jsonDecode(key) as List);
  return ref.read(apiProvider).debts(
      direction: f[0].isEmpty ? null : f[0],
      search: f[1],
      status: f[2].isEmpty ? null : f[2],
      due: f[3].isEmpty ? null : f[3],
      sort: f[4].isEmpty ? null : f[4],
      start: f[5].isEmpty ? null : f[5],
      end: f[6].isEmpty ? null : f[6]);
});

class DebtsScreen extends ConsumerStatefulWidget {
  const DebtsScreen({super.key});
  @override
  ConsumerState<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends ConsumerState<DebtsScreen> {
  String? _direction;
  String? _status;
  String? _due;
  String _sort = 'newest';
  DateTime? _start;
  DateTime? _end;
  final _search = TextEditingController();
  bool _busy = false;
  String _money(dynamic raw) => tr('m642', [
        NumberFormat('#,##0.##', activeLanguage)
            .format(double.tryParse('$raw') ?? 0)
      ]);
  String get _queryKey => jsonEncode([
        _direction ?? '',
        _search.text.trim(),
        _status ?? '',
        _due ?? '',
        _sort == 'newest' ? '' : _sort,
        _start == null ? '' : DateFormat('yyyy-MM-dd').format(_start!),
        _end == null ? '' : DateFormat('yyyy-MM-dd').format(_end!),
      ]);
  Future<void> _refresh() async => ref.invalidate(debtsProvider(_queryKey));

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    final data = ref.watch(debtsProvider(_queryKey));
    return Scaffold(
      body: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(padding: EdgeInsets.all(16), children: [
            Row(children: [
              Expanded(
                  child: Text(tr('m103'),
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold))),
              FilledButton.icon(
                  onPressed: _busy ? null : _newDebt,
                  icon: Icon(Icons.add),
                  label: Text(tr('m588')))
            ]),
            SizedBox(height: 14),
            DropdownButtonFormField<String?>(
                isExpanded: true,
                initialValue: _direction,
                decoration: InputDecoration(
                    labelText: tr('m379'), border: OutlineInputBorder()),
                items: [
                  DropdownMenuItem(value: null, child: Text(tr('m50'))),
                  DropdownMenuItem(value: 'customer', child: Text(tr('m283'))),
                  DropdownMenuItem(value: 'store', child: Text(tr('m117')))
                ],
                onChanged: (v) => setState(() => _direction = v)),
            SizedBox(height: 10),
            TextField(
                controller: _search,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: tr('m180'),
                    suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () => setState(() {})),
                    border: OutlineInputBorder()),
                onSubmitted: (_) => setState(() {})),
            SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [
              SizedBox(
                  width: 165,
                  child: DropdownButtonFormField<String?>(
                      isExpanded: true,
                      initialValue: _status,
                      decoration: InputDecoration(
                          labelText: tr('m165'), border: OutlineInputBorder()),
                      items: [
                        DropdownMenuItem(value: null, child: Text(tr('m48'))),
                        DropdownMenuItem(
                            value: 'open', child: Text(tr('m536'))),
                        DropdownMenuItem(
                            value: 'partial', child: Text(tr('m390'))),
                        DropdownMenuItem(
                            value: 'paid', child: Text(tr('m534'))),
                        DropdownMenuItem(
                            value: 'overdue', child: Text(tr('m292')))
                      ],
                      onChanged: (v) => setState(() => _status = v))),
              SizedBox(
                  width: 165,
                  child: DropdownButtonFormField<String?>(
                      isExpanded: true,
                      initialValue: _due,
                      decoration: InputDecoration(
                          labelText: tr('m289'), border: OutlineInputBorder()),
                      items: [
                        DropdownMenuItem(value: null, child: Text(tr('m49'))),
                        DropdownMenuItem(
                            value: 'today', child: Text(tr('m85'))),
                        DropdownMenuItem(
                            value: 'overdue', child: Text(tr('m351')))
                      ],
                      onChanged: (v) => setState(() => _due = v))),
              SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _sort,
                      decoration: InputDecoration(
                          labelText: tr('m428'), border: OutlineInputBorder()),
                      items: [
                        DropdownMenuItem(
                            value: 'newest', child: Text(tr('m589'))),
                        DropdownMenuItem(
                            value: 'largest', child: Text(tr('m130'))),
                        DropdownMenuItem(
                            value: 'oldest', child: Text(tr('m129'))),
                        DropdownMenuItem(
                            value: 'overdue', child: Text(tr('m293')))
                      ],
                      onChanged: (v) => setState(() => _sort = v ?? 'newest'))),
            ]),
            ActionButtons(children: [
              TextButton.icon(
                  onPressed: () async {
                    final d = await showDatePicker(
                        context: context,
                        initialDate: _start ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now());
                    if (d != null) setState(() => _start = d);
                  },
                  icon: Icon(Icons.calendar_month),
                  label: Text(_start == null
                      ? tr('m74')
                      : DateFormat('dd.MM.yyyy').format(_start!))),
              TextButton.icon(
                  onPressed: () async {
                    final d = await showDatePicker(
                        context: context,
                        initialDate: _end ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now());
                    if (d != null) setState(() => _end = d);
                  },
                  icon: Icon(Icons.calendar_month),
                  label: Text(_end == null
                      ? tr('m558')
                      : DateFormat('dd.MM.yyyy').format(_end!))),
              if (_start != null || _end != null)
                IconButton(
                    onPressed: () => setState(() {
                          _start = null;
                          _end = null;
                        }),
                    icon: Icon(Icons.clear))
            ]),
            SizedBox(height: 16),
            data.when(
                loading: () => Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Column(children: [
                      Icon(Icons.error_outline, size: 48),
                      Text(friendlyFailure(e), textAlign: TextAlign.center),
                      TextButton(onPressed: _refresh, child: Text(tr('m381')))
                    ]),
                data: (items) {
                  final visible = items;
                  final receivable = items
                      .where((x) => x['direction'] == 'customer')
                      .fold<double>(
                          0,
                          (s, x) =>
                              s + (double.tryParse('${x['balance']}') ?? 0));
                  final payable = items
                      .where((x) => x['direction'] == 'store')
                      .fold<double>(
                          0,
                          (s, x) =>
                              s + (double.tryParse('${x['balance']}') ?? 0));
                  final overdue =
                      items.where((x) => x['status'] == 'overdue').toList();
                  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
                  final dueToday = items
                      .where((x) =>
                          x['due_date'] == today &&
                          (double.tryParse('${x['balance']}') ?? 0) > 0)
                      .toList();
                  final customers = items
                      .where((x) =>
                          x['direction'] == 'customer' &&
                          (double.tryParse('${x['balance']}') ?? 0) > 0)
                      .map((x) => '${x['party_name']}|${x['phone']}')
                      .toSet()
                      .length;
                  final partialCount =
                      items.where((x) => x['status'] == 'partial').length;
                  final paidCount =
                      items.where((x) => x['status'] == 'paid').length;
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(children: [
                          Expanded(
                              child: _stat(tr('m336'), _money(receivable))),
                          SizedBox(width: 8),
                          Expanded(child: _stat(tr('m117'), _money(payable)))
                        ]),
                        SizedBox(height: 8),
                        Row(children: [
                          Expanded(
                              child: _stat(
                                  tr('m292'),
                                  tr('m653', [
                                    _money(overdue.fold<double>(
                                        0,
                                        (s, x) =>
                                            s +
                                            (double.tryParse(
                                                    '${x['balance']}') ??
                                                0))),
                                    overdue.length
                                  ]))),
                          SizedBox(width: 8),
                          Expanded(
                              child: _stat(
                                  tr('m86'),
                                  tr('m653', [
                                    _money(dueToday.fold<double>(
                                        0,
                                        (s, x) =>
                                            s +
                                            (double.tryParse(
                                                    '${x['balance']}') ??
                                                0))),
                                    dueToday.length
                                  ])))
                        ]),
                        SizedBox(height: 8),
                        _stat(tr('m380'), tr('m643', [customers])),
                        SizedBox(height: 8),
                        Row(children: [
                          Expanded(
                              child: _stat(
                                  tr('m391'), tr('m643', [partialCount]))),
                          SizedBox(width: 8),
                          Expanded(
                              child: _stat(tr('m538'), tr('m643', [paidCount])))
                        ]),
                        SizedBox(height: 12),
                        if (visible.isEmpty)
                          Padding(
                              padding: EdgeInsets.all(36),
                              child: Column(children: [
                                Icon(Icons.menu_book_outlined,
                                    size: 54,
                                    color: adaptiveColor(context, Colors.grey)),
                                Text(tr('m167'))
                              ]))
                        else
                          ...visible.map((d) => Card(
                              child: ListTile(
                                  leading: CircleAvatar(
                                      child: Icon(d['direction'] == 'customer'
                                          ? Icons.call_received
                                          : Icons.call_made)),
                                  title: Text('${d['party_name']}'),
                                  subtitle: Text(
                                      '${d['phone'] ?? ''}\n${_statusLabel(d['status'])}${d['due_date'] == null ? '' : ' · Muddat: ${DateFormat('dd.MM.yyyy').format(DateTime.parse('${d['due_date']}'))}'}\n${d['reason'] ?? ''}',
                                      maxLines: 2),
                                  isThreeLine: true,
                                  trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(_money(d['balance']),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        if ((double.tryParse(
                                                    '${d['balance']}') ??
                                                0) >
                                            0)
                                          TextButton(
                                              onPressed:
                                                  _busy ? null : () => _pay(d),
                                              child: Text(tr('m539')))
                                      ]),
                                  onTap: () => _details(d))))
                      ]);
                }),
          ])),
    );
  }

  Widget _stat(String title, String value) => Card(
      child: Padding(
          padding: EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title),
            SizedBox(height: 6),
            Text(value,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
          ])));

  String _statusLabel(dynamic status) => switch (status) {
        'paid' => tr('m534'),
        'partial' => tr('m391'),
        'overdue' => tr('m292'),
        _ => tr('m536'),
      };

  Future<void> _newDebt() async {
    final name = TextEditingController(),
        phone = TextEditingController(),
        amount = TextEditingController(),
        reason = TextEditingController(),
        note = TextEditingController();
    String direction = 'customer';
    DateTime createdOn = DateTime.now();
    DateTime? dueDate;
    final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => StatefulBuilder(
            builder: (ctx, set) => AlertDialog(
                    title: Text(tr('m588')),
                    content: SingleChildScrollView(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                      DropdownButtonFormField(
                          isExpanded: true,
                          initialValue: direction,
                          items: [
                            DropdownMenuItem(
                                value: 'customer', child: Text(tr('m283'))),
                            DropdownMenuItem(
                                value: 'store', child: Text(tr('m117')))
                          ],
                          onChanged: (v) => set(() => direction = v!),
                          decoration: InputDecoration(labelText: tr('m379'))),
                      TextField(
                          controller: name,
                          decoration: InputDecoration(labelText: tr('m179'))),
                      TextField(
                          controller: phone,
                          decoration: InputDecoration(labelText: tr('m516'))),
                      TextField(
                          controller: amount,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: tr('m488'))),
                      TextField(
                          controller: reason,
                          decoration: InputDecoration(labelText: tr('m418'))),
                      TextField(
                          controller: note,
                          decoration: InputDecoration(labelText: tr('m183'))),
                      Row(children: [
                        Expanded(
                            child: TextButton.icon(
                                onPressed: () async {
                                  final selected = await showDatePicker(
                                      context: ctx,
                                      initialDate: createdOn,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now());
                                  if (selected != null) {
                                    set(() => createdOn = selected);
                                  }
                                },
                                icon: Icon(Icons.event),
                                label: Text(tr('m423', [
                                  DateFormat('dd.MM.yyyy').format(createdOn)
                                ])))),
                        Expanded(
                            child: TextButton.icon(
                                onPressed: () async {
                                  final selected = await showDatePicker(
                                      context: ctx,
                                      initialDate: dueDate ?? DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2100));
                                  if (selected != null) {
                                    set(() => dueDate = selected);
                                  }
                                },
                                icon: Icon(Icons.event_available),
                                label: Text(dueDate == null
                                    ? tr('m291')
                                    : DateFormat('dd.MM.yyyy')
                                        .format(dueDate!))))
                      ])
                    ])),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(tr('m55'))),
                      FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(tr('m426')))
                    ])));
    if (ok != true || !mounted) return;
    final value = double.tryParse(amount.text.replaceAll(',', '.'));
    if (name.text.trim().isEmpty || value == null || value <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(tr('m178'))));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(apiProvider).createDebt({
        'direction': direction,
        'party_name': name.text.trim(),
        'phone': phone.text.trim(),
        'amount': value.toStringAsFixed(2),
        'reason': reason.text.trim(),
        'note': note.text.trim(),
        'created_on': DateFormat('yyyy-MM-dd').format(createdOn),
        if (dueDate != null)
          'due_date': DateFormat('yyyy-MM-dd').format(dueDate!)
      });
      await _refresh();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(tr('m378'))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pay(Map<String, dynamic> debt) async {
    final amount = TextEditingController();
    String method = 'cash';
    DateTime paidOn = DateTime.now();
    final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => StatefulBuilder(
            builder: (ctx, set) => AlertDialog(
                    title: Text(tr('m651', [debt['party_name']])),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(tr('m399', [_money(debt['balance'])])),
                      TextField(
                          controller: amount,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: tr('m547'))),
                      DropdownButtonFormField(
                          isExpanded: true,
                          initialValue: method,
                          items: [
                            DropdownMenuItem(
                                value: 'cash', child: Text(tr('m298'))),
                            DropdownMenuItem(
                                value: 'card', child: Text(tr('m204'))),
                            DropdownMenuItem(
                                value: 'bank', child: Text(tr('m47')))
                          ],
                          onChanged: (v) => set(() => method = v!)),
                      TextButton.icon(
                          onPressed: () async {
                            final selected = await showDatePicker(
                                context: ctx,
                                initialDate: paidOn,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now());
                            if (selected != null) set(() => paidOn = selected);
                          },
                          icon: Icon(Icons.event),
                          label: Text(tr('m545',
                              [DateFormat('dd.MM.yyyy').format(paidOn)])))
                    ]),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(tr('m55'))),
                      FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(tr('m374')))
                    ])));
    if (ok != true || !mounted) return;
    final value = double.tryParse(amount.text.replaceAll(',', '.'));
    if (value == null ||
        value <= 0 ||
        value > (double.tryParse('${debt['balance']}') ?? 0)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(tr('m544'))));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(apiProvider).recordDebtPayment(debt['id'] as int,
          amount: value.toStringAsFixed(2),
          method: method,
          paidOn: DateFormat('yyyy-MM-dd').format(paidOn));
      await _refresh();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(tr('m546'))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _details(Map<String, dynamic> debt) async {
    try {
      final d = await ref.read(apiProvider).debtDetail(debt['id'] as int);
      if (!mounted) return;
      showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
                  title: Text('${d['party_name']}'),
                  content: SizedBox(
                      width: 360,
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tr('m517', [d['phone'] ?? '—'])),
                            Text(tr('m73', [_money(d['amount'])])),
                            Text(tr('m535', [_money(d['paid'])])),
                            Text(tr('m399', [_money(d['balance'])])),
                            Text(tr('m419', [d['reason'] ?? '—'])),
                            Divider(),
                            Text(tr('m550'),
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            ...((d['payments'] as List?) ?? []).map((p) => Text(
                                '${p['paid_on']} · ${_money(p['amount'])} · ${p['method']}'))
                          ])),
                  actions: [
                    TextButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _editDetails(d);
                        },
                        icon: Icon(Icons.edit_outlined),
                        label: Text(tr('m495'))),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(tr('m601')))
                  ]));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(tr('m494'))));
      }
    }
  }

  Future<void> _editDetails(Map<String, dynamic> debt) async {
    final note = TextEditingController(text: '${debt['note'] ?? ''}');
    DateTime? due = debt['due_date'] == null
        ? null
        : DateTime.tryParse('${debt['due_date']}');
    final saved = await showDialog<bool>(
        context: context,
        builder: (ctx) => StatefulBuilder(
            builder: (ctx, set) => AlertDialog(
                  title: Text(tr('m376')),
                  content: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                        controller: note,
                        maxLines: 3,
                        decoration: InputDecoration(labelText: tr('m182'))),
                    TextButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                              context: ctx,
                              initialDate: due ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100));
                          if (picked != null) set(() => due = picked);
                        },
                        icon: Icon(Icons.event),
                        label: Text(due == null
                            ? tr('m543')
                            : DateFormat('dd.MM.yyyy').format(due!))),
                    if (due != null)
                      TextButton(
                          onPressed: () => set(() => due = null),
                          child: Text(tr('m294')))
                  ]),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(tr('m55'))),
                    FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(tr('m426')))
                  ],
                )));
    if (saved != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(apiProvider).updateDebt(debt['id'] as int,
          note: note.text,
          dueDate: due == null ? null : DateFormat('yyyy-MM-dd').format(due!),
          clearDueDate: due == null);
      await _refresh();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(tr('m352'))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
