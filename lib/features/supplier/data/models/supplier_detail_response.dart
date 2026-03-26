// lib/features/supplier/data/models/supplier_detail_response.dart
import 'package:app_jht_front/features/supplier/data/models/supplier_detail_model.dart';

class SupplierDetailResponse {
  final String status;
  final String message;
  final SupplierDetailModel data;

  SupplierDetailResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SupplierDetailResponse.fromJson(Map<String, dynamic> json) {
    return SupplierDetailResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: SupplierDetailModel.fromJson(json['data'] ?? {}),
    );
  }
}