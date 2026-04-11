// Ruta: lib/features/mantenimiento/presentation/bloc/mantenimiento_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/mantenimiento/data/repositories/mantenimiento_repository.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/bloc/mantenimiento_event.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/bloc/mantenimiento_state.dart';

class MantenimientoBloc extends Bloc<MantenimientoEvent, MantenimientoState> {
  final MantenimientoRepository repository;

  MantenimientoBloc({required this.repository}) : super(MantenimientoInitial()) {
    on<LoadMantenimientosEvent>(_onLoadMantenimientos);
    on<RefreshMantenimientosEvent>(_onRefreshMantenimientos);
    on<LoadDetalleMantenimientoEvent>(_onLoadDetalleMantenimiento);
    on<UpdateMantenimientoEvent>(_onUpdateMantenimiento);
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
  print('🔄 Recargando mantenimientos desde API...');
  try {
    final response = await repository.getMantenimientosPendientes();
    emit(MantenimientoSuccess(response.data));
    print('✅ Mantenimientos recargados: ${response.data.length} registros');
  } catch (e) {
    print('❌ Error al refrescar: $e');
    emit(MantenimientoError(e.toString()));
  }
}

  Future<void> _onLoadDetalleMantenimiento(
    LoadDetalleMantenimientoEvent event,
    Emitter<MantenimientoState> emit,
  ) async {
    emit(DetalleMantenimientoLoading());
    try {
      final response = await repository.getDetalleMantenimiento(
        event.bitacoraId,
        event.accesorioId,
      );
      emit(DetalleMantenimientoSuccess(response.data));
    } catch (e) {
      emit(DetalleMantenimientoError(e.toString()));
    }
  }

  Future<void> _onUpdateMantenimiento(
    UpdateMantenimientoEvent event,
    Emitter<MantenimientoState> emit,
  ) async {
    emit(MantenimientoUpdating());
    try {
      final response = await repository.actualizarMantenimiento(event.request);
      emit(MantenimientoUpdated(response.message));
      // Después de actualizar, recargar la lista
      add(RefreshMantenimientosEvent());
    } catch (e) {
      emit(MantenimientoUpdateError(e.toString()));
    }
  }
}