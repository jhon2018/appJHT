// Ruta: lib/features/mantenimiento/presentation/pages/mantenimiento_page.dart
import 'package:app_jht_front/features/mantenimiento/presentation/bloc/mantenimiento_event.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/bloc/mantenimiento_state.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_jht_front/core/widgets/app_notification.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/shared/presentation/widgets/side_menu.dart';
import 'package:app_jht_front/features/shared/presentation/widgets/scaffold_with_menu.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/widgets/add_mantenimiento_modal.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/widgets/edit_mantenimiento_modal.dart';
import 'package:app_jht_front/features/mantenimiento/data/models/mantenimiento_model.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/bloc/mantenimiento_bloc.dart';
import 'package:app_jht_front/core/widgets/pagination_widget.dart';
import 'package:app_jht_front/features/shared/presentation/mixins/navigation_helper_mixin.dart';

class MantenimientoPage extends StatefulWidget {
  final String userName;
  final String userRole;

  const MantenimientoPage({
    super.key,
    required this.userName,
    required this.userRole,
  });

  @override
  State<MantenimientoPage> createState() => _MantenimientoPageState();
}

class _MantenimientoPageState extends State<MantenimientoPage>
    with NavigationHelperMixin<MantenimientoPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _horizontalScrollController = ScrollController();
  List<MantenimientoModel>? _cachedMantenimientos;
  bool _isLoadingDialogVisible = false;
  // ── Paginación local ──────────────────────────────────────────────────────
  int _currentPage = 1;
  int _itemsPerPage = 5;

  // ── Búsqueda local ───────────────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Helpers de paginación ────────────────────────────────────────────────

  List<MantenimientoModel> _applySearch(List<MantenimientoModel> all) {
    if (_searchQuery.isEmpty) return all;
    final q = _searchQuery.toLowerCase();
    return all
        .where(
          (m) =>
              m.vehiculoPlaca.toLowerCase().contains(q) ||
              m.tipoAccesorio.toLowerCase().contains(q) ||
              m.estado.toLowerCase().contains(q) ||
              m.diccionarioMantenimiento.toLowerCase().contains(q),
        )
        .toList();
  }

  List<MantenimientoModel> _getPageItems(List<MantenimientoModel> filtered) {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, filtered.length);
    if (start >= filtered.length) return [];
    return filtered.sublist(start, end);
  }

  int _totalPages(int filteredCount) =>
      (filteredCount / _itemsPerPage).ceil().clamp(1, double.maxFinite.toInt());

  void _onPageChanged(int page) => setState(() => _currentPage = page);

  void _onItemsPerPageChanged(int value) => setState(() {
    _itemsPerPage = value;
    _currentPage = 1;
  });

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted)
        setState(() {
          _searchQuery = value;
          _currentPage = 1;
        });
    });
  }

  // ── Modales ──────────────────────────────────────────────────────────────

  void _openEditMantenimientoModal(MantenimientoModel mantenimiento) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BlocProvider.value(
        value: context.read<MantenimientoBloc>(),
        child: EditMantenimientoModal(
          mantenimiento: mantenimiento,
          onMantenimientoActualizado: () {
            context.read<MantenimientoBloc>().add(RefreshMantenimientosEvent());
            AppNotification.success(
              context,
              'Mantenimiento actualizado correctamente.',
            );
          },
        ),
      ),
    );
  }

  void _openAddMantenimientoModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AddMantenimientoModal(
        onMantenimientoAdded: () {
          context.read<MantenimientoBloc>().add(RefreshMantenimientosEvent());
          AppNotification.success(
            context,
            'Mantenimiento registrado correctamente.',
          );
        },
      ),
    );
  }

  void _showLoadingDialog([String message = 'Cargando...']) {
    if (_isLoadingDialogVisible) return;
    _isLoadingDialogVisible = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: const Color(0xFF303366),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).then((_) => _isLoadingDialogVisible = false);
  }

  // ── Build principal ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 768;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF7F8FC),
      body: BlocListener<MantenimientoBloc, MantenimientoState>(
        listener: (context, state) {
          if (state is MantenimientoSuccess) {
            if (_isLoadingDialogVisible) {
              Navigator.of(context, rootNavigator: true).pop();
              _isLoadingDialogVisible = false;
            }
          } else if (state is MantenimientoError) {
            if (_isLoadingDialogVisible) {
              Navigator.of(context, rootNavigator: true).pop();
              _isLoadingDialogVisible = false;
            }
            AppNotification.error(context, state.message);
          }
        },
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // ── AppBar ────────────────────────────────────────────────
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    leading: isMobile
                        ? IconButton(
                            icon: const Icon(Icons.menu_rounded, color: Color(0xFF303366)),
                            onPressed: () {
                              context.findAncestorStateOfType<ScaffoldWithMenuState>()?.openMobileMenu();
                            },
                          )
                        : null,
                    backgroundColor: Colors.white,
                    elevation: 1,
                    pinned: true,
                    title: const Text(
                      'JHT TRANSPORT',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF303366),
                      ),
                    ),
                    actions: const [],
                  ),

                  SliverPadding(
                    padding: EdgeInsets.all(isMobile ? 12.0 : 20.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildHeader(isMobile),
                        const SizedBox(height: 20),
                        _buildSearchBar(isMobile),
                        const SizedBox(height: 16),
                        _buildTableCard(isMobile),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }



  // ── Header + botón agregar ───────────────────────────────────────────────

  Widget _buildHeader(bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Ícono decorativo
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF303366),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.build_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mantenimientos',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF303366),
                ),
              ),
              Text(
                'Gestión de mantenimientos pendientes',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        if (!isMobile) _buildAddButton(isMobile),
      ],
    );
  }

  Widget _buildAddButton(bool isMobile) {
    return ElevatedButton.icon(
      onPressed: _openAddMantenimientoModal,
      icon: const Icon(Icons.add, size: 18),
      label: Text(
        isMobile ? 'Agregar' : 'Agregar Mantenimiento',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF303366),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 14 : 20,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }

  // ── Barra de búsqueda ────────────────────────────────────────────────────

  Widget _buildSearchBar(bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                  size: 20,
                ),
                hintText: 'Buscar por vehículo, accesorio, estado...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
        if (isMobile) ...[const SizedBox(width: 10), _buildAddButton(isMobile)],
      ],
    );
  }

  // ── Card contenedor de tabla + paginación ────────────────────────────────

  Widget _buildTableCard(bool isMobile) {
    return BlocBuilder<MantenimientoBloc, MantenimientoState>(
      builder: (context, state) {
        // Actualizar cache solo cuando llega lista nueva
        if (state is MantenimientoSuccess) {
          _cachedMantenimientos = state.mantenimientos;
        }

        // Mostrar indicador de carga inline en lugar de dialog
        if (state is MantenimientoLoading && _cachedMantenimientos == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF303366)),
                  ),
                  SizedBox(height: 16),
                  Text('Cargando mantenimientos...'),
                ],
              ),
            ),
          );
        }

        // Error solo si no hay datos previos
        if (state is MantenimientoError && _cachedMantenimientos == null) {
          return _buildErrorWidget(state.message);
        }

        // Grid visible si hay cache — sobrevive a cualquier estado del bloc
        if (_cachedMantenimientos != null) {
          final filtered = _applySearch(_cachedMantenimientos!);
          final pageItems = _getPageItems(filtered);
          final totalPages = _totalPages(filtered.length);

          if (_currentPage > totalPages && totalPages > 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() => _currentPage = 1);
            });
          }

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardHeader(
                  filtered.length,
                  _cachedMantenimientos!.length,
                ),
                const Divider(height: 1),
                filtered.isEmpty
                    ? _buildEmptyState()
                    : _buildResponsiveTable(pageItems, isMobile),
                const Divider(height: 1),
                if (filtered.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: PaginationWidget(
                      currentPage: _currentPage,
                      totalPages: totalPages,
                      totalItems: filtered.length,
                      itemsPerPage: _itemsPerPage,
                      onPageChanged: _onPageChanged,
                      onItemsPerPageChanged: _onItemsPerPageChanged,
                    ),
                  ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCardHeader(int filteredCount, int totalCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text(
            'Registros',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF303366),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF303366).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _searchQuery.isEmpty
                  ? '$totalCount'
                  : '$filteredCount de $totalCount',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF303366),
              ),
            ),
          ),
          const Spacer(),
          // Botón refresh
          InkWell(
            onTap: () {
              context.read<MantenimientoBloc>().add(LoadMantenimientosEvent());
              setState(() {
                _currentPage = 1;
                _searchQuery = '';
                _searchController.clear();
              });
            },
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.refresh_rounded,
                size: 18,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Skeleton loader ──────────────────────────────────────────────────────

  Widget _buildSkeletonLoader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cabecera skeleton
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _skeletonBox(80, 14),
                const SizedBox(width: 8),
                _skeletonBox(30, 14, radius: 12),
              ],
            ),
          ),
          const Divider(height: 1),
          // Filas skeleton
          ...List.generate(5, (i) => _buildSkeletonRow(i)),
        ],
      ),
    );
  }

  Widget _buildSkeletonRow(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.grey[50] : Colors.white,
      ),
      child: Row(
        children: [
          _skeletonBox(120, 12),
          const SizedBox(width: 24),
          _skeletonBox(80, 12),
          const SizedBox(width: 24),
          _skeletonBox(160, 12),
          const SizedBox(width: 24),
          _skeletonBox(70, 20, radius: 12),
          const SizedBox(width: 24),
          _skeletonBox(90, 12),
          const SizedBox(width: 24),
          _skeletonBox(30, 30, radius: 6),
        ],
      ),
    );
  }

  Widget _skeletonBox(double w, double h, {double radius = 4}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ── Error ────────────────────────────────────────────────────────────────

  Widget _buildErrorWidget(String message) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar mantenimientos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context.read<MantenimientoBloc>().add(
              LoadMantenimientosEvent(),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF303366),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    final bool isSearch = _searchQuery.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearch ? Icons.search_off_rounded : Icons.build_circle_outlined,
              color: Colors.grey[400],
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isSearch ? 'Sin resultados' : 'Sin mantenimientos',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isSearch
                ? 'No se encontraron registros para "$_searchQuery"'
                : 'No hay mantenimientos pendientes en este momento.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          if (isSearch) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
              icon: const Icon(Icons.clear),
              label: const Text('Limpiar búsqueda'),
            ),
          ],
        ],
      ),
    );
  }

  // ── Tabla responsive ─────────────────────────────────────────────────────

  Widget _buildResponsiveTable(List<MantenimientoModel> items, bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          controller: _horizontalScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth > (isMobile ? 680 : 900)
                    ? constraints.maxWidth
                    : (isMobile ? 680.0 : 900.0),
              ),
              child: DataTable(
                headingRowHeight: 46,
                dataRowMinHeight: 52,
                dataRowMaxHeight: 56,
                horizontalMargin: 16,
                columnSpacing: isMobile ? 12 : 20,
                dividerThickness: 1,
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFF303366),
                ),
                dataRowColor: WidgetStateProperty.resolveWith((states) {
                  return Colors.transparent;
                }),
                columns: _buildColumns(isMobile),
                rows: items.asMap().entries.map((entry) {
                  return _buildDataRow(entry.value, entry.key.isEven);
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildColumns(bool isMobile) {
    final style = TextStyle(
      color: Colors.white,
      fontSize: isMobile ? 11 : 13,
      fontWeight: FontWeight.w600,
    );
    final columns = [
      ('Accesorio', isMobile ? 100.0 : 140.0),
      ('Vehículo', isMobile ? 80.0 : 110.0),
      ('Dic. Mantenimiento', isMobile ? 130.0 : 180.0),
      ('Estado', isMobile ? 90.0 : 110.0),
      ('Fecha Registro', isMobile ? 95.0 : 130.0),
      ('Acciones', isMobile ? 60.0 : 80.0),
    ];

    return columns
        .map(
          (col) => DataColumn(
            label: SizedBox(
              width: col.$2,
              child: Text(col.$1, style: style),
            ),
          ),
        )
        .toList();
  }

  DataRow _buildDataRow(MantenimientoModel m, bool isEven) {
    return DataRow(
      color: WidgetStateProperty.all(
        isEven ? const Color(0xFFF7F8FC) : Colors.white,
      ),
      cells: [
        DataCell(
          Text(
            m.tipoAccesorio,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF303366).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.directions_car_outlined,
                  size: 13,
                  color: Color(0xFF303366),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                m.vehiculoPlaca,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            m.diccionarioMantenimiento,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(_buildEstadoBadge(m.estado)),
        DataCell(
          Text(
            _formatFecha(m.fechaRegistro),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
        DataCell(_buildEditButton(m)),
      ],
    );
  }

  Widget _buildEstadoBadge(String estado) {
    final config = _getEstadoConfig(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config['bg'] as Color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: config['dot'] as Color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            estado,
            style: TextStyle(
              fontSize: 11,
              color: config['text'] as Color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, Color> _getEstadoConfig(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return {
          'bg': Colors.orange[50]!,
          'dot': Colors.orange,
          'text': Colors.orange[800]!,
        };
      case 'completado':
        return {
          'bg': Colors.green[50]!,
          'dot': Colors.green,
          'text': Colors.green[800]!,
        };
      case 'en proceso':
        return {
          'bg': Colors.blue[50]!,
          'dot': Colors.blue,
          'text': Colors.blue[800]!,
        };
      default:
        return {
          'bg': Colors.grey[100]!,
          'dot': Colors.grey,
          'text': Colors.grey[700]!,
        };
    }
  }

  Widget _buildEditButton(MantenimientoModel m) {
    return Tooltip(
      message: 'Editar mantenimiento',
      child: InkWell(
        onTap: () => _openEditMantenimientoModal(m),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF303366).withOpacity(0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.edit_outlined,
            color: Color(0xFF303366),
            size: 16,
          ),
        ),
      ),
    );
  }

  String _formatFecha(String fecha) {
    try {
      final dt = DateTime.parse(fecha);
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return fecha;
    }
  }

  // ── Copyright ─────────────────────────────────────────────────────────────

  Widget _buildCopyright() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Center(
        child: Text(
          '© 2026 JHT Transport Company · Todos los derechos reservados.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[500], fontSize: 11),
        ),
      ),
    );
  }
}
