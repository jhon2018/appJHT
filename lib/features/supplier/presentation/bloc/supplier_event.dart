//Ruta: lib/features/supplier/bloc/supplier_event.dart

part of 'supplier_bloc.dart';

@freezed
class SupplierEvent with _$SupplierEvent {
  const factory SupplierEvent.registrarProveedor({
    required SupplierRegistroDto dto,
  }) = _RegistrarProveedor;
} 
