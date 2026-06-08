// lib/features/home/data/datasources/dashboard_service.dart
import 'dart:convert';
import 'package:app_jht_front/core/network/base_remote_data_source.dart';
import 'package:flutter/foundation.dart';

class DashboardService extends BaseRemoteDataSource {
  
  Future<int> getVehiculosCount() async {
    try {
      final response = await protectedGet('/api/general/Listar-todos-vehiculos');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('data')) {
          return (data['data'] as List).length;
        } else if (data is List) {
          return data.length;
        }
      }
      return 0;
    } catch (e) {
      debugPrint('Error al obtener vehículos para dashboard: $e');
      return 0;
    }
  }

  Future<Map<String, dynamic>> getMantenimientosPendientes() async {
    try {
      final response = await protectedGet('/api/general/mantenimientos-pendientes');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> list = [];
        if (data is Map && data.containsKey('data')) {
          list = data['data'] as List;
        } else if (data is List) {
          list = data;
        }
        return {
          'count': list.length,
          'items': list.take(3).toList(), // Solo tomamos los primeros 3 para alertas
        };
      }
      return {'count': 0, 'items': []};
    } catch (e) {
      debugPrint('Error al obtener mantenimientos para dashboard: $e');
      return {'count': 0, 'items': []};
    }
  }

  Future<int> getConductoresCount() async {
    try {
      final response = await protectedGet('/api/admin/Listar-personas');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('data')) {
          return (data['data'] as List).length;
        } else if (data is List) {
          return data.length;
        }
      }
      return 0;
    } catch (e) {
      debugPrint('Error al obtener conductores para dashboard: $e');
      return 0;
    }
  }

  Future<int> getProveedoresCount() async {
    try {
      final response = await protectedGet('/api/general/listar-proveedores');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('data')) {
          return (data['data'] as List).length;
        } else if (data is List) {
          return data.length;
        }
      }
      return 0;
    } catch (e) {
      debugPrint('Error al obtener proveedores para dashboard: $e');
      return 0;
    }
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    final vehiculos = await getVehiculosCount();
    final mantenimientosData = await getMantenimientosPendientes();
    final conductores = await getConductoresCount();
    final proveedores = await getProveedoresCount();

    return {
      'vehiculos': vehiculos,
      'mantenimientosCount': mantenimientosData['count'],
      'mantenimientosAlertas': mantenimientosData['items'],
      'conductores': conductores,
      'proveedores': proveedores,
    };
  }

  // --- NUEVO: METODOS PARA CONDUCTOR DASHBOARD ---
  
  Future<Map<String, dynamic>?> getAssignedVehicle() async {
    try {
      final response = await protectedGet('/api/general/Listar-todos-vehiculos');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> list = [];
        if (data is Map && data.containsKey('data')) {
          list = data['data'] as List;
        } else if (data is List) {
          list = data;
        }
        
        if (list.isNotEmpty) {
          // Por ahora, simulamos que el conductor tiene asignado el primer vehículo activo.
          // En un futuro se podría filtrar por "conductorId" o consumir un endpoint específico.
          return list.first;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error al obtener vehículo asignado: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getConductorDashboardData() async {
    final vehiculoAsignado = await getAssignedVehicle();
    final mantenimientosData = await getMantenimientosPendientes();

    return {
      'vehiculo': vehiculoAsignado,
      'mantenimientosCount': mantenimientosData['count'],
      'mantenimientosAlertas': mantenimientosData['items'],
      // Aquí se podrían agregar futuras métricas: viajes de hoy, alertas específicas, etc.
    };
  }

  // --- NUEVO: METODOS PARA REPORTE DE MANTENIMIENTO ---

  Future<List<dynamic>> getVehiculosParaFiltro() async {
    try {
      final response = await protectedGet('/api/general/Listar-todos-vehiculos');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('data')) {
          return data['data'] as List;
        } else if (data is List) {
          return data;
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error al obtener vehículos para filtro: $e');
      return [];
    }
  }

  Future<List<dynamic>> getReporteMantenimientos({
    required DateTime fechaInicio,
    required DateTime fechaFin,
    int? vehiculoId,
  }) async {
    try {
      final queryParams = {
        'fechaInicio': fechaInicio.toIso8601String().split('T')[0],
        'fechaFin': fechaFin.toIso8601String().split('T')[0],
      };
      
      if (vehiculoId != null) {
        queryParams['vehiculoId'] = vehiculoId.toString();
      }

      final response = await protectedGet(
        '/api/general/reporte-mantenimientos',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('data')) {
          return data['data'] as List;
        }
      }
      throw Exception('Error al generar el reporte: Código ${response.statusCode}');
    } catch (e) {
      debugPrint('Error al generar reporte de mantenimientos: $e');
      rethrow;
    }
  }
}
