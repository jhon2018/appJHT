// lib/features/supplier/data/datasources/supplier_remote_data_source.dart
// Descripcion: Data source remoto para proveedores, maneja las llamadas HTTP a la API para registrar, listar, obtener detalles y actualizar proveedores.

import 'package:app_jht_front/core/network/http_client.dart';
import 'package:app_jht_front/core/utils/token_service.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_actualizar_dto.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_actualizar_response.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_registro_dto.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_registro_response.dart';
import 'package:app_jht_front/features/supplier/data/models/tipo_telefono_model.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_list_response.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_detail_response.dart';
import 'package:app_jht_front/features/config/environment_config.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:app_jht_front/core/network/base_remote_data_source.dart';
import 'package:flutter/foundation.dart';

abstract class SupplierRemoteDataSource {
  // Métodos existentes
  Future<SupplierRegistroResponse> registrarProveedor(SupplierRegistroDto dto);
  Future<List<TipoTelefonoModel>> getTiposTelefono();
  
  // NUEVOS MÉTODOS - AGREGAR ESTOS
  Future<SupplierListResponse> listarProveedores();
  Future<SupplierDetailResponse> obtenerDetalleProveedor(int proveedorId);

  Future<SupplierActualizarResponse> actualizarProveedor(SupplierActualizarDto dto);

}

class SupplierRemoteDataSourceImpl extends BaseRemoteDataSource 
    implements SupplierRemoteDataSource {
  
  final HttpClient httpClient;

  SupplierRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<SupplierRegistroResponse> registrarProveedor(SupplierRegistroDto dto) async {
    try {
      debugPrint('🔵 Iniciando registro de proveedor: ${dto.razonSocial}');
      
      final String? token = await TokenService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación.');
      }
      
      debugPrint('🟡 Token obtenido: ${token.substring(0, 20)}...');

      final response = await http.post(
        Uri.parse('${EnvironmentConfig.baseUrl}/api/general/insertar-proveedor'),
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
        return SupplierRegistroResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Token inválido o expirado.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para registrar proveedores.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(_getErrorMessage(errorData));
      }
    } catch (e) {
      debugPrint('❌ ERROR en registro de proveedor: $e');
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
        throw Exception('Error al obtener tipos de teléfono: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ ERROR en getTiposTelefono: $e');
      throw Exception('Error en getTiposTelefono: $e');
    }
  }

  // NUEVO MÉTODO - AGREGAR ESTA IMPLEMENTACIÓN
  @override
  Future<SupplierListResponse> listarProveedores() async {
    try {
      debugPrint('🔵 Listando proveedores...');
      
      final String? token = await TokenService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación.');
      }

      final response = await http.get(
        Uri.parse('${EnvironmentConfig.baseUrl}/api/general/listar-proveedores'),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      );

      debugPrint('🟡 Response status listar proveedores: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return SupplierListResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Token inválido o expirado.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para listar proveedores.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(_getErrorMessage(errorData));
      }
    } catch (e) {
      debugPrint('❌ ERROR en listar proveedores: $e');
      rethrow;
    }
  }

  // NUEVO MÉTODO - AGREGAR ESTA IMPLEMENTACIÓN
  @override
  Future<SupplierDetailResponse> obtenerDetalleProveedor(int proveedorId) async {
    try {
      debugPrint('🔵 Obteniendo detalle del proveedor ID: $proveedorId');
      
      final String? token = await TokenService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación.');
      }

      final response = await http.get(
        Uri.parse('${EnvironmentConfig.baseUrl}/api/general/detalle-proveedor/$proveedorId'),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      );

      debugPrint('🟡 Response status detalle proveedor: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        try {
          // DEBUG: Escribir json en archivo
          // Usamos la ruta absoluta de Windows del workspace para guardar el JSON
          File('d:\\JONATHAN\\Proyectos\\Jht_Transport Company\\Software\\Front_jht\\app_jht_front\\api_detalle_proveedor_debug.json').writeAsStringSync(response.body);
        } catch (e) {}
        
        return SupplierDetailResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Token inválido o expirado.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para ver detalle de proveedores.');
      } else if (response.statusCode == 404) {
        throw Exception('Proveedor no encontrado.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(_getErrorMessage(errorData));
      }
    } catch (e) {
      debugPrint('❌ ERROR en obtener detalle proveedor: $e');
      rethrow;
    }
  }

 @override
  Future<SupplierActualizarResponse> actualizarProveedor(SupplierActualizarDto dto) async {
    try {
      debugPrint('🔵 Actualizando proveedor ID: ${dto.proveedorId}');
      
      final String? token = await TokenService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación.');
      }
      debugPrint('📤 JSON enviado supplier_remote_data_source.dart:  ${json.encode(dto.toJson())}');
      final response = await http.put(
        Uri.parse('${EnvironmentConfig.baseUrl}/api/general/actualizar-proveedor'),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(dto.toJson()),
      );

      debugPrint('🟡 Response status actualizar: ${response.statusCode}');
      debugPrint('🟡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return SupplierActualizarResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Token inválido o expirado.');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para actualizar proveedores.');
      } else if (response.statusCode == 404) {
        throw Exception('Proveedor no encontrado.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(_getErrorMessage(errorData));
      }
    } catch (e) {
      debugPrint('❌ ERROR en actualizar proveedor: $e');
      rethrow;
    }
  }


  String _getErrorMessage(Map<String, dynamic> errorData) {
    debugPrint('🔍 Error data: $errorData');

    if (errorData['errors'] != null) {
      final errors = errorData['errors'] as Map<String, dynamic>;
      if (errors.isNotEmpty) {
        List<String> mensajes = [];
        errors.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            mensajes.add('• $key: ${value.join(', ')}');
          } else if (value is String) {
            mensajes.add('• $key: $value');
          }
        });
        if (mensajes.isNotEmpty) {
          return 'Campos inválidos:\n' + mensajes.join('\n');
        }
      }
    }

    String detalle = '';
    if (errorData['error'] != null && errorData['error'] is String) {
      detalle = errorData['error'].toString();
    } else if (errorData['detalle'] != null) {
      detalle = errorData['detalle'].toString();
    }

    String general = '';
    if (errorData['mensaje'] != null) general = errorData['mensaje'].toString();
    else if (errorData['message'] != null) general = errorData['message'].toString();
    else if (errorData['title'] != null) general = errorData['title'].toString();

    if (detalle.isNotEmpty && general.isNotEmpty) {
      // Evitar redundancia si el mensaje general es igual al detalle
      if (general == detalle) return general;
      return '$general\n\nDetalle: $detalle';
    } else if (detalle.isNotEmpty) {
      return detalle;
    } else if (general.isNotEmpty) {
      return general;
    }

    return 'Error en la operación del proveedor';
  }

}