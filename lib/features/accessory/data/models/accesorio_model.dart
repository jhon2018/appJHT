//Ruta: lib/features/accesory/data/models/accesorio_model.dart
class AccesorioModel {
  final int accesorioId;
  final String codigoFabricante;
  final DateTime fechaInstalacion;
  final String? marca;
  final int tipoId;
  final String tipoNombre;
  final UltimoMantenimiento? ultimoMantenimiento;
  
  // Campos adicionales que vienen en el detalle (API27)
  final int? kilometrajeInstalacion;
  final String? estado;
  final String? observacion;
  final String? tipoDescripcion;

  AccesorioModel({
    required this.accesorioId,
    required this.codigoFabricante,
    required this.fechaInstalacion,
    this.marca,
    required this.tipoId,
    required this.tipoNombre,
    this.ultimoMantenimiento,
    this.kilometrajeInstalacion,
    this.estado,
    this.observacion,
    this.tipoDescripcion,
  });

  factory AccesorioModel.fromJson(Map<String, dynamic> json) {
    return AccesorioModel(
      accesorioId: json['accesorioId'],
      codigoFabricante: json['codigoFabricante'] ?? '',
      fechaInstalacion: DateTime.parse(json['fechaInstalacion']),
      marca: json['marca'],
      tipoId: json['tipoId'],
      tipoNombre: json['tipoNombre'] ?? '',
      ultimoMantenimiento: json['ultimoMantenimiento'] != null 
          ? UltimoMantenimiento.fromJson(json['ultimoMantenimiento']) 
          : null,
      kilometrajeInstalacion: json['kilometrajeInstalacion'],
      estado: json['estado'],
      observacion: json['observacion'],
      tipoDescripcion: json['tipoDescripcion'],
    );
  }
}

class UltimoMantenimiento {
  final String? descripcion;
  final int? proximoKilometraje;
  final String? proximaFecha;
  final String? estado;

  UltimoMantenimiento({
    this.descripcion,
    this.proximoKilometraje,
    this.proximaFecha,
    this.estado,
  });

  factory UltimoMantenimiento.fromJson(Map<String, dynamic> json) {
    return UltimoMantenimiento(
      descripcion: json['descripcion'],
      proximoKilometraje: json['proximoKilometraje'],
      proximaFecha: json['proximaFecha'],
      estado: json['estado'],
    );
  }
}