// Ruta: lib/features/mantenimiento/data/repositories/mantenimiento_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:app_jht_front/core/utils/token_service.dart';
import 'package:app_jht_front/features/mantenimiento/data/models/mantenimiento_model.dart';
import 'package:app_jht_front/features/mantenimiento/data/models/detalle_mantenimiento_model.dart';

class MantenimientoRepository {
  // Método para obtener la URL base (igual que en otros repositorios)
  String getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:7030';
    } else {
      // Para Android/iOS, usa la IP de tu computadora
      // Ejemplo: 'http://192.168.1.2:7030'
      return 'http://192.168.1.2:7030'; // Ajusta esta IP a la de tu computadora
    }
  }

  Future<MantenimientoResponse> getMantenimientosPendientes() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) throw Exception('No hay token de autenticación');
      
      print('🟡 Obteniendo mantenimientos de: ${getBaseUrl()}');
      
      final response = await http.get(
        Uri.parse('${getBaseUrl()}/api/general/mantenimientos-pendientes'),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      );

      print('🟡 Response status: ${response.statusCode}');
      print('🟡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return MantenimientoResponse.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado o inválido. Por favor, inicie sesión nuevamente.');
      } else {
        throw Exception('Error al obtener mantenimientos: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR en getMantenimientosPendientes: $e');
      rethrow;
    }
  }

  Future<DetalleMantenimientoResponse> getDetalleMantenimiento(
    int bitacoraId, 
    int accesorioId
  ) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) throw Exception('No hay token de autenticación');
      
      print('🟡 Obteniendo detalle de: ${getBaseUrl()}');
      
      final response = await http.get(
        Uri.parse('${getBaseUrl()}/api/general/detalle-mantenimiento?bit_iid=$bitacoraId&acc_iid=$accesorioId'),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      );

      print('🟡 Response status detalle: ${response.statusCode}');
      print('🟡 Response body detalle: ${response.body}');

      if (response.statusCode == 200) {
        return DetalleMantenimientoResponse.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('No se encontró el mantenimiento solicitado');
      } else if (response.statusCode == 401) {
        throw Exception('Token expirado o inválido.');
      } else {
        throw Exception('Error al obtener detalle: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR en getDetalleMantenimiento: $e');
      rethrow;
    }
  }

Future<ActualizarMantenimientoResponse> actualizarMantenimiento(
  
  ActualizarMantenimientoRequest request,
) async {
  try {
    final token = await TokenService.getToken();
    if (token == null) throw Exception('No hay token de autenticación');
    
    final url = '${getBaseUrl()}/api/general/actualizar-historico';
    final body = json.encode(request.toJson());
    
    print('🟢 Método: POST');
    print('🟢 URL: $url');
    print('🟢 Request Body: $body');
    print('🟢 Token: ${token.substring(0, 20)}...');
 final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'accept': 'application/json',
      },
      body: body,
    );

    print('🟢 Response status: ${response.statusCode}');
    print('🟢 Response body: ${response.body}');
    print('🟢 Response headers: ${response.headers}');

    if (response.statusCode == 200) {
      return ActualizarMantenimientoResponse.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('No se encontró el registro de mantenimiento');
    } else if (response.statusCode == 401) {
      throw Exception('Token expirado o inválido.');
    } else {
      throw Exception('Error al actualizar: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('❌ ERROR en actualizarMantenimiento: $e');
    rethrow;
  }
}
}