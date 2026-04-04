// lib/features/vehicle/data/models/vehicle_update_dto.dart

class VehicleUpdateDto {
  final int vehiculoId;
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
  final String? fechaRegistro;
  final String? fechaBaja;
  final String estado;

  VehicleUpdateDto({
    required this.vehiculoId,
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
    this.fechaRegistro,
    this.fechaBaja,
    required this.estado,
  });

  Map<String, dynamic> toJson() {
    return {
      'vehiculoId': vehiculoId,
      'placa': placa,
      'marca': marca,
      'modelo': modelo,
      'numeroVin': numeroVin,
      'color': color,
      'numAsientos': numAsientos,
      'numEjes': numEjes,
      'pesoNeto': pesoNeto,
      'pesoBruto': pesoBruto,
      'cargaUtil': cargaUtil,
      'fechaFabricacion': fechaFabricacion,
      'largo': largo,
      'ancho': ancho,
      'alto': alto,
      'tipo': tipo,
      'kilometraje': kilometraje,
      'tarjetaUnicaCirculacion': tarjetaUnicaCirculacion,
      'fechaHabilitacionTUC': fechaHabilitacionTUC,
      'fechaVencimientoTUC': fechaVencimientoTUC,
      'fechaRegistro': fechaRegistro,
      'fechaBaja': fechaBaja,
      'estado': estado,
    };
  }
}