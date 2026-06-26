// lib/features/shared/presentation/widgets/scaffold_with_menu.dart
import 'package:flutter/material.dart';
import 'package:app_jht_front/core/utils/token_service.dart';
import 'side_menu.dart';
import 'menu_config.dart';
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
    final userData = await TokenService.getResolvedUserData();
    if (mounted) {
      setState(() {
        _userName = userData?['usuario'] ?? 'Usuario';
        _userRole = userData?['cargo'] ?? 'Conductor';
        _isLoading = false;
      });
    }
  }

  void _onMenuItemSelected(String pageName) {
    if (pageName == 'Panel' || pageName == 'Dashboard') {
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
                _buildMiniRail(MenuUtil.toMenuItemList(_userRole)),

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

  Widget _buildMiniRail(List<MenuItem> menuItems) {
    return Container(
      width: 76,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200, width: 1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF303366).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Hamburguesa
            Tooltip(
              message: 'Expandir menú',
              verticalOffset: 20,
              preferBelow: false,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _isMenuVisible = true),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF303366).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_rounded,
                      color: Color(0xFF303366),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Separador
            Container(
              width: 32,
              height: 1,
              color: Colors.grey.shade200,
            ),
            const SizedBox(height: 16),
            // Items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Tooltip(
                      message: item.title,
                      verticalOffset: 20,
                      preferBelow: false,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      child: _MiniRailItem(
                        item: item,
                        onTap: () => _onMenuItemSelected(item.title),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Logout
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Tooltip(
                message: 'Cerrar Sesión',
                verticalOffset: 20,
                preferBelow: false,
                decoration: BoxDecoration(
                  color: Colors.red.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showLogoutConfirmation(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.power_settings_new_rounded,
                        color: Colors.red.shade700,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Cerrar Sesión',
                style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
            ],
          ),
          content: Text(
            '¿Estás seguro $_userName? ¿Deseas cerrar tu sesión actual?',
            style: const TextStyle(color: Color(0xFF64748B), height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCELAR',
                style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context);
                _performRealLogout(context);
              },
              child: const Text('CERRAR SESIÓN', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            ),
          ],
        );
      },
    );
  }

  void _performRealLogout(BuildContext context) async {
    try {
      await TokenService.deleteToken();
      if (context.mounted) {
        context.go('/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesión cerrada correctamente'),
            backgroundColor: Color(0xFF303366),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _MiniRailItem extends StatefulWidget {
  final MenuItem item;
  final VoidCallback onTap;

  const _MiniRailItem({required this.item, required this.onTap});

  @override
  State<_MiniRailItem> createState() => _MiniRailItemState();
}

class _MiniRailItemState extends State<_MiniRailItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _isHovered 
                ? const Color(0xFF303366) 
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
            boxShadow: _isHovered ? [
              BoxShadow(
                color: const Color(0xFF303366).withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              )
            ] : [],
          ),
          child: widget.item.materialIcon != null
              ? Icon(
                  widget.item.materialIcon,
                  size: 20,
                  color: _isHovered ? Colors.white : const Color(0xFF303366),
                )
              : Text(
                  widget.item.icon,
                  style: const TextStyle(fontSize: 16),
                ),
        ),
      ),
    );
  }
}
