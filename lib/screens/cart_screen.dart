import 'package:bloc/blocs/cart_bloc.dart';
import 'package:bloc/models/cart.dart';
import 'package:flutter/material.dart';

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
            return _buildEmptyCart(context);
          }
          return _buildCartList(snapshot, context);
        },
      ),
      bottomNavigationBar: _buildCheckoutSection(context),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 86,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(AsyncSnapshot snapshot, BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: snapshot.data.length,
      itemBuilder: (context, index) {
        final cart = snapshot.data[index];
        return _buildCartItem(cart, context);
      },
    );
  }

  Widget _buildCartItem(Cart cart, BuildContext context) {
    return Dismissible(
      key: Key('${cart.product.id}${cart.quantity}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete_outline,
          color: Colors.red.shade700,
          size: 28,
        ),
      ),
      onDismissed: (_) {
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
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Product Icon based on category
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconForProduct(cart.product.name),
                      size: 24,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cart.product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${cart.product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Quantity Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: cart.quantity > 1
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                        onPressed: cart.quantity > 1
                            ? () => cartBloc.decreaseQuantity(cart)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${cart.quantity}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () => cartBloc.incrementQuantity(cart),
                      ),
                    ],
                  ),
                  // Subtotal
                  Text(
                    'Subtotal: \$${(cart.product.price * cart.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context) {
    return StreamBuilder(
      stream: cartBloc.cartStream,
      initialData: cartBloc.getCart(),
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData || snapshot.data.isEmpty) {
          return const SizedBox.shrink();
        }

        double total = 0;
        for (var cart in snapshot.data) {
          total += cart.product.price * cart.quantity;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total (${snapshot.data.length} items):',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _processCheckout(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForProduct(String productName) {
    final name = productName.toLowerCase();
    final iconMap = {
      'phone': Icons.smartphone,
      'laptop': Icons.laptop,
      'tablet': Icons.tablet,
      'watch': Icons.watch,
      'tv': Icons.tv,
      'camera': Icons.camera_alt,
      'game': Icons.games,
      'headphone': Icons.headphones,
      'speaker': Icons.speaker,
    };

    return iconMap.entries
        .firstWhere(
          (entry) => name.contains(entry.key),
          orElse: () => MapEntry('default', Icons.shopping_bag),
        )
        .value;
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
    // Implement checkout logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Processing checkout...')),
    );
  }
}
