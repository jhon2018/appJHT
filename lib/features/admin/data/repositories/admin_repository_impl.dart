// lib/features/admin/data/repositories/admin_repository_impl.dart

import 'package:app_jht_front/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:app_jht_front/features/admin/data/models/historial_mantenimiento_model.dart';
import 'package:app_jht_front/features/admin/domain/repositories/admin_repository.dart';
import 'package:app_jht_front/features/mantenimiento/data/models/accesorio_models.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<HistorialDashboardResponse> getHistorialMantenimiento({
    int? anio,
    int? vehIid,
    int? tipIid,
  }) async {
    return await remoteDataSource.getHistorialMantenimiento(
      anio: anio,
      vehIid: vehIid,
      tipIid: tipIid,
    );
  }

  @override
  Future<List<ConceptoMantenimientoModel>> getTiposAccesorio() async {
    return await remoteDataSource.getTiposAccesorio();
  }
}
