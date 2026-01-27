// Ruta: lib/features/conductor/domain/usecases/actualizar_persona_usecase.dart

import 'package:app_jht_front/features/conductor/domain/repositories/conductor_repository.dart';
import 'package:app_jht_front/features/conductor/data/models/persona_actualizar_dto.dart';
import 'package:app_jht_front/features/conductor/data/models/persona_actualizar_response.dart';

class ActualizarPersonaUseCase {
  final ConductorRepository repository;

  ActualizarPersonaUseCase({required this.repository});

  Future<PersonaActualizarResponse> execute(PersonaActualizarDto dto) {
    return repository.actualizarPersona(dto);
  }
}