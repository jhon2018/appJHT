// lib/features/accessory/presentation/bloc/accessory_state.dart

part of 'accessory_bloc.dart';

abstract class AccessoryState {}

/// Estados iniciales y generales
class AccessoryInitial extends AccessoryState {}
class AccessoryLoading extends AccessoryState {}

class AccessoryError extends AccessoryState {
  final String message;
  AccessoryError({required this.message});
}

/// Estados de carga de listas / catálogos
class SegmentosLoading extends AccessoryState {}
class SegmentosLoaded extends AccessoryState {
  final List<SegmentoModel> segmentos;
  SegmentosLoaded({required this.segmentos});
}

class TiposAccesorioLoading extends AccessoryState {}
class TiposAccesorioLoaded extends AccessoryState {
  final List<TipoAccesorioModel> tiposAccesorio;
  TiposAccesorioLoaded({required this.tiposAccesorio});
}

class VehiculosLoading extends AccessoryState {}
class VehiculosLoaded extends AccessoryState {
  final List<VehiculoModel> vehiculos;
  VehiculosLoaded({required this.vehiculos});
}

/// Estados para REQF07 - Listado y detalle de accesorios por vehículo
class AccesoriosByVehiculoLoading extends AccessoryState {}
class AccesoriosByVehiculoLoaded extends AccessoryState {
  final List<AccesorioModel> accesorios;
  AccesoriosByVehiculoLoaded({required this.accesorios});
}

class DetalleAccesorioLoading extends AccessoryState {
  final String? nombreAccesorio;
  DetalleAccesorioLoading({this.nombreAccesorio});
}

class DetalleAccesorioLoaded extends AccessoryState {
  final AccesorioDetalleModel detalle;
  DetalleAccesorioLoaded({required this.detalle});
}

/// Estados de registro
class RegistrandoAccesorio extends AccessoryState {}
class AccesorioRegistrado extends AccessoryState {
  final AccesorioRegistroResponse response;
  AccesorioRegistrado({required this.response});
}

class RegistroError extends AccessoryState {
  final String message;
  RegistroError({required this.message});
}

class RegistrandoTipoAccesorio extends AccessoryState {}
class TipoAccesorioRegistrado extends AccessoryState {
  final dynamic response;
  TipoAccesorioRegistrado({required this.response});
}

class TipoAccesorioRegistroError extends AccessoryState {
  final String message;
  TipoAccesorioRegistroError({required this.message});
}

// ─── REQF08 ───────────────────────────────────────────────────────────────────
/// Guardando cambios en API20
class ActualizandoAccesorio extends AccessoryState {}

/// Actualización exitosa — incluye el vehiculoId para que la página
/// pueda recargar automáticamente la lista.
class AccesorioActualizado extends AccessoryState {
  final int vehiculoId;
  AccesorioActualizado({required this.vehiculoId});
}

/// Error al actualizar
class ActualizacionError extends AccessoryState {
  final String message;
  ActualizacionError({required this.message});
}