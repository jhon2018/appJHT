// lib/features/shared/presentation/widgets/side_menu.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:app_jht_front/core/utils/token_service.dart';
import 'menu_config.dart';
import 'permission_service.dart';

class SideMenu extends StatelessWidget {
  final String userName;
  final String userRole;
  final VoidCallback onClose;
  final Function(String) onItemSelected;

  const SideMenu({
    super.key,
    required this.userName,
    required this.userRole,
    required this.onClose,
    required this.onItemSelected,
  });

  List<MenuItem> _getMenuItems() {
    return MenuUtil.toMenuItemList(userRole);
  }

  @override
  Widget build(BuildContext context) {
    PermissionService().updateRole(userRole);
    
    return Container(
      width: 280,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF303366).withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: -5,
            offset: const Offset(10, 0),
          )
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SafeArea(
            child: Column(
              children: [
                // Header elegante con logo/título
                _buildHeader(),
                
                // Tarjeta de usuario Premium
                _buildUserCard(),
                
                const SizedBox(height: 24),
                
                // Título de sección
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF303366),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'OPERACIONES',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Items del menú con scroll elegante
                Expanded(
                  child: _buildMenuItems(context),
                ),
                
                // Footer con botón de salida rediseñado
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'JHT',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF303366),
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
              Text(
                'TRANSPORT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4834D4),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF303366).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.keyboard_backspace_rounded,
                  size: 20,
                  color: Color(0xFF303366),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF303366), Color(0xFF4834D4), Color(0xFF686DE0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF303366).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF303366).withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            // Avatar con efecto de borde
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white.withOpacity(0.1),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4834D4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      userRole.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final menuItems = _getMenuItems();
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _MenuItemWidget(
            item: item,
            index: index,
            onTap: () {
              onClose();
              onItemSelected(item.title);
            },
          ),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!, width: 1)),
      ),
      child: Column(
        children: [
          _LogoutButtonWidget(onLogout: () {
            onClose();
            _showLogoutConfirmation(context);
          }),
          const SizedBox(height: 12),
          Text(
            'v1.2.0 • JHT System',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
            '¿Estás seguro $userName? ¿Deseas cerrar tu sesión actual?',
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
      PermissionService().updateRole(null);
      
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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

class _MenuItemWidget extends StatefulWidget {
  final MenuItem item;
  final int index;
  final VoidCallback onTap;

  const _MenuItemWidget({
    required this.item, 
    required this.index, 
    required this.onTap
  });

  @override
  State<_MenuItemWidget> createState() => _MenuItemWidgetState();
}

class _MenuItemWidgetState extends State<_MenuItemWidget> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + (widget.index * 100)),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.4, 1.0, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.4, 1.0, curve: Curves.easeOutBack),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _isPressed 
                  ? const Color(0xFF303366).withOpacity(0.1) 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Icono con contenedor estilizado
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isPressed 
                        ? const Color(0xFF303366) 
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: _isPressed ? [
                      BoxShadow(
                        color: const Color(0xFF303366).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ] : [],
                  ),
                  child: widget.item.materialIcon != null
                      ? Icon(
                          widget.item.materialIcon,
                          size: 18,
                          color: _isPressed ? Colors.white : const Color(0xFF303366),
                        )
                      : Text(
                          widget.item.icon,
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(width: 16),
                // Texto del item
                Expanded(
                  child: Text(
                    widget.item.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: _isPressed ? FontWeight.w700 : FontWeight.w600,
                      color: _isPressed ? const Color(0xFF303366) : const Color(0xFF334155),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                // Flecha de indicación
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: _isPressed 
                      ? const Color(0xFF303366) 
                      : const Color(0xFFCBD5E1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutButtonWidget extends StatefulWidget {
  final VoidCallback onLogout;

  const _LogoutButtonWidget({required this.onLogout});

  @override
  State<_LogoutButtonWidget> createState() => _LogoutButtonWidgetState();
}

class _LogoutButtonWidgetState extends State<_LogoutButtonWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onLogout,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _isPressed ? Colors.red[50] : const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isPressed ? Colors.red.withOpacity(0.2) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isPressed ? Colors.red : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.power_settings_new_rounded,
                size: 18,
                color: _isPressed ? Colors.white : Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Cerrar Sesión',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}