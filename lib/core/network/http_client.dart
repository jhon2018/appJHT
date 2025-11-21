//Ruta: lib/core/network/http_client.dart
// Objetivo: Configurar un cliente HTTP que ignore los errores SSL para entornos de desarrollo.

import 'dart:io';
import 'package:http/http.dart' as http;

class DevHttpClient {
  static http.Client create() {
    return http.Client();
  }
  
  static void ignoreSslErrors() {
    HttpOverrides.global = MyHttpOverrides();
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = 
          (X509Certificate cert, String host, int port) => true;
  }
}

