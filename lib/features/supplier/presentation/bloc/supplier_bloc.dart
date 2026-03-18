//Ruta: lib/features/supplier/bloc/supplier_bloc.dart
import 'package:app_jht_front/features/supplier/data/models/supplier_detail_response.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_list_response.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_registro_response.dart';
import 'package:app_jht_front/features/supplier/domain/usecases/listar_proveedores_usecase.dart';
import 'package:app_jht_front/features/supplier/domain/usecases/obtener_detalle_proveedor_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:app_jht_front/features/supplier/domain/usecases/registrar_supplier_usecase.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_registro_dto.dart';

part 'supplier_event.dart';
part 'supplier_state.dart';
part 'supplier_bloc.freezed.dart';


class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  final RegistrarSupplierUseCase registrarSupplierUseCase;
  final ListarProveedoresUseCase listarProveedoresUseCase;
  final ObtenerDetalleProveedorUseCase obtenerDetalleProveedorUseCase;

  SupplierBloc({
    required this.registrarSupplierUseCase,
    required this.listarProveedoresUseCase,
    required this.obtenerDetalleProveedorUseCase,
  }) : super(const SupplierState.initial()) {
    on<_RegistrarProveedor>(_onRegistrarProveedor);
    on<_ListarProveedores>(_onListarProveedores);
    on<_ObtenerDetalleProveedor>(_onObtenerDetalleProveedor);
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

  Future<void> _onListarProveedores(
    _ListarProveedores event,
    Emitter<SupplierState> emit,
  ) async {
    emit(const SupplierState.loading());
    
    try {
      final response = await listarProveedoresUseCase.execute();
      emit(SupplierState.listLoaded(response: response));
    } catch (e) {
      emit(SupplierState.error(message: e.toString()));
    }
  }

  Future<void> _onObtenerDetalleProveedor(
    _ObtenerDetalleProveedor event,
    Emitter<SupplierState> emit,
  ) async {
    emit(const SupplierState.loading());
    
    try {
      final response = await obtenerDetalleProveedorUseCase.execute(event.proveedorId);
      emit(SupplierState.detailLoaded(response: response));
    } catch (e) {
      emit(SupplierState.error(message: e.toString()));
    }
  }
}