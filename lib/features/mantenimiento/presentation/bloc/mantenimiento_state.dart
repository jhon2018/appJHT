// Ruta: lib/features/mantenimiento/presentation/bloc/mantenimiento_state.dart
import 'package:flutter/foundation.dart';
import 'package:app_jht_front/features/mantenimiento/data/models/mantenimiento_model.dart';
import 'package:app_jht_front/features/mantenimiento/data/models/detalle_mantenimiento_model.dart';

@immutable
abstract class MantenimientoState {
  const MantenimientoState(); // ✅ Agregar constructor const
}

class MantenimientoInitial extends MantenimientoState {
  const MantenimientoInitial();
}

class MantenimientoLoading extends MantenimientoState {
  const MantenimientoLoading();
}

class MantenimientoSuccess extends MantenimientoState {
  final List<MantenimientoModel> mantenimientos;

  const MantenimientoSuccess(this.mantenimientos);
}

class MantenimientoError extends MantenimientoState {
  final String message;

  const MantenimientoError(this.message);
}

class DetalleMantenimientoLoading extends MantenimientoState {
  const DetalleMantenimientoLoading();
}

class DetalleMantenimientoSuccess extends MantenimientoState {
  final DetalleMantenimientoModel detalle;

  const DetalleMantenimientoSuccess(this.detalle);
}

class DetalleMantenimientoError extends MantenimientoState {
  final String message;

  const DetalleMantenimientoError(this.message);
}

class MantenimientoUpdating extends MantenimientoState {
  const MantenimientoUpdating();
}

class MantenimientoUpdated extends MantenimientoState {
  final String message;

  const MantenimientoUpdated(this.message);
}

class MantenimientoUpdateError extends MantenimientoState {
  final String message;

  const MantenimientoUpdateError(this.message);
}