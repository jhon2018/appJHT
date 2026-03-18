//Ruta: lib/features/supplier/bloc/supplier_event.dart

part of 'supplier_bloc.dart';

@freezed
class SupplierEvent with _$SupplierEvent {
  const factory SupplierEvent.registrarProveedor({
    required SupplierRegistroDto dto,
  }) = _RegistrarProveedor;

  const factory SupplierEvent.listarProveedores() = _ListarProveedores;
  
  const factory SupplierEvent.obtenerDetalleProveedor({
    required int proveedorId,
  }) = _ObtenerDetalleProveedor;

} 
