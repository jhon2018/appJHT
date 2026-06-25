// lib/features/accessory/data/repositories/accessory_repository_impl.dart
import 'package:app_jht_front/features/accessory/data/datasources/accessory_remote_data_source.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_detalle_model.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_model.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_registro_dto.dart';
import 'package:app_jht_front/features/accessory/data/models/tipo_accesorio_registro_dto.dart';
import 'package:app_jht_front/features/accessory/domain/repositories/accessory_repository.dart';
import 'package:app_jht_front/features/accessory/data/models/segmento_model.dart';
import 'package:app_jht_front/features/accessory/data/models/tipo_accesorio_model.dart';
import 'package:app_jht_front/features/accessory/data/models/vehiculo_model.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_actualizar_dto.dart';

import '../../domain/entities/accesorio_entity.dart';
import 'package:flutter/foundation.dart';

class AccessoryRepositoryImpl implements AccessoryRepository {
  final AccessoryRemoteDataSource remoteDataSource;

  AccessoryRepositoryImpl({required this.remoteDataSource});
  
@override
Future<AccesorioDetalleModel> getAccesorioDetalle(int accId) async {
  // Llama a tu Data Source que conecta con el API 27
  return await remoteDataSource.getAccesorioDetalle(accId);
}




@override
  Future<List<VehiculoModel>> getVehiculos() async {
    return await remoteDataSource.listarVehiculos();
  }

  @override
  Future<List<AccesorioModel>> getAccesoriosPorVehiculo(int vehId) async {
    return await remoteDataSource.listarAccesoriosPorVehiculo(vehId);
  }

@override
Future<AccesorioDetalleModel> getDetalleAccesorio(int accId) async {
  // Llama a tu Data Source que conecta con el API 27
  return await remoteDataSource.getAccesorioDetalle(accId);
}

  @override
  Future<List<SegmentoModel>> listarSegmentos() async {
    return await remoteDataSource.listarSegmentos();
  }

  @override
  Future<List<TipoAccesorioModel>> listarTiposAccesorioPorSegmento(
    int segmentoId,
  ) async {
    return await remoteDataSource.listarTiposAccesorioPorSegmento(segmentoId);
  }

  @override
  Future<List<VehiculoModel>> listarVehiculos() async {
    return await remoteDataSource.listarVehiculos();
  }

  @override
  Future<void> actualizarAccesorio(AccesorioActualizarDto dto) async {
    return await remoteDataSource.actualizarAccesorio(dto);
  }

  // En el método registrarAccesorio
  @override
  Future<AccesorioEntity> registrarAccesorio(AccesorioRegistroDto dto) async {
    try {
      debugPrint('🔵 Repository: Registrando accesorio');

      // Llamar al datasource
      final response = await remoteDataSource.insertarAccesorio(dto);

      // Verificar si fue exitoso (status = "OK")
      if (response.status != 'OK') {
        throw Exception(response.message);
      }

      // Mapear respuesta a entidad
      return AccesorioEntity(
        id: response.data?['idAccesorio'] ?? 0, // <-- Cambiado aquí
        marca: dto.marca,
        codigoFabricante: dto.codigoFabricante,
        fechaInstalacion: dto.fechaInstalacion,
        kilometrajeInstalacion: dto.kilometrajeInstalacion,
        estado: dto.estado,
        observacion: dto.observacion,
        vehiculoId: dto.vehiculoId,
        tipoAccesorioId: dto.tipoAccesorioId,
      );
    } catch (e) {
      debugPrint('❌ ERROR en repository registrarAccesorio: $e');
      rethrow;
    }
  }

 @override
  Future<dynamic> registrarTipoAccesorio(TipoAccesorioRegistroDto dto) async {
    try {
      debugPrint('🔵 Repository: Registrando tipo de accesorio: ${dto.tipoAccesorio.tipVnombre}');
      
      final response = await remoteDataSource.registrarTipoAccesorio(dto);
      
      if (response['status'] != 201 && response['status'] != 200) {
        throw Exception(response['message'] ?? 'Error al registrar tipo de accesorio');
      }
      
      return response;
    } catch (e) {
      debugPrint('❌ ERROR en repository registrarTipoAccesorio: $e');
      rethrow;
    }
  }

}
