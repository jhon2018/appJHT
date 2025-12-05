// Ruta: lib/features/supplier/domain/entities/supplier_entity.dart
class SupplierEntity {
  final String razonSocial;
  final String representante;
  final String direccion;
  final String ruc;
  final String tipo;
  final String correo;

  SupplierEntity({
    required this.razonSocial,
    required this.representante,
    required this.direccion,
    required this.ruc,
    required this.tipo,
    required this.correo,
  });
}