// lib/features/accessory/data/models/tipo_accesorio_model.dart
// descripción: Modelo de datos para representar un tipo de accesorio.
// objetivo: Definir la estructura del modelo de tipo de accesorio.

class TipoAccesorioModel {
  final int id;
  final String nombre;
  final String descripcion;

  TipoAccesorioModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });

  factory TipoAccesorioModel.fromJson(Map<String, dynamic> json) {
    return TipoAccesorioModel(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TipoAccesorioModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => nombre;
}