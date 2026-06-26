// Ruta: lib/main.dart

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Pages
import 'package:app_jht_front/features/welcome/presentation/pages/welcome_page.dart';
import 'package:app_jht_front/features/login/presentation/pages/login_page.dart';
import 'package:app_jht_front/features/home/presentation/pages/home_page.dart';

// Blocs
import 'package:app_jht_front/features/login/presentation/bloc/login_bloc.dart';

// Auditoría
import 'package:app_jht_front/core/utils/app_logger.dart';

import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:app_jht_front/core/router/app_router.dart';

void main() {
  // Configurar estrategia de URL para Web (quita el # de la URL)
  usePathUrlStrategy();
  
  // ── FIX: ensureInitialized DENTRO de runZonedGuarded ─────────────────────
  // Si se llama FUERA, Flutter crea los bindings en el zone raíz.
  // Luego runApp corre en el zone de runZonedGuarded → "Zone mismatch".
  // La solución es que ambos (ensureInitialized y runApp) corran en el mismo zone.
  runZonedGuarded(
    () {
      // 1. Inicializar bindings dentro del zone correcto
      WidgetsFlutterBinding.ensureInitialized();

      // 2. Captura de errores del framework Flutter
      FlutterError.onError = (FlutterErrorDetails details) {
        // Ignorar el "Zone mismatch" que generábamos nosotros mismos
        // para no llenar el log con falsos críticos
        final msg = details.exceptionAsString();
        if (msg.contains('Zone mismatch')) return;

        try {
          AppLogger.critical(
            'Flutter Error — ${details.exceptionAsString()}',
            source: 'FlutterError',
            error: details.exception,
            stackTrace: details.stack,
            metadata: {
              'library': details.library ?? 'desconocida',
              'context': details.context?.toDescription() ?? '',
              'silent':  details.silent,
            },
          );
        } catch (_) {}

        FlutterError.presentError(details);
      };

      // 3. Captura de errores de plataforma / isolates
      PlatformDispatcher.instance.onError = (error, stack) {
        try {
          AppLogger.critical(
            'Platform Error — $error',
            source: 'PlatformDispatcher',
            error: error,
            stackTrace: stack,
            metadata: {'type': error.runtimeType.toString()},
          );
        } catch (_) {}
        return true;
      };

      // 4. Log de arranque
      AppLogger.info(
        'App JHT iniciada',
        source: 'main',
        metadata: {
          'mode':     kReleaseMode ? 'release' : kProfileMode ? 'profile' : 'debug',
          'platform': kIsWeb ? 'web' : 'mobile',
        },
      );

      runApp(const MyApp());
    },
    (error, stackTrace) {
      try {
        AppLogger.critical(
          'Error async no controlado — $error',
          source: 'ZoneGuard',
          error: error,
          stackTrace: stackTrace,
          metadata: {'type': error.runtimeType.toString()},
        );
      } catch (_) {}
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// MyApp
// ─────────────────────────────────────────────────────────────────────────────
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.setUser('anonimo');

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginBloc()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'JHT Transport',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: WelcomePage.primaryColor,
          ),
          useMaterial3: true,
          fontFamily: 'Inter',
        ),
        builder: (context, child) {
          // Envolvemos en un Overlay para que SelectionArea encuentre un ancestro Overlay
          return Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) => SelectionArea(
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ],
          );
        },
        routeInformationProvider: appRouter.routeInformationProvider,
        routeInformationParser: appRouter.routeInformationParser,
        routerDelegate: appRouter.routerDelegate,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
          Locale('en', 'US'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Observer de navegación mejorado
//
// Mejoras vs versión anterior:
// 1. Solo registra rutas con NOMBRE — los modales y diálogos anónimos
//    se ignoran para no saturar el log con "(sin nombre)".
// 2. Anti-spam: no repite el mismo par from→to dentro de 500ms.
// 3. Extrae el nombre del widget cuando la ruta no tiene nombre registrado
//    pero el route settings tiene argumento descriptivo.
// ─────────────────────────────────────────────────────────────────────────────
class _JhtNavigatorObserver extends NavigatorObserver {

  // Último log de navegación — evita duplicados en ráfagas
  String _lastNav  = '';
  DateTime _lastTs = DateTime(2000);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log('PUSH', to: route, from: previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log('POP', to: previousRoute, from: route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _log('REPLACE', to: newRoute, from: oldRoute);
  }

  void _log(String action, {Route<dynamic>? to, Route<dynamic>? from}) {
    try {
      final toName   = _routeName(to);
      final fromName = _routeName(from);

      // ── Regla 1: ignorar si ambos son anónimos (modales, diálogos)
      if (toName == null && fromName == null) return;

      // ── Regla 2: usar el nombre conocido; si uno es null, usar etiqueta
      final toLabel   = toName   ?? '[modal/dialog]';
      final fromLabel = fromName ?? '[modal/dialog]';

      // ── Regla 3: anti-spam — ignorar si es el mismo evento en < 500ms
      final key = '$action|$fromLabel→$toLabel';
      final now = DateTime.now();
      if (key == _lastNav && now.difference(_lastTs).inMilliseconds < 500) return;
      _lastNav = key;
      _lastTs  = now;

      AppLogger.navigation(fromLabel, toLabel, usuario: action);
    } catch (_) {}
  }

  /// Devuelve el nombre de la ruta o null si es anónima.
  String? _routeName(Route<dynamic>? route) {
    if (route == null) return null;
    final name = route.settings.name;
    // Excluir rutas sin nombre y la raíz interna de Flutter
    if (name == null || name.isEmpty || name == 'flutter') return null;
    return name;
  }
}