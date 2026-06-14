//ruta: lib/features/welcome/presentation/pages/welcome_page.dart
//Objetivo: Página de bienvenida con diseño responsivo para web y móvil
import 'package:app_jht_front/features/login/presentation/bloc/login_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/welcome_wave_clip.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../login/presentation/pages/login_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  // Colores definidos
  static const Color primaryColor = Color(0xFFF9C4B7); 
  static const Color accentColor = Color.fromARGB(255, 34, 35, 90); // Azul oscuro de JHT

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Detecta si es una pantalla ancha (Web/Tablet)
        final isWebOrTablet = constraints.maxWidth > 600;

        return Scaffold(
          // Elimirnamos el Center y el Container limitador aquí. 
          // El Column debe ocupar todo el espacio.
          body: Column(
            children: [
              // 1. Sección Superior (Imagen con Onda) - Ocupa 100% del ancho
              _buildImageHeader(context, isWebOrTablet, constraints.maxHeight),
              
              // 2. Sección Inferior (Contenido de Texto y Botón) - Ocupa 100% del ancho restante
              Expanded(
                // Contenido de texto y botón con centrado horizontal condicional
                child: Center( // Usamos Center aquí para limitar el ancho del contenido del texto
                  child: Container(
                    // === NUEVA LIMITACIÓN DE ANCHO PARA EL CONTENIDO DE TEXTO ===
                    constraints: BoxConstraints(
                      maxWidth: isWebOrTablet ? 800 : constraints.maxWidth, // El texto se limita a 800px en web
                    ),
                    child: _buildTextAndButton(context, isWebOrTablet),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGET PARA EL HEADER (IMAGEN) ---
  // Ahora también pasamos la altura máxima del viewport para cálculos
  Widget _buildImageHeader(BuildContext context, bool isWebOrTablet, double totalHeight) {
    
    // Altura controlada: menor en web para dejar espacio al texto, mayor en móvil.
    final double headerHeight = isWebOrTablet 
        ? totalHeight * 0.40 // 40% de la altura de la ventana
        : totalHeight * 0.60; // 60% en móvil
    
    // Aseguramos un máximo de altura absoluta para web (para ventanas muy altas)
    final double maxHeight = isWebOrTablet ? 300 : headerHeight; 

    return SizedBox(
      height: maxHeight, 
      width: double.infinity, // Ocupa el 100% del ancho
      child: ClipPath(
        clipper: WelcomeWaveClipper(),
        child: Stack( 
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/welcome.png', 
                fit: BoxFit.cover,
              ),
            ),
            Container(
              color: primaryColor.withOpacity(0.0), 
            ),
          ],
        ),
      ),
    );
  }
  
  // --- WIDGET PARA TEXTO Y BOTÓN ---
  Widget _buildTextAndButton(BuildContext context, bool isWebOrTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isWebOrTablet ? 40.0 : 25.0, // Más padding en web
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Espacio superior para web
          if (isWebOrTablet) const SizedBox(height: 20),
          
          const Text(
            '¿Quiénes somos?', 
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(222, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '¡Welcome to \n JHT Transport Company!',
            style: TextStyle(
              fontSize: isWebOrTablet ? 36 : 30, 
              fontWeight: FontWeight.bold,
              color: accentColor,
              height: 1.2, 
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Soluciones de transporte confiables y eficientes para tus necesidades logísticas.',
            style: TextStyle(
              fontSize: 16,
              color: const Color.fromARGB(255, 29, 27, 27),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '¡Explora nuestra app mòvil o visita nuestra página web y descubre todo lo que podemos hacer por ti!',
            style: TextStyle(
              fontSize: 14,
              color: const Color.fromARGB(255, 29, 27, 27),
            ),
          ),

          const Spacer(), 

          // Botón "Continue"
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0), 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                child: IconButton(
                  padding: EdgeInsets.zero, 
                  icon: const Icon(FontAwesomeIcons.arrowRight, size: 20),
                  color: Colors.white,
                  onPressed: () {
                    context.go('/login');
                  },
                ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}