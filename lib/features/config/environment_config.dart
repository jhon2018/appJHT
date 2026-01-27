// lib/config/environment_config.dart
abstract class EnvironmentConfig {
  // URL base según el entorno
  static String get baseUrl {
    // En producción (Render) usamos variable de entorno
    const String envUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://jht-transport-api.onrender.com',
    );
    
    // Para desarrollo local, puedes sobreescribir aquí
    const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;
    
    if (isDebug) {
      // Cambia esto según necesites para desarrollo
      return 'http://localhost:7030'; // Tu backend local
    }
    
    return envUrl;
  }
  
  static String get apiUrl => '$baseUrl/api';
  
  // Método auxiliar para desarrollo vs producción
  static bool get isProduction => baseUrl.contains('onrender.com');
  
  // Endpoints específicos (ajusta según tu backend)
  static String get loginEndpoint => '$apiUrl/auth/login';
  static String get registerEndpoint => '$apiUrl/auth/register';
  static String get listarPersonasEndpoint => '$apiUrl/admin/Listar-personas';
  // Agrega más endpoints aquí...
}