//Ruta: lib/features/conductor/data/repositories/conductor_repository_impl.dart

import 'package:app_jht_front/features/conductor/data/datasources/conductor_remote_data_source.dart';
import 'package:app_jht_front/features/conductor/domain/repositories/conductor_repository.dart';
import 'package:app_jht_front/features/conductor/data/models/conductor_registro_dto.dart';
import 'package:app_jht_front/features/conductor/data/models/conductor_registro_response.dart';
import 'package:app_jht_front/features/supplier/data/models/tipo_telefono_model.dart';

class ConductorRepositoryImpl implements ConductorRepository {
  final ConductorRemoteDataSource remoteDataSource;

  ConductorRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ConductorRegistroResponse> registrarConductor(ConductorRegistroDto dto) {
    return remoteDataSource.registrarConductor(dto);
  }

  @override
  Future<List<TipoTelefonoModel>> getTiposTelefono() {
    return remoteDataSource.getTiposTelefono();
  }
}
