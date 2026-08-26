import 'package:app_jht_front/features/admin/data/models/historial_mantenimiento_model.dart';
import 'package:app_jht_front/features/accessory/data/models/vehiculo_model.dart';
import 'package:app_jht_front/features/mantenimiento/data/models/accesorio_models.dart';
import 'package:app_jht_front/features/accessory/data/models/segmento_model.dart';
import 'package:app_jht_front/features/accessory/data/models/tipo_accesorio_model.dart';
import 'dart:math';

List<HistorialGeneralItem>? _cachedRawRecords;

// Generator function for raw records (deterministic with seed)
List<HistorialGeneralItem> _generateRawRecords(
    List<VehiculoModel> vehiculos, List<SegmentoModel> segmentos, List<TipoAccesorioModel> accesorios) {
  final random = Random(42);
  final List<HistorialGeneralItem> records = [];

  final List<String> vPlacas = vehiculos.isNotEmpty
      ? vehiculos.map((v) => v.placa).toList()
      : ['ABC-123', 'XYZ-987', 'DEF-456', 'GHI-789', 'JKL-012'];
      
  final List<String> aNombres = accesorios.isNotEmpty
      ? accesorios.map((a) => a.nombre).toList()
      : ['Disco de embrague', 'Filtro de aire', 'Pastillas de freno', 'Aceite sintético', 'Batería 12V', 'Faro delantero'];

  final List<String> sNombres = segmentos.isNotEmpty
      ? segmentos.map((s) => s.nombre).toList()
      : ['Transmisión', 'Motor', 'Frenos', 'Fluidos', 'Eléctrico', 'Carrocería'];

  final List<String> providers = ['Llantas del Norte', 'Repuestos S.A.', 'Energía Total SAC', 'Frenos y Partes', 'Lubricantes Express'];
  final List<String> clasificaciones = ['Preventivo', 'Correctivo', 'Predictivo'];
  
  final List<int> years = [2024, 2025, 2026];

  for (int i = 0; i < 200; i++) {
    int vIdx = random.nextInt(vPlacas.length);
    int aIdx = random.nextInt(aNombres.length);
    int pIdx = random.nextInt(providers.length);
    int cIdx = random.nextInt(clasificaciones.length);
    int year = years[random.nextInt(years.length)];
    int month = random.nextInt(12) + 1;
    int day = random.nextInt(28) + 1;
    
    // Some bias to make data look realistic
    double baseCost = random.nextDouble() * 500 + 100;
    if (clasificaciones[cIdx] == 'Correctivo') baseCost *= 2.5; // Corrective is more expensive
    if (aNombres[aIdx].toLowerCase().contains('neumático') || aNombres[aIdx].toLowerCase().contains('llanta')) baseCost += 800; // Tires are expensive
    if (vPlacas[vIdx] == 'XYZ-987') baseCost *= 1.3; // One vehicle is inherently more expensive
    
    String clasificacion = clasificaciones[cIdx];
    String vehicleName = vPlacas[vIdx];
    String accName = aNombres[aIdx];
    String segName = sNombres[random.nextInt(sNombres.length)];
    
    records.add(
      HistorialGeneralItem(
        bitDfechRegistro: '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}T10:00:00',
        vehVplaca: vehicleName,
        vehVmarca: 'Marca $vIdx',
        bitIkilometraje: 100000 + (i * 1000),
        bitIcantidad: random.nextInt(3) + 1,
        dicVnombre: accName,
        dicVdescripcion: 'Detalle de $accName',
        dicVtipo: 'Repuesto',
        hisVdescripcion: 'Mantenimiento $clasificacion', // Encodes classification
        hisIproximoKilometraje: 0,
        hisDproximaFech: '',
        segVnombre: segName,
        perVprimerNom: 'Mecánico',
        perVsegundoNom: '',
        perVapellidoPa: 'Pérez',
        perVapellidoMa: '',
        hisVestado: 'Completado',
        hisVlinkFoto: null,
        tipVnombre: accName,
        proVrazonSocial: providers[pIdx],
        gasVtipo: 'Factura',
        gasVnumeroDocumento: 'F001-${i.toString().padLeft(4, '0')}',
        gasBmonto: baseCost,
      )
    );
  }
  return records;
}

/// Función que provee datos simulados realistas para el dashboard
HistorialDashboardResponse getMockHistorialDashboardResponse({
  int? anio,
  int? vehIid,
  int? segIid,
  int? tipIid, // accIid
  List<VehiculoModel> vehiculos = const [],
  List<SegmentoModel> segmentos = const [],
  List<TipoAccesorioModel> accesorios = const [],
}) {
  if (_cachedRawRecords == null || vehiculos.isNotEmpty) {
    _cachedRawRecords = _generateRawRecords(vehiculos, segmentos, accesorios);
  }

  // 1. FILTERING
  List<HistorialGeneralItem> filteredRecords = _cachedRawRecords!.where((record) {
    bool matchYear = true;
    bool matchVeh = true;
    bool matchSeg = true;
    bool matchAcc = true;

    if (anio != null) {
      matchYear = record.bitDfechRegistro.startsWith(anio.toString());
    }
    
    if (vehIid != null) {
      final veh = vehiculos.where((v) => v.id == vehIid).firstOrNull;
      if (veh != null) {
        matchVeh = record.vehVplaca == veh.placa;
      } else {
        matchVeh = false; // ID provided but not found in list
      }
    }
    
    if (segIid != null) {
      final seg = segmentos.where((s) => s.id == segIid).firstOrNull;
      if (seg != null) {
        matchSeg = record.segVnombre == seg.nombre;
      } else {
        matchSeg = false; 
      }
    }

    if (tipIid != null) {
      final acc = accesorios.where((a) => a.id == tipIid).firstOrNull;
      if (acc != null) {
        matchAcc = record.dicVnombre == acc.nombre;
      } else {
        matchAcc = false; // ID provided but not found in list
      }
    }

    return matchYear && matchVeh && matchSeg && matchAcc;
  }).toList();

  // 2. AGGREGATION
  
  // A. Historial por Fecha (Meses)
  final Map<int, double> costsByMonth = {};
  final Map<int, int> countsByMonth = {};
  for (var record in filteredRecords) {
    int month = int.parse(record.bitDfechRegistro.substring(5, 7));
    costsByMonth[month] = (costsByMonth[month] ?? 0.0) + record.gasBmonto;
    countsByMonth[month] = (countsByMonth[month] ?? 0) + 1;
  }
  
  final List<String> monthNames = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
  final List<HistorialPorFechaItem> porFecha = List.generate(12, (index) {
    int month = index + 1;
    return HistorialPorFechaItem(
      mes: monthNames[index],
      anio: anio ?? DateTime.now().year,
      cantidad: countsByMonth[month] ?? 0,
      costoTotal: costsByMonth[month] ?? 0.0,
    );
  });

  // B. Clasificación Gerencial (Preventivo, Correctivo, Predictivo)
  final Map<String, double> costsByClasif = {'Preventivo': 0.0, 'Correctivo': 0.0, 'Predictivo': 0.0};
  final Map<String, int> countsByClasif = {'Preventivo': 0, 'Correctivo': 0, 'Predictivo': 0};
  for (var record in filteredRecords) {
    // We encoded clasificacion in hisVdescripcion
    String clasif = 'Preventivo';
    if (record.hisVdescripcion.contains('Correctivo')) clasif = 'Correctivo';
    if (record.hisVdescripcion.contains('Predictivo')) clasif = 'Predictivo';
    
    costsByClasif[clasif] = costsByClasif[clasif]! + record.gasBmonto;
    countsByClasif[clasif] = countsByClasif[clasif]! + 1;
  }
  
  final List<HistorialPorClasificacionItem> porClasificacion = costsByClasif.entries
      .where((e) => countsByClasif[e.key]! > 0) // Solo mostrar si hay cantidad
      .map((e) => HistorialPorClasificacionItem(
            clasificacion: e.key,
            cantidad: countsByClasif[e.key]!,
            costoTotal: e.value,
          ))
      .toList();

  // C. Top Vehículos
  final Map<String, double> costsByVeh = {};
  for (var record in filteredRecords) {
    costsByVeh[record.vehVplaca] = (costsByVeh[record.vehVplaca] ?? 0.0) + record.gasBmonto;
  }
  
  final List<TopVehiculoCostosoItem> topVehiculos = costsByVeh.entries
      .map((e) => TopVehiculoCostosoItem(vehVplaca: e.key, costoTotal: e.value))
      .toList();
  topVehiculos.sort((a, b) => b.costoTotal.compareTo(a.costoTotal));
  if (topVehiculos.length > 5) topVehiculos.removeRange(5, topVehiculos.length);

  // D. Top Proveedores
  final Map<String, double> costsByProv = {};
  for (var record in filteredRecords) {
    costsByProv[record.proVrazonSocial] = (costsByProv[record.proVrazonSocial] ?? 0.0) + record.gasBmonto;
  }
  
  final List<TopProveedorItem> topProveedores = costsByProv.entries
      .map((e) => TopProveedorItem(proVrazonSocial: e.key, costoTotal: e.value))
      .toList();
  topProveedores.sort((a, b) => b.costoTotal.compareTo(a.costoTotal));
  if (topProveedores.length > 5) topProveedores.removeRange(5, topProveedores.length);

  // 3. RETURN RESPONSE
  return HistorialDashboardResponse(
    historialGeneral: filteredRecords,
    consultaHistorialPorFecha: porFecha,
    consultaHistorialPorAccesorio: [], // Deprecated in UI but required by model
    consultaHistorialPorClasificacion: porClasificacion,
    topVehiculosCostosos: topVehiculos,
    topProveedores: topProveedores,
  );
}
