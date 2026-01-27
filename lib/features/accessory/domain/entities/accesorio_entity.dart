// lib/features/accessory/domain/entities/accesorio_entity.dart
// description: Entidad que representa un accesorio instalado en un vehículo.
// // objetivo: Definir la estructura de datos para un accesorio en el dominio de la aplicación.

class AccesorioEntity {
  final int id;
  final String marca;
  final String codigoFabricante;
  final DateTime fechaInstalacion;
  final int kilometrajeInstalacion;
  final String estado;
  final String observacion;
  final int vehiculoId;
  final int tipoAccesorioId;

  const AccesorioEntity({
    required this.id,
    required this.marca,
    required this.codigoFabricante,
    required this.fechaInstalacion,
    required this.kilometrajeInstalacion,
    required this.estado,
    required this.observacion,
    required this.vehiculoId,
    required this.tipoAccesorioId,
  });
}