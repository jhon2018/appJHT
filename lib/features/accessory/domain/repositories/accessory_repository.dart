// lib/features/accessory/domain/repositories/accessory_repository.dart
import '../../data/models/segmento_model.dart';
import '../../data/models/tipo_accesorio_model.dart';
import '../../data/models/vehiculo_model.dart';
import '../../data/models/accesorio_registro_dto.dart';
import '../entities/accesorio_entity.dart';


abstract class AccessoryRepository {
  Future<List<SegmentoModel>> listarSegmentos();
  Future<List<TipoAccesorioModel>> listarTiposAccesorioPorSegmento(int segmentoId);
  Future<List<VehiculoModel>> listarVehiculos();

  Future<AccesorioEntity> registrarAccesorio(AccesorioRegistroDto dto);

}