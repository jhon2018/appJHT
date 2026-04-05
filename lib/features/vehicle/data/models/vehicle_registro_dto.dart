/// Definición: Modelo de datos para el registro de vehículos
/// Objetivo: Representar la estructura de datos enviada al API
library;

class VehicleRegistroDto {
  final String vehVplaca;
  final String vehVmarca;
  final String vehVmodelo;
  final String vehVnumeroVin;
  final String vehVcolor;
  final int vehInumAsientos;
  final int vehInumEjes;
  final double vehBpesoNeto;
  final double vehBpesoBruto;
  final double vehBcargaUtil;
  final String vehDfechFabricacion;
  final double vehBlargo;
  final double vehBancho;
  final double vehBalto;
  final String vehVtipo;
  final int vehIkilometraje;
  final String vehVtarjetaUnicaCirculacion;
  final String vehDfechHabilitacionTuc;
  final String vehDfechVencimientoTuc;
  final String vehVestado;

  VehicleRegistroDto({
    required this.vehVplaca,
    required this.vehVmarca,
    required this.vehVmodelo,
    required this.vehVnumeroVin,
    required this.vehVcolor,
    required this.vehInumAsientos,
    required this.vehInumEjes,
    required this.vehBpesoNeto,
    required this.vehBpesoBruto,
    required this.vehBcargaUtil,
    required this.vehDfechFabricacion,
    required this.vehBlargo,
    required this.vehBancho,
    required this.vehBalto,
    required this.vehVtipo,
    required this.vehIkilometraje,
    required this.vehVtarjetaUnicaCirculacion,
    required this.vehDfechHabilitacionTuc,
    required this.vehDfechVencimientoTuc,
    required this.vehVestado,
  });



Map<String, dynamic> toJson() { //sirce para registro y actualización, pero en actualización se omiten campos como fecha_registro, fecha_baja, etc.
  return {
    'veh_vplaca': vehVplaca,
    'veh_vmarca': vehVmarca,
    'veh_vmodelo': vehVmodelo,
    'veh_vnumero_vin': vehVnumeroVin,
    'veh_vcolor': vehVcolor,
    'veh_inum_asientos': vehInumAsientos,
    'veh_inum_ejes': vehInumEjes,
    'veh_bpeso_neto': vehBpesoNeto,
    'veh_bpeso_bruto': vehBpesoBruto,
    'veh_bcarga_util': vehBcargaUtil,
    'veh_dfech_fabricacion': vehDfechFabricacion,
    'veh_blargo': vehBlargo,
    'veh_bancho': vehBancho,
    'veh_balto': vehBalto,
    'veh_vtipo': vehVtipo,
    'veh_ikilometraje': vehIkilometraje,
    'veh_vtarjeta_unica_circulacion': vehVtarjetaUnicaCirculacion,
    'veh_dfech_habilitacion_tuc': vehDfechHabilitacionTuc,
    'veh_dfech_vencimiento_tuc': vehDfechVencimientoTuc,
    'veh_fecha_registro': DateTime.now().toIso8601String(),
    'veh_fecha_baja': null,
    'veh_vestado': vehVestado,
  };
}
}