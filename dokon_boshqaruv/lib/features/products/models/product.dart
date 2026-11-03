import '../../../src/l10n/translations.dart';

class Product {
  final int id;
  final String name;
  final String sku;
  final String? barcode;
  final int? categoryId;
  final String? categoryName;
  final String purchasePrice;
  final String salePrice;
  final String stock;
  final String unit;
  final String minStock;
  final bool active;
  final String? image;
  final String warehouse;
  final String section;
  final String shelf;
  String get locationLabel =>
      [warehouse, section, shelf].where((v) => v.trim().isNotEmpty).join(' → ');
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    this.barcode,
    this.categoryId,
    this.categoryName,
    required this.purchasePrice,
    required this.salePrice,
    required this.stock,
    required this.unit,
    required this.minStock,
    this.active = true,
    this.image,
    this.warehouse = '',
    this.section = '',
    this.shelf = '',
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      sku: json['sku'] as String,
      barcode: json['barcode'] as String?,
      categoryId: json['category'] as int?,
      categoryName: json['category_name'] as String?,
      purchasePrice: json['purchase_price']?.toString() ?? '0',
      salePrice: json['sale_price']?.toString() ?? '0',
      stock: json['stock']?.toString() ?? '0',
      unit: json['unit'] as String? ?? 'dona',
      minStock: json['min_stock']?.toString() ?? '0',
      active: json['active'] as bool? ?? true,
      image: json['image'] as String?,
      warehouse: json['warehouse']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      shelf: json['shelf']?.toString() ?? '',
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'category': categoryId,
      'purchase_price': purchasePrice,
      'sale_price': salePrice,
      'stock': stock,
      'unit': unit,
      'min_stock': minStock,
      'image': image,
      'category_name': categoryName,
      'warehouse': warehouse,
      'section': section,
      'shelf': shelf,
      'active': active,
    };
  }

  // Stock status calculation
  String get stockStatus {
    final stockNum = double.tryParse(stock) ?? 0;
    final minStockNum = double.tryParse(minStock) ?? 0;

    if (stockNum <= 0) return 'tugagan';
    if (stockNum <= minStockNum) return 'kam_qolgan';
    return 'mavjud';
  }

  String get stockStatusLabel {
    switch (stockStatus) {
      case 'tugagan':
        return tr('m557');
      case 'kam_qolgan':
        return tr('m195');
      case 'mavjud':
        return tr('m270');
      default:
        return tr('m309');
    }
  }

  Product copyWith({
    int? id,
    String? name,
    String? sku,
    String? barcode,
    int? categoryId,
    String? categoryName,
    String? purchasePrice,
    String? salePrice,
    String? stock,
    String? unit,
    String? minStock,
    bool? active,
    String? image,
    String? warehouse,
    String? section,
    String? shelf,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      minStock: minStock ?? this.minStock,
      active: active ?? this.active,
      image: image ?? this.image,
      warehouse: warehouse ?? this.warehouse,
      section: section ?? this.section,
      shelf: shelf ?? this.shelf,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'] as int, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class ProductFilters {
  static const _unset = Object();
  final String? searchQuery;
  final int? categoryId;
  final String? stockStatus; // 'all', 'mavjud', 'kam_qolgan', 'tugagan'
  final double? minPrice;
  final double? maxPrice;
  final String sortBy; // 'name', 'sale_price', 'purchase_price', 'stock'
  final bool sortAscending;

  ProductFilters({
    this.searchQuery,
    this.categoryId,
    this.stockStatus,
    this.minPrice,
    this.maxPrice,
    this.sortBy = 'name',
    this.sortAscending = true,
  });

  bool get hasActiveFilters {
    return searchQuery != null && searchQuery!.isNotEmpty ||
        categoryId != null ||
        (stockStatus != null && stockStatus != 'all') ||
        minPrice != null ||
        maxPrice != null;
  }

  ProductFilters copyWith({
    String? searchQuery,
    Object? categoryId = _unset,
    String? stockStatus,
    Object? minPrice = _unset,
    Object? maxPrice = _unset,
    String? sortBy,
    bool? sortAscending,
  }) {
    return ProductFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as int?,
      stockStatus: stockStatus ?? this.stockStatus,
      minPrice: identical(minPrice, _unset)
          ? this.minPrice
          : minPrice as double?,
      maxPrice: identical(maxPrice, _unset)
          ? this.maxPrice
          : maxPrice as double?,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  ProductFilters clearFilters() {
    return ProductFilters(sortBy: sortBy, sortAscending: sortAscending);
  }
}

class ProductSummary {
  final int totalProducts;
  final double totalStock;
  final int lowStockCount;
  final int outOfStockCount;

  ProductSummary({
    required this.totalProducts,
    required this.totalStock,
    required this.lowStockCount,
    required this.outOfStockCount,
  });

  factory ProductSummary.fromProducts(List<Product> products) {
    double totalStock = 0;
    int lowStockCount = 0;
    int outOfStockCount = 0;

    for (final product in products) {
      final stock = double.tryParse(product.stock) ?? 0;
      totalStock += stock;

      if (product.stockStatus == 'kam_qolgan') {
        lowStockCount++;
      } else if (product.stockStatus == 'tugagan') {
        outOfStockCount++;
      }
    }

    return ProductSummary(
      totalProducts: products.length,
      totalStock: totalStock,
      lowStockCount: lowStockCount,
      outOfStockCount: outOfStockCount,
    );
  }
}
