// lib/features/vehicle/domain/usecases/listar_vehiculos_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:app_jht_front/core/error/failures.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_list_response.dart';
import 'package:app_jht_front/features/vehicle/domain/repositories/vehicle_repository.dart';

class ListarVehiculosUseCase {
  final VehicleRepository repository;

  ListarVehiculosUseCase(this.repository);

  Future<Either<Failure, List<VehicleListData>>> call() {
    return repository.getAllVehicles();
  }
}