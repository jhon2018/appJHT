// lib/features/shared/presentation/pages/base_dashboard.dart
import 'dart:ui';
import 'package:app_jht_front/core/network/http_client.dart';
import 'package:app_jht_front/core/utils/token_service.dart';
import 'package:app_jht_front/features/accessory/presentation/pages/accessory_page.dart';
import 'package:app_jht_front/features/conductor/data/datasources/conductor_remote_data_source.dart';
import 'package:app_jht_front/features/conductor/data/repositories/conductor_repository_impl.dart';
import 'package:app_jht_front/features/conductor/domain/usecases/actualizar_persona_usecase.dart';
import 'package:app_jht_front/features/conductor/domain/usecases/listar_personas_usecase.dart';
import 'package:app_jht_front/features/conductor/domain/usecases/obtener_persona_detalle_usecase.dart';
import 'package:app_jht_front/features/conductor/domain/usecases/registrar_conductor_usecase.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_bloc.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_event.dart';
import 'package:app_jht_front/features/conductor/presentation/pages/conductor_page.dart';
import 'package:app_jht_front/features/mantenimiento/data/repositories/mantenimiento_repository.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/bloc/mantenimiento_bloc.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/bloc/mantenimiento_event.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/pages/mantenimiento_page.dart';
import 'package:app_jht_front/features/shared/presentation/mixins/dashboard_responsive_mixin.dart';
import 'package:app_jht_front/features/supplier/presentation/pages/supplier_page.dart';
import 'package:app_jht_front/features/vehicle/data/datasources/vehicle_remote_data_source.dart';
import 'package:app_jht_front/features/vehicle/data/repositories/vehicle_repository_impl.dart';
import 'package:app_jht_front/features/vehicle/domain/usecases/actualizar_vehiculo_usecase.dart';
import 'package:app_jht_front/features/vehicle/domain/usecases/listar_vehiculos_usecase.dart';
import 'package:app_jht_front/features/vehicle/domain/usecases/registrar_vehiculo_usecase.dart';
import 'package:app_jht_front/features/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:app_jht_front/features/vehicle/presentation/pages/vehicle_page.dart';
import 'package:app_jht_front/features/accessory/presentation/bloc/accessory_bloc.dart';
import 'package:app_jht_front/features/accessory/domain/repositories/accessory_repository_impl.dart';
import 'package:app_jht_front/features/accessory/data/datasources/accessory_remote_data_source.dart';
import 'package:flutter/material.dart';
import 'package:app_jht_front/core/widgets/app_notification.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/side_menu.dart';
import '../widgets/scaffold_with_menu.dart';
import 'package:app_jht_front/features/shared/presentation/mixins/navigation_helper_mixin.dart';

class BaseDashboard extends StatefulWidget {
  final String userName;
  final String userRole;
  final Widget Function(BuildContext, bool isDesktop)? contentBuilder;

  const BaseDashboard({
    super.key,
    required this.userName,
    required this.userRole,
    this.contentBuilder, // ← AHORA ES OPCIONAL
  });

  @override
  State<BaseDashboard> createState() => _BaseDashboardState();
}

class _BaseDashboardState extends State<BaseDashboard>
    with SingleTickerProviderStateMixin, DashboardResponsiveMixin, NavigationHelperMixin<BaseDashboard> {
  bool _isMenuOpen = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: -300, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _closeMenu() {
    setState(() {
      _isMenuOpen = false;
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktopDevice = isDesktop(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildMainContent(isDesktopDevice),
    );
  }

  Widget _buildMainContent(bool isDesktopDevice) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildHeader(isDesktopDevice),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(isDesktopDevice ? 24 : 16),
              child: widget.contentBuilder != null
                  ? widget.contentBuilder!(context, isDesktopDevice)
                  : _buildDefaultContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDesktopDevice) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktopDevice ? 32 : 20,
        vertical: isDesktopDevice ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(bottom: BorderSide(color: Colors.grey[100]!, width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'JHT TRANSPORT',
                  style: TextStyle(
                    fontSize: isDesktopDevice ? 20 : 16,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF303366),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'COMPANY',
                  style: TextStyle(
                    fontSize: isDesktopDevice ? 12 : 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4834D4),
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (isDesktopDevice) ...[
                  Text(
                    'Bienvenido, ${widget.userName}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ] else ...[
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        final scaffoldState = context.findAncestorStateOfType<ScaffoldWithMenuState>();
                        scaffoldState?.openMobileMenu();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF303366).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.menu_rounded,
                          color: Color(0xFF303366),
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ DASHBOARD GENÉRICO POR DEFECTO (cuando se usa BaseDashboard directamente)
  Widget _buildDefaultContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Text(
            'DASHBOARD',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: 1.2,
            ),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildCategoryCard(
              'MANTENIMIENTO',
              'Gestión y control de mantenimiento preventivo y correctivo de la flota vehicular.',
              const Color(0xFF303366),
            ),
            _buildCategoryCard(
              'VEHÍCULOS',
              'Administración completa de la flota vehicular, seguros y documentación.',
              const Color(0xFF4CAF50),
            ),
            _buildCategoryCard(
              'COLABORADORES',
              'Gestión de colaboradores, licencias, capacitaciones y asignaciones.',
              const Color(0xFF2196F3),
            ),
            _buildCategoryCard(
              'REPORTES',
              'Generación de reportes operativos, financieros y de desempeño.',
              const Color(0xFFFF9800),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'ESTADÍSTICAS RÁPIDAS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildStatCard('Vehículos Activos', '24', Icons.directions_car),
            _buildStatCard('Viajes Hoy', '8', Icons.assignment),
            _buildStatCard('Mantenimientos', '3', Icons.build),
            _buildStatCard('Alertas', '2', Icons.warning),
          ],
        ),
        const SizedBox(height: 40),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey[300]!, width: 3)),
          ),
          child: Column(
            children: [
              Text(
                '© ${DateTime.now().year} JHT Transport Company',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'All rights reserved.',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String title, String description, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF303366)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF303366),
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildDesktopSideMenu() {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_isMenuOpen ? 0 : -280, 0),
            child: SideMenu(
              userName: widget.userName,
              userRole: widget.userRole,
              onClose: _closeMenu,
              onItemSelected: (itemTitle) {
                _closeMenu();
                _navigateToPage(itemTitle);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileSideMenu() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: SideMenu(
            userName: widget.userName,
            userRole: widget.userRole,
            onClose: _closeMenu,
            onItemSelected: (itemTitle) {
              _closeMenu();
              _navigateToPage(itemTitle);
            },
          ),
        );
      },
    );
  }

  Widget _buildOverlay() {
    return GestureDetector(
      onTap: _closeMenu,
      child: Container(color: Colors.black.withOpacity(0.5)),
    );
  }

  // ✅ FUNCIÓN DE NAVEGACIÓN (Usa el mixin centralizado)
  void _navigateToPage(String pageName) {
    navigateToMenuPage(context, pageName, widget.userName, widget.userRole);
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Cerrar Sesión',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF303366),
            ),
          ),
          content: Text(
            '¿Estás seguro usuario ${widget.userName}? ¿deseas cerrar sesión?',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _performRealLogout(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF303366),
              ),
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _performRealLogout(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await TokenService.deleteToken();
      navigator.pushNamedAndRemoveUntil('/login', (route) => false);

      Future.delayed(const Duration(milliseconds: 100), () {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('✅ Sesión cerrada correctamente'),
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('❌ Error al cerrar sesión: $e'),
          backgroundColor: Color(0xFFC62828),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}