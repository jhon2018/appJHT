// Ruta: lib/core/services/remote_logger_service.dart
//
// Servicio Singleton de logging remoto.
// Envía logs de auditoría al backend JHT para visualizarlos en Render.
//
// Uso básico:
//   final log = RemoteLoggerService.instance;
//   log.info('Pantalla cargada', source: 'HomeScreen');
//   log.warning('Token próximo a expirar', source: 'AuthBloc');
//   log.error('Fallo en login', error: e, stackTrace: st, source: 'LoginBloc');
//   log.critical('App en estado irrecuperable', source: 'main');

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:app_jht_front/features/config/environment_config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────────
// Niveles de log disponibles
// ─────────────────────────────────────────────────────────────────────────────
enum LogLevel {
  debug,    // ⚪ 10% — solo desarrollo, valores de variables
  info,     // 🔵 30% — flujo normal importante
  warning,  // 🟡 50% — algo sospechoso, puede degradarse
  error,    // 🔴 100% — operación falló completamente
  critical, // 🔴🔴 100% — app rota, datos perdidos, fallo total
}

extension LogLevelExt on LogLevel {
  String get value => name.toUpperCase();
}

// ─────────────────────────────────────────────────────────────────────────────
// RemoteLoggerService
// ─────────────────────────────────────────────────────────────────────────────
class RemoteLoggerService {
  // Singleton
  static final RemoteLoggerService _instance = RemoteLoggerService._internal();
  static RemoteLoggerService get instance => _instance;
  factory RemoteLoggerService() => _instance;
  RemoteLoggerService._internal();

  // URL del endpoint de logs en el backend JHT
  final String _logsUrl = '${EnvironmentConfig.apiUrl}/logs';

  // Cliente HTTP reutilizable
  final http.Client _client = http.Client();

  // Estado de sesión
  String? _sessionId;
  String? _currentUser;

  // ─── Session ──────────────────────────────────────────────────────────────

  /// Genera un sessionId único para correlacionar logs de una misma sesión.
  String get sessionId {
    _sessionId ??= _generateSessionId();
    return _sessionId!;
  }

  /// Registra el usuario activo — llamar después del login exitoso.
  void setUser(String username) {
    _currentUser = username;
    // Log implícito: el auditor sabe quién inició sesión
    info(
      'Sesión iniciada para el usuario "$username"',
      source: 'RemoteLoggerService',
      metadata: {'action': 'LOGIN'},
    );
  }

  /// Limpia la sesión — llamar en logout para que la próxima sesión
  /// tenga un sessionId diferente y se pueda rastrear por separado.
  void resetSession() {
    _currentUser = null;
    _sessionId   = _generateSessionId();
  }

  // ─── API pública ──────────────────────────────────────────────────────────

  /// 🔵 INFO — flujo normal, pantallas cargadas, acciones exitosas.
  Future<void> info(
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
  }) =>
      _send(
        message:  message,
        level:    LogLevel.info,
        source:   source,
        metadata: metadata,
      );

  /// 🟡 WARNING — situación sospechosa, no es un error pero puede serlo pronto.
  Future<void> warning(
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
  }) =>
      _send(
        message:  message,
        level:    LogLevel.warning,
        source:   source,
        metadata: metadata,
      );

  /// 🔴 ERROR — operación falló, el usuario fue afectado.
  Future<void> error(
    String message, {
    String?      source,
    Object?      error,
    StackTrace?  stackTrace,
    Map<String, dynamic>? metadata,
  }) =>
      _send(
        message:      message,
        level:        LogLevel.error,
        source:       source,
        errorObject:  error,
        stackTrace:   stackTrace,
        metadata:     metadata,
      );

  /// 🔴🔴 CRITICAL — fallo total, estado irrecuperable, pérdida de datos.
  /// Usar cuando la app no puede continuar funcionando normalmente.
  Future<void> critical(
    String message, {
    String?      source,
    Object?      error,
    StackTrace?  stackTrace,
    Map<String, dynamic>? metadata,
  }) =>
      _send(
        message:      message,
        level:        LogLevel.critical,
        source:       source,
        errorObject:  error,
        stackTrace:   stackTrace,
        metadata:     metadata,
      );

  /// ⚪ DEBUG — solo visible en modo desarrollo, nunca en producción.
  Future<void> debug(
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
  }) {
    // En Release ignoramos completamente los DEBUG para no saturar Render
    if (kReleaseMode) return Future.value();
    return _send(
      message:  message,
      level:    LogLevel.debug,
      source:   source,
      metadata: metadata,
    );
  }

  // ─── Internos ─────────────────────────────────────────────────────────────

  Future<void> _send({
    required String   message,
    required LogLevel level,
    String?           source,
    Object?           errorObject,
    StackTrace?       stackTrace,
    Map<String, dynamic>? metadata,
  }) async {
    // Imprimir en consola local durante desarrollo
    if (!kReleaseMode) {
      final prefix = _consolePrefix(level);
      debugPrint('$prefix [${level.value}] $message');
    }

    try {
      // StackTrace SOLO en ERROR y CRITICAL — no saturar con ruido
      final bool needsStack = level == LogLevel.error || level == LogLevel.critical;
      final String? rawStack = needsStack
          ? (stackTrace?.toString() ?? StackTrace.current.toString())
          : null;

      final parsed    = rawStack != null ? _parseStackTrace(rawStack) : <String, dynamic>{};
      final errorType = errorObject != null ? errorObject.runtimeType.toString() : null;

      final body = <String, dynamic>{
        'message':       message,
        'level':         level.value,
        'source':        source ?? 'Flutter',
        'usuario':       _currentUser ?? 'anonimo',
        'sessionId':     sessionId,
        'timestamp':     DateTime.now().toIso8601String(),
        // Error
        'errorMessage':  errorObject?.toString(),
        'errorType':     errorType,
        'stackTrace':    rawStack,
        // Ubicación (solo si hay stack)
        'fileName':      (parsed['fileName'] as String?)?.toString(),
        'lineNumber':    parsed['lineNumber'] as int?,
        'columnNumber':  parsed['columnNumber'] as int?,
        'functionName':  (parsed['functionName'] as String?)?.toString(),
        // Metadata personalizada
        'metadata':      metadata != null ? Map<String, dynamic>.from(metadata) : null,
      };

      // Fire & Forget — no bloquea la UI
      unawaited(
        _client
            .post(
              Uri.parse(_logsUrl),
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 5))
            .catchError((_) {
              // Silenciar errores de red — el logger NUNCA debe romper la app
            }),
      );
    } catch (_) {
      // Doble protección — el logger nunca propaga excepciones
    }
  }

  /// Parsea el stack trace de Dart para extraer archivo, línea y función.
  /// Formato: #1  MyClass.myMethod (package:my_app/file.dart:45:12)
  Map<String, dynamic> _parseStackTrace(String stack) {
    try {
      final regex = RegExp(
        r'#\d+\s+(?:<anonymous>|(.+?)\s+)?\((.+?):(\d+)(?::(\d+))?\)',
      );
      for (final line in stack.split('\n')) {
        final match = regex.firstMatch(line);
        if (match != null && (line.contains('package:') || line.contains('.dart'))) {
          return {
            'functionName': match.group(1)?.trim(),
            'fileName':     match.group(2),
            'lineNumber':   int.tryParse(match.group(3) ?? ''),
            'columnNumber': int.tryParse(match.group(4) ?? ''),
          };
        }
      }
    } catch (_) {
      // Si falla el parseo, retornamos vacío sin romper nada
    }
    return {};
  }

  String _generateSessionId() {
    final rnd = Random.secure();
    final ts  = DateTime.now().millisecondsSinceEpoch;
    final rndPart = rnd.nextInt(999999).toString().padLeft(6, '0');
    return 'sess_${ts}_$rndPart';
  }

  String _consolePrefix(LogLevel level) => switch (level) {
    LogLevel.critical => '🔴🔴',
    LogLevel.error    => '🔴',
    LogLevel.warning  => '🟡',
    LogLevel.debug    => '⚪',
    _                 => '🔵',
  };

  /// Liberar recursos — útil en tests o al cerrar la app.
  void dispose() => _client.close();
}