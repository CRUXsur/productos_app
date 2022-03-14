import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  //
  final String _baseUrl = 'identitytoolkit.googleapis.com';
  //token para el acceso al API de Firebase,
  //no es el token que usan los usuarios
  final String _firebaseToken = 'AIzaSyCP-LUnN8kpTqnJmCLIURi13N1blnNjV1k';

  //crear usuario; metodo
  Future<String?> createUser(String email, String password) async {
    //creamos la informacion del POST
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
    };
    //creamos el url
    final url =
        Uri.https(_baseUrl, '/v1/accounts:signUp', {'key': _firebaseToken});
    //disparamos la peticion http
    final resp = await http.post(url, body: json.encode(authData));
    //decodoficamos la respuesta
    final Map<String, dynamic> decodeResp = json.decode(resp.body);
    //analizamos la respuesta si tenemos error......la procesamos....
    print(decodeResp);
  }
}