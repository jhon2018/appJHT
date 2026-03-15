// lib/features/conductor/presentation/pages/conductor_dashboard.dart
import 'package:app_jht_front/features/shared/presentation/mixins/dashboard_responsive_mixin.dart';
import 'package:app_jht_front/features/shared/presentation/pages/base_dashboard.dart';
import 'package:flutter/material.dart';


class ConductorDashboard extends StatelessWidget with DashboardResponsiveMixin {
  final String userName;
  final String userRole;

  const ConductorDashboard({
    super.key,
    required this.userName,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return BaseDashboard(
      userName: userName,
      userRole: userRole,
      contentBuilder: (context, isDesktop) {
        return SingleChildScrollView(
          padding: getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saludo personalizado
              _buildWelcomeSection(context),
              const SizedBox(height: 24),
              
              // Tarjeta del vehículo asignado
              _buildVehicleCard(context),
              const SizedBox(height: 24),
              
              // Próximos mantenimientos y tareas
              _buildMaintenanceAndTasks(context, isDesktop),
              const SizedBox(height: 24),
              
              // Checklist del día
              _buildDailyChecklist(context),
              const SizedBox(height: 24),
              
              // Notificaciones y alertas
              _buildNotifications(context),
              const SizedBox(height: 40),
              
              // Footer
              _buildFooter(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    
    if (hour < 12) {
      greeting = 'Buenos días';
    } else if (hour < 18) {
      greeting = 'Buenas tardes';
    } else {
      greeting = 'Buenas noches';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: TextStyle(
            fontSize: 24,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userName,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Color(0xFF303366),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Turno: Mañana (6:00 - 14:00)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF303366), Color(0xFF4A4F8C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF303366).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Vehículo Asignado',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ACTIVO',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_bus,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Volvo FH 540',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Placa: ABC-123 • Modelo: 2023',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildVehicleInfoItem('Combustible', '75%', Icons.local_gas_station),
              _buildVehicleInfoItem('Kilometraje', '12,450 km', Icons.speed),
              _buildVehicleInfoItem('Próximo Mant.', '500 km', Icons.build),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.white70),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildMaintenanceAndTasks(BuildContext context, bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildMaintenanceSchedule(context),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _buildTodaysTasks(context),
          ),
        ],
      );
    }
    
    return Column(
      children: [
        _buildMaintenanceSchedule(context),
        const SizedBox(height: 20),
        _buildTodaysTasks(context),
      ],
    );
  }

  Widget _buildMaintenanceSchedule(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'PRÓXIMOS MANTENIMIENTOS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.build, size: 16, color: Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMaintenanceItem(
            'Cambio de aceite',
            '15 Mayo, 2024',
            'En 3 días',
            Colors.orange,
          ),
          _buildMaintenanceItem(
            'Revisión de frenos',
            '20 Mayo, 2024',
            'En 8 días',
            Colors.blue,
          ),
          _buildMaintenanceItem(
            'Alineación y balanceo',
            '25 Mayo, 2024',
            'En 13 días',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceItem(String title, String date, String daysLeft, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              daysLeft,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysTasks(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'TAREAS DE HOY',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.checklist, size: 16, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTaskItem('Realizar inspección pre-viaje', true),
          _buildTaskItem('Cargar combustible', true),
          _buildTaskItem('Revisar presión de neumáticos', false),
          _buildTaskItem('Actualizar bitácora de viaje', false),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '2 de 4 tareas completadas',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String task, bool completed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed ? Colors.green : Colors.transparent,
              border: Border.all(
                color: completed ? Colors.green : Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: completed
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task,
              style: TextStyle(
                fontSize: 14,
                color: completed ? Colors.grey : Colors.black87,
                decoration: completed ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChecklist(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_turned_in, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text(
                'CHECKLIST DIARIO',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChecklistChip('Luces', true),
              _ChecklistChip('Frenos', true),
              _ChecklistChip('Aceite', true),
              _ChecklistChip('Agua', false),
              _ChecklistChip('Neumáticos', true),
              _ChecklistChip('Herramientas', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotifications(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active, color: Colors.orange[700]),
              const SizedBox(width: 8),
              const Text(
                'NOTIFICACIONES',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNotificationItem(
            'Recordatorio: Documentación vence en 7 días',
            'Hace 2 horas',
            Icons.description,
            Colors.orange,
          ),
          _buildNotificationItem(
            'Ruta asignada: Lima - Callao (09:00)',
            'Hace 3 horas',
            Icons.route,
            Colors.blue,
          ),
          _buildNotificationItem(
            'Nuevo mensaje del administrador',
            'Hace 5 horas',
            Icons.message,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String text, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Column(
        children: [
          Text(
            '© ${DateTime.now().year} JHT Transport Company',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            'All rights reserved.',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _ChecklistChip extends StatelessWidget {
  final String label;
  final bool completed;

  const _ChecklistChip(this.label, this.completed);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: completed ? Colors.green.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: completed ? Colors.green : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (completed)
            Icon(Icons.check, size: 14, color: Colors.green[700]),
          if (completed) const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: completed ? Colors.green[700] : Colors.grey[600],
              fontWeight: completed ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}