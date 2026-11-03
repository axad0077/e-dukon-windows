import '../../../src/adaptive_colors.dart';
import '../../../src/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../products/providers/api.dart';
import '../models/sale.dart';
import 'receipt_screen.dart';

final salesHistoryProvider =
    FutureProvider.autoDispose<List<Sale>>((ref) async {
  final sales = await ref.read(apiProvider).getSalesList();
  return sales;
});

class SalesHistoryScreen extends ConsumerWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLocaleScope.of(context);
    final salesAsync = ref.watch(salesHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('m481')),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(salesHistoryProvider);
            },
            icon: Icon(Icons.refresh_rounded),
            tooltip: tr('m595'),
          ),
        ],
      ),
      body: salesAsync.when(
        data: (sales) {
          if (sales.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: adaptiveColor(context, Colors.grey[400]!),
                  ),
                  SizedBox(height: 16),
                  Text(
                    tr('m482'),
                    style: TextStyle(
                      fontSize: 18,
                      color: adaptiveColor(context, Colors.grey[600]!,
                          foreground: true),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: sales.length,
            itemBuilder: (context, index) {
              final sale = sales[index];
              return _SaleCard(sale: sale);
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 64, color: adaptiveColor(context, Colors.red[300]!)),
              SizedBox(height: 16),
              Text(
                tr('m575'),
                style: TextStyle(
                    fontSize: 18,
                    color: adaptiveColor(context, Colors.red[700]!,
                        foreground: true)),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  friendlyFailure(error),
                  style: TextStyle(
                      color: adaptiveColor(context, Colors.grey[600]!,
                          foreground: true)),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => ref.invalidate(salesHistoryProvider),
                icon: Icon(Icons.refresh),
                label: Text(tr('m381')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaleCard extends StatelessWidget {
  final Sale sale;

  const _SaleCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    final numberFormat = NumberFormat('#,##0', activeLanguage);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ReceiptScreen(sale: sale),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: adaptiveColor(context, Colors.blue[50]!),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '№${sale.receiptNumber}',
                          style: TextStyle(
                            color: adaptiveColor(context, Colors.blue[700]!,
                                foreground: true),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        dateFormat.format(sale.createdAt),
                        style: TextStyle(
                          fontSize: 13,
                          color: adaptiveColor(context, Colors.grey[600]!,
                              foreground: true),
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.chevron_right,
                      color: adaptiveColor(context, Colors.grey[400]!)),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('m259', [sale.items.length]),
                        style: TextStyle(
                          fontSize: 13,
                          color: adaptiveColor(context, Colors.grey[600]!,
                              foreground: true),
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          if (sale.cash > 0)
                            Container(
                              margin: EdgeInsets.only(right: 4),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    adaptiveColor(context, Colors.green[50]!),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.money,
                                      size: 12,
                                      color: adaptiveColor(
                                          context, Colors.green[700]!)),
                                  SizedBox(width: 2),
                                  Text(
                                    tr('m298'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: adaptiveColor(
                                          context, Colors.green[700]!,
                                          foreground: true),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (sale.card > 0)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: adaptiveColor(context, Colors.blue[50]!),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.credit_card,
                                      size: 12,
                                      color: adaptiveColor(
                                          context, Colors.blue[700]!)),
                                  SizedBox(width: 2),
                                  Text(
                                    tr('m204'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: adaptiveColor(
                                          context, Colors.blue[700]!,
                                          foreground: true),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    tr('m641', [numberFormat.format(sale.total)]),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
