// lib/features/accessory/data/models/accesorio_actualizar_dto.dart

class AccesorioActualizarDto {
  final int accesorioId;
  final String marca;
  final String codigoFabricante;
  final DateTime fechaInstalacion;
  final int kilometrajeInstalacion;
  final DateTime? fechaRetiro;
  final int kilometrajeRetiro;
  final String estado;
  final String observacion;
  final int vehiculoId;
  final int tipoId;

  AccesorioActualizarDto({
    required this.accesorioId,
    required this.marca,
    required this.codigoFabricante,
    required this.fechaInstalacion,
    required this.kilometrajeInstalacion,
    this.fechaRetiro,
    required this.kilometrajeRetiro,
    required this.estado,
    required this.observacion,
    required this.vehiculoId,
    required this.tipoId,
  });

  Map<String, dynamic> toJson() {
    return {
      'AccesorioId': accesorioId,
      'Marca': marca,
      'CodigoFabricante': codigoFabricante,
      'FechaInstalacion': fechaInstalacion.toIso8601String(),
      'KilometrajeInstalacion': kilometrajeInstalacion,
      'FechaRetiro': fechaRetiro != null
          ? '${fechaRetiro!.year.toString().padLeft(4, '0')}-'
            '${fechaRetiro!.month.toString().padLeft(2, '0')}-'
            '${fechaRetiro!.day.toString().padLeft(2, '0')}'
          : null,
      'KilometrajeRetiro': kilometrajeRetiro,
      'Estado': estado,
      'Observacion': observacion,
      'VehiculoId': vehiculoId,
      'TipoId': tipoId,
    };
  }
}