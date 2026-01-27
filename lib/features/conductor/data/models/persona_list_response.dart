//Ruta: lib/features/conductor/data/models/persona_list_response.dart
import 'package:flutter/foundation.dart';
import 'persona_model.dart';

@immutable
class PersonaListResponse {
  final String status;
  final String message;
  final List<PersonaModel> data;

  const PersonaListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PersonaListResponse.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data'] as List<dynamic>)
        .map((item) => PersonaModel.fromJson(item as Map<String, dynamic>))
        .toList();
    
    return PersonaListResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      data: dataList,
    );
  }

  @override
  String toString() => 'PersonaListResponse(${data.length} personas)';
}