// lib/features/vehicle/data/datasources/vehicle_remote_data_source.dart
import 'package:app_jht_front/core/network/http_client.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_list_response.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_registro_dto.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_registro_response.dart';
import 'package:app_jht_front/core/network/base_remote_data_source.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_update_dto.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_update_response.dart';
import 'package:app_jht_front/core/utils/app_logger.dart';

import 'dart:convert';

abstract class VehicleRemoteDataSource {
  Future<VehicleRegistroResponse> registrarVehiculo(VehicleRegistroDto dto);
  Future<List<VehicleListData>> getAllVehicles(); 
  Future<VehicleUpdateResponse> actualizarVehiculo(VehicleUpdateDto dto); 
}

class VehicleRemoteDataSourceImpl extends BaseRemoteDataSource 
    implements VehicleRemoteDataSource {
  
  VehicleRemoteDataSourceImpl({required HttpClient httpClient});

  @override
  Future<VehicleRegistroResponse> registrarVehiculo(VehicleRegistroDto dto) async {
    final response = await protectedPost(
      '/api/general/registro_vehiculo', 
      dto.toJson()
    );

    if (response.statusCode == 200) {
      // ✅ Log de auditoría de negocio
      AppLogger.audit(
        'Vehículo registrado: ${dto.vehVplaca}', 
        action: 'CREATE', 
        entity: 'Vehiculo',
        source: 'VehicleRemoteDataSource'
      );
      
      final responseData = json.decode(response.body);
      return VehicleRegistroResponse.fromJson(responseData);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(getErrorMessage(errorData));
    }
  }

  @override
  Future<List<VehicleListData>> getAllVehicles() async {
    final response = await protectedGet('/api/general/Listar-todos-vehiculos');
    
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final vehicleResponse = VehicleListResponse.fromJson(jsonData);
      return vehicleResponse.data;
    } else {
      final errorData = json.decode(response.body);
      throw Exception(getErrorMessage(errorData));
    }
  }

  @override
  Future<VehicleUpdateResponse> actualizarVehiculo(VehicleUpdateDto dto) async {
    final response = await protectedPut(
      '/api/general/actualizar-vehiculo', 
      dto.toJson()
    );

    if (response.statusCode == 200) {
      // ✅ Log de auditoría de negocio
      AppLogger.audit(
        'Vehículo actualizado ID: ${dto.vehiculoId}', 
        action: 'UPDATE', 
        entity: 'Vehiculo',
        source: 'VehicleRemoteDataSource'
      );

      final responseData = json.decode(response.body);
      return VehicleUpdateResponse.fromJson(responseData);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(getErrorMessage(errorData));
    }
  }
}