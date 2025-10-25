// Ruta: lib/features/admin/presentation/pages/admin_dashboard.dart
//Objetivo: Implementar la página del panel de administración para usuarios con privilegios de administrador.

import 'package:flutter/material.dart';
import '../../../shared/presentation/pages/base_dashboard.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseDashboard(
      userName: 'Juan Pérez', // Esto vendría de tu estado
      userRole: 'Administrador',
      nivelAcceso: 1,
    );
  }
}