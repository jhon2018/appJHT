// conductor_event.dart - ARCHIVO CORREGIDO
//Ruta: lib\features\conductor\presentation\bloc\conductor_event.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app_jht_front/features/conductor/data/models/conductor_registro_dto.dart';

part 'conductor_event.freezed.dart';

@freezed
class ConductorEvent with _$ConductorEvent {
  const factory ConductorEvent.registrarConductor({
    required ConductorRegistroDto dto,
  }) = _RegistrarConductor;

  // ✅ NUEVOS EVENTOS PARA REQF14
  const factory ConductorEvent.listarPersonas() = _ListarPersonas;
  
  const factory ConductorEvent.obtenerPersonaDetalle({
    required int personaId,
  }) = _ObtenerPersonaDetalle;
}