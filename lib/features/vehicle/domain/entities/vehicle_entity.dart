// lib/features/vehicle/domain/entities/vehicle_entity.dart

class VehicleEntity {
  final int? vehiculoId;
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
  final DateTime fechaFabricacion;
  final double largo;
  final double ancho;
  final double alto;
  final String tipo;
  final int kilometraje;
  final String tarjetaUnicaCirculacion;
  final DateTime fechaHabilitacionTUC;
  final DateTime fechaVencimientoTUC;
  final DateTime fechaRegistro;  // ← Cambiar a no nullable
  final DateTime? fechaBaja;
  final String estado;

  VehicleEntity({
    this.vehiculoId,
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
    required this.fechaRegistro,  // ← Ahora requerido
    this.fechaBaja,
    required this.estado,
  });
}