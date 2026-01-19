//Ruta: lib\features\conductor\presentation\bloc\conductor_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app_jht_front/features/conductor/data/models/persona_model.dart';
import 'package:app_jht_front/features/conductor/data/models/conductor_registro_response.dart';

part 'conductor_state.freezed.dart';

@freezed
class ConductorState with _$ConductorState {
  const factory ConductorState.initial() = _Initial;
  const factory ConductorState.loading() = _Loading;
  const factory ConductorState.success({
    required ConductorRegistroResponse response,
  }) = _Success;
  const factory ConductorState.error({
    required String message,
  }) = _Error;

  // ✅ NUEVOS ESTADOS PARA REQF14
  const factory ConductorState.personasCargando() = _PersonasCargando;
  
  const factory ConductorState.personasCargadas({
    required List<PersonaModel> personas,
  }) = _PersonasCargadas;
  
  const factory ConductorState.personaDetalleCargando() = _PersonaDetalleCargando;
  
  const factory ConductorState.personaDetalleCargado({
    required PersonaModel persona,
  }) = _PersonaDetalleCargado;
  
  const factory ConductorState.personaDetalleError({
    required String message,
  }) = _PersonaDetalleError;
}