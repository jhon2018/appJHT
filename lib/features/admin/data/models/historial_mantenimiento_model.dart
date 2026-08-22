// lib/features/admin/data/models/historial_mantenimiento_model.dart

class HistorialGeneralItem {
  final String bitDfechRegistro;
  final String vehVplaca;
  final String vehVmarca;
  final int bitIkilometraje;
  final int bitIcantidad;
  final String dicVnombre;
  final String dicVdescripcion;
  final String dicVtipo;
  final String hisVdescripcion;
  final int hisIproximoKilometraje;
  final String hisDproximaFech;
  final String segVnombre;
  final String perVprimerNom;
  final String perVsegundoNom;
  final String perVapellidoPa;
  final String perVapellidoMa;
  final String hisVestado;
  final String? hisVlinkFoto;
  final String tipVnombre;
  final String proVrazonSocial;
  final String gasVtipo;
  final String gasVnumeroDocumento; // Confirmado por backend (String)
  final double gasBmonto;
  final String? gastoVlinkFoto;

  HistorialGeneralItem({
    required this.bitDfechRegistro,
    required this.vehVplaca,
    required this.vehVmarca,
    required this.bitIkilometraje,
    required this.bitIcantidad,
    required this.dicVnombre,
    required this.dicVdescripcion,
    required this.dicVtipo,
    required this.hisVdescripcion,
    required this.hisIproximoKilometraje,
    required this.hisDproximaFech,
    required this.segVnombre,
    required this.perVprimerNom,
    required this.perVsegundoNom,
    required this.perVapellidoPa,
    required this.perVapellidoMa,
    required this.hisVestado,
    this.hisVlinkFoto,
    required this.tipVnombre,
    required this.proVrazonSocial,
    required this.gasVtipo,
    required this.gasVnumeroDocumento,
    required this.gasBmonto,
    this.gastoVlinkFoto,
  });

  factory HistorialGeneralItem.fromJson(Map<String, dynamic> json) {
    return HistorialGeneralItem(
      bitDfechRegistro: json['bit_dfech_registro'] ?? '',
      vehVplaca: json['veh_vplaca'] ?? '',
      vehVmarca: json['veh_vmarca'] ?? '',
      bitIkilometraje: json['bit_ikilometraje'] ?? 0,
      bitIcantidad: json['bit_icantidad'] ?? 0,
      dicVnombre: json['dic_vnombre'] ?? '',
      dicVdescripcion: json['dic_vdescripcion'] ?? '',
      dicVtipo: json['dic_vtipo'] ?? '',
      hisVdescripcion: json['his_vdescripcion'] ?? '',
      hisIproximoKilometraje: json['his_iproximo_kilometraje'] ?? 0,
      hisDproximaFech: json['his_dproxima_fech'] ?? '',
      segVnombre: json['seg_vnombre'] ?? '',
      perVprimerNom: json['per_vprimer_nom'] ?? '',
      perVsegundoNom: json['per_vsegundo_nom'] ?? '',
      perVapellidoPa: json['per_vapellido_pa'] ?? '',
      perVapellidoMa: json['per_vapellido_ma'] ?? '',
      hisVestado: json['his_vestado'] ?? '',
      hisVlinkFoto: json['his_vlink_foto'],
      tipVnombre: json['tip_vnombre'] ?? '',
      proVrazonSocial: json['pro_vrazon_social'] ?? '',
      gasVtipo: json['gas_vtipo'] ?? '',
      gasVnumeroDocumento: json['gas_vnumero_documento'] ?? '',
      gasBmonto: (json['gas_bmonto'] ?? 0).toDouble(),
      gastoVlinkFoto: json['gasto_vlink_foto'],
    );
  }
}

class HistorialPorFechaItem {
  final String mes;
  final int anio;
  final int cantidad;

  HistorialPorFechaItem({
    required this.mes,
    required this.anio,
    required this.cantidad,
  });

  factory HistorialPorFechaItem.fromJson(Map<String, dynamic> json) {
    return HistorialPorFechaItem(
      mes: json['mes'] ?? '',
      anio: json['anio'] ?? 0,
      cantidad: json['cantidad'] ?? 0,
    );
  }
}

class HistorialPorAccesorioItem {
  final String tipVnombre;
  final int cantidad;

  HistorialPorAccesorioItem({
    required this.tipVnombre,
    required this.cantidad,
  });

  factory HistorialPorAccesorioItem.fromJson(Map<String, dynamic> json) {
    return HistorialPorAccesorioItem(
      tipVnombre: json['tip_vnombre'] ?? '',
      cantidad: json['cantidad'] ?? 0,
    );
  }
}

class HistorialDashboardResponse {
  final List<HistorialGeneralItem> historialGeneral;
  final List<HistorialPorFechaItem> consultaHistorialPorFecha;
  final List<HistorialPorAccesorioItem> consultaHistorialPorAccesorio;

  HistorialDashboardResponse({
    required this.historialGeneral,
    required this.consultaHistorialPorFecha,
    required this.consultaHistorialPorAccesorio,
  });

  factory HistorialDashboardResponse.fromJson(Map<String, dynamic> json) {
    return HistorialDashboardResponse(
      historialGeneral: (json['historialGeneral'] as List? ?? [])
          .map((e) => HistorialGeneralItem.fromJson(e))
          .toList(),
      consultaHistorialPorFecha: (json['consultaHistorialPorFecha'] as List? ?? [])
          .map((e) => HistorialPorFechaItem.fromJson(e))
          .toList(),
      consultaHistorialPorAccesorio: (json['consultaHistorialPorAccesorio'] as List? ?? [])
          .map((e) => HistorialPorAccesorioItem.fromJson(e))
          .toList(),
    );
  }
}
