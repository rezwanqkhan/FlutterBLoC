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

  static void decreaseQuantity(Cart cart) {
    final index =
        cartitems.indexWhere((item) => item.quantity == cart.quantity);
    if (index != -1 && cartitems[index].quantity > 1) {
      cartitems[index].quantity--;
    } else {
      removeCart(cart);
    }
  }

  static void incrementQuantity(Cart cart) {
    final index =
        cartitems.indexWhere((item) => item.quantity == cart.quantity);
    if (index != -1) {
      cartitems[index].quantity++;
    }
  }

  static void clearCart() {
    cartitems.clear();
  }
}
