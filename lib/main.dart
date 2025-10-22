//ruta: lib/main.dart
//descripción: Punto de entrada principal de la aplicación Flutter, configurando el tema y la pantalla inicial.

// import 'package:app_jht_front/core/network/http_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/welcome/presentation/pages/welcome_page.dart';
import 'features/login/presentation/bloc/login_bloc.dart';



void main() {
  // DevHttpClient.ignoreSslErrors(); // Ignorar errores SSL en desarrollo temporalmente

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginBloc()),
        // Aquí puedes agregar más Blocs en el futuro
      ],
      child: MaterialApp(
        title: 'JHT Transport', // Cambié el título para que coincida con tu app
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: WelcomePage.primaryColor),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const WelcomePage(), 
      ),
    );
  }
}