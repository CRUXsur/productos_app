// To parse this JSON data, do
//
//     final product = productFromMap(jsonString);

import 'dart:convert';

class Product {
  Product(
      {required this.available,
      required this.name,
      this.picture,
      required this.price,
      //added
      this.id});

  bool available;
  String name;
  String? picture;
  double price;
  String? id;

  factory Product.fromJson(String str) => Product.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Product.fromMap(Map<String, dynamic> json) => Product(
        available: json["available"],
        name: json["name"],
        picture: json["picture"],
        price: json["price"].toDouble(),
      );

  Map<String, dynamic> toMap() => {
        "available": available,
        "name": name,
        "picture": picture,
        "price": price,
      };
  //? me creo una copia de mi model porque, cuando hago un tap en un
  //? card producto, me manda x referencia, entonces puedo modificar
  //? el card antes del tap en el floating de save!!!!!
  Product copy() => Product(
        available: this.available,
        name: this.name,
        picture: this.picture,
        price: this.price,
        id: this.id,
      );
}
