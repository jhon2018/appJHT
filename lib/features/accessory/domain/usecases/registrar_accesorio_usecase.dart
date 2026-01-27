// lib/features/accessory/domain/usecases/registrar_accesorio_usecase.dart


import '../../data/models/accesorio_registro_dto.dart';

import '../repositories/accessory_repository.dart';
import '../entities/accesorio_entity.dart';


class RegistrarAccesorioUseCase {
  final AccessoryRepository repository;

  RegistrarAccesorioUseCase({required this.repository});

  Future<AccesorioEntity> call(AccesorioRegistroDto dto) async {
    return await repository.registrarAccesorio(dto);
  }
}