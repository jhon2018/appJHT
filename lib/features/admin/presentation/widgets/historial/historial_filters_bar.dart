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
        int? tipIid;
        List vehiculos = [];
        List accesorios = [];

        if (state is HistorialLoading) {
          anio = state.anio;
          vehIid = state.vehIid;
          tipIid = state.tipIid;
          vehiculos = state.vehiculos;
          accesorios = state.accesorios;
        } else if (state is HistorialLoaded) {
          anio = state.anio;
          vehIid = state.vehIid;
          tipIid = state.tipIid;
          vehiculos = state.vehiculos;
          accesorios = state.accesorios;
        } else if (state is HistorialError) {
          anio = state.anio;
          vehIid = state.vehIid;
          tipIid = state.tipIid;
          vehiculos = state.vehiculos;
          accesorios = state.accesorios;
        }

        final bool isLoading = state is HistorialLoading;
        final bool isMobile = MediaQuery.sizeOf(context).width < 600;

        final filters = [
          _buildDropdown<int>(
            context: context,
            label: 'Año',
            icon: Icons.calendar_today_rounded,
            value: anio,
            items: [
              const DropdownMenuItem(value: null, child: Text('Todos')),
              ...List.generate(5, (i) {
                final year = DateTime.now().year - i;
                return DropdownMenuItem(value: year, child: Text(year.toString()));
              }),
            ],
            onChanged: isLoading
                ? null
                : (val) => context.read<HistorialMantenimientoBloc>().add(ChangeFilterAnioEvent(val)),
          ),
          if (isMobile) const SizedBox(height: 12),
          if (!isMobile) const SizedBox(width: 12),
          _buildDropdown<int>(
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
          ),
          if (isMobile) const SizedBox(height: 12),
          if (!isMobile) const SizedBox(width: 12),
          _buildDropdown<int>(
            context: context,
            label: 'Accesorio',
            icon: Icons.build_circle_rounded,
            value: tipIid,
            items: [
              const DropdownMenuItem(value: null, child: Text('Todos los accesorios')),
              ...accesorios.map((a) => DropdownMenuItem<int>(
                    value: a.id,
                    child: Text(a.nombre),
                  )),
            ],
            onChanged: isLoading
                ? null
                : (val) => context.read<HistorialMantenimientoBloc>().add(ChangeFilterAccesorioEvent(val)),
          ),
        ];

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: isMobile
              ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: filters)
              : Row(children: filters.map((f) => Expanded(child: f)).toList()),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
            ],
          ),
          selectedItemBuilder: (context) {
            return items.map<Widget>((item) {
              return Row(
                children: [
                  Icon(icon, size: 16, color: const Color(0xFF303366)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      (item.child as Text).data ?? label,
                      style: const TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
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
