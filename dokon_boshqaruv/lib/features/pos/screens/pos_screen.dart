import '../../../src/adaptive_colors.dart';
import '../../../src/l10n/app_strings.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../providers/cart_provider.dart';
import '../utils/product_lookup.dart';
import '../../products/providers/products_provider.dart';
import '../../products/models/product.dart';
import '../widgets/cart_panel.dart';
import '../widgets/product_search.dart';
import '../widgets/product_grid.dart';
import '../widgets/payment_dialog.dart';
import 'sales_history_screen.dart';

class POSScreen extends ConsumerStatefulWidget {
  const POSScreen({super.key});

  @override
  ConsumerState<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends ConsumerState<POSScreen>
    with TickerProviderStateMixin {
  Timer? _clockTimer;
  String _currentTime = '';
  String _currentDate = '';
  final _searchController = TextEditingController();
  final _barcodeController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _fabAnimController;
  late Animation<double> _fabScaleAnim;
  bool _lookingUpBarcode = false;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _clockTimer = Timer.periodic(Duration(seconds: 1), (_) => _updateTime());

    _fabAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _fabScaleAnim = CurvedAnimation(
      parent: _fabAnimController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _searchController.dispose();
    _barcodeController.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  void _updateTime() {
    if (mounted) {
      final now = DateTime.now();
      setState(() {
        _currentTime = DateFormat('HH:mm:ss').format(now);
        _currentDate = DateFormat('dd.MM.yyyy').format(now);
      });
    }
  }

  Future<void> _addScannedBarcode(String barcode) async {
    if (_lookingUpBarcode) return;
    _lookingUpBarcode = true;
    try {
      var products = ref.read(productsProvider).asData?.value;
      if (products == null) {
        await ref.read(productsProvider.notifier).refresh().timeout(
              Duration(seconds: 12),
            );
        products = ref.read(productsProvider).asData?.value;
      }
      if (products == null && ref.read(productsProvider).hasError) {
        throw StateError(
          tr('m261'),
        );
      }
      products ??= <Product>[];
      final normalizedCode = normalizeProductCode(barcode);
      final product = findProductByCode(products, normalizedCode);
      if (!mounted) return;
      if (product == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(tr('m83')),
          backgroundColor: adaptiveColor(context, Colors.red),
        ));
        return;
      }
      final stock = double.tryParse(product.stock) ?? 0;
      if (stock <= 0 || !ref.read(cartProvider.notifier).addProduct(product)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(stock <= 0
              ? tr('m656', [product.name])
              : tr('m657', [product.name])),
          backgroundColor: adaptiveColor(context, Colors.orange[800]!),
        ));
        return;
      }
      HapticFeedback.selectionClick();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(tr('m640', [product.name])),
        duration: Duration(milliseconds: 900),
      ));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(tr('m262')),
          backgroundColor: adaptiveColor(context, Colors.red),
        ));
      }
    } finally {
      _lookingUpBarcode = false;
    }
  }

  Future<void> _clearCart() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color:
                      adaptiveColor(context, Colors.red.withValues(alpha: 0.1)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_sweep_rounded,
                  color: adaptiveColor(context, Colors.red, foreground: true),
                  size: 32,
                ),
              ),
              SizedBox(height: 16),
              Text(
                tr('m436'),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                tr('m52', [cart.length]),
                style: TextStyle(
                    color: adaptiveColor(context, Colors.grey[600]!,
                        foreground: true)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(tr('m600')),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: adaptiveColor(context, Colors.red),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(tr('m157')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      ref.read(cartProvider.notifier).clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: adaptiveColor(context, Colors.white), size: 18),
                SizedBox(width: 8),
                Text(tr('m434')),
              ],
            ),
            backgroundColor: adaptiveColor(context, Colors.orange[700]!),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> _showPaymentDialog() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.shopping_cart_outlined,
                  color: adaptiveColor(context, Colors.white), size: 18),
              SizedBox(width: 8),
              Text(tr('m431')),
            ],
          ),
          backgroundColor: adaptiveColor(context, Colors.grey[700]!),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: EdgeInsets.all(16),
        ),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentDialog(),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: adaptiveColor(context, Colors.white), size: 20),
              SizedBox(width: 10),
              Text(
                tr('m438'),
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: adaptiveColor(context, Color(0xFF2E7D32)),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    final isMobile = MediaQuery.of(context).size.width < 900;
    final cartItemCount = ref.watch(cartItemCountProvider);
    final cartSubtotal = ref.watch(cartSubtotalProvider);
    final numberFormat = NumberFormat('#,##0', activeLanguage);

    // FAB animation
    if (cartItemCount > 0) {
      _fabAnimController.forward();
    } else {
      _fabAnimController.reverse();
    }

    return Scaffold(
      backgroundColor: adaptiveColor(context, Color(0xFFF0F2F5)),
      appBar: _buildAppBar(context, cartItemCount, cartSubtotal, numberFormat),
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
      floatingActionButton: isMobile
          ? ScaleTransition(
              scale: _fabScaleAnim,
              child:
                  _buildCheckoutFAB(cartItemCount, cartSubtotal, numberFormat),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    int cartItemCount,
    double cartSubtotal,
    NumberFormat numberFormat,
  ) {
    return PreferredSize(
      preferredSize: Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF1976D2), Color(0xFF1E88E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: adaptiveColor(context, Color(0x331565C0)),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              SizedBox(width: 16),
              // Logo / Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: adaptiveColor(
                      context, Colors.white.withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.store_rounded,
                    color:
                        adaptiveColor(context, Colors.white, foreground: true),
                    size: 22),
              ),
              SizedBox(width: 12),
              // Title + Date
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('m210'),
                      style: TextStyle(
                        color: adaptiveColor(context, Colors.white,
                            foreground: true),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      _currentDate,
                      style: TextStyle(
                        color: adaptiveColor(
                            context, Colors.white.withValues(alpha: 0.75),
                            foreground: true),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Keep history and clear actions visible on compact phones.
              if (MediaQuery.sizeOf(context).width >= 480)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: adaptiveColor(
                        context, Colors.white.withValues(alpha: 0.12)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: adaptiveColor(
                            context, Colors.white.withValues(alpha: 0.2))),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 13,
                          color: adaptiveColor(
                              context, Colors.white.withValues(alpha: 0.8))),
                      SizedBox(width: 5),
                      Text(
                        _currentTime,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: adaptiveColor(context, Colors.white,
                              foreground: true),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(width: 8),
              // History button
              _AppBarIconBtn(
                icon: Icons.receipt_long_rounded,
                tooltip: tr('m481'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SalesHistoryScreen()),
                ),
              ),
              // Clear cart
              _AppBarIconBtn(
                icon: Icons.delete_sweep_rounded,
                tooltip: tr('m436'),
                onTap: _clearCart,
                badgeCount: cartItemCount > 0 ? cartItemCount : null,
              ),
              SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutFAB(
    int cartItemCount,
    double cartSubtotal,
    NumberFormat numberFormat,
  ) {
    if (cartItemCount == 0) return SizedBox.shrink();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        color: adaptiveColor(context, Colors.transparent),
        child: InkWell(
          onTap: _showPaymentDialog,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1B5E20),
                  Color(0xFF2E7D32),
                  Color(0xFF388E3C)
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: adaptiveColor(context, Color(0x662E7D32)),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment_rounded,
                    color: adaptiveColor(context, Colors.white), size: 22),
                SizedBox(width: 10),
                Text(
                  tr('m531', [cartItemCount]),
                  style: TextStyle(
                    color:
                        adaptiveColor(context, Colors.white, foreground: true),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: adaptiveColor(
                        context, Colors.white.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tr('m641', [numberFormat.format(cartSubtotal)]),
                    style: TextStyle(
                      color: adaptiveColor(context, Colors.white,
                          foreground: true),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left: Products
        Expanded(
          flex: 7,
          child: Column(
            children: [
              if (ref.watch(productsStaleProvider)) _StaleStockBanner(),
              _buildSearchBar(),
              Expanded(child: ProductGrid(searchQuery: _searchQuery)),
            ],
          ),
        ),
        // Divider
        Container(width: 1, color: adaptiveColor(context, Color(0xFFE0E0E0))),
        // Right: Cart
        Container(
          width: 420,
          color: adaptiveColor(context, Colors.white),
          child: CartPanel(onCheckout: _showPaymentDialog),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    final cartItemCount = ref.watch(cartItemCountProvider);

    return Column(
      children: [
        if (ref.watch(productsStaleProvider)) _StaleStockBanner(),
        _buildSearchBar(),
        if (cartItemCount > 0) _buildMiniCartBanner(cartItemCount),
        Expanded(child: ProductGrid(searchQuery: _searchQuery)),
        SizedBox(height: 80), // FAB spacing
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: adaptiveColor(context, Colors.white),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: ProductSearch(
        controller: _searchController,
        barcodeController: _barcodeController,
        onBarcodeSubmitted: _addScannedBarcode,
        onSearch: (query) => setState(() => _searchQuery = query),
      ),
    );
  }

  Widget _buildMiniCartBanner(int cartItemCount) {
    final subtotal = ref.watch(cartSubtotalProvider);
    final numberFormat = NumberFormat('#,##0', activeLanguage);

    return Container(
      margin: EdgeInsets.fromLTRB(12, 0, 12, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: adaptiveColor(context, Color(0x331565C0)),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: adaptiveColor(context, Colors.transparent),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: adaptiveColor(context, Colors.transparent),
              builder: (context) => DraggableScrollableSheet(
                initialChildSize: 0.9,
                minChildSize: 0.5,
                maxChildSize: 0.95,
                builder: (context, scrollController) => CartPanel(
                  onCheckout: () {
                    Navigator.pop(context);
                    _showPaymentDialog();
                  },
                  scrollController: scrollController,
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: adaptiveColor(
                        context, Colors.white.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$cartItemCount',
                      style: TextStyle(
                        color: adaptiveColor(context, Colors.white,
                            foreground: true),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  tr('m429'),
                  style: TextStyle(
                    color:
                        adaptiveColor(context, Colors.white, foreground: true),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Spacer(),
                Text(
                  tr('m641', [numberFormat.format(subtotal)]),
                  style: TextStyle(
                    color:
                        adaptiveColor(context, Colors.white, foreground: true),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.keyboard_arrow_up_rounded,
                    color: adaptiveColor(context, Colors.white), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StaleStockBanner extends StatelessWidget {
  const _StaleStockBanner();

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: adaptiveColor(context, Color(0xFFFFF3E0)),
      child: Text(
        tr('m174'),
        style: TextStyle(
            color: adaptiveColor(context, Color(0xFFE65100), foreground: true),
            fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Reusable AppBar icon button
class _AppBarIconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final int? badgeCount;

  const _AppBarIconBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          margin: EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: adaptiveColor(context, Colors.white.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                  child: Icon(icon,
                      color: adaptiveColor(context, Colors.white,
                          foreground: true),
                      size: 22)),
              if (badgeCount != null && badgeCount! > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: adaptiveColor(context, Color(0xFFFF5252)),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$badgeCount',
                        style: TextStyle(
                          color: adaptiveColor(context, Colors.white,
                              foreground: true),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
