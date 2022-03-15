import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:productos_app/screens/screens.dart';
import 'package:productos_app/services/services.dart';

//ESTA ES UNA PANTALLA INTERMEDIA ANTES DE ENTRAR...
//ES COMO UN SPLASH SCREEN!

class CheckAuthScreen extends StatelessWidget {
  const CheckAuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //leo el provider, listen: false porque no necesito redibujar este widget
    // NEVER!!!!!
    final authService = Provider.of<AuthService>(context, listen: false);
    //
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: authService.readToken(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            //si no teine data!
            if (!snapshot.hasData) return const Text('Espere...');
            //si regresa vacio
            //! PERO AQUI NO PUEDO UNAS UN NAVIGATOR PARA IRME A OTRA
            //! PANTALLA PORQUE TIENE QUE REGRESAR ALGO EL WIDGET
            //! QUE ESTA CONSTRUYENDO ALGO....REVIENTA MI APP!
            //! USAMOS UN microtask!!!!!!
            if (snapshot.data == '') {
              //sacamos al usuario.....
              Future.microtask(() {
                //* HACEMOS UNA NAVEGACION MANUAL
                //* en vez de usar el navigator......
                //Navigator.of(context).pushReplacementNamed('login');
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const LoginScreen(),
                    transitionDuration: const Duration(seconds: 0),
                  ),
                );
              });
            } else {
              Future.microtask(() {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const HomeScreen(),
                    transitionDuration: const Duration(seconds: 0),
                  ),
                );
              });
            }

            return Container();
          },
        ),
      ),
    );
  }
}
