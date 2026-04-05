// lib/features/accessory/presentation/bloc/accessory_bloc.dart

import 'package:app_jht_front/features/accessory/data/models/accesorio_detalle_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_registro_dto.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_registro_response.dart';
import 'package:app_jht_front/features/accessory/data/models/tipo_accesorio_registro_dto.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_model.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_actualizar_dto.dart';
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
    on<LoadSegmentosEvent>(_onLoadSegmentos);
    on<LoadTiposAccesorioEvent>(_onLoadTiposAccesorio);
    on<LoadVehiculosEvent>(_onLoadVehiculos);
    on<RegistrarAccesorioEvent>(_onRegistrarAccesorio);
    on<RegistrarTipoAccesorioEvent>(_onRegistrarTipoAccesorio);
    on<OnFetchAccesoriosByVehiculo>(_onFetchAccesoriosByVehiculo);
    on<OnFetchDetalleAccesorio>(_onFetchDetalleAccesorio);
    // REQF08
    on<ActualizarAccesorioEvent>(_onActualizarAccesorio);
  }

  // REQF07 - API26
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

  // REQF07 - API27
  Future<void> _onFetchDetalleAccesorio(
    OnFetchDetalleAccesorio event,
    Emitter<AccessoryState> emit,
  ) async {
    emit(DetalleAccesorioLoading(nombreAccesorio: "Accesorio"));
    try {
      final detalle = await repository.getDetalleAccesorio(event.accesorioId);
      emit(DetalleAccesorioLoaded(detalle: detalle));
    } catch (e) {
      emit(AccessoryError(message: "Error al obtener detalle: ${e.toString()}"));
    }
  }

  // API04
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

  // API03
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

  // API05
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

  // ─── REQF08 - API20 ────────────────────────────────────────────────────────
  Future<void> _onActualizarAccesorio(
    ActualizarAccesorioEvent event,
    Emitter<AccessoryState> emit,
  ) async {
    emit(ActualizandoAccesorio());
    try {
      await repository.actualizarAccesorio(event.dto);
      emit(AccesorioActualizado(vehiculoId: event.vehiculoIdActual));
    } catch (e) {
      emit(ActualizacionError(message: "Error al actualizar accesorio: ${e.toString()}"));
    }
  }
}