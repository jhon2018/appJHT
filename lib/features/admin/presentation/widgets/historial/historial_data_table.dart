// lib/features/admin/presentation/widgets/historial/historial_data_table.dart

import 'package:flutter/material.dart';
import 'package:app_jht_front/features/admin/data/models/historial_mantenimiento_model.dart';
import 'package:app_jht_front/core/widgets/pagination_widget.dart';
import 'dart:math';

class HistorialDataTable extends StatefulWidget {
  final List<HistorialGeneralItem> data;

  const HistorialDataTable({super.key, required this.data});

  @override
  State<HistorialDataTable> createState() => _HistorialDataTableState();
}

class _HistorialDataTableState extends State<HistorialDataTable> {
  int _currentPage = 1;
  int _itemsPerPage = 5;

  List<HistorialGeneralItem> get _paginatedItems {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    if (startIndex >= widget.data.length) return [];
    final endIndex = min(startIndex + _itemsPerPage, widget.data.length);
    return widget.data.sublist(startIndex, endIndex);
  }

  int get _totalPages => (widget.data.length / _itemsPerPage).ceil();

  @override
  void didUpdateWidget(covariant HistorialDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _currentPage = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No hay registros de mantenimientos con estos filtros.',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFF303366)),
                  headingTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  dataRowMinHeight: 56,
                  dataRowMaxHeight: 64,
                  columns: const [
                    DataColumn(label: Text('Fecha')),
                    DataColumn(label: Text('Vehículo')),
                    DataColumn(label: Text('Accesorio / Repuesto')),
                    DataColumn(label: Text('Proveedor')),
                    DataColumn(label: Text('Monto')),
                    DataColumn(label: Text('Estado')),
                  ],
                  rows: _paginatedItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isEven = index % 2 == 0;
                    
                    return DataRow(
                      color: WidgetStateProperty.all(
                        isEven ? const Color(0xFFF7F8FC) : Colors.white,
                      ),
                      cells: [
                        DataCell(Text(item.bitDfechRegistro.split('T').first)),
                        DataCell(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item.vehVplaca, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(item.vehVmarca, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        )),
                        DataCell(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item.dicVnombre),
                            Text(item.tipVnombre, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        )),
                        DataCell(Text(item.proVrazonSocial)),
                        DataCell(Text('S/${item.gasBmonto.toStringAsFixed(2)}')),
                        DataCell(_buildStatusBadge(item.hisVestado)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
        if (widget.data.length > _itemsPerPage)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: PaginationWidget(
              currentPage: _currentPage,
              totalPages: _totalPages,
              totalItems: widget.data.length,
              itemsPerPage: _itemsPerPage,
              itemLabel: 'mantenimientos',
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              onItemsPerPageChanged: (newLimit) {
                setState(() {
                  _itemsPerPage = newLimit;
                  _currentPage = 1;
                });
              },
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'completado':
      case 'completo':
        bgColor = const Color(0xFFDCFCE7); // successBg
        textColor = const Color(0xFF16A34A); // success
        break;
      case 'pendiente':
        bgColor = const Color(0xFFFEF3C7); // warningBg
        textColor = const Color(0xFFF59E0B); // warning
        break;
      case 'en proceso':
        bgColor = const Color(0xFFDBEAFE); // infoBg
        textColor = const Color(0xFF2563EB); // info
        break;
      default:
        bgColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
