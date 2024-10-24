import 'package:bloc/models/product.dart';

/// Service class to handle product-related operations and manage product data.
class ProductService {
  // Static list to store Product objects, initialized as an empty growable list.
  static List<Product> products = List<Product>.empty(growable: true);

  // Private static instance of ProductService for singleton pattern.
  static final ProductService _singleton = ProductService._internal();

  // Factory constructor that returns the singleton instance.
  factory ProductService() {
    return _singleton;
  }

  // Private named constructor for internal use, ensures only one instance (singleton).
  ProductService._internal();

  /// Static method to get all products.
  /// This method simulates fetching product data, typically from a database or API.
  static List<Product> getAll() {
    // Adding sample product data. This would be replaced by a database or API call.
    products.add(Product(1, "Laptop", 1000));
    products.add(Product(2, "Mobile", 2000));
    products.add(Product(3, "Tablet", 3000));
    products.add(Product(4, "Desktop", 4000));
    products.add(Product(5, "Monitor", 5000));
    products.add(Product(6, "Keyboard", 6000));
    products.add(Product(7, "Mouse", 7000));
    products.add(Product(8, "Headset", 8000));
    products.add(Product(9, "Speaker", 9000));

    // Return the list of products.
    return products;
  }
}
