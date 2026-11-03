import '../widgets/category_picker.dart';
import '../widgets/product_location_fields.dart';
import '../../../src/adaptive_colors.dart';
import '../../../src/l10n/app_strings.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/products_provider.dart';
import '../models/product.dart';
import '../widgets/barcode_scanner_dialog.dart';
import '../widgets/image_picker_widget.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _hasChanges = false;
  String? _imagePath;
  final _warehouseController = TextEditingController();
  final _sectionController = TextEditingController();
  final _shelfController = TextEditingController();

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _salePriceController;
  late final TextEditingController _minStockController;

  int? _selectedCategoryId;
  String _selectedUnit = 'dona';

  final List<String> _units = [
    'dona',
    'kg',
    'litr',
    'metr',
    'quti',
    'paket',
    'pachka',
    'butilka',
    'gramm',
    'ml',
    'm²',
    'm³',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing values
    _nameController = TextEditingController(text: widget.product.name);
    _skuController = TextEditingController(text: widget.product.sku);
    _barcodeController = TextEditingController(
      text: widget.product.barcode ?? '',
    );
    _purchasePriceController = TextEditingController(
      text: widget.product.purchasePrice,
    );
    _salePriceController = TextEditingController(
      text: widget.product.salePrice,
    );
    _minStockController = TextEditingController(text: widget.product.minStock);

    _warehouseController.text = widget.product.warehouse;
    _sectionController.text = widget.product.section;
    _shelfController.text = widget.product.shelf;
    for (final c in [
      _warehouseController,
      _sectionController,
      _shelfController,
    ]) {
      c.addListener(_markChanged);
    }
    _selectedCategoryId = widget.product.categoryId;
    _selectedUnit = widget.product.unit;

    // Track changes
    _nameController.addListener(_markChanged);
    _skuController.addListener(_markChanged);
    _barcodeController.addListener(_markChanged);
    _purchasePriceController.addListener(_markChanged);
    _salePriceController.addListener(_markChanged);
    _minStockController.addListener(_markChanged);
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _minStockController.dispose();
    _warehouseController.dispose();
    _sectionController.dispose();
    _shelfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await _confirmDiscard();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(tr('m266'))),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Product Image Section
              _SectionHeader(title: tr('m249'), icon: Icons.image),
              SizedBox(height: 16),
              ImagePickerWidget(
                initialImagePath: _imagePath ?? widget.product.image,
                onImageSelected: (path) {
                  setState(() {
                    _imagePath = path;
                    _markChanged();
                  });
                },
              ),
              SizedBox(height: 24),

              // Info banner
              Card(
                color: adaptiveColor(context, Colors.blue[50]!),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: adaptiveColor(context, Colors.blue[700]!),
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tr('m401'),
                          style: TextStyle(
                            fontSize: 12,
                            color: adaptiveColor(
                              context,
                              Colors.blue[900]!,
                              foreground: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Basic Information Section
              _SectionHeader(title: tr('m35'), icon: Icons.info_outline),
              SizedBox(height: 16),

              if (isSmallScreen) ...[
                _buildNameField(),
                SizedBox(height: 16),
                _buildSKUField(),
                SizedBox(height: 16),
                _buildBarcodeField(),
              ] else ...[
                Row(
                  children: [
                    Expanded(child: _buildNameField()),
                    SizedBox(width: 16),
                    Expanded(child: _buildSKUField()),
                  ],
                ),
                SizedBox(height: 16),
                _buildBarcodeField(),
              ],

              SizedBox(height: 24),

              // Category Section
              _SectionHeader(title: tr('m212'), icon: Icons.category_outlined),
              SizedBox(height: 16),

              CategoryPicker(
                value: _selectedCategoryId,
                onChanged: (id) {
                  setState(() => _selectedCategoryId = id);
                  _markChanged();
                },
              ),
              const SizedBox(height: 16),
              ProductLocationFields(
                warehouse: _warehouseController,
                section: _sectionController,
                shelf: _shelfController,
              ),
              const SizedBox(height: 24),

              // Pricing Section
              _SectionHeader(title: tr('m307'), icon: Icons.attach_money),
              SizedBox(height: 16),

              if (isSmallScreen) ...[
                _buildPurchasePriceField(),
                SizedBox(height: 16),
                _buildSalePriceField(),
              ] else ...[
                Row(
                  children: [
                    Expanded(child: _buildPurchasePriceField()),
                    SizedBox(width: 16),
                    Expanded(child: _buildSalePriceField()),
                  ],
                ),
              ],

              // Price warning
              if (_purchasePriceController.text.isNotEmpty &&
                  _salePriceController.text.isNotEmpty)
                Builder(
                  builder: (context) {
                    final purchase =
                        double.tryParse(_purchasePriceController.text) ?? 0;
                    final sale =
                        double.tryParse(_salePriceController.text) ?? 0;

                    if (sale > 0 && sale < purchase) {
                      return Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Card(
                          color: adaptiveColor(context, Colors.orange[50]!),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: adaptiveColor(
                                    context,
                                    Colors.orange[700]!,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    tr('m473'),
                                    style: TextStyle(
                                      color: adaptiveColor(
                                        context,
                                        Colors.orange[900]!,
                                        foreground: true,
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
                    return SizedBox.shrink();
                  },
                ),

              SizedBox(height: 24),

              // Inventory Section
              _SectionHeader(title: tr('m338'), icon: Icons.storage),
              SizedBox(height: 16),

              // Current stock (read-only)
              TextFormField(
                initialValue:
                    '${widget.product.stock} ${unitLabel(widget.product.unit)}',
                decoration: InputDecoration(
                  labelText: tr('m191'),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                  enabled: false,
                ),
              ),

              SizedBox(height: 16),

              if (isSmallScreen) ...[
                _buildMinStockField(),
                SizedBox(height: 16),
                _buildUnitField(),
              ] else ...[
                Row(
                  children: [
                    Expanded(child: _buildMinStockField()),
                    SizedBox(width: 16),
                    Expanded(child: _buildUnitField()),
                  ],
                ),
              ],

              SizedBox(height: 32),

              // Save Button
              FilledButton(
                onPressed: _isSaving || !_hasChanges ? null : _saveProduct,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: adaptiveColor(context, Colors.white),
                        ),
                      )
                    : Text(tr('m319')),
              ),

              SizedBox(height: 16),

              OutlinedButton(
                onPressed: _isSaving
                    ? null
                    : () async {
                        if (_hasChanges) {
                          final shouldPop = await _confirmDiscard();
                          if (shouldPop && context.mounted) {
                            Navigator.pop(context);
                          }
                        } else {
                          Navigator.pop(context);
                        }
                      },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(tr('m57')),
              ),

              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: tr('m245'),
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.inventory_2),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return tr('m246');
        }
        return null;
      },
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildSKUField() {
    return TextFormField(
      controller: _skuController,
      decoration: InputDecoration(
        labelText: tr('m242'),
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.qr_code),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return tr('m415');
        }
        return null;
      },
      textCapitalization: TextCapitalization.characters,
    );
  }

  Widget _buildBarcodeField() {
    return TextFormField(
      controller: _barcodeController,
      decoration: InputDecoration(
        labelText: tr('m455'),
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.barcode_reader),
        helperText: tr('m181'),
        suffixIcon: IconButton(
          icon: Icon(Icons.qr_code_scanner),
          onPressed: () async {
            final barcode = await showDialog<String>(
              context: context,
              builder: (context) => BarcodeScannerDialog(),
            );
            if (barcode != null) {
              _barcodeController.text = barcode;
              _markChanged();
            }
          },
          tooltip: tr('m466'),
        ),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildPurchasePriceField() {
    return TextFormField(
      controller: _purchasePriceController,
      decoration: InputDecoration(
        labelText: tr('m574'),
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.shopping_cart),
        suffixText: 'UZS',
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final price = double.tryParse(value);
          if (price == null || price < 0) {
            return tr('m528');
          }
        }
        return null;
      },
    );
  }

  Widget _buildSalePriceField() {
    return TextFormField(
      controller: _salePriceController,
      decoration: InputDecoration(
        labelText: tr('m472'),
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.sell),
        suffixText: 'UZS',
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return tr('m474');
        }
        final price = double.tryParse(value);
        if (price == null || price <= 0) {
          return tr('m528');
        }
        return null;
      },
    );
  }

  Widget _buildMinStockField() {
    return TextFormField(
      controller: _minStockController,
      decoration: InputDecoration(
        labelText: tr('m284'),
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.warning_amber),
        helperText: tr('m335'),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
      ],
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final minStock = double.tryParse(value);
          if (minStock == null || minStock < 0) {
            return tr('m527');
          }
        }
        return null;
      },
    );
  }

  Widget _buildUnitField() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: InputDecoration(
        labelText: tr('m314'),
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.straighten),
      ),
      initialValue: _selectedUnit,
      items: _units.map((unit) {
        return DropdownMenuItem(value: unit, child: Text(unitLabel(unit)));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedUnit = value;
            _markChanged();
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return tr('m62');
        }
        return null;
      },
    );
  }

  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('m318')),
        content: Text(tr('m427')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr('m386')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: adaptiveColor(context, Colors.red),
            ),
            child: Text(tr('m57')),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final data = {
        'warehouse': _warehouseController.text.trim(),
        'section': _sectionController.text.trim(),
        'shelf': _shelfController.text.trim(),
        'name': _nameController.text.trim(),
        'sku': _skuController.text.trim(),
        'barcode': _barcodeController.text.trim().isEmpty
            ? null
            : _barcodeController.text.trim(),
        'category': _selectedCategoryId,
        'purchase_price': _purchasePriceController.text.isEmpty
            ? '0'
            : _purchasePriceController.text,
        'sale_price': _salePriceController.text,
        'min_stock': _minStockController.text.isEmpty
            ? '0'
            : _minStockController.text,
        'unit': _selectedUnit,
        'active': widget.product.active,
      };

      await ref
          .read(productsProvider.notifier)
          .updateProduct(widget.product.id, data, imagePath: _imagePath);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('m317')),
          backgroundColor: adaptiveColor(context, Colors.green),
        ),
      );

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friendlyFailure(e)),
          backgroundColor: adaptiveColor(context, Colors.red),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    return Row(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
