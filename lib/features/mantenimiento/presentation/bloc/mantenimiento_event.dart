// Ruta: lib/features/mantenimiento/presentation/bloc/mantenimiento_event.dart
import 'package:flutter/foundation.dart';

@immutable
abstract class MantenimientoEvent {}

class LoadMantenimientosEvent extends MantenimientoEvent {}

class RefreshMantenimientosEvent extends MantenimientoEvent {}