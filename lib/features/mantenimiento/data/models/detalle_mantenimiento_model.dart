// Ruta: lib/features/mantenimiento/data/models/detalle_mantenimiento_model.dart
import 'package:flutter/foundation.dart';

@immutable
class DetalleMantenimientoModel {
  final String descripcion;
  final int proximoKilometraje;
  final String proximaFecha;
  final String estado;
  final String linkFoto;
  final String fechaRegistro;
  final String tipoAccesorio;
  final String concepto;
  final String vehiculoPlaca;

  const DetalleMantenimientoModel({
    required this.descripcion,
    required this.proximoKilometraje,
    required this.proximaFecha,
    required this.estado,
    required this.linkFoto,
    required this.fechaRegistro,
    required this.tipoAccesorio,
    required this.concepto,
    required this.vehiculoPlaca,
  });

  factory DetalleMantenimientoModel.fromJson(Map<String, dynamic> json) {
    return DetalleMantenimientoModel(
      descripcion: json['descripcion'] ?? '',
      proximoKilometraje: json['proximoKilometraje'] ?? 0,
      proximaFecha: json['proximaFecha'] ?? '',
      estado: json['estado'] ?? '',
      linkFoto: json['linkFoto'] ?? '',
      fechaRegistro: json['fechaRegistro'] ?? '',
      tipoAccesorio: json['tipoAccesorio'] ?? '',
      concepto: json['concepto'] ?? '',
      vehiculoPlaca: json['vehiculoPlaca'] ?? '',
    );
  }
}

// Modelo para la respuesta de detalle
@immutable
class DetalleMantenimientoResponse {
  final String status;
  final String message;
  final DetalleMantenimientoModel data;

  const DetalleMantenimientoResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DetalleMantenimientoResponse.fromJson(Map<String, dynamic> json) {
    return DetalleMantenimientoResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: DetalleMantenimientoModel.fromJson(json['data']),
    );
  }
}

// Modelo para actualizar mantenimiento
@immutable
class ActualizarMantenimientoRequest {
  final int bitacoraId;
  final int accesorioId;
  final String descripcion;
  final int proximoKilometraje;
  final String proximaFecha;
  final String estado;

  const ActualizarMantenimientoRequest({
    required this.bitacoraId,
    required this.accesorioId,
    required this.descripcion,
    required this.proximoKilometraje,
    required this.proximaFecha,
    required this.estado,
  });

  Map<String, dynamic> toJson() {
    return {
      'bitacoraId': bitacoraId,
      'accesorioId': accesorioId,
      'descripcion': descripcion,
      'proximoKilometraje': proximoKilometraje,
      'proximaFecha': proximaFecha,
      'estado': estado,
    };
  }
}

// Modelo para respuesta de actualización
@immutable
class ActualizarMantenimientoResponse {
  final String status;
  final String message;

  const ActualizarMantenimientoResponse({
    required this.status,
    required this.message,
  });

  factory ActualizarMantenimientoResponse.fromJson(Map<String, dynamic> json) {
    return ActualizarMantenimientoResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}