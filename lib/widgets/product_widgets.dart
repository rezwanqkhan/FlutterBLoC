// lib/widgets/product_list_widgets.dart

import 'package:flutter/material.dart';

class ProductListWidgets {
  static Widget buildCartButton(VoidCallback onPressed) {
    return Stack(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: const Icon(Icons.shopping_cart_outlined, size: 28),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Text(
              '0',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildSearchBar({
    required TextEditingController controller,
    required String searchQuery,
    required Function(String) onChanged,
    required Function(String) onSubmitted,
    required VoidCallback onClear,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
      ),
    );
  }

  static Widget buildRecentSearches({
    required List<String> searches,
    required Function(String) onDelete,
    required VoidCallback onClearAll,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: onClearAll,
                child: const Text('Clear All'),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            children: searches.map((search) {
              return Chip(
                label: Text(search),
                onDeleted: () => onDelete(search),
                deleteIcon: const Icon(Icons.close, size: 16),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  static Widget buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  static Widget buildEmptyState(
      String searchQuery, VoidCallback? onClearSearch) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            searchQuery.isEmpty
                ? Icons.shopping_bag_outlined
                : Icons.search_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'No Products Available'
                : 'No products matching "$searchQuery"',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (searchQuery.isNotEmpty && onClearSearch != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onClearSearch,
              child: const Text('Clear Search'),
            ),
          ],
        ],
      ),
    );
  }

  static Widget buildProductCard(
    dynamic product,
    int index,
    Color color,
    Function(dynamic) onAddToCart,
    BuildContext context,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImage(product, color),
          _buildProductDetails(product, context, onAddToCart),
        ],
      ),
    );
  }

  static Widget _buildProductImage(dynamic product, Color color) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              _getIconForProduct(product.name),
              size: 64,
              color: color.withAlpha(140),
            ),
            Text(
              product.name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: color.withAlpha(140),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildProductDetails(
    dynamic product,
    BuildContext context,
    Function(dynamic) onAddToCart,
  ) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '\$${product.price.toString()}',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => onAddToCart(product),
              icon: const Icon(Icons.add_shopping_cart, size: 18),
              label: const Text('Add to Cart'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _getIconForProduct(String productName) {
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
