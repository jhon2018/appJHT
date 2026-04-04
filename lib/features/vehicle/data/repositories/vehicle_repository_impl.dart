// lib/features/vehicle/data/repositories/vehicle_repository_impl.dart
import 'package:app_jht_front/features/vehicle/data/models/vehicle_list_response.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_update_dto.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_update_response.dart';
import 'package:dartz/dartz.dart';
import 'package:app_jht_front/core/error/failures.dart';
import 'package:app_jht_front/features/vehicle/data/datasources/vehicle_remote_data_source.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_registro_dto.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_registro_response.dart';
import 'package:app_jht_front/features/vehicle/domain/repositories/vehicle_repository.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource remoteDataSource;

  const VehicleRepositoryImpl({required this.remoteDataSource}); // ✅ AGREGAR const

  @override
  Future<Either<Failure, VehicleRegistroResponse>> registrarVehiculo(
      VehicleRegistroDto dto) async {
    try {
      final response = await remoteDataSource.registrarVehiculo(dto);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ✅ IMPLEMENTACIÓN CORRECTA
  @override
  Future<Either<Failure, List<VehicleListData>>> getAllVehicles() async {
    try {
      final vehicles = await remoteDataSource.getAllVehicles();
      return Right(vehicles);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

@override
Future<Either<Failure, VehicleUpdateResponse>> actualizarVehiculo(
  VehicleUpdateDto dto,
) async {
  try {
    final response = await remoteDataSource.actualizarVehiculo(dto);
    return Right(response);
  } catch (e) {
    return Left(ServerFailure(message: e.toString()));
  }
}

}