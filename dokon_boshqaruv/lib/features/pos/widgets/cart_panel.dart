import '../../../src/adaptive_colors.dart';
import '../../../src/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import 'package:intl/intl.dart';

class CartPanel extends ConsumerWidget {
  final VoidCallback onCheckout;
  final ScrollController? scrollController;

  const CartPanel({
    super.key,
    required this.onCheckout,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLocaleScope.of(context);
    final cart = ref.watch(cartProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final numberFormat = NumberFormat('#,##0', activeLanguage);
    final isBottomSheet = scrollController != null;

    return Column(
      children: [
        // ──── Header ────
        Container(
          padding: EdgeInsets.fromLTRB(
              20, isBottomSheet ? 16 : 12, 12, isBottomSheet ? 12 : 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: isBottomSheet
                ? BorderRadius.vertical(top: Radius.circular(24))
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: adaptiveColor(
                      context, Colors.white.withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.shopping_cart_rounded,
                    color:
                        adaptiveColor(context, Colors.white, foreground: true),
                    size: 20),
              ),
              SizedBox(width: 10),
              Expanded(
                  child: Text(
                tr('m429'),
                style: TextStyle(
                  color: adaptiveColor(context, Colors.white, foreground: true),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )),
              const SizedBox(width: 8),
              if (cart.isNotEmpty)
                Flexible(
                    child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: adaptiveColor(
                        context, Colors.white.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tr('m638', [cart.length]),
                    style: TextStyle(
                      color: adaptiveColor(context, Colors.white,
                          foreground: true),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                )),
              if (isBottomSheet)
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded,
                      color: adaptiveColor(context, Colors.white,
                          foreground: true)),
                ),
            ],
          ),
        ),

        // ──── Cart Items ────
        Expanded(
          child: cart.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                  itemCount: cart.length,
                  itemBuilder: (context, index) {
                    return _CartItemTile(item: cart[index], index: index);
                  },
                ),
        ),

        // ──── Summary + Checkout ────
        if (cart.isNotEmpty)
          _buildSummarySection(subtotal, numberFormat, context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: adaptiveColor(context, Color(0xFFE3F2FD)),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 48,
                color:
                    adaptiveColor(context, Color(0xFF1976D2), foreground: true),
              ),
            ),
            SizedBox(height: 20),
            Text(
              tr('m430'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:
                    adaptiveColor(context, Color(0xFF424242), foreground: true),
              ),
            ),
            SizedBox(height: 8),
            Text(
              tr('m267'),
              style: TextStyle(
                color:
                    adaptiveColor(context, Colors.grey[500]!, foreground: true),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(
      double subtotal, NumberFormat numberFormat, BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: adaptiveColor(context, Colors.white),
        boxShadow: [
          BoxShadow(
            color: adaptiveColor(context, Colors.black.withValues(alpha: 0.06)),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Total Row
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: adaptiveColor(context, Color(0xFFF3F8FF)),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Color(0xFF1976D2).withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('m188'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: adaptiveColor(context, Color(0xFF424242),
                        foreground: true),
                  ),
                ),
                Text(
                  tr('m641', [numberFormat.format(subtotal)]),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: adaptiveColor(context, Color(0xFF1565C0),
                        foreground: true),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          // Standard button supplies focus, semantics and a flexible text label.
          SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                  onPressed: onCheckout,
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32)),
                  icon: const Icon(Icons.payment_rounded),
                  label: Text(tr('m530'), textAlign: TextAlign.center))),
        ],
      ),
    );
  }
}

// ──── Cart Item Tile ────
class _CartItemTile extends ConsumerStatefulWidget {
  final CartItem item;
  final int index;

  const _CartItemTile({required this.item, required this.index});

  @override
  ConsumerState<_CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends ConsumerState<_CartItemTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
    _slideAnim = Tween<Offset>(
      begin: Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  void _showQuantityEditor(BuildContext context) {
    final ctrl = TextEditingController(
      text: widget.item.quantity.toStringAsFixed(
          widget.item.quantity == widget.item.quantity.truncate() ? 0 : 3),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          widget.item.name,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tr('m273', [widget.item.availableStock, widget.item.unit]),
              style: TextStyle(
                  color: adaptiveColor(context, Colors.grey[600]!,
                      foreground: true),
                  fontSize: 13),
            ),
            SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              autofocus: true,
              decoration: InputDecoration(
                labelText: tr('m285'),
                suffixText: widget.item.unit,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('m55')),
          ),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text);
              if (v == null || v <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(tr('m287')),
                ));
                return;
              }
              if (v > widget.item.availableStock) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(tr('m343')),
                ));
                return;
              }
              ref
                  .read(cartProvider.notifier)
                  .updateQuantity(widget.item.productId, v);
              Navigator.pop(ctx);
            },
            child: Text(tr('m321')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    final numberFormat = NumberFormat('#,##0', activeLanguage);
    final canIncrement = widget.item.canIncrement();

    return SlideTransition(
      position: _slideAnim,
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: adaptiveColor(context, Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: adaptiveColor(context, Color(0xFFE0E0E0))),
          boxShadow: [
            BoxShadow(
              color: adaptiveColor(context, Color(0x0A000000)),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Row: name + delete ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item number circle
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: adaptiveColor(context, Color(0xFFE3F2FD)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index + 1}',
                        style: TextStyle(
                          color: adaptiveColor(context, Color(0xFF1976D2),
                              foreground: true),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: adaptiveColor(context, Color(0xFF212121),
                                foreground: true),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.qr_code_2_rounded,
                                size: 11,
                                color:
                                    adaptiveColor(context, Colors.grey[500]!)),
                            SizedBox(width: 3),
                            Text(
                              widget.item.sku,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: adaptiveColor(
                                      context, Colors.grey[500]!,
                                      foreground: true)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Delete button
                  GestureDetector(
                    onTap: () => ref
                        .read(cartProvider.notifier)
                        .removeProduct(widget.item.productId),
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: adaptiveColor(
                            context, Colors.red.withValues(alpha: 0.08)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: adaptiveColor(context, Colors.red,
                            foreground: true),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),

              // ── Bottom Row: qty controls + line total ──
              Wrap(
                spacing: 12,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Quantity control
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: adaptiveColor(context, Color(0xFFF5F5F5)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: adaptiveColor(context, Color(0xFFE0E0E0))),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Decrement
                        _QtyButton(
                          icon: Icons.remove_rounded,
                          onPressed: () => ref
                              .read(cartProvider.notifier)
                              .decrementQuantity(widget.item.productId),
                        ),
                        // Quantity tap to edit
                        GestureDetector(
                          onTap: () => _showQuantityEditor(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              widget.item.quantity ==
                                      widget.item.quantity.truncate()
                                  ? '${widget.item.quantity.toInt()}'
                                  : widget.item.quantity.toStringAsFixed(1),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: adaptiveColor(context, Color(0xFF212121),
                                    foreground: true),
                              ),
                            ),
                          ),
                        ),
                        // Increment
                        _QtyButton(
                          icon: Icons.add_rounded,
                          onPressed: canIncrement
                              ? () => ref
                                  .read(cartProvider.notifier)
                                  .incrementQuantity(widget.item.productId)
                              : null,
                          disabled: !canIncrement,
                        ),
                      ],
                    ),
                  ),

                  // Unit price
                  Text(
                    tr('m658', [numberFormat.format(widget.item.salePrice)]),
                    style: TextStyle(
                      fontSize: 12,
                      color: adaptiveColor(context, Colors.grey[600]!,
                          foreground: true),
                    ),
                  ),

                  // Line total
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: adaptiveColor(context, Color(0xFFE8F5E9)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tr('m641', [numberFormat.format(widget.item.lineTotal)]),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: adaptiveColor(context, Color(0xFF2E7D32),
                            foreground: true),
                      ),
                    ),
                  ),
                ],
              ),

              // Stock warning
              if (!canIncrement)
                Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 13,
                          color: adaptiveColor(context, Colors.orange)),
                      SizedBox(width: 4),
                      Text(
                        tr('m275',
                            [widget.item.availableStock, widget.item.unit]),
                        style: TextStyle(
                          fontSize: 11,
                          color: adaptiveColor(context, Colors.orange,
                              foreground: true),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Quantity +/- button
class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool disabled;

  const _QtyButton({
    required this.icon,
    required this.onPressed,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    return IconButton(
      onPressed: disabled ? null : onPressed,
      tooltip: icon == Icons.add_rounded
          ? tr('quantity_increase')
          : tr('quantity_decrease'),
      style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer),
      icon: Icon(icon, size: 20),
    );
  }
}
