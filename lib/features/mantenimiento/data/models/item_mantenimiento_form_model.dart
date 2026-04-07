// lib/features/mantenimiento/data/models/item_mantenimiento_form_model.dart
//
// Representa UN ítem del formulario de registro:
// cada ítem = un accesorio + su concepto + datos específicos según tipo.

import 'package:app_jht_front/features/mantenimiento/data/models/accesorio_vehiculo_model.dart';

import 'accesorio_models.dart';

class ItemMantenimientoForm {
  /// Accesorio seleccionado de API14
  final AccesorioConceptoModel accesorioConcepto;

  /// Concepto seleccionado de API15 (puede ser diferente al sugerido por API14)
  ConceptoMantenimientoModel? conceptoSeleccionado;

  // ── Campos comunes ────────────────────────────────────────────────────────
  String descripcion;
  int? proximoKilometraje;
  DateTime? proximaFecha;
  /// "Pendiente" | "Completo"
  String estado;

  // ── Foto del accesorio (histórico) ────────────────────────────────────────
  String? fotoPath; // ruta local del archivo seleccionado

  // ── Solo si dic_vtipo == "Cambio": datos del nuevo accesorio ──────────────
  String? nuevaMarca;
  String? nuevoCodigoFabricante;
  DateTime? nuevaFechaInstalacion;
  int? nuevoKilometrajeInstalacion;

  ItemMantenimientoForm({
    required this.accesorioConcepto,
    this.conceptoSeleccionado,
    this.descripcion = '',
    this.proximoKilometraje,
    this.proximaFecha,
    this.estado = 'Pendiente',
    this.fotoPath,
    this.nuevaMarca,
    this.nuevoCodigoFabricante,
    this.nuevaFechaInstalacion,
    this.nuevoKilometrajeInstalacion,
  });

  bool get esCambio =>
      conceptoSeleccionado?.esCambio ??
      accesorioConcepto.esCambio;

  bool get isComplete {
    if (conceptoSeleccionado == null) return false;
    if (descripcion.trim().isEmpty) return false;
    if (proximoKilometraje == null) return false;
    if (proximaFecha == null) return false;
    if (esCambio) {
      if (nuevaMarca == null || nuevaMarca!.trim().isEmpty) return false;
      if (nuevoCodigoFabricante == null ||
          nuevoCodigoFabricante!.trim().isEmpty) return false;
      if (nuevaFechaInstalacion == null) return false;
    }
    return true;
  }

  /// Construye el JSON para el array HistoricoMantenimientosJson de API16
  Map<String, dynamic> toHistoricoJson() => {
        'acc_iid': accesorioConcepto.accesorioId,
        'his_vdescripcion': descripcion,
        'his_iproximo_kilometraje': proximoKilometraje ?? 0,
        'his_dproxima_fech':
            proximaFecha?.toIso8601String().split('T').first ?? '',
        'his_vestado': estado,
        'dic_vtipo': conceptoSeleccionado?.tipo ?? accesorioConcepto.conceptoTipo,
        'dic_iid': conceptoSeleccionado?.id ?? 0,
      };
}