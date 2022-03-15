import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:productos_app/models/models.dart';
import 'package:productos_app/screens/screens.dart';

import 'package:productos_app/services/services.dart';
import 'package:productos_app/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsService = Provider.of<ProductsService>(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    //
    //! AQUI isLoading?...UN LOADING FULL SCREEN!
    //! x si....esperar!      x no cargar!
    if (productsService.isLoading) return const LoadingScreen();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        leading: IconButton(
          icon: const Icon(Icons.login_outlined),
          onPressed: () {
            //
            authService.logout(); //destruimos token
            Navigator.pushReplacementNamed(context, 'login');
          },
        ),
      ),
      body: ListView.builder(
        itemCount: productsService.products.length,
        itemBuilder: (
          BuildContext context,
          int index,
        ) =>
            GestureDetector(
          onTap: () {
            //?
            //? aqui, onTap le mando la copia para romper la referencia!
            productsService.selectedProduct =
                productsService.products[index].copy();
            Navigator.pushNamed(context, 'product');
          },
          child: ProductCard(
            product: productsService.products[index],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          //* Initials values del nuevo producto
          productsService.selectedProduct = Product(
            available: false,
            name: '',
            price: 0,
          );
          //* nos vamos a la nueva pantalla del nuevo producto
          Navigator.pushNamed(context, 'product');
        },
      ),
    );
  }
}
