// Ruta: lib/features/conductor/data/datasources/conductor_remote_data_source.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_jht_front/core/utils/token_service.dart';
import 'package:app_jht_front/features/conductor/data/models/conductor_registro_dto.dart';
import 'package:app_jht_front/features/conductor/data/models/conductor_registro_response.dart';
import 'package:app_jht_front/features/supplier/data/models/tipo_telefono_model.dart';
import 'package:app_jht_front/features/conductor/data/models/persona_list_response.dart';
import 'package:app_jht_front/features/conductor/data/models/persona_detalle_response.dart';
import 'package:app_jht_front/features/conductor/data/models/persona_actualizar_dto.dart';
import 'package:app_jht_front/features/conductor/data/models/persona_actualizar_response.dart';
import 'package:app_jht_front/features/config/environment_config.dart';
import 'package:flutter/foundation.dart';

abstract class ConductorRemoteDataSource {
  Future<ConductorRegistroResponse> registrarConductor(
    ConductorRegistroDto dto,
  );
  Future<List<TipoTelefonoModel>> getTiposTelefono();

  Future<PersonaListResponse> listarPersonas();
  Future<PersonaDetalleResponse> obtenerPersonaDetalle(int personaId);
  Future<PersonaActualizarResponse> actualizarPersona(PersonaActualizarDto dto);
}

class ConductorRemoteDataSourceImpl implements ConductorRemoteDataSource {
  @override
  Future<ConductorRegistroResponse> registrarConductor(
    ConductorRegistroDto dto,
  ) async {
    try {
      debugPrint(
        '🔵 Iniciando registro de conductor: ${dto.persona.primerNombre} ${dto.persona.apellidoPaterno}',
      );

      final String? token = await TokenService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación.');
      }

      debugPrint('🟡 Token obtenido: ${token.substring(0, 20)}...');

      // ✅ Usando EnvironmentConfig.baseUrl de forma global
      final response = await http.post(
        Uri.parse('${EnvironmentConfig.baseUrl}/api/admin/registrar_colaborador'),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(dto.toJson()),
      );

      debugPrint('🟡 Response status: ${response.statusCode}');
      debugPrint('🟡 Response body: ${response.body}');

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
      debugPrint('❌ ERROR en registro de conductor: $e');
      rethrow;
    }
  }

  @override
  Future<List<TipoTelefonoModel>> getTiposTelefono() async {
    try {
      debugPrint('🟡 Obteniendo tipos de teléfono...');

      final String? token = await TokenService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación.');
      }

      // ✅ Usando EnvironmentConfig.baseUrl de forma global
      final response = await http.get(
        Uri.parse('${EnvironmentConfig.baseUrl}/api/admin/consulta_tipo_telefono'),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      );

      debugPrint('🟡 Response status tipos teléfono: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'] as List;
        return data.map((item) => TipoTelefonoModel.fromJson(item)).toList();
      } else {
        throw Exception(
          'Error al obtener tipos de teléfono: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('❌ ERROR en getTiposTelefono: $e');
      throw Exception('Error en getTiposTelefono: $e');
    }
  }

  String _getErrorMessage(Map<String, dynamic> errorData) {
    debugPrint('🔍 Error data: $errorData');

    // PRIMERO: Buscar el campo 'error' que contiene el mensaje específico
    if (errorData['error'] != null) {
      final errorMessage = errorData['error'].toString();
      debugPrint('🟡 Mensaje del campo "error": $errorMessage');

      // Extraer solo la parte específica si contiene "Ocurrió un error al registrar el colaborador:"
      if (errorMessage.contains(
        'Ocurrió un error al registrar el colaborador:',
      )) {
        final partes = errorMessage.split(':');
        if (partes.length > 1) {
          return partes[1]
              .trim(); // Devuelve "Ya existe un colaborador con el mismo dni o nombres."
        }
      }
      return errorMessage;
    }
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

  @override
  Future<PersonaListResponse> listarPersonas() async {
    try {
      debugPrint('🔵 Listando personas...');

      final String? token = await TokenService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación.');
      }

      debugPrint('🟡 Token obtenido: ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse('${EnvironmentConfig.baseUrl}/api/admin/Listar-personas'),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      );

      debugPrint('🟡 Response status listar personas: ${response.statusCode}');
      debugPrint('🟡 Response body listar personas: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return PersonaListResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Token inválido o expirado.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para listar personas.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Error al listar personas: ${errorData['message']}');
      }
    } catch (e) {
      debugPrint('❌ ERROR en listarPersonas: $e');
      rethrow;
    }
  }

  @override
  Future<PersonaDetalleResponse> obtenerPersonaDetalle(int personaId) async {
    try {
      debugPrint('🔵 Obteniendo detalle de persona ID: $personaId');

      final String? token = await TokenService.getToken();
      if (token == null || token.isEmpty) throw Exception('No hay token.');

      // ✅ Usando EnvironmentConfig.baseUrl de forma global
      final response = await http.get(
        Uri.parse('${EnvironmentConfig.baseUrl}/api/admin/persona/$personaId'),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      );

      debugPrint('🟡 Response status detalle persona: ${response.statusCode}');
      debugPrint('🟡 Response body detalle persona: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return PersonaDetalleResponse.fromJson(responseData);
      } else if (response.statusCode == 404) {
        throw Exception('Persona no encontrada.');
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Token inválido o expirado.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para ver detalles de persona.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          'Error al obtener detalle: ${response.statusCode} - ${errorData['message']}',
        );
      }
    } catch (e) {
      debugPrint('❌ ERROR en obtenerPersonaDetalle: $e');
      rethrow;
    }
  }

  @override
  Future<PersonaActualizarResponse> actualizarPersona(
    PersonaActualizarDto dto,
  ) async {
    try {
      debugPrint('🔵 Iniciando actualización de persona ID: ${dto.personaId}');
      debugPrint(
        '🔵 Datos a actualizar: ${dto.primerNombre} ${dto.apellidoPaterno}',
      );

      final String? token = await TokenService.getToken();
      if (token == null || token.isEmpty) throw Exception('No hay token.');

      // ✅ Usando EnvironmentConfig.baseUrl de forma global
      final response = await http.put(
        Uri.parse('${EnvironmentConfig.baseUrl}/api/admin/actualizar-persona'),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(dto.toJson()),
      );

      debugPrint('🟡 Response status actualizar persona: ${response.statusCode}');
      debugPrint('🟡 Response body actualizar persona: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return PersonaActualizarResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Token inválido o expirado.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para actualizar personas.');
      } else if (response.statusCode == 404) {
        throw Exception('Persona no encontrada.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          'Error al actualizar persona: ${response.statusCode} - ${errorData['message'] ?? 'Error desconocido'}',
        );
      }
    } catch (e) {
      debugPrint('❌ ERROR en actualizarPersona: $e');
      rethrow;
    }
  }
}