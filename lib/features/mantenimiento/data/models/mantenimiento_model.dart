// Ruta: lib/features/mantenimiento/data/models/mantenimiento_model.dart
class MantenimientoModel {
  final int bitacoraId;
  final int accesorioId;
  final String fechaRegistro;
  final String estado;
  final String vehiculoPlaca;
  final String diccionarioMantenimiento;
  final String tipoAccesorio;

  MantenimientoModel({
    required this.bitacoraId,
    required this.accesorioId,
    required this.fechaRegistro,
    required this.estado,
    required this.vehiculoPlaca,
    required this.diccionarioMantenimiento,
    required this.tipoAccesorio,
  });

  factory MantenimientoModel.fromJson(Map<String, dynamic> json) {
    return MantenimientoModel(
      bitacoraId: json['bitacoraId'] ?? 0,
      accesorioId: json['accesorioId'] ?? 0,
      fechaRegistro: json['fechaRegistro'] ?? '',
      estado: json['estado'] ?? '',
      vehiculoPlaca: json['vehiculoPlaca'] ?? '',
      diccionarioMantenimiento: json['diccionarioMantenimiento'] ?? '',
      tipoAccesorio: json['tipoAccesorio'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bitacoraId': bitacoraId,
      'accesorioId': accesorioId,
      'fechaRegistro': fechaRegistro,
      'estado': estado,
      'vehiculoPlaca': vehiculoPlaca,
      'diccionarioMantenimiento': diccionarioMantenimiento,
      'tipoAccesorio': tipoAccesorio,
    };
  }
}

// Modelo para la respuesta de la API
class MantenimientoResponse {
  final String status;
  final String message;
  final List<MantenimientoModel> data;

  MantenimientoResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory MantenimientoResponse.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List;
    List<MantenimientoModel> mantenimientos = dataList
        .map((item) => MantenimientoModel.fromJson(item))
        .toList();

    return MantenimientoResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: mantenimientos,
    );
  }
}