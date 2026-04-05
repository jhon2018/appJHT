// lib/features/vehicle/data/models/vehicle_update_response.dart

class VehicleUpdateResponse {
  final String status;
  final String message;
  final VehicleUpdateData? data;

  VehicleUpdateResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory VehicleUpdateResponse.fromJson(Map<String, dynamic> json) {
    return VehicleUpdateResponse(
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      data: json['data'] != null 
          ? VehicleUpdateData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class VehicleUpdateData {
  final int idVehiculo;

  VehicleUpdateData({required this.idVehiculo});

  factory VehicleUpdateData.fromJson(Map<String, dynamic> json) {
    return VehicleUpdateData(
      idVehiculo: json['idVehiculo'] as int? ?? 0,
    );
  }
}