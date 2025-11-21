// lib/features/accessory/data/repositories/accessory_repository_impl.dart
import 'package:app_jht_front/features/accessory/data/datasources/accessory_remote_data_source.dart';
import 'package:app_jht_front/features/accessory/domain/repositories/accessory_repository.dart';
import 'package:app_jht_front/features/accessory/data/models/segmento_model.dart';
import 'package:app_jht_front/features/accessory/data/models/tipo_accesorio_model.dart';
import 'package:app_jht_front/features/accessory/data/models/vehiculo_model.dart';

class AccessoryRepositoryImpl implements AccessoryRepository {
  final AccessoryRemoteDataSource remoteDataSource;

  AccessoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SegmentoModel>> listarSegmentos() async {
    return await remoteDataSource.listarSegmentos();
  }

  @override
  Future<List<TipoAccesorioModel>> listarTiposAccesorioPorSegmento(int segmentoId) async {
    return await remoteDataSource.listarTiposAccesorioPorSegmento(segmentoId);
  }

  @override
  Future<List<VehiculoModel>> listarVehiculos() async {
    return await remoteDataSource.listarVehiculos();
  }
}