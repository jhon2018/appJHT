// lib/features/admin/presentation/bloc/historial/historial_mantenimiento_event.dart

import 'package:equatable/equatable.dart';

abstract class HistorialMantenimientoEvent extends Equatable {
  const HistorialMantenimientoEvent();

  @override
  List<Object?> get props => [];
}

class LoadHistorialEvent extends HistorialMantenimientoEvent {}

class ChangeFilterVehiculoEvent extends HistorialMantenimientoEvent {
  final int? vehIid;
  const ChangeFilterVehiculoEvent(this.vehIid);

  @override
  List<Object?> get props => [vehIid];
}

class ChangeFilterAccesorioEvent extends HistorialMantenimientoEvent {
  final int? tipIid;
  const ChangeFilterAccesorioEvent(this.tipIid);

  @override
  List<Object?> get props => [tipIid];
}

class ChangeFilterAnioEvent extends HistorialMantenimientoEvent {
  final int? anio;
  const ChangeFilterAnioEvent(this.anio);

  @override
  List<Object?> get props => [anio];
}
