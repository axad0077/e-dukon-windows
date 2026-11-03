import '../../../src/widgets/action_buttons.dart';
import '../../../src/adaptive_colors.dart';
import '../../../src/l10n/app_strings.dart';
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../src/api.dart';
import '../../../src/app.dart' show apiProvider, queueProvider;

import '../providers/cart_provider.dart';
import '../screens/receipt_screen.dart';

import '../../products/providers/api.dart' show ApiPosExtension;
import '../../products/providers/products_provider.dart';

class PaymentDialog extends ConsumerStatefulWidget {
  const PaymentDialog({super.key});

  @override
  ConsumerState<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<PaymentDialog> {
  final _cashController = TextEditingController();
  final _cardController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();

  int _paymentType = 0;
  bool _processing = false;

  String? _operationId;
  Map<String, dynamic>? _frozenPayload;

  static final _blue = Color(0xFF1565C0);
  static final _green = Color(0xFF2E7D32);

  @override
  void dispose() {
    _cashController.dispose();
    _cardController.dispose();
    _discountController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    super.dispose();
  }

  String _format(double value) {
    return NumberFormat('#,##0.##', activeLanguage).format(value);
  }

  double? _parse(String value) {
    final text = value.trim();

    if (text.isEmpty) return 0;

    final parsed = double.tryParse(
      text.replaceAll(',', '.'),
    );

    if (parsed == null || !parsed.isFinite) return null;

    return parsed;
  }

  int? _moneyCents(String value) {
    final amount = _parse(value);

    if (amount == null || amount < 0) return null;

    final scaled = amount * 100;

    if ((scaled - scaled.round()).abs() > 0.00001) {
      return null;
    }

    return scaled.round();
  }

  double get _discountPreview {
    return _parse(_discountController.text) ?? 0;
  }

  double get _cashPreview {
    return _parse(_cashController.text) ?? 0;
  }

  double get _cardPreview {
    return _parse(_cardController.text) ?? 0;
  }

  void _message(
    String text, {
    bool error = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? Colors.red.shade700 : _green,
      ),
    );
  }

  String _serverMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map) {
      final detail = data['error'];

      if (detail is Map && detail['message'] != null) {
        return detail['message'].toString();
      }

      if (detail is String) return detail;

      if (data['detail'] != null) {
        return data['detail'].toString();
      }

      if (data['message'] != null) {
        return data['message'].toString();
      }
    }

    final status = error.response?.statusCode;

    return status == null ? tr('m449') : tr('m446', [status]);
  }

  Map<String, dynamic>? _buildPayload() {
    final cart = ref.read(cartProvider);

    if (cart.isEmpty) {
      _message(tr('m432'), error: true);
      return null;
    }

    final subtotal = ref.read(cartSubtotalProvider);

    if (!subtotal.isFinite || subtotal < 0) {
      _message(tr('m433'), error: true);
      return null;
    }

    final subtotalCents = (subtotal * 100).round();
    final discountCents = _moneyCents(_discountController.text);

    if (discountCents == null || discountCents > subtotalCents) {
      _message(
        tr('m91'),
        error: true,
      );
      return null;
    }

    final totalCents = subtotalCents - discountCents;

    int cashCents = 0;
    int cardCents = 0;
    int debtCents = 0;

    if (_paymentType == 0) {
      final received = _moneyCents(_cashController.text);

      if (received == null || received < totalCents) {
        _message(
          tr('m301'),
          error: true,
        );
        return null;
      }

      cashCents = totalCents;
    } else if (_paymentType == 1) {
      final entered = _moneyCents(_cardController.text);

      if (entered == null || entered != totalCents) {
        _message(
          tr('m207'),
          error: true,
        );
        return null;
      }

      cardCents = entered;
    } else if (_paymentType == 2) {
      final receivedCash = _moneyCents(_cashController.text);
      final enteredCard = _moneyCents(_cardController.text);

      if (receivedCash == null || enteredCard == null) {
        _message(
          tr('m302'),
          error: true,
        );
        return null;
      }

      if (enteredCard > totalCents || receivedCash + enteredCard < totalCents) {
        _message(
          tr('m549'),
          error: true,
        );
        return null;
      }

      cardCents = enteredCard;
      cashCents = totalCents - enteredCard;
    } else {
      final customerName = _customerNameController.text.trim();
      if (customerName.isEmpty) {
        _message(
          tr('m282'),
          error: true,
        );
        return null;
      }
      debtCents = totalCents;
    }

    final payload = {
      'items': cart.map((item) => item.toJson()).toList(),
      'cash': (cashCents / 100).toStringAsFixed(2),
      'card': (cardCents / 100).toStringAsFixed(2),
      'discount': (discountCents / 100).toStringAsFixed(2),
    };

    if (debtCents > 0) {
      payload['debt'] = (debtCents / 100).toStringAsFixed(2);
      payload['customer_name'] = _customerNameController.text.trim();
      final phone = _customerPhoneController.text.trim();
      if (phone.isNotEmpty) {
        payload['customer_phone'] = phone;
      }
    }

    return payload;
  }

  void _setExact() {
    if (_processing || _frozenPayload != null) return;

    final subtotal = ref.read(cartSubtotalProvider);
    final discount = _parse(_discountController.text);

    if (discount == null || discount < 0 || discount > subtotal) {
      _message(tr('m94'), error: true);
      return;
    }

    final total = subtotal - discount;

    setState(() {
      if (_paymentType == 0) {
        _cashController.text = total.toStringAsFixed(2);
      } else if (_paymentType == 1) {
        _cardController.text = total.toStringAsFixed(2);
      } else {
        final card = _parse(_cardController.text) ?? 0;

        if (card >= 0 && card <= total) {
          _cashController.text = (total - card).toStringAsFixed(2);
        }
      }
    });
  }

  void _applyQuickPayment(double ratio) {
    if (_processing || _frozenPayload != null) return;

    final subtotal = ref.read(cartSubtotalProvider);
    final discount = _parse(_discountController.text) ?? 0;
    if (!subtotal.isFinite ||
        subtotal < 0 ||
        discount < 0 ||
        discount > subtotal) {
      _message(tr('m92'), error: true);
      return;
    }

    final total = subtotal - discount;
    final amount = (total * ratio).clamp(0.0, total);

    setState(() {
      if (_paymentType == 0) {
        _cashController.text = amount.toStringAsFixed(2);
      } else if (_paymentType == 1) {
        _cardController.text = amount.toStringAsFixed(2);
      } else {
        _cardController.text = amount.toStringAsFixed(2);
        _cashController.text = (total - amount).toStringAsFixed(2);
      }
    });
  }

  List<Map<String, dynamic>> _items(
    Map<String, dynamic> payload,
  ) {
    return (payload['items'] as List)
        .map(
          (item) => Map<String, dynamic>.from(item as Map),
        )
        .toList();
  }

  Map<int, double> _quantities(
    Map<String, dynamic> payload,
  ) {
    final result = <int, double>{};

    for (final item in _items(payload)) {
      final id = int.tryParse('${item['product_id']}');
      final quantity = double.tryParse('${item['quantity']}');

      if (id == null ||
          quantity == null ||
          !quantity.isFinite ||
          quantity <= 0) {
        throw FormatException(
          tr('m480'),
        );
      }

      result[id] = (result[id] ?? 0) + quantity;
    }

    return result;
  }

  Future<bool> _saveOfflineSale(
    Map<String, dynamic> payload,
    String operationId,
  ) async {
    final api = ref.read(apiProvider);
    final owner = api.sessionKey;
    final queue = ref.read(queueProvider);
    final database = await queue.db;
    final encoded = jsonEncode(payload);
    final quantities = _quantities(payload);

    // Sotuv va keshlangan qoldiq bir tranzaksiyada yoziladi.
    // Baza yozuvi tugamaguncha savat tozalanmaydi.
    return database.transaction<bool>((transaction) async {
      if (owner == null || api.sessionKey != owner) {
        throw StateError(tr('m16'));
      }

      final existing = await transaction.query(
        'operations',
        where: 'id = ?',
        whereArgs: [operationId],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        if (existing.first['payload'] != encoded) {
          throw StateError(
            tr('m347'),
          );
        }

        return false;
      }

      final cache = await transaction.query(
        'cache',
        where: 'key = ?',
        whereArgs: ['products'],
        limit: 1,
      );

      if (cache.isNotEmpty) {
        final cached = List<dynamic>.from(
          jsonDecode(
            cache.first['payload'] as String,
          ) as List,
        );

        final updated = cached.map<dynamic>((raw) {
          final product = Map<String, dynamic>.from(raw as Map);

          final id = int.tryParse('${product['id']}');
          final sold = quantities[id];

          if (sold != null) {
            final stock = double.tryParse('${product['stock']}');

            if (stock == null || !stock.isFinite) {
              throw FormatException(
                tr('m215'),
              );
            }

            final remaining = stock - sold;

            product['stock'] =
                (remaining < 0 ? 0.0 : remaining).toStringAsFixed(3);
          }

          return product;
        }).toList();

        await transaction.insert(
          'cache',
          {
            'key': 'products',
            'payload': jsonEncode(updated),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await transaction.insert(
        'operations',
        {
          'id': operationId,
          'payload': encoded,
          'status': 'pending',
          'retries': 0,
          'error': null,
        },
      );

      return true;
    });
  }

  void _adjustVisibleStock(
    Map<String, dynamic> payload,
  ) {
    final notifier = ref.read(productsProvider.notifier);

    for (final entry in _quantities(payload).entries) {
      notifier.adjustStockLocally(
        entry.key,
        -entry.value,
      );
    }
  }

  Future<void> _processSale() async {
    if (_processing) return;

    final newPayload = _frozenPayload == null ? _buildPayload() : null;

    if (_frozenPayload == null && newPayload == null) {
      return;
    }

    // Noaniq tarmoq xatosidan keyingi qayta urinishda
    // aynan bir xil ID va ma’lumotlar ishlatiladi.
    _frozenPayload ??= Map<String, dynamic>.from(
      jsonDecode(jsonEncode(newPayload)) as Map,
    );
    _operationId ??= Uuid().v4();

    final payload = _frozenPayload!;
    final operationId = _operationId!;

    final api = ref.read(apiProvider);
    final owner = api.sessionKey;

    if (owner == null) {
      _message(
        tr('m22'),
        error: true,
      );
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _processing = true);

    try {
      final sale = await api.createSalePOS(
        items: _items(payload),
        cash: double.parse(payload['cash'] as String),
        card: double.parse(payload['card'] as String),
        discount: double.parse(payload['discount'] as String),
        operationId: operationId,
        debt: payload.containsKey('debt')
            ? double.parse(payload['debt'] as String)
            : null,
        customerName: payload['customer_name'] as String?,
        customerPhone: payload['customer_phone'] as String?,
      );

      if (!mounted || api.sessionKey != owner) return;

      // Sotuv tasdiqlandi. Endi mahsulot yangilash xatosi
      // uni muvaffaqiyatsiz sotuvga aylantirmasligi kerak.
      ref.read(cartProvider.notifier).clear();

      try {
        _adjustVisibleStock(payload);
      } catch (_) {
        // Serverdagi sotuv allaqachon tasdiqlangan.
      }

      bool refreshFailed = false;

      try {
        final pending = await ref.read(queueProvider).pendingCount();

        if (pending == 0) {
          await ref.read(productsProvider.notifier).refresh();
        }
      } catch (_) {
        refreshFailed = true;
      }

      if (!mounted || api.sessionKey != owner) return;

      _frozenPayload = null;
      _operationId = null;

      navigator.pop(true);

      unawaited(
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => ReceiptScreen(sale: sale),
          ),
        ),
      );

      if (refreshFailed) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              tr('m478'),
            ),
          ),
        );
      }
    } on DioException catch (error) {
      if (!mounted || api.sessionKey != owner) return;

      if (Api.isNetworkError(error)) {
        try {
          final inserted = await _saveOfflineSale(
            payload,
            operationId,
          );

          if (!mounted || api.sessionKey != owner) return;

          ref.read(cartProvider.notifier).clear();

          if (inserted) {
            try {
              _adjustVisibleStock(payload);
            } catch (_) {
              // Doimiy bazadagi sotuv saqlangan.
            }
          }

          _operationId = null;
          _frozenPayload = null;

          navigator.pop(true);

          messenger.showSnackBar(
            SnackBar(
              content: Text(
                tr('m477'),
              ),
            ),
          );
        } catch (_) {
          if (mounted) {
            _message(
              tr('m483'),
              error: true,
            );
          }
        }
      } else {
        final status = error.response?.statusCode;

        // Aniq validatsiya rad javobidan keyin
        // summalarni tahrirlash mumkin.
        if (status == 400 || status == 422) {
          _operationId = null;
          _frozenPayload = null;
        }

        _message(
          _serverMessage(error),
          error: true,
        );
      }
    } catch (_) {
      if (mounted && api.sessionKey == owner) {
        _message(
          tr('m476'),
          error: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  Future<void> _close() async {
    if (_processing) return;

    if (_frozenPayload != null) {
      final shouldClose = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(tr('m475')),
          content: Text(
            tr('m445'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(tr('m403')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(tr('m601')),
            ),
          ],
        ),
      );

      if (shouldClose != true || !mounted) return;
    }

    Navigator.of(context).pop(false);
  }

  Widget _amountField(
    TextEditingController controller,
    String label,
  ) {
    return TextField(
      controller: controller,
      enabled: !_processing && _frozenPayload == null,
      keyboardType: TextInputType.numberWithOptions(
        decimal: true,
      ),
      inputFormatters: [
        TextInputFormatter.withFunction(
          (oldValue, newValue) {
            return RegExp(r'^\d*([.,]\d{0,2})?$').hasMatch(newValue.text)
                ? newValue
                : oldValue;
          },
        ),
      ],
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        suffixText: tr('m626'),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _quickAmountChip(String label, double ratio) {
    return ActionChip(
      label: Text(label),
      avatar: Icon(Icons.auto_awesome, size: 16),
      onPressed: _processing || _frozenPayload != null
          ? null
          : () => _applyQuickPayment(ratio),
      backgroundColor: Colors.blue.shade50,
      side: BorderSide(color: Colors.blue.shade200),
    );
  }

  Widget _summaryRow(
    String label,
    double value, {
    bool bold = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label),
        const SizedBox(height: 4),
        Text(tr('m642', [_format(value)]),
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: bold ? 18 : 14)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    final subtotal = ref.watch(cartSubtotalProvider);
    final cart = ref.watch(cartProvider);
    final total = subtotal - _discountPreview;

    final received = switch (_paymentType) {
      0 => _cashPreview,
      1 => _cardPreview,
      _ => _cashPreview + _cardPreview,
    };

    final change = _paymentType == 1 ? 0.0 : received - total;

    final locked = _processing || _frozenPayload != null;

    final screenHeight = MediaQuery.sizeOf(context).height;

    return PopScope(
      canPop: !_processing && _frozenPayload == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_processing) {
          unawaited(_close());
        }
      },
      child: Dialog(
        insetPadding: EdgeInsets.all(16),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 520,
            maxHeight: screenHeight * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: adaptiveColor(context, _blue),
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  8,
                  12,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.payment,
                      color: adaptiveColor(context, Colors.white),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tr('m539'),
                        style: TextStyle(
                          color: adaptiveColor(context, Colors.white,
                              foreground: true),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _processing ? null : _close,
                      icon: Icon(
                        Icons.close,
                        color: adaptiveColor(context, Colors.white,
                            foreground: true),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _summaryRow(
                        tr('m256'),
                        subtotal,
                      ),
                      SizedBox(height: 12),
                      _amountField(
                        _discountController,
                        tr('m89'),
                      ),
                      SizedBox(height: 12),
                      _summaryRow(
                        tr('m547'),
                        total,
                        bold: true,
                      ),
                      Divider(height: 28),
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        initialValue: _paymentType,
                        decoration: InputDecoration(
                          labelText: tr('m548'),
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 0,
                            child: Text(tr('m298')),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Text(tr('m204')),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text(tr('m299')),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Text(tr('m375')),
                          ),
                        ],
                        onChanged: locked
                            ? null
                            : (value) {
                                if (value != null) {
                                  setState(() {
                                    _paymentType = value;
                                  });
                                  if (_paymentType != 3 &&
                                      (_cashController.text.isEmpty ||
                                          _cardController.text.isEmpty)) {
                                    final subtotal =
                                        ref.read(cartSubtotalProvider);
                                    final discount =
                                        _parse(_discountController.text) ?? 0;
                                    final total = subtotal - discount;
                                    if (total > 0) {
                                      if (_paymentType == 0) {
                                        _cashController.text =
                                            total.toStringAsFixed(2);
                                      } else if (_paymentType == 1) {
                                        _cardController.text =
                                            total.toStringAsFixed(2);
                                      } else {
                                        _cardController.text =
                                            total.toStringAsFixed(2);
                                        _cashController.text = '0.00';
                                      }
                                    }
                                  }
                                }
                              },
                      ),
                      SizedBox(height: 16),
                      if (_paymentType != 3) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _quickAmountChip('25%', 0.25),
                              _quickAmountChip('50%', 0.50),
                              _quickAmountChip('75%', 0.75),
                              _quickAmountChip(tr('m537'), 1.0),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                      if (_paymentType == 3) ...[
                        TextField(
                          controller: _customerNameController,
                          enabled: !_processing && _frozenPayload == null,
                          decoration: InputDecoration(
                            labelText: tr('m281'),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _customerPhoneController,
                          enabled: !_processing && _frozenPayload == null,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: tr('m516'),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),
                      ] else ...[
                        if (_paymentType != 1)
                          _amountField(
                            _cashController,
                            tr('m280'),
                          ),
                        if (_paymentType == 2) SizedBox(height: 16),
                        if (_paymentType != 0)
                          _amountField(
                            _cardController,
                            tr('m205'),
                          ),
                      ],
                      SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: locked ? null : _setExact,
                        icon: Icon(Icons.calculate),
                        label: Text(
                          tr('m30'),
                        ),
                      ),
                      if (change > 0) ...[
                        SizedBox(height: 12),
                        _summaryRow(
                          tr('m385'),
                          change,
                          bold: true,
                        ),
                      ],
                      if (_frozenPayload != null) ...[
                        SizedBox(height: 12),
                        Text(
                          tr('m382'),
                          style: TextStyle(
                            color: adaptiveColor(context, Colors.orange,
                                foreground: true),
                          ),
                        ),
                      ],
                      SizedBox(height: 16),
                      Text(
                        tr('m206'),
                        style: TextStyle(
                          color: adaptiveColor(context, Colors.grey,
                              foreground: true),
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 8),
                      if (_paymentType == 3)
                        Text(
                          tr('m377'),
                          style: TextStyle(
                            color: adaptiveColor(context, Colors.grey,
                                foreground: true),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: ActionButtons(children: [
                  OutlinedButton(
                      onPressed: _processing ? null : _close,
                      child: Text(tr('m348'), textAlign: TextAlign.center)),
                  FilledButton(
                      onPressed:
                          _processing || cart.isEmpty ? null : _processSale,
                      style: FilledButton.styleFrom(
                          backgroundColor: adaptiveColor(context, _green)),
                      child: _processing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(
                              _frozenPayload == null ? tr('m511') : tr('m381'),
                              textAlign: TextAlign.center)),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
