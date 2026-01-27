//Ruta: lib/features/accessory/data/models/accesorio_detalle_model.dart
class AccesorioDetalleModel {
  final int accesorioId;
  final String codigoFabricante;
  final DateTime fechaInstalacion;
  final int kilometrajeInstalacion;
  final DateTime? fechaRetiro;
  final int? kilometrajeRetiro;
  final String estado;
  final String observacion;
  final int vehiculoId;
  final String placa;
  final int tipoId;
  final String tipoNombre;
  final String tipoDescripcion;
  final String marca; // Asumo que viene o se usa la del tipo, pero agregaré campo si falta en JSON
  
  AccesorioDetalleModel({
    required this.accesorioId,
    required this.codigoFabricante,
    required this.fechaInstalacion,
    required this.kilometrajeInstalacion,
    this.fechaRetiro,
    this.kilometrajeRetiro,
    required this.estado,
    required this.observacion,
    required this.vehiculoId,
    required this.placa,
    required this.tipoId,
    required this.tipoNombre,
    required this.tipoDescripcion,
    this.marca = '', // Valor por defecto si no viene
  });

  factory AccesorioDetalleModel.fromJson(Map<String, dynamic> json) {
    return AccesorioDetalleModel(
      accesorioId: json['accesorioId'] ?? 0,
      codigoFabricante: json['codigoFabricante'] ?? '',
      fechaInstalacion: DateTime.parse(json['fechaInstalacion']),
      kilometrajeInstalacion: json['kilometrajeInstalacion'] ?? 0,
      fechaRetiro: json['fechaRetiro'] != null ? DateTime.parse(json['fechaRetiro']) : null,
      kilometrajeRetiro: json['kilometrajeRetiro'],
      estado: json['estado'] ?? '',
      observacion: json['observacion'] ?? '',
      vehiculoId: json['vehiculoId'] ?? 0,
      placa: json['placa'] ?? '',
      tipoId: json['tipoId'] ?? 0,
      tipoNombre: json['tipoNombre'] ?? '',
      tipoDescripcion: json['tipoDescripcion'] ?? '',
    );
  }

  get segmentoNombre => null;
}