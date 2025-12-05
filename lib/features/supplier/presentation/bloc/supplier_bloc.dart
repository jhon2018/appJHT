//Ruta: lib/features/supplier/bloc/supplier_bloc.dart
import 'package:app_jht_front/features/supplier/data/models/supplier_registro_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:app_jht_front/features/supplier/domain/usecases/registrar_supplier_usecase.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_registro_dto.dart';

part 'supplier_event.dart';
part 'supplier_state.dart';
part 'supplier_bloc.freezed.dart';

class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  final RegistrarSupplierUseCase registrarSupplierUseCase;

  SupplierBloc({required this.registrarSupplierUseCase})
      : super(const SupplierState.initial()) {
    on<_RegistrarProveedor>(_onRegistrarProveedor);
  }

  Future<void> _onRegistrarProveedor(
    _RegistrarProveedor event,
    Emitter<SupplierState> emit,
  ) async {
    emit(const SupplierState.loading());
    
    try {
      final response = await registrarSupplierUseCase.execute(event.dto);
      emit(SupplierState.success(response: response));
    } catch (e) {
      emit(SupplierState.error(message: e.toString()));
    }
  }
}