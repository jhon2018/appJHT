//Ruta:  lib/features/conductor/domain/repositories/conductor_repository.dart

import 'package:app_jht_front/features/conductor/data/models/conductor_registro_dto.dart';
import 'package:app_jht_front/features/conductor/data/models/conductor_registro_response.dart';
import 'package:app_jht_front/features/supplier/data/models/tipo_telefono_model.dart';

abstract class ConductorRepository {
  Future<ConductorRegistroResponse> registrarConductor(ConductorRegistroDto dto);
  Future<List<TipoTelefonoModel>> getTiposTelefono();
}