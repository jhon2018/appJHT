// lib/features/supplier/presentation/bloc/supplier_state.dart
part of 'supplier_bloc.dart';

@freezed
class SupplierState with _$SupplierState {
  const factory SupplierState.initial() = _Initial;
  const factory SupplierState.loading() = _Loading;
  
  // Estados para registro
  const factory SupplierState.success({
    required SupplierRegistroResponse response,
  }) = _Success;
  
  // Estados para listado
  const factory SupplierState.listLoaded({
    required SupplierListResponse response,
  }) = _ListLoaded;
  
  // Estados para detalle
  const factory SupplierState.detailLoaded({
    required SupplierDetailResponse response,
  }) = _DetailLoaded;
  
  // NUEVO ESTADO para actualización exitosa
  const factory SupplierState.updateSuccess({
    required SupplierActualizarResponse response,
  }) = _UpdateSuccess;
  
  const factory SupplierState.error({
    required String message,
  }) = _Error;
}