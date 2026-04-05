// lib/features/supplier/data/models/supplier_actualizar_dto.dart

class TelefonoActualizarDto {
  final int telId;
  final String numero;
  final int titId;

  TelefonoActualizarDto({
    required this.telId,
    required this.numero,
    required this.titId,
  });

  Map<String, dynamic> toJson() => {
        // ✅ FIX: El backend espera telId=0 para todos los teléfonos.
        // Cuando recibe telId>0 intenta hacer UPDATE en tbl_htelefono y
        // pisa tel_vfuente con NULL → error 500.
        // Con telId=0 el backend los trata como registros nuevos (INSERT)
        // y setea tel_vfuente='Proveedor' correctamente.
        'telId': 0,
        'numero': numero,
        'titId': titId,
      };
}

class SupplierActualizarDto {
  final int proveedorId;
  final String razonSocial;
  final String representante;
  final String direccion;
  final String linkUbicacion;
  final int ruc;
  final String tipo;
  final String correo;
  final String banco;
  final int numCuenta;
  final String encargado;
  final String estado;
  final String observaciones;
  final List<TelefonoActualizarDto> telefonos;

  SupplierActualizarDto({
    required this.proveedorId,
    required this.razonSocial,
    required this.representante,
    required this.direccion,
    required this.linkUbicacion,
    required this.ruc,
    required this.tipo,
    required this.correo,
    required this.banco,
    required this.numCuenta,
    required this.encargado,
    required this.estado,
    required this.observaciones,
    required this.telefonos,
  });

  Map<String, dynamic> toJson() => {
        'proveedorId': proveedorId,
        'razonSocial': razonSocial,
        'representante': representante,
        'direccion': direccion,
        'linkUbicacion': linkUbicacion,
        'ruc': ruc,
        'tipo': tipo,
        'correo': correo,
        'banco': banco,
        'numCuenta': numCuenta,
        'encargado': encargado,
        'estado': estado,
        'observaciones': observaciones,
        'telefonos': telefonos.map((tel) => tel.toJson()).toList(),
      };
}