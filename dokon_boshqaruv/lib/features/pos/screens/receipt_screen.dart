import '../../../src/adaptive_colors.dart';
import '../../../src/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';

class ReceiptScreen extends StatelessWidget {
  final Sale sale;

  const ReceiptScreen({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    final numberFormat = NumberFormat('#,##0', activeLanguage);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Scaffold(
      backgroundColor: adaptiveColor(context, Colors.grey[100]!),
      appBar: AppBar(
        title: Text(tr('m95')),
        actions: [
          // Printer/PDF integrations are not implemented in this project.
          // Keep their availability explicit instead of pretending an export succeeded.
          IconButton(
              onPressed: null,
              icon: const Icon(Icons.print),
              tooltip: tr('m100')),
          IconButton(
              onPressed: null,
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: tr('m354')),
        ],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          margin: EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Store header
                  Center(
                    child: Column(
                      children: [
                        Text(
                          tr('m102'),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          tr('m437'),
                          style: TextStyle(
                            fontSize: 14,
                            color: adaptiveColor(context, Colors.grey,
                                foreground: true),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Divider(),
                  SizedBox(height: 16),
                  // Receipt info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tr('m96'),
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      Text(
                        sale.receiptNumber,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tr('m422'),
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      Text(dateFormat.format(sale.createdAt)),
                    ],
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),
                  // Items
                  Text(
                    tr('m235'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color:
                          adaptiveColor(context, Colors.grey, foreground: true),
                    ),
                  ),
                  SizedBox(height: 12),
                  ...sale.items.map((item) => Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  tr('m655', [
                                    item.quantity,
                                    numberFormat.format(item.unitPrice)
                                  ]),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: adaptiveColor(
                                        context, Colors.grey[600]!,
                                        foreground: true),
                                  ),
                                ),
                                Text(
                                  tr('m641',
                                      [numberFormat.format(item.lineTotal)]),
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),
                  // Totals
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tr('m188'), style: TextStyle(fontSize: 15)),
                      Text(
                        tr('m641', [numberFormat.format(sale.subtotal)]),
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  if (sale.discount > 0) ...[
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tr('m93'), style: TextStyle(fontSize: 15)),
                        Text(
                          tr('m2', [numberFormat.format(sale.discount)]),
                          style: TextStyle(
                              fontSize: 15,
                              color: adaptiveColor(context, Colors.red,
                                  foreground: true)),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: adaptiveColor(context, Colors.green[50]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tr('m491'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          tr('m641', [numberFormat.format(sale.total)]),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: adaptiveColor(context, Colors.green,
                                foreground: true),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  // Payment methods
                  Text(
                    tr('m490'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color:
                          adaptiveColor(context, Colors.grey, foreground: true),
                    ),
                  ),
                  SizedBox(height: 8),
                  if (sale.cash > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tr('m303')),
                        Text(
                          tr('m641', [numberFormat.format(sale.cash)]),
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  if (sale.card > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tr('m208')),
                        Text(
                          tr('m641', [numberFormat.format(sale.card)]),
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  SizedBox(height: 24),
                  Divider(),
                  SizedBox(height: 16),
                  // Footer
                  Center(
                    child: Column(
                      children: [
                        Text(
                          tr('m405'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          tr('m384'),
                          style: TextStyle(
                              color: adaptiveColor(context, Colors.grey[600]!,
                                  foreground: true)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
          icon: Icon(Icons.home_rounded),
          label: Text(tr('m36')),
          style: FilledButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}
