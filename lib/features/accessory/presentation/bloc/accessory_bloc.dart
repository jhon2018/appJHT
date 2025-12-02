// lib/features/accessory/presentation/bloc/accessory_bloc.dart
// descripción: Bloc para gestionar el estado de los accesorios, incluyendo la carga de segmentos, tipos de accesorio y vehículos.
// objetivo: Implementar la lógica de negocio para manejar eventos y estados relacionados con accesorios.
import 'package:app_jht_front/features/accessory/data/models/accesorio_registro_dto.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_registro_response.dart';
import 'package:app_jht_front/features/accessory/domain/usecases/registrar_accesorio_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/accessory/domain/repositories/accessory_repository.dart';
import 'package:app_jht_front/features/accessory/data/models/segmento_model.dart';
import 'package:app_jht_front/features/accessory/data/models/tipo_accesorio_model.dart';
import 'package:app_jht_front/features/accessory/data/models/vehiculo_model.dart';

part 'accessory_event.dart';
part 'accessory_state.dart';

class AccessoryBloc extends Bloc<AccessoryEvent, AccessoryState> {
  final AccessoryRepository repository;

  AccessoryBloc({required this.repository}) : super(AccessoryInitial()) {
    on<LoadSegmentosEvent>(_onLoadSegmentos);
    on<LoadTiposAccesorioEvent>(_onLoadTiposAccesorio);
    on<LoadVehiculosEvent>(_onLoadVehiculos);
    on<RegistrarAccesorioEvent>(_onRegistrarAccesorio);

  }

Future<void> _onRegistrarAccesorio(
  RegistrarAccesorioEvent event,
  Emitter<AccessoryState> emit,
) async {
  emit(RegistrandoAccesorio());
  try {
    // Aquí necesitas el usecase o llamar directo al repository
    final useCase = RegistrarAccesorioUseCase(repository: repository);
    final accesorio = await useCase(event.dto);
    
    emit(AccesorioRegistrado(
      response: AccesorioRegistroResponse(
        status: 'OK',
        message: 'Accesorio registrado exitosamente',
        data: {'idAccesorio': accesorio.id},
      ),
    ));
  } catch (e) {
    emit(RegistroError(message: e.toString()));
  }
}

  Future<void> _onLoadSegmentos(
    LoadSegmentosEvent event,
    Emitter<AccessoryState> emit,
  ) async {
   emit(SegmentosLoading()); // Cambiado a loading específico
    try {
      final segmentos = await repository.listarSegmentos();
      emit(SegmentosLoaded(segmentos: segmentos));
    } catch (e) {
      emit(AccessoryError(message: e.toString()));
    }
  }

  Future<void> _onLoadTiposAccesorio(
    LoadTiposAccesorioEvent event,
    Emitter<AccessoryState> emit,
  ) async {
   emit(TiposAccesorioLoading()); 
    try {
      final tiposAccesorio = await repository.listarTiposAccesorioPorSegmento(
        event.segmentoId,
      );

      // DEBUG: Verificar datos recibidos
      print('🟡 Tipos accesorio recibidos: ${tiposAccesorio.length}');
      for (var tipo in tiposAccesorio) {
        print('  - ${tipo.id}: ${tipo.nombre}');
      }

      emit(TiposAccesorioLoaded(tiposAccesorio: tiposAccesorio));
    } catch (e) {
      print('❌ ERROR en _onLoadTiposAccesorio: $e');
      emit(AccessoryError(message: e.toString()));
    }
  }

  Future<void> _onLoadVehiculos(
    LoadVehiculosEvent event,
    Emitter<AccessoryState> emit,
  ) async {
   emit(VehiculosLoading()); 
    try {
      final vehiculos = await repository.listarVehiculos();
      emit(VehiculosLoaded(vehiculos: vehiculos));
    } catch (e) {
      emit(AccessoryError(message: e.toString()));
    }
  }
}
