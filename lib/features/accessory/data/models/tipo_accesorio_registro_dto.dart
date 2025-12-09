// lib/features/accessory/data/models/tipo_accesorio_registro_dto.dart
class TipoAccesorioRegistroDto {
  final TipoAccesorioRegistro tipoAccesorio;
  final List<DiccionarioDto> diccionarios;

  TipoAccesorioRegistroDto({
    required this.tipoAccesorio,
    required this.diccionarios,
  });

  Map<String, dynamic> toJson() => {
    "tipoAccesorio": tipoAccesorio.toJson(),
    "diccionarios": diccionarios.map((d) => d.toJson()).toList(),
  };
}

class TipoAccesorioRegistro {
  final String tipVnombre;
  final String tipVunidadMedida;
  final int tipIcantidad;
  final String tipVdescripcion;
  final int segIid;

  TipoAccesorioRegistro({
    required this.tipVnombre,
    required this.tipVunidadMedida,
    required this.tipIcantidad,
    required this.tipVdescripcion,
    required this.segIid,
  });

  Map<String, dynamic> toJson() => {
    "tip_vnombre": tipVnombre,
    "tip_vunidad_medida": tipVunidadMedida,
    "tip_icantidad": tipIcantidad,
    "tip_vdescripcion": tipVdescripcion,
    "seg_iid": segIid,
  };
}

class DiccionarioDto {
  final String dicVnombre;
  final String dicVdescripcion;
  final String dicVtipo;
  final int dicIfrecuenciaKilometros;
  final int dicIfrecuenciaTiempo;
  final String dicVestado;

  DiccionarioDto({
    required this.dicVnombre,
    required this.dicVdescripcion,
    required this.dicVtipo,
    required this.dicIfrecuenciaKilometros,
    required this.dicIfrecuenciaTiempo,
    required this.dicVestado,
  });

  Map<String, dynamic> toJson() => {
    "dic_vnombre": dicVnombre,
    "dic_vdescripcion": dicVdescripcion,
    "dic_vtipo": dicVtipo,
    "dic_ifrecuencia_kilometros": dicIfrecuenciaKilometros,
    "dic_ifrecuencia_tiempo": dicIfrecuenciaTiempo,
    "dic_vestado": dicVestado,
  };
}