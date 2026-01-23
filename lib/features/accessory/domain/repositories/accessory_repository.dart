// lib/features/accessory/domain/repositories/accessory_repository.dart
import 'package:app_jht_front/features/accessory/data/models/accesorio_detalle_model.dart';

import '../../data/models/segmento_model.dart';
import '../../data/models/tipo_accesorio_model.dart';
import '../../data/models/vehiculo_model.dart';
import '../../data/models/accesorio_registro_dto.dart';
import '../../data/models/tipo_accesorio_registro_dto.dart';
import '../entities/accesorio_entity.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_model.dart';


abstract class AccessoryRepository {
  Future<List<SegmentoModel>> listarSegmentos();
  Future<List<TipoAccesorioModel>> listarTiposAccesorioPorSegmento(int segmentoId);
  Future<List<VehiculoModel>> listarVehiculos();

  Future<AccesorioEntity> registrarAccesorio(AccesorioRegistroDto dto);

  Future<dynamic> registrarTipoAccesorio(TipoAccesorioRegistroDto dto);
  Future<List<VehiculoModel>> getVehiculos();
  Future<List<AccesorioModel>> getAccesoriosPorVehiculo(int vehId);
  // Future<AccesorioModel> getDetalleAccesorio(int accId);

  Future<AccesorioDetalleModel> getDetalleAccesorio(int accId);

  // Ya tienes este método, puedes dejarlo o usarlo como el principal
  // Future<AccesorioDetalleModel> getAccesorioDetalle(int id);

}