// lib/features/vehicle/presentation/bloc/vehicle_state.dart
part of 'vehicle_bloc.dart';

@freezed
class VehicleState with _$VehicleState {
  const factory VehicleState.initial() = _Initial;
  const factory VehicleState.loading() = _Loading;
  const factory VehicleState.registroExitoso({
    required VehicleRegistroResponse response,
  }) = _RegistroExitoso;
  
  const factory VehicleState.vehiculosCargados({
    required List<VehicleListData> vehicles,
  }) = _VehiculosCargados;
  
  const factory VehicleState.error({
    required String message,
  }) = _Error;
}