// lib/features/mantenimiento/data/models/accesorio_vehiculo_model.dart

class AccesorioVehiculoModel {
  final int idAccesorio;
  final String marca;
  final String codigoFabricante;
  final String fechaInstalacion;
  final int tipoId;
  final String tipoNombre;

  const AccesorioVehiculoModel({
    required this.idAccesorio,
    required this.marca,
    required this.codigoFabricante,
    required this.fechaInstalacion,
    required this.tipoId,
    required this.tipoNombre,
  });

  factory AccesorioVehiculoModel.fromJson(Map<String, dynamic> json) =>
      AccesorioVehiculoModel(
        idAccesorio: json['idAccesorio'] ?? 0,
        marca: json['marca'] ?? '',
        codigoFabricante: json['codigoFabricante'] ?? '',
        fechaInstalacion: json['fechaInstalacion'] ?? '',
        tipoId: json['tipoId'] ?? 0,
        tipoNombre: json['tipoNombre'] ?? '',
      );

  String get descripcionCorta => '$tipoNombre — $marca ($codigoFabricante)';
}

// ─────────────────────────────────────────────────────────────────────────────

// lib/features/mantenimiento/data/models/accesorio_concepto_model.dart

class AccesorioConceptoModel {
  final int accesorioId;
  final String marca;
  final String codigoFabricante;
  final String fechaInstalacion;
  final String tipoNombre;
  final String conceptoNombre;
  /// "Cambio" o "Mantenimiento"
  final String conceptoTipo;

  const AccesorioConceptoModel({
    required this.accesorioId,
    required this.marca,
    required this.codigoFabricante,
    required this.fechaInstalacion,
    required this.tipoNombre,
    required this.conceptoNombre,
    required this.conceptoTipo,
  });

  bool get esCambio =>
      conceptoTipo.toLowerCase() == 'cambio';

  factory AccesorioConceptoModel.fromJson(Map<String, dynamic> json) =>
      AccesorioConceptoModel(
        accesorioId: json['accesorioId'] ?? 0,
        marca: json['marca'] ?? '',
        codigoFabricante: json['codigoFabricante'] ?? '',
        fechaInstalacion: json['fechaInstalacion'] ?? '',
        tipoNombre: json['tipoNombre'] ?? '',
        conceptoNombre: json['conceptoNombre'] ?? '',
        conceptoTipo: json['conceptoTipo'] ?? '',
      );
}

// ─────────────────────────────────────────────────────────────────────────────

// lib/features/mantenimiento/data/models/concepto_mantenimiento_model.dart

class ConceptoMantenimientoModel {
  final int id;
  final String nombre;
  /// "Cambio" o "Mantenimiento"
  final String tipo;
  final int frecuenciaKilometros;
  final int frecuenciaTiempo;

  const ConceptoMantenimientoModel({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.frecuenciaKilometros,
    required this.frecuenciaTiempo,
  });

  bool get esCambio => tipo.toLowerCase() == 'cambio';

  factory ConceptoMantenimientoModel.fromJson(Map<String, dynamic> json) =>
      ConceptoMantenimientoModel(
        id: json['id'] ?? 0,
        nombre: json['nombre'] ?? '',
        tipo: json['tipo'] ?? '',
        frecuenciaKilometros: json['frecuenciaKilometros'] ?? 0,
        frecuenciaTiempo: json['frecuenciaTiempo'] ?? 0,
      );
}