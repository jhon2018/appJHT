// lib/features/mantenimiento/presentation/bloc/registro_mantenimiento_state.dart

import 'package:app_jht_front/features/mantenimiento/data/models/accesorio_vehiculo_model.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/datos_iniciales_model.dart';
import '../../data/models/item_mantenimiento_form_model.dart';

@immutable
class RegistroMantenimientoState {
  // ── Datos iniciales (API12) ───────────────────────────────────────────────
  final bool cargandoDatosIniciales;
  final DatosInicialesModel? datosIniciales;
  final String? errorDatosIniciales;

  // ── Selecciones base ──────────────────────────────────────────────────────
  final int? vehiculoIdSeleccionado;
  final int kilometrajeVehiculo;
  final int? proveedorIdSeleccionado;
  final int? segmentoIdSeleccionado;
  final int? conductorIdSeleccionado; // null = usa per_iid del token

  // ── Accesorios del vehículo (API13, en memoria) ───────────────────────────
  final bool cargandoAccesorios;
  final List<AccesorioVehiculoModel> accesoriosVehiculo;

  // ── Accesorios por concepto (API14) ───────────────────────────────────────
  final bool cargandoAccesoriosConcepto;
  final List<AccesorioConceptoModel> accesoriosConcepto;
  final String? errorAccesoriosConcepto;

  // ── Conceptos por tipo (API15) — mapa indexado por itemIndex ─────────────
  final Map<int, bool> cargandoConceptos; // itemIndex → isLoading
  final Map<int, List<ConceptoMantenimientoModel>> conceptosPorItem;

  // ── Ítems del formulario ──────────────────────────────────────────────────
  final List<ItemMantenimientoForm> items;

  // ── Estado de envío (API16) ───────────────────────────────────────────────
  final bool enviando;
  final bool exitoRegistro;
  final int? bitacoraIdCreada;
  final String? errorRegistro;

  const RegistroMantenimientoState({
    this.cargandoDatosIniciales = false,
    this.datosIniciales,
    this.errorDatosIniciales,
    this.vehiculoIdSeleccionado,
    this.kilometrajeVehiculo = 0,
    this.proveedorIdSeleccionado,
    this.segmentoIdSeleccionado,
    this.conductorIdSeleccionado,
    this.cargandoAccesorios = false,
    this.accesoriosVehiculo = const [],
    this.cargandoAccesoriosConcepto = false,
    this.accesoriosConcepto = const [],
    this.errorAccesoriosConcepto,
    this.cargandoConceptos = const {},
    this.conceptosPorItem = const {},
    this.items = const [],
    this.enviando = false,
    this.exitoRegistro = false,
    this.bitacoraIdCreada,
    this.errorRegistro,
  });

  bool get datosListos => datosIniciales != null && !cargandoDatosIniciales;
  bool get vehiculoSeleccionado => vehiculoIdSeleccionado != null;
  bool get puedeAgregarItems =>
      vehiculoSeleccionado &&
      segmentoIdSeleccionado != null &&
      accesoriosConcepto.isNotEmpty;
  bool get maxItemsAlcanzado => items.length >= 20;
  bool get puedeEnviar =>
      items.isNotEmpty &&
      items.every((i) => i.isComplete) &&
      proveedorIdSeleccionado != null &&
      vehiculoIdSeleccionado != null;

  RegistroMantenimientoState copyWith({
    bool? cargandoDatosIniciales,
    DatosInicialesModel? datosIniciales,
    String? errorDatosIniciales,
    int? vehiculoIdSeleccionado,
    int? kilometrajeVehiculo,
    int? proveedorIdSeleccionado,
    int? segmentoIdSeleccionado,
    int? conductorIdSeleccionado,
    bool? cargandoAccesorios,
    List<AccesorioVehiculoModel>? accesoriosVehiculo,
    bool? cargandoAccesoriosConcepto,
    List<AccesorioConceptoModel>? accesoriosConcepto,
    String? errorAccesoriosConcepto,
    Map<int, bool>? cargandoConceptos,
    Map<int, List<ConceptoMantenimientoModel>>? conceptosPorItem,
    List<ItemMantenimientoForm>? items,
    bool? enviando,
    bool? exitoRegistro,
    int? bitacoraIdCreada,
    String? errorRegistro,
    // Flags para limpiar nullables
    bool clearErrorDatosIniciales = false,
    bool clearErrorAccesoriosConcepto = false,
    bool clearErrorRegistro = false,
    bool clearVehiculoId = false,
    bool clearSegmentoId = false,
    bool clearProveedorId = false,
    bool clearConductorId = false,
  }) {
    return RegistroMantenimientoState(
      cargandoDatosIniciales:
          cargandoDatosIniciales ?? this.cargandoDatosIniciales,
      datosIniciales: datosIniciales ?? this.datosIniciales,
      errorDatosIniciales: clearErrorDatosIniciales
          ? null
          : errorDatosIniciales ?? this.errorDatosIniciales,
      vehiculoIdSeleccionado: clearVehiculoId
          ? null
          : vehiculoIdSeleccionado ?? this.vehiculoIdSeleccionado,
      kilometrajeVehiculo:
          kilometrajeVehiculo ?? this.kilometrajeVehiculo,
      proveedorIdSeleccionado: clearProveedorId
          ? null
          : proveedorIdSeleccionado ?? this.proveedorIdSeleccionado,
      segmentoIdSeleccionado: clearSegmentoId
          ? null
          : segmentoIdSeleccionado ?? this.segmentoIdSeleccionado,
      conductorIdSeleccionado: clearConductorId
          ? null
          : conductorIdSeleccionado ?? this.conductorIdSeleccionado,
      cargandoAccesorios: cargandoAccesorios ?? this.cargandoAccesorios,
      accesoriosVehiculo: accesoriosVehiculo ?? this.accesoriosVehiculo,
      cargandoAccesoriosConcepto:
          cargandoAccesoriosConcepto ?? this.cargandoAccesoriosConcepto,
      accesoriosConcepto: accesoriosConcepto ?? this.accesoriosConcepto,
      errorAccesoriosConcepto: clearErrorAccesoriosConcepto
          ? null
          : errorAccesoriosConcepto ?? this.errorAccesoriosConcepto,
      cargandoConceptos: cargandoConceptos ?? this.cargandoConceptos,
      conceptosPorItem: conceptosPorItem ?? this.conceptosPorItem,
      items: items ?? this.items,
      enviando: enviando ?? this.enviando,
      exitoRegistro: exitoRegistro ?? this.exitoRegistro,
      bitacoraIdCreada: bitacoraIdCreada ?? this.bitacoraIdCreada,
      errorRegistro: clearErrorRegistro
          ? null
          : errorRegistro ?? this.errorRegistro,
    );
  }
}