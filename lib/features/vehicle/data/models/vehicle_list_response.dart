// lib/features/vehicle/data/models/vehicle_list_response.dart
class VehicleListResponse {
  final String status;
  final String message;
  final List<VehicleListData> data;

  VehicleListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory VehicleListResponse.fromJson(Map<String, dynamic> json) {
    return VehicleListResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => VehicleListData.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class VehicleListData {
  final int id;
  final String placa;
  final String marca;
  final String modelo;
  final String numeroVin;
  final String color;
  final int numAsientos;
  final int numEjes;
  final double pesoNeto;
  final double pesoBruto;
  final double cargaUtil;
  final String fechaFabricacion;
  final double largo;
  final double ancho;
  final double alto;
  final String tipo;
  final int kilometraje;
  final String tarjetaUnicaCirculacion;
  final String fechaHabilitacionTUC;
  final String fechaVencimientoTUC;
  final String fechaRegistro;
  final String? fechaBaja;
  final String estado;

  VehicleListData({
    required this.id,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.numeroVin,
    required this.color,
    required this.numAsientos,
    required this.numEjes,
    required this.pesoNeto,
    required this.pesoBruto,
    required this.cargaUtil,
    required this.fechaFabricacion,
    required this.largo,
    required this.ancho,
    required this.alto,
    required this.tipo,
    required this.kilometraje,
    required this.tarjetaUnicaCirculacion,
    required this.fechaHabilitacionTUC,
    required this.fechaVencimientoTUC,
    required this.fechaRegistro,
    this.fechaBaja,
    required this.estado,
  });

  factory VehicleListData.fromJson(Map<String, dynamic> json) {
    return VehicleListData(
      id: json['vehiculoId'] ?? 0,
      placa: json['placa'] ?? '',
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      numeroVin: json['numeroVin'] ?? '',
      color: json['color'] ?? '',
      numAsientos: json['numAsientos'] ?? 0,
      numEjes: json['numEjes'] ?? 0,
      pesoNeto: (json['pesoNeto'] ?? 0).toDouble(),
      pesoBruto: (json['pesoBruto'] ?? 0).toDouble(),
      cargaUtil: (json['cargaUtil'] ?? 0).toDouble(),
      fechaFabricacion: json['fechaFabricacion'] ?? '',
      largo: (json['largo'] ?? 0).toDouble(),
      ancho: (json['ancho'] ?? 0).toDouble(),
      alto: (json['alto'] ?? 0).toDouble(),
      tipo: json['tipo'] ?? '',
      kilometraje: json['kilometraje'] ?? 0,
      tarjetaUnicaCirculacion: json['tarjetaUnicaCirculacion'] ?? '',
      fechaHabilitacionTUC: json['fechaHabilitacionTUC'] ?? '',
      fechaVencimientoTUC: json['fechaVencimientoTUC'] ?? '',
      fechaRegistro: json['fechaRegistro'] ?? '',
      fechaBaja: json['fechaBaja'],
      estado: json['estado'] ?? '',
    );
  }
}