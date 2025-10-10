//ruta: lib/main.dart
//descripción: Punto de entrada principal de la aplicación Flutter, configurando el tema y la pantalla inicial.

import 'package:flutter/material.dart';
import 'features/welcome/presentation/pages/welcome_page.dart';
// import 'core/di/injection_container.dart'; // Si ya tienes la inyección lista

void main() {
  // initDependencies(); // Llamada a tu función de inyección
  runApp(const MyApp());
}

// ... (código previo)

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Clean Arch',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: WelcomePage.primaryColor),
        useMaterial3: true,
      ),
      // === SOLUCIÓN 2: Desactivar la etiqueta de debug ===
      debugShowCheckedModeBanner: false, // <-- ¡Agrega esta línea!
      // ==================================================
      home: const WelcomePage(), 
    );
  }
}