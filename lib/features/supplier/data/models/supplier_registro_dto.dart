// lib/features/supplier/data/models/supplier_registro_dto.dart

class SupplierRegistroDto {
  final String razonSocial;
  final String representante;
  final String direccion;
  final String linkUbicacion;
  final String ruc;
  final String tipo;
  final String correo;
  final String banco;
  final String numCuenta;
  final String encargado;
  final String estado;
  final String observaciones;
  final List<TelefonoDto> telefonos;

  SupplierRegistroDto({
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

class TelefonoDto {
  final String numero;
  final String tipo;
  final String uso;

  TelefonoDto({
    required this.numero,
    required this.tipo,
    required this.uso,
  });

  Map<String, dynamic> toJson() => {
        'numero': numero,
        'tipo': tipo,
        'uso': uso,
      };
}