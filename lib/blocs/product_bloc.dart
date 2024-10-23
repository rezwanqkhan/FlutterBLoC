import 'dart:async';
import 'package:bloc/data/product_service.dart';
import 'package:bloc/models/product.dart';

class ProductBloc {
  final productStreamController = StreamController.broadcast();

  Stream get productStream => productStreamController.stream;

  List<Product> getAll() {
    return ProductService.getAll();
  }
}

final productBloc = ProductBloc();
