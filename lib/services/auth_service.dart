import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  //
  final String _baseUrl = 'identitytoolkit.googleapis.com';
  //token para el acceso al API de Firebase,
  //no es el token que usan los usuarios
  final String _firebaseToken = 'AIzaSyCP-LUnN8kpTqnJmCLIURi13N1blnNjV1k';

  //
  //token: Al auth_service es al unico que le interesa el idToken
  //token: instancia para el Secure Storage
  //token: Y YA LA PODEMOS UTILIZAR EN CUALQUIER PARTE DE LA APLICACION
  final storage = new FlutterSecureStorage();
  //
  //
  //! si retornamos algo es un error, si no, todo bien!
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
    //print(decodeResp);
    //La respuesta si tiene el idToken, que vienen en la respuesta correcta
    //entonces se creo correctamente
    if (decodeResp.containsKey('idToken')) {
      //Token hay que guardarlo en un lugar seguro!!!!!!!
      await storage.write(key: 'token', value: decodeResp['idToken']);
      //decodeResp['idToken'];
      return null; //hey las credencial estan mal!
    } else {
      return decodeResp['error']['message'];
    }
  }

  //login usuario; metodo
  Future<String?> login(String email, String password) async {
    //creamos la informacion del POST
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
    };
    //creamos el url
    final url = Uri.https(
        _baseUrl, '/v1/accounts:signInWithPassword', {'key': _firebaseToken});
    //disparamos la peticion http
    final resp = await http.post(url, body: json.encode(authData));
    //decodoficamos la respuesta
    final Map<String, dynamic> decodeResp = json.decode(resp.body);
    //analizamos la respuesta si tenemos error......la procesamos....
    print(decodeResp);
    //return 'Error en el login';
    //La respuesta si tiene el idToken, que vienen en la respuesta correcta
    //entonces se creo correctamente
    if (decodeResp.containsKey('idToken')) {
      //Token hay que guardarlo en un lugar seguro!!!!!!!
      await storage.write(key: 'token', value: decodeResp['idToken']);
      //decodeResp['idToken'];
      //todo esta bien
      return null; //hey las credencial estan mal!
    } else {
      return decodeResp['error']['message'];
    }
  }

  Future logout() async {
    await storage.delete(key: 'token');
    return;
  }

  //14.252
  //Se encarga de verificar si tengo un nuevo token
  //isAuthenticated?
  Future<String> readToken() async {
    //en el storage evaluo si existe el token
    //storage.read...puede retornar un null o un String
    //entonces... si el token no existe retorno un String vacio
    return await storage.read(key: 'token') ?? '';
  }
}
