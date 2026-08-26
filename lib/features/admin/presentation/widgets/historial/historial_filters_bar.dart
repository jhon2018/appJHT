// lib/features/admin/presentation/widgets/historial/historial_filters_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/admin/presentation/bloc/historial/historial_mantenimiento_bloc.dart';
import 'package:app_jht_front/features/admin/presentation/bloc/historial/historial_mantenimiento_event.dart';
import 'package:app_jht_front/features/admin/presentation/bloc/historial/historial_mantenimiento_state.dart';

class HistorialFiltersBar extends StatelessWidget {
  const HistorialFiltersBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistorialMantenimientoBloc, HistorialMantenimientoState>(
      builder: (context, state) {
        int? anio;
        int? vehIid;
        int? segIid;
        int? tipIid;
        List vehiculos = [];
        List segmentos = [];
        List accesorios = [];

        if (state is HistorialLoading) {
          anio = state.anio;
          vehIid = state.vehIid;
          segIid = state.segIid;
          tipIid = state.tipIid;
          vehiculos = state.vehiculos;
          segmentos = state.segmentos;
          accesorios = state.accesorios;
        } else if (state is HistorialLoaded) {
          anio = state.anio;
          vehIid = state.vehIid;
          segIid = state.segIid;
          tipIid = state.tipIid;
          vehiculos = state.vehiculos;
          segmentos = state.segmentos;
          accesorios = state.accesorios;
        } else if (state is HistorialError) {
          anio = state.anio;
          vehIid = state.vehIid;
          segIid = state.segIid;
          tipIid = state.tipIid;
          vehiculos = state.vehiculos;
          segmentos = state.segmentos;
          accesorios = state.accesorios;
        }

        final bool isLoading = state is HistorialLoading;
        final double width = MediaQuery.sizeOf(context).width;
        
        final bool isMobile = width < 640;
        final bool isTablet = width >= 640 && width < 1100;

        final dropdownAnio = _buildDropdown<int>(
          context: context,
          label: 'Año',
          icon: Icons.calendar_today_rounded,
          value: anio,
          items: [
            const DropdownMenuItem(value: null, child: Text('Todos los años')),
            ...List.generate(5, (i) {
              final year = DateTime.now().year - i;
              return DropdownMenuItem(value: year, child: Text(year.toString()));
            }),
          ],
          onChanged: isLoading
              ? null
              : (val) => context.read<HistorialMantenimientoBloc>().add(ChangeFilterAnioEvent(val)),
        );

        final dropdownVehiculo = _buildDropdown<int>(
          context: context,
          label: 'Vehículo',
          icon: Icons.local_shipping_rounded,
          value: vehIid,
          items: [
            const DropdownMenuItem(value: null, child: Text('Todos los vehículos')),
            ...vehiculos.map((v) => DropdownMenuItem<int>(
                  value: v.id,
                  child: Text(v.placa),
                )),
          ],
          onChanged: isLoading
              ? null
              : (val) => context.read<HistorialMantenimientoBloc>().add(ChangeFilterVehiculoEvent(val)),
        );

        final dropdownSegmento = _buildDropdown<int>(
          context: context,
          label: 'Segmento',
          icon: Icons.category_rounded,
          value: segIid,
          items: [
            const DropdownMenuItem(value: null, child: Text('Todos los segmentos')),
            ...segmentos.map((s) => DropdownMenuItem<int>(
                  value: s.id,
                  child: Text(s.nombre),
                )),
          ],
          onChanged: isLoading
              ? null
              : (val) => context.read<HistorialMantenimientoBloc>().add(ChangeFilterSegmentoEvent(val)),
        );

        final dropdownAccesorio = _buildDropdown<int>(
          context: context,
          label: 'Accesorio',
          icon: Icons.build_circle_rounded,
          value: tipIid,
          items: [
            DropdownMenuItem(
              value: null, 
              child: Text(segIid == null ? 'Seleccione Segmento' : 'Todos los accesorios')
            ),
            ...accesorios.map((a) => DropdownMenuItem<int>(
                  value: a.id,
                  child: Text(a.nombre),
                )),
          ],
          onChanged: isLoading || segIid == null
              ? null
              : (val) => context.read<HistorialMantenimientoBloc>().add(ChangeFilterAccesorioEvent(val)),
        );

        Widget body;

        if (isMobile) {
          body = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              dropdownAnio,
              const SizedBox(height: 10),
              dropdownVehiculo,
              const SizedBox(height: 10),
              dropdownSegmento,
              const SizedBox(height: 10),
              dropdownAccesorio,
            ],
          );
        } else if (isTablet) {
          // Layout de 2 filas x 2 columnas para Tablet (espacio óptimo sin recortes)
          body = Column(
            children: [
              Row(
                children: [
                  Expanded(flex: 1, child: dropdownAnio),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: dropdownVehiculo),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(flex: 1, child: dropdownSegmento),
                  const SizedBox(width: 12),
                  Expanded(flex: 1, child: dropdownAccesorio),
                ],
              ),
            ],
          );
        } else {
          // Layout de 1 fila con proporciones balanceadas para Desktop
          body = Row(
            children: [
              Expanded(flex: 1, child: dropdownAnio),
              const SizedBox(width: 12),
              Expanded(flex: 3, child: dropdownVehiculo),
              const SizedBox(width: 12),
              Expanded(flex: 3, child: dropdownSegmento),
              const SizedBox(width: 12),
              Expanded(flex: 3, child: dropdownAccesorio),
            ],
          );
        }

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: body,
        );
      },
    );
  }

  Widget _buildDropdown<T>({
    required BuildContext context,
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E8)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF6B7280)),
          hint: Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF6B7280)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label, 
                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          selectedItemBuilder: (context) {
            return items.map<Widget>((item) {
              final text = (item.child as Text).data ?? label;
              return Tooltip(
                message: text,
                waitDuration: const Duration(milliseconds: 500),
                child: Row(
                  children: [
                    Icon(icon, size: 16, color: const Color(0xFF303366)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: Color(0xFF1A1A2E), 
                          fontWeight: FontWeight.w600, 
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
