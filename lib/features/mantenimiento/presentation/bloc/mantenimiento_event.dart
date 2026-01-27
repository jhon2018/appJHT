// Ruta: lib/features/mantenimiento/presentation/bloc/mantenimiento_event.dart
import 'package:flutter/foundation.dart';
import 'package:app_jht_front/features/mantenimiento/data/models/detalle_mantenimiento_model.dart';

@immutable
abstract class MantenimientoEvent {
  const MantenimientoEvent(); // ✅ Agregar constructor const
}

class LoadMantenimientosEvent extends MantenimientoEvent {
  const LoadMantenimientosEvent();
}

class RefreshMantenimientosEvent extends MantenimientoEvent {
  const RefreshMantenimientosEvent();
}

class LoadDetalleMantenimientoEvent extends MantenimientoEvent {
  final int bitacoraId;
  final int accesorioId;

  const LoadDetalleMantenimientoEvent({
    required this.bitacoraId,
    required this.accesorioId,
  });
}

class UpdateMantenimientoEvent extends MantenimientoEvent {
  final ActualizarMantenimientoRequest request;

  const UpdateMantenimientoEvent({
    required this.request,
  });
}