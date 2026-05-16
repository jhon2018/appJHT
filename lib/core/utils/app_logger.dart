// Ruta: lib/core/utils/app_logger.dart
//
// Fachada estática de auditoría para toda la app JHT.
//
// PROPÓSITO:
//   Centralizar el acceso al RemoteLoggerService sin necesidad de instanciarlo
//   manualmente en cada clase. Uso simple desde cualquier parte del proyecto:
//
//     AppLogger.info('Pantalla cargada', source: 'HomeScreen');
//     AppLogger.error('Fallo en login', error: e, stackTrace: st);
//     AppLogger.critical('No se puede inicializar la app');
//
// REGLA:
//   - CRITICAL / ERROR  → siempre registrar (100%)
//   - WARNING           → registrar cuando algo puede degradarse (50%)
//   - INFO              → flujos importantes, no spam (30%)
//   - DEBUG             → solo en desarrollo, se ignora en producción (10%)

import 'package:app_jht_front/core/services/remote_logger_service.dart';

class AppLogger {
  // No instanciar — solo métodos estáticos
  AppLogger._();

  static final RemoteLoggerService _svc = RemoteLoggerService.instance;

  // ─── Ciclo de sesión ──────────────────────────────────────────────────────

  /// Registra el usuario activo y emite un INFO de inicio de sesión.
  /// Llamar justo después del login exitoso.
  static void setUser(String username) => _svc.setUser(username);

  /// Limpia la sesión activa y genera un nuevo sessionId.
  /// Llamar en logout para separar sesiones en los logs de Render.
  static void resetSession() => _svc.resetSession();

  // ─── Niveles de log ───────────────────────────────────────────────────────

  /// 🔵 INFO — flujo normal, acciones exitosas, pantallas cargadas.
  /// Ejemplo: 'Lista de vehículos cargada (12 registros)'
  static Future<void> info(
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
  }) =>
      _svc.info(message, source: source, metadata: metadata);

  /// 🟡 WARNING — algo sospechoso que no rompe la app pero merece atención.
  /// Ejemplo: 'Token próximo a expirar en 2 minutos'
  static Future<void> warning(
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
  }) =>
      _svc.warning(message, source: source, metadata: metadata);

  /// 🔴 ERROR — operación falló, el usuario fue afectado.
  /// Ejemplo: 'Fallo al registrar vehículo — HTTP 500'
  static Future<void> error(
    String message, {
    String?     source,
    Object?     error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) =>
      _svc.error(
        message,
        source:     source,
        error:      error,
        stackTrace: stackTrace,
        metadata:   metadata,
      );

  /// 🔴🔴 CRITICAL — fallo total, la app no puede continuar normalmente.
  /// Ejemplo: 'No se pudo inicializar la app — fallo en datos iniciales'
  static Future<void> critical(
    String message, {
    String?     source,
    Object?     error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) =>
      _svc.critical(
        message,
        source:     source,
        error:      error,
        stackTrace: stackTrace,
        metadata:   metadata,
      );

  /// ⚪ DEBUG — valores de variables, pasos intermedios.
  /// Se ignora completamente en producción (kReleaseMode).
  static Future<void> debug(
    String message, {
    String? source,
    Map<String, dynamic>? metadata,
  }) =>
      _svc.debug(message, source: source, metadata: metadata);

  // ─── Helpers de auditoría ─────────────────────────────────────────────────

  /// Registra el inicio de una operación HTTP importante.
  /// Ideal para llamadas a endpoints críticos.
  ///
  /// Ejemplo:
  ///   AppLogger.httpRequest('POST /api/general/registro_vehiculo',
  ///     source: 'VehiculoService');
  static Future<void> httpRequest(
    String endpoint, {
    String? source,
    Map<String, dynamic>? extraData,
  }) =>
      _svc.info(
        'HTTP → $endpoint',
        source: source,
        metadata: {'operation': 'HTTP_REQUEST', ...?extraData},
      );

  /// Registra el resultado de una operación HTTP.
  ///
  /// Ejemplo:
  ///   AppLogger.httpResponse('POST /api/general/registro_vehiculo',
  ///     statusCode: 200, durationMs: 342, source: 'VehiculoService');
  static Future<void> httpResponse(
    String endpoint, {
    required int statusCode,
    int?    durationMs,
    String? source,
    Map<String, dynamic>? extraData,
  }) {
    final message = 'HTTP ← $endpoint [$statusCode]'
        '${durationMs != null ? " (${durationMs}ms)" : ""}';

    final meta = <String, dynamic>{
      'operation':  'HTTP_RESPONSE',
      'statusCode': statusCode,
      if (durationMs != null) 'durationMs': durationMs,
      ...?extraData,
    };

    if (statusCode >= 500) {
      return _svc.error(message, source: source, metadata: meta);
    } else if (statusCode >= 400) {
      return _svc.warning(message, source: source, metadata: meta);
    } else {
      return _svc.info(message, source: source, metadata: meta);
    }
  }

  /// Registra navegación entre pantallas — útil para auditar flujos de usuario.
  ///
  /// Ejemplo:
  ///   AppLogger.navigation('HomeScreen', 'VehiculosScreen');
  static Future<void> navigation(
    String from,
    String to, {
    String? usuario,
  }) =>
      _svc.info(
        'Navegación: $from → $to',
        source: 'Navigator',
        metadata: {
          'operation': 'NAVIGATION',
          'from': from,
          'to': to,
          if (usuario != null) 'usuario': usuario,
        },
      );

  /// Registra acciones de auditoría explícitas (CRUD, permisos, etc.).
  ///
  /// Ejemplo:
  ///   AppLogger.audit('Vehículo registrado', action: 'CREATE',
  ///     entity: 'Vehiculo', entityId: '42');
  static Future<void> audit(
    String message, {
    required String action,   // CREATE, UPDATE, DELETE, READ
    String? entity,           // Vehiculo, Proveedor, Colaborador...
    String? entityId,
    String? source,
    Map<String, dynamic>? extraData,
  }) =>
      _svc.info(
        '[$action] $message',
        source: source,
        metadata: {
          'operation': 'AUDIT',
          'action':    action,
          if (entity   != null) 'entity':   entity,
          if (entityId != null) 'entityId': entityId,
          ...?extraData,
        },
      );
}
