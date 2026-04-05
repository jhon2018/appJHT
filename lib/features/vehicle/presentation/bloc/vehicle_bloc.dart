// lib/features/vehicle/presentation/bloc/vehicle_bloc.dart
import 'package:app_jht_front/features/vehicle/data/models/vehicle_list_response.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_registro_dto.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_registro_response.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_update_dto.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_update_response.dart';
import 'package:app_jht_front/features/vehicle/domain/usecases/actualizar_vehiculo_usecase.dart';
import 'package:app_jht_front/features/vehicle/domain/usecases/registrar_vehiculo_usecase.dart';
import 'package:app_jht_front/features/vehicle/domain/usecases/listar_vehiculos_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle_event.dart';
part 'vehicle_state.dart';
part 'vehicle_bloc.freezed.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final RegistrarVehiculoUseCase registrarVehiculoUseCase;
  final ListarVehiculosUseCase listarVehiculosUseCase;
  final ActualizarVehiculoUseCase actualizarVehiculoUseCase;

  VehicleBloc({
    required this.registrarVehiculoUseCase,
    required this.listarVehiculosUseCase,
    required this.actualizarVehiculoUseCase

  }) : super(const VehicleState.initial()) {
    on<_RegistrarVehiculo>(_onRegistrarVehiculo);
    on<_CargarVehiculos>(_onCargarVehiculos);
    on<_ActualizarVehiculo>(_onActualizarVehiculo);
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

  Future<void> _onCargarVehiculos(
    _CargarVehiculos event,
    Emitter<VehicleState> emit,
  ) async {
    emit(const VehicleState.loading());
    
    final result = await listarVehiculosUseCase();
    
    result.fold(
      (failure) => emit(VehicleState.error(message: failure.message)),
      (vehicles) => emit(VehicleState.vehiculosCargados(vehicles: vehicles)),
    );
  }

Future<void> _onActualizarVehiculo(
  _ActualizarVehiculo event,
  Emitter<VehicleState> emit,
) async {
  print('🔵 BLoC: Iniciando actualización de vehículo');
  emit(const VehicleState.loading());
  
  final result = await actualizarVehiculoUseCase(event.dto);
  
  result.fold(
    (failure) {
      print('❌ BLoC: Error en actualización: ${failure.message}');
      emit(VehicleState.error(message: failure.message));
    },
    (response) {
      print('✅ BLoC: Actualización exitosa: ${response.message}');
      emit(VehicleState.actualizacionExitosa(response: response));
    },
  );
}


}