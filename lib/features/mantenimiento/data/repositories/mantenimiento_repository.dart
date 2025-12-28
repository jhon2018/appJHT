// Ruta: lib/features/mantenimiento/data/repositories/mantenimiento_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:app_jht_front/core/utils/token_service.dart';
import 'package:app_jht_front/features/mantenimiento/data/models/mantenimiento_model.dart';

class MantenimientoRepository {
  String getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:7030';
    } else {
      return 'http://192.168.1.2:7030';
    }
  }

  Future<MantenimientoResponse> getMantenimientosPendientes() async {
    try {
      final String? token = await TokenService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación.');
      }

      final response = await http.get(
        Uri.parse('${getBaseUrl()}/api/general/mantenimientos-pendientes'),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      );

      print('🟡 Response status mantenimientos: ${response.statusCode}');
      print('🟡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return MantenimientoResponse.fromJson(responseData);
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
}