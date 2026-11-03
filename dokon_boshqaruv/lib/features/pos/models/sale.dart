class Sale {
  final String id;
  final String operationId;
  final double subtotal;
  final double discount;
  final double total;
  final double cash;
  final double card;
  final DateTime createdAt;
  final List<SaleItemDetail> items;

  Sale({
    required this.id,
    required this.operationId,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.cash,
    required this.card,
    required this.createdAt,
    required this.items,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as String,
      operationId: json['operation_id'] as String,
      subtotal: double.parse(json['subtotal'].toString()),
      discount: double.parse(json['discount'].toString()),
      total: double.parse(json['total'].toString()),
      cash: double.parse(json['cash'].toString()),
      card: double.parse(json['card'].toString()),
      createdAt: DateTime.parse(json['created_at'] as String),
      items: (json['items'] as List?)
              ?.map((item) => SaleItemDetail.fromJson(item))
              .toList() ??
          [],
    );
  }

  String get receiptNumber => id.substring(0, 8).toUpperCase();
}

class SaleItemDetail {
  final int productId;
  final String name;
  final double quantity;
  final double unitPrice;
  final double lineTotal;

  SaleItemDetail({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory SaleItemDetail.fromJson(Map<String, dynamic> json) {
    return SaleItemDetail(
      productId: json['product_id'] as int,
      name: json['name'] as String,
      quantity: double.parse(json['quantity'].toString()),
      unitPrice: double.parse(json['unit_price'].toString()),
      lineTotal: double.parse(json['line_total'].toString()),
    );
  }
}
