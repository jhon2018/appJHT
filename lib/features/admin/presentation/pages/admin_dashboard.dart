// Ruta: lib/features/admin/presentation/pages/admin_dashboard.dart
// OBJETIVO: Página de dashboard para el administrador de alto impacto visual (Modern UI).
import 'package:app_jht_front/features/shared/presentation/mixins/dashboard_responsive_mixin.dart';
import 'package:app_jht_front/features/shared/presentation/pages/base_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:app_jht_front/features/home/data/datasources/dashboard_service.dart';
import 'package:app_jht_front/features/home/presentation/widgets/download_report_modal.dart';
import 'dart:ui';

class AdminDashboard extends StatefulWidget {
  final String userName;
  final String userRole;

  const AdminDashboard({
    super.key,
    required this.userName,
    required this.userRole,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with DashboardResponsiveMixin, SingleTickerProviderStateMixin {
  final DashboardService _dashboardService = DashboardService();
  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
        _animController.forward(from: 0.0);
      }
    } catch (e) {
      debugPrint('Error al cargar datos del dashboard: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseDashboard(
      userName: widget.userName,
      userRole: widget.userRole,
      contentBuilder: (context, isDesktop) {
        if (_isLoading) {
          return const _DashboardSkeleton();
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          color: const Color(0xFF4834D4),
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: getResponsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 32),

                _buildStatsGrid(context),
                const SizedBox(height: 32),

                _buildChartsAndActivities(context, isDesktop),
                const SizedBox(height: 32),

                _buildRecentDataTable(context, isDesktop),
                const SizedBox(height: 40),

                _buildFooter(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _animController,
                curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
              ),
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panel Administrativo',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Hola ${widget.userName}, aquí tienes el resumen operativo.',
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const DownloadReportModal(),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 20),
                  label: const Text(
                    'Reporte CSV',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4834D4),
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shadowColor: const Color(0xFF4834D4).withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4834D4).withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.sync_rounded, color: Color(0xFF4834D4)),
                    onPressed: _loadData,
                    tooltip: 'Actualizar datos',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final isMobileLocal = isMobile(context);
    final crossAxisCount = isMobileLocal
        ? 1
        : (MediaQuery.sizeOf(context).width < 1200 ? 2 : 4);

    final vehiculosCount = _dashboardData?['vehiculos'] ?? 0;
    final conductoresCount = _dashboardData?['conductores'] ?? 0;
    final mantenimientosCount = _dashboardData?['mantenimientosCount'] ?? 0;
    final proveedoresCount = _dashboardData?['proveedores'] ?? 0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: isMobileLocal ? 2.2 : 1.6,
      children: [
        _buildAnimatedStatCard(
          0,
          title: 'Flota Total',
          value: '$vehiculosCount',
          subtitle: 'Vehículos registrados',
          icon: Icons.local_shipping_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF4834D4), Color(0xFF686DE0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        _buildAnimatedStatCard(
          1,
          title: 'Conductores',
          value: '$conductoresCount',
          subtitle: 'Personal activo',
          icon: Icons.badge_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFF009432), Color(0xFF2ED573)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        _buildAnimatedStatCard(
          2,
          title: 'Mantenimientos',
          value: '$mantenimientosCount',
          subtitle: mantenimientosCount > 0 ? 'Requieren atención' : 'Al día',
          icon: Icons.build_circle_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFFEA2027), Color(0xFFFF5252)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        _buildAnimatedStatCard(
          3,
          title: 'Proveedores',
          value: '$proveedoresCount',
          subtitle: 'Registrados en red',
          icon: Icons.store_mall_directory_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFFF79F1F), Color(0xFFFFC312)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedStatCard(
    int index, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required LinearGradient gradient,
  }) {
    final start = 0.2 + (index * 0.1);
    final end = 0.7 + (index * 0.1);
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _animController,
                curve: Interval(start, end, curve: Curves.easeOut),
              ),
            ),
        child: _StatCardPremium(
          title: title,
          value: value,
          subtitle: subtitle,
          icon: icon,
          gradient: gradient,
        ),
      ),
    );
  }

  Widget _buildChartsAndActivities(BuildContext context, bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _buildChartSection(context)),
          const SizedBox(width: 24),
          Expanded(flex: 2, child: _buildRecentActivities(context)),
        ],
      );
    }
    return Column(
      children: [
        _buildChartSection(context),
        const SizedBox(height: 24),
        _buildRecentActivities(context),
      ],
    );
  }

  Widget _buildChartSection(BuildContext context) {
    return _GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Visión Operativa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Este mes',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: Stack(
              children: [
                // Simulación visual elegante de gráfico (Background gradient curve)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomPaint(painter: _MockChartPainter()),
                  ),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.insert_chart_rounded,
                          color: Color(0xFF4834D4),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Módulo de Analítica en Desarrollo',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
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

  Widget _buildRecentActivities(BuildContext context) {
    final List<dynamic> alertas =
        _dashboardData?['mantenimientosAlertas'] ?? [];

    return _GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Color(0xFFEF4444),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Alertas Recientes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (alertas.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: Colors.green.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sin alertas críticas',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: alertas.length > 5
                  ? 5
                  : alertas.length, // Mostrar max 5
              separatorBuilder: (_, __) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(color: Color(0xFFF1F5F9), height: 1),
              ),
              itemBuilder: (context, index) {
                final alerta = alertas[index];
                final descripcion = alerta['man_descripcion'] ?? 'Alerta';
                final vehiculo = alerta['vehiculo'] != null
                    ? alerta['vehiculo']['veh_vplaca'] ?? ''
                    : '';
                return _buildTimelineItem(descripcion, vehiculo);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String descripcion, String vehiculo) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Color(0xFFF59E0B),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                descripcion,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Vehículo afectado: $vehiculo',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentDataTable(BuildContext context, bool isDesktop) {
    final List<dynamic> alertas =
        _dashboardData?['mantenimientosAlertas'] ?? [];

    return _GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estado de Mantenimientos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('Ver todos'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF4834D4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (alertas.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'Todos los vehículos están operativos.',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
                ),
              ),
            )
          else
            isDesktop
                ? _buildPremiumTable(alertas)
                : _buildMobileCards(alertas),
        ],
      ),
    );
  }

  Widget _buildPremiumTable(List<dynamic> alertas) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
          dataRowHeight: 65,
          horizontalMargin: 24,
          columns: const [
            DataColumn(
              label: Text(
                'Vehículo',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Descripción',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Costo Est.',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Prioridad',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
            ),
          ],
          rows: alertas.map((alerta) {
            final vehiculo = alerta['vehiculo'] != null
                ? alerta['vehiculo']['veh_vplaca'] ?? 'N/A'
                : 'N/A';
            final descripcion = alerta['man_descripcion'] ?? 'Sin descripción';
            final costo = alerta['man_costo_estimado']?.toString() ?? '0.00';

            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.directions_car_rounded,
                          color: Color(0xFF4338CA),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        vehiculo,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    descripcion,
                    style: const TextStyle(color: Color(0xFF475569)),
                  ),
                ),
                DataCell(
                  Text(
                    '\$$costo',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                DataCell(_buildStatusBadge('Alta')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileCards(List<dynamic> alertas) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: alertas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final alerta = alertas[index];
        final vehiculo = alerta['vehiculo'] != null
            ? alerta['vehiculo']['veh_vplaca'] ?? 'N/A'
            : 'N/A';
        final descripcion = alerta['man_descripcion'] ?? 'Sin descripción';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.directions_car_rounded,
                        color: Color(0xFF4338CA),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        vehiculo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  _buildStatusBadge('Alta'),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                descripcion,
                style: const TextStyle(color: Color(0xFF475569)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: const Text(
        'Prioridad Alta',
        style: TextStyle(
          color: Color(0xFFDC2626),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text(
            'JHT Transport Company',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Plataforma de Administración v2.0',
            style: TextStyle(fontSize: 12, color: const Color(0xFFCBD5E1)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// WIDGETS PREMIUM Y COMPONENTES VISUALES
// ---------------------------------------------------------

class _StatCardPremium extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;

  const _StatCardPremium({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });

  @override
  State<_StatCardPremium> createState() => _StatCardPremiumState();
}

class _StatCardPremiumState extends State<_StatCardPremium> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -5.0 : 0.0),
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.gradient.colors.first.withOpacity(
                _isHovered ? 0.4 : 0.2,
              ),
              blurRadius: _isHovered ? 20 : 10,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Icono decorativo de fondo translúcido gigante
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  widget.icon,
                  size: 120,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              // Contenido principal
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.value,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;

  const _GlassContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Pintor personalizado para simular un gráfico bonito y premium
class _MockChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF4834D4).withOpacity(0.2),
          const Color(0xFF4834D4).withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.7);

    // Curva suave
    path.cubicTo(
      size.width * 0.25,
      size.height * 0.8,
      size.width * 0.5,
      size.height * 0.3,
      size.width * 0.75,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.6,
      size.width,
      size.height * 0.2,
    );

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Línea del gráfico
    final linePaint = Paint()
      ..color = const Color(0xFF4834D4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final linePath = Path();
    linePath.moveTo(0, size.height * 0.7);
    linePath.cubicTo(
      size.width * 0.25,
      size.height * 0.8,
      size.width * 0.5,
      size.height * 0.3,
      size.width * 0.75,
      size.height * 0.5,
    );
    linePath.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.6,
      size.width,
      size.height * 0.2,
    );

    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------
// COMPONENTES DE CARGA (SKELETON LOADER) DE ALTO IMPACTO
// ---------------------------------------------------------

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 800;
    final isMobileLocal = MediaQuery.sizeOf(context).width < 600;
    final crossAxisCount = isMobileLocal ? 1 : (MediaQuery.sizeOf(context).width < 1200 ? 2 : 4);

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(width: 250, height: 40, borderRadius: 8),
                  const SizedBox(height: 8),
                  _SkeletonBox(width: 300, height: 20, borderRadius: 4),
                ],
              ),
              _SkeletonBox(width: 50, height: 50, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 32),
          
          // Cards Skeleton
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: isMobileLocal ? 2.2 : 1.6,
            children: List.generate(4, (index) => _SkeletonBox(width: double.infinity, height: double.infinity, borderRadius: 20)),
          ),
          const SizedBox(height: 32),

          // Charts & Activities Skeleton
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _SkeletonBox(width: double.infinity, height: 350, borderRadius: 20)),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: _SkeletonBox(width: double.infinity, height: 350, borderRadius: 20)),
              ],
            )
          else
            Column(
              children: [
                _SkeletonBox(width: double.infinity, height: 350, borderRadius: 20),
                const SizedBox(height: 24),
                _SkeletonBox(width: double.infinity, height: 300, borderRadius: 20),
              ],
            ),
          const SizedBox(height: 32),

          // Table Skeleton
          _SkeletonBox(width: double.infinity, height: 400, borderRadius: 20),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.3, end: 0.8),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOutSine,
      builder: (context, value, child) {
        // En lugar de usar repeat directamente (que no existe en TweenAnimationBuilder nativamente),
        // usamos un truco con un contenedor animado simulando el pulso (o en su defecto, 
        // simplemente dejamos el contenedor estático claro que se ve muy elegante también).
        // Para ser nativo 100% y sin errores, haremos un contenedor brillante simple:
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0).withOpacity(value),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    gradient: LinearGradient(
                      begin: Alignment(-2.0 + (value * 4), -0.5),
                      end: Alignment(2.0 + (value * 4), 0.5),
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.5),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      onEnd: () {
        // Si quisiéramos repetir, requeriría un stateful. Aquí el tween se ejecuta una vez.
      },
    );
  }
}
