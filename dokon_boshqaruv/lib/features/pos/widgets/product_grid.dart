import '../../../src/widgets/product_photo.dart';
import '../../../src/adaptive_colors.dart';
import '../../../src/l10n/app_strings.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../products/providers/products_provider.dart';
import '../../products/models/product.dart';
import '../providers/cart_provider.dart';

import 'package:intl/intl.dart';

class ProductGrid extends ConsumerWidget {
  final String searchQuery;

  const ProductGrid({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLocaleScope.of(context);
    final productsAsync = ref.watch(productsProvider);

    return productsAsync.when(
      data: (products) {
        // Only show active products with stock > 0 filter option
        final filteredProducts = searchQuery.isEmpty
            ? products.where((p) => p.active).toList()
            : products.where((p) {
                if (!p.active) return false;
                final query = searchQuery.toLowerCase();
                return p.name.toLowerCase().contains(query) ||
                    p.sku.toLowerCase().contains(query) ||
                    (p.barcode?.toLowerCase().contains(query) ?? false);
              }).toList();

        if (filteredProducts.isEmpty) {
          return _buildEmptyState(context, searchQuery);
        }

        return LayoutBuilder(
          builder: (context, box) {
            final crossAxisCount = (box.maxWidth / 190).floor().clamp(1, 4);
            final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
            return GridView.builder(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 100),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisExtent: 320 * scale.clamp(1.0, 1.8),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return _ProductCard(product: product);
              },
            );
          },
        );
      },
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(strokeWidth: 3),
            SizedBox(height: 12),
            Text(
              tr('m258'),
              style: TextStyle(
                color: adaptiveColor(context, Colors.grey, foreground: true),
              ),
            ),
          ],
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: adaptiveColor(context, Colors.red[50]!),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: adaptiveColor(
                    context,
                    Colors.red[400]!,
                    foreground: true,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                tr('m575'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: adaptiveColor(
                    context,
                    Color(0xFF424242),
                    foreground: true,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(
                  color: adaptiveColor(context, Colors.grey, foreground: true),
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String query) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: adaptiveColor(context, Colors.grey[100]!),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                query.isEmpty
                    ? Icons.inventory_2_outlined
                    : Icons.search_off_rounded,
                size: 48,
                color: adaptiveColor(
                  context,
                  Colors.grey[400]!,
                  foreground: true,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              query.isEmpty ? tr('m257') : tr('m158'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: adaptiveColor(
                  context,
                  Color(0xFF616161),
                  foreground: true,
                ),
              ),
            ),
            if (query.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                tr('m1', [query]),
                style: TextStyle(
                  color: adaptiveColor(context, Colors.grey, foreground: true),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends ConsumerStatefulWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  ConsumerState<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<_ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _addCtrl;
  late Animation<double> _addScale;

  @override
  void initState() {
    super.initState();
    _addCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 180),
    );
    _addScale = Tween<double>(
      begin: 1.0,
      end: 0.82,
    ).animate(CurvedAnimation(parent: _addCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _addCtrl.dispose();
    super.dispose();
  }

  void _onAddToCart() {
    final product = widget.product;
    final stock = double.tryParse(product.stock) ?? 0;
    if (stock <= 0) return;

    // Bounce animation: shrink then return
    _addCtrl.forward().then((_) => _addCtrl.reverse());

    ref.read(cartProvider.notifier).addProduct(product);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.add_shopping_cart_rounded,
              color: adaptiveColor(context, Colors.white),
              size: 18,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                tr('m639', [product.name]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: adaptiveColor(context, Color(0xFF1565C0)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.fromLTRB(12, 0, 12, 12),
        duration: Duration(milliseconds: 1200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    final product = widget.product;
    final stock = double.tryParse(product.stock) ?? 0;
    final isAvailable = stock > 0;
    final isInCart = ref
        .watch(cartProvider)
        .any((item) => item.productId == product.id);
    final numberFormat = NumberFormat('#,##0', activeLanguage);

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: adaptiveColor(context, Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isInCart
              ? Color(0xFF1565C0).withValues(alpha: 0.6)
              : Color(0xFFEEEEEE),
          width: isInCart ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isInCart
                ? Color(0xFF1565C0).withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isInCart ? 12 : 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: adaptiveColor(context, Colors.transparent),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isAvailable ? _onAddToCart : null,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Image / Icon Area ──
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ProductPhoto(
                        image: product.image,
                        name: product.name,
                        radius: 16,
                      ),
                    ),
                    // Out of stock overlay
                    if (!isAvailable)
                      Container(
                        decoration: BoxDecoration(
                          color: adaptiveColor(
                            context,
                            Colors.black.withValues(alpha: 0.35),
                          ),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            tr('m492'),
                            style: TextStyle(
                              color: adaptiveColor(
                                context,
                                Colors.white,
                                foreground: true,
                              ),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    // In-cart badge
                    if (isInCart)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: adaptiveColor(context, Color(0xFF1565C0)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shopping_cart_rounded,
                                color: adaptiveColor(context, Colors.white),
                                size: 11,
                              ),
                              SizedBox(width: 3),
                              Text(
                                tr('m435'),
                                style: TextStyle(
                                  color: adaptiveColor(
                                    context,
                                    Colors.white,
                                    foreground: true,
                                  ),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Stock badge top-right
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildStockBadge(stock, product.unit),
                    ),
                  ],
                ),
              ),

              // ── Info area ──
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          height: 1.3,
                          color: isAvailable
                              ? Color(0xFF212121)
                              : Colors.grey[500],
                        ),
                      ),
                      if (product.locationLabel.isNotEmpty)
                        Tooltip(
                          message: product.locationLabel,
                          child: Text(
                            product.locationLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      Spacer(),
                      // Price row + add button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr('m641', [
                                    numberFormat.format(
                                      double.tryParse(product.salePrice) ?? 0,
                                    ),
                                  ]),
                                  style: TextStyle(
                                    color: isAvailable
                                        ? Color(0xFF1565C0)
                                        : Colors.grey[400],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isAvailable)
                            ScaleTransition(
                              scale: _addScale,
                              child: GestureDetector(
                                onTap: _onAddToCart,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF1565C0),
                                        Color(0xFF1E88E5),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(9),
                                    boxShadow: [
                                      BoxShadow(
                                        color: adaptiveColor(
                                          context,
                                          Color(0x441565C0),
                                        ),
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.add_rounded,
                                    color: adaptiveColor(
                                      context,
                                      Colors.white,
                                      foreground: true,
                                    ),
                                    size: 18,
                                  ),
                                ),
                              ),
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
      ),
    );
  }

  Widget _buildStockBadge(double stock, String unit) {
    if (stock <= 0) return SizedBox.shrink();
    final isLow = stock <= (double.tryParse(widget.product.minStock) ?? 0);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isLow ? Colors.orange[700] : Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${stock % 1 == 0 ? stock.toInt() : stock.toStringAsFixed(1)} ${unitLabel(unit)}',
        style: TextStyle(
          color: adaptiveColor(context, Colors.white, foreground: true),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
