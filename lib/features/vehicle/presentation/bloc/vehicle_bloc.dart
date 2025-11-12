//Ruta: lib/features/vehicle/presentation/bloc/vehicle_bloc.dart
// Definición: BLoC principal para manejar el estado de vehículos
// Objetivo: Gestionar la lógica de presentación y estado de la feature vehículo
// Uso: flutter pub run build_runner build --delete-conflicting-outputs

import 'package:app_jht_front/features/vehicle/data/models/vehicle_registro_dto.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_registro_response.dart';
// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:app_jht_front/features/vehicle/domain/usecases/registrar_vehiculo_usecase.dart';

part 'vehicle_event.dart';
part 'vehicle_state.dart';
part 'vehicle_bloc.freezed.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final RegistrarVehiculoUseCase registrarVehiculoUseCase;

  VehicleBloc({required this.registrarVehiculoUseCase}) : super(const VehicleState.initial()) {
    on<_RegistrarVehiculo>(_onRegistrarVehiculo);
  }

  Future<void> _onRegistrarVehiculo(
    _RegistrarVehiculo event,
    Emitter<VehicleState> emit,
  ) async {
    emit(const VehicleState.loading());
    
    final result = await registrarVehiculoUseCase(event.dto);
    
    result.fold(
      (failure) => emit(VehicleState.error(message: failure.message)),
      (response) => emit(VehicleState.registroExitoso(response: response)),
    );
  }
} 
