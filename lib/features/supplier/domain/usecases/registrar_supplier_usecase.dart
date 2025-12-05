//Ruta: lib/features/supplier/domain/usecases/registrar_supplier_usecase.dart
import 'package:app_jht_front/features/supplier/domain/repositories/supplier_repository.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_registro_dto.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_registro_response.dart';

class RegistrarSupplierUseCase {
  final SupplierRepository repository;

  RegistrarSupplierUseCase({required this.repository});

  Future<SupplierRegistroResponse> execute(SupplierRegistroDto dto) async {
    return await repository.registrarProveedor(dto);
  }
}