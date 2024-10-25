import 'dart:async';
import 'package:bloc/data/cart_service.dart';
import 'package:bloc/models/cart.dart';

class CartBloc {
  final cartstreamController = StreamController.broadcast();

  Stream get cartStream => cartstreamController.stream;

  void addToCart(Cart item) {
    CartService.addCart(item);
    cartstreamController.sink.add(CartService.getCart());
  }

  void removeFromCart(Cart item) {
    CartService.removeCart(item);
    cartstreamController.sink.add(CartService.getCart());
  }

  List<Cart> getCart() {
    return CartService.getCart();
  }

  void decreaseQuantity(Cart cart) {
    CartService.decreaseQuantity(cart);
    cartstreamController.sink.add(CartService.getCart());
  }

  void incrementQuantity(Cart cart) {
    CartService.incrementQuantity(cart);
    cartstreamController.sink.add(CartService.getCart());
  }

  void clearCart() {
    CartService.clearCart();
    cartstreamController.sink.add(CartService.getCart());
  }
}

final cartBloc = CartBloc();
