class CartItem {
  final int productId;
  final String name;
  final String sku;
  final double salePrice;
  final double availableStock;
  final String unit;
  double quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.sku,
    required this.salePrice,
    required this.availableStock,
    required this.unit,
    this.quantity = 1.0,
  });

  int get salePriceCents => (salePrice * 100).round();
  int get quantityMilli => (quantity * 1000).round();
  int get lineTotalCents => (salePriceCents * quantityMilli + 500) ~/ 1000;
  double get lineTotal => lineTotalCents / 100;

  bool canIncrement() =>
      (quantityMilli + 1000) <= (availableStock * 1000).round();

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'quantity': quantity.toStringAsFixed(3),
      };
}
