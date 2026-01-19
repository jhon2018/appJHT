import 'package:flutter/foundation.dart';
import 'persona_model.dart';

@immutable
class PersonaDetalleResponse {
  final String status;
  final String message;
  final PersonaModel data;

  const PersonaDetalleResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PersonaDetalleResponse.fromJson(Map<String, dynamic> json) {
    return PersonaDetalleResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      data: PersonaModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  @override
  String toString() => 'PersonaDetalleResponse(${data.nombreCompleto})';
}