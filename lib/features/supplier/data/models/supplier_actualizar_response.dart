// lib/features/supplier/data/models/supplier_actualizar_response.dart
// Descripcion: 

class SupplierActualizarResponse {
  final String status;
  final String message;
  final Map<String, dynamic> data;

  SupplierActualizarResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SupplierActualizarResponse.fromJson(Map<String, dynamic> json) {
    return SupplierActualizarResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] ?? {},
    );
  }

  int? get idProveedor => data['idProveedor'] as int?;
}