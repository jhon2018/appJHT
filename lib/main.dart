// Ruta: lib/main.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Pages
import 'package:app_jht_front/features/welcome/presentation/pages/welcome_page.dart';
import 'package:app_jht_front/features/login/presentation/pages/login_page.dart';
import 'package:app_jht_front/features/home/presentation/pages/home_page.dart';

// Blocs
import 'package:app_jht_front/features/login/presentation/bloc/login_bloc.dart';

// Logger
import 'core/services/remote_logger_service.dart';

void main() {
  final logger = RemoteLoggerService.instance;

  // ✅ 1. Inicialización temprana de auditoría
  _setupGlobalErrorHandling(logger);

  // ✅ 2. Ejecutar app dentro del Zone (CRÍTICO)
  runZonedGuarded(
    () {
      // 📊 Log de arranque (clave para auditoría en Render)
      logger.info(
        '🚀 App started',
        source: 'app_lifecycle',
        metadata: <String, dynamic>{
          'env': kReleaseMode ? 'release' : 'debug',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      runApp(const MyApp());
    },
    (error, stackTrace) {
      try {
        logger.error(
          '💥 Uncaught Async Error',
          source: 'zone_guard',
          error: error,
          stackTrace: stackTrace,
        );
      } catch (_) {}
    },
  );
}

/// 🔐 Manejo global de errores (seguro)
void _setupGlobalErrorHandling(RemoteLoggerService logger) {
  FlutterError.onError = (FlutterErrorDetails details) {
    try {
      logger.error(
        '💥 Flutter Error',
        source: 'flutter_framework',
        error: details.exception,
        stackTrace: details.stack,
        metadata: <String, dynamic>{
          'library': details.library?.toString(),
          'context': details.context?.toString(),
        },
      );
    } catch (_) {}

    // 🔁 Mantiene comportamiento original (NO romper flujo)
    FlutterError.presentError(details);
  };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = RemoteLoggerService.instance;

    // ✅ Usuario por defecto (auditoría)
    logger.setUser('anonimo');

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginBloc()),
        // ... tus demás blocs
      ],
      child: MaterialApp(
        title: 'JHT Transport',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: WelcomePage.primaryColor,
          ),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,

        // ✅ LOCALIZACIÓN EN ESPAÑOL (DatePicker, TimePicker, etc.)
        locale: const Locale('es', 'ES'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
          Locale('en', 'US'),
        ],

        // ✅ AUDITORÍA DE NAVEGACIÓN (MUY IMPORTANTE)
        navigatorObservers: [
          _AppNavigatorObserver(logger),
        ],

        routes: {
          '/welcome': (context) => const WelcomePage(),
          '/login': (context) => LoginPage(),
          '/home': (context) => HomePage(),
        },
        initialRoute: '/welcome',
      ),
    );
  }
}

//
// 📊 OBSERVER DE NAVEGACIÓN (CLAVE PARA RENDER)
//
class _AppNavigatorObserver extends NavigatorObserver {
  final RemoteLoggerService logger;

  _AppNavigatorObserver(this.logger);

  @override
  void didPush(Route route, Route? previousRoute) {
    _logNavigation('PUSH', route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _logNavigation('POP', route, previousRoute);
  }

  void _logNavigation(String action, Route route, Route? previousRoute) {
    try {
      logger.info(
        '🧭 Navigation $action',
        source: 'navigation',
        metadata: <String, dynamic>{
          'to': route.settings.name,
          'from': previousRoute?.settings.name,
        },
      );
    } catch (_) {}
  }
}