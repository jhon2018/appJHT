// lib/features/accessory/data/datasources/accessory_remote_data_source.dart

import 'package:app_jht_front/features/accessory/data/models/accesorio_detalle_model.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_model.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_actualizar_dto.dart';
import 'package:app_jht_front/features/accessory/data/models/tipo_accesorio_registro_dto.dart';
import '../models/accesorio_registro_dto.dart';
import '../models/accesorio_registro_response.dart';

import 'dart:convert';
import 'package:app_jht_front/core/network/http_client.dart';
import 'package:app_jht_front/core/network/base_remote_data_source.dart';
import 'package:app_jht_front/core/utils/app_logger.dart';
import 'package:app_jht_front/features/accessory/data/models/segmento_model.dart';
import 'package:app_jht_front/features/accessory/data/models/tipo_accesorio_model.dart';
import 'package:app_jht_front/features/accessory/data/models/vehiculo_model.dart';

// INTERFAZ ABSTRACTA
abstract class AccessoryRemoteDataSource {
  Future<List<SegmentoModel>> listarSegmentos();
  Future<List<TipoAccesorioModel>> listarTiposAccesorioPorSegmento(int segmentoId);
  Future<List<VehiculoModel>> listarVehiculos();
  Future<AccesorioRegistroResponse> insertarAccesorio(AccesorioRegistroDto dto);
  Future<Map<String, dynamic>> registrarTipoAccesorio(TipoAccesorioRegistroDto dto);
  Future<List<AccesorioModel>> listarAccesoriosPorVehiculo(int vehId);
  Future<AccesorioModel> obtenerDetalleAccesorio(int accId);
  Future<AccesorioDetalleModel> getAccesorioDetalle(int accId);
  Future<void> actualizarAccesorio(AccesorioActualizarDto dto);
}

// IMPLEMENTACIÓN
class AccessoryRemoteDataSourceImpl extends BaseRemoteDataSource 
    implements AccessoryRemoteDataSource {
  
  final HttpClient httpClient;
  AccessoryRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<AccesorioRegistroResponse> insertarAccesorio(AccesorioRegistroDto dto) async {
    final response = await protectedPost('/api/general/insertar-accesorio', dto.toJson());

    if (response.statusCode == 200) {
      // dto.marca es el campo correcto en AccesorioRegistroDto
      AppLogger.audit('Accesorio registrado: ${dto.marca}', action: 'CREATE', entity: 'Accesorio', source: 'AccessoryRemoteDataSource');
      return AccesorioRegistroResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception(getErrorMessage(json.decode(response.body)));
    }
  }

  @override
  Future<List<SegmentoModel>> listarSegmentos() async {
    final response = await protectedGet('/api/admin/listar_segmento_accesorio');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => SegmentoModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar segmentos: ${response.statusCode}');
    }
  }

  @override
  Future<List<TipoAccesorioModel>> listarTiposAccesorioPorSegmento(int segmentoId) async {
    final response = await protectedGet('/api/general/listar-tipos-accesorio-por-segmento/$segmentoId');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      if (data.isNotEmpty) {
        final List<dynamic> tiposData = data[0]['tipos'];
        return tiposData.map((json) => TipoAccesorioModel.fromJson(json)).toList();
      }
      return [];
    } else {
      throw Exception('Error al cargar tipos de accesorio: ${response.statusCode}');
    }
  }

  @override
  Future<List<VehiculoModel>> listarVehiculos() async {
    final response = await protectedGet('/api/general/listar-vehiculos');

    if (response.statusCode == 200) {
      final List<dynamic> vehiculosData = json.decode(response.body)['data'][0]['vehiculos'];
      return vehiculosData.map((json) => VehiculoModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar vehículos: ${response.statusCode}');
    }
  }

  @override
  Future<Map<String, dynamic>> registrarTipoAccesorio(TipoAccesorioRegistroDto dto) async {
    final response = await protectedPost('/api/admin/registro_tipo_accesorio', dto.toJson());

    if (response.statusCode == 201 || response.statusCode == 200) {
      // tipVnombre está en dto.tipoAccesorio.tipVnombre
      AppLogger.audit('Tipo de accesorio registrado: ${dto.tipoAccesorio.tipVnombre}', action: 'CREATE', entity: 'TipoAccesorio', source: 'AccessoryRemoteDataSource');
      return json.decode(response.body);
    } else {
      throw Exception('Error al registrar tipo: ${response.statusCode}');
    }
  }

  @override
  Future<List<AccesorioModel>> listarAccesoriosPorVehiculo(int vehId) async {
    final response = await protectedGet('/api/general/vehiculo/$vehId/accesorios');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => AccesorioModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar accesorios: ${response.statusCode}');
    }
  }

  @override
  Future<AccesorioModel> obtenerDetalleAccesorio(int accId) async {
    final response = await protectedGet('/api/general/accesorio/$accId');

    if (response.statusCode == 200) {
      return AccesorioModel.fromJson(json.decode(response.body)['data']);
    } else {
      throw Exception('Error al obtener detalle: ${response.statusCode}');
    }
  }

  @override
  Future<AccesorioDetalleModel> getAccesorioDetalle(int accId) async {
    final response = await protectedGet('/api/general/accesorio/$accId');

    if (response.statusCode == 200) {
      return AccesorioDetalleModel.fromJson(json.decode(response.body)['data']);
    } else {
      throw Exception('Error al obtener detalle completo: ${response.statusCode}');
    }
  }

  @override
  Future<void> actualizarAccesorio(AccesorioActualizarDto dto) async {
    final response = await protectedPut('/api/general/actualizar-accesorio', dto.toJson());

    if (response.statusCode == 200) {
      AppLogger.audit('Accesorio actualizado ID: ${dto.accesorioId}', action: 'UPDATE', entity: 'Accesorio', source: 'AccessoryRemoteDataSource');
    } else {
      throw Exception('Error al actualizar accesorio: ${response.statusCode}');
    }
  }
}