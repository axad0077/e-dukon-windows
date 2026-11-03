import '../../products/models/product.dart';

String normalizeProductCode(String? value) {
  if (value == null) return '';
  final compact = value
      .trim()
      .replaceAll(RegExp(r'[\s_\-\./\\]+'), '')
      .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
      .toUpperCase();
  return compact;
}

Product? findProductByCode(List<Product> products, String rawCode) {
  final code = normalizeProductCode(rawCode);
  if (code.isEmpty) return null;

  for (final product in products) {
    if (!product.active) continue;

    final matches = <String>{
      normalizeProductCode(product.barcode),
      normalizeProductCode(product.sku),
    };

    if (matches.contains(code)) {
      return product;
    }
  }

  return null;
}
