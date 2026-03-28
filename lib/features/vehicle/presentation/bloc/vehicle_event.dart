// lib/features/vehicle/presentation/bloc/vehicle_event.dart
part of 'vehicle_bloc.dart';

@freezed
class VehicleEvent with _$VehicleEvent {
  const factory VehicleEvent.registrarVehiculo({
    required VehicleRegistroDto dto,
  }) = _RegistrarVehiculo;
  
  const factory VehicleEvent.cargarVehiculos() = _CargarVehiculos;
}