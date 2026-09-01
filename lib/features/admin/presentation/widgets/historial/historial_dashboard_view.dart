// lib/features/admin/presentation/widgets/historial/historial_dashboard_view.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:app_jht_front/features/admin/presentation/bloc/historial/historial_mantenimiento_bloc.dart';
import 'package:app_jht_front/features/admin/presentation/bloc/historial/historial_mantenimiento_state.dart';
import 'package:app_jht_front/features/admin/presentation/bloc/historial/historial_mantenimiento_event.dart';
import 'historial_filters_bar.dart';
import 'historial_bar_chart.dart';
import 'historial_pie_chart.dart';
import 'historial_accesorio_pie_chart.dart';
import 'historial_data_table.dart';
import 'historial_top_list.dart';

class HistorialDashboardView extends StatelessWidget {
  const HistorialDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Título + Toggle Data Mode
        BlocBuilder<HistorialMantenimientoBloc, HistorialMantenimientoState>(
          buildWhen: (prev, curr) {
            // Solo reconstruir cuando cambie el modo de datos
            bool prevMock = true;
            bool currMock = true;
            if (prev is HistorialLoaded) prevMock = prev.useMockData;
            if (prev is HistorialLoading) prevMock = prev.useMockData;
            if (prev is HistorialError) prevMock = prev.useMockData;
            if (curr is HistorialLoaded) currMock = curr.useMockData;
            if (curr is HistorialLoading) currMock = curr.useMockData;
            if (curr is HistorialError) currMock = curr.useMockData;
            return prevMock != currMock;
          },
          builder: (context, state) {
            bool useMockData = true;
            if (state is HistorialLoaded) useMockData = state.useMockData;
            if (state is HistorialLoading) useMockData = state.useMockData;
            if (state is HistorialError) useMockData = state.useMockData;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  // Título
                  Expanded(
                    child: Text(
                      'Análisis de Mantenimiento de Flota',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF303366),
                      ),
                    ),
                  ),
                  // Toggle Data Mode
                  _buildDataModeToggle(context, useMockData),
                ],
              ),
            );
          },
        ),

        // Barra de filtros
        const HistorialFiltersBar(),
        const SizedBox(height: 24),


        // Contenedor de gráficos
        BlocBuilder<HistorialMantenimientoBloc, HistorialMantenimientoState>(
          builder: (context, state) {
            if (state is HistorialInitial) {
              return const SizedBox.shrink();
            } else if (state is HistorialLoading) {
              return _buildSkeletonCharts(context);
            } else if (state is HistorialError) {
              return _buildErrorState(state.message);
            } else if (state is HistorialLoaded) {
              final data = state.data;
              if (data.historialGeneral.isEmpty && 
                  data.consultaHistorialPorAccesorio.isEmpty && 
                  data.consultaHistorialPorFecha.isEmpty) {
                return _buildEmptyState();
              }
              return _buildCharts(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildCharts(BuildContext context, HistorialLoaded state) {
    final isMobile = MediaQuery.sizeOf(context).width < 800;

    final barChartCard = _buildGlassCard(
      context: context,
      title: 'Mantenimientos por Mes',
      tooltipQueMuestra: 'Evolución de los mantenimientos registrados y el costo total durante el período seleccionado.',
      tooltipComoInterpretarlo: 'Las barras más altas representan meses con mayor actividad de mantenimiento y/o gasto.',
      child: HistorialBarChart(data: state.data.consultaHistorialPorFecha),
    );

    final pieChartCard = _buildGlassCard(
      context: context,
      title: 'Clasificación Gerencial',
      tooltipQueMuestra: 'Distribución de mantenimientos preventivos, correctivos y predictivos.',
      tooltipComoInterpretarlo: 'Un mayor peso del mantenimiento preventivo indica una estrategia proactiva.',
      child: HistorialPieChart(data: state.data.consultaHistorialPorClasificacion),
    );

    final accesorioPieChartCard = _buildGlassCard(
      context: context,
      title: 'Mantenimientos por Accesorio',
      tooltipQueMuestra: 'Distribución de la cantidad de mantenimientos según el tipo de accesorio.',
      tooltipComoInterpretarlo: 'Permite identificar qué accesorios requieren mantenimiento con mayor frecuencia.',
      child: HistorialAccesorioPieChart(data: state.data.consultaHistorialPorAccesorio),
    );

    final topVehiculosCard = _buildGlassCard(
      context: context,
      title: 'Top 5 Vehículos Más Costosos',
      tooltipQueMuestra: 'Las unidades que concentran el mayor costo acumulado de mantenimiento.',
      tooltipComoInterpretarlo: 'Vehículos recurrentes en esta lista podrían requerir renovación, revisión profunda o un cambio en su esquema de operación.',
      child: HistorialTopList(
        data: state.data.topVehiculosCostosos
            .map((e) => TopItemData(title: e.vehVplaca, costoTotal: e.costoTotal))
            .toList(),
      ),
      expandChild: false,
    );

    final topProveedoresCard = _buildGlassCard(
      context: context,
      title: 'Top 5 Proveedores',
      tooltipQueMuestra: 'Los proveedores que concentran la mayor facturación por mantenimientos.',
      tooltipComoInterpretarlo: 'Proveedores con alta facturación son candidatos ideales para negociar contratos corporativos o descuentos por volumen.',
      child: HistorialTopList(
        data: state.data.topProveedores
            .map((e) => TopItemData(title: e.proVrazonSocial, costoTotal: e.costoTotal))
            .toList(),
      ),
      expandChild: false,
    );

    if (isMobile) {
      return Column(
        children: [
          SizedBox(height: 300, child: barChartCard),
          const SizedBox(height: 16),
          SizedBox(height: 320, child: pieChartCard),
          const SizedBox(height: 16),
          SizedBox(height: 320, child: accesorioPieChartCard),
          const SizedBox(height: 16),
          topVehiculosCard,
          const SizedBox(height: 16),
          topProveedoresCard,
          const SizedBox(height: 24),
          _buildGlassCard(
            context: context,
            title: 'Listado Detallado',
            child: HistorialDataTable(data: state.data.historialGeneral),
            expandChild: false,
          ),
        ],
      );
    }

    return Column(
      children: [
        // Primera fila: Bar Chart
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 12, child: SizedBox(height: 340, child: barChartCard)),
          ],
        ),
        const SizedBox(height: 16),
        // Segunda fila: Pie Charts
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: SizedBox(height: 350, child: pieChartCard)),
            const SizedBox(width: 16),
            Expanded(flex: 5, child: SizedBox(height: 350, child: accesorioPieChartCard)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: topVehiculosCard),
            const SizedBox(width: 16),
            Expanded(child: topProveedoresCard),
          ],
        ),
        const SizedBox(height: 24),
        _buildGlassCard(
          context: context,
          title: 'Listado Detallado de Mantenimientos',
          child: HistorialDataTable(data: state.data.historialGeneral),
          expandChild: false,
        ),
      ],
    );
  }

  Widget _buildGlassCard({
    required BuildContext context,
    required String title,
    required Widget child,
    bool expandChild = true,
    String? tooltipQueMuestra,
    String? tooltipComoInterpretarlo,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4834D4).withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E), // textPrimary
                      ),
                    ),
                  ),
                  if (tooltipQueMuestra != null && tooltipComoInterpretarlo != null) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _showInfoDialog(context, title, tooltipQueMuestra, tooltipComoInterpretarlo),
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFF6B7280)),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              if (expandChild) Expanded(child: child) else child,
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String queMuestra, String comoInterpretarlo) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Color(0xFF4834D4)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Qué muestra?',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(queMuestra, style: const TextStyle(color: Color(0xFF64748B), height: 1.4)),
            const SizedBox(height: 16),
            const Text(
              '¿Cómo interpretarlo?',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(comoInterpretarlo, style: const TextStyle(color: Color(0xFF64748B), height: 1.4)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF4834D4)),
            child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildSkeletonCharts(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 800;
    final skeletonCard = Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );

    if (isMobile) {
      return Column(
        children: [
          skeletonCard,
          const SizedBox(height: 24),
          skeletonCard,
        ],
      );
    }
    return Row(
      children: [
        Expanded(flex: 5, child: skeletonCard),
        const SizedBox(width: 24),
        Expanded(flex: 3, child: skeletonCard),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2), // errorBg
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 48),
          const SizedBox(height: 16),
          Text(
            'Error al cargar el historial',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFDC2626)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: const [
          Icon(Icons.inbox_rounded, color: Color(0xFF9CA3AF), size: 64),
          SizedBox(height: 16),
          Text(
            'No existen mantenimientos registrados para los filtros seleccionados.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildDataModeToggle(BuildContext context, bool useMockData) {
    final bool isReal = !useMockData;
    
    return Tooltip(
      message: isReal
          ? 'Mostrando datos reales de la API'
          : 'Mostrando datos de demostración (Mock)',
      child: Container(
        padding: const EdgeInsets.only(left: 8, right: 2, top: 2, bottom: 2),
        decoration: BoxDecoration(
          color: isReal 
              ? const Color(0xFF16A34A).withValues(alpha: 0.1)
              : const Color(0xFFF59E0B).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isReal 
                ? const Color(0xFF16A34A).withValues(alpha: 0.3)
                : const Color(0xFFF59E0B).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isReal ? Icons.cloud_done_rounded : Icons.science_rounded,
              size: 14,
              color: isReal ? const Color(0xFF16A34A) : const Color(0xFFF59E0B),
            ),
            const SizedBox(width: 4),
            Text(
              isReal ? 'DATA REAL' : 'DEMO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
                color: isReal ? const Color(0xFF16A34A) : const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 2),
            Transform.scale(
              scale: 0.65,
              child: Switch(
                value: isReal,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF16A34A),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFF59E0B),
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (val) {
                  context.read<HistorialMantenimientoBloc>().add(
                    ToggleDataModeEvent(!val),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
