
      // lib/features/mantenimiento/data/models/datos_iniciales_model.dart

class VehiculoInicialModel {
  final int id;
  final String placa;
  final int kilometraje;

  const VehiculoInicialModel({
    required this.id,
    required this.placa,
    required this.kilometraje,
  });

  factory VehiculoInicialModel.fromJson(Map<String, dynamic> json) =>
      VehiculoInicialModel(
        id: json['id'] ?? 0,
        placa: json['placa'] ?? '',
        kilometraje: json['kilometraje'] ?? 0,
      );
}

class ProveedorInicialModel {
  final int id;
  final String razonSocial;

  const ProveedorInicialModel({required this.id, required this.razonSocial});

  factory ProveedorInicialModel.fromJson(Map<String, dynamic> json) =>
      ProveedorInicialModel(
        id: json['id'] ?? 0,
        razonSocial: json['razonSocial'] ?? '',
      );
}

class SegmentoInicialModel {
  final int id;
  final String nombre;

  const SegmentoInicialModel({required this.id, required this.nombre});

  factory SegmentoInicialModel.fromJson(Map<String, dynamic> json) =>
      SegmentoInicialModel(
        id: json['id'] ?? 0,
        nombre: json['nombre'] ?? '',
      );
}

class ConductorInicialModel {
  final int id;
  final String primerNombre;
  final String apellidoPaterno;
  final String apellidoMaterno;

  const ConductorInicialModel({
    required this.id,
    required this.primerNombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
  });

  String get nombreCompleto =>
      '$primerNombre $apellidoPaterno $apellidoMaterno'.trim();

  factory ConductorInicialModel.fromJson(Map<String, dynamic> json) =>
      ConductorInicialModel(
        id: json['id'] ?? 0,
        primerNombre: json['primerNombre'] ?? '',
        apellidoPaterno: json['apellidoPaterno'] ?? '',
        apellidoMaterno: json['apellidoMaterno'] ?? '',
      );
}

class DatosInicialesModel {
  final List<VehiculoInicialModel> vehiculos;
  final List<ProveedorInicialModel> proveedores;
  final List<SegmentoInicialModel> segmentos;
  final List<ConductorInicialModel> conductores;

  const DatosInicialesModel({
    required this.vehiculos,
    required this.proveedores,
    required this.segmentos,
    required this.conductores,
  });

  factory DatosInicialesModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return DatosInicialesModel(
      vehiculos: (data['vehiculos'] as List? ?? [])
          .map((e) => VehiculoInicialModel.fromJson(e))
          .toList(),
      proveedores: (data['proveedores'] as List? ?? [])
          .map((e) => ProveedorInicialModel.fromJson(e))
          .toList(),
      segmentos: (data['segmentos'] as List? ?? [])
          .map((e) => SegmentoInicialModel.fromJson(e))
          .toList(),
      // API12 devuelve "personas" (conductores con rol conductor)
      conductores: (data['personas'] as List? ?? [])  //      conductores: (data['conductores'] as List? ?? [])  
          .map((e) => ConductorInicialModel.fromJson(e))
          .toList(),
    );
  }
}
