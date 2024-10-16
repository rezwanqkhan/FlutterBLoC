import 'package:bloc/models/cart.dart';

class CartService {
  static List<Cart> cartitems = List.empty(growable: true);

  static final CartService _singlton = CartService._internal();

  factory CartService() {
    return _singlton;
  }

  CartService._internal();

  static void addCart(Cart item) {
    cartitems.add(item);
  }

  static void removeCart(Cart item) {
    cartitems.remove(item);
  }

  static List<Cart> getCart() {
    return cartitems;
  }
}
