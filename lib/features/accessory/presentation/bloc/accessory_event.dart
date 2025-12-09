// lib/features/accessory/presentation/bloc/accessory_event.dart
// descripción: Definición de eventos para el AccessoryBloc.
// objetivo: Manejar eventos relacionados con la carga de segmentos, tipos de accesorio y vehículos.

part of 'accessory_bloc.dart';

abstract class AccessoryEvent {}

class LoadSegmentosEvent extends AccessoryEvent {}

class LoadTiposAccesorioEvent extends AccessoryEvent {
  final int segmentoId;

  LoadTiposAccesorioEvent({required this.segmentoId});
}

class LoadVehiculosEvent extends AccessoryEvent {}

// Agrega este evento
class RegistrarAccesorioEvent extends AccessoryEvent {
  final AccesorioRegistroDto dto;
  
  RegistrarAccesorioEvent({required this.dto});
}

class RegistrarTipoAccesorioEvent extends AccessoryEvent {
  final TipoAccesorioRegistroDto dto;
  
  RegistrarTipoAccesorioEvent({required this.dto});
}