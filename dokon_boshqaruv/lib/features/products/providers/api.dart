// Yagona API va queue provider'lari `lib/src/app.dart` da e'lon qilinadi.
// Bu fayl faqat POS uchun extension va products provider'ini ta'minlaydi.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../src/app.dart' show apiProvider;
import '../../../src/api.dart';
import '../models/product.dart';
import '../../pos/models/sale.dart';

// app.dart dagi yagona apiProvider ni re-eksport qilamiz.
export '../../../src/app.dart' show apiProvider, queueProvider;

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final api = ref.watch(apiProvider);
  final data = await api.products();
  return data.map((json) => Product.fromJson(json)).toList();
});

// POS uchun Api kengaytmasi (extension).
extension ApiPosExtension on Api {
  Future<Sale> createSalePOS({
    required List<Map<String, dynamic>> items,
    required double cash,
    required double card,
    required double discount,
    required String operationId,
    double? debt,
    String? customerName,
    String? customerPhone,
  }) async {
    final data = await posCreateSale(
      items: items,
      cash: cash,
      card: card,
      discount: discount,
      operationId: operationId,
      debt: debt,
      customerName: customerName,
      customerPhone: customerPhone,
    );
    return Sale.fromJson(data);
  }

  Future<List<Sale>> getSalesList() async {
    final data = await posSalesList();
    return data
        .map((json) => Sale.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
