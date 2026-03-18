// lib/features/supplier/data/repositories/supplier_repository_impl.dart
import 'package:app_jht_front/features/supplier/data/models/supplier_detail_response.dart';
import 'package:app_jht_front/features/supplier/domain/repositories/supplier_repository.dart';
import 'package:app_jht_front/features/supplier/data/datasources/supplier_remote_data_source.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_registro_dto.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_registro_response.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_list_response.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final SupplierRemoteDataSource remoteDataSource;

  SupplierRepositoryImpl({required this.remoteDataSource});

  @override
  Future<SupplierRegistroResponse> registrarProveedor(SupplierRegistroDto dto) async {
    return await remoteDataSource.registrarProveedor(dto);
  }

  @override
  Future<SupplierListResponse> listarProveedores() async {
    return await remoteDataSource.listarProveedores();
  }

  @override
  Future<SupplierDetailResponse> obtenerDetalleProveedor(int proveedorId) async {
    return await remoteDataSource.obtenerDetalleProveedor(proveedorId);
  }
}