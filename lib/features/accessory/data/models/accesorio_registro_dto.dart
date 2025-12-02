// lib/features/accessory/data/models/accesorio_registro_dto.dart
// description: DTO para el registro de un accesorio en un vehículo.
// objetivo: Facilitar la transferencia de datos necesarios para registrar un accesorio en el sistema.

class AccesorioRegistroDto {
  final String marca;
  final String codigoFabricante;
  final DateTime fechaInstalacion;
  final int kilometrajeInstalacion;
  final String estado;
  final String observacion;
  final int vehiculoId;
  final int tipoAccesorioId;

  const AccesorioRegistroDto({
    required this.marca,
    required this.codigoFabricante,
    required this.fechaInstalacion,
    required this.kilometrajeInstalacion,
    required this.estado,
    required this.observacion,
    required this.vehiculoId,
    required this.tipoAccesorioId,
  });

  Map<String, dynamic> toJson() => {
    'marca': marca,
    'codigoFabricante': codigoFabricante,
    'fechaInstalacion': _formatDateForApi(fechaInstalacion),
    'kilometrajeInstalacion': kilometrajeInstalacion,
    'estado': estado,
    'observacion': observacion,
    'vehiculoId': vehiculoId,
    'tipoAccesorioId': tipoAccesorioId,
  };

  // lib/features/accessory/data/models/accesorio_registro_dto.dart
  String _formatDateForApi(DateTime date) {
    // Si la hora es 00:00:00 (usuario solo seleccionó fecha), usar 10:30:00 como default
    DateTime dateToSend = date;
    if (date.hour == 0 && date.minute == 0 && date.second == 0) {
      dateToSend = DateTime(
        date.year,
        date.month,
        date.day,
        10, // 10 AM como hora por defecto
        30, // 30 minutos
        0, // 0 segundos
      );
      print('🕒 Usando hora por defecto (10:30:00)');
    }

    final localDate = dateToSend.toLocal();

    return "${localDate.year.toString().padLeft(4, '0')}-"
        "${localDate.month.toString().padLeft(2, '0')}-"
        "${localDate.day.toString().padLeft(2, '0')}T"
        "${localDate.hour.toString().padLeft(2, '0')}:"
        "${localDate.minute.toString().padLeft(2, '0')}:"
        "${localDate.second.toString().padLeft(2, '0')}";
  }

  @override
  String toString() {
    return 'AccesorioRegistroDto{marca: $marca, fecha: ${_formatDateForApi(fechaInstalacion)}, vehiculoId: $vehiculoId, tipoAccesorioId: $tipoAccesorioId}';
  }
}
