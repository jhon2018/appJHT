// Ruta: lib/features/conductor/presentation/bloc/conductor_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:app_jht_front/features/conductor/data/models/conductor_registro_dto.dart';
import 'package:app_jht_front/features/conductor/data/models/persona_actualizar_dto.dart';
import 'package:app_jht_front/features/conductor/data/models/persona_model.dart';
import 'package:app_jht_front/features/conductor/domain/usecases/registrar_conductor_usecase.dart';
import 'package:app_jht_front/features/conductor/domain/usecases/listar_personas_usecase.dart';
import 'package:app_jht_front/features/conductor/domain/usecases/obtener_persona_detalle_usecase.dart';
import 'package:app_jht_front/features/conductor/domain/usecases/actualizar_persona_usecase.dart';
import 'package:app_jht_front/features/conductor/domain/repositories/conductor_repository.dart';
import 'conductor_event.dart';
import 'conductor_state.dart';

class ConductorBloc extends Bloc<ConductorEvent, ConductorState> {
  final RegistrarConductorUseCase registrarConductorUseCase;
  final ListarPersonasUseCase listarPersonasUseCase;
  final ObtenerPersonaDetalleUseCase obtenerPersonaDetalleUseCase;
  final ActualizarPersonaUseCase actualizarPersonaUseCase;
  final ConductorRepository conductorRepository;

  // Cache de la última lista cargada para restaurar la tabla
  // tras un error de registro sin afectar la visualización.
  List<PersonaModel>? _lastLoadedPersonas;

  ConductorBloc({
    required this.registrarConductorUseCase,
    required this.listarPersonasUseCase,
    required this.obtenerPersonaDetalleUseCase,
    required this.actualizarPersonaUseCase,
    required this.conductorRepository,
  }) : super(const ConductorState.initial()) {
    on<ConductorEvent>((event, emit) async {
      await event.when(
        registrarConductor: (dto) => _onRegistrarConductor(dto, emit),
        listarPersonas: () => _onListarPersonas(emit),
        obtenerPersonaDetalle: (personaId) => _onObtenerPersonaDetalle(personaId, emit),
        actualizarPersona: (dto) => _onActualizarPersona(dto, emit),
        cargarTiposTelefono: () => _onCargarTiposTelefono(emit),
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
      // Emitir error para que el BlocListener del modal muestre el diálogo
      emit(ConductorState.error(message: e.toString()));

      // Restaurar la tabla inmediatamente: si la lista estaba cargada,
      // re-emitirla para que el BlocBuilder de la tabla no quede en estado error.
      if (_lastLoadedPersonas != null) {
        emit(ConductorState.personasCargadas(personas: _lastLoadedPersonas!));
      }
    }
  }

  Future<void> _onListarPersonas(
    Emitter<ConductorState> emit,
  ) async {
    emit(const ConductorState.personasCargando());
    
    try {
      final response = await listarPersonasUseCase.execute();
      _lastLoadedPersonas = response.data;
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

  Future<void> _onActualizarPersona(
    PersonaActualizarDto dto,
    Emitter<ConductorState> emit,
  ) async {
    emit(const ConductorState.personaActualizando());
    
    try {
      final response = await actualizarPersonaUseCase.execute(dto);
      emit(ConductorState.personaActualizada(response: response));
      
      // Opcional: Recargar la lista de personas después de actualizar
      add(const ConductorEvent.listarPersonas());
    } catch (e) {
      emit(ConductorState.personaActualizacionError(message: e.toString()));
    }
  }

Future<void> _onCargarTiposTelefono(Emitter<ConductorState> emit) async {
    emit(const ConductorState.tiposTelefonoCargando());
    try {
      final tipos = await conductorRepository.getTiposTelefono();
      emit(ConductorState.tiposTelefonoCargados(tipos: tipos));
    } catch (e) {
      emit(ConductorState.tiposTelefonoError(message: e.toString()));
    }
  }

}