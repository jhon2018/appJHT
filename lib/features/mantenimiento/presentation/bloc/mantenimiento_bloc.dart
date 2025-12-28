// Ruta: lib/features/mantenimiento/presentation/bloc/mantenimiento_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/mantenimiento/data/repositories/mantenimiento_repository.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/bloc/mantenimiento_event.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/bloc/mantenimiento_state.dart';

class MantenimientoBloc extends Bloc<MantenimientoEvent, MantenimientoState> {
  final MantenimientoRepository repository;

  MantenimientoBloc({required this.repository}) : super(MantenimientoInitial()) {
    on<LoadMantenimientosEvent>(_onLoadMantenimientos);
    on<RefreshMantenimientosEvent>(_onRefreshMantenimientos);
  }

  Future<void> _onLoadMantenimientos(
    LoadMantenimientosEvent event,
    Emitter<MantenimientoState> emit,
  ) async {
    emit(MantenimientoLoading());
    try {
      final response = await repository.getMantenimientosPendientes();
      emit(MantenimientoSuccess(response.data));
    } catch (e) {
      emit(MantenimientoError(e.toString()));
    }
  }

  Future<void> _onRefreshMantenimientos(
    RefreshMantenimientosEvent event,
    Emitter<MantenimientoState> emit,
  ) async {
    try {
      final response = await repository.getMantenimientosPendientes();
      emit(MantenimientoSuccess(response.data));
    } catch (e) {
      emit(MantenimientoError(e.toString()));
      // Volver al estado anterior si hay error
      if (state is MantenimientoSuccess) {
        emit(state);
      }
    }
  }
}