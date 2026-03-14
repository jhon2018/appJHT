// Ruta: lib/features/admin/presentation/pages/admin_dashboard.dart
// OBJETIVO: Página de dashboard para el administrador que utiliza BaseDashboard y obtiene datos del usuario desde TokenService.
// lib/features/admin/presentation/pages/admin_dashboard.dart
import 'package:app_jht_front/features/shared/presentation/mixins/dashboard_responsive_mixin.dart';
import 'package:app_jht_front/features/shared/presentation/pages/base_dashboard.dart';
import 'package:flutter/material.dart';


class AdminDashboard extends StatelessWidget with DashboardResponsiveMixin {
  final String userName;
  final String userRole;

  const AdminDashboard({
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
              // Título del dashboard
              _buildHeader(context),
              const SizedBox(height: 24),
              
              // Tarjetas de estadísticas principales
              _buildStatsGrid(context),
              const SizedBox(height: 32),
              
              // Gráficos y actividades recientes
              _buildChartsAndActivities(context, isDesktop),
              const SizedBox(height: 32),
              
              // Tabla de datos recientes
              _buildRecentDataTable(context, isDesktop),
              const SizedBox(height: 40),
              
              // Footer
              _buildFooter(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PANEL DE ADMINISTRACIÓN',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF303366),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bienvenido de nuevo, ${userName}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final isMobileLocal = isMobile(context);
    final crossAxisCount = isMobileLocal ? 2 : 4;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isMobileLocal ? 1.2 : 1.5,
      children: const [
        _StatCard(
          title: 'Vehículos',
          value: '24',
          subtitle: '+3 este mes',
          icon: Icons.directions_car,
          color: Color(0xFF303366),
        ),
        _StatCard(
          title: 'Conductores',
          value: '18',
          subtitle: '2 inactivos',
          icon: Icons.person,
          color: Color(0xFF4CAF50),
        ),
        _StatCard(
          title: 'Viajes Hoy',
          value: '8',
          subtitle: '75% completados',
          icon: Icons.assignment,
          color: Color(0xFF2196F3),
        ),
        _StatCard(
          title: 'Mantenimientos',
          value: '3',
          subtitle: '2 urgentes',
          icon: Icons.build,
          color: Color(0xFFFF9800),
        ),
      ],
    );
  }

  Widget _buildChartsAndActivities(BuildContext context, bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildChartSection(context),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _buildRecentActivities(context),
          ),
        ],
      );
    }
    
    return Column(
      children: [
        _buildChartSection(context),
        const SizedBox(height: 20),
        _buildRecentActivities(context),
      ],
    );
  }

  Widget _buildChartSection(BuildContext context) {
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
          const Text(
            'VIAJES POR MES',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.show_chart, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'Gráfico de rendimiento',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const Text(
                    '(Próximamente)',
                    style: TextStyle(
                      color: Color(0xFF303366),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
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
          const Text(
            'ACTIVIDADES RECIENTES',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            'Vehículo ABC-123 completó mantenimiento',
            'Hace 2 horas',
            Icons.check_circle,
            Colors.green,
          ),
          _buildActivityItem(
            'Nuevo conductor registrado: Juan Pérez',
            'Hace 5 horas',
            Icons.person_add,
            Colors.blue,
          ),
          _buildActivityItem(
            'Alerta de combustible en vehículo XYZ-789',
            'Hace 1 día',
            Icons.warning,
            Colors.orange,
          ),
          _buildActivityItem(
            'Reporte mensual generado',
            'Hace 2 días',
            Icons.description,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String text, String time, IconData icon, Color color) {
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDataTable(BuildContext context, bool isDesktop) {
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
          const Text(
            'VEHÍCULOS EN MANTENIMIENTO',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          isDesktop
              ? _buildDesktopTable()
              : _buildMobileTable(),
        ],
      ),
    );
  }

  Widget _buildDesktopTable() {
    return Table(
      border: TableBorder(
        horizontalInside: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[50]),
          children: [
            _buildTableCell('Vehículo', isHeader: true),
            _buildTableCell('Conductor', isHeader: true),
            _buildTableCell('Tipo', isHeader: true),
            _buildTableCell('Estado', isHeader: true),
          ],
        ),
        _buildTableRow('ABC-123', 'Carlos Ruiz', 'Preventivo', 'En proceso'),
        _buildTableRow('XYZ-789', 'María López', 'Correctivo', 'Pendiente'),
        _buildTableRow('DEF-456', 'Juan Pérez', 'Preventivo', 'Completado'),
      ],
    );
  }

  TableRow _buildTableRow(String vehiculo, String conductor, String tipo, String estado) {
    return TableRow(
      children: [
        _buildTableCell(vehiculo),
        _buildTableCell(conductor),
        _buildTableCell(tipo),
        _buildTableCell(estado, 
          color: estado == 'Completado' ? Colors.green : 
                 estado == 'En proceso' ? Colors.orange : Colors.red,
        ),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 13 : 14,
          fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
          color: color ?? (isHeader ? Colors.grey[700] : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildMobileTable() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final items = [
          ['ABC-123', 'Carlos Ruiz', 'Preventivo', 'En proceso'],
          ['XYZ-789', 'María López', 'Correctivo', 'Pendiente'],
          ['DEF-456', 'Juan Pérez', 'Preventivo', 'Completado'],
        ];
        final item = items[index];
        
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(item[0], style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
              Expanded(
                flex: 2,
                child: Text(item[1]),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item[3] == 'Completado' ? Colors.green.withOpacity(0.1) :
                           item[3] == 'En proceso' ? Colors.orange.withOpacity(0.1) :
                           Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item[3],
                    style: TextStyle(
                      fontSize: 12,
                      color: item[3] == 'Completado' ? Colors.green :
                             item[3] == 'En proceso' ? Colors.orange :
                             Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}