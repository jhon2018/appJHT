// Ruta: lib/features/vehicle/data/repositories/vehicle_repository_impl.dart
/// Definición: Implementación concreta del repositorio de vehículos
/// Objetivo: Orquestar las fuentes de datos y manejar errores

import 'package:dartz/dartz.dart';
import 'package:app_jht_front/core/error/failures.dart';
import 'package:app_jht_front/features/vehicle/data/datasources/vehicle_remote_data_source.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_registro_dto.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_registro_response.dart';
import 'package:app_jht_front/features/vehicle/domain/repositories/vehicle_repository.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource remoteDataSource;

  VehicleRepositoryImpl({required this.remoteDataSource});

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
}