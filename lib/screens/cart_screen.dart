import 'package:bloc/widgets/cart_widgets.dart';
import 'package:flutter/material.dart';
import '../blocs/cart_bloc.dart';

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
            StreamBuilder(
              stream: cartBloc.cartStream,
              builder: (context, snapshot) {
                final itemCount = snapshot.hasData ? snapshot.data.length : 0;
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
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showClearCartDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder(
        stream: cartBloc.cartStream,
        initialData: cartBloc.getCart(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData || snapshot.data.isEmpty) {
            return const EmptyCart();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              final cart = snapshot.data[index];
              return CartItem(
                cart: cart,
                onRemove: (cart) {
                  cartBloc.removeFromCart(cart);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${cart.product.name} removed from cart'),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () => cartBloc.addToCart(cart),
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
          if (!snapshot.hasData) return const SizedBox.shrink();
          return CheckoutSection(
            cartItems: snapshot.data,
            onCheckout: () => _processCheckout(context),
          );
        },
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              cartBloc.clearCart();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cart cleared')),
              );
            },
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
  }

  void _processCheckout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Processing checkout...')),
    );
  }
}
