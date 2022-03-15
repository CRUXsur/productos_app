import 'package:flutter/material.dart';

class NotificationsService {
  //no extends de ChangeNotifier, porque
  //esto no necesita redibujar nada
  //solo tendra metodos y propiedades static
  //que me sirven par reutilizarlas en cualquier parte del la app

  //* esto hago para mantener mi referencia!
  static GlobalKey<ScaffoldMessengerState> messengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  //1er metodo statico, lo puedo llamar desde cualquier lugar*******
  static showSnackbar(String message) {
    //
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    );

    //para mandarlo a llamar voy a utilizar la llave: messengerKey
    messengerKey.currentState!.showSnackBar(snackBar);
  }

  //2do metodo statico, lo puedo llamar desde cualquier lugar*******
}
