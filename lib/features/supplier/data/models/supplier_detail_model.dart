// lib/features/supplier/data/models/supplier_detail_model.dart
// PARSING DEFENSIVO: prueba múltiples claves posibles para 'telefonos'
// ya que distintas versiones del API pueden usar nombres diferentes.
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
    // ── Parsing defensivo de teléfonos ─────────────────────────────────────
    // El API puede devolver la lista bajo distintas claves:
    // 'telefonos', 'Telefonos', 'telefonosProveedor', 'contactos', 'telefono'
    List<dynamic>? rawTelefonos;
    for (final key in ['telefonos', 'Telefonos', 'telefonosProveedor',
                        'contactos', 'telefono', 'telefonosList']) {
      if (json[key] != null && json[key] is List) {
        rawTelefonos = json[key] as List<dynamic>;
        break;
      }
    }
    final telefonosList = rawTelefonos
        ?.map((x) => TelefonoDetailModel.fromJson(x as Map<String, dynamic>))
        .toList() ?? <TelefonoDetailModel>[];

    return SupplierDetailModel(
      proveedorId:   json['proveedorId']   ?? 0,
      razonSocial:   json['razonSocial']   ?? '',
      representante: json['representante'] ?? '',
      direccion:     json['direccion']     ?? '',
      linkUbicacion: json['linkUbicacion'] ?? '',
      ruc:           json['ruc']           ?? 0,
      tipo:          json['tipo']          ?? '',
      correo:        json['correo']        ?? '',
      banco:         json['banco']         ?? '',
      numeroCuenta:  json['numeroCuenta']  ?? json['numCuenta'] ?? 0,
      encargado:     json['encargado']     ?? '',
      estado:        json['estado']        ?? '',
      observaciones: json['observaciones'] ?? '',
      telefonos:     telefonosList,
    );
  }
}
