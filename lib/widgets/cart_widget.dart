// lib/widgets/cart_widgets.dart

import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../blocs/cart_bloc.dart';

// MARK: - Empty Cart Widget
class EmptyCart extends StatelessWidget {
  const EmptyCart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}

// MARK: - Cart Item Widget
class CartItem extends StatelessWidget {
  final Cart cart;
  final Function(Cart) onRemove;

  const CartItem({
    Key? key,
    required this.cart,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('${cart.product.id}${cart.quantity}'),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      onDismissed: (_) => onRemove(cart),
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
              _buildProductInfo(context),
              const SizedBox(height: 12),
              _buildQuantityAndSubtotal(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
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
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    return Row(
      children: [
        ProductIcon(productName: cart.product.name),
        const SizedBox(width: 16),
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
    );
  }

  Widget _buildQuantityAndSubtotal(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        QuantityControls(cart: cart),
        Text(
          'Subtotal: \$${(cart.product.price * cart.quantity).toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// MARK: - Product Icon Widget
class ProductIcon extends StatelessWidget {
  final String productName;

  const ProductIcon({
    Key? key,
    required this.productName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _getIconForProduct(productName),
        size: 24,
        color: Theme.of(context).primaryColor,
      ),
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
}

// MARK: - Quantity Controls Widget
class QuantityControls extends StatelessWidget {
  final Cart cart;

  const QuantityControls({
    Key? key,
    required this.cart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.remove_circle_outline,
            color: cart.quantity > 1
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          onPressed:
              cart.quantity > 1 ? () => cartBloc.decreaseQuantity(cart) : null,
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
    );
  }
}

// MARK: - Checkout Section Widget
class CheckoutSection extends StatelessWidget {
  final List<Cart> cartItems;
  final VoidCallback onCheckout;

  const CheckoutSection({
    Key? key,
    required this.cartItems,
    required this.onCheckout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (cartItems.isEmpty) {
      return const SizedBox.shrink();
    }

    double total = cartItems.fold(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );

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
                  'Total (${cartItems.length} items):',
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
                onPressed: onCheckout,
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
  }
}
