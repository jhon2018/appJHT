// lib/features/accessory/data/repositories/accessory_repository_impl.dart
import 'package:app_jht_front/features/accessory/data/datasources/accessory_remote_data_source.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_model.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_registro_dto.dart';
import 'package:app_jht_front/features/accessory/data/models/tipo_accesorio_registro_dto.dart';
import 'package:app_jht_front/features/accessory/domain/repositories/accessory_repository.dart';
import 'package:app_jht_front/features/accessory/data/models/segmento_model.dart';
import 'package:app_jht_front/features/accessory/data/models/tipo_accesorio_model.dart';
import 'package:app_jht_front/features/accessory/data/models/vehiculo_model.dart';

import '../../domain/entities/accesorio_entity.dart';

class AccessoryRepositoryImpl implements AccessoryRepository {
  final AccessoryRemoteDataSource remoteDataSource;

  AccessoryRepositoryImpl({required this.remoteDataSource});


@override
  Future<List<VehiculoModel>> getVehiculos() async {
    return await remoteDataSource.listarVehiculos();
  }

  @override
  Future<List<AccesorioModel>> getAccesoriosPorVehiculo(int vehId) async {
    return await remoteDataSource.listarAccesoriosPorVehiculo(vehId);
  }

  @override
  Future<AccesorioModel> getDetalleAccesorio(int accId) async {
    return await remoteDataSource.obtenerDetalleAccesorio(accId);
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

  // En el método registrarAccesorio
  @override
  Future<AccesorioEntity> registrarAccesorio(AccesorioRegistroDto dto) async {
    try {
      print('🔵 Repository: Registrando accesorio');

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
      print('❌ ERROR en repository registrarAccesorio: $e');
      rethrow;
    }
  }

 @override
  Future<dynamic> registrarTipoAccesorio(TipoAccesorioRegistroDto dto) async {
    try {
      print('🔵 Repository: Registrando tipo de accesorio: ${dto.tipoAccesorio.tipVnombre}');
      
      final response = await remoteDataSource.registrarTipoAccesorio(dto);
      
      if (response['status'] != 201 && response['status'] != 200) {
        throw Exception(response['message'] ?? 'Error al registrar tipo de accesorio');
      }
      
      return response;
    } catch (e) {
      print('❌ ERROR en repository registrarTipoAccesorio: $e');
      rethrow;
    }
  }

}
