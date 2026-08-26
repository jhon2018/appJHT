// lib/features/admin/presentation/widgets/historial/historial_bar_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_jht_front/features/admin/data/models/historial_mantenimiento_model.dart';
import 'package:app_jht_front/core/theme/maintenance_colors.dart';

class HistorialBarChart extends StatelessWidget {
  final List<HistorialPorFechaItem> data;

  const HistorialBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('Sin datos para mostrar', style: TextStyle(color: Color(0xFF6B7280))),
      );
    }

    final maxY = data.fold<double>(0, (max, item) => item.costoTotal > max ? item.costoTotal : max);
    final adjustedMaxY = maxY == 0 ? 5000.0 : maxY + (maxY * 0.15); // Dar algo de espacio superior

    return Padding(
      padding: const EdgeInsets.only(top: 16.0, right: 16.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: adjustedMaxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final item = data[groupIndex];
                return BarTooltipItem(
                  '${item.mes}\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  children: [
                    TextSpan(
                      text: 'Costo: S/${item.costoTotal.toStringAsFixed(2)}\n',
                      style: const TextStyle(color: Color(0xFF16A34A), fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '${item.cantidad} mantenimientos',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < data.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        data[value.toInt()].mes.substring(0, 3),
                        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 28,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  if (value == meta.max || value == meta.min) return const SizedBox.shrink();
                  // Format as k (thousands)
                  String text;
                  if (value >= 1000) {
                    text = 'S/${(value / 1000).toStringAsFixed(1)}k';
                  } else {
                    text = 'S/${value.toInt()}';
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      text,
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10),
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (adjustedMaxY / 4).ceilToDouble() > 0 ? (adjustedMaxY / 4).ceilToDouble() : 1,
            getDrawingHorizontalLine: (value) => const FlLine(
              color: Color(0xFFF3F4F6),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.costoTotal,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4682B4), Color(0xFF303366)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
        swapAnimationDuration: const Duration(milliseconds: 400),
        swapAnimationCurve: Curves.easeInOut,
      ),
    );
  }
}
