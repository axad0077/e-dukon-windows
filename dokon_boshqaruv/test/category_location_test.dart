import 'package:flutter_test/flutter_test.dart';
import 'package:dokon_boshqaruv/features/products/models/product.dart';

void main() {
  final old = <String, dynamic>{
    'id': 1,
    'name': 'Quloqchin',
    'sku': 'P1',
    'sale_price': '10000',
    'stock': '2',
    'purchase_price': '5000',
    'unit': 'dona',
    'min_stock': '0',
  };
  test('old cache remains readable without location fields', () {
    final product = Product.fromJson(old);
    expect(product.locationLabel, isEmpty);
  });
  test(
    'location and category survive cache roundtrip and stock adjustment',
    () {
      final product = Product.fromJson({
        ...old,
        'category': 3,
        'category_name': 'Elektronika',
        'warehouse': 'Asosiy ombor',
        'section': 'B',
        'shelf': '3-polka',
      });
      final restored = Product.fromJson(product.copyWith(stock: '1').toJson());
      expect(restored.locationLabel, 'Asosiy ombor → B → 3-polka');
      expect(restored.categoryName, 'Elektronika');
      expect(restored.stock, '1');
    },
  );
  test('Barchasi clears category while preserving other filters', () {
    final filters = ProductFilters(
      categoryId: 4,
      searchQuery: 'telefon',
      minPrice: 10,
    );
    final all = filters.copyWith(categoryId: null);
    expect(all.categoryId, isNull);
    expect(all.searchQuery, 'telefon');
    expect(all.minPrice, 10);
    expect(all.copyWith(minPrice: null).minPrice, isNull);
    expect(filters.copyWith(sortAscending: false).categoryId, 4);
  });
}
