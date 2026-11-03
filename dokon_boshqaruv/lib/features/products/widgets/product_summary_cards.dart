import '../../../src/adaptive_colors.dart';
import '../../../src/l10n/app_strings.dart';

import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductSummaryCards extends StatelessWidget {
  final ProductSummary summary;

  const ProductSummaryCards({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    if (isSmallScreen) {
      return Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: tr('m185'),
                    value: summary.totalProducts.toString(),
                    icon: Icons.inventory_2,
                    color: adaptiveColor(context, Colors.blue),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: tr('m396'),
                    value: summary.totalStock.toStringAsFixed(0),
                    icon: Icons.storage,
                    color: adaptiveColor(context, Colors.green),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: tr('m195'),
                    value: summary.lowStockCount.toString(),
                    icon: Icons.warning_amber,
                    color: adaptiveColor(context, Colors.orange),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: tr('m557'),
                    value: summary.outOfStockCount.toString(),
                    icon: Icons.error_outline,
                    color: adaptiveColor(context, Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Desktop/tablet layout
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              title: tr('m186'),
              value: summary.totalProducts.toString(),
              icon: Icons.inventory_2,
              color: adaptiveColor(context, Colors.blue),
              isLarge: true,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _SummaryCard(
              title: tr('m187'),
              value: summary.totalStock.toStringAsFixed(0),
              icon: Icons.storage,
              color: adaptiveColor(context, Colors.green),
              isLarge: true,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _SummaryCard(
              title: tr('m195'),
              value: summary.lowStockCount.toString(),
              icon: Icons.warning_amber,
              color: adaptiveColor(context, Colors.orange),
              isLarge: true,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _SummaryCard(
              title: tr('m557'),
              value: summary.outOfStockCount.toString(),
              icon: Icons.error_outline,
              color: adaptiveColor(context, Colors.red),
              isLarge: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLarge;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isLarge ? 20.0 : 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: isLarge ? 32 : 24),
                if (isLarge)
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
              ],
            ),
            SizedBox(height: isLarge ? 12 : 8),
            Text(
              title,
              style: TextStyle(
                fontSize: isLarge ? 14 : 12,
                color: adaptiveColor(
                  context,
                  Colors.grey[600]!,
                  foreground: true,
                ),
              ),
            ),
            if (!isLarge)
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
