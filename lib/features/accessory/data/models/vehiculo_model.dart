// lib/features/accessory/data/models/vehiculo_model.dart
class VehiculoModel {
  final int id;
  final String placa;
  final int kilometraje;

  VehiculoModel({
    required this.id,
    required this.placa,
    required this.kilometraje,
  });

  factory VehiculoModel.fromJson(Map<String, dynamic> json) {
    return VehiculoModel(
      id: json['id'],
      placa: json['placa'],
      kilometraje: json['kilometraje'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VehiculoModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => placa;
}