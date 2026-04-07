// lib/features/mantenimiento/presentation/bloc/registro_mantenimiento_bloc.dart

import 'package:app_jht_front/features/mantenimiento/data/models/accesorio_vehiculo_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/registro_mantenimiento_datasource.dart';
import '../../data/models/item_mantenimiento_form_model.dart';
import 'registro_mantenimiento_event.dart';
import 'registro_mantenimiento_state.dart';

class RegistroMantenimientoBloc
    extends Bloc<RegistroMantenimientoEvent, RegistroMantenimientoState> {
  final RegistroMantenimientoDataSource dataSource;

  RegistroMantenimientoBloc({required this.dataSource})
      : super(const RegistroMantenimientoState()) {
    on<CargarDatosInicialesEvent>(_onCargarDatosIniciales);
    on<VehiculoSeleccionadoEvent>(_onVehiculoSeleccionado);
    on<SegmentoSeleccionadoEvent>(_onSegmentoSeleccionado);
    on<AgregarItemEvent>(_onAgregarItem);
    on<CargarConceptosPorTipoEvent>(_onCargarConceptosPorTipo);
    on<ConceptoSeleccionadoEvent>(_onConceptoSeleccionado);
    on<ActualizarItemEvent>(_onActualizarItem);
    on<EliminarItemEvent>(_onEliminarItem);
    on<RegistrarMantenimientoEvent>(_onRegistrarMantenimiento);
    on<ResetRegistroEvent>(_onReset);
  }

  // ── API12 ─────────────────────────────────────────────────────────────────
  Future<void> _onCargarDatosIniciales(
    CargarDatosInicialesEvent event,
    Emitter<RegistroMantenimientoState> emit,
  ) async {
    emit(state.copyWith(
      cargandoDatosIniciales: true,
      clearErrorDatosIniciales: true,
    ));
    try {
      final datos = await dataSource.getDatosIniciales();
      emit(state.copyWith(
        cargandoDatosIniciales: false,
        datosIniciales: datos,
      ));
    } catch (e) {
      emit(state.copyWith(
        cargandoDatosIniciales: false,
        errorDatosIniciales: e.toString(),
      ));
    }
  }

  // ── API13 ─────────────────────────────────────────────────────────────────
  Future<void> _onVehiculoSeleccionado(
    VehiculoSeleccionadoEvent event,
    Emitter<RegistroMantenimientoState> emit,
  ) async {
    // Resetear items y segmento al cambiar vehículo
    emit(state.copyWith(
      vehiculoIdSeleccionado: event.vehiculoId,
      kilometrajeVehiculo: event.kilometraje,
      cargandoAccesorios: true,
      accesoriosVehiculo: [],
      accesoriosConcepto: [],
      items: [],
      clearSegmentoId: true,
    ));
    try {
      final accesorios =
          await dataSource.getAccesoriosPorVehiculo(event.vehiculoId);
      emit(state.copyWith(
        cargandoAccesorios: false,
        accesoriosVehiculo: accesorios,
      ));
    } catch (e) {
      emit(state.copyWith(cargandoAccesorios: false));
    }
  }

  // ── API14 ─────────────────────────────────────────────────────────────────
  Future<void> _onSegmentoSeleccionado(
    SegmentoSeleccionadoEvent event,
    Emitter<RegistroMantenimientoState> emit,
  ) async {
    emit(state.copyWith(
      segmentoIdSeleccionado: event.segmentoId,
      cargandoAccesoriosConcepto: true,
      accesoriosConcepto: [],
      items: [], // resetear ítems al cambiar segmento
      clearErrorAccesoriosConcepto: true,
    ));
    try {
      final accesorios = await dataSource.getAccesoriosPorConcepto(
        smaId: event.segmentoId,
        vehId: event.vehiculoId,
      );
      emit(state.copyWith(
        cargandoAccesoriosConcepto: false,
        accesoriosConcepto: accesorios,
      ));
    } catch (e) {
      emit(state.copyWith(
        cargandoAccesoriosConcepto: false,
        errorAccesoriosConcepto: e.toString(),
      ));
    }
  }

  // ── Agregar ítem ──────────────────────────────────────────────────────────
  void _onAgregarItem(
    AgregarItemEvent event,
    Emitter<RegistroMantenimientoState> emit,
  ) {
    if (state.items.length >= 20) return;

    // Verificar que no esté ya agregado
    final yaAgregado = state.items.any(
      (i) => i.accesorioConcepto.accesorioId ==
          event.accesorioConcepto.accesorioId,
    );
    if (yaAgregado) return;

    final newItems = List<ItemMantenimientoForm>.from(state.items)
      ..add(ItemMantenimientoForm(
        accesorioConcepto: event.accesorioConcepto,
      ));
    emit(state.copyWith(items: newItems));
  }

  // ── API15 ─────────────────────────────────────────────────────────────────
  Future<void> _onCargarConceptosPorTipo(
    CargarConceptosPorTipoEvent event,
    Emitter<RegistroMantenimientoState> emit,
  ) async {
    final newCargando = Map<int, bool>.from(state.cargandoConceptos)
      ..[event.itemIndex] = true;
    emit(state.copyWith(cargandoConceptos: newCargando));

    try {
      final conceptos =
          await dataSource.getConceptosMantenimiento(event.tipoId);
      final newConceptos =
          Map<int, List<ConceptoMantenimientoModel>>.from(state.conceptosPorItem)
            ..[event.itemIndex] = conceptos;
      final newCargandoOff = Map<int, bool>.from(state.cargandoConceptos)
        ..[event.itemIndex] = false;
      emit(state.copyWith(
        cargandoConceptos: newCargandoOff,
        conceptosPorItem: newConceptos,
      ));
    } catch (e) {
      final newCargandoOff = Map<int, bool>.from(state.cargandoConceptos)
        ..[event.itemIndex] = false;
      emit(state.copyWith(cargandoConceptos: newCargandoOff));
    }
  }

  // ── Concepto seleccionado → pre-calcular km y fecha ───────────────────────
  void _onConceptoSeleccionado(
    ConceptoSeleccionadoEvent event,
    Emitter<RegistroMantenimientoState> emit,
  ) {
    final newItems = List<ItemMantenimientoForm>.from(state.items);
    if (event.itemIndex >= newItems.length) return;

    final item = newItems[event.itemIndex];
    item.conceptoSeleccionado = event.concepto;
    item.proximoKilometraje =
        (event.kilometrajeVehiculo + event.concepto.frecuenciaKilometros) as int?;
    item.proximaFecha = DateTime.now()
        .add(Duration(days: event.concepto.frecuenciaTiempo));

    emit(state.copyWith(items: newItems));
  }

  // ── Actualizar campos de un ítem ──────────────────────────────────────────
  void _onActualizarItem(
    ActualizarItemEvent event,
    Emitter<RegistroMantenimientoState> emit,
  ) {
    final newItems = List<ItemMantenimientoForm>.from(state.items);
    if (event.itemIndex >= newItems.length) return;

    final item = newItems[event.itemIndex];
    if (event.descripcion != null) item.descripcion = event.descripcion!;
    if (event.proximoKilometraje != null)
      item.proximoKilometraje = event.proximoKilometraje;
    if (event.proximaFecha != null) item.proximaFecha = event.proximaFecha;
    if (event.estado != null) item.estado = event.estado!;
    if (event.fotoPath != null) item.fotoPath = event.fotoPath;
    if (event.nuevaMarca != null) item.nuevaMarca = event.nuevaMarca;
    if (event.nuevoCodigoFabricante != null)
      item.nuevoCodigoFabricante = event.nuevoCodigoFabricante;
    if (event.nuevaFechaInstalacion != null)
      item.nuevaFechaInstalacion = event.nuevaFechaInstalacion;
    if (event.nuevoKilometrajeInstalacion != null)
      item.nuevoKilometrajeInstalacion = event.nuevoKilometrajeInstalacion;

    emit(state.copyWith(items: newItems));
  }

  // ── Eliminar ítem ─────────────────────────────────────────────────────────
  void _onEliminarItem(
    EliminarItemEvent event,
    Emitter<RegistroMantenimientoState> emit,
  ) {
    final newItems = List<ItemMantenimientoForm>.from(state.items)
      ..removeAt(event.itemIndex);
    // Limpiar conceptos del índice eliminado y re-indexar
    final newConceptos = <int, List<ConceptoMantenimientoModel>>{};
    state.conceptosPorItem.forEach((k, v) {
      if (k < event.itemIndex) newConceptos[k] = v;
      if (k > event.itemIndex) newConceptos[k - 1] = v;
    });
    emit(state.copyWith(items: newItems, conceptosPorItem: newConceptos));
  }

  // ── API16 ─────────────────────────────────────────────────────────────────
  Future<void> _onRegistrarMantenimiento(
    RegistrarMantenimientoEvent event,
    Emitter<RegistroMantenimientoState> emit,
  ) async {
    emit(state.copyWith(
      enviando: true,
      clearErrorRegistro: true,
      exitoRegistro: false,
    ));
    try {
      final bitacoraId = await dataSource.registrarMantenimiento(
        perIid: event.perIid,
        vehIid: event.vehIid,
        proIid: event.proIid,
        bitKilometraje: event.bitKilometraje,
        bitCantidad: state.items.length,
        bitFechaRegistro: event.bitFechaRegistro,
        items: state.items,
        gasTipo: event.gasTipo,
        gasMoneda: event.gasMoneda,
        gasNumeroDocumento: event.gasNumeroDocumento,
        gasMonto: event.gasMonto,
        gasFechaGasto: event.gasFechaGasto,
        gasDescripcion: event.gasDescripcion,
        gasTipoGasto: event.gasTipoGasto,
        gastoFotoPath: event.gastoFotoPath,
      );
      emit(state.copyWith(
        enviando: false,
        exitoRegistro: true,
        bitacoraIdCreada: bitacoraId,
      ));
    } catch (e) {
      emit(state.copyWith(
        enviando: false,
        exitoRegistro: false,
        errorRegistro: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  void _onReset(
    ResetRegistroEvent event,
    Emitter<RegistroMantenimientoState> emit,
  ) {
    emit(RegistroMantenimientoState(
      datosIniciales: state.datosIniciales, // mantener datos iniciales
    ));
  }
}