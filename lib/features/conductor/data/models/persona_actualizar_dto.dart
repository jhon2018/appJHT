// Ruta: lib/features/conductor/data/models/persona_actualizar_dto.dart

import 'package:flutter/foundation.dart';

@immutable
class TelefonoActualizarDto {
  final int telId;
  final String numero;
  final int titId;

  const TelefonoActualizarDto({
    required this.telId,
    required this.numero,
    required this.titId,
  });

  Map<String, dynamic> toJson() => {
        'telId': telId,
        'numero': numero,
        'titId': titId,
      };
}

@immutable
class PersonaActualizarDto {
  final int personaId;
  final int dni;
  final String primerNombre;
  final String segundoNombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String fechaNacimiento;
  final String correo;
  final String cargo;
  final double salario;
  final String estado;
  final String fechaIngreso;
  final String? fechaSalida;
  final String? usuario;
  final String? nuevaContrasena;
  // Campos de conductor aplanados para el API
  final String numeroLicencia;
  final String claseLicencia;
  final String categoriaLicencia;
  final String fechaRegistroLicencia;
  final String fechaVencimientoLicencia;
  final List<TelefonoActualizarDto> telefonos;

  const PersonaActualizarDto({
    required this.personaId,
    required this.dni,
    required this.primerNombre,
    required this.segundoNombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.fechaNacimiento,
    required this.correo,
    required this.cargo,
    required this.salario,
    required this.estado,
    required this.fechaIngreso,
    this.fechaSalida,
    this.usuario,
    this.nuevaContrasena,
    required this.numeroLicencia,
    required this.claseLicencia,
    required this.categoriaLicencia,
    required this.fechaRegistroLicencia,
    required this.fechaVencimientoLicencia,
    required this.telefonos,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'personaId': personaId,
      'dni': dni,
      'primerNombre': primerNombre,
      'segundoNombre': segundoNombre,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'fechaNacimiento': fechaNacimiento,
      'correo': correo,
      'cargo': cargo,
      'salario': salario,
      'estado': estado,
      'fechaIngreso': fechaIngreso,
      'fechaSalida': fechaSalida, // Ahora incluido
      'usuario': usuario ?? "",
      'nuevaContrasena': nuevaContrasena ?? "",
      'numeroLicencia': numeroLicencia,
      'claseLicencia': claseLicencia,
      'categoriaLicencia': categoriaLicencia,
      'fechaRegistroLicencia': fechaRegistroLicencia,
      'fechaVencimientoLicencia': fechaVencimientoLicencia,
      'telefonos': telefonos.map((t) => t.toJson()).toList(),
    };
    return json;
  }
}