// Ruta: lib/features/supplier/data/repositories/supplier_repository_impl.dart

import 'package:app_jht_front/features/supplier/domain/repositories/supplier_repository.dart';
import 'package:app_jht_front/features/supplier/data/datasources/supplier_remote_data_source.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_registro_dto.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_registro_response.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final SupplierRemoteDataSource remoteDataSource;

  SupplierRepositoryImpl({required this.remoteDataSource});

  @override
  Future<SupplierRegistroResponse> registrarProveedor(SupplierRegistroDto dto) async {
    return await remoteDataSource.registrarProveedor(dto);
  }
}