//Ruta: lib/features/conductor/data/models/conductor_registro_response.dart

class ConductorRegistroResponse {
  final String status;
  final String message;
  final List<Map<String, dynamic>> data;

  ConductorRegistroResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ConductorRegistroResponse.fromJson(Map<String, dynamic> json) {
    return ConductorRegistroResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      data: (json['data'] as List).cast<Map<String, dynamic>>(),
    );
  }
}

