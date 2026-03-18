// lib/features/supplier/domain/usecases/obtener_detalle_proveedor_usecase.dart
import 'package:app_jht_front/features/supplier/domain/repositories/supplier_repository.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_detail_response.dart';

class ObtenerDetalleProveedorUseCase {
  final SupplierRepository repository;

  ObtenerDetalleProveedorUseCase({required this.repository});

  Future<SupplierDetailResponse> execute(int proveedorId) async {
    return await repository.obtenerDetalleProveedor(proveedorId);
  }
}