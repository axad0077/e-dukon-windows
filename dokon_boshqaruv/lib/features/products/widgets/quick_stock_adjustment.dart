import '../../../src/adaptive_colors.dart';
import '../../../src/l10n/app_strings.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../../../src/app.dart';
import '../providers/products_provider.dart';

class QuickStockAdjustmentDialog extends ConsumerStatefulWidget {
  final Product product;

  const QuickStockAdjustmentDialog({super.key, required this.product});

  @override
  ConsumerState<QuickStockAdjustmentDialog> createState() =>
      _QuickStockAdjustmentDialogState();
}

class _QuickStockAdjustmentDialogState
    extends ConsumerState<QuickStockAdjustmentDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  final List<int> _presets = [10, 20, 50, 100, 200, 500];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitAdjustment(bool isAdding) async {
    if (_quantityController.text.isEmpty) {
      setState(() => _error = tr('m288'));
      return;
    }

    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      setState(() => _error = tr('m527'));
      return;
    }

    final delta = isAdding ? quantity : -quantity;
    final currentStock = double.tryParse(widget.product.stock) ?? 0;

    // Check if subtraction would result in negative stock
    if (!isAdding && (currentStock + delta) < 0) {
      setState(() => _error = tr('m397'));
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await ref
          .read(apiProvider)
          .adjustStock(
            widget.product.id,
            delta.toStringAsFixed(3),
            _reasonController.text.isEmpty
                ? (isAdding ? tr('m394') : tr('m44'))
                : _reasonController.text,
          );

      // Lokal ravishda darhol yangilaymiz — sahifa qayta yuklanmaydi
      ref
          .read(productsProvider.notifier)
          .adjustStockLocally(widget.product.id, delta);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: adaptiveColor(context, Colors.white),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tr('m398', [
                      isAdding ? "qo'shildi" : "ayrildi",
                      quantity.toStringAsFixed(1),
                      widget.product.unit,
                    ]),
                  ),
                ),
              ],
            ),
            backgroundColor: adaptiveColor(context, Colors.green),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _error = friendlyFailure(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    final isAdding = _tabController.index == 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[400]!],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: adaptiveColor(
                            context,
                            Colors.white.withValues(alpha: 0.2),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.inventory_2_rounded,
                          color: adaptiveColor(
                            context,
                            Colors.white,
                            foreground: true,
                          ),
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tr('m400'),
                          style: TextStyle(
                            color: adaptiveColor(
                              context,
                              Colors.white,
                              foreground: true,
                            ),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: adaptiveColor(
                            context,
                            Colors.white,
                            foreground: true,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: adaptiveColor(
                        context,
                        Colors.white.withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.name,
                                style: TextStyle(
                                  color: adaptiveColor(
                                    context,
                                    Colors.white,
                                    foreground: true,
                                  ),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                tr('m193', [
                                  double.tryParse(widget.product.stock)
                                          ?.toStringAsFixed(1) ??
                                      widget.product.stock,
                                  widget.product.unit,
                                ]),
                                style: TextStyle(
                                  color: adaptiveColor(
                                    context,
                                    Colors.white70,
                                    foreground: true,
                                  ),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: adaptiveColor(context, Colors.grey[100]!),
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.blue[700]!, width: 3),
                  ),
                ),
                labelColor: Colors.blue[700],
                unselectedLabelColor: Colors.grey[600],
                onTap: (_) => setState(() {}),
                tabs: [
                  Tab(
                    icon: Icon(Icons.add_circle_outline_rounded),
                    text: tr('m395'),
                  ),
                  Tab(
                    icon: Icon(Icons.remove_circle_outline_rounded),
                    text: tr('m43'),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Presets
                    Text(
                      tr('m520'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: adaptiveColor(
                          context,
                          Colors.grey,
                          foreground: true,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presets.map((preset) {
                        return ActionChip(
                          label: Text(
                            '$preset ${unitLabel(widget.product.unit)}',
                          ),
                          avatar: Icon(
                            isAdding ? Icons.add_rounded : Icons.remove_rounded,
                            size: 18,
                          ),
                          backgroundColor: adaptiveColor(
                            context,
                            Colors.blue[50]!,
                          ),
                          labelStyle: TextStyle(
                            color: adaptiveColor(
                              context,
                              Colors.blue[700]!,
                              foreground: true,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                          side: BorderSide(color: Colors.blue[200]!),
                          onPressed: () {
                            _quantityController.text = preset.toString();
                          },
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 24),

                    // Quantity Input
                    TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: tr('m286'),
                        hintText: '0.0',
                        suffixText: widget.product.unit,
                        prefixIcon: Icon(
                          isAdding
                              ? Icons.add_circle_rounded
                              : Icons.remove_circle_rounded,
                          color: isAdding ? Colors.green : Colors.orange,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: adaptiveColor(context, Colors.grey[50]!),
                      ),
                      autofocus: true,
                      onChanged: (_) => setState(() => _error = null),
                    ),

                    SizedBox(height: 16),

                    // Reason Input
                    TextField(
                      controller: _reasonController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: tr('m416'),
                        hintText: isAdding ? tr('m269') : tr('m268'),
                        prefixIcon: Icon(Icons.notes_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: adaptiveColor(context, Colors.grey[50]!),
                      ),
                    ),

                    if (_error != null)
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: adaptiveColor(context, Colors.red[50]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: adaptiveColor(context, Colors.red[700]!),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: TextStyle(
                                    color: adaptiveColor(
                                      context,
                                      Colors.red[700]!,
                                      foreground: true,
                                    ),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    SizedBox(height: 24),

                    // Preview
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isAdding
                              ? [Colors.green[50]!, Colors.green[100]!]
                              : [Colors.orange[50]!, Colors.orange[100]!],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isAdding
                              ? Colors.green[300]!
                              : Colors.orange[300]!,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                tr('m192'),
                                style: TextStyle(
                                  color: adaptiveColor(
                                    context,
                                    Colors.grey[700]!,
                                    foreground: true,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${double.tryParse(widget.product.stock)?.toStringAsFixed(1) ?? widget.product.stock} ${unitLabel(widget.product.unit)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                tr('m590'),
                                style: TextStyle(
                                  color: adaptiveColor(
                                    context,
                                    Colors.grey[700]!,
                                    foreground: true,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _calculateNewStock(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isAdding
                                      ? Colors.green[700]
                                      : Colors.orange[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: adaptiveColor(context, Colors.grey[50]!),
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(tr('m57')),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () => _submitAdjustment(isAdding),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: isAdding
                            ? Colors.green
                            : Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _isSubmitting
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: adaptiveColor(context, Colors.white),
                              ),
                            )
                          : Icon(
                              isAdding
                                  ? Icons.add_rounded
                                  : Icons.remove_rounded,
                            ),
                      label: Text(
                        _isSubmitting
                            ? tr('m425')
                            : (isAdding ? tr('m395') : tr('m43')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateNewStock() {
    final quantity = double.tryParse(_quantityController.text);
    final currentStock = double.tryParse(widget.product.stock) ?? 0;

    if (quantity == null) {
      return '${currentStock.toStringAsFixed(1)} ${unitLabel(widget.product.unit)}';
    }

    final isAdding = _tabController.index == 0;
    final delta = isAdding ? quantity : -quantity;
    final newStock = currentStock + delta;

    return '${newStock.toStringAsFixed(1)} ${unitLabel(widget.product.unit)}';
  }
}
