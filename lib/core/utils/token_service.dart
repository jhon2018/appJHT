// lib/core/utils/token_service.dart
//OBJETIVO: Servicio para manejar el almacenamiento seguro de tokens y datos de usuario.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
  
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userKey);
  }
  
  static Future<void> saveUserData(String user, int nivelAcceso) async {
    await _storage.write(key: _userKey, value: '$user|$nivelAcceso');
  }
  
  static Future<Map<String, dynamic>?> getUserData() async {
    final data = await _storage.read(key: _userKey);
    if (data != null) {
      final parts = data.split('|');
      return {
        'usuario': parts[0],
        'nivelAcceso': int.tryParse(parts[1]) ?? 0,
      };
    }
    return null;
  }
}