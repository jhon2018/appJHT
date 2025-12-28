// Ruta: lib/features/mantenimiento/presentation/bloc/mantenimiento_state.dart
import 'package:flutter/foundation.dart';
import 'package:app_jht_front/features/mantenimiento/data/models/mantenimiento_model.dart';

@immutable
abstract class MantenimientoState {}

class MantenimientoInitial extends MantenimientoState {}

class MantenimientoLoading extends MantenimientoState {}

class MantenimientoSuccess extends MantenimientoState {
  final List<MantenimientoModel> mantenimientos;

  MantenimientoSuccess(this.mantenimientos);
}

class MantenimientoError extends MantenimientoState {
  final String message;

  MantenimientoError(this.message);
}