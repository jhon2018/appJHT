// Ruta: lib/features/conductor/presentation/pages/conductor_dashboard.dart
// OBJETIVO: Página de dashboard para el conductor que utiliza BaseDashboard y obtiene datos del usuario desde TokenService.

import 'package:flutter/material.dart';
import '../../../shared/presentation/pages/base_dashboard.dart';
import '../../../../../../core/utils/token_service.dart';

class ConductorDashboard extends StatefulWidget {
  const ConductorDashboard({super.key});

  @override
  State<ConductorDashboard> createState() => _ConductorDashboardState();
}

class _ConductorDashboardState extends State<ConductorDashboard> {
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
          return BaseDashboard(
            userName: 'Usuario',
            userRole: 'Conductor',
            nivelAcceso: 2,
          );
        }

        final userData = snapshot.data!;
        return BaseDashboard(
          userName: userData['usuario'] ?? 'Usuario',
          userRole: userData['nivelAcceso'] == 1 ? 'Administrador' : 'Conductor',
          nivelAcceso: userData['nivelAcceso'] ?? 2,
        );
      },
    );
  }
}