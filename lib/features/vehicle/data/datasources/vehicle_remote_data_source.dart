// lib/features/vehicle/data/datasources/vehicle_remote_data_source.dart
import 'package:app_jht_front/core/network/http_client.dart';
import 'package:app_jht_front/core/utils/token_service.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_list_response.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_registro_dto.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_registro_response.dart';
import 'package:app_jht_front/features/config/environment_config.dart';
import 'package:app_jht_front/core/network/base_remote_data_source.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
// ... resto del código igual

abstract class VehicleRemoteDataSource {
  Future<VehicleRegistroResponse> registrarVehiculo(VehicleRegistroDto dto);
  Future<List<VehicleListData>> getAllVehicles(); // ✅ MÉTODO DECLARADO
}

class VehicleRemoteDataSourceImpl extends BaseRemoteDataSource // ✅ EXTENDER BaseRemoteDataSource
    implements VehicleRemoteDataSource {
  
  VehicleRemoteDataSourceImpl({required HttpClient httpClient});

  @override
  Future<VehicleRegistroResponse> registrarVehiculo(VehicleRegistroDto dto) async {
    try {
      print('🔵 Iniciando registro de vehículo: ${dto.vehVplaca}');
      
      final String? token = await TokenService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación. Por favor inicie sesión nuevamente.');
      }
      
      print('🟡 Token obtenido: ${token.substring(0, 20)}...');

      final response = await http.post(
        Uri.parse('${EnvironmentConfig.baseUrl}/api/general/registro_vehiculo'),
        headers: {
          'Content-Type': 'application/json', 
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(dto.toJson()),
      );

      print('🟡 Response status: ${response.statusCode}');
      print('🟡 Response body: ${response.body}');

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

  // ✅ IMPLEMENTACIÓN CORRECTA del método getAllVehicles
  @override
  Future<List<VehicleListData>> getAllVehicles() async {
    try {
      final response = await protectedGet('/api/general/Listar-todos-vehiculos');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final vehicleResponse = VehicleListResponse.fromJson(jsonData);
        return vehicleResponse.data;
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Token inválido o expirado.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para listar vehículos.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(getErrorMessage(errorData));
      }
    } catch (e) {
      print('❌ ERROR al listar vehículos: $e');
      rethrow;
    }
  }

  String _getErrorMessage(Map<String, dynamic> errorData) {
    print('🔍 Error data: $errorData');

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