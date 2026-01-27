// Ruta: lib/features/conductor/presentation/bloc/conductor_state.dart
import 'package:app_jht_front/features/conductor/presentation/widgets/editar_persona_modal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app_jht_front/features/conductor/data/models/persona_model.dart';
import 'package:app_jht_front/features/conductor/data/models/conductor_registro_response.dart';
import 'package:app_jht_front/features/conductor/data/models/persona_actualizar_response.dart';
import 'package:app_jht_front/features/supplier/data/models/tipo_telefono_model.dart'; // Importante
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

  const factory ConductorState.personaActualizando() = _PersonaActualizando;
  
  const factory ConductorState.personaActualizada({
    required PersonaActualizarResponse response,
  }) = _PersonaActualizada;
  
  const factory ConductorState.personaActualizacionError({
    required String message,
  }) = _PersonaActualizacionError;

const factory ConductorState.tiposTelefonoCargando() = _TiposTelefonoCargando;
  const factory ConductorState.tiposTelefonoCargados({
    required List<TipoTelefonoModel> tipos,
  }) = _TiposTelefonoCargados;
  const factory ConductorState.tiposTelefonoError({
    required String message,
  }) = _TiposTelefonoError;


}