//Ruta: lib/features/supplier/domain/repositories/supplier_repository.dart

import 'package:app_jht_front/features/supplier/data/models/supplier_actualizar_dto.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_actualizar_response.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_detail_response.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_list_response.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_registro_dto.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_registro_response.dart';

abstract class SupplierRepository {
  Future<SupplierRegistroResponse> registrarProveedor(SupplierRegistroDto dto);
  Future<SupplierListResponse> listarProveedores();
  Future<SupplierDetailResponse> obtenerDetalleProveedor(int proveedorId);
  Future<SupplierActualizarResponse> actualizarProveedor(SupplierActualizarDto dto);
}