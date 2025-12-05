// lib/features/shared/presentation/pages/base_dashboard.dart
import 'package:app_jht_front/core/utils/token_service.dart';
import 'package:app_jht_front/features/shared/presentation/widgets/side_menu.dart';
import 'package:app_jht_front/features/supplier/data/datasources/supplier_remote_data_source.dart';
import 'package:app_jht_front/features/supplier/data/repositories/supplier_repository_impl.dart';
import 'package:app_jht_front/features/supplier/domain/usecases/registrar_supplier_usecase.dart';
import 'package:app_jht_front/features/supplier/presentation/bloc/supplier_bloc.dart';
import 'package:app_jht_front/features/vehicle/presentation/pages/vehicle_page.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:app_jht_front/features/vehicle/domain/usecases/registrar_vehiculo_usecase.dart';
import 'package:app_jht_front/features/vehicle/data/repositories/vehicle_repository_impl.dart';
import 'package:app_jht_front/features/vehicle/data/datasources/vehicle_remote_data_source.dart';
import 'package:app_jht_front/core/network/http_client.dart';

import 'package:app_jht_front/features/accessory/presentation/pages/accessory_page.dart';
import 'package:app_jht_front/features/supplier/presentation/pages/supplier_page.dart';

class BaseDashboard extends StatefulWidget {
  final String userName;
  final String userRole;

  const BaseDashboard({
    super.key,
    required this.userName,
    required this.userRole,
  });

  @override
  State<BaseDashboard> createState() => _BaseDashboardState();
}

class _BaseDashboardState extends State<BaseDashboard>
    with SingleTickerProviderStateMixin {
  bool _isMenuOpen = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Contenido principal
          _buildMainContent(),

          // Overlay oscuro
          if (_isMenuOpen) _buildOverlay(),

          // Menú lateral
          _buildSideMenu(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                // Header - ESTILO JHT TRANSPORT
                _buildHeader(),

                // Contenido
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'JHT TRANSPORT \n COMPANY',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF303366),
                letterSpacing: 1.0,
              ),
            ),

            InkWell(
              onTap: _toggleMenu,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
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
              'CONDUCTORES',
              'Gestión de conductores, licencias, capacitaciones y asignaciones.',
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

  Widget _buildOverlay() {
    return GestureDetector(
      onTap: _closeMenu,
      child: Container(color: Colors.black.withOpacity(0.5)),
    );
  }

  Widget _buildSideMenu() {
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
              _showNavigationMessage(itemTitle);
              _navigateToPage(itemTitle);
            },
          ),
        );
      },
    );
  }

  // FUNCIÓN QUE FALTABA - AGREGADA
  void _navigateToPage(String pageName) {
    switch (pageName) {
      case 'Vehículo':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (context) => SupplierBloc(
                // ← NUEVA INSTANCIA
                registrarSupplierUseCase: RegistrarSupplierUseCase(
                  repository: SupplierRepositoryImpl(
                    remoteDataSource: SupplierRemoteDataSourceImpl(
                      httpClient: DevHttpClient(),
                    ),
                  ),
                ),
              ),
              child: SupplierPage(
                userName: widget.userName,
                userRole: widget.userRole,
              ),
            ),
          ),
        );
        break;
      case 'Mantenimiento':
        // Navigator.push(context, MaterialPageRoute(builder: (_) => MaintenancePage()));
        _showNotImplementedMessage(pageName);
        break;
// En base_dashboard.dart
case 'Proveedor':
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => SupplierPage( // ← QUITA EL BlocProvider de aquí
        userName: widget.userName,
        userRole: widget.userRole,
      ),
    ),
  );
  break;
      case 'Conductores':
        // Navigator.push(context, MaterialPageRoute(builder: (_) => DriversPage()));
        _showNotImplementedMessage(pageName);
        break;
      case 'Accesorios':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AccessoryPage(
              userName: widget.userName,
              userRole: widget.userRole,
            ),
          ),
        );
        break;
      case 'Ayuda':
        // Navigator.push(context, MaterialPageRoute(builder: (_) => HelpPage()));
        _showNotImplementedMessage(pageName);
        break;
      default:
        _showNotImplementedMessage(pageName);
        //imprime en consola
        print('Navegación a $pageName no implementada.');
    }
  }

  void _showNotImplementedMessage(String pageName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$pageName - Página en desarrollo'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showNavigationMessage(String pageName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navegando a: $pageName'),
        backgroundColor: const Color(0xFF303366),
        duration: const Duration(seconds: 2),
      ),
    );
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
            '¿Estás seguro usuario ${widget.userName}? ¿que deseas cerrar sesión?',
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
            content: Text('Sesión cerrada correctamente'),
            backgroundColor: Color(0xFF303366),
            duration: Duration(seconds: 4),
          ),
        );
      });
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class MenuItem {
  final String icon;
  final String title;
  final bool enabled;

  MenuItem({required this.icon, required this.title, required this.enabled});
}
