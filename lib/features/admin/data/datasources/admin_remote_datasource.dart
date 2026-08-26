// lib/features/admin/data/datasources/admin_remote_datasource.dart

import 'dart:convert';
import 'package:app_jht_front/core/network/base_remote_data_source.dart';
import 'package:app_jht_front/core/utils/app_logger.dart';
import 'package:app_jht_front/features/admin/data/models/historial_mantenimiento_model.dart';
import 'package:app_jht_front/features/mantenimiento/data/models/accesorio_models.dart';

abstract class AdminRemoteDataSource {
  Future<HistorialDashboardResponse> getHistorialMantenimiento({
    int? anio,
    int? vehIid,
    int? tipIid,
  });
  
  Future<List<ConceptoMantenimientoModel>> getTiposAccesorio();
}

class AdminRemoteDataSourceImpl extends BaseRemoteDataSource implements AdminRemoteDataSource {
  // Cuando el endpoint esté 100% en producción, cambia useMock = false
  final bool useMock = false;

  @override
  Future<HistorialDashboardResponse> getHistorialMantenimiento({
    int? anio,
    int? vehIid,
    int? tipIid,
  }) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 1500)); // Simular latencia de red
      return _getMockHistorial(anio, vehIid, tipIid);
    }

    try {
      final queryParams = <String, String>{};
      if (anio != null) queryParams['anio'] = anio.toString();
      if (vehIid != null) queryParams['veh_iid'] = vehIid.toString();
      if (tipIid != null) queryParams['tip_iid'] = tipIid.toString();

      final res = await protectedGet(
        '/api/general/consulta-historial',
        queryParameters: queryParams,
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          return HistorialDashboardResponse.fromJson(decoded['data']);
        }
        throw Exception('El formato de la respuesta no es válido (falta "data").');
      } else {
        throw Exception('Error al obtener historial (HTTP ${res.statusCode}).');
      }
    } catch (e) {
      AppLogger.error('AdminRemoteDataSource - Error al obtener historial', error: e);
      // QA MODE: Desactivamos el fallback para ver el error real
      rethrow;
    }
  }

  @override
  Future<List<ConceptoMantenimientoModel>> getTiposAccesorio() async {
    try {
      // Consumimos el endpoint recomendado por el backend para llenar los tipos de accesorio
      final res = await protectedGet('/api/general/conceptos-mantenimiento');
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final data = decoded['data'] as List? ?? [];
        return data.map((e) => ConceptoMantenimientoModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      AppLogger.error('AdminRemoteDataSource - Error al obtener tipos de accesorio', error: e);
      return [];
    }
  }

  HistorialDashboardResponse _getMockHistorial(int? anio, int? vehIid, int? tipIid) {
    // Si hay un vehículo seleccionado pero no hay movimientos simulamos estado vacío
    if (vehIid == 999) {
      return HistorialDashboardResponse(
        historialGeneral: [],
        consultaHistorialPorFecha: List.generate(
          12,
          (i) => HistorialPorFechaItem(
            mes: _getMesNombre(i + 1),
            anio: anio ?? DateTime.now().year,
            cantidad: 0,
            costoTotal: 0.0,
          ),
        ),
        consultaHistorialPorAccesorio: [],
        consultaHistorialPorClasificacion: [],
        topVehiculosCostosos: [],
        topProveedores: [],
      );
    }

    // Datos simulados generales (Scenarios 1 & 2)
    return HistorialDashboardResponse(
      historialGeneral: [
        HistorialGeneralItem(
          bitDfechRegistro: "2026-08-20T14:30:00",
          vehVplaca: "ABC-123",
          vehVmarca: "Volvo",
          bitIkilometraje: 120500,
          bitIcantidad: 1,
          dicVnombre: "Filtro de Aceite",
          dicVdescripcion: "Filtro sintético para motor",
          dicVtipo: "Repuesto",
          hisVdescripcion: "Cambio rutinario cada 10k",
          hisIproximoKilometraje: 130500,
          hisDproximaFech: "2026-11-20",
          segVnombre: "Motor",
          perVprimerNom: "Juan",
          perVsegundoNom: "Carlos",
          perVapellidoPa: "Pérez",
          perVapellidoMa: "Gómez",
          hisVestado: "Completo",
          hisVlinkFoto: "https://s3.amazonaws.com/bucket/fotos/filtro1.jpg",
          tipVnombre: "Filtros",
          proVrazonSocial: "Repuestos S.A.",
          gasVtipo: "Factura",
          gasVnumeroDocumento: "F001-12345",
          gasBmonto: 150.50,
          gastoVlinkFoto: "https://s3.amazonaws.com/bucket/facturas/fac1.jpg",
        ),
        if (vehIid == null || vehIid == 5) // El segundo registro pertenece al vehículo 5 ("XYZ-987")
          HistorialGeneralItem(
            bitDfechRegistro: "2026-06-15T09:00:00",
            vehVplaca: "XYZ-987",
            vehVmarca: "Scania",
            bitIkilometraje: 450000,
            bitIcantidad: 2,
            dicVnombre: "Llanta Delantera 22.5",
            dicVdescripcion: "Llantas direccionales",
            dicVtipo: "Repuesto",
            hisVdescripcion: "Cambio por desgaste natural",
            hisIproximoKilometraje: 550000,
            hisDproximaFech: "2027-06-15",
            segVnombre: "Chasis y Llantas",
            perVprimerNom: "Luis",
            perVsegundoNom: "",
            perVapellidoPa: "Mendoza",
            perVapellidoMa: "Vargas",
            hisVestado: "Pendiente",
            hisVlinkFoto: "",
            tipVnombre: "Neumáticos",
            proVrazonSocial: "Llantas y Más SAC",
            gasVtipo: "Boleta",
            gasVnumeroDocumento: "B002-9876",
            gasBmonto: 1200.00,
            gastoVlinkFoto: "",
          ),
      ],
      consultaHistorialPorFecha: [
        HistorialPorFechaItem(mes: "Enero", anio: 2026, cantidad: 0, costoTotal: 0.0),
        HistorialPorFechaItem(mes: "Febrero", anio: 2026, cantidad: 0, costoTotal: 0.0),
        HistorialPorFechaItem(mes: "Marzo", anio: 2026, cantidad: 0, costoTotal: 0.0),
        HistorialPorFechaItem(mes: "Abril", anio: 2026, cantidad: 0, costoTotal: 0.0),
        HistorialPorFechaItem(mes: "Mayo", anio: 2026, cantidad: 0, costoTotal: 0.0),
        HistorialPorFechaItem(mes: "Junio", anio: 2026, cantidad: (vehIid == null || vehIid == 5) ? 1 : 0, costoTotal: (vehIid == null || vehIid == 5) ? 450.0 : 0.0),
        HistorialPorFechaItem(mes: "Julio", anio: 2026, cantidad: 0, costoTotal: 0.0),
        HistorialPorFechaItem(mes: "Agosto", anio: 2026, cantidad: (vehIid == null || vehIid != 5) ? 1 : 0, costoTotal: (vehIid == null || vehIid != 5) ? 65.5 : 0.0),
        HistorialPorFechaItem(mes: "Septiembre", anio: 2026, cantidad: 0, costoTotal: 0.0),
        HistorialPorFechaItem(mes: "Octubre", anio: 2026, cantidad: 0, costoTotal: 0.0),
        HistorialPorFechaItem(mes: "Noviembre", anio: 2026, cantidad: 0, costoTotal: 0.0),
        HistorialPorFechaItem(mes: "Diciembre", anio: 2026, cantidad: 0, costoTotal: 0.0),
      ],
      consultaHistorialPorAccesorio: [
        HistorialPorAccesorioItem(tipVnombre: "Baterías", cantidad: (vehIid == null || vehIid == 5) ? 1 : 0),
        HistorialPorAccesorioItem(tipVnombre: "Filtros", cantidad: (vehIid == null || vehIid != 5) ? 1 : 0),
      ],
      consultaHistorialPorClasificacion: [
        HistorialPorClasificacionItem(clasificacion: "Preventivo", cantidad: 1, costoTotal: 65.5),
        HistorialPorClasificacionItem(clasificacion: "Correctivo", cantidad: 1, costoTotal: 450.0),
      ],
      topVehiculosCostosos: [
        TopVehiculoCostosoItem(vehVplaca: "XYZ-987", costoTotal: 450.0),
      ],
      topProveedores: [
        TopProveedorItem(proVrazonSocial: "Energía Total SAC", costoTotal: 450.0),
      ],
    );
  }

  String _getMesNombre(int mes) {
    const meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return meses[mes - 1];
  }
}
