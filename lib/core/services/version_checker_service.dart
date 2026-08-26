import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import 'package:app_jht_front/core/utils/app_logger.dart';

enum UpdateState {
  none,
  optional,
  mandatory,
}

class VersionInfo {
  final String version;
  final String? buildNumber;
  final String? minRequiredVersion;
  final bool forceUpdate;

  VersionInfo({
    required this.version,
    this.buildNumber,
    this.minRequiredVersion,
    this.forceUpdate = false,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      version: json['version'] as String? ?? '1.0.0',
      buildNumber: json['buildNumber']?.toString(),
      minRequiredVersion: json['minRequiredVersion'] as String?,
      forceUpdate: json['forceUpdate'] == true,
    );
  }
}

class VersionCheckerService {
  static final VersionCheckerService _instance = VersionCheckerService._internal();
  factory VersionCheckerService() => _instance;
  VersionCheckerService._internal();

  // El valor por defecto se obtiene en tiempo de compilación.
  static const String localVersion = String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');

  bool _isChecking = false;
  
  // Callback para notificar a la UI
  void Function(UpdateState state, VersionInfo remoteInfo, String localVersion)? onUpdateAvailable;

  Future<void> checkVersion() async {
    // Solo aplica para Web
    if (!kIsWeb) return;
    
    if (_isChecking) return;
    _isChecking = true;

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      // Obtener el origen actual (ej. https://dominio.com) para buscar el version.json en la raíz
      final origin = html.window.location.origin;
      final response = await http.get(
        Uri.parse('$origin/version.json?t=$timestamp'),
        headers: {
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final remoteInfo = VersionInfo.fromJson(json);

        final updateState = _evaluateUpdate(localVersion, remoteInfo);

        if (updateState != UpdateState.none) {
          AppLogger.info(
            'Nueva versión detectada',
            source: 'VersionCheckerService',
            metadata: {
              'local': localVersion,
              'remote': remoteInfo.version,
              'state': updateState.toString(),
            },
          );
          onUpdateAvailable?.call(updateState, remoteInfo, localVersion);
        }
      }
    } catch (e) {
      AppLogger.warning(
        'Error al verificar versión: $e',
        source: 'VersionCheckerService',
      );
      // No bloqueamos, solo ignoramos el error de red
    } finally {
      _isChecking = false;
    }
  }

  UpdateState _evaluateUpdate(String local, VersionInfo remoteInfo) {
    bool isNewer = _isVersionGreater(remoteInfo.version, local);
    if (!isNewer) return UpdateState.none;

    bool isMandatory = remoteInfo.forceUpdate;
    if (remoteInfo.minRequiredVersion != null && remoteInfo.minRequiredVersion!.isNotEmpty) {
      // Si minRequiredVersion es mayor que la version local, es obligatoria
      if (_isVersionGreater(remoteInfo.minRequiredVersion!, local)) {
        isMandatory = true;
      }
    }

    return isMandatory ? UpdateState.mandatory : UpdateState.optional;
  }

  // Retorna true si v1 > v2
  bool _isVersionGreater(String v1, String v2) {
    final v1Parts = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final v2Parts = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    
    for (int i = 0; i < 3; i++) {
      final p1 = i < v1Parts.length ? v1Parts[i] : 0;
      final p2 = i < v2Parts.length ? v2Parts[i] : 0;
      if (p1 > p2) return true;
      if (p1 < p2) return false;
    }
    return false;
  }

  Future<void> performUpdate() async {
    if (!kIsWeb) return;

    try {
      // 1. Eliminar Service Workers antiguos si los hay para que no bloqueen los nuevos JS
      final swRegistration = html.window.navigator.serviceWorker;
      if (swRegistration != null) {
        final registrations = await swRegistration.getRegistrations();
        for (final reg in registrations) {
          await reg.unregister();
        }
      }

      // 2. Limpiamos solo los cachés del navegador que pertenecen al Service Worker de Flutter si fuera necesario,
      // pero OMITIMOS esta limpieza indiscriminada de caches porque el service worker será
      // registrado de nuevo y NGINX ya está correctamente configurado para no cachear el service worker.
      
      // 3. Forzar recarga desde el servidor.
      // location.reload() hace que el navegador descargue el nuevo index.html
      // ya que nginx tiene reglas "no-cache" para él.
      html.window.location.reload();
    } catch (e) {
      AppLogger.critical(
        'Error durante la actualización (reload): $e',
        source: 'VersionCheckerService',
      );
      // Fallback
      html.window.location.reload();
    }
  }
}
