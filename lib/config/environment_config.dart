// // lib/config/environment_config.dart
// import 'package:flutter/foundation.dart';

// class EnvironmentConfig {
//   // URL base única para toda la aplicación
//   static String get baseUrl {
//     // 1. Primero intenta usar variable de entorno de Dart
//     const String dartEnvUrl = String.fromEnvironment(
//       'API_BASE_URL',
//       defaultValue: '',
//     );
    
//     if (dartEnvUrl.isNotEmpty) {
//       return dartEnvUrl;
//     }
    
//     // 2. Si no hay variable de Dart, usa configuración por plataforma
//     if (kIsWeb) {
//       // Para web, siempre producción
//       return 'https://jht-transport-api.onrender.com';
//     } else {
//       // Para móvil, puedes cambiar aquí según necesidad
//       // return 'http://192.168.1.2:7030'; // Local
//       return 'https://jht-transport-api.onrender.com'; // Producción
//     }
//   }
  
//   static String get apiUrl => '$baseUrl/api';
  
//   // Método auxiliar
//   static bool get isProduction => baseUrl.contains('onrender.com');
  
//   // Endpoints comunes (opcional, para mantener consistencia)
//   static String get generalApi => '$apiUrl/general';
//   static String get adminApi => '$apiUrl/admin';
//   static String get authApi => '$apiUrl/auth';
// }