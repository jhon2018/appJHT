//RUta: lib/features/supplier/bloc/supplier_state.dart
part of 'supplier_bloc.dart';

@freezed
class SupplierState with _$SupplierState {
  const factory SupplierState.initial() = _Initial;
  const factory SupplierState.loading() = _Loading;
  const factory SupplierState.success({
    required SupplierRegistroResponse response,
  }) = _Success;
  const factory SupplierState.error({
    required String message,
  }) = _Error;
}