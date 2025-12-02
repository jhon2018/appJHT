// lib/features/accessory/data/models/accesorio_registro_response.dart
// // Descripción: Modelo de respuesta para el registro de un accesorio en un vehículo.
// // Objetivo: Representar la respuesta recibida del servidor tras intentar registrar un accesorio.
class AccesorioRegistroResponse {
  final String status;  // "OK" o "ERROR"
  final String message;
  final Map<String, dynamic>? data;

  const AccesorioRegistroResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory AccesorioRegistroResponse.fromJson(Map<String, dynamic> json) {
    // La API devuelve "data" como array, tomamos el primer elemento si existe
    final dataArray = json['data'] as List<dynamic>?;
    final firstData = dataArray != null && dataArray.isNotEmpty 
        ? dataArray[0] 
        : null;
    
    return AccesorioRegistroResponse(
      status: json['status'] ?? 'ERROR',
      message: json['message'] ?? '',
      data: firstData != null ? Map<String, dynamic>.from(firstData) : null,
    );
  }
}