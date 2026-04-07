// lib/features/mantenimiento/data/datasources/registro_mantenimiento_datasource.dart

import 'dart:convert';
import 'package:app_jht_front/features/mantenimiento/data/models/accesorio_vehiculo_model.dart';
import 'package:http/http.dart' as http;
import 'package:app_jht_front/core/network/base_remote_data_source.dart';
import 'package:app_jht_front/features/config/environment_config.dart';
import 'package:app_jht_front/core/utils/token_service.dart';
import '../models/datos_iniciales_model.dart';
import '../models/item_mantenimiento_form_model.dart';

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
    required int bitCantidad,
    required DateTime bitFechaRegistro,
    required List<ItemMantenimientoForm> items,
    // Gasto
    required String gasTipo,
    required String gasMoneda,
    required int gasNumeroDocumento,
    required double gasMonto,
    required DateTime gasFechaGasto,
    required String gasDescripcion,
    required String gasTipoGasto,
    String? gastoFotoPath,
  });
}

class RegistroMantenimientoDataSourceImpl extends BaseRemoteDataSource
    implements RegistroMantenimientoDataSource {
  // ── API12: datos-iniciales ────────────────────────────────────────────────
  @override
  Future<DatosInicialesModel> getDatosIniciales() async {
    final response = await protectedGet('/api/general/datos-iniciales');
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return DatosInicialesModel.fromJson(json);
    }
    throw Exception('Error al cargar datos iniciales: ${response.statusCode}');
  }

  // ── API13: accesorios-por-vehiculo/{id} ───────────────────────────────────
  @override
  Future<List<AccesorioVehiculoModel>> getAccesoriosPorVehiculo(
      int vehiculoId) async {
    final response = await protectedGet(
        '/api/general/accesorios-por-vehiculo/$vehiculoId');
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as List? ?? [];
      return data.map((e) => AccesorioVehiculoModel.fromJson(e)).toList();
    }
    throw Exception(
        'Error al cargar accesorios del vehículo: ${response.statusCode}');
  }

  // ── API14: accesorios-por-concepto ────────────────────────────────────────
  @override
  Future<List<AccesorioConceptoModel>> getAccesoriosPorConcepto({
    required int smaId,
    required int vehId,
  }) async {
    final response = await protectedGet(
      '/api/general/accesorios-por-concepto',
      queryParameters: {
        'sma_iid': smaId.toString(),
        'veh_iid': vehId.toString(),
      },
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as List? ?? [];
      return data.map((e) => AccesorioConceptoModel.fromJson(e)).toList();
    }
    throw Exception(
        'Error al cargar accesorios por concepto: ${response.statusCode}');
  }

  // ── API15: conceptos-mantenimiento ────────────────────────────────────────
  @override
  Future<List<ConceptoMantenimientoModel>> getConceptosMantenimiento(
      int tipId) async {
    final response = await protectedGet(
      '/api/general/conceptos-mantenimiento',
      queryParameters: {'tip_iid': tipId.toString()},
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as List? ?? [];
      return data.map((e) => ConceptoMantenimientoModel.fromJson(e)).toList();
    }
    throw Exception(
        'Error al cargar conceptos de mantenimiento: ${response.statusCode}');
  }

  // ── API16: registrar-mantenimiento (multipart/form-data) ──────────────────
  @override
  Future<int> registrarMantenimiento({
    required int perIid,
    required int vehIid,
    required int proIid,
    required int bitKilometraje,
    required int bitCantidad,
    required DateTime bitFechaRegistro,
    required List<ItemMantenimientoForm> items,
    required String gasTipo,
    required String gasMoneda,
    required int gasNumeroDocumento,
    required double gasMonto,
    required DateTime gasFechaGasto,
    required String gasDescripcion,
    required String gasTipoGasto,
    String? gastoFotoPath,
  }) async {
    final String? token = await TokenService.getToken();
    if (token == null) throw Exception('Sin token de autenticación');

    final url =
        '${EnvironmentConfig.baseUrl}/api/general/registrar-mantenimiento';

    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['accept'] = '*/*';

    // ── Bitácora ─────────────────────────────────────────────────────────
    request.fields['Bitacora.per_iid'] = perIid.toString();
    request.fields['Bitacora.veh_iid'] = vehIid.toString();
    request.fields['Bitacora.pro_iid'] = proIid.toString();
    request.fields['Bitacora.bit_ikilometraje'] = bitKilometraje.toString();
    request.fields['Bitacora.bit_icantidad'] = bitCantidad.toString();
    request.fields['Bitacora.bit_dfech_registro'] =
        bitFechaRegistro.toIso8601String();

    // ── Histórico JSON ────────────────────────────────────────────────────
    final historicoList =
        items.map((item) => item.toHistoricoJson()).toList();
    request.fields['HistoricoMantenimientosJson'] = jsonEncode(historicoList);

    // ── Gasto ─────────────────────────────────────────────────────────────
    request.fields['Gasto.gas_vtipo'] = gasTipo;
    request.fields['Gasto.gas_vmoneda'] = gasMoneda;
    request.fields['Gasto.gas_inumero_documento'] =
        gasNumeroDocumento.toString();
    request.fields['Gasto.gas_bmonto'] = gasMonto.toString();
    request.fields['Gasto.gas_dfecha_gasto'] =
        gasFechaGasto.toIso8601String().split('T').first;
    request.fields['Gasto.gas_vdescripcion'] = gasDescripcion;
    request.fields['Gasto.gas_vtipo_gasto'] = gasTipoGasto;

    // ── Fotos de accesorios históricos ────────────────────────────────────
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.fotoPath != null && item.fotoPath!.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
          'FotosHistorico',
          item.fotoPath!,
        ));
      }
    }

    // ── Foto del gasto (factura/boleta) ───────────────────────────────────
    if (gastoFotoPath != null && gastoFotoPath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'Gasto.gas_vlink_foto',
        gastoFotoPath,
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['data'] as int? ?? 0;
    }

    // Intentar extraer mensaje de error
    try {
      final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
      final msg = errorJson['message'] ?? 'Error al registrar mantenimiento';
      throw Exception(msg);
    } catch (_) {
      throw Exception(
          'Error al registrar mantenimiento: ${response.statusCode}');
    }
  }
}