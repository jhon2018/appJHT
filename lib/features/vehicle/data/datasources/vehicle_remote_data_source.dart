// Ruta: lib/features/vehicle/data/datasources/vehicle_remote_data_source.dart
// Definición: Fuente de datos remota para operaciones de vehículos
// Objetivo: Comunicarse con el API backend para operaciones CRUD usando autenticación Bearer Token

import 'package:app_jht_front/core/network/http_client.dart';
import 'package:app_jht_front/core/utils/token_service.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_registro_dto.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_registro_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

abstract class VehicleRemoteDataSource {
  Future<VehicleRegistroResponse> registrarVehiculo(VehicleRegistroDto dto);
}

class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final DevHttpClient httpClient;

  VehicleRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<VehicleRegistroResponse> registrarVehiculo(VehicleRegistroDto dto) async {
    try {
      print('🔵 Iniciando registro de vehículo: ${dto.vehVplaca}');
      
      // 1. OBTENER TOKEN DE AUTENTICACIÓN
      final String? token = await TokenService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación. Por favor inicie sesión nuevamente.');
      }
      
      print('🟡 Token obtenido: ${token.substring(0, 20)}...'); // Log parcial del token

      // 2. CONFIGURAR URL BASE (igual que en login)
      String getBaseUrl() {
        if (kIsWeb) {
          return 'http://localhost:7030'; // Web funciona con localhost
        } else {
          return 'http://192.168.1.2:7030'; // Móvil usa IP
        }
      }

      // 3. LLAMADA REAL AL API CON AUTENTICACIÓN
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/api/general/registro_vehiculo'),
        headers: {
          'Content-Type': 'application/json', 
          'accept': '*/*',
          'Authorization': 'Bearer $token', // ← TOKEN INCLUIDO AQUÍ
        },
        body: json.encode(dto.toJson()),
      );

      print('🟡 Response status: ${response.statusCode}');
      print('🟡 Response body: ${response.body}');

      // 4. MANEJAR RESPUESTA
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return VehicleRegistroResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Token inválido o expirado.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para registrar vehículos.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(_getErrorMessage(errorData));
      }
    } catch (e) {
      print('❌ ERROR en registro de vehículo: $e');
      rethrow;
    }
  }

  String _getErrorMessage(Map<String, dynamic> errorData) {
    print('🔍 Error data: $errorData');

    // Mismo manejo de errores que en el login
    if (errorData['mensaje'] != null) {
      return errorData['mensaje'].toString();
    }

    if (errorData['message'] != null) {
      return errorData['message'].toString();
    }

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

    if (errorData['title'] != null) {
      return errorData['title'].toString();
    }

    return 'Error en el registro del vehículo';
  }
}