//ruta: lib/features/welcome/presentation/pages/welcome_page.dart
//Objetivo: Página de bienvenida con diseño responsivo para web y móvil
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/welcome_wave_clip.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
        // Detecta si es una pantalla corta en altura (ej. iPhone SE, Galaxy S8)
        final isCompactHeight = constraints.maxHeight < 750;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight, // Ocupa al menos el 100% de la pantalla
                ),
                child: IntrinsicHeight( // Permite que Spacer funcione dentro del scroll
                  child: Column(
                    children: [
                      // 1. Sección Superior (Imagen con Onda)
                      _buildImageHeader(context, isWebOrTablet, constraints.maxHeight, isCompactHeight),
                      
                      // 2. Sección Inferior (Contenido de Texto y Botón)
                      Expanded(
                        child: Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: isWebOrTablet ? 800 : constraints.maxWidth,
                            ),
                            child: _buildTextAndButton(context, isWebOrTablet, isCompactHeight),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET PARA EL HEADER (IMAGEN) ---
  Widget _buildImageHeader(BuildContext context, bool isWebOrTablet, double totalHeight, bool isCompactHeight) {
    
    // Altura dinámica: reducimos drásticamente en móviles pequeños para evitar que empuje el contenido.
    final double headerHeight = isWebOrTablet 
        ? totalHeight * 0.40 
        : (isCompactHeight ? totalHeight * 0.35 : totalHeight * 0.45); 
    
    // Máximos y mínimos para garantizar consistencia visual
    final double maxHeight = isWebOrTablet ? 300 : headerHeight.clamp(160.0, 360.0); 

    return SizedBox(
      height: maxHeight, 
      width: double.infinity,
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
  Widget _buildTextAndButton(BuildContext context, bool isWebOrTablet, bool isCompactHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isWebOrTablet ? 40.0 : (isCompactHeight ? 20.0 : 25.0), 
        vertical: isCompactHeight ? 5.0 : 10.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isWebOrTablet) const SizedBox(height: 20),
          
          Text(
            '¿Quiénes somos?', 
            style: TextStyle(
              fontSize: isCompactHeight ? 15 : 18,
              fontWeight: FontWeight.w500,
              color: const Color.fromARGB(222, 0, 0, 0),
            ),
          ),
          SizedBox(height: isCompactHeight ? 4 : 6),
          Text(
            '¡Welcome to \n JHT Transport Company!',
            style: TextStyle(
              fontSize: isWebOrTablet ? 36 : (isCompactHeight ? 26 : 30), 
              fontWeight: FontWeight.bold,
              color: accentColor,
              height: 1.2, 
            ),
          ),
          SizedBox(height: isCompactHeight ? 8 : 10),
          Text(
            'Soluciones de transporte confiables y eficientes para tus necesidades logísticas.',
            style: TextStyle(
              fontSize: isCompactHeight ? 14 : 16,
              color: const Color.fromARGB(255, 29, 27, 27),
            ),
          ),
          SizedBox(height: isCompactHeight ? 12 : 20),
          Text(
            '¡Explora nuestra app móvil o visita nuestra página web y descubre todo lo que podemos hacer por ti!',
            style: TextStyle(
              fontSize: isCompactHeight ? 13 : 14,
              color: const Color.fromARGB(255, 29, 27, 27),
            ),
          ),

          const Spacer(), 

          // Botón "Continue"
          SafeArea(
            top: false, // Solo aseguramos los bordes inferiores/laterales
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isCompactHeight ? 15.0 : 20.0, 
                top: 15.0
              ), 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        context.go('/login');
                      },
                      borderRadius: BorderRadius.circular(30),
                      splashColor: accentColor.withOpacity(0.3),
                      hoverColor: accentColor.withOpacity(0.1),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            )
                          ]
                        ),
                        child: const Center(
                          child: Icon(
                            FontAwesomeIcons.arrowRight, 
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}