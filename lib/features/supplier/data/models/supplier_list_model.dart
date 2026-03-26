// lib/features/supplier/data/models/supplier_list_model.dart
class SupplierListModel {
  final int proveedorId;
  final String razonSocial;
  final String representante;
  final int ruc;
  final String encargado;
  final String estado;
  final String telefono;

  SupplierListModel({
    required this.proveedorId,
    required this.razonSocial,
    required this.representante,
    required this.ruc,
    required this.encargado,
    required this.estado,
    required this.telefono,
  });

  factory SupplierListModel.fromJson(Map<String, dynamic> json) {
    return SupplierListModel(
      proveedorId: json['proveedorId'] ?? 0,
      razonSocial: json['razonSocial'] ?? '',
      representante: json['representante'] ?? '',
      ruc: json['ruc'] ?? 0,
      encargado: json['encargado'] ?? '',
      estado: json['estado'] ?? '',
      telefono: json['telefono'] ?? '',
    );
  }
}