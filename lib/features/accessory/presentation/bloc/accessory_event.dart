// lib/features/accessory/presentation/bloc/accessory_event.dart

part of 'accessory_bloc.dart';

abstract class AccessoryEvent {}

class LoadSegmentosEvent extends AccessoryEvent {}

class LoadTiposAccesorioEvent extends AccessoryEvent {
  final int segmentoId;
  LoadTiposAccesorioEvent({required this.segmentoId});
}

class LoadVehiculosEvent extends AccessoryEvent {}

class RegistrarAccesorioEvent extends AccessoryEvent {
  final AccesorioRegistroDto dto;
  RegistrarAccesorioEvent({required this.dto});
}

class RegistrarTipoAccesorioEvent extends AccessoryEvent {
  final TipoAccesorioRegistroDto dto;
  RegistrarTipoAccesorioEvent({required this.dto});
}

class OnFetchVehiculos extends AccessoryEvent {}

class OnFetchAccesoriosByVehiculo extends AccessoryEvent {
  final int vehiculoId;
  OnFetchAccesoriosByVehiculo(this.vehiculoId);
}

class OnFetchDetalleAccesorio extends AccessoryEvent {
  final int accesorioId;
  OnFetchDetalleAccesorio(this.accesorioId);
  @override
  List<Object?> get props => [accesorioId];
}

// ─── REQF08 ───────────────────────────────────────────────────────────────────
class ActualizarAccesorioEvent extends AccessoryEvent {
  final AccesorioActualizarDto dto;
  /// vehiculoId del vehículo actualmente seleccionado en la página,
  /// para recargar la lista tras guardar.
  final int vehiculoIdActual;

  ActualizarAccesorioEvent({
    required this.dto,
    required this.vehiculoIdActual,
  });
}