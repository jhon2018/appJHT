// lib/features/mantenimiento/presentation/bloc/registro_mantenimiento_event.dart

import 'package:app_jht_front/features/mantenimiento/data/models/accesorio_vehiculo_model.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/item_mantenimiento_form_model.dart';

@immutable
abstract class RegistroMantenimientoEvent {
  const RegistroMantenimientoEvent();
}

/// Carga datos iniciales (API12): vehículos, proveedores, segmentos, conductores
class CargarDatosInicialesEvent extends RegistroMantenimientoEvent {
  const CargarDatosInicialesEvent();
}

/// Al seleccionar un vehículo → dispara API13
class VehiculoSeleccionadoEvent extends RegistroMantenimientoEvent {
  final int vehiculoId;
  final int kilometraje;
  const VehiculoSeleccionadoEvent({
    required this.vehiculoId,
    required this.kilometraje,
  });
}

/// Al seleccionar un segmento → dispara API14
class SegmentoSeleccionadoEvent extends RegistroMantenimientoEvent {
  final int segmentoId;
  final int vehiculoId;
  const SegmentoSeleccionadoEvent({
    required this.segmentoId,
    required this.vehiculoId,
  });
}

/// Al seleccionar un accesorio-concepto de API14 para agregar al formulario
class AgregarItemEvent extends RegistroMantenimientoEvent {
  final AccesorioConceptoModel accesorioConcepto;
  const AgregarItemEvent({required this.accesorioConcepto});
}

/// Al seleccionar un ítem ya agregado → dispara API15 para obtener conceptos
class CargarConceptosPorTipoEvent extends RegistroMantenimientoEvent {
  final int tipoId;
  final int itemIndex;
  const CargarConceptosPorTipoEvent({
    required this.tipoId,
    required this.itemIndex,
  });
}

/// Seleccionar concepto de API15 para un ítem específico
class ConceptoSeleccionadoEvent extends RegistroMantenimientoEvent {
  final int itemIndex;
  final ConceptoMantenimientoModel concepto;
  final int kilometrajeVehiculo;
  const ConceptoSeleccionadoEvent({
    required this.itemIndex,
    required this.concepto,
    required this.kilometrajeVehiculo,
  });
}

/// Actualizar campos de un ítem (descripcion, estado, fotos, nuevo accesorio)
class ActualizarItemEvent extends RegistroMantenimientoEvent {
  final int itemIndex;
  final String? descripcion;
  final int? proximoKilometraje;
  final DateTime? proximaFecha;
  final String? estado;
  final String? fotoPath;
  // Cambio
  final String? nuevaMarca;
  final String? nuevoCodigoFabricante;
  final DateTime? nuevaFechaInstalacion;
  final int? nuevoKilometrajeInstalacion;

  const ActualizarItemEvent({
    required this.itemIndex,
    this.descripcion,
    this.proximoKilometraje,
    this.proximaFecha,
    this.estado,
    this.fotoPath,
    this.nuevaMarca,
    this.nuevoCodigoFabricante,
    this.nuevaFechaInstalacion,
    this.nuevoKilometrajeInstalacion,
  });
}

/// Eliminar un ítem de la lista
class EliminarItemEvent extends RegistroMantenimientoEvent {
  final int itemIndex;
  const EliminarItemEvent({required this.itemIndex});
}

/// Enviar el formulario completo → API16
class RegistrarMantenimientoEvent extends RegistroMantenimientoEvent {
  final int perIid;
  final int vehIid;
  final int proIid;
  final int bitKilometraje;
  final DateTime bitFechaRegistro;
  // Gasto
  final String gasTipo;
  final String gasMoneda;
  final int gasNumeroDocumento;
  final double gasMonto;
  final DateTime gasFechaGasto;
  final String gasDescripcion;
  final String gasTipoGasto;
  final String? gastoFotoPath;

  const RegistrarMantenimientoEvent({
    required this.perIid,
    required this.vehIid,
    required this.proIid,
    required this.bitKilometraje,
    required this.bitFechaRegistro,
    required this.gasTipo,
    required this.gasMoneda,
    required this.gasNumeroDocumento,
    required this.gasMonto,
    required this.gasFechaGasto,
    required this.gasDescripcion,
    required this.gasTipoGasto,
    this.gastoFotoPath,
  });
}

/// Reset completo del formulario
class ResetRegistroEvent extends RegistroMantenimientoEvent {
  const ResetRegistroEvent();
}

/// Nuevo evento V2 — usa HistoricoItem + GastoRegistro directamente
class RegistrarMantenimientoV2Event extends RegistroMantenimientoEvent {
  final int          perIid;
  final int          vehIid;
  final int          proIid;
  final int          bitKilometraje;
  final DateTime     bitFechaRegistro;
  final List<dynamic> historicos;   // List<HistoricoItem>
  final dynamic       gasto;        // GastoRegistro

  const RegistrarMantenimientoV2Event({
    required this.perIid,
    required this.vehIid,
    required this.proIid,
    required this.bitKilometraje,
    required this.bitFechaRegistro,
    required this.historicos,
    required this.gasto,
  });
}