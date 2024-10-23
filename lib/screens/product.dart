import 'package:bloc/blocs/cart_bloc.dart';
import 'package:bloc/blocs/product_bloc.dart';
import 'package:bloc/models/cart.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  // Controllers and state variables
  final TextEditingController _searchController = TextEditingController();
  final _searchSubject = BehaviorSubject<String>();
  String _searchQuery = '';
  List<String> _recentSearches = [];

  // Product display configuration
  final List<Color> productColors = [
    Colors.blue.shade50,
    Colors.green.shade50,
    Colors.orange.shade50,
    Colors.purple.shade50,
    Colors.red.shade50,
    Colors.teal.shade50,
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _setupSearchDebounce();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchSubject.close();
    super.dispose();
  }

  // MARK: - Setup Methods
  void _setupSearchDebounce() {
    _searchSubject.stream
        .debounceTime(const Duration(milliseconds: 300))
        .listen((query) {
      setState(() {
        _searchQuery = query;
      });
    });
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  Future<void> _saveRecentSearch(String query) async {
    if (query.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches.remove(query); // Remove if exists
      _recentSearches.insert(0, query); // Add to front
      if (_recentSearches.length > 5) {
        _recentSearches.removeLast(); // Keep only last 5
      }
    });
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  // MARK: - Build Methods
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_searchQuery.isEmpty && _recentSearches.isNotEmpty)
            _buildRecentSearches(),
          Expanded(child: _buildProductList()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Product List',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [_buildCartButton(), const SizedBox(width: 8)],
    );
  }

  Widget _buildCartButton() {
    return Stack(
      children: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/cart'),
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          _searchSubject.add(value);
        },
        onSubmitted: (value) {
          _saveRecentSearch(value);
        },
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildRecentSearches() {
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
                onPressed: _clearRecentSearches,
                child: const Text('Clear All'),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            children: _recentSearches.map((search) {
              return Chip(
                label: Text(search),
                onDeleted: () => _removeRecentSearch(search),
                deleteIcon: const Icon(Icons.close, size: 16),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return StreamBuilder(
      initialData: productBloc.getAll(),
      stream: productBloc.productStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredProducts = _filterProducts(snapshot.data);

        if (filteredProducts.isEmpty) {
          return _buildEmptyState();
        }

        return _buildProductGrid(filteredProducts);
      },
    );
  }

  Widget _buildErrorState(String error) {
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
            onPressed: () {
              // Retry loading products
              setState(() {});
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isEmpty
                ? Icons.shopping_bag_outlined
                : Icons.search_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No Products Available'
                : 'No products matching "$_searchQuery"',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: _clearSearch,
              child: const Text('Clear Search'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<dynamic> products) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) =>
            _buildProductCard(products[index], index),
      ),
    );
  }

  Widget _buildProductCard(dynamic product, int index) {
    final color = productColors[index % productColors.length];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImage(product, color),
          _buildProductDetails(product),
        ],
      ),
    );
  }

  Widget _buildProductImage(dynamic product, Color color) {
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

  Widget _buildProductDetails(dynamic product) {
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
              onPressed: () => _addToCart(product),
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

  // MARK: - Helper Methods
  List<dynamic> _filterProducts(List<dynamic> products) {
    if (_searchQuery.isEmpty) {
      return products;
    }

    final query = _searchQuery.toLowerCase();
    return products.where((product) {
      final searchableFields = [
        product.name.toString(),
        product.price.toString(),
        // Add more fields as needed
      ].map((s) => s.toLowerCase());

      return searchableFields.any((field) => field.contains(query));
    }).toList();
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

  void _addToCart(dynamic product) {
    cartBloc.addToCart(Cart(product, 1));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ),
    );
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches.clear();
    });
    await prefs.remove('recent_searches');
  }

  Future<void> _removeRecentSearch(String search) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches.remove(search);
    });
    await prefs.setStringList('recent_searches', _recentSearches);
  }
}
