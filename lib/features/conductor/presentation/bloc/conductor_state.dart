//Ruta:  lib/features/conductor/presentation/bloc/conductor_state.dart

part of 'conductor_bloc.dart';

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
}