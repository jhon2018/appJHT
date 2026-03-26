// lib/features/supplier/data/models/supplier_list_response.dart
import 'package:app_jht_front/features/supplier/data/models/supplier_list_model.dart';

class SupplierListResponse {
  final String status;
  final String message;
  final List<SupplierListModel> data;

  SupplierListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SupplierListResponse.fromJson(Map<String, dynamic> json) {
    return SupplierListResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => SupplierListModel.fromJson(item))
          .toList(),
    );
  }
}