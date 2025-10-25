//Ruta: lib/features/conductor/presentation/pages/conductor_dashboard.dart
// OBJETIVO: Implementar la página del panel de conductor para usuarios con privilegios de conductor.

import 'package:flutter/material.dart';
import '../../../shared/presentation/pages/base_dashboard.dart';


class ConductorDashboard extends StatelessWidget {
  const ConductorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseDashboard(
      userName: 'Carlos López', // Esto vendría de tu estado
      userRole: 'Conductor', 
      nivelAcceso: 2,
    );
  }
}