//Ruta: lib/features/vehicle/presentation/bloc/vehicle_state.dart
// Definición: Estados del BLoC de vehículos  
// Objetivo: Representar los diferentes estados de la UI

part of 'vehicle_bloc.dart';

@freezed
class VehicleState with _$VehicleState {
  const factory VehicleState.initial() = _Initial;
  const factory VehicleState.loading() = _Loading;
  const factory VehicleState.registroExitoso({
    required VehicleRegistroResponse response,
  }) = _RegistroExitoso;
  const factory VehicleState.error({
    required String message,
  }) = _Error;
}
