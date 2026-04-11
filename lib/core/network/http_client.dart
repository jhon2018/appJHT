// //Ruta: lib/core/network/http_client.dart
// // Objetivo: Configurar un cliente HTTP que ignore los errores SSL para entornos de desarrollo.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_jht_front/features/config/environment_config.dart';

class HttpClient {
  final String _baseUrl;
  
  HttpClient({String? baseUrl}) 
    : _baseUrl = baseUrl ?? EnvironmentConfig.baseUrl;
  
  Future<http.Response> get(String endpoint, 
      {Map<String, String>? headers}) async {
    
    final url = '$_baseUrl$endpoint';
    print('GET: $url'); // Debug
    
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (headers != null) {
      defaultHeaders.addAll(headers);
    }
    
    return await http.get(
      Uri.parse(url),
      headers: defaultHeaders,
    );
  }
  
  Future<http.Response> post(String endpoint,
      {Map<String, dynamic>? body,
      Map<String, String>? headers}) async {
    
    final url = '$_baseUrl$endpoint';
    print('POST: $url'); // Debug
    
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (headers != null) {
      defaultHeaders.addAll(headers);
    }
    
    return await http.post(
      Uri.parse(url),
      headers: defaultHeaders,
      body: jsonEncode(body),
    );
  }
  
  // Agrega PUT, DELETE según necesites
}