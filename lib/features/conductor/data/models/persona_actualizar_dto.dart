// Ruta: lib/features/conductor/data/models/persona_actualizar_dto.dart
// FIX: fechaRegistroLicencia y fechaVencimientoLicencia se omiten del JSON cuando
//      están vacías/null. El servidor usa System.DateOnly (no-nullable) → recibir
//      null provoca un error de parse que a su vez invalida todo el DTO (400 doble).

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
  final String numeroLicencia;
  final String claseLicencia;
  final String categoriaLicencia;
  // Nullable: si están vacías NO se incluyen en el JSON
  final String? fechaRegistroLicencia;
  final String? fechaVencimientoLicencia;
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
    this.fechaRegistroLicencia,
    this.fechaVencimientoLicencia,
    required this.telefonos,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'personaId': personaId,
      'dni': dni,
      'primerNombre': primerNombre,
      'segundoNombre': segundoNombre,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'fechaNacimiento': fechaNacimiento.isEmpty ? null : fechaNacimiento,
      'correo': correo,
      'cargo': cargo,
      'salario': salario,
      'estado': estado,
      'fechaIngreso': fechaIngreso,
      'fechaSalida': (fechaSalida == null || fechaSalida!.isEmpty)
          ? null
          : fechaSalida,
      'usuario': usuario ?? '',
      'nuevaContrasena': nuevaContrasena ?? '',
      'numeroLicencia': numeroLicencia,
      'claseLicencia': claseLicencia,
      'categoriaLicencia': categoriaLicencia,
      'telefonos': telefonos.map((t) => t.toJson()).toList(),
    };

    // ── FIX CRÍTICO ────────────────────────────────────────────────────────
    // System.DateOnly en .NET NO acepta null ni "". Si la fecha está vacía,
    // omitimos la clave del JSON por completo para evitar el 400.
    if (fechaRegistroLicencia != null && fechaRegistroLicencia!.isNotEmpty) {
      map['fechaRegistroLicencia'] = fechaRegistroLicencia;
    }
    if (fechaVencimientoLicencia != null &&
        fechaVencimientoLicencia!.isNotEmpty) {
      map['fechaVencimientoLicencia'] = fechaVencimientoLicencia;
    }

    return map;
  }
}
