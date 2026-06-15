// lib/features/shared/presentation/widgets/menu_config.dart
// Descripción: Archivo que define la configuración del menú lateral, incluyendo los tipos de menú, su configuración visual y los permisos asociados a cada rol de usuario. Este archivo centraliza la lógica de qué items mostrar según el rol, facilitando la gestión de permisos y la escalabilidad futura.

import 'package:app_jht_front/core/utils/role_constants.dart';
import 'package:flutter/material.dart';

// Definición de tipos de menú
enum MenuItemType {
  dashboard,
  mantenimiento,
  vehiculo,
  proveedor,
  conductores,
  accesorios,
  ayuda,
}

// Configuración visual de cada item del menú
class MenuItemConfig {
  final String icon;
  final String title;
  final IconData? materialIcon; // Opcional para cuando quieras usar Iconos de Material

  const MenuItemConfig({
    required this.icon,
    required this.title,
    this.materialIcon,
  });
}

// Configuración visual de todos los items
const Map<MenuItemType, MenuItemConfig> menuItemVisualConfig = {
  MenuItemType.dashboard: MenuItemConfig(
    icon: '📊',
    title: 'Dashboard',
    materialIcon: Icons.dashboard_rounded,
  ),
  MenuItemType.mantenimiento: MenuItemConfig(
    icon: '🔧',
    title: 'Mantenimiento',
    materialIcon: Icons.build_circle_rounded,
  ),
  MenuItemType.vehiculo: MenuItemConfig(
    icon: '🚗',
    title: 'Vehículo',
    materialIcon: Icons.directions_bus_filled_rounded,
  ),
  MenuItemType.proveedor: MenuItemConfig(
    icon: '🏢',
    title: 'Proveedor',
    materialIcon: Icons.store_mall_directory_rounded,
  ),
  MenuItemType.conductores: MenuItemConfig(
    icon: '👨‍💼',
    title: 'Colaboradores',
    materialIcon: Icons.badge_rounded,
  ),
  MenuItemType.accesorios: MenuItemConfig(
    icon: '🔩',
    title: 'Accesorios',
    materialIcon: Icons.settings_input_component_rounded,
  ),
  MenuItemType.ayuda: MenuItemConfig(
    icon: '❓',
    title: 'Ayuda',
    materialIcon: Icons.help_outline_rounded,
  ),
};

// PERMISOS: Definición de qué puede ver cada rol
const Map<String, List<MenuItemType>> rolePermissions = {
  // Root y Administrador ven TODO
  UserRoles.root: [
    MenuItemType.dashboard,
    MenuItemType.mantenimiento,
    MenuItemType.vehiculo,
    MenuItemType.proveedor,
    MenuItemType.conductores,
    MenuItemType.accesorios,
    MenuItemType.ayuda,
  ],
  UserRoles.administrador: [
    MenuItemType.dashboard,
    MenuItemType.mantenimiento,
    MenuItemType.vehiculo,
    MenuItemType.proveedor,
    MenuItemType.conductores,
    MenuItemType.accesorios,
    MenuItemType.ayuda,
  ],
  // Conductor solo ve Dashboard, Mantenimiento y Ayuda
  UserRoles.conductor: [
    MenuItemType.dashboard,
    MenuItemType.mantenimiento,
    MenuItemType.ayuda, // Ayuda visible para todos
  ],
};

// Clase de utilidad para trabajar con el menú
class MenuUtil {
  // Obtener items permitidos para un rol
  static List<MenuItemType> getItemsForRole(String? role) {
    if (role == null) return [];
    
    // Buscar los permisos para el rol, si no existe retornar lista vacía
    return rolePermissions[role] ?? [];
  }
  
  // Verificar si un rol tiene acceso a un item específico
  static bool hasAccess(String? role, MenuItemType item) {
    if (role == null) return false;
    final allowedItems = rolePermissions[role] ?? [];
    return allowedItems.contains(item);
  }
  
  // Obtener configuración visual de un item
  static MenuItemConfig getConfigForItem(MenuItemType item) {
    return menuItemVisualConfig[item]!;
  }
  
  // Convertir MenuItemType a nuestro modelo MenuItem (para compatibilidad)
  static List<MenuItem> toMenuItemList(String? role) {
    final allowedItems = getItemsForRole(role);
    
    return allowedItems.map((itemType) {
      final config = getConfigForItem(itemType);
      return MenuItem(
        icon: config.icon,
        title: config.title,
        materialIcon: config.materialIcon,
        enabled: true, // Todos los permitidos están enabled
      );
    }).toList();
  }
}

// Modelo MenuItem (mantenemos el existente para compatibilidad)
class MenuItem {
  final String icon;
  final String title;
  final IconData? materialIcon;
  final bool enabled;

  MenuItem({
    required this.icon,
    required this.title,
    this.materialIcon,
    required this.enabled,
  });
}