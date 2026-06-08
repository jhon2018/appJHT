// lib/features/supplier/presentation/pages/supplier_page.dart
// description: Página principal de proveedores con menú lateral, tabla responsiva y paginación.

import 'package:app_jht_front/core/network/http_client.dart';
import 'package:app_jht_front/features/supplier/domain/usecases/actualizar_supplier_usecase.dart';
import 'dart:async';
import 'package:app_jht_front/core/widgets/app_notification.dart';
import 'package:flutter/material.dart';
import 'package:app_jht_front/features/shared/presentation/widgets/side_menu.dart';
import 'package:app_jht_front/features/supplier/presentation/widgets/add_supplier_modal.dart';
import 'package:app_jht_front/features/supplier/presentation/widgets/detalle_supplier_modal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/supplier/presentation/bloc/supplier_bloc.dart';
import 'package:app_jht_front/features/supplier/domain/usecases/registrar_supplier_usecase.dart';
import 'package:app_jht_front/features/supplier/domain/usecases/listar_proveedores_usecase.dart';
import 'package:app_jht_front/features/supplier/domain/usecases/obtener_detalle_proveedor_usecase.dart';
import 'package:app_jht_front/features/supplier/data/repositories/supplier_repository_impl.dart';
import 'package:app_jht_front/features/supplier/data/datasources/supplier_remote_data_source.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_list_model.dart';
import 'package:app_jht_front/features/shared/presentation/mixins/navigation_helper_mixin.dart';
import 'package:flutter/foundation.dart';

class SupplierPage extends StatefulWidget {
  final String userName;
  final String userRole;

  const SupplierPage({
    super.key,
    required this.userName,
    required this.userRole,
  });

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  @override
  Widget build(BuildContext context) {
    final repository = SupplierRepositoryImpl(
      remoteDataSource: SupplierRemoteDataSourceImpl(httpClient: HttpClient()),
    );

    return BlocProvider(
      create: (context) => SupplierBloc(
        registrarSupplierUseCase: RegistrarSupplierUseCase(
          repository: repository,
        ),
        listarProveedoresUseCase: ListarProveedoresUseCase(
          repository: repository,
        ),
        obtenerDetalleProveedorUseCase: ObtenerDetalleProveedorUseCase(
          repository: repository,
        ),
        actualizarSupplierUseCase: ActualizarSupplierUseCase(
          repository: repository,
        ),
      ),
      child: _SupplierPageContent(
        userName: widget.userName,
        userRole: widget.userRole,
      ),
    );
  }
}

class _SupplierPageContent extends StatefulWidget {
  final String userName;
  final String userRole;

  const _SupplierPageContent({required this.userName, required this.userRole});

  @override
  State<_SupplierPageContent> createState() => __SupplierPageContentState();
}

class __SupplierPageContentState extends State<_SupplierPageContent>
    with NavigationHelperMixin<_SupplierPageContent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<SupplierListModel> _proveedores = [];
  List<SupplierListModel> _filteredProveedores = [];
  List<SupplierListModel> _paginatedProveedores = [];

  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  bool _isMobile = false;
  // ✅ PAGINACIÓN: 5 registros por página
  int _currentPage = 1;
  int _itemsPerPage = 5;
  String _currentFilter = 'Todos';

  int get _totalPages => _filteredProveedores.isEmpty
      ? 1
      : (_filteredProveedores.length / _itemsPerPage).ceil();

  // bool get _isMobile => MediaQuery.sizeOf(context).width < 768;

  @override
  void initState() {
    super.initState();
    _cargarProveedores();
    _searchController.addListener(_onSearchChanged);
  }

  void _cargarProveedores() {
    if (mounted) {
      BlocProvider.of<SupplierBloc>(
        context,
      ).add(const SupplierEvent.listarProveedores());
    }
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) _aplicarFiltros();
    });
  }

  void _aplicarFiltros() {
    if (!mounted) return;
    setState(() {
      final query = _searchController.text.toLowerCase();
      List<SupplierListModel> tempList = _proveedores;

      if (query.isNotEmpty) {
        tempList = _proveedores.where((proveedor) {
          return proveedor.razonSocial.toLowerCase().contains(query) ||
              proveedor.ruc.toString().contains(query) ||
              proveedor.telefono.contains(query) ||
              proveedor.representante.toLowerCase().contains(query);
        }).toList();
      }

      if (_currentFilter != 'Todos') {
        final estadoFilter = _currentFilter == 'Activos'
            ? 'activo'
            : 'inactivo';
        tempList = tempList
            .where(
              (proveedor) => proveedor.estado.toLowerCase() == estadoFilter,
            )
            .toList();
      }

      _filteredProveedores = tempList;
      _currentPage = 1;
      _actualizarPagina();
    });
  }

  void _actualizarPagina() {
    if (!mounted) return;
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;

    setState(() {
      if (startIndex < _filteredProveedores.length) {
        _paginatedProveedores = _filteredProveedores.sublist(
          startIndex,
          endIndex > _filteredProveedores.length
              ? _filteredProveedores.length
              : endIndex,
        );
      } else {
        _paginatedProveedores = [];
      }
    });
  }

  void _cambiarPagina(int page) {
    if (!mounted) return;
    if (page < 1 || page > _totalPages) return;
    setState(() {
      _currentPage = page;
      _actualizarPagina();
    });
  }

  void _paginaAnterior() {
    if (_currentPage > 1) {
      _cambiarPagina(_currentPage - 1);
    }
  }

  void _paginaSiguiente() {
    if (_currentPage < _totalPages) {
      _cambiarPagina(_currentPage + 1);
    }
  }

  void _cambiarFiltro(String filtro) {
    if (!mounted) return;
    setState(() {
      _currentFilter = filtro;
      _aplicarFiltros();
    });
  }

  Color _getEstadoColor(String estado) {
    final estadoLower = estado.toLowerCase();
    debugPrint(
      '🔍 Estado recibido: "$estado" -> Lower: "$estadoLower"',
    ); // Para debug

    if (estadoLower == 'activo' || estadoLower.contains('activo')) {
      return Colors.green[800]!;
    } else if (estadoLower == 'inactivo' || estadoLower.contains('inactivo')) {
      return Colors.red[800]!;
    } else {
      // Para cualquier otro estado (como ACTIVO, INACTIVO en mayúsculas)
      if (estado == 'ACTIVO') return Colors.green[800]!;
      if (estado == 'INACTIVO') return Colors.red[800]!;
      return Colors.grey[800]!;
    }
  }

  void _verDetalleProveedor(int proveedorId) {
    if (mounted) {
      BlocProvider.of<SupplierBloc>(
        context,
      ).add(SupplierEvent.obtenerDetalleProveedor(proveedorId: proveedorId));
    }
  }

  void _openAddSupplierModal() {
    if (!mounted) return;
    final supplierBloc = BlocProvider.of<SupplierBloc>(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BlocProvider.value(
          value: supplierBloc,
          child: AddSupplierModal(
            parentContext: context,
            onSupplierAdded: () {
              _cargarProveedores();
              if (mounted) {
                AppNotification.success(
                  context,
                  'Proveedor agregado correctamente.',
                );
              }
            },
          ),
        );
      },
    );
  }

  void _handleMenuSelection(String itemTitle) {
    navigateToMenuPage(context, itemTitle, widget.userName, widget.userRole);
  }

  void _showLoadingDialog([String message = 'Cargando...']) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
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
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isMobile = MediaQuery.sizeOf(context).width < 768;

    return BlocListener<SupplierBloc, SupplierState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {
            _showLoadingDialog('Cargando proveedores...');
          },
          success: (response) {},
          listLoaded: (response) {
            if (Navigator.canPop(context)) Navigator.pop(context);
            if (mounted) {
              setState(() {
                _proveedores = response.data;
                _filteredProveedores = response.data;
                _actualizarPagina();
              });
            }
          },
          // En supplier_page.dart, en el BlocListener:
          detailLoaded: (response) {
            if (Navigator.canPop(context)) Navigator.pop(context);
            if (mounted) {
              // ✅ Obtener el BLoC ANTES de mostrar el diálogo
              final supplierBloc = BlocProvider.of<SupplierBloc>(context);

              showDialog(
                context: context,
                builder: (context) => DetalleSupplierModal(
                  proveedor: response.data,
                  supplierBloc: supplierBloc, // ✅ PASAR EL BLOC COMO PARÁMETRO
                ),
              );
            }
          },
          updateSuccess: (response) {
            if (Navigator.canPop(context)) Navigator.pop(context);
            if (mounted) {
              AppNotification.success(context, response.message);
              _cargarProveedores();
            }
          },
          error: (message) {
            if (Navigator.canPop(context)) Navigator.pop(context);
            if (mounted) {
              AppNotification.error(context, 'Error: $message');
            }
          },
        );
      },
      child: Scaffold(
        key: _scaffoldKey,
        endDrawer: Drawer(
          child: SideMenu(
            userName: widget.userName,
            userRole: widget.userRole,
            onClose: () => Navigator.pop(context),
            onItemSelected: _handleMenuSelection,
          ),
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
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
                    actions: [_buildMenuButton()],
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: EdgeInsets.all(_isMobile ? 12.0 : 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderWithAddButton(),
                            const SizedBox(height: 16),
                            _buildFilters(),
                            const SizedBox(height: 16),
                            _buildResponsiveTable(),
                            const SizedBox(height: 16),
                            // ✅ PAGINACIÓN CON BOTONES
                            if (_filteredProveedores.isNotEmpty)
                              _buildPagination(),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            _buildCopyright(),
          ],
        ),
      ),
    );
  }

  // ── Loading spinner azul con texto contextual (I) ─────────────────────────
  Widget _buildLoadingSupplier() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF1565C0).withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF1565C0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Cargando proveedores...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Por favor espere un momento',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton() {
    return InkWell(
      onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(SupplierListModel proveedor, int index) {
    final globalIndex = ((_currentPage - 1) * _itemsPerPage) + index + 1;

    return DataRow(
      cells: [
        DataCell(
          Text(globalIndex.toString(), style: const TextStyle(fontSize: 12)),
        ),
        DataCell(
          Container(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              proveedor.razonSocial,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          Container(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(
              proveedor.representante,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          Container(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              proveedor.encargado,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          Text(proveedor.telefono, style: const TextStyle(fontSize: 12)),
        ),
        DataCell(
          Text(proveedor.ruc.toString(), style: const TextStyle(fontSize: 12)),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getEstadoColor(proveedor.estado).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              proveedor.estado,
              style: TextStyle(
                fontSize: 11,
                color: _getEstadoColor(proveedor.estado),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(
          InkWell(
            onTap: () => _verDetalleProveedor(proveedor.proveedorId),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF303366).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.remove_red_eye,
                color: Color(0xFF303366),
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderWithAddButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PROVEEDORES',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF303366),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 20),
        _isMobile ? _buildMobileHeaderLayout() : _buildDesktopHeaderLayout(),
      ],
    );
  }

  Widget _buildMobileHeaderLayout() {
    return Column(
      children: [
        InkWell(
          onTap: _openAddSupplierModal,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF303366),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'AGREGAR PROVEEDOR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Icon(Icons.search, color: Colors.grey, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Buscar por RUC, razón social o teléfono...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                  onPressed: () => _searchController.clear(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeaderLayout() {
    return Row(
      children: [
        InkWell(
          onTap: _openAddSupplierModal,
          child: Container(
            width: 220,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF303366),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'AGREGAR PROVEEDOR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.search, color: Colors.grey, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Buscar por RUC, razón social o teléfono...',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                    onPressed: () => _searchController.clear(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtros',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF303366),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('Todos', isSelected: _currentFilter == 'Todos'),
              _buildFilterChip(
                'Activos',
                isSelected: _currentFilter == 'Activos',
              ),
              _buildFilterChip(
                'Inactivos',
                isSelected: _currentFilter == 'Inactivos',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {required bool isSelected}) {
    return GestureDetector(
      onTap: () => _cambiarFiltro(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF303366) : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF303366) : Colors.grey[400]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ✅ TABLA SIN SCROLLBAR - EVITA ERROR EN DESKTOP
  Widget _buildResponsiveTable() {
    if (_filteredProveedores.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                _proveedores.isEmpty
                    ? 'No hay proveedores registrados'
                    : 'No se encontraron resultados con los filtros aplicados',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              if (_proveedores.isNotEmpty && _filteredProveedores.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextButton(
                    onPressed: () {
                      _searchController.clear();
                      _cambiarFiltro('Todos');
                    },
                    child: const Text('Limpiar filtros'),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minW = _isMobile ? 800.0 : 1000.0;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth > minW
                        ? constraints.maxWidth
                        : minW,
                  ),
                  child: DataTable(
                    headingRowHeight: 50,
                    dataRowHeight: 55,
                    horizontalMargin: _isMobile ? 12 : 16,
                    columnSpacing: _isMobile ? 8 : 16,
                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xFF303366),
                    ),
                    columns: _buildTableColumns(),
                    rows: _paginatedProveedores.asMap().entries.map((entry) {
                      final index = entry.key;
                      final proveedor = entry.value;
                      return _buildDataRow(proveedor, index);
                    }).toList(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<DataColumn> _buildTableColumns() {
    final fontSize = _isMobile ? 11.0 : 13.0;
    final columnWidths = _isMobile
        ? [40.0, 120.0, 120.0, 100.0, 90.0, 80.0, 70.0, 70.0]
        : [50.0, 160.0, 160.0, 140.0, 100.0, 100.0, 80.0, 80.0];

    final labels = [
      'Nr',
      'Razón Social',
      'Representante',
      'Encargado',
      'Teléfono',
      'RUC',
      'Estado',
      'Detalle',
    ];

    return List.generate(8, (index) {
      return DataColumn(
        label: SizedBox(
          width: columnWidths[index],
          child: Text(
            labels[index],
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    });
  }

  // ✅ NUEVA PAGINACIÓN CON BOTONES: 1, 2, 3, Anterior, Siguiente
  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botón Anterior
          InkWell(
            onTap: _paginaAnterior,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _currentPage > 1
                    ? const Color(0xFF303366)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.chevron_left,
                    color: _currentPage > 1 ? Colors.white : Colors.grey[600],
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Anterior',
                    style: TextStyle(
                      color: _currentPage > 1 ? Colors.white : Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Botones de página
          ..._buildPageButtons(),
          const SizedBox(width: 16),
          // Botón Siguiente
          InkWell(
            onTap: _paginaSiguiente,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _currentPage < _totalPages
                    ? const Color(0xFF303366)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Text(
                    'Siguiente',
                    style: TextStyle(
                      color: _currentPage < _totalPages
                          ? Colors.white
                          : Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    color: _currentPage < _totalPages
                        ? Colors.white
                        : Colors.grey[600],
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageButtons() {
    List<Widget> buttons = [];
    int startPage = (_currentPage - 2).clamp(1, _totalPages);
    int endPage = (_currentPage + 2).clamp(1, _totalPages);

    // Ajustar para mostrar siempre hasta 5 botones
    if (endPage - startPage < 4) {
      if (startPage == 1) {
        endPage = (startPage + 4).clamp(1, _totalPages);
      } else if (endPage == _totalPages) {
        startPage = (endPage - 4).clamp(1, _totalPages);
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      buttons.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: InkWell(
            onTap: () => _cambiarPagina(i),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? const Color(0xFF303366)
                    : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _currentPage == i
                      ? const Color(0xFF303366)
                      : Colors.grey[400]!,
                ),
              ),
              child: Center(
                child: Text(
                  i.toString(),
                  style: TextStyle(
                    color: _currentPage == i ? Colors.white : Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return buttons;
  }

  Widget _buildCopyright() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      child: Center(
        child: Text(
          '© 2026 JHT Transport Company\nTodos los derechos reservados.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.4),
        ),
      ),
    );
  }
}
