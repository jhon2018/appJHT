// Ruta: lib/features/conductor/presentation/bloc/conductor_event.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app_jht_front/features/conductor/data/models/conductor_registro_dto.dart';
import 'package:app_jht_front/features/conductor/data/models/persona_actualizar_dto.dart';

part 'conductor_event.freezed.dart';

@freezed
class ConductorEvent with _$ConductorEvent {
  const factory ConductorEvent.registrarConductor({
    required ConductorRegistroDto dto,
  }) = _RegistrarConductor;

  const factory ConductorEvent.listarPersonas() = _ListarPersonas;
  
  const factory ConductorEvent.obtenerPersonaDetalle({
    required int personaId,
  }) = _ObtenerPersonaDetalle;

  const factory ConductorEvent.actualizarPersona({
    required PersonaActualizarDto dto,
  }) = _ActualizarPersona;

  // 🔥 NUEVO EVENTO PARA LOS TELÉFONOS
  const factory ConductorEvent.cargarTiposTelefono() = _CargarTiposTelefono;
}