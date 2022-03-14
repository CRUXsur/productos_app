import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:productos_app/providers/product_form_provider.dart';
import 'package:provider/provider.dart';

import 'package:productos_app/services/services.dart';

import 'package:productos_app/ui/input_decorations.dart';
import 'package:productos_app/widgets/widgets.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //
    final productService = Provider.of<ProductsService>(context);
    //
    //? lo extraigo a un widget para poder _ProductScreenBody
    //
    //! asi, tendre acceso a la instancia de mi ProductFormProvider,
    //! a lo largo de todo el body....no importa donde se encuentre
    //! siempre y cuando este dentro de todo mi _ProductScreenBody....
    //!
    return ChangeNotifierProvider(
      create: (_) => ProductFormProvider(productService.selectedProduct!),
      child: _ProductScreenBody(productService: productService),
    );
  }
}

class _ProductScreenBody extends StatelessWidget {
  const _ProductScreenBody({
    Key? key,
    required this.productService,
  }) : super(key: key);

  final ProductsService productService;

  @override
  Widget build(BuildContext context) {
    //! creo la referencia a ese provider <ProductFormProvider>
    //! dejo el listen en true, ara que se actualice
    final productForm = Provider.of<ProductFormProvider>(context);
    return Scaffold(
      body: SingleChildScrollView(
        //* en lo personal lo veo muy agresivo!
        //keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            //
            Stack(
              children: [
                ProductImage(
                  url: productService.selectedProduct!.picture,
                ),
                Positioned(
                  top: 60,
                  left: 20,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 20,
                  child: IconButton(
                    onPressed: () async {
                      //Done!: Camara o galeria
                      //creo una instancia del image_picker
                      final picker = new ImagePicker();
                      // archivo seleccionado
                      final PickedFile? pickedFile = await picker.getImage(
                        //source: ImageSource.camera,
                        source: ImageSource.gallery,
                        imageQuality: 100,
                      );
                      if (pickedFile == null) {
                        //no selecciono nada
                        print('No selecciono nada');
                        //return para que no siga!
                        return;
                      }
                      print('Tenemos imagen ${pickedFile.path}');
                      productService
                          .updateSelectedProductImage(pickedFile.path);
                    },
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            //
            const _ProductForm(),
            //!HABILITAR ESPACIO DE SCROLL PARA EL TECLADO y PUEDA VERSE
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        child: productService.isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.save_outlined),
        onPressed: productService.isSaving
            ? null
            : () async {
                // Done! Guardar producto
                if (!productForm.isValidForm()) return;
                //img upload:hago la peticion y la respuesta lo almaceno en imageUrl

                final String? imageUrl = await productService.uploadImage();
                //img upload: Ya tenemos la url de la imagen
                //print(imageUrl);
                if (imageUrl != null) {
                  productForm.product.picture = imageUrl;
                }
                await productService.saveOrCreateProduct(productForm.product);
              },
      ),
    );
  }
}

class _ProductForm extends StatelessWidget {
  const _ProductForm({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //
    final productForm = Provider.of<ProductFormProvider>(context);
    final product = productForm.product;
    //
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: double.infinity,
        //height: 200,
        decoration: _buildBoxDecoration(),
        child: Form(
          //! asignamos el key del product_form_provider al formulario
          key: productForm.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              //
              const SizedBox(height: 10),
              TextFormField(
                initialValue: product.name,
                onChanged: (value) => product.name = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  //return null;
                },
                decoration: InputDecorations.authInputDecoration(
                  hintText: 'Nombre del producto',
                  labelText: 'Nombre:',
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                initialValue: '${product.price}',
                //! damos formato al valor del TextFormField(.....
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^(\d+)?\.?\d{0,2}'))
                ],
                onChanged: (value) {
                  if (double.tryParse(value) == null) {
                    product.price = 0;
                  } else {
                    product.price = double.parse(value);
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecorations.authInputDecoration(
                  hintText: '\$150',
                  //!precio solo numeros y validados!!!!!!!!!!!!
                  labelText: 'Precio:',
                ),
              ),
              const SizedBox(height: 30),
              SwitchListTile.adaptive(
                value: product.available,
                title: const Text('Disponible'),
                activeColor: Colors.indigo,
                onChanged: (value) {
                  //TODO: pendiente
                  productForm.updateAvailability(value);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() => BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 5),
            )
          ]);
}
