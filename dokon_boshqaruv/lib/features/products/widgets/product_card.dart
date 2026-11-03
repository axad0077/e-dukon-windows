import '../../../src/widgets/product_photo.dart';
import '../../../src/adaptive_colors.dart';
import '../../../src/l10n/app_strings.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import 'quick_stock_adjustment.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLocaleScope.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder with quick action
            Stack(
              children: [
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: ProductPhoto(image: product.image, name: product.name),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _StockBadge(product: product),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.qr_code_2,
                          size: 12,
                          color: adaptiveColor(context, Colors.grey[600]!),
                        ),
                        SizedBox(width: 4),
                        Text(
                          product.sku,
                          style: TextStyle(
                            fontSize: 11,
                            color: adaptiveColor(
                              context,
                              Colors.grey[600]!,
                              foreground: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (product.categoryName?.isNotEmpty ?? false)
                      Text(
                        product.categoryName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (product.locationLabel.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Tooltip(
                          message: product.locationLabel,
                          child: Text(
                            product.locationLabel,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                    Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr('m631', [product.salePrice]),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: adaptiveColor(
                                    context,
                                    Colors.blue,
                                    foreground: true,
                                  ),
                                ),
                              ),
                              Text(
                                '${double.tryParse(product.stock)?.toStringAsFixed(1) ?? product.stock} ${unitLabel(product.unit)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: adaptiveColor(
                                    context,
                                    Colors.grey[600]!,
                                    foreground: true,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: adaptiveColor(context, Colors.blue[50]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              size: 18,
                              color: adaptiveColor(
                                context,
                                Colors.blue[700]!,
                                foreground: true,
                              ),
                            ),
                          ),
                          onPressed: () async {
                            await showDialog<bool>(
                              context: context,
                              builder: (context) =>
                                  QuickStockAdjustmentDialog(product: product),
                            );
                          },
                          tooltip: tr('m519'),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductListTile extends ConsumerWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductListTile({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLocaleScope.of(context);
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: ProductPhoto(
                      image: product.image,
                      name: product.name,
                      radius: 12,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.sku,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (product.categoryName != null)
                          Text(product.categoryName!),
                        if (product.locationLabel.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              product.locationLabel,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Chip(
                    label: Text('${product.stock} ${unitLabel(product.unit)}'),
                  ),
                  _StockBadge(product: product),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                tr('m631', [product.salePrice]),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => showDialog<bool>(
                  context: context,
                  builder: (_) => QuickStockAdjustmentDialog(product: product),
                ),
                icon: const Icon(Icons.add_rounded),
                label: Text(tr('m393')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final Product product;

  const _StockBadge({required this.product});

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    Color color;
    IconData icon;

    switch (product.stockStatus) {
      case 'tugagan':
        color = Colors.red;
        icon = Icons.error_rounded;
        break;
      case 'kam_qolgan':
        color = Colors.orange;
        icon = Icons.warning_rounded;
        break;
      case 'mavjud':
        color = Colors.green;
        icon = Icons.check_circle_rounded;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            product.stockStatusLabel,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
