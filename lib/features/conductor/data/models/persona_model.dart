//Ruta: lib/features/conductor/data/models/persona_model.dart
import 'package:flutter/foundation.dart';
// En TelefonoModel, agrega el campo telId:
@immutable
class TelefonoModel {
  final int? telId;  // ← AGREGAR ESTE CAMPO
  final String numero;
  final String uso;
  final int? titId;

  const TelefonoModel({
    this.telId,  // ← AGREGAR
    required this.numero,
    required this.uso,
    this.titId,
  });

factory TelefonoModel.fromJson(Map<String, dynamic> json) {
  return TelefonoModel(
    telId: json['telId'] as int?,
    numero: json['numero']?.toString() ?? json['tel_vnumero']?.toString() ?? '',
    uso: json['uso']?.toString() ?? json['tit_vuso']?.toString() ?? 'Personal', // 'uso' suele venir como Personal/Trabajo
    // 🔥 CLAVE: El API manda 'tipoId', el modelo usa 'titId'
    titId: json['tipoId'] as int? ?? json['titId'] as int? ?? json['tit_iid'] as int?,
  );
}

  @override
  String toString() => '$numero ($uso)';
}

@immutable
class ConductorDetalleModel {
  final String numeroLicencia;
  final String claseLicencia;
  final String categoriaLicencia;
  final String fechaRegistroLicencia;
  final String fechaVencimientoLicencia;

  const ConductorDetalleModel({
    required this.numeroLicencia,
    required this.claseLicencia,
    required this.categoriaLicencia,
    required this.fechaRegistroLicencia,
    required this.fechaVencimientoLicencia,
  });
factory ConductorDetalleModel.fromJson(Map<String, dynamic> json) {
  return ConductorDetalleModel(
    numeroLicencia: json['numeroLicencia']?.toString() ?? json['con_vnumero_licencia']?.toString() ?? '',
    claseLicencia: json['claseLicencia']?.toString() ?? json['con_vclase_lic']?.toString() ?? '',
    categoriaLicencia: json['categoriaLicencia']?.toString() ?? json['con_vcategoria_lic']?.toString() ?? '',
    fechaRegistroLicencia: json['fechaRegistroLicencia']?.toString() ?? json['con_dfecha_registro_lic']?.toString() ?? '',
    fechaVencimientoLicencia: json['fechaVencimientoLicencia']?.toString() ?? json['con_dfecha_vencimiento_lic']?.toString() ?? '',
  );
}

  @override
  String toString() => 'Licencia: $numeroLicencia';
}

@immutable
class PersonaModel {
  final int personaId;
  final int dni;
  final String primerNombre;
  final String segundoNombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String? fechaNacimiento;
  final String? correo;
  final String? cargo;
  final double? salario;
  final String estado;
  final String fechaRegistro;
  final String? fechaIngreso;
  final String? fechaSalida;
  final List<TelefonoModel> telefonos;
  final ConductorDetalleModel? conductor;

  const PersonaModel({
    required this.personaId,
    required this.dni,
    required this.primerNombre,
    required this.segundoNombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    this.fechaNacimiento,
    this.correo,
    this.cargo,
    this.salario,
    required this.estado,
    required this.fechaRegistro,
    this.fechaIngreso,
    this.fechaSalida,
    required this.telefonos,
    this.conductor,
  });

  // Método para obtener nombre completo
  String get nombreCompleto {
    final nombres = [primerNombre, segundoNombre].where((n) => n != null && n.isNotEmpty).join(' ');
    final apellidos = [apellidoPaterno, apellidoMaterno].where((a) => a != null && a.isNotEmpty).join(' ');
    return '$nombres $apellidos'.trim();
  }

  // Método para obtener nombre corto (primer nombre + apellido paterno)
  String get nombreCorto {
    return '$primerNombre $apellidoPaterno'.trim();
  }

  // Método para formatear fecha de ingreso
  String get fechaIngresoFormateada {
    if (fechaIngreso == null) return 'No registrada';
    try {
      final date = DateTime.parse(fechaIngreso!);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return fechaIngreso!;
    }
  }

  // Método para obtener primer teléfono
  String? get primerTelefono {
    if (telefonos.isEmpty) return null;
    return telefonos.first.numero;
  }

  // Método para verificar si es conductor
  bool get esConductor => conductor != null;

factory PersonaModel.fromJson(Map<String, dynamic> json) {
  return PersonaModel(
    personaId: json['personaId'] as int,
    dni: json['dni'] as int,
    primerNombre: json['primerNombre']?.toString() ?? '',
    segundoNombre: json['segundoNombre']?.toString() ?? '',
    apellidoPaterno: json['apellidoPaterno']?.toString() ?? '',
    apellidoMaterno: json['apellidoMaterno']?.toString() ?? '',
    fechaNacimiento: json['fechaNacimiento']?.toString(),
    correo: json['correo']?.toString(),
    cargo: json['cargo']?.toString(),
    salario: (json['salario'] as num?)?.toDouble(),
    estado: json['estado']?.toString() ?? '',
    fechaRegistro: json['fechaRegistro']?.toString() ?? '',
    fechaIngreso: json['fechaIngreso']?.toString(),
    fechaSalida: json['fechaSalida']?.toString(),
    telefonos: (json['telefonos'] as List<dynamic>?)
        ?.map((tel) {
          // Manejar ambos formatos de teléfono
          if (tel is Map<String, dynamic>) {
            return TelefonoModel.fromJson(tel);
          }
          return TelefonoModel(numero: '', uso: '');
        })
        .toList() ?? [],
    conductor: json['conductor'] != null 
        ? ConductorDetalleModel.fromJson(json['conductor'] as Map<String, dynamic>)
        : null,
  );
}

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonaModel &&
          runtimeType == other.runtimeType &&
          personaId == other.personaId;

  @override
  int get hashCode => personaId.hashCode;

  get nombres => null;

  get email => null;

  @override
  String toString() => 'Persona $personaId: $nombreCompleto ($dni)';



  
}

