import 'dart:async';
import 'package:bloc/data/product_service.dart';
import 'package:bloc/models/product.dart';

/// Bloc class to manage product-related operations using streams.
class ProductBloc {
  // Stream controller to broadcast product updates to listeners.
  final productStreamController = StreamController.broadcast();

  // Getter to expose the product stream for listening to product updates.
  Stream get productStream => productStreamController.stream;

  /// Retrieves all products from the product service.
  List<Product> getAll() {
    return ProductService.getAll(); // Returns a list of all products.
  }
}

// Singleton instance of ProductBloc to provide a single point of access.
final productBloc = ProductBloc();
