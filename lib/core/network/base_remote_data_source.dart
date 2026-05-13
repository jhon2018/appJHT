// lib/core/network/base_remote_data_source.dart
import 'package:app_jht_front/features/config/environment_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/token_service.dart';
import 'package:app_jht_front/core/utils/app_logger.dart';
import 'dart:async'; // Para Stopwatch

abstract class BaseRemoteDataSource {
  // Métodos protegidos que todas las clases pueden usar
  Future<http.Response> protectedPost(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? additionalHeaders,
  }) async {
    final stopwatch = Stopwatch()..start();
    final sourceName = runtimeType.toString();
    
    try {
      final String? token = await TokenService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación.');
      }

      final url = '${EnvironmentConfig.baseUrl}$endpoint';
      
      // ✅ Log de petición
      AppLogger.httpRequest('POST $endpoint', source: sourceName);
      
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

      // ✅ Log de respuesta
      AppLogger.httpResponse(
        'POST $endpoint', 
        statusCode: response.statusCode,
        durationMs: stopwatch.elapsedMilliseconds,
        source: sourceName
      );
      
      return response;
    } catch (e, stack) {
      // ✅ Log de error crítico de red o parsing
      AppLogger.error(
        'Fallo en protectedPost ($endpoint)', 
        error: e, 
        stackTrace: stack,
        source: sourceName
      );
      rethrow;
    }
  }

  Future<http.Response> protectedGet(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? additionalHeaders,
  }) async {
    final stopwatch = Stopwatch()..start();
    final sourceName = runtimeType.toString();

    try {
      final String? token = await TokenService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación.');
      }

      String url = '${EnvironmentConfig.baseUrl}$endpoint';
      
      if (queryParameters != null && queryParameters.isNotEmpty) {
        final uri = Uri.parse(url);
        url = uri.replace(queryParameters: queryParameters).toString();
      }

      // ✅ Log de petición
      AppLogger.httpRequest('GET $endpoint', source: sourceName);
      
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

      // ✅ Log de respuesta
      AppLogger.httpResponse(
        'GET $endpoint', 
        statusCode: response.statusCode,
        durationMs: stopwatch.elapsedMilliseconds,
        source: sourceName
      );
      
      return response;
    } catch (e, stack) {
      // ✅ Log de error
      AppLogger.error(
        'Fallo en protectedGet ($endpoint)', 
        error: e, 
        stackTrace: stack,
        source: sourceName
      );
      rethrow;
    }
  }

  Future<http.Response> protectedPut(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? additionalHeaders,
  }) async {
    final stopwatch = Stopwatch()..start();
    final sourceName = runtimeType.toString();

    try {
      final String? token = await TokenService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación.');
      }

      final url = '${EnvironmentConfig.baseUrl}$endpoint';
      AppLogger.httpRequest('PUT $endpoint', source: sourceName);

      final headers = {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      if (additionalHeaders != null) headers.addAll(additionalHeaders);

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      AppLogger.httpResponse(
        'PUT $endpoint',
        statusCode: response.statusCode,
        durationMs: stopwatch.elapsedMilliseconds,
        source: sourceName,
      );

      return response;
    } catch (e, stack) {
      AppLogger.error(
        'Fallo en protectedPut ($endpoint)',
        error: e,
        stackTrace: stack,
        source: sourceName,
      );
      rethrow;
    }
  }

  Future<http.Response> protectedDelete(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) async {
    final stopwatch = Stopwatch()..start();
    final sourceName = runtimeType.toString();

    try {
      final String? token = await TokenService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación.');
      }

      final url = '${EnvironmentConfig.baseUrl}$endpoint';
      AppLogger.httpRequest('DELETE $endpoint', source: sourceName);

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      if (additionalHeaders != null) headers.addAll(additionalHeaders);

      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );

      AppLogger.httpResponse(
        'DELETE $endpoint',
        statusCode: response.statusCode,
        durationMs: stopwatch.elapsedMilliseconds,
        source: sourceName,
      );

      return response;
    } catch (e, stack) {
      AppLogger.error(
        'Fallo en protectedDelete ($endpoint)',
        error: e,
        stackTrace: stack,
        source: sourceName,
      );
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