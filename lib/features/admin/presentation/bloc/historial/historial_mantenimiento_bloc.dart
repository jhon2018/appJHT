// lib/features/admin/presentation/bloc/historial/historial_mantenimiento_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/admin/domain/repositories/admin_repository.dart';
import 'package:app_jht_front/features/admin/data/mocks/historial_mock_data.dart';
import 'package:app_jht_front/features/accessory/domain/repositories/accessory_repository.dart';
import 'package:app_jht_front/features/accessory/data/models/vehiculo_model.dart';
import 'package:app_jht_front/features/accessory/data/models/segmento_model.dart';
import 'package:app_jht_front/features/accessory/data/models/tipo_accesorio_model.dart';
import 'historial_mantenimiento_event.dart';
import 'historial_mantenimiento_state.dart';

class HistorialMantenimientoBloc extends Bloc<HistorialMantenimientoEvent, HistorialMantenimientoState> {
  final AdminRepository adminRepository;
  final AccessoryRepository vehicleRepository;

  // Variables para mantener catálogos cacheados y no volver a pedirlos
  List<VehiculoModel> _vehiculosCache = [];
  List<SegmentoModel> _segmentosCache = [];
  List<TipoAccesorioModel> _accesoriosCache = [];
  
  // Variables de filtros actuales
  int? _currentAnio = DateTime.now().year;
  int? _currentVehIid;
  int? _currentSegIid;
  int? _currentTipIid;

  // Toggle de modo de datos: true = Mock, false = API real
  bool _useMockData = true;

  HistorialMantenimientoBloc({
    required this.adminRepository,
    required this.vehicleRepository,
  }) : super(HistorialInitial()) {
    on<LoadHistorialEvent>(_onLoadHistorial);
    on<ChangeFilterVehiculoEvent>(_onChangeFilterVehiculo);
    on<ChangeFilterSegmentoEvent>(_onChangeFilterSegmento);
    on<ChangeFilterAccesorioEvent>(_onChangeFilterAccesorio);
    on<ChangeFilterAnioEvent>(_onChangeFilterAnio);
    on<ToggleDataModeEvent>(_onToggleDataMode);
  }

  Future<void> _onLoadHistorial(LoadHistorialEvent event, Emitter<HistorialMantenimientoState> emit) async {
    emit(HistorialLoading(
      anio: _currentAnio,
      vehIid: _currentVehIid,
      segIid: _currentSegIid,
      tipIid: _currentTipIid,
      useMockData: _useMockData,
      vehiculos: _vehiculosCache,
      segmentos: _segmentosCache,
      accesorios: _accesoriosCache,
    ));

    try {
      // 1. Cargar catálogos iniciales si están vacíos
      if (_vehiculosCache.isEmpty) {
        _vehiculosCache = await vehicleRepository.listarVehiculos();
      }
      
      if (_segmentosCache.isEmpty) {
        _segmentosCache = await vehicleRepository.listarSegmentos();
      }

      // Si hay un segmento seleccionado, cargar sus accesorios
      if (_currentSegIid != null) {
        _accesoriosCache = await vehicleRepository.listarTiposAccesorioPorSegmento(_currentSegIid!);
      } else {
        _accesoriosCache = []; // Si no hay segmento, no hay accesorios que mostrar
      }

      final response = _useMockData 
          ? getMockHistorialDashboardResponse(
              anio: _currentAnio,
              vehIid: _currentVehIid,
              segIid: _currentSegIid,
              tipIid: _currentTipIid,
              vehiculos: _vehiculosCache,
              segmentos: _segmentosCache,
              accesorios: _accesoriosCache,
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
        segIid: _currentSegIid,
        tipIid: _currentTipIid,
        useMockData: _useMockData,
        vehiculos: _vehiculosCache,
        segmentos: _segmentosCache,
        accesorios: _accesoriosCache,
      ));
    } catch (e) {
      emit(HistorialError(
        message: e.toString(),
        anio: _currentAnio,
        vehIid: _currentVehIid,
        segIid: _currentSegIid,
        tipIid: _currentTipIid,
        useMockData: _useMockData,
        vehiculos: _vehiculosCache,
        segmentos: _segmentosCache,
        accesorios: _accesoriosCache,
      ));
    }
  }

  void _onChangeFilterVehiculo(ChangeFilterVehiculoEvent event, Emitter<HistorialMantenimientoState> emit) {
    _currentVehIid = event.vehIid;
    add(LoadHistorialEvent());
  }

  void _onChangeFilterSegmento(ChangeFilterSegmentoEvent event, Emitter<HistorialMantenimientoState> emit) {
    _currentSegIid = event.segIid;
    // Si cambia el segmento, reseteamos el accesorio porque la lista va a cambiar
    _currentTipIid = null;
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

  void _onToggleDataMode(ToggleDataModeEvent event, Emitter<HistorialMantenimientoState> emit) {
    _useMockData = event.useMockData;
    add(LoadHistorialEvent());
  }
}
