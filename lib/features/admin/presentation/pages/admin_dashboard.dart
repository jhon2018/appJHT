// Ruta: lib/features/admin/presentation/pages/admin_dashboard.dart
// OBJETIVO: Página de dashboard para el administrador que utiliza BaseDashboard y obtiene datos del usuario desde TokenService.

import 'package:flutter/material.dart';
import '../../../shared/presentation/pages/base_dashboard.dart';
import '../../../../../../core/utils/token_service.dart'; // Ajusta la ruta según tu estructura

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Future<Map<String, dynamic>?> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = TokenService.getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          // Fallback seguro si no hay datos
          return BaseDashboard(
            userName: 'Usuario',
            userRole: 'Administrador', 
            nivelAcceso: 1,
          );
        }

        final userData = snapshot.data!;
        return BaseDashboard(
          userName: userData['usuario'] ?? 'Usuario',
          userRole: userData['nivelAcceso'] == 1 ? 'Administrador' : 'Conductor',
          nivelAcceso: userData['nivelAcceso'] ?? 1,
        );
      },
    );
  }
}