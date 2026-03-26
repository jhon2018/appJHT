// lib/features/supplier/domain/usecases/actualizar_supplier_usecase.dart
// Descripcion: UseCase para actualizar un proveedor existente. Recibe un SupplierActualizarDto con los datos a actualizar y devuelve un SupplierActualizarResponse con el resultado de la operación.

import 'package:app_jht_front/features/supplier/domain/repositories/supplier_repository.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_actualizar_dto.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_actualizar_response.dart';

class ActualizarSupplierUseCase {
  final SupplierRepository repository;

  ActualizarSupplierUseCase({required this.repository});

  Future<SupplierActualizarResponse> execute(SupplierActualizarDto dto) async {
    return await repository.actualizarProveedor(dto);
  }
}