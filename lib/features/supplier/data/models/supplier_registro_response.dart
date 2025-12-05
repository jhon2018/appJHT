// lib/features/supplier/data/models/supplier_registro_response.dart

class SupplierRegistroResponse {
  final String status;
  final String message;
  final List<Map<String, dynamic>> data;

  SupplierRegistroResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SupplierRegistroResponse.fromJson(Map<String, dynamic> json) {
    return SupplierRegistroResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => item as Map<String, dynamic>)
          .toList(),
    );
  }

  int? get insertedId {
    if (data.isNotEmpty && data.first.containsKey('idProveedor')) {
      return data.first['idProveedor'] as int?;
    }
    return null;
  }
}