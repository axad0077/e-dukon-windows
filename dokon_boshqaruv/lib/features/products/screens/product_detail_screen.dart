import '../../../src/adaptive_colors.dart';
import '../../../src/l10n/app_strings.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/products_provider.dart';
import '../models/product.dart';
import '../../../src/app.dart'; // Import for apiProvider
import 'edit_product_screen.dart';

class ProductDetailScreen extends ConsumerWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLocaleScope.of(context);
    final productAsync = ref.watch(productProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('m243')),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              productAsync.whenData((product) {
                if (product != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProductScreen(product: product),
                    ),
                  );
                }
              });
            },
            tooltip: tr('m495'),
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(context, ref),
          ),
        ],
      ),
      body: productAsync.when(
        data: (product) {
          if (product == null) {
            return Center(child: Text(tr('m253')));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product Image
                Container(
                  height: 250,
                  color: adaptiveColor(context, Colors.grey[200]!),
                  child: product.image == null || product.image!.isEmpty
                      ? Center(
                          child: Icon(
                            Icons.image,
                            size: 80,
                            color: adaptiveColor(
                              context,
                              Colors.grey,
                              foreground: true,
                            ),
                          ),
                        )
                      : Image.network(
                          product.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(
                              Icons.image,
                              size: 80,
                              color: adaptiveColor(
                                context,
                                Colors.grey,
                                foreground: true,
                              ),
                            ),
                          ),
                        ),
                ),

                // Product Info
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildStockStatusBadge(product),
                        ],
                      ),

                      SizedBox(height: 8),

                      if (product.categoryName != null)
                        Chip(
                          avatar: Icon(Icons.category, size: 16),
                          label: Text(product.categoryName!),
                          visualDensity: VisualDensity.compact,
                        ),

                      SizedBox(height: 24),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mahsulot manzili',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ombor: ${product.warehouse.isEmpty ? 'Belgilanmagan' : product.warehouse}',
                              ),
                              Text(
                                'Bo‘lim: ${product.section.isEmpty ? 'Belgilanmagan' : product.section}',
                              ),
                              Text(
                                'Polka: ${product.shelf.isEmpty ? 'Belgilanmagan' : product.shelf}',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Price Cards
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              title: tr('m471'),
                              value: tr('m631', [product.salePrice]),
                              icon: Icons.sell,
                              color: adaptiveColor(context, Colors.green),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              title: tr('m574'),
                              value: tr('m631', [product.purchasePrice]),
                              icon: Icons.shopping_cart,
                              color: adaptiveColor(context, Colors.blue),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      // Stock Cards
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              title: tr('m396'),
                              value:
                                  '${product.stock} ${unitLabel(product.unit)}',
                              icon: Icons.inventory,
                              color: adaptiveColor(context, Colors.purple),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              title: tr('m284'),
                              value:
                                  '${product.minStock} ${unitLabel(product.unit)}',
                              icon: Icons.warning_amber,
                              color: adaptiveColor(context, Colors.orange),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Details Section
                      Text(
                        tr('m493'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 16),

                      _DetailRow(label: tr('m241'), value: product.sku),

                      if (product.barcode != null)
                        _DetailRow(label: tr('m455'), value: product.barcode!),

                      _DetailRow(label: tr('m313'), value: product.unit),

                      _DetailRow(
                        label: tr('m163'),
                        value: product.active ? tr('m132') : tr('m134'),
                      ),

                      if (product.updatedAt != null)
                        _DetailRow(
                          label: tr('m349'),
                          value: _formatDate(product.updatedAt!),
                        ),

                      SizedBox(height: 24),

                      // Action Buttons
                      FilledButton.icon(
                        onPressed: () =>
                            _showStockAdjustment(context, ref, product),
                        icon: Icon(Icons.add_circle),
                        label: Text(tr('m402')),
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),

                      SizedBox(height: 12),

                      OutlinedButton.icon(
                        onPressed: () =>
                            _viewInventoryHistory(context, ref, product),
                        icon: Icon(Icons.history),
                        label: Text(tr('m340')),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: adaptiveColor(context, Colors.red),
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(_readableError(error), textAlign: TextAlign.center),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(productProvider(productId)),
                child: Text(tr('m381')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _readableError(Object error) {
    if (error is StateError) return error.message.toString();
    if (error is DioException) {
      final data = error.response?.data;
      final code = error.response?.statusCode;
      if (code == 403) {
        if (data is Map &&
            data['error'] is Map &&
            data['error']['code'] == 'subscription_expired') {
          return tr('m326');
        }
        return tr('m79');
      }
      if (code == 409) return tr('m252');
      if (code == 401) return tr('m452');
      if (code == 404) return tr('m254');
      return tr('m442');
    }
    return tr('m279');
  }

  Widget _buildStockStatusBadge(Product product) {
    Color color;
    IconData icon;
    String label;

    switch (product.stockStatus) {
      case 'tugagan':
        color = Colors.red;
        icon = Icons.error;
        label = tr('m557');
        break;
      case 'kam_qolgan':
        color = Colors.orange;
        icon = Icons.warning;
        label = tr('m195');
        break;
      case 'mavjud':
        color = Colors.green;
        icon = Icons.check_circle;
        label = tr('m270');
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
        label = tr('m309');
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.archive),
                title: Text(tr('m34')),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _archiveProduct(context, ref);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: adaptiveColor(context, Colors.red, foreground: true),
                ),
                title: Text(
                  tr('m312'),
                  style: TextStyle(
                    color: adaptiveColor(context, Colors.red, foreground: true),
                  ),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _deleteProduct(context, ref);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _runRemoval(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final route = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(tr('m231'))),
            ],
          ),
        ),
      ),
    );
    navigator.push(route);
    try {
      await action();
    } finally {
      if (route.isActive) navigator.removeRoute(route);
    }
  }

  Future<void> _archiveProduct(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('m263')),
        content: Text(tr('m238')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr('m600')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr('m154')),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await _runRemoval(
          context,
          () => ref.read(productsProvider.notifier).archiveProduct(productId),
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tr('m239')),
              backgroundColor: adaptiveColor(context, Colors.green),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_readableError(e)),
              backgroundColor: adaptiveColor(context, Colors.red),
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteProduct(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('m264')),
        content: Text(tr('m240')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr('m600')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: adaptiveColor(context, Colors.red),
            ),
            child: Text(tr('m156')),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await _runRemoval(
          context,
          () => ref.read(productsProvider.notifier).deleteProduct(productId),
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tr('m247')),
              backgroundColor: adaptiveColor(context, Colors.green),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_readableError(e)),
              backgroundColor: adaptiveColor(context, Colors.red),
            ),
          );
        }
      }
    }
  }

  void _showStockAdjustment(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) {
    showDialog(
      context: context,
      builder: (context) => _StockAdjustmentDialog(product: product),
    );
  }

  void _viewInventoryHistory(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) {
    final history = ref
        .read(apiProvider)
        .getInventoryMovements(productId: product.id);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(tr('m340')),
        content: SizedBox(
          width: 480,
          height: 360,
          child: FutureBuilder<List<dynamic>>(
            future: history,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(_readableError(snapshot.error!)));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final rows = snapshot.data!;
              if (rows.isEmpty) {
                return Center(child: Text(tr('m168')));
              }
              return ListView.separated(
                itemCount: rows.length,
                separatorBuilder: (_, index) => const Divider(),
                itemBuilder: (_, index) {
                  final row = rows[index] as Map;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${row['delta']} ${unitLabel(product.unit)}'),
                    subtitle: Text(
                      '${row['reference'] ?? ''}\n${row['before']} → ${row['after']}\n${row['created_at'] ?? ''}',
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(tr('m601')),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: adaptiveColor(
                  context,
                  Colors.grey[600]!,
                  foreground: true,
                ),
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: adaptiveColor(
                  context,
                  Colors.grey[600]!,
                  foreground: true,
                ),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _StockAdjustmentDialog extends ConsumerStatefulWidget {
  final Product product;

  const _StockAdjustmentDialog({required this.product});

  @override
  ConsumerState<_StockAdjustmentDialog> createState() =>
      _StockAdjustmentDialogState();
}

class _StockAdjustmentDialogState
    extends ConsumerState<_StockAdjustmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _deltaController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isAdding = true;
  bool _isSaving = false;

  String _readableError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      final code = error.response?.statusCode;
      if (code == 403) {
        if (data is Map &&
            data['error'] is Map &&
            data['error']['code'] == 'subscription_expired') {
          return tr('m326');
        }
        return tr('m79');
      }
      if (code == 401) return tr('m452');
      if (code == 404) return tr('m254');
      return tr('m442');
    }
    return tr('m279');
  }

  @override
  void dispose() {
    _deltaController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    return AlertDialog(
      title: Text(tr('m402')),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              tr('m193', [widget.product.stock, widget.product.unit]),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: true,
                        label: Text(tr('m395')),
                        icon: Icon(Icons.add),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text(tr('m43')),
                        icon: Icon(Icons.remove),
                      ),
                    ],
                    selected: {_isAdding},
                    onSelectionChanged: (Set<bool> selection) {
                      setState(() {
                        _isAdding = selection.first;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _deltaController,
              decoration: InputDecoration(
                labelText: tr('m285'),
                border: OutlineInputBorder(),
                suffixText: widget.product.unit,
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return tr('m288');
                }
                final delta = double.tryParse(value);
                if (delta == null || delta <= 0) {
                  return tr('m527');
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: tr('m416'),
                border: OutlineInputBorder(),
                hintText: tr('m175'),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return tr('m420');
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text(tr('m57')),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _saveAdjustment,
          child: _isSaving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(tr('m426')),
        ),
      ],
    );
  }

  Future<void> _saveAdjustment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final delta = double.parse(_deltaController.text);
      final actualDelta = _isAdding ? delta : -delta;

      await ref
          .read(apiProvider)
          .adjustStock(
            widget.product.id,
            actualDelta.toString(),
            _reasonController.text.trim(),
          );

      // Lokal yangilaymiz — sahifa qayta yuklanmaydi
      ref
          .read(productsProvider.notifier)
          .adjustStockLocally(widget.product.id, actualDelta);
      // productProvider ham yangilansin
      ref.invalidate(productProvider(widget.product.id));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: adaptiveColor(context, Colors.white),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                tr('m398', [
                  _isAdding ? "qo'shildi" : "ayrildi",
                  delta.toStringAsFixed(1),
                  widget.product.unit,
                ]),
              ),
            ],
          ),
          backgroundColor: adaptiveColor(context, Colors.green[700]!),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_readableError(e)),
          backgroundColor: adaptiveColor(context, Colors.red[700]!),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
