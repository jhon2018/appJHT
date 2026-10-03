import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_jht_front/features/home/data/datasources/dashboard_service.dart';
import 'package:app_jht_front/core/utils/csv_export_util.dart';
import 'package:app_jht_front/core/widgets/app_notification.dart';

class DownloadReportModal extends StatefulWidget {
  const DownloadReportModal({Key? key}) : super(key: key);

  @override
  State<DownloadReportModal> createState() => _DownloadReportModalState();
}

class _DownloadReportModalState extends State<DownloadReportModal> {
  final DashboardService _service = DashboardService();
  
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  int? _vehiculoIdSeleccionado;
  
  List<dynamic> _vehiculos = [];
  bool _isLoadingVehiculos = true;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    try {
      final list = await _service.getVehiculosParaFiltro();
      if (mounted) {
        setState(() {
          _vehiculos = list;
          _isLoadingVehiculos = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingVehiculos = false);
        AppNotification.error(context, 'Error al cargar vehículos');
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart 
        ? (_fechaInicio ?? DateTime.now())
        : (_fechaFin ?? DateTime.now());
        
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF303366), // Color principal
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _fechaInicio = picked;
          // Validar que inicio no sea mayor que fin
          if (_fechaFin != null && _fechaInicio!.isAfter(_fechaFin!)) {
            _fechaFin = null;
          }
        } else {
          // Validar que fin no sea menor que inicio
          if (_fechaInicio != null && picked.isBefore(_fechaInicio!)) {
            AppNotification.error(context, 'La fecha fin debe ser mayor o igual a la de inicio');
          } else {
            _fechaFin = picked;
          }
        }
      });
    }
  }

  Future<void> _generarReporte() async {
    if (_fechaInicio == null || _fechaFin == null) {
      AppNotification.error(context, 'Debe seleccionar un rango de fechas válido');
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final data = await _service.getReporteMantenimientos(
        fechaInicio: _fechaInicio!,
        fechaFin: _fechaFin!,
        vehiculoId: _vehiculoIdSeleccionado,
      );

      if (data.isEmpty) {
        if (mounted) {
          AppNotification.info(context, 'No hay datos para el rango seleccionado');
          setState(() => _isGenerating = false);
        }
        return;
      }

      // 1. Extraer todas las llaves (columnas) de forma dinámica preservando el orden de llegada
      final Set<String> allKeys = {};
      for (var item in data) {
        if (item is Map) {
          for (var key in item.keys) {
            allKeys.add(key.toString());
          }
        }
      }

      if (allKeys.isEmpty) {
        if (mounted) {
          AppNotification.info(context, 'El reporte no contiene columnas para exportar');
          setState(() => _isGenerating = false);
        }
        return;
      }

      // 2. Generar cabeceras dinámicas con nombres amigables
      final List<dynamic> headers = allKeys.map((key) => _formatearNombreColumna(key)).toList();

      // 3. Generar filas dinámicamente según las llaves encontradas
      final List<List<dynamic>> csvData = [headers];

      for (var item in data) {
        if (item is Map) {
          final row = allKeys.map((key) {
            final val = item[key];
            if (val == null) return '';
            if (val is String) {
              // Limpiar iconos/emojis de retiro o instalación para dejar solo texto limpio
              return val
                  .replaceAll('🔻', '')
                  .replaceAll('🔺', '')
                  .replaceAll('▼', '')
                  .replaceAll('▲', '')
                  .trim();
            }
            return val;
          }).toList();
          csvData.add(row);
        }
      }

      final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
      final fileName = 'Reporte_Mantenimientos_$dateStr';

      await CsvExportUtil.exportAndDownloadCSV(
        data: csvData,
        fileName: fileName,
      );

      if (mounted) {
        Navigator.pop(context); // Cerrar modal
        AppNotification.success(context, 'Reporte exportado correctamente');
      }
    } catch (e) {
      if (mounted) {
        AppNotification.error(context, 'Error al generar reporte: $e');
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobileScreen = screenWidth < 600;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobileScreen ? 16 : 40,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.white,
      elevation: 8,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.download_rounded, color: Color(0xFF303366), size: 28),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'Descargar Reporte CSV',
                            style: TextStyle(
                              fontSize: isMobileScreen ? 18 : 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Rango de fechas
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      label: 'Fecha Inicio',
                      selectedDate: _fechaInicio,
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDatePicker(
                      label: 'Fecha Fin',
                      selectedDate: _fechaFin,
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Dropdown Vehículo
              const Text(
                'Filtro por Vehículo (Opcional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
              if (_isLoadingVehiculos)
                const LinearProgressIndicator(color: Color(0xFF303366))
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    return DropdownMenu<int?>(
                      width: constraints.maxWidth,
                      enableSearch: true,
                      enableFilter: true,
                      hintText: 'Buscar y seleccionar vehículo...',
                      textStyle: const TextStyle(fontSize: 14),
                      inputDecorationTheme: InputDecorationTheme(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onSelected: (int? value) {
                        setState(() {
                          _vehiculoIdSeleccionado = value;
                        });
                      },
                      dropdownMenuEntries: [
                        const DropdownMenuEntry<int?>(
                          value: null,
                          label: 'Todos los vehículos',
                        ),
                        ..._vehiculos.map((v) {
                          final id = v['veh_iid'] ?? v['id'];
                          final placa = v['veh_vplaca'] ?? v['placa'] ?? 'Sin placa';
                          return DropdownMenuEntry<int?>(
                            value: id,
                            label: placa,
                          );
                        }).toList(),
                      ],
                    );
                  }
                ),
              const SizedBox(height: 32),

              // Botón de acción
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _generarReporte,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF303366),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isGenerating
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 24, height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Generando...',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        )
                      : const Text(
                          'Generar Reporte',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? DateFormat('dd/MM/yyyy').format(selectedDate)
                      : 'dd/mm/aaaa',
                  style: TextStyle(
                    fontSize: 14,
                    color: selectedDate != null ? const Color(0xFF334155) : Colors.grey,
                    fontWeight: selectedDate != null ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                Icon(Icons.calendar_today_rounded, size: 18, color: Colors.grey.shade500),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatearNombreColumna(String key) {
    final normalized = key.toLowerCase();

    // Diccionario de cabeceras amigables para campos conocidos
    const friendlyHeaders = {
      'bitacoraid': 'ID Bitácora',
      'bitacorafecharegistro': 'Fecha Registro Bitácora',
      'bitacorafecha': 'Fecha Bitácora',
      'bitacorahora': 'Hora Bitácora',
      'bitacorakilometraje': 'Kilometraje Bitácora',
      'bitacoracantidad': 'Cantidad Bitácora',
      'vehiculoid': 'ID Vehículo',
      'placa': 'Placa',
      'marca': 'Marca',
      'numerovin': 'Número VIN',
      'kilometrajevehiculo': 'Kilometraje Vehículo',
      'proveedorrazonsocial': 'Proveedor',
      'codigofabricante': 'Código Fabricante',
      'fechainstalacion': 'Fecha Instalación',
      'horainstalacion': 'Hora Instalación',
      'kilometrajeinstalacion': 'Kilometraje Instalación',
      'fecharetiro': 'Fecha Retiro',
      'kilometrajeretiro': 'Kilometraje Retiro',
      'tipoaccesorionombre': 'Accesorio Tipo',
      'segmentonombre': 'Accesorio Segmento',
      'diccionarionombre': 'Concepto Mantenimiento',
      'diccionariotipo': 'Tipo Clasificación',
      'frecuenciakilometros': 'Frecuencia Km',
      'frecuenciatiempo': 'Frecuencia Tiempo (días)',
      'historicodescripcion': 'Descripción Histórico',
      'historicoproximokilometraje': 'Próx. Kilometraje',
      'historicoproximafecha': 'Próxima Fecha',
      'historicoestado': 'Estado Histórico',
      'historicolinkfoto': 'Link Foto',
      'historicofecharegistro': 'Fecha Registro Histórico',
      'historicofecha': 'Fecha Histórico',
      'historicohora': 'Hora Histórico',
      'montofactura': 'Monto Factura (S/)',
      'gasbmonto': 'Monto Gasto (S/)',
    };

    if (friendlyHeaders.containsKey(normalized)) {
      return friendlyHeaders[normalized]!;
    }

    // Si es un campo nuevo (añadido en el backend a futuro):
    // Separa camelCase o snake_case y capitaliza cada palabra
    final formatted = key
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (Match m) => '${m[1]} ${m[2]}',
        )
        .replaceAll('_', ' ')
        .trim();

    return formatted
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
