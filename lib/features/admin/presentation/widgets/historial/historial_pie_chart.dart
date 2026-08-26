// lib/features/admin/presentation/widgets/historial/historial_pie_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_jht_front/features/admin/data/models/historial_mantenimiento_model.dart';

class HistorialPieChart extends StatefulWidget {
  final List<HistorialPorClasificacionItem> data;

  const HistorialPieChart({super.key, required this.data});

  @override
  State<HistorialPieChart> createState() => _HistorialPieChartState();
}

class _HistorialPieChartState extends State<HistorialPieChart> {
  int touchedIndex = -1;

  final List<Color> _chartColors = [
    const Color(0xFF303366),
    const Color(0xFF4682B4),
    const Color(0xFF16A34A),
    const Color(0xFFF59E0B),
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(
        child: Text(
          'Sin datos para los filtros seleccionados.',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      );
    }

    final isMobile = MediaQuery.sizeOf(context).width < 600;

    if (isMobile) {
      return Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 55, // Aumentado para dar espacio al texto
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
                          widget.data[touchedIndex].clasificacion,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4B5563)),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'S/ ${widget.data[touchedIndex].costoTotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF303366), fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: widget.data.asMap().entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _chartColors[entry.key % _chartColors.length],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${entry.value.clasificacion}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563)),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 75, // Aumentado para el texto en el centro
                  sections: widget.data.asMap().entries.map((entry) {
                    final isTouched = entry.key == touchedIndex;
                    final fontSize = isTouched ? 16.0 : 12.0;
                    final radius = isTouched ? 60.0 : 50.0;
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
                        widget.data[touchedIndex].clasificacion,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4B5563)),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'S/ ${widget.data[touchedIndex].costoTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16, color: Color(0xFF303366), fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.data.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _chartColors[entry.key % _chartColors.length],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.value.clasificacion,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
