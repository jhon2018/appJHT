// lib/features/admin/presentation/widgets/historial/historial_accesorio_pie_chart.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_jht_front/features/admin/data/models/historial_mantenimiento_model.dart';

class HistorialAccesorioPieChart extends StatefulWidget {
  final List<HistorialPorAccesorioItem> data;

  const HistorialAccesorioPieChart({super.key, required this.data});

  @override
  State<HistorialAccesorioPieChart> createState() => _HistorialAccesorioPieChartState();
}

class _HistorialAccesorioPieChartState extends State<HistorialAccesorioPieChart> {
  int touchedIndex = -1;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _handleTouch(FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
    setState(() {
      if (!event.isInterestedForInteractions ||
          pieTouchResponse == null ||
          pieTouchResponse.touchedSection == null) {
        
        // Iniciar o reiniciar el timer de 3 segundos para limpiar
        _hideTimer?.cancel();
        _hideTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              touchedIndex = -1;
            });
          }
        });
        return;
      }
      
      // Si el mouse entra, cancelamos el timer y actualizamos el índice
      _hideTimer?.cancel();
      touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
    });
  }

  final List<Color> _chartColors = [
    const Color(0xFF8B5CF6),
    const Color(0xFFF59E0B),
    const Color(0xFF10B981),
    const Color(0xFFEF4444),
    const Color(0xFF3B82F6),
    const Color(0xFFEC4899),
    const Color(0xFF6366F1),
    const Color(0xFF14B8A6),
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(
        child: Text(
          'Sin datos de accesorios.',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      );
    }

    final isMobile = MediaQuery.sizeOf(context).width < 600;

    if (isMobile) {
      return Column(
        children: [
          Expanded(
            child: _buildPieChart(),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: _buildPieChart(),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: _buildLegend(),
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: _handleTouch,
            ),
            borderData: FlBorderData(show: false),
            sectionsSpace: 2,
            centerSpaceRadius: 55,
            sections: widget.data.asMap().entries.map((entry) {
              final isTouched = entry.key == touchedIndex;
              final fontSize = isTouched ? 16.0 : 12.0;
              final radius = isTouched ? 45.0 : 38.0;
              final color = _chartColors[entry.key % _chartColors.length];
              return PieChartSectionData(
                color: color,
                value: entry.value.cantidad.toDouble(),
                title: '${entry.value.cantidad}',
                radius: radius,
                titleStyle: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }).toList(),
          ),
          swapAnimationDuration: const Duration(milliseconds: 400),
          swapAnimationCurve: Curves.easeInOut,
        ),
        if (touchedIndex != -1)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.data[touchedIndex].tipVnombre,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4B5563)),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '${widget.data[touchedIndex].cantidad} reg.',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF303366), fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLegend() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.data.asMap().entries.map((entry) {
          final isHovered = touchedIndex == entry.key;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _chartColors[entry.key % _chartColors.length],
                    shape: BoxShape.circle,
                    border: isHovered ? Border.all(color: Colors.black26, width: 2) : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.value.tipVnombre,
                    style: TextStyle(
                      fontSize: 12,
                      color: isHovered ? const Color(0xFF303366) : const Color(0xFF6B7280),
                      fontWeight: isHovered ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
