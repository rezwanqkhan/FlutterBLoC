import 'package:bloc/widgets/cart_widgets.dart';
import 'package:flutter/material.dart';
import '../blocs/cart_bloc.dart';

/// A stateless widget that represents the shopping cart screen.
class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shopping Cart',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            // StreamBuilder to listen to cart updates and display item count.
            StreamBuilder(
              stream: cartBloc.cartStream,
              builder: (context, snapshot) {
                final itemCount = snapshot.hasData
                    ? snapshot.data.length
                    : 0; // Check if data exists, then show count.
                return Text(
                  '$itemCount items',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          // Button to clear the cart.
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showClearCartDialog(
                context), // Show dialog to confirm clearing cart.
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder(
        stream: cartBloc.cartStream,
        initialData: cartBloc.getCart(), // Get initial data of the cart.
        builder: (context, AsyncSnapshot snapshot) {
          // If cart is empty, show an empty cart widget.
          if (!snapshot.hasData || snapshot.data.isEmpty) {
            return const EmptyCart();
          }
          // Display cart items in a list.
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              final cart = snapshot.data[index];
              // Display each cart item with a remove option.
              return CartItem(
                cart: cart,
                onRemove: (cart) {
                  cartBloc.removeFromCart(cart); // Remove item from cart.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${cart.product.name} removed from cart'), // Show feedback on removal.
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () => cartBloc
                            .addToCart(cart), // Option to undo the removal.
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: StreamBuilder(
        stream: cartBloc.cartStream,
        initialData: cartBloc.getCart(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData)
            return const SizedBox.shrink(); // Hide if no cart data exists.
          // Checkout section with cart items.
          return CheckoutSection(
            cartItems: snapshot.data,
            onCheckout: () =>
                _processCheckout(context), // Initiate the checkout process.
          );
        },
      ),
    );
  }

  // Show a dialog to confirm clearing the cart.
  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items?'),
        actions: [
          // Cancel button to close the dialog without action.
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          // Clear button to empty the cart.
          TextButton(
            onPressed: () {
              cartBloc.clearCart(); // Clear the cart when confirmed.
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Cart cleared')), // Feedback after clearing.
              );
            },
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
  }

  // Method to process the checkout.
  void _processCheckout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'Processing checkout...')), // Show feedback during checkout process.
    );
  }
}
