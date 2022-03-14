import 'dart:convert';
import 'dart:io';

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
  // img:
  File? newPictureFile;

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

  // img: Nuevo metodo para mostrar la imagen
  // img: Obejtivo de este metodo es simplemente cambiar la imagen
  // img: que tengo en la vista previa, todavia no voy a grabar nada
  // img: en la base de datos, ni hare una peticion, porque pudiera ser
  // img: que la persona simopkemente selecciono la imgen y regresa
  // img: y no quiere grabarla
  // img: Necesito recibir el path
  void updateSelectedProductImage(String path) {
    // img: path que estoy recibiendo
    // img: actualiza selectedProduct!.picture...con el path
    this.selectedProduct!.picture = path;
    // img: crea una nueva variable newPictureFile ....
    this.newPictureFile = File.fromUri(Uri(path: path));
    // img: notifica, para que en product_screen se redibuje
    // img: con la nueva imagen!!!!
    notifyListeners();
  }

  // img upload : PETICION A Cloudinary! para subir la imagen
  Future<String?> uploadImage() async {
    // nos aseguramos que tenemos una imagen
    if (this.newPictureFile == null) return null;
    this.isSaving = true;
    notifyListeners();

    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/djtycwcta/image/upload?upload_preset=rqr9vart');
    //img upload: me creo el request
    final imageUploadRequest = http.MultipartRequest(
      'POST',
      url,
    );
    //img upload: adjunto el archivo...
    //img upload: acabo de hacer la evaluacion y NO sera nulo !
    final file = await http.MultipartFile.fromPath(
      'file',
      newPictureFile!.path,
    );
    //img upload: adjuntamos el file
    imageUploadRequest.files.add(file);
    //img upload: Disparo la peticion
    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('algo salio mal');
      print(resp.body);
      return null;
    }
    //img upload: ya lo subi y limpio esa propiedad, no necesito
    //img upload: hacer nada mas
    this.newPictureFile = null;
    final decodedData = json.decode(resp.body);
    //print(resp.body);
    return decodedData['secure_url'];
    //this.isSaving = false;
    //notifyListeners();
  }
}
