// lib/features/vehicle/domain/usecases/registrar_vehiculo_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:app_jht_front/core/error/failures.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_registro_dto.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_registro_response.dart';
import 'package:app_jht_front/features/vehicle/domain/repositories/vehicle_repository.dart';

class RegistrarVehiculoUseCase {
  final VehicleRepository repository;

  RegistrarVehiculoUseCase(this.repository);

  Future<Either<Failure, VehicleRegistroResponse>> call(
      VehicleRegistroDto dto) async {
    return await repository.registrarVehiculo(dto);
  }
}