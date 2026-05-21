//Ruta: lib/features/conductor/data/models/conductor_registro_dto.dart

import 'package:app_jht_front/features/supplier/data/models/tipo_telefono_model.dart';

class TelefonoConductorDto {
  final String numero;
  final int tipoId;

  TelefonoConductorDto({
    required this.numero,
    required this.tipoId,
  });

  Map<String, dynamic> toJson() {
    return {
      'tel_vnumero': numero,
      'tit_iid': tipoId,
    };
  }
}

class PersonaDto {
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

  PersonaDto({
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
  });

  Map<String, dynamic> toJson() {
    return {
      'per_idni': dni,
      'per_vprimer_nom': primerNombre,
      'per_vsegundo_nom': segundoNombre,
      'per_vapellido_pa': apellidoPaterno,
      'per_vapellido_ma': apellidoMaterno,
      // Enviar null si vacío; .NET espera DateOnly? y falla con string vacío ""
      'per_dfecha_nacimiento': fechaNacimiento.isEmpty ? null : fechaNacimiento,
      'per_vcorreo': correo,
      'per_vcargo': cargo,
      'per_isalario': salario,
      'per_vestado': estado,
      'per_dfecha_ingreso': fechaIngreso.isEmpty ? null : fechaIngreso,
    };
  }
}

class ConductorDto {
  final String numeroLicencia;
  final String claseLicencia;
  final String categoriaLicencia;
  final String fechaRegistroLicencia;
  final String fechaVencimientoLicencia;

  ConductorDto({
    required this.numeroLicencia,
    required this.claseLicencia,
    required this.categoriaLicencia,
    required this.fechaRegistroLicencia,
    required this.fechaVencimientoLicencia,
  });

  Map<String, dynamic> toJson() {
    return {
      'con_vnumero_licencia': numeroLicencia,
      'con_vclase_lic': claseLicencia,
      'con_vcategoria_lic': categoriaLicencia,
      'con_dfecha_registro_lic': fechaRegistroLicencia,
      'con_dfecha_vencimiento_lic': fechaVencimientoLicencia,
    };
  }
}

class ConductorRegistroDto {
  final PersonaDto persona;
  final ConductorDto? conductor; // Null si cargo es "Administrador"
  final List<TelefonoConductorDto> telefonos;

  ConductorRegistroDto({
    required this.persona,
    this.conductor,
    required this.telefonos,
  });

  Map<String, dynamic> toJson() {
    return {
      'persona': persona.toJson(),
      if (conductor != null) 'conductor': conductor!.toJson(),
      'telefonos': telefonos.map((tel) => tel.toJson()).toList(),
    };
  }
}
