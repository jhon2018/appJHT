// lib/features/admin/domain/repositories/admin_repository.dart

import 'package:app_jht_front/features/admin/data/models/historial_mantenimiento_model.dart';
import 'package:app_jht_front/features/mantenimiento/data/models/accesorio_models.dart';

abstract class AdminRepository {
  Future<HistorialDashboardResponse> getHistorialMantenimiento({
    int? anio,
    int? vehIid,
    int? tipIid,
  });
  
  Future<List<ConceptoMantenimientoModel>> getTiposAccesorio();
}
