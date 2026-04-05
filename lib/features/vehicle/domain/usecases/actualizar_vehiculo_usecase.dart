// lib/features/vehicle/domain/usecases/actualizar_vehiculo_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:app_jht_front/core/error/failures.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_update_dto.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_update_response.dart';
import 'package:app_jht_front/features/vehicle/domain/repositories/vehicle_repository.dart';

class ActualizarVehiculoUseCase {
  final VehicleRepository repository;

  // ✅ CONSTRUCTOR POSICIONAL (sin llaves)
  ActualizarVehiculoUseCase(this.repository);

  Future<Either<Failure, VehicleUpdateResponse>> call(
    VehicleUpdateDto dto,
  ) async {
    return await repository.actualizarVehiculo(dto);
  }
}