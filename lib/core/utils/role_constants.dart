// lib/core/constants/role_constants.dart
// Descripción: Archivo que define los roles de usuario como constantes, junto con métodos helper para verificar roles específicos y listas de roles válidos para facilitar la gestión de permisos en toda la aplicación.

abstract class UserRoles {
  static const String root = 'Root';
  static const String administrador = 'Administrador';
  static const String conductor = 'Conductor';
  
  // Lista de roles que son administradores
  static const List<String> adminRoles = [root, administrador];
  
  // Todos los roles válidos
  static const List<String> allRoles = [root, administrador, conductor];
  
  // Método helper para verificar si un rol es admin
  static bool isAdmin(String? role) {
    return adminRoles.contains(role);
  }
  
  // Método helper para verificar si un rol es conductor
  static bool isConductor(String? role) {
    return role == conductor;
  }
}