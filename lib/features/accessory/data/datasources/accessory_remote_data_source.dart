// lib/features/accessory/data/datasources/accessory_remote_data_source.dart
// Descripción: Implementación del datasource remoto para accesorios, incluyendo métodos para listar segmentos, tipos de accesorio y vehículos con autenticación.
// Objetivo: Completar la implementación del datasource remoto para accesorios.
import '../models/accesorio_registro_dto.dart';
import '../models/accesorio_registro_response.dart';

import 'dart:convert';
import 'package:app_jht_front/core/network/http_client.dart';
import 'package:app_jht_front/core/utils/token_service.dart';
import 'package:app_jht_front/features/accessory/data/models/segmento_model.dart';
import 'package:app_jht_front/features/accessory/data/models/tipo_accesorio_model.dart';
import 'package:app_jht_front/features/accessory/data/models/vehiculo_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

// INTERFAZ ABSTRACTRA (igual que en Vehicle)
abstract class AccessoryRemoteDataSource {
  Future<List<SegmentoModel>> listarSegmentos();
  Future<List<TipoAccesorioModel>> listarTiposAccesorioPorSegmento(
    int segmentoId,
  );
  Future<List<VehiculoModel>> listarVehiculos();
  Future<AccesorioRegistroResponse> insertarAccesorio(AccesorioRegistroDto dto);
}

// IMPLEMENTACIÓN (igual que en Vehicle)
class AccessoryRemoteDataSourceImpl implements AccessoryRemoteDataSource {
  final DevHttpClient httpClient;

  AccessoryRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<AccesorioRegistroResponse> insertarAccesorio(
    AccesorioRegistroDto dto,
  ) async {
    try {
      print('🔵 Iniciando registro de accesorio');

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

      print('📡 Enviando DTO: ${dto.toJson()}');

      final response = await http.post(
        Uri.parse('${getBaseUrl()}/api/general/insertar-accesorio'),
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
        final Map<String, dynamic> responseData = json.decode(response.body);
        return AccesorioRegistroResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Token inválido o expirado.');
      } else {
        throw Exception('Error al registrar accesorio: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR en insertarAccesorio: $e');
      rethrow;
    }
  }

  @override
  Future<List<SegmentoModel>> listarSegmentos() async {
    try {
      print('🔵 Iniciando carga de segmentos');

      final String? token = await TokenService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'No hay token de autenticación. Por favor inicie sesión nuevamente.',
        );
      }

      String getBaseUrl() {
        if (kIsWeb) {
          return 'http://localhost:7030';
        } else {
          return 'http://192.168.1.2:7030';
        }
      }

      final response = await http.get(
        Uri.parse('${getBaseUrl()}/api/admin/listar_segmento_accesorio'),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      print('🟡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'];
        return data.map((json) => SegmentoModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Token inválido o expirado.');
      } else {
        throw Exception('Error al cargar segmentos: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR en listarSegmentos: $e');
      rethrow;
    }
  }

  @override
  Future<List<TipoAccesorioModel>> listarTiposAccesorioPorSegmento(
    int segmentoId,
  ) async {
    try {
      print('🔵 Iniciando carga de tipos accesorio para segmento: $segmentoId');

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
        Uri.parse(
          '${getBaseUrl()}/api/general/listar-tipos-accesorio-por-segmento/$segmentoId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      print('🟡 Response status: ${response.statusCode}');
      print('🟡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'];

        // CORRECCIÓN AQUÍ:
        if (data.isNotEmpty) {
          final Map<String, dynamic> firstItem = data[0];
          final List<dynamic> tiposData = firstItem['tipos'];

          print('🟡 Tipos encontrados: ${tiposData.length}');

          return tiposData
              .map((json) => TipoAccesorioModel.fromJson(json))
              .toList();
        } else {
          print('🟡 No hay datos en la respuesta');
          return [];
        }
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Token inválido o expirado.');
      } else {
        throw Exception(
          'Error al cargar tipos de accesorio: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ ERROR en listarTiposAccesorioPorSegmento: $e');
      rethrow;
    }
  }

  @override
  Future<List<VehiculoModel>> listarVehiculos() async {
    try {
      print('🔵 Iniciando carga de vehículos');

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
        Uri.parse('${getBaseUrl()}/api/general/listar-vehiculos'),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      print('🟡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> vehiculosData =
            responseData['data'][0]['vehiculos'];
        return vehiculosData
            .map((json) => VehiculoModel.fromJson(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Token inválido o expirado.');
      } else {
        throw Exception('Error al cargar vehículos: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR en listarVehiculos: $e');
      rethrow;
    }
  }
}
