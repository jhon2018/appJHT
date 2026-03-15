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
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header del menú
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MENÚ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            
            // Tarjeta de usuario
            _buildUserCard(),
            
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF303366),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Avatar del usuario
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Color(0xFF303366),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Información del usuario
          Column(
            children: [
              Text(
                'JHT TRANSPORT COMPANY',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                userName,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userRole,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final menuItems = _getMenuItems();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ListView.separated(
        itemCount: menuItems.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                onClose();
                onItemSelected(item.title);
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.grey[50],
                ),
                child: Row(
                  children: [
                    Text(
                      item.icon,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onClose();
            _showLogoutConfirmation(context);
          },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.red[50],
            ),
            child: const Row(
              children: [
                Icon(Icons.logout, size: 18, color: Colors.red),
                SizedBox(width: 12),
                Text(
                  'Cerrar Sesión',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: Text('¿Estás seguro usuario $userName? ¿Deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _performRealLogout(context);
              },
              child: const Text('Cerrar Sesión'),
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