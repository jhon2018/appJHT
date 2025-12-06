//Ruta:  lib/features/conductor/domain/usecases/registrar_conductor_usecase.dart  

import 'package:app_jht_front/features/conductor/domain/repositories/conductor_repository.dart';
import 'package:app_jht_front/features/conductor/data/models/conductor_registro_dto.dart';
import 'package:app_jht_front/features/conductor/data/models/conductor_registro_response.dart';

class RegistrarConductorUseCase {
  final ConductorRepository repository;

  RegistrarConductorUseCase({required this.repository});

  Future<ConductorRegistroResponse> execute(ConductorRegistroDto dto) {
    return repository.registrarConductor(dto);
  }
}