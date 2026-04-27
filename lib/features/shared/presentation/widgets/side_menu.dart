// lib/features/shared/presentation/widgets/side_menu.dart
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

  // Obtener items del menú basado en el rol (AHORA CORRECTO)
  List<MenuItem> _getMenuItems() {
    // Usamos MenuUtil para obtener los items permitidos para este rol
    return MenuUtil.toMenuItemList(userRole);
  }

  @override
  Widget build(BuildContext context) {
    // Actualizar el PermissionService con el rol actual
    PermissionService().updateRole(userRole);
    
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header del menú
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MENÚ PRINCIPAL',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF303366),
                      letterSpacing: 0.5,
                    ),
                  ),
                  InkWell(
                    onTap: onClose,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 20, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
            
            // Tarjeta de usuario
            _buildUserCard(),
            
            const SizedBox(height: 16),
            
            // Items del menú
            Expanded(
              child: _buildMenuItems(context),
            ),
            
            // Botón salir
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF303366), Color(0xFF4834D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF303366).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Avatar del usuario
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                size: 28,
                color: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Información del usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'JHT TRANSPORT',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    userRole,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final menuItems = _getMenuItems();
    
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: menuItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _MenuItemWidget(
          item: item,
          onTap: () {
            onClose();
            onItemSelected(item.title);
          },
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return _LogoutButtonWidget(onLogout: () {
      onClose();
      _showLogoutConfirmation(context);
    });
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 10),
              Text('Cerrar Sesión'),
            ],
          ),
          content: Text('¿Estás seguro $userName? ¿Deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(context);
                _performRealLogout(context);
              },
              child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _performRealLogout(BuildContext context) async {
    try {
      await TokenService.deleteToken();
      // Limpiar el rol en PermissionService
      PermissionService().updateRole(null);
      
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesión cerrada correctamente'),
            backgroundColor: Color(0xFF303366),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _MenuItemWidget extends StatefulWidget {
  final MenuItem item;
  final VoidCallback onTap;

  const _MenuItemWidget({required this.item, required this.onTap});

  @override
  State<_MenuItemWidget> createState() => _MenuItemWidgetState();
}

class _MenuItemWidgetState extends State<_MenuItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _isHovered ? const Color(0xFF303366).withOpacity(0.08) : Colors.transparent,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isHovered ? const Color(0xFF303366) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.item.icon,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: _isHovered ? FontWeight.w700 : FontWeight.w500,
                      color: _isHovered ? const Color(0xFF303366) : Colors.black87,
                    ),
                    child: Text(widget.item.title),
                  ),
                ),
                if (_isHovered)
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF303366),
                    size: 20,
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
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onLogout,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _isHovered ? Colors.red[50] : Colors.transparent,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isHovered ? Colors.red : Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.logout,
                      size: 16,
                      color: _isHovered ? Colors.white : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: _isHovered ? FontWeight.w700 : FontWeight.w500,
                      color: _isHovered ? Colors.red : Colors.black87,
                    ),
                    child: const Text('Cerrar Sesión'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}