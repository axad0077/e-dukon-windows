import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../../products/models/product.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  bool addProduct(Product product, {double quantity = 1.0}) {
    if (!quantity.isFinite ||
        !(quantity * 1000).isFinite ||
        quantity <= 0 ||
        (quantity * 1000).round() <= 0 ||
        (quantity * 1000 - (quantity * 1000).round()).abs() > 0.000001 ||
        (!{'kg', 'gramm', 'litr', 'ml', 'metr', 'm²', 'm³'}
                .contains(product.unit) &&
            quantity != quantity.truncateToDouble())) {
      return false;
    }
    final existingIndex =
        state.indexWhere((item) => item.productId == product.id);

    if (existingIndex != -1) {
      // Update existing item
      final updatedState = [...state];
      final existingItem = updatedState[existingIndex];
      final currentStock = double.tryParse(product.stock) ?? 0;
      final newQuantity =
          (existingItem.quantityMilli + (quantity * 1000).round()) / 1000;

      if (currentStock.isFinite &&
          (newQuantity * 1000).round() <= (currentStock * 1000).round()) {
        updatedState[existingIndex] = CartItem(
          productId: existingItem.productId,
          name: existingItem.name,
          sku: existingItem.sku,
          salePrice: existingItem.salePrice,
          availableStock: currentStock,
          unit: existingItem.unit,
          quantity: (newQuantity * 1000).round() / 1000,
        );
        state = updatedState;
        return true;
      }
      return false;
    } else {
      // Add new item
      final currentStock = double.tryParse(product.stock) ?? 0;
      if (currentStock.isFinite &&
          (quantity * 1000).round() <= (currentStock * 1000).round()) {
        state = [
          ...state,
          CartItem(
            productId: product.id,
            name: product.name,
            sku: product.sku,
            salePrice: double.tryParse(product.salePrice) ?? 0,
            availableStock: currentStock,
            unit: product.unit,
            quantity: (quantity * 1000).round() / 1000,
          ),
        ];
        return true;
      }
      return false;
    }
  }

  void updateQuantity(int productId, double newQuantity) {
    if (newQuantity == 0) {
      removeProduct(productId);
      return;
    }
    if (!newQuantity.isFinite ||
        !(newQuantity * 1000).isFinite ||
        newQuantity <= 0 ||
        (newQuantity * 1000).round() <= 0 ||
        (newQuantity * 1000 - (newQuantity * 1000).round()).abs() > 0.000001) {
      return;
    }
    final selected =
        state.where((item) => item.productId == productId).toList();
    if (selected.isNotEmpty &&
        !{'kg', 'gramm', 'litr', 'ml', 'metr', 'm²', 'm³'}
            .contains(selected.first.unit) &&
        newQuantity != newQuantity.truncateToDouble()) {
      return;
    }
    final updatedState = state.map((item) {
      if (item.productId == productId) {
        if (item.availableStock.isFinite &&
            (newQuantity * 1000).round() <=
                (item.availableStock * 1000).round()) {
          return CartItem(
            productId: item.productId,
            name: item.name,
            sku: item.sku,
            salePrice: item.salePrice,
            availableStock: item.availableStock,
            unit: item.unit,
            quantity: (newQuantity * 1000).round() / 1000,
          );
        }
      }
      return item;
    }).toList();

    state = updatedState;
  }

  void incrementQuantity(int productId) {
    final updatedState = state.map((item) {
      if (item.productId == productId && item.canIncrement()) {
        return CartItem(
          productId: item.productId,
          name: item.name,
          sku: item.sku,
          salePrice: item.salePrice,
          availableStock: item.availableStock,
          unit: item.unit,
          quantity: item.quantity + 1,
        );
      }
      return item;
    }).toList();

    state = updatedState;
  }

  void decrementQuantity(int productId) {
    final matches = state.where((item) => item.productId == productId);
    if (matches.isEmpty) return;
    final item = matches.first;
    if (item.quantity <= 1) {
      removeProduct(productId);
    } else {
      updateQuantity(productId, item.quantity - 1);
    }
  }

  void removeProduct(int productId) {
    state = state.where((item) => item.productId != productId).toList();
  }

  void clear() {
    state = [];
  }

  int get subtotalCents =>
      state.fold(0, (sum, item) => sum + item.lineTotalCents);
  double get subtotal => subtotalCents / 100;

  int get itemCount => state.length;

  bool get isEmpty => state.isEmpty;

  bool get isNotEmpty => state.isNotEmpty;
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final cartSubtotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  final cents = cart.fold(0, (sum, item) => sum + item.lineTotalCents);
  return cents / 100;
});

final cartSubtotalCentsProvider = Provider<int>((ref) {
  return ref
      .watch(cartProvider)
      .fold(0, (sum, item) => sum + item.lineTotalCents);
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).length;
});
