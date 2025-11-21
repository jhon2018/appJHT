// lib/features/accessory/data/models/segmento_model.dart
// descripción: Modelo de datos para representar un segmento de accesorio.
// Objetivo: Definir la estructura del modelo de segmento de accesorio.

class SegmentoModel {
  final int id;
  final String nombre;
  final String definicion;
  final String resumen;
  final DateTime fechaRegistro;

  SegmentoModel({
    required this.id,
    required this.nombre,
    required this.definicion,
    required this.resumen,
    required this.fechaRegistro,
  });

  factory SegmentoModel.fromJson(Map<String, dynamic> json) {
    return SegmentoModel(
      id: json['id'],
      nombre: json['nombre'],
      definicion: json['definicion'],
      resumen: json['resumen'],
      fechaRegistro: DateTime.parse(json['fechaRegistro']),
    );
  }

  // MÉTODO CRÍTICO PARA DROPDOWN - AGREGA ESTO
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SegmentoModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => nombre;
}