import '../widgets/category_picker.dart';
import '../widgets/product_location_fields.dart';
import '../../../src/adaptive_colors.dart';
import '../../../src/l10n/app_strings.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/products_provider.dart';
import '../widgets/barcode_scanner_dialog.dart';
import '../widgets/image_picker_widget.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  String? _imagePath;
  final _warehouseController = TextEditingController();
  final _sectionController = TextEditingController();
  final _shelfController = TextEditingController();

  // Controllers
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _minStockController = TextEditingController(text: '0');
  final _descriptionController = TextEditingController();

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
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _descriptionController.dispose();
    _warehouseController.dispose();
    _sectionController.dispose();
    _shelfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(title: Text(tr('m581'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Product Image Section
            _SectionHeader(title: tr('m249'), icon: Icons.image),
            SizedBox(height: 16),
            ImagePickerWidget(
              initialImagePath: _imagePath,
              onImageSelected: (path) {
                setState(() {
                  _imagePath = path;
                });
              },
            ),
            SizedBox(height: 24),

            // Basic Information Section
            _SectionHeader(title: tr('m35'), icon: Icons.info_outline),
            SizedBox(height: 16),

            if (isSmallScreen) ...[
              // Mobile layout - single column
              _buildNameField(),
              SizedBox(height: 16),
              _buildSKUField(),
              SizedBox(height: 16),
              _buildBarcodeField(),
            ] else ...[
              // Desktop layout - two columns
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

            CategoryPicker(
              value: _selectedCategoryId,
              onChanged: (id) => setState(() => _selectedCategoryId = id),
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
                  final sale = double.tryParse(_salePriceController.text) ?? 0;

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
            _SectionHeader(title: tr('m337'), icon: Icons.storage),
            SizedBox(height: 16),

            if (isSmallScreen) ...[
              _buildStockField(),
              SizedBox(height: 16),
              _buildMinStockField(),
              SizedBox(height: 16),
              _buildUnitField(),
            ] else ...[
              Row(
                children: [
                  Expanded(child: _buildStockField()),
                  SizedBox(width: 16),
                  Expanded(child: _buildMinStockField()),
                  SizedBox(width: 16),
                  Expanded(child: _buildUnitField()),
                ],
              ),
            ],

            SizedBox(height: 8),
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
                        tr('m72'),
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

            SizedBox(height: 32),

            // Save Button
            FilledButton(
              onPressed: _isSaving ? null : _saveProduct,
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
                  : Text(tr('m265')),
            ),

            SizedBox(height: 16),

            OutlinedButton(
              onPressed: _isSaving ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(tr('m57')),
            ),

            SizedBox(height: 32),
          ],
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
        suffixIcon: IconButton(
          icon: Icon(Icons.auto_fix_high),
          onPressed: _generateSKU,
          tooltip: tr('m41'),
        ),
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

  bool get _fractionalUnit =>
      {'kg', 'gramm', 'litr', 'ml', 'metr', 'm²', 'm³'}.contains(_selectedUnit);

  Widget _buildStockField() {
    return TextFormField(
      controller: _stockController,
      decoration: InputDecoration(
        labelText: tr('m71'),
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.inventory),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
      ],
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final stock = double.tryParse(value);
          if (stock == null ||
              stock < 0 ||
              (!_fractionalUnit && stock != stock.truncateToDouble())) {
            return tr('m527');
          }
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
          if (minStock == null ||
              minStock < 0 ||
              (!_fractionalUnit && minStock != minStock.truncateToDouble())) {
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
            _formKey.currentState?.validate();
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

  void _generateSKU() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final sku = 'PRD${timestamp.substring(timestamp.length - 8)}';
    _skuController.text = sku;
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
        'category': _selectedCategoryId,
        'warehouse': _warehouseController.text.trim(),
        'section': _sectionController.text.trim(),
        'shelf': _shelfController.text.trim(),
        'name': _nameController.text.trim(),
        'sku': _skuController.text.trim(),
        'barcode': _barcodeController.text.trim().isEmpty
            ? null
            : _barcodeController.text.trim(),
        'purchase_price': _purchasePriceController.text.isEmpty
            ? '0'
            : _purchasePriceController.text,
        'sale_price': _salePriceController.text,
        'initial_stock': _stockController.text.isEmpty
            ? '0'
            : _stockController.text,
        'min_stock': _minStockController.text.isEmpty
            ? '0'
            : _minStockController.text,
        'unit': _selectedUnit,
        'active': true,
      };

      await ref
          .read(productsProvider.notifier)
          .addProduct(data, imagePath: _imagePath);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('m244')),
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
