//ruta: lib/main.dart
//descripción: Punto de entrada principal de la aplicación Flutter, configurando el tema y la pantalla inicial.

// import 'package:app_jht_front/core/network/http_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/welcome/presentation/pages/welcome_page.dart';
import 'features/login/presentation/bloc/login_bloc.dart';
import 'features/login/presentation/pages/login_page.dart';
import 'features/home/presentation/pages/home_page.dart';



void main() {
  // DevHttpClient.ignoreSslErrors(); // Ignorar errores SSL en desarrollo temporalmente

  runApp(const MyApp());
}

// En tu main.dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginBloc()),
      ],
      child: MaterialApp(
        title: 'JHT Transport',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: WelcomePage.primaryColor),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        
        // AGREGAR ESTAS RUTAS:
        routes: {
          '/welcome': (context) => const WelcomePage(),
          '/login': (context) => LoginPage(), // ← Asegúrate de tener esta importación
          '/home': (context) => HomePage(),   // ← Necesitas crear esta página
        },
        initialRoute: '/welcome',
      ),
    );
  }
}