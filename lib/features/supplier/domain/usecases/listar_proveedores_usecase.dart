// lib/features/supplier/domain/usecases/listar_proveedores_usecase.dart
import 'package:app_jht_front/features/supplier/domain/repositories/supplier_repository.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_list_response.dart';

class ListarProveedoresUseCase {
  final SupplierRepository repository;

  ListarProveedoresUseCase({required this.repository});

  Future<SupplierListResponse> execute() async {
    return await repository.listarProveedores();
  }
}