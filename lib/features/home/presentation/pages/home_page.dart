// lib/features/home/presentation/pages/home_page.dart
import 'package:app_jht_front/features/home/data/datasources/dashboard_service.dart';
import 'package:flutter/material.dart';
import 'package:app_jht_front/features/home/presentation/widgets/download_report_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Colores principales de la marca (basado en login_page)
  final Color primaryColor = const Color(0xFF303366);
  final Color accentColor = const Color(0xFF4834D4);
  final Color alertColor = const Color(0xFFE74C3C);
  final Color warningColor = const Color(0xFFF39C12);
  final Color successColor = const Color(0xFF2ECC71);

  final DashboardService _dashboardService = DashboardService();
  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _dashboardService.getDashboardData();
      if (mounted) {
        setState(() {
          _dashboardData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Podríamos mostrar un error aquí
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F7FA),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF303366)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA), // Fondo claro y limpio
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: primaryColor,
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isDesktop = constraints.maxWidth > 800;
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildKPISection(isDesktop),
                    const SizedBox(height: 32),
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildAlertsSection()),
                          const SizedBox(width: 24),
                          Expanded(flex: 1, child: _buildQuickActionsSection()),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildAlertsSection(),
                          const SizedBox(height: 24),
                          _buildQuickActionsSection(),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Panel de Control',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF303366)),
              onPressed: _loadData,
              tooltip: 'Actualizar datos',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Bienvenido de vuelta, Administrador. Aquí tienes el resumen de tu flota.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.blueGrey.shade400,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildKPISection(bool isDesktop) {
    return GridView.count(
      crossAxisCount: isDesktop ? 4 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isDesktop ? 1.5 : 1.2,
      children: [
        _buildKPICard(
          title: 'Flota Total',
          value: '${_dashboardData?['vehiculos'] ?? 0}',
          subtitle: 'Vehículos registrados',
          icon: Icons.directions_bus_filled_rounded,
          color: primaryColor,
        ),
        _buildKPICard(
          title: 'Mantenimientos',
          value: '${_dashboardData?['mantenimientosCount'] ?? 0}',
          subtitle: 'Pendientes',
          icon: Icons.build_circle_rounded,
          color: alertColor,
          isAlert: (_dashboardData?['mantenimientosCount'] ?? 0) > 0,
        ),
        _buildKPICard(
          title: 'Conductores',
          value: '${_dashboardData?['conductores'] ?? 0}',
          subtitle: 'Registrados',
          icon: Icons.badge_rounded,
          color: successColor,
        ),
        _buildKPICard(
          title: 'Proveedores',
          value: '${_dashboardData?['proveedores'] ?? 0}',
          subtitle: 'Activos',
          icon: Icons.store_mall_directory_rounded,
          color: warningColor,
        ),
      ],
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool isAlert = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isAlert ? color.withOpacity(0.3) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              if (isAlert)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: alertColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_rounded, color: alertColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Acción requerida',
                        style: TextStyle(
                          color: alertColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isAlert ? alertColor : Colors.blueGrey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
    final List<dynamic> alertas =
        _dashboardData?['mantenimientosAlertas'] ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.notification_important_rounded,
                      color: Color(0xFFE74C3C),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Alertas de Mantenimiento',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                if (alertas.isNotEmpty)
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Ver todas',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          if (alertas.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 48,
                      color: successColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay alertas pendientes',
                      style: TextStyle(
                        color: Colors.blueGrey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: alertas.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final alerta = alertas[index];
                // Intentamos extraer datos si es posible, según la estructura probable
                final descripcion =
                    alerta['man_descripcion'] ?? 'Mantenimiento pendiente';
                final vehiculo = alerta['vehiculo'] != null
                    ? alerta['vehiculo']['veh_vplaca'] ?? 'Vehículo'
                    : 'Vehículo';

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.car_crash_rounded,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  title: Text(
                    '$descripcion - $vehiculo',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                  subtitle: const Text(
                    'Requiere atención inmediata para prevenir daños operativos.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Revisar',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Acciones Rápidas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildActionTile(
                  icon: Icons.add_circle_outline_rounded,
                  title: 'Nuevo Vehículo',
                  color: primaryColor,
                  onTap: () {
                    // Navigate to vehicle creation or show modal
                  },
                ),
                const SizedBox(height: 12),
                _buildActionTile(
                  icon: Icons.build_rounded,
                  title: 'Registrar Mantenimiento',
                  color: warningColor,
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildActionTile(
                  icon: Icons.person_add_alt_1_rounded,
                  title: 'Nuevo Conductor',
                  color: successColor,
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildActionTile(
                  icon: Icons.download_rounded,
                  title: 'Reporte Mant. (CSV)',
                  color: Colors.teal,
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) => const DownloadReportModal(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                  fontSize: 15,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.blueGrey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}
