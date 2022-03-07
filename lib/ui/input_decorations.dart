import 'package:flutter/material.dart';

class InputDecorations {
  static InputDecoration authInputDecoration({
    required String hintText, //obligatorio
    required String labelText, //obligatorio
    IconData? prefixIcon, //opcional
  }) {
    return InputDecoration(
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.deepPurple,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.deepPurple,
            width: 2,
          ),
        ),
        hintText: hintText, //'john.doe@gmail.com',
        labelText: labelText, //'Correo electronico',
        labelStyle: const TextStyle(
          color: Colors.blueGrey,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Colors.deepPurple)
            : null
//      Icon(
//        Icons.alternate_email_sharp,
//        color: Colors.deepPurple,
//      ),
        );
  }
}
