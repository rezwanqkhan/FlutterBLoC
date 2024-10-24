import 'package:bloc/models/cart.dart';

/// Service class to handle cart-related operations and manage cart items.
class CartService {
  // A growable list that holds the cart items.
  static List<Cart> cartitems = List.empty(growable: true);

  // Singleton instance of the CartService class.
  static final CartService _singlton = CartService._internal();

  // Factory constructor to return the singleton instance.
  factory CartService() {
    return _singlton;
  }

  // Internal named constructor for creating the singleton instance.
  CartService._internal();

  /// Adds an item to the cart.
  static void addCart(Cart item) {
    cartitems.add(item); // Adds the item to the cart list.
  }

  /// Removes an item from the cart.
  static void removeCart(Cart item) {
    cartitems.remove(item); // Removes the item from the cart list.
  }

  /// Returns the current list of cart items.
  static List<Cart> getCart() {
    return cartitems; // Returns all items in the cart.
  }

  /// Decreases the quantity of a specific item in the cart.
  /// If the quantity reaches 1, the item is removed from the cart.
  static void decreaseQuantity(Cart cart) {
    final index =
        cartitems.indexWhere((item) => item.quantity == cart.quantity);
    if (index != -1 && cartitems[index].quantity > 1) {
      cartitems[index].quantity--; // Decreases the quantity.
    } else {
      removeCart(cart); // Removes the item if the quantity is 1.
    }
  }

  /// Increases the quantity of a specific item in the cart.
  static void incrementQuantity(Cart cart) {
    final index =
        cartitems.indexWhere((item) => item.quantity == cart.quantity);
    if (index != -1) {
      cartitems[index].quantity++; // Increases the quantity.
    }
  }

  /// Clears all items from the cart.
  static void clearCart() {
    cartitems.clear(); // Empties the cart list.
  }
}
