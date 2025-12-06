//Ruta: lib/features/conductor/presentation/bloc/conductor_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app_jht_front/features/conductor/domain/usecases/registrar_conductor_usecase.dart';
import 'package:app_jht_front/features/conductor/data/models/conductor_registro_dto.dart';
import 'package:app_jht_front/features/conductor/data/models/conductor_registro_response.dart';

part 'conductor_event.dart';
part 'conductor_state.dart';
part 'conductor_bloc.freezed.dart';

class ConductorBloc extends Bloc<ConductorEvent, ConductorState> {
  final RegistrarConductorUseCase registrarConductorUseCase;

  ConductorBloc({required this.registrarConductorUseCase})
      : super(const ConductorState.initial()) {
    on<_RegistrarConductor>(_onRegistrarConductor);
  }

  Future<void> _onRegistrarConductor(
    _RegistrarConductor event,
    Emitter<ConductorState> emit,
  ) async {
    emit(const ConductorState.loading());
    
    try {
      final response = await registrarConductorUseCase.execute(event.dto);
      emit(ConductorState.success(response: response));
    } catch (e) {
      emit(ConductorState.error(message: e.toString()));
    }
  }
}
