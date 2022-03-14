import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:productos_app/models/models.dart';
import 'package:http/http.dart' as http;

class ProductsService extends ChangeNotifier {
  //
  final String _baseUrl = 'flutter-mark-ff8e2-default-rtdb.firebaseio.com';
  //* La lista de productos
  final List<Product> products = [];
  //? propiedad
  Product? selectedProduct;
  bool isLoading = true;
  bool isSaving = false;

  //HACER FETCH DE PRODUCTOS

  //cuando la instancia sea llamada
  ProductsService() {
    //cuando se crea la primera instancia mando a llamar
    //el this.loadProducts()
    this.loadProducts();
  }

  //? este metodo async , Future y devuelve(retorna), aunque no necesita
  //? pero me ayuda con la restriccion....
  //? necesito que me devuelva la lista se productos
  //? se dispara cuando se carga la instancia
  //<List<Product>>...nos sirve cuando ponemos return
  //Future<List<Product>>loadProducts() async {
  Future<List<Product>> loadProducts() async {
    this.isLoading = true;
    notifyListeners();
    //
    final url = Uri.https(_baseUrl, 'products.json');
    //?disparamos la peticion
    final resp = await http.get(url);
    //?y me va a regresar una respuesta cuyo body viene como un String,
    //?tengo que convertir esa respuesta.body (resp.body)
    //?en un mapa de nuestros productos
    final Map<String, dynamic> productsMap = json.decode(resp.body);
    //? resp.body es un String => tengo que parsearlo....
    //? .... = json.decode(resp.body);
    //? json .....import 'dart:convert';

    //? pero esto es un Map.....mmmmm...yo quisiera que sea un listado
    //print(productsMap);
    //? lo parseo...del metodo fromMap que nos creo quicktype.io
    productsMap.forEach((key, value) {
      final tempProduct = Product.fromMap(value);
      //? en el modelo(product.dart) aumento id -> String? id;
      //? y ese id , sera igual al key que recibo.....
      tempProduct.id = key;
      //? y ahora si tempProduct es un producto completo
      //? y lo puedo almacenar en el listado de productos que tengo
      //? aqui... final List<Product> products = [];
      //? pero como es final entonces no puedo asignar,
      //? SOLO PUEDO hacer un add....
      this.products.add(tempProduct);
    });

    this.isLoading = false;
    notifyListeners();

    //print(this.products[0].name);
    return this.products;
  }

  //! AQUI el proceso de grabacion al CRUD....
  //! ****************************************
  //! creo un nuevo metodo, este es el encargado de hacer las interacciones
  //! con mi backend
  Future saveOrCreateProduct(Product product) async {
    isSaving = true;
    notifyListeners();
    //! necesito confirmar el id de producto
    //! si tengo un id ==> estoy actualizando
    //! si no tengo un id ==> es un producto nuevo
    if (product.id == null) {
      //* Es necesario crear, nuevo producto
      await this.createProduct(product);
    } else {
      //!Actualizar
      //! llamo un uevo metodo!
      await this.updateProduct(product);
    }

    isSaving = false;
    notifyListeners();
  }

  //! la idea es que esto se encargue hacer la peticion al backend
  Future<String> updateProduct(Product product) async {
    //
    final url = Uri.https(_baseUrl, 'products/${product.id}.json');
    //! disparamos la peticion
    final resp = await http.put(url, body: product.toJson());
    //! creo una nuevo variable
    final decodedData = resp.body;

    //print(decodedData);
    //Done! Actualizar el listado de productos
    //! esto me regresa el indice del producto cuyo id es igual al id
    //! que estoy recibiendo aqui: ....Product product....
    //! Future<String> updateProduct(Product product) async {
    final index =
        this.products.indexWhere((element) => element.id == product.id);
    this.products[index] = product;

    return product.id!;
  }

  //* AQUI! Create nuevo producto***************
  Future<String> createProduct(Product product) async {
    //* recibo un producto que NO tiene el id!!!!!
    final url = Uri.https(_baseUrl, 'products.json');
    //* disparamos la peticion post para crear una nueva
    final resp = await http.post(url, body: product.toJson());
    //* creo una nuevo variable
    //* y lo convierto a un mapa
    //*   json.decode(resp.body);
    final decodedData = json.decode(resp.body);
    //print(decodedData);
    //* en el name recibimos el id que le pone Firebase
    //* I/flutter (14522): {"name":"-My5-6cGGp2-HL4eMdne"}
    product.id = decodedData['name'];
    //* o lo anadimos al inicio o lo anadimos al final!!!!
    this.products.add(product);

    return product.id!;
  }
}
