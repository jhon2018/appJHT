// lib/core/network/base_remote_data_source.dart
import 'package:app_jht_front/config/environment_config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/token_service.dart';

abstract class BaseRemoteDataSource {
  // Métodos protegidos que todas las clases pueden usar
  Future<http.Response> protectedPost(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final String? token = await TokenService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación.');
      }

      final url = '${EnvironmentConfig.baseUrl}$endpoint';
      print('🌐 POST: $url');
      
      final headers = {
        'Content-Type': 'application/json',
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      };
      
      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      print('📦 Status: ${response.statusCode}');
      
      return response;
    } catch (e) {
      print('❌ Error en protectedPost: $e');
      rethrow;
    }
  }

  Future<http.Response> protectedGet(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final String? token = await TokenService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación.');
      }

      String url = '${EnvironmentConfig.baseUrl}$endpoint';
      
      // Agregar query parameters si existen
      if (queryParameters != null && queryParameters.isNotEmpty) {
        final uri = Uri.parse(url);
        url = uri.replace(queryParameters: queryParameters).toString();
      }

      print('🌐 GET: $url');
      
      final headers = {
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
      };
      
      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📦 Status: ${response.statusCode}');
      
      return response;
    } catch (e) {
      print('❌ Error en protectedGet: $e');
      rethrow;
    }
  }

  // Método para manejar errores comunes
  String getErrorMessage(Map<String, dynamic> errorData) {
    print('🔍 Error data: $errorData');

    if (errorData['mensaje'] != null) return errorData['mensaje'].toString();
    if (errorData['message'] != null) return errorData['message'].toString();

    if (errorData['errors'] != null) {
      final errors = errorData['errors'] as Map<String, dynamic>;
      if (errors.isNotEmpty) {
        final firstKey = errors.keys.first;
        final firstError = errors[firstKey];
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        } else if (firstError is String) {
          return firstError;
        }
      }
    }

    if (errorData['title'] != null) return errorData['title'].toString();

    return 'Error en la operación';
  }
}