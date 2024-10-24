import 'package:bloc/models/product.dart';
import 'package:bloc/screens/cart_screen.dart';
import 'package:bloc/screens/product_list.dart';
import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bloc Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/': (context) => ProductListScreen(),
        '/cart': (context) => CartScreen(),
      },
      initialRoute: '/',
    );
  }
}
