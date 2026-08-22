// lib/features/admin/presentation/bloc/historial/historial_mantenimiento_state.dart

import 'package:equatable/equatable.dart';
import 'package:app_jht_front/features/admin/data/models/historial_mantenimiento_model.dart';
import 'package:app_jht_front/features/mantenimiento/data/models/accesorio_models.dart';
import 'package:app_jht_front/features/accessory/data/models/vehiculo_model.dart';

abstract class HistorialMantenimientoState extends Equatable {
  const HistorialMantenimientoState();

  @override
  List<Object?> get props => [];
}

class HistorialInitial extends HistorialMantenimientoState {}

class HistorialLoading extends HistorialMantenimientoState {
  final int? anio;
  final int? vehIid;
  final int? tipIid;
  final List<VehiculoModel> vehiculos;
  final List<ConceptoMantenimientoModel> accesorios;

  const HistorialLoading({
    this.anio,
    this.vehIid,
    this.tipIid,
    this.vehiculos = const [],
    this.accesorios = const [],
  });

  @override
  List<Object?> get props => [anio, vehIid, tipIid, vehiculos, accesorios];
}

class HistorialLoaded extends HistorialMantenimientoState {
  final HistorialDashboardResponse data;
  final int? anio;
  final int? vehIid;
  final int? tipIid;
  final List<VehiculoModel> vehiculos;
  final List<ConceptoMantenimientoModel> accesorios;

  const HistorialLoaded({
    required this.data,
    this.anio,
    this.vehIid,
    this.tipIid,
    required this.vehiculos,
    required this.accesorios,
  });

  @override
  List<Object?> get props => [data, anio, vehIid, tipIid, vehiculos, accesorios];
}

class HistorialError extends HistorialMantenimientoState {
  final String message;
  final int? anio;
  final int? vehIid;
  final int? tipIid;
  final List<VehiculoModel> vehiculos;
  final List<ConceptoMantenimientoModel> accesorios;

  const HistorialError({
    required this.message,
    this.anio,
    this.vehIid,
    this.tipIid,
    this.vehiculos = const [],
    this.accesorios = const [],
  });

  @override
  List<Object?> get props => [message, anio, vehIid, tipIid, vehiculos, accesorios];
}
