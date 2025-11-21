/// Definición: Contrato abstracto para el repositorio de vehículos
/// Objetivo: Definir las operaciones disponibles para vehículos

import 'package:app_jht_front/features/vehicle/data/models/vehicle_registro_dto.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_registro_response.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class VehicleRepository {
  Future<Either<Failure, VehicleRegistroResponse>> registrarVehiculo(
      VehicleRegistroDto dto);
}