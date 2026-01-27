//Ruta: lib/features/conductor/domain/usecases/obtener_persona_detalle_usecase.dart
import 'package:app_jht_front/features/conductor/domain/repositories/conductor_repository.dart';
import 'package:app_jht_front/features/conductor/data/models/persona_detalle_response.dart';

class ObtenerPersonaDetalleUseCase {
  final ConductorRepository repository;

  ObtenerPersonaDetalleUseCase({required this.repository});

  Future<PersonaDetalleResponse> execute(int personaId) {
    return repository.obtenerPersonaDetalle(personaId);
  }
}