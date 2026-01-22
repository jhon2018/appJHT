// lib/features/accessory/presentation/bloc/accessory_state.dart
// lib/features/accessory/presentation/bloc/accessory_state.dart
part of 'accessory_bloc.dart';

abstract class AccessoryState {}

// --- ESTADOS INICIALES Y CARGA GENERAL ---
class AccessoryInitial extends AccessoryState {}
class AccessoryLoading extends AccessoryState {}

class AccessoryError extends AccessoryState {
  final String message;
  AccessoryError({required this.message});
}

// --- ESTADOS DE CARGA ESPECÍFICOS ---
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

// --- NUEVOS: ESTADOS PARA REQF07 (TABLA Y DETALLE) ---
class AccesoriosByVehiculoLoading extends AccessoryState {}
class AccesoriosByVehiculoLoaded extends AccessoryState {
  final List<AccesorioModel> accesorios;
  AccesoriosByVehiculoLoaded({required this.accesorios});
}

class DetalleAccesorioLoading extends AccessoryState {}
class DetalleAccesorioLoaded extends AccessoryState {
  final AccesorioModel detalle;
  DetalleAccesorioLoaded({required this.detalle});
}

// --- ESTADOS DE REGISTRO ---
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