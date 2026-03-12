// lib/features/shared/presentation/widgets/permission_service.dart
// Descripción: Servicio de permisos que centraliza la lógica de acceso a los items del menú según el rol del usuario. Este servicio se inicializa al iniciar sesión y se puede consultar desde cualquier widget para verificar qué items mostrar o habilitar. Facilita la gestión de permisos y la escalabilidad futura al tener toda la lógica en un solo lugar.

import 'package:app_jht_front/core/utils/role_constants.dart';
import 'package:app_jht_front/core/utils/token_service.dart';
import 'package:flutter/material.dart';
import 'menu_config.dart';

class PermissionService {
  // Singleton
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // Rol actual (se actualiza al iniciar sesión)
  String? _currentRole;
  
  // Getter para el rol actual
  String? get currentRole => _currentRole;
  
  // Inicializar el servicio con el rol del usuario
  Future<void> initialize() async {
    _currentRole = await TokenService.getUserRole();
  }
  
  // Actualizar el rol (cuando cambia la sesión)
  void updateRole(String? role) {
    _currentRole = role;
  }
  
  // Verificar si el usuario actual tiene permiso para ver un item
  bool hasPermission(MenuItemType item) {
    if (_currentRole == null) return false;
    return MenuUtil.hasAccess(_currentRole, item);
  }
  
  // Obtener items permitidos para el rol actual
  List<MenuItemType> getAllowedItems() {
    if (_currentRole == null) return [];
    return MenuUtil.getItemsForRole(_currentRole);
  }
  
  // Verificar si es admin
  bool get isAdmin {
    return UserRoles.isAdmin(_currentRole);
  }
  
  // Verificar si es conductor
  bool get isConductor {
    return UserRoles.isConductor(_currentRole);
  }
  
  // Para usar en widgets, crear un stream/provider si es necesario
  static PermissionService of(BuildContext context) {
    return _instance;
  }
}