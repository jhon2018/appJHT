// lib/core/utils/token_service.dart
//OBJETIVO: Servicio para manejar el almacenamiento seguro de tokens, datos de usuario y roles, con métodos específicos para cada tipo de dato y una función mejorada de logout que borra toda la información relevante.
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_jht_front/features/config/environment_config.dart';
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

  static Future<Map<String, dynamic>?> getResolvedUserData() async {
    final data = await getUserData();
    if (data == null) return null;

    String userName = data['usuario'];
    final userRole = data['cargo'];

    if (userName.isNotEmpty && !userName.contains(' ')) {
      try {
        final token = await getToken();
        if (token != null) {
          final parts = token.split('.');
          if (parts.length == 3) {
            final payload = json.decode(
              utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
            );
            final userId = payload['UserId'];
            if (userId != null) {
              var response = await http.get(
                Uri.parse('${EnvironmentConfig.baseUrl}/api/admin/persona/$userId'),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
              );
              
              if (response.statusCode == 200) {
                final responseData = json.decode(response.body);
                if (responseData['data'] != null) {
                  final primerNombre = responseData['data']['primerNombre'] ?? '';
                  final apellidoPaterno = responseData['data']['apellidoPaterno'] ?? '';
                  final fullName = '$primerNombre $apellidoPaterno'.trim();
                  
                  if (fullName.isNotEmpty) {
                    userName = fullName;
                    await saveUserData(fullName, userRole);
                  }
                }
              } else {
                // Si falla (ej. 401/403 para Conductor), buscamos en datos-iniciales
                final resDatos = await http.get(
                  Uri.parse('${EnvironmentConfig.baseUrl}/api/general/datos-iniciales'),
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                  },
                );
                
                if (resDatos.statusCode == 200) {
                  final jsonDatos = json.decode(resDatos.body);
                  final personas = jsonDatos['data']?['personas'] as List? ?? [];
                  for (var p in personas) {
                    final idMatches = p['id'].toString() == userId.toString();
                    final nombreMatches = (p['primerNombre'] ?? '').toString().toLowerCase() == userName.toLowerCase();
                    
                    if (idMatches || nombreMatches) {
                      final primerNombre = p['primerNombre'] ?? '';
                      final apellidoPaterno = p['apellidoPaterno'] ?? '';
                      final fullName = '$primerNombre $apellidoPaterno'.trim();
                      
                      if (fullName.isNotEmpty) {
                        userName = fullName;
                        await saveUserData(fullName, userRole);
                      }
                      break;
                    }
                  }
                }
              }
            }
          }
        }
      } catch (e) {
        // Fallback silent
      }
    }

    return {'usuario': userName, 'cargo': userRole};
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