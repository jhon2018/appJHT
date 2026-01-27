//Ruta: lib/features/supplier/domain/repositories/supplier_repository.dart

import 'package:app_jht_front/features/supplier/data/models/supplier_registro_dto.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_registro_response.dart';

abstract class SupplierRepository {
  Future<SupplierRegistroResponse> registrarProveedor(SupplierRegistroDto dto);
}