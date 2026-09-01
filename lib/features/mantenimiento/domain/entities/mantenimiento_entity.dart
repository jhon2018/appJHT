// lib/features/mantenimiento/domain/entities/mantenimiento_entity.dart
import 'package:equatable/equatable.dart';

/// 🏗️ Entidad de Dominio para Mantenimiento
/// Representa el modelo de negocio independiente de frameworks
class MantenimientoEntity extends Equatable {
  // ─── Campos de Lectura (NO editables en UI) ───────────────────────────────
  final String fechaRegistro;     // bit_dfech_registro
  final String vehiculoPlaca;     // veh_vplaca
  final String tipoAccesorio;     // acc_vnombre
  final String concepto;          // his_vtipo_mantenimiento
  
  // ─── Campos Editables (UI permite modificación) ───────────────────────────
  final String descripcion;       // his_vdescripcion
  final int proximoKilometraje;   // his_iproximo_kilometraje
  final String proximaFecha;      // his_dproxima_fech (yyyy-MM-dd)
  final String estado;            // his_vestado
  final String linkFoto;          // his_vlink_foto
  
  // ─── Identificadores para API ─────────────────────────────────────────────
  final int bitacoraId;           // bit_iid
  final int accesorioId;          // acc_iid

  const MantenimientoEntity({
    required this.fechaRegistro,
    required this.vehiculoPlaca,
    required this.tipoAccesorio,
    required this.concepto,
    required this.descripcion,
    required this.proximoKilometraje,
    required this.proximaFecha,
    required this.estado,
    required this.linkFoto,
    required this.bitacoraId,
    required this.accesorioId,
  });

  /// ✅ Factory desde Model (Data Layer → Domain)
  factory MantenimientoEntity.fromModel(dynamic model) {
    // Soporta tanto DetalleMantenimientoModel como MantenimientoModel
    return MantenimientoEntity(
      fechaRegistro: model.fechaRegistro ?? '',
      vehiculoPlaca: model.vehiculoPlaca ?? model.vehiculo?.placa ?? '',
      tipoAccesorio: model.tipoAccesorio ?? model.tipoNombre ?? '',
      concepto: model.concepto ?? model.diccionarioMantenimiento ?? '',
      descripcion: model.descripcion ?? '',
      proximoKilometraje: model.proximoKilometraje ?? model.proxKilometraje ?? 0,
      proximaFecha: model.proximaFecha ?? model.proxFecha ?? '',
      estado: model.estado ?? 'Pendiente',
      linkFoto: model.linkFoto ?? '',
      bitacoraId: model.bitacoraId ?? model.bitIid ?? 0,
      accesorioId: model.accesorioId ?? model.accIid ?? 0,
    );
  }

  /// ✅ To Model (Domain → Data Layer) para requests de actualización
  Map<String, dynamic> toUpdateRequest() {
    return {
      'bitacoraId': bitacoraId,
      'accesorioId': accesorioId,
      'descripcion': descripcion,
      'proximoKilometraje': proximoKilometraje,
      'proximaFecha': proximaFecha,
      'estado': estado,
      // linkFoto se maneja por separado en el servicio de upload
    };
  }

  /// ✅ Copia con modificaciones (inmutabilidad)
  MantenimientoEntity copyWith({
    String? descripcion,
    int? proximoKilometraje,
    String? proximaFecha,
    String? estado,
    String? linkFoto,
  }) {
    return MantenimientoEntity(
      fechaRegistro: fechaRegistro,      // 🔒 readonly
      vehiculoPlaca: vehiculoPlaca,      // 🔒 readonly
      tipoAccesorio: tipoAccesorio,      // 🔒 readonly
      concepto: concepto,                // 🔒 readonly
      descripcion: descripcion ?? this.descripcion, 
      proximoKilometraje: proximoKilometraje ?? this.proximoKilometraje,
      proximaFecha: proximaFecha ?? this.proximaFecha,
      estado: estado ?? this.estado,
      linkFoto: linkFoto ?? this.linkFoto,
      bitacoraId: bitacoraId,
      accesorioId: accesorioId,
    );
  }

  /// ✅ Validaciones de negocio (reusables en UI y Domain)
  String? validateDescripcion() {
    if (descripcion.trim().isEmpty) return 'La descripción es requerida';
    if (descripcion.length < 10) return 'Mínimo 10 caracteres';
    return null;
  }

  String? validateProximoKilometraje() {
    if (proximoKilometraje <= 0) return 'Debe ser mayor a 0';
    if (proximoKilometraje > 999999) return 'Valor no válido';
    return null;
  }

  String? validateProximaFecha() {
    if (proximaFecha.isEmpty) return 'Seleccione una fecha';
    // Validar formato yyyy-MM-dd
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!regex.hasMatch(proximaFecha)) return 'Formato: AAAA-MM-DD';
    return null;
  }

  String? validateEstado() {
    const validos = ['Pendiente', 'En proceso', 'Completo'];
    if (!validos.contains(estado)) return 'Estado no válido';
    return null;
  }

  /// ✅ Validación completa del formulario
  Map<String, String?> validateAll() {
    return {
      'descripcion': validateDescripcion(),
      'proximoKilometraje': validateProximoKilometraje(),
      'proximaFecha': validateProximaFecha(),
      'estado': validateEstado(),
    };
  }

  @override
  List<Object?> get props => [
        fechaRegistro, vehiculoPlaca, tipoAccesorio, concepto,
        descripcion, proximoKilometraje, proximaFecha, estado, linkFoto,
        bitacoraId, accesorioId,
      ];
}