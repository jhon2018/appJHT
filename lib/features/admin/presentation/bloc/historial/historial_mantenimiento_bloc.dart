// lib/features/admin/presentation/bloc/historial/historial_mantenimiento_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/admin/domain/repositories/admin_repository.dart';
import 'package:app_jht_front/features/admin/data/mocks/historial_mock_data.dart';
import 'package:app_jht_front/features/accessory/domain/repositories/accessory_repository.dart';
import 'package:app_jht_front/features/accessory/data/models/vehiculo_model.dart';
import 'package:app_jht_front/features/mantenimiento/data/models/accesorio_models.dart';
import 'historial_mantenimiento_event.dart';
import 'historial_mantenimiento_state.dart';

class HistorialMantenimientoBloc extends Bloc<HistorialMantenimientoEvent, HistorialMantenimientoState> {
  final AdminRepository adminRepository;
  final AccessoryRepository vehicleRepository;

  // Variables para mantener catálogos cacheados y no volver a pedirlos
  List<VehiculoModel> _vehiculosCache = [];
  List<ConceptoMantenimientoModel> _accesoriosCache = [];
  
  // Variables de filtros actuales
  int? _currentAnio = DateTime.now().year;
  int? _currentVehIid;
  int? _currentTipIid;

  HistorialMantenimientoBloc({
    required this.adminRepository,
    required this.vehicleRepository,
  }) : super(HistorialInitial()) {
    on<LoadHistorialEvent>(_onLoadHistorial);
    on<ChangeFilterVehiculoEvent>(_onChangeFilterVehiculo);
    on<ChangeFilterAccesorioEvent>(_onChangeFilterAccesorio);
    on<ChangeFilterAnioEvent>(_onChangeFilterAnio);
  }

  Future<void> _onLoadHistorial(LoadHistorialEvent event, Emitter<HistorialMantenimientoState> emit) async {
    emit(HistorialLoading(
      anio: _currentAnio,
      vehIid: _currentVehIid,
      tipIid: _currentTipIid,
      vehiculos: _vehiculosCache,
      accesorios: _accesoriosCache,
    ));

    try {
      // 1. Cargar catálogos si están vacíos
      if (_vehiculosCache.isEmpty || _accesoriosCache.isEmpty) {
        final vehiculosRes = await vehicleRepository.listarVehiculos();
        _vehiculosCache = vehiculosRes;

        final accesoriosRes = await adminRepository.getTiposAccesorio();
        _accesoriosCache = accesoriosRes;
      }

      // TODO: MODO PRUEBA (MOCK) - Cambiar a `false` para usar la API real
      const bool useMockData = true;

      final response = useMockData 
          ? getMockHistorialDashboardResponse(
              anio: _currentAnio,
              vehIid: _currentVehIid,
              tipIid: _currentTipIid,
            )
          : await adminRepository.getHistorialMantenimiento(
              anio: _currentAnio,
              vehIid: _currentVehIid,
              tipIid: _currentTipIid,
            );

      emit(HistorialLoaded(
        data: response,
        anio: _currentAnio,
        vehIid: _currentVehIid,
        tipIid: _currentTipIid,
        vehiculos: _vehiculosCache,
        accesorios: _accesoriosCache,
      ));
    } catch (e) {
      emit(HistorialError(
        message: e.toString(),
        anio: _currentAnio,
        vehIid: _currentVehIid,
        tipIid: _currentTipIid,
        vehiculos: _vehiculosCache,
        accesorios: _accesoriosCache,
      ));
    }
  }

  void _onChangeFilterVehiculo(ChangeFilterVehiculoEvent event, Emitter<HistorialMantenimientoState> emit) {
    _currentVehIid = event.vehIid;
    add(LoadHistorialEvent());
  }

  void _onChangeFilterAccesorio(ChangeFilterAccesorioEvent event, Emitter<HistorialMantenimientoState> emit) {
    _currentTipIid = event.tipIid;
    add(LoadHistorialEvent());
  }

  void _onChangeFilterAnio(ChangeFilterAnioEvent event, Emitter<HistorialMantenimientoState> emit) {
    _currentAnio = event.anio;
    add(LoadHistorialEvent());
  }
}
