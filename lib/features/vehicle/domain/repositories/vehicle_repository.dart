// lib/features/vehicle/domain/repositories/vehicle_repository.dart
import 'package:dartz/dartz.dart';
import 'package:app_jht_front/core/error/failures.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_registro_dto.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_registro_response.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_list_response.dart';

abstract class VehicleRepository {
  Future<Either<Failure, VehicleRegistroResponse>> registrarVehiculo(
      VehicleRegistroDto dto);
  
  Future<Either<Failure, List<VehicleListData>>> getAllVehicles();
}