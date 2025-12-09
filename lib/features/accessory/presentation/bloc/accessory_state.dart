// lib/features/accessory/presentation/bloc/accessory_state.dart
// description: Definición de estados para el AccessoryBloc.
// objetivo: Representar los diferentes estados durante la carga de segmentos, tipos de accesorio y vehículos.

part of 'accessory_bloc.dart';

abstract class AccessoryState {}

class AccessoryInitial extends AccessoryState {}

class AccessoryLoading extends AccessoryState {}

class SegmentosLoading extends AccessoryState {}
class TiposAccesorioLoading extends AccessoryState {}
class VehiculosLoading extends AccessoryState {}

class AccessoryError extends AccessoryState {
  final String message;

  AccessoryError({required this.message});
}

class SegmentosLoaded extends AccessoryState {
  final List<SegmentoModel> segmentos;

  SegmentosLoaded({required this.segmentos});
}

class TiposAccesorioLoaded extends AccessoryState {
  final List<TipoAccesorioModel> tiposAccesorio;

  TiposAccesorioLoaded({required this.tiposAccesorio});
}

class VehiculosLoaded extends AccessoryState {
  final List<VehiculoModel> vehiculos;

  VehiculosLoaded({required this.vehiculos});
}


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