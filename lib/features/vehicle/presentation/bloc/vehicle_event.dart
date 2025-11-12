//Ruta: lib/features/vehicle/presentation/bloc/vehicle_event.dart
/// Definición: Eventos del BLoC de vehículos
/// Objetivo: Definir las acciones que puede disparar el usuario

part of 'vehicle_bloc.dart';

@freezed
class VehicleEvent with _$VehicleEvent {
  const factory VehicleEvent.registrarVehiculo({
    required VehicleRegistroDto dto,
  }) = _RegistrarVehiculo;
}