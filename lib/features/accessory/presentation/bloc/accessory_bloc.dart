// lib/features/accessory/presentation/bloc/accessory_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_registro_dto.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_registro_response.dart';
import 'package:app_jht_front/features/accessory/data/models/tipo_accesorio_registro_dto.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_model.dart';
import 'package:app_jht_front/features/accessory/data/models/segmento_model.dart';
import 'package:app_jht_front/features/accessory/data/models/tipo_accesorio_model.dart';
import 'package:app_jht_front/features/accessory/data/models/vehiculo_model.dart';
import 'package:app_jht_front/features/accessory/domain/repositories/accessory_repository.dart';
import 'package:app_jht_front/features/accessory/domain/usecases/registrar_accesorio_usecase.dart';

part 'accessory_event.dart';
part 'accessory_state.dart';

class AccessoryBloc extends Bloc<AccessoryEvent, AccessoryState> {
  final AccessoryRepository repository;

  AccessoryBloc({required this.repository}) : super(AccessoryInitial()) {
    // Registro de eventos
    on<LoadSegmentosEvent>(_onLoadSegmentos);
    on<LoadTiposAccesorioEvent>(_onLoadTiposAccesorio);
    on<LoadVehiculosEvent>(_onLoadVehiculos);
    on<RegistrarAccesorioEvent>(_onRegistrarAccesorio);
    on<RegistrarTipoAccesorioEvent>(_onRegistrarTipoAccesorio);
    on<OnFetchAccesoriosByVehiculo>(_onFetchAccesoriosByVehiculo);
    on<OnFetchDetalleAccesorio>(_onFetchDetalleAccesorio);
  }

  // REQF07 - API 26: Listar accesorios de un vehículo
  Future<void> _onFetchAccesoriosByVehiculo(
    OnFetchAccesoriosByVehiculo event,
    Emitter<AccessoryState> emit,
  ) async {
    emit(AccesoriosByVehiculoLoading());
    try {
      final accesorios = await repository.getAccesoriosPorVehiculo(event.vehiculoId);
      emit(AccesoriosByVehiculoLoaded(accesorios: accesorios));
    } catch (e) {
      emit(AccessoryError(message: "Error al listar accesorios: ${e.toString()}"));
    }
  }

  // REQF07 - API 27: Obtener detalle de un accesorio
  Future<void> _onFetchDetalleAccesorio(
    OnFetchDetalleAccesorio event,
    Emitter<AccessoryState> emit,
  ) async {
    emit(DetalleAccesorioLoading());
    try {
      final detalle = await repository.getDetalleAccesorio(event.accesorioId);
      emit(DetalleAccesorioLoaded(detalle: detalle));
    } catch (e) {
      emit(AccessoryError(message: "Error al obtener detalle: ${e.toString()}"));
    }
  }

  // Cargar Vehículos (API 04)
  Future<void> _onLoadVehiculos(
    LoadVehiculosEvent event,
    Emitter<AccessoryState> emit,
  ) async {
    emit(VehiculosLoading());
    try {
      final vehiculos = await repository.listarVehiculos();
      emit(VehiculosLoaded(vehiculos: vehiculos));
    } catch (e) {
      emit(AccessoryError(message: e.toString()));
    }
  }

  // Cargar Segmentos
  Future<void> _onLoadSegmentos(
    LoadSegmentosEvent event,
    Emitter<AccessoryState> emit,
  ) async {
    emit(SegmentosLoading());
    try {
      final segmentos = await repository.listarSegmentos();
      emit(SegmentosLoaded(segmentos: segmentos));
    } catch (e) {
      emit(AccessoryError(message: e.toString()));
    }
  }

  // Cargar Tipos de Accesorio
  Future<void> _onLoadTiposAccesorio(
    LoadTiposAccesorioEvent event,
    Emitter<AccessoryState> emit,
  ) async {
    emit(TiposAccesorioLoading());
    try {
      final tipos = await repository.listarTiposAccesorioPorSegmento(event.segmentoId);
      emit(TiposAccesorioLoaded(tiposAccesorio: tipos));
    } catch (e) {
      emit(AccessoryError(message: e.toString()));
    }
  }

  // Registrar Nuevo Accesorio
  Future<void> _onRegistrarAccesorio(
    RegistrarAccesorioEvent event,
    Emitter<AccessoryState> emit,
  ) async {
    emit(RegistrandoAccesorio());
    try {
      final useCase = RegistrarAccesorioUseCase(repository: repository);
      final responseEntity = await useCase(event.dto);
      emit(AccesorioRegistrado(
        response: AccesorioRegistroResponse(
          status: 'OK',
          message: 'Accesorio registrado exitosamente',
          data: {'id': responseEntity.id},
        ),
      ));
    } catch (e) {
      emit(RegistroError(message: e.toString()));
    }
  }

  // Registrar Nuevo Tipo de Accesorio
  Future<void> _onRegistrarTipoAccesorio(
    RegistrarTipoAccesorioEvent event,
    Emitter<AccessoryState> emit,
  ) async {
    emit(RegistrandoTipoAccesorio());
    try {
      final response = await repository.registrarTipoAccesorio(event.dto);
      emit(TipoAccesorioRegistrado(response: response));
    } catch (e) {
      emit(TipoAccesorioRegistroError(message: e.toString()));
    }
  }
}