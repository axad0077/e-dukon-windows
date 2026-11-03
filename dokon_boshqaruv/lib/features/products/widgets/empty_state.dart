import '../../../src/adaptive_colors.dart';
import '../../../src/l10n/app_strings.dart';

import 'package:flutter/material.dart';

class EmptyProductsState extends StatelessWidget {
  final VoidCallback onAddProduct;

  const EmptyProductsState({super.key, required this.onAddProduct});

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 120,
              color: adaptiveColor(context, Colors.grey[300]!),
            ),
            SizedBox(height: 24),
            Text(
              tr('m166'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: adaptiveColor(context, Colors.grey, foreground: true),
              ),
            ),
            SizedBox(height: 12),
            Text(
              tr('m61'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: adaptiveColor(
                  context,
                  Colors.grey[600]!,
                  foreground: true,
                ),
              ),
            ),
            SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onAddProduct,
              icon: Icon(Icons.add),
              label: Text(tr('m248')),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
