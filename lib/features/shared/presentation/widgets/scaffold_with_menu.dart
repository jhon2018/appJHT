// lib/features/shared/presentation/widgets/scaffold_with_menu.dart
import 'package:flutter/material.dart';
import 'package:app_jht_front/core/utils/token_service.dart';
import 'side_menu.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithMenu extends StatefulWidget {
  final Widget child;

  const ScaffoldWithMenu({super.key, required this.child});

  @override
  State<ScaffoldWithMenu> createState() => ScaffoldWithMenuState();
}

class ScaffoldWithMenuState extends State<ScaffoldWithMenu> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _userName = 'Usuario';
  String _userRole = 'Rol';
  bool _isLoading = true;
  bool _isMenuVisible = true; // <-- Control visibility for Desktop

  bool get isMenuVisible => _isMenuVisible;

  void toggleMenu() {
    if (mounted) {
      setState(() {
        _isMenuVisible = !_isMenuVisible;
      });
    }
  }

  void openMobileMenu() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await TokenService.getUserData();
    if (mounted) {
      setState(() {
        _userName = userData?['usuario'] ?? 'Usuario';
        _userRole = userData?['cargo'] ?? 'Conductor';
        _isLoading = false;
      });
    }
  }

  void _onMenuItemSelected(String pageName) {
    if (pageName == 'Panel') {
      context.go('/dashboard');
    } else if (pageName == 'Vehículo') {
      context.go('/vehiculos');
    } else if (pageName == 'Mantenimiento') {
      context.go('/mantenimiento');
    } else if (pageName == 'Proveedor') {
      context.go('/proveedores');
    } else if (pageName == 'Colaboradores') {
      context.go('/colaboradores');
    } else if (pageName == 'Accesorios') {
      context.go('/accesorios');
    } else if (pageName == 'Ayuda') {
      context.go('/ayuda');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 800;

        return Scaffold(
          key: _scaffoldKey,
          drawer: !isDesktop
              ? Drawer(
                  child: SideMenu(
                    userName: _userName,
                    userRole: _userRole,
                    onClose: () => Navigator.pop(context),
                    onItemSelected: _onMenuItemSelected,
                  ),
                )
              : null,
          body: Row(
            children: [
              // ── Menú lateral completo (Desktop, visible) ──
              if (isDesktop && _isMenuVisible)
                SideMenu(
                  userName: _userName,
                  userRole: _userRole,
                  onClose: () => setState(() => _isMenuVisible = false),
                  onItemSelected: _onMenuItemSelected,
                ),

              // ── Mini rail (Desktop, menú oculto) ──
              if (isDesktop && !_isMenuVisible)
                Container(
                  width: 56,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF303366),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF303366).withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        // Botón hamburguesa para re-abrir el menú
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => setState(() => _isMenuVisible = true),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.menu_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Contenido principal ──
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: widget.child),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade300, width: 1.0),
                        ),
                      ),
                      child: const Text(
                        '© 2026 JHT Transport Company · Todos los derechos reservados.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
