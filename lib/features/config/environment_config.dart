import 'package:flutter/foundation.dart';

class EnvironmentConfig {
  static const String _urlProduccion = 'https://jht-transport-api.onrender.com';
  static const String _urlLocalWeb = 'http://localhost:7030';
  static const String _urlLocalMovilEmulador = 'http://10.0.2.2:7030';

  static String get baseUrl {
    // 1. Variable de entorno para forzar el uso de LOCAL 
    // Se activa lanzando: flutter run -d chrome --dart-define=USE_LOCAL=true
    const bool useLocal = bool.fromEnvironment('USE_LOCAL', defaultValue: false);

    if (kReleaseMode) return _urlProduccion;

    if (kIsWeb) {
      // SI NO activaste explicitamente "USE_LOCAL", por defecto usa PRODUCCIÓN
      // Esto soluciona que el navegador siempre intente ir a localhost por error.
      if (!useLocal) {
        debugPrint('🌐 Web Local: Conectando a PRODUCCIÓN (Render)');
        return _urlProduccion;
      }
      debugPrint('💻 Web Local: Conectando a BACKEND LOCAL (7030)');
      return _urlLocalWeb;
    } else {
      // Para móvil (Emulador)
      if (!useLocal) return _urlProduccion;
      return _urlLocalMovilEmulador;
    }
  }

  // 3. Rutas Base
  static String get apiUrl => '$baseUrl/api';
  static bool get isProduction => baseUrl.contains('onrender.com');

  // 4. Todos tus Endpoints Unificados
  // Auth
  static String get authApi => '$apiUrl/Auth'; 
  static String get loginEndpoint => '$authApi/login';
  static String get registerEndpoint => '$authApi/register';

  // Admin
  static String get adminApi => '$apiUrl/admin';
  static String get listarPersonasEndpoint => '$adminApi/Listar-personas';

  // General
  static String get generalApi => '$apiUrl/general';
}