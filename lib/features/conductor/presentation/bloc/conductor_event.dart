//Ruta: lib/features/conductor/presentation/bloc/conductor_event.dart

part of 'conductor_bloc.dart';

@freezed
class ConductorEvent with _$ConductorEvent {
  const factory ConductorEvent.registrarConductor({
    required ConductorRegistroDto dto,
  }) = _RegistrarConductor;
}