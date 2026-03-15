// lib/core/utils/token_service.dart
//OBJETIVO: Servicio para manejar el almacenamiento seguro de tokens, datos de usuario y roles, con métodos específicos para cada tipo de dato y una función mejorada de logout que borra toda la información relevante.
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  static const String _userRoleKey = 'user_role'; // ← NUEVO
  static const String _usernameKey = 'username'; // ← NUEVO

  // Token methods
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Nuevos métodos específicos para rol y usuario
  static Future<void> saveUserRole(String role) async {
    await _storage.write(key: _userRoleKey, value: role);
  }

  static Future<String?> getUserRole() async {
    return await _storage.read(key: _userRoleKey);
  }

  static Future<void> saveUsername(String username) async {
    await _storage.write(key: _usernameKey, value: username);
  }

  static Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  // Mantener compatibilidad con el método anterior
  static Future<void> saveUserData(String user, String cargo) async {
    await _storage.write(key: _userKey, value: '$user|$cargo');
    // También guardamos por separado para facilitar acceso
    await saveUsername(user);
    await saveUserRole(cargo);
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final data = await _storage.read(key: _userKey);
    if (data != null) {
      final parts = data.split('|');
      return {'usuario': parts[0], 'cargo': parts[1]};
    }
    return null;
  }

  // Método mejorado para logout
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userKey);
    await _storage.delete(key: _userRoleKey); // ← NUEVO
    await _storage.delete(key: _usernameKey); // ← NUEVO
  }

  // Método para verificar si hay sesión activa
  static Future<bool> hasActiveSession() async {
    final token = await getToken();
    final role = await getUserRole();
    return token != null && role != null;
  }
}