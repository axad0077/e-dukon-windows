import 'package:flutter_test/flutter_test.dart';
import 'package:dokon_boshqaruv/features/pos/providers/cart_provider.dart';
import 'package:dokon_boshqaruv/features/products/models/product.dart';

void main() {
  Product product(
          {String unit = 'dona', String stock = '5', String price = '1.01'}) =>
      Product(
        id: 1,
        name: 'Sinov mahsuloti',
        sku: 'TEST-1',
        barcode: '123456789',
        purchasePrice: '0.50',
        salePrice: price,
        stock: stock,
        unit: unit,
        minStock: '1',
      );

  test('bir xil mahsulot qayta qo‘shilganda qator va miqdor birlashtiriladi',
      () {
    final cart = CartNotifier();
    expect(cart.addProduct(product()), isTrue);
    expect(cart.addProduct(product()), isTrue);
    expect(cart.state, hasLength(1));
    expect(cart.state.single.quantity, 2);
    expect(cart.state.single.lineTotalCents, 202);
  });

  test('miqdor ombor chegarasidan oshmaydi va musbat bo‘lishi kerak', () {
    final cart = CartNotifier();
    cart.addProduct(product(stock: '2'));
    cart.updateQuantity(1, 3);
    expect(cart.state.single.quantity, 1);
    cart.updateQuantity(1, 0);
    expect(cart.state, isEmpty);
  });

  test('kasrli birlik uchun qator summasi sentga yaxlitlanadi', () {
    final cart = CartNotifier();
    cart.addProduct(product(unit: 'kg', price: '2.50', stock: '5'),
        quantity: 1.255);
    expect(cart.state.single.lineTotalCents, 314);
  });
  test('kasrli qoldiqda +1 ombor chegarasini buzmaydi', () {
    final cart = CartNotifier();
    cart.addProduct(product(unit: 'kg', stock: '1.5'));
    expect(cart.state.single.canIncrement(), isFalse);
    cart.incrementQuantity(1);
    expect(cart.state.single.quantity, 1);
    cart.decrementQuantity(999);
    expect(cart.state.single.quantity, 1);
  });
  test('miqdor oshirish, kamaytirish va tozalash', () {
    final cart = CartNotifier();
    cart.addProduct(product());
    cart.incrementQuantity(1);
    expect(cart.state.single.quantity, 2);
    cart.updateQuantity(1, 4);
    cart.decrementQuantity(1);
    expect(cart.state.single.quantity, 3);
    expect(cart.subtotalCents, 303);
    expect(cart.state.single.toJson()['quantity'], '3.000');
    cart.clear();
    expect(cart.state, isEmpty);
  });

  test('decimal quantity is normalized to three places without binary drift',
      () {
    final cart = CartNotifier();
    expect(cart.addProduct(product(unit: 'kg', stock: '5'), quantity: 1.001),
        isTrue);
    expect(cart.addProduct(product(unit: 'kg', stock: '5'), quantity: .009),
        isTrue);
    expect(cart.state.single.quantity, 1.010);
    cart.updateQuantity(1, 1.003);
    expect(cart.state.single.quantityMilli, 1003);
    expect(cart.addProduct(product(unit: 'kg'), quantity: .0001), isFalse);
    expect(
        cart.addProduct(product(unit: 'kg'), quantity: .0000000001), isFalse);
    expect(cart.addProduct(product(unit: 'kg'), quantity: double.infinity),
        isFalse);
  });
}
