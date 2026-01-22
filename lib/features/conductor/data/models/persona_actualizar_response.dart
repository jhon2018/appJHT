// Ruta: lib/features/conductor/data/models/persona_actualizar_response.dart

import 'package:flutter/foundation.dart';

@immutable
class PersonaActualizarResponse {
  final String status;
  final String message;
  final List<PersonaActualizarData> data;

  const PersonaActualizarResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PersonaActualizarResponse.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data'] as List<dynamic>)
        .map((item) => PersonaActualizarData.fromJson(item as Map<String, dynamic>))
        .toList();
    
    return PersonaActualizarResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      data: dataList,
    );
  }

  @override
  String toString() => 'PersonaActualizarResponse(status: $status, message: $message)';
}

@immutable
class PersonaActualizarData {
  final int idnuevaPersona;

  const PersonaActualizarData({
    required this.idnuevaPersona,
  });

  factory PersonaActualizarData.fromJson(Map<String, dynamic> json) {
    return PersonaActualizarData(
      idnuevaPersona: json['idnuevaPersona'] as int,
    );
  }

  @override
  String toString() => 'PersonaActualizarData(idnuevaPersona: $idnuevaPersona)';
}