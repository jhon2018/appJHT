// lib/features/admin/presentation/bloc/historial/historial_mantenimiento_state.dart

import 'package:equatable/equatable.dart';
import 'package:app_jht_front/features/admin/data/models/historial_mantenimiento_model.dart';
import 'package:app_jht_front/features/accessory/data/models/vehiculo_model.dart';
import 'package:app_jht_front/features/accessory/data/models/segmento_model.dart';
import 'package:app_jht_front/features/accessory/data/models/tipo_accesorio_model.dart';

abstract class HistorialMantenimientoState extends Equatable {
  const HistorialMantenimientoState();

  @override
  List<Object?> get props => [];
}

class HistorialInitial extends HistorialMantenimientoState {}

class HistorialLoading extends HistorialMantenimientoState {
  final int? anio;
  final int? vehIid;
  final int? segIid;
  final int? tipIid;
  final bool useMockData;
  final List<VehiculoModel> vehiculos;
  final List<SegmentoModel> segmentos;
  final List<TipoAccesorioModel> accesorios;

  const HistorialLoading({
    this.anio,
    this.vehIid,
    this.segIid,
    this.tipIid,
    this.useMockData = true,
    this.vehiculos = const [],
    this.segmentos = const [],
    this.accesorios = const [],
  });

  @override
  List<Object?> get props => [anio, vehIid, segIid, tipIid, useMockData, vehiculos, segmentos, accesorios];
}

class HistorialLoaded extends HistorialMantenimientoState {
  final HistorialDashboardResponse data;
  final int? anio;
  final int? vehIid;
  final int? segIid;
  final int? tipIid;
  final bool useMockData;
  final List<VehiculoModel> vehiculos;
  final List<SegmentoModel> segmentos;
  final List<TipoAccesorioModel> accesorios;

  const HistorialLoaded({
    required this.data,
    this.anio,
    this.vehIid,
    this.segIid,
    this.tipIid,
    this.useMockData = true,
    required this.vehiculos,
    required this.segmentos,
    required this.accesorios,
  });

  @override
  List<Object?> get props => [data, anio, vehIid, segIid, tipIid, useMockData, vehiculos, segmentos, accesorios];
}

class HistorialError extends HistorialMantenimientoState {
  final String message;
  final int? anio;
  final int? vehIid;
  final int? segIid;
  final int? tipIid;
  final bool useMockData;
  final List<VehiculoModel> vehiculos;
  final List<SegmentoModel> segmentos;
  final List<TipoAccesorioModel> accesorios;

  const HistorialError({
    required this.message,
    this.anio,
    this.vehIid,
    this.segIid,
    this.tipIid,
    this.useMockData = true,
    this.vehiculos = const [],
    this.segmentos = const [],
    this.accesorios = const [],
  });

  @override
  List<Object?> get props => [message, anio, vehIid, segIid, tipIid, useMockData, vehiculos, segmentos, accesorios];
}
