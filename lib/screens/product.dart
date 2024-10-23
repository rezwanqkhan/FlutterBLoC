// lib/screens/product_list_screen.dart

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
  final TextEditingController _searchController = TextEditingController();
  final _searchSubject = BehaviorSubject<String>();
  String _searchQuery = '';
  List<String> _recentSearches = [];

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
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 5) {
        _recentSearches.removeLast();
      }
    });
    await prefs.setStringList('recent_searches', _recentSearches);
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

  List<dynamic> _filterProducts(List<dynamic> products) {
    if (_searchQuery.isEmpty) return products;
    final query = _searchQuery.toLowerCase();
    return products.where((product) {
      final searchableFields = [
        product.name.toString(),
        product.price.toString(),
      ].map((s) => s.toLowerCase());
      return searchableFields.any((field) => field.contains(query));
    }).toList();
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
          ProductListWidgets.buildCartButton(
            () => Navigator.pushNamed(context, '/cart'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          ProductListWidgets.buildSearchBar(
            controller: _searchController,
            searchQuery: _searchQuery,
            onChanged: (value) => _searchSubject.add(value),
            onSubmitted: _saveRecentSearch,
            onClear: _clearSearch,
          ),
          if (_searchQuery.isEmpty && _recentSearches.isNotEmpty)
            ProductListWidgets.buildRecentSearches(
              searches: _recentSearches,
              onDelete: _removeRecentSearch,
              onClearAll: _clearRecentSearches,
            ),
          Expanded(
            child: StreamBuilder(
              initialData: productBloc.getAll(),
              stream: productBloc.productStream,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return ProductListWidgets.buildErrorState(
                    snapshot.error.toString(),
                    () => setState(() {}),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredProducts = _filterProducts(snapshot.data);

                if (filteredProducts.isEmpty) {
                  return ProductListWidgets.buildEmptyState(
                    _searchQuery,
                    _searchQuery.isNotEmpty ? _clearSearch : null,
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) =>
                        ProductListWidgets.buildProductCard(
                      filteredProducts[index],
                      index,
                      productColors[index % productColors.length],
                      _addToCart,
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
