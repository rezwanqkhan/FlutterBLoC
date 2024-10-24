import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/product_widgets.dart';
import '../blocs/cart_bloc.dart';
import '../blocs/product_bloc.dart';
import '../models/cart.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  // Controller to manage search input text
  final TextEditingController _searchController = TextEditingController();

  // BehaviorSubject to handle search query stream and debounce the input
  final _searchSubject = BehaviorSubject<String>();

  // Current search query
  String _searchQuery = '';

  // List to store recent search queries
  List<String> _recentSearches = [];

  // List of colors to be used for product cards in the UI
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
    _loadRecentSearches(); // Load recent searches from shared preferences
    _setupSearchDebounce(); // Setup debouncing for search query input
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchSubject.close(); // Close the search stream
    super.dispose();
  }

  // Set up a debounce for the search query to delay sending search input for 300ms.
  void _setupSearchDebounce() {
    _searchSubject.stream
        .debounceTime(const Duration(milliseconds: 300))
        .listen((query) {
      setState(() {
        _searchQuery = query; // Update the search query after debounce
      });
    });
  }

  // Load recent search queries from shared preferences
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  // Save a new search query to the list of recent searches
  Future<void> _saveRecentSearch(String query) async {
    if (query.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches.remove(query); // Remove if it already exists
      _recentSearches.insert(0, query); // Insert at the top
      if (_recentSearches.length > 5) {
        _recentSearches.removeLast(); // Limit to 5 recent searches
      }
    });
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  // Clear the current search input
  void _clearSearch() {
    setState(() {
      _searchController.clear(); // Clear the text field
      _searchQuery = ''; // Clear the search query
    });
  }

  // Clear all recent searches
  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches.clear(); // Clear the local list
    });
    await prefs.remove('recent_searches'); // Remove from shared preferences
  }

  // Remove a specific recent search query
  Future<void> _removeRecentSearch(String search) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches.remove(search); // Remove the specific search
    });
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  // Add a product to the cart
  void _addToCart(dynamic product) {
    cartBloc.addToCart(Cart(product, 1)); // Add product to the cart
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () => Navigator.pushNamed(
              context, '/cart'), // Navigate to the cart screen
        ),
      ),
    );
  }

  // Filter the list of products based on the search query
  List<dynamic> _filterProducts(List<dynamic> products) {
    if (_searchQuery.isEmpty) return products;
    final query = _searchQuery.toLowerCase();
    return products.where((product) {
      final searchableFields = [
        product.name.toString(), // Product name
        product.price.toString(), // Product price
      ].map((s) => s.toLowerCase());
      return searchableFields.any((field) => field.contains(query));
    }).toList(); // Return products matching the search query
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Product List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Build cart button to navigate to cart screen
          ProductListWidgets.buildCartButton(
            () => Navigator.pushNamed(context, '/cart'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search bar widget
          ProductListWidgets.buildSearchBar(
            controller: _searchController,
            searchQuery: _searchQuery,
            onChanged: (value) =>
                _searchSubject.add(value), // Stream search input
            onSubmitted: _saveRecentSearch, // Save recent search
            onClear: _clearSearch, // Clear search
          ),
          if (_searchQuery.isEmpty && _recentSearches.isNotEmpty)
            // Display recent searches if no search query is present
            ProductListWidgets.buildRecentSearches(
              searches: _recentSearches,
              onDelete: _removeRecentSearch, // Remove a specific search
              onClearAll: _clearRecentSearches, // Clear all recent searches
            ),
          Expanded(
            child: StreamBuilder(
              initialData: productBloc.getAll(), // Get initial products
              stream: productBloc.productStream, // Listen to product stream
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return ProductListWidgets.buildErrorState(
                    snapshot.error.toString(),
                    () => setState(() {}), // Retry on error
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                      child:
                          CircularProgressIndicator()); // Show loader if no data
                }

                final filteredProducts = _filterProducts(
                    snapshot.data); // Filter products based on search query

                if (filteredProducts.isEmpty) {
                  return ProductListWidgets.buildEmptyState(
                    _searchQuery,
                    _searchQuery.isNotEmpty
                        ? _clearSearch
                        : null, // Clear search if no products match
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Two columns for products
                      childAspectRatio: 0.75, // Aspect ratio for product card
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) =>
                        ProductListWidgets.buildProductCard(
                      filteredProducts[index], // Display filtered product
                      index,
                      productColors[index %
                          productColors.length], // Cycle through product colors
                      _addToCart, // Add product to cart
                      context,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
