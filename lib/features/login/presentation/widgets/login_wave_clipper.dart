//ruta: lib/features/login/presentation/widgets/login_wave_clip.dart
//descripción: Clase que define un clipper personalizado para crear una forma de onda en la pantalla de login.

import 'package:flutter/material.dart';

class LoginWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    
    // 1. Inicia en la esquina superior izquierda (0, 0)
    path.lineTo(0, 0); 
    
    // 2. Traza la línea recta vertical hasta donde empieza la onda (aprox 75% de la altura)
    path.lineTo(0, size.height * 0.75); 
    
    // 3. Primer punto de control de la curva (Curva descendente)
    final firstControlPoint = Offset(size.width / 4, size.height * 0.85);
    final firstEndPoint = Offset(size.width / 2, size.height * 0.75);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    
    // 4. Segundo punto de control de la curva (Curva ascendente)
    final secondControlPoint = Offset(size.width * 3 / 4, size.height * 0.65);
    final secondEndPoint = Offset(size.width, size.height * 0.75);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    
    // 5. Línea recta hasta la esquina superior derecha
    path.lineTo(size.width, 0);
    
    // Cierra el path
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

