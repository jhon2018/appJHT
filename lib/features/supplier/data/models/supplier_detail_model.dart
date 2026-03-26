// lib/features/supplier/data/models/supplier_detail_model.dart
import 'package:app_jht_front/features/supplier/data/models/telefono_detail_model.dart';

class SupplierDetailModel {
  final int proveedorId;
  final String razonSocial;
  final String representante;
  final String direccion;
  final String linkUbicacion;
  final int ruc;
  final String tipo;
  final String correo;
  final String banco;
  final int numeroCuenta;
  final String encargado;
  final String estado;
  final String observaciones;
  final List<TelefonoDetailModel> telefonos;

  SupplierDetailModel({
    required this.proveedorId,
    required this.razonSocial,
    required this.representante,
    required this.direccion,
    required this.linkUbicacion,
    required this.ruc,
    required this.tipo,
    required this.correo,
    required this.banco,
    required this.numeroCuenta,
    required this.encargado,
    required this.estado,
    required this.observaciones,
    required this.telefonos,
  });

  factory SupplierDetailModel.fromJson(Map<String, dynamic> json) {
    var telefonosList = <TelefonoDetailModel>[];
    if (json['telefonos'] != null) {
      telefonosList = List<TelefonoDetailModel>.from(
        json['telefonos'].map((x) => TelefonoDetailModel.fromJson(x))
      );
    }

    return SupplierDetailModel(
      proveedorId: json['proveedorId'] ?? 0,
      razonSocial: json['razonSocial'] ?? '',
      representante: json['representante'] ?? '',
      direccion: json['direccion'] ?? '',
      linkUbicacion: json['linkUbicacion'] ?? '',
      ruc: json['ruc'] ?? 0,
      tipo: json['tipo'] ?? '',
      correo: json['correo'] ?? '',
      banco: json['banco'] ?? '',
      numeroCuenta: json['numeroCuenta'] ?? 0,
      encargado: json['encargado'] ?? '',
      estado: json['estado'] ?? '',
      observaciones: json['observaciones'] ?? '',
      telefonos: telefonosList,
    );
  }
}