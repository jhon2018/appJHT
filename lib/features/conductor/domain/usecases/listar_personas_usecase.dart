//Ruta: lib/features/conductor/domain/usecases/listar_personas_usecase.dart
import 'package:app_jht_front/features/conductor/domain/repositories/conductor_repository.dart';
import 'package:app_jht_front/features/conductor/data/models/persona_list_response.dart';

class ListarPersonasUseCase {
  final ConductorRepository repository;

  ListarPersonasUseCase({required this.repository});

  Future<PersonaListResponse> execute() {
    return repository.listarPersonas();
  }
}