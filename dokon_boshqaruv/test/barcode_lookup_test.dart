import 'package:dokon_boshqaruv/features/pos/utils/product_lookup.dart';
import 'package:dokon_boshqaruv/features/products/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('barcode and sku values are normalized for scanning', () {
    expect(normalizeProductCode('  12345\n '), '12345');
    expect(normalizeProductCode('ab-12 34'), 'AB1234');
  });

  test(
      'product lookup matches barcode or sku ignoring whitespace and separators',
      () {
    final products = [
      Product(
        id: 1,
        name: 'Qahva',
        sku: 'sku-007',
        barcode: ' 12-34 56 ',
        purchasePrice: '1000',
        salePrice: '2000',
        stock: '12',
        unit: 'dona',
        minStock: '2',
      ),
      Product(
        id: 2,
        name: 'Suv',
        sku: 'sku-010',
        barcode: null,
        purchasePrice: '1500',
        salePrice: '2500',
        stock: '8',
        unit: 'dona',
        minStock: '1',
      ),
    ];

    expect(findProductByCode(products, '123456'), isNotNull);
    expect(findProductByCode(products, 'SKU-007'), isNotNull);
    expect(findProductByCode(products, 'sku-010'), isNotNull);
    expect(findProductByCode(products, '999999'), isNull);
  });
}
