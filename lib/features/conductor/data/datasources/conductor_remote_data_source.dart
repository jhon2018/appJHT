//Ruta: lib/features/conductor/data/datasources/conductor_remote_data_source.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:app_jht_front/core/utils/token_service.dart';
import 'package:app_jht_front/features/conductor/data/models/conductor_registro_dto.dart';
import 'package:app_jht_front/features/conductor/data/models/conductor_registro_response.dart';
import 'package:app_jht_front/features/supplier/data/models/tipo_telefono_model.dart';

abstract class ConductorRemoteDataSource {
  Future<ConductorRegistroResponse> registrarConductor(ConductorRegistroDto dto);
  Future<List<TipoTelefonoModel>> getTiposTelefono();
}

class ConductorRemoteDataSourceImpl implements ConductorRemoteDataSource {
  @override
  Future<ConductorRegistroResponse> registrarConductor(ConductorRegistroDto dto) async {
    try {
      print('🔵 Iniciando registro de conductor: ${dto.persona.primerNombre} ${dto.persona.apellidoPaterno}');
      
      final String? token = await TokenService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación.');
      }
      
      print('🟡 Token obtenido: ${token.substring(0, 20)}...');

      String getBaseUrl() {
        if (kIsWeb) {
          return 'http://localhost:7030';
        } else {
          return 'http://192.168.1.2:7030';
        }
      }

      final response = await http.post(
        Uri.parse('${getBaseUrl()}/api/admin/registrar_colaborador'),
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
        return ConductorRegistroResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Token inválido o expirado.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para registrar conductores.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(_getErrorMessage(errorData));
      }
    } catch (e) {
      print('❌ ERROR en registro de conductor: $e');
      rethrow;
    }
  }

  @override
  Future<List<TipoTelefonoModel>> getTiposTelefono() async {
    try {
      print('🟡 Obteniendo tipos de teléfono...');
      
      final String? token = await TokenService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación.');
      }

      String getBaseUrl() {
        if (kIsWeb) {
          return 'http://localhost:7030';
        } else {
          return 'http://192.168.1.2:7030';
        }
      }

      final response = await http.get(
        Uri.parse('${getBaseUrl()}/api/admin/consulta_tipo_telefono'),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      );

      print('🟡 Response status tipos teléfono: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'] as List;
        return data.map((item) => TipoTelefonoModel.fromJson(item)).toList();
      } else {
        throw Exception('Error al obtener tipos de teléfono: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR en getTiposTelefono: $e');
      throw Exception('Error en getTiposTelefono: $e');
    }
  }

String _getErrorMessage(Map<String, dynamic> errorData) {
  print('🔍 Error data: $errorData');

  // PRIMERO: Buscar el campo 'error' que contiene el mensaje específico
  if (errorData['error'] != null) {
    final errorMessage = errorData['error'].toString();
    print('🟡 Mensaje del campo "error": $errorMessage');
    
    // Extraer solo la parte específica si contiene "Ocurrió un error al registrar el colaborador:"
    if (errorMessage.contains('Ocurrió un error al registrar el colaborador:')) {
      final partes = errorMessage.split(':');
      if (partes.length > 1) {
        return partes[1].trim(); // Devuelve "Ya existe un colaborador con el mismo dni o nombres."
      }
    }
    return errorMessage;
  }

  // SEGUNDO: Buscar otros campos posibles
  if (errorData['mensaje'] != null) return errorData['mensaje'].toString();
  if (errorData['message'] != null) return errorData['message'].toString();

  // TERCERO: Buscar en 'errors' si existe
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

  return 'Error en el registro del conductor';
}
}