// Ruta: lib/features/conductor/presentation/bloc/conductor_bloc.dart
import 'dart:async';
import 'package:app_jht_front/features/conductor/data/models/conductor_registro_dto.dart';
import 'package:app_jht_front/features/conductor/data/repositories/conductor_repository_impl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/conductor/domain/usecases/registrar_conductor_usecase.dart';
import 'package:app_jht_front/features/conductor/domain/repositories/conductor_repository.dart';
import 'package:app_jht_front/features/conductor/domain/usecases/listar_personas_usecase.dart';
import 'package:app_jht_front/features/conductor/domain/usecases/obtener_persona_detalle_usecase.dart';
import 'conductor_event.dart';
import 'conductor_state.dart';

class ConductorBloc extends Bloc<ConductorEvent, ConductorState> {
  final RegistrarConductorUseCase registrarConductorUseCase;
  final ListarPersonasUseCase listarPersonasUseCase;
  final ObtenerPersonaDetalleUseCase obtenerPersonaDetalleUseCase;

  ConductorBloc({
    required this.registrarConductorUseCase,
    required this.listarPersonasUseCase,
    required this.obtenerPersonaDetalleUseCase, required ConductorRepositoryImpl repository,
  }) : super(const ConductorState.initial()) {
    on<ConductorEvent>((event, emit) async {
      await event.when(
        registrarConductor: (dto) => _onRegistrarConductor(dto, emit),
        listarPersonas: () => _onListarPersonas(emit),
        obtenerPersonaDetalle: (personaId) => _onObtenerPersonaDetalle(personaId, emit),
      );
    });
  }

  Future<void> _onRegistrarConductor(
    ConductorRegistroDto dto,
    Emitter<ConductorState> emit,
  ) async {
    emit(const ConductorState.loading());
    
    try {
      final response = await registrarConductorUseCase.execute(dto);
      emit(ConductorState.success(response: response));
    } catch (e) {
      emit(ConductorState.error(message: e.toString()));
    }
  }

  Future<void> _onListarPersonas(
    Emitter<ConductorState> emit,
  ) async {
    emit(const ConductorState.personasCargando());
    
    try {
      final response = await listarPersonasUseCase.execute();
      // AQUÍ ESTÁ LA CLAVE: response.data es List<PersonaModel>
      emit(ConductorState.personasCargadas(personas: response.data));
    } catch (e) {
      emit(ConductorState.error(message: e.toString()));
    }
  }

  Future<void> _onObtenerPersonaDetalle(
    int personaId,
    Emitter<ConductorState> emit,
  ) async {
    emit(const ConductorState.personaDetalleCargando());
    
    try {
      final response = await obtenerPersonaDetalleUseCase.execute(personaId);
      emit(ConductorState.personaDetalleCargado(persona: response.data));
    } catch (e) {
      emit(ConductorState.personaDetalleError(message: e.toString()));
    }
  }
}