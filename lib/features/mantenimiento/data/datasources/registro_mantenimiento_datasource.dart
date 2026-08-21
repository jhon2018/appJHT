// lib/features/mantenimiento/data/datasources/registro_mantenimiento_datasource.dart

import 'dart:convert';
import 'package:app_jht_front/features/mantenimiento/data/models/accesorio_vehiculo_model.dart';
import 'package:http/http.dart' as http;
import 'package:app_jht_front/core/network/base_remote_data_source.dart';
import 'package:app_jht_front/core/utils/app_logger.dart';
import '../models/datos_iniciales_model.dart';
import '../models/accesorio_models.dart';
import '../services/photo_upload_service.dart';
import '../services/multipart_photo_upload_service.dart';

// ─── HistoricoItem — un ítem del array HistoricoMantenimientosJson ────────────
class HistoricoItem {
  final int accIid;
  final String hisVdescripcion;
  final int hisIproxKilometraje;
  final String hisDproximaFech; // "yyyy-MM-dd"
  final String hisVestado;
  final String dicVtipo; // "Mantenimiento" | "Cambio"
  final int dicIid;
  // Solo Cambio
  final String? accVmarca;
  final String? accVcodigoFabricante;
  final int? accIkilometrajeInstalacion;
  final String accVestado; // siempre "Activo"
  final int? vehIid;
  final int? tipIid; // acc.tipoId de API13
  // Foto del ítem (se sube como FotosHistorico[i])
  final SelectedPhoto? foto;

  const HistoricoItem({
    required this.accIid,
    required this.hisVdescripcion,
    required this.hisIproxKilometraje,
    required this.hisDproximaFech,
    required this.hisVestado,
    required this.dicVtipo,
    required this.dicIid,
    this.accVmarca,
    this.accVcodigoFabricante,
    this.accIkilometrajeInstalacion,
    this.accVestado = 'Activo',
    this.vehIid,
    this.tipIid,
    this.foto,
  });

  bool get esCambio => dicVtipo.toLowerCase().contains('cambio');

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'acc_iid': accIid,
      'his_vdescripcion': hisVdescripcion,
      'his_iproximo_kilometraje': hisIproxKilometraje,
      'his_dproxima_fech': hisDproximaFech,
      'his_vestado': hisVestado,
      'his_vlink_foto': '',
      'dic_vtipo': dicVtipo,
      'dic_iid': dicIid,
      'acc_vestado': accVestado,
    };
    if (esCambio) {
      map['acc_vmarca'] = accVmarca ?? '';
      map['acc_vcodigo_fabricante'] = accVcodigoFabricante ?? '';
      map['acc_ikilometraje_instalacion'] = accIkilometrajeInstalacion ?? 0;
      map['veh_iid'] = vehIid ?? 0;
      map['tip_iid'] = tipIid ?? 0;
    }
    return map;
  }
}

// ─── GastoRegistro ────────────────────────────────────────────────────────────
class GastoRegistro {
  final String gasVtipo; // Boleta | Factura
  final String gasVnumeroDocumento;
  final String gasVtipoGasto; // Mantenimiento | Compra
  final String gasVmoneda; // Soles | Dólares
  final double gasBmonto;
  final String gasDfechaGasto; // "yyyy-MM-dd" — fecha de mantenimiento
  final String gasVdescripcion;
  final SelectedPhoto? foto;

  const GastoRegistro({
    required this.gasVtipo,
    required this.gasVnumeroDocumento,
    required this.gasVtipoGasto,
    required this.gasVmoneda,
    required this.gasBmonto,
    required this.gasDfechaGasto,
    required this.gasVdescripcion,
    this.foto,
  });
}

// ─── Interface ────────────────────────────────────────────────────────────────
abstract class RegistroMantenimientoDataSource {
  Future<DatosInicialesModel> getDatosIniciales();
  Future<List<AccesorioVehiculoModel>> getAccesoriosPorVehiculo(int vehiculoId);
  Future<List<AccesorioConceptoModel>> getAccesoriosPorConcepto({
    required int smaId,
    required int vehId,
  });
  Future<List<ConceptoMantenimientoModel>> getConceptosMantenimiento(int tipId);
  Future<int> registrarMantenimiento({
    required int perIid,
    required int vehIid,
    required int proIid,
    required int bitKilometraje,
    required DateTime bitFechaRegistro,
    required List<HistoricoItem> historicos,
    required GastoRegistro gasto,
  });
}

// ─── Implementación ───────────────────────────────────────────────────────────
class RegistroMantenimientoDataSourceImpl extends BaseRemoteDataSource
    implements RegistroMantenimientoDataSource {
  final _photoService = MultipartPhotoUploadService();

  @override
  Future<DatosInicialesModel> getDatosIniciales() async {
    final res = await protectedGet('/api/general/datos-iniciales');
    _check(res, 'datos iniciales');
    return DatosInicialesModel.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    );
  }

  @override
  Future<List<AccesorioVehiculoModel>> getAccesoriosPorVehiculo(
    int vehiculoId,
  ) async {
    final res = await protectedGet(
      '/api/general/accesorios-por-vehiculo/$vehiculoId',
    );
    _check(res, 'accesorios por vehículo');
    final data =
        (jsonDecode(res.body) as Map<String, dynamic>)['data'] as List? ?? [];
    return data.map((e) => AccesorioVehiculoModel.fromJson(e)).toList();
  }

  @override
  Future<List<AccesorioConceptoModel>> getAccesoriosPorConcepto({
    required int smaId,
    required int vehId,
  }) async {
    final res = await protectedGet(
      '/api/general/accesorios-por-concepto',
      queryParameters: {
        'sma_iid': smaId.toString(),
        'veh_iid': vehId.toString(),
      },
    );
    _check(res, 'accesorios por concepto');
    final data =
        (jsonDecode(res.body) as Map<String, dynamic>)['data'] as List? ?? [];
    return data.map((e) => AccesorioConceptoModel.fromJson(e)).toList();
  }

  @override
  Future<List<ConceptoMantenimientoModel>> getConceptosMantenimiento(
    int tipId,
  ) async {
    final res = await protectedGet(
      '/api/general/conceptos-mantenimiento',
      queryParameters: {'tip_iid': tipId.toString()},
    );
    _check(res, 'conceptos de mantenimiento');
    final data =
        (jsonDecode(res.body) as Map<String, dynamic>)['data'] as List? ?? [];
    return data.map((e) => ConceptoMantenimientoModel.fromJson(e)).toList();
  }

  @override
  Future<int> registrarMantenimiento({
    required int perIid,
    required int vehIid,
    required int proIid,
    required int bitKilometraje,
    required DateTime bitFechaRegistro,
    required List<HistoricoItem> historicos,
    required GastoRegistro gasto,
  }) async {
    // ── Bitácora ─────────────────────────────────────────────────────────────
    final bitacoraFields = {
      'Bitacora.per_iid': perIid.toString(),
      'Bitacora.veh_iid': vehIid.toString(),
      'Bitacora.pro_iid': proIid.toString(),
      'Bitacora.bit_ikilometraje': bitKilometraje.toString(),
      'Bitacora.bit_icantidad': historicos.length.toString(),
      'Bitacora.bit_dfech_registro': bitFechaRegistro.toIso8601String(),
    };

    // ── HistoricoMantenimientosJson ───────────────────────────────────────────
    final historicoJson = jsonEncode(
      historicos.map((h) => h.toJson()).toList(),
    );

    // ── Gasto — nota: el prefijo "Gasto." lo agrega buildAndSendRegistroRequest
    final gastoFields = {
      'gas_vtipo': gasto.gasVtipo,
      'gas_vnumero_documento': gasto.gasVnumeroDocumento,
      'gas_vtipo_gasto': gasto.gasVtipoGasto,
      'gas_vmoneda': gasto.gasVmoneda,
      'gas_bmonto': gasto.gasBmonto.toString(),
      'gas_dfecha_gasto': gasto.gasDfechaGasto,
      'gas_vdescripcion': gasto.gasVdescripcion,
    };

    // ── Fotos (índice = índice del histórico) ─────────────────────────────────
    final fotosHistorico = historicos.map((h) => h.foto).toList();

    final response = await _photoService.buildAndSendRegistroRequest(
      bitacoraFields: bitacoraFields,
      historicoJson: historicoJson,
      gastoFields: gastoFields,
      fotosHistorico: fotosHistorico,
      fotoGasto: gasto.foto,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final id = json['data'] as int? ?? json['bitacoraId'] as int? ?? 0;

      // ✅ Auditoría de negocio
      AppLogger.audit(
        'Mantenimiento registrado con éxito. ID: $id',
        action: 'CREATE',
        entity: 'Mantenimiento',
        source: 'RegistroMantenimientoDataSource',
      );

      return id;
    }

    try {
      final err = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(
        err['message'] ?? err['error'] ?? 'Error al registrar mantenimiento',
      );
    } catch (_) {
      throw Exception(
        'Error al registrar mantenimiento: ${response.statusCode}',
      );
    }
  }

  void _check(http.Response res, String label) {
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Error al cargar $label: ${res.statusCode}');
    }
  }
}
