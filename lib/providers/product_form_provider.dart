import 'package:flutter/material.dart';

import 'package:productos_app/models/models.dart';

class ProductFormProvider extends ChangeNotifier {
  //
  //? es la manera que tenemos de mantener la referencia del formulario
  //? en este key formKey y eventualmente yo podre hacer....(ver {A])
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //* GRACIAS a  este key (formKey) ya puedo hacer validaciones afuera....

  Product product;
  ProductFormProvider(this.product);
  //
  //
  updateAvailability(bool value) {
    //
    print(value);
    this.product.available = value;
    notifyListeners();
  }
  //
  //

  //? [A]
  //? esto es un metodo, en el cual yo voy a retornar...
  bool isValidForm() {
    //
    //? return formKey.currentState?.validate() ?? false;
    //? y si esto resulta nulo, entonces sera false!
    //? el signo ? es por si acaso no esta asignado a un widget
    //? ...ate?.va...
    print(product.name);
    print(product.price);
    print(product.available);
    return formKey.currentState?.validate() ?? false;
  }
}
