//lib\features\vehicle\data\models\vehicle_registro_response.dart
import 'package:app_jht_front/features/vehicle/data/models/vehicle_registro_dto.dart';

/// Definición: Modelo de respuesta del API al registrar vehículo
/// Objetivo: Parsear y tipificar la respuesta del servidor

class VehicleRegistroResponse {
  final String status;
  final String message;
  final List<VehicleData> data;

  VehicleRegistroResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory VehicleRegistroResponse.fromJson(Map<String, dynamic> json) {
    return VehicleRegistroResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => VehicleData.fromJson(item))
              .toList() ??
          [],
    );
  }

  VehicleRegistroDto? get vehiculo => null;
}

class VehicleData {
  final int idVehiculo;

  VehicleData({required this.idVehiculo});

  factory VehicleData.fromJson(Map<String, dynamic> json) {
    return VehicleData(
      idVehiculo: json['IdVehiculo'] ?? json['idVehiculo'] ?? 0,
    );
  }
}