// ruta: lib/features/login/presentation/widgets/login_wave_clipper.dart
// descripción: Clases que definen clippers personalizados para crear formas de onda dinámicas y modernas en la pantalla de login.

import 'package:flutter/material.dart';

/// Clipper principal con una curva pronunciada, asimétrica y elegante
class LoginWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Inicia un poco más abajo para dar espacio a una curva profunda
    path.lineTo(0, size.height * 0.70);

    // Primera curva: Descenso profundo y suave
    final firstControlPoint = Offset(size.width * 0.20, size.height);
    final firstEndPoint = Offset(size.width * 0.55, size.height * 0.80);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    // Segunda curva: Ascenso hacia el borde derecho
    final secondControlPoint = Offset(size.width * 0.85, size.height * 0.60);
    final secondEndPoint = Offset(size.width, size.height * 0.85);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

/// Clipper secundario para crear un efecto de superposición (Layering) y profundidad
class LoginWaveClipperSecondary extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Inicia un poco más abajo que la onda principal para que se asome por detrás
    path.lineTo(0, size.height * 0.85);

    // Curva más amplia y estirada
    final firstControlPoint = Offset(size.width * 0.35, size.height * 1.05);
    final firstEndPoint = Offset(size.width * 0.65, size.height * 0.70);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    // Curva ascendente más pronunciada al final
    final secondControlPoint = Offset(size.width * 0.85, size.height * 0.50);
    final secondEndPoint = Offset(size.width, size.height * 0.65);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
