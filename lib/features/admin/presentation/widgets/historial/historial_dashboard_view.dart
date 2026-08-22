// lib/features/admin/presentation/widgets/historial/historial_dashboard_view.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:app_jht_front/features/admin/presentation/bloc/historial/historial_mantenimiento_bloc.dart';
import 'package:app_jht_front/features/admin/presentation/bloc/historial/historial_mantenimiento_state.dart';
import 'historial_filters_bar.dart';
import 'historial_bar_chart.dart';
import 'historial_pie_chart.dart';
import 'historial_data_table.dart';

class HistorialDashboardView extends StatelessWidget {
  const HistorialDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Título de la sección
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            'Analítica de Mantenimientos (En Desarrollo - Vista Previa)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF303366), // MaintenanceColors.primary
            ),
          ),
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
      title: 'Mantenimientos por Mes',
      child: HistorialBarChart(data: state.data.consultaHistorialPorFecha),
    );

    final pieChartCard = _buildGlassCard(
      title: 'Distribución por Accesorio',
      child: HistorialPieChart(data: state.data.consultaHistorialPorAccesorio),
    );

    if (isMobile) {
      return Column(
        children: [
          SizedBox(height: 320, child: barChartCard),
          const SizedBox(height: 24),
          SizedBox(height: 350, child: pieChartCard),
          const SizedBox(height: 32),
          _buildGlassCard(
            title: 'Listado Detallado',
            child: HistorialDataTable(data: state.data.historialGeneral),
            expandChild: false,
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: SizedBox(height: 350, child: barChartCard)),
            const SizedBox(width: 24),
            Expanded(flex: 3, child: SizedBox(height: 350, child: pieChartCard)),
          ],
        ),
        const SizedBox(height: 32),
        _buildGlassCard(
          title: 'Listado Detallado de Mantenimientos',
          child: HistorialDataTable(data: state.data.historialGeneral),
          expandChild: false,
        ),
      ],
    );
  }

  Widget _buildGlassCard({
    required String title,
    required Widget child,
    bool expandChild = true,
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E), // textPrimary
                ),
              ),
              const SizedBox(height: 16),
              if (expandChild) Expanded(child: child) else child,
            ],
          ),
        ),
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
}
