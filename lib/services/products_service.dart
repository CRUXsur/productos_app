import 'package:flutter/material.dart';
import 'package:productos_app/models/models.dart';

class ProductsService extends ChangeNotifier {
  //
  final String _baseUrl = 'flutter-mark-ff8e2-default-rtdb.firebaseio.com';
  //* La lista de productos
  final List<Product> products = [];

  //TODO: Hacer fetch de productos
}
