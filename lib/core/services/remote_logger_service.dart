import 'dart:async';
import 'dart:convert';
import 'dart:math'; // ← Para Random
import 'package:app_jht_front/features/config/environment_config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class RemoteLoggerService {
  static final RemoteLoggerService _instance = RemoteLoggerService._internal();
  static RemoteLoggerService get instance => _instance;
  factory RemoteLoggerService() => _instance;
  RemoteLoggerService._internal();

  // ✅ Usa tu EnvironmentConfig para la URL
  final String _baseUrl = '${EnvironmentConfig.apiUrl}/logs';
  final http.Client _client = http.Client();
  
  String? _sessionId;
  String? _currentUser;

  // ✅ Genera sessionId sin paquete externo
  String get sessionId {
    if (_sessionId == null) {
      final random = Random();
      _sessionId = 'sess_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(999999)}';
    }
    return _sessionId!;
  }

  void setUser(String username) => _currentUser = username;

  Future<void> _sendLog({
    required String message,
    required String level,
    String? source,
    String? errorMessage,
    String? stackTrace,
    String? fileName,
    int? lineNumber,
    String? functionName,
    Map<String, dynamic>? metadata,
  }) async {
    // En desarrollo, imprime en consola local también
    if (!kReleaseMode) {
      debugPrint('📤 [$level] $message');
    }

    try {
      // Parsear stack trace automáticamente si no se proporciona
      final trace = stackTrace ?? StackTrace.current.toString();
      final parsed = _parseStackTrace(trace);

      // FIX: Sanitizar metadata para evitar IdentityMap en Flutter Web (dart2js)
      final safeMetadata = metadata != null
          ? Map<String, dynamic>.from(metadata)
          : null;

      final body = <String, dynamic>{
        'message': message,
        'level': level,
        'source': source ?? 'Flutter-Web',
        'errorMessage': errorMessage,
        'stackTrace': trace,
        'fileName': (parsed['fileName'] ?? fileName)?.toString(),
        'lineNumber': parsed['lineNumber'] ?? lineNumber,
        'functionName': (parsed['functionName'] ?? functionName)?.toString(),
        'usuario': _currentUser ?? 'anonimo',
        'sessionId': sessionId,
        'timestamp': DateTime.now().toIso8601String(),
        'metadata': safeMetadata,
      };

      // Fire & Forget: no bloquea la UI del usuario
      unawaited(
        _client
            .post(
              Uri.parse(_baseUrl),
              headers: <String, String>{'Content-Type': 'application/json'},
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 3))
            // ignore: body_might_complete_normally_catch_error
            .catchError((_) {}), // Silencia errores de red para no afectar la app
      );
    } catch (e) {
      // NUNCA propagar errores del logger — evita cascadas que bloquean la UI
      if (!kReleaseMode) {
        debugPrint('⚠️ Fallo al enviar log remoto: $e');
      }
    }
  }

  /// Parsea el stack trace de Dart para extraer archivo, línea y función
  Map<String, dynamic> _parseStackTrace(String stack) {
    try {
      // Formato típico: #1      MyClass.myMethod (package:my_app/file.dart:45:12)
      final regex = RegExp(r'#\d+\s+(?:<anonymous>|(.+?)\s+)?\((.+?):(\d+)(?::(\d+))?\)');
      final lines = stack.split('\n');
      
      // Busca la primera línea que contenga "package:" o ".dart"
      for (var line in lines) {
        final match = regex.firstMatch(line);
        if (match != null && (line.contains('package:') || line.contains('.dart'))) {
          return {
            'functionName': match.group(1)?.trim(),
            'fileName': match.group(2),
            'lineNumber': int.tryParse(match.group(3) ?? ''),
            'columnNumber': int.tryParse(match.group(4) ?? ''),
          };
        }
      }
    } catch (_) {
      // Si falla el parseo, retornamos vacío sin romper nada
    }
    return {};
  }

  // ─────────────────────────────────────────────
  // Métodos públicos para usar en toda la app
  // ─────────────────────────────────────────────

  Future<void> info(
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
  }) =>
      _sendLog(
        message: message,
        level: 'INFO',
        source: source,
        metadata: metadata,
      );

  Future<void> warning(
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
  }) =>
      _sendLog(
        message: message,
        level: 'WARNING',
        source: source,
        metadata: metadata,
      );

  Future<void> error(
    String message, {
    String? source,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) =>
      _sendLog(
        message: message,
        level: 'ERROR',
        source: source,
        errorMessage: error?.toString(),
        stackTrace: stackTrace?.toString(),
        metadata: metadata,
      );

  // Método para cerrar el cliente HTTP (útil en tests)
  void dispose() => _client.close();
}