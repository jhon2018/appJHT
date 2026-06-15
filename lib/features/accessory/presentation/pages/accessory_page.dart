// lib/features/accessory/presentation/pages/accessory_page.dart
// CAMBIOS vs versión anterior:
//   1. _marcaAccesorioSeleccionado: guarda marca de AccesorioModel al presionar lápiz
//   2. _openEditAccessoryModal: pasa marcaFromLista al modal
//   3. _buildEstadoChip: colores semánticos Activo=verde / Completado=azul / Inactivo=gris
//   Todo lo demás idéntico al original.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_jht_front/core/widgets/app_notification.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:app_jht_front/features/shared/presentation/widgets/side_menu.dart';
import 'package:app_jht_front/features/shared/presentation/widgets/scaffold_with_menu.dart';
import 'package:app_jht_front/features/accessory/presentation/widgets/add_accessory_modal.dart';
import 'package:app_jht_front/features/accessory/presentation/widgets/detalle_accessory_modal.dart';
import 'package:app_jht_front/features/accessory/presentation/widgets/edit_accessory_modal.dart';
import 'package:app_jht_front/features/accessory/presentation/bloc/accessory_bloc.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_model.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_detalle_model.dart';
import 'package:app_jht_front/features/accessory/data/models/vehiculo_model.dart';
import 'package:app_jht_front/features/shared/presentation/mixins/navigation_helper_mixin.dart';

class AccessoryPage extends StatefulWidget {
  final String userName;
  final String userRole;

  const AccessoryPage({
    super.key,
    required this.userName,
    required this.userRole,
  });

  @override
  State<AccessoryPage> createState() => _AccessoryPageState();
}

class _AccessoryPageState extends State<AccessoryPage>
    with NavigationHelperMixin<AccessoryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _horizontalScrollController = ScrollController();

  List<VehiculoModel> _vehiclesList = [];
  VehiculoModel? _selectedVehicle;

  int _currentPage = 1;
  final int _itemsPerPage = 5;

  // Guarda la marca del AccesorioModel (API26) antes de llamar API27
  // porque API27 no devuelve el campo marca.
  String _marcaAccesorioSeleccionado = '';

  // Controla qué modal abrir cuando llega DetalleAccesorioLoaded
  _PendingAction _pendingAction = _PendingAction.none;

  // ── Búsqueda con debounce ──────────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounceTimer;

  bool _isVehiclesLoading = true;
  bool _hasVehiclesError = false;

  @override
  void initState() {
    super.initState();
    context.read<AccessoryBloc>().add(LoadVehiculosEvent());
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted)
        setState(() {
          _searchQuery = _searchController.text;
          _currentPage = 1;
        });
    });
  }

  List<AccesorioModel> _filterAccesorios(List<AccesorioModel> all) {
    if (_searchQuery.isEmpty) return all;
    final q = _searchQuery.toLowerCase();
    return all
        .where(
          (a) =>
              a.tipoNombre.toLowerCase().contains(q) ||
              (a.marca?.toLowerCase().contains(q) ?? false) ||
              (a.ultimoMantenimiento?.estado?.toLowerCase().contains(q) ??
                  false),
        )
        .toList();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ── Color de fila por alerta de mantenimiento ─────────────────────────────
  Color _getRowColor(AccesorioModel acc) {
    if (acc.ultimoMantenimiento == null) return Colors.transparent;
    final proxima = DateTime.tryParse(
      acc.ultimoMantenimiento!.proximaFecha ?? '',
    );
    if (proxima != null && proxima.difference(DateTime.now()).inDays <= 15) {
      return Colors.red.withOpacity(0.15);
    }
    return Colors.transparent;
  }

  // ── Loading dialog ────────────────────────────────────────────────────────
  bool _isLoadingDialogVisible = false;

  void _showLoadingDialog(String message) {
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

  // ── Agregar accesorio ─────────────────────────────────────────────────────
  void _openAddAccessoryModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<AccessoryBloc>(),
        child: AddAccessoryModal(
          onAccessoryAdded: () {
            AppNotification.success(
              context,
              'Accesorio agregado exitosamente.',
            );
            if (_selectedVehicle != null) {
              context.read<AccessoryBloc>().add(
                OnFetchAccesoriosByVehiculo(_selectedVehicle!.id),
              );
            }
          },
        ),
      ),
    );
  }

  // ── Editar accesorio: abre modal pasando marca desde API26 ────────────────
  void _openEditAccessoryModal(AccesorioDetalleModel detalle) {
    if (_selectedVehicle == null) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<AccessoryBloc>(),
        child: EditAccessoryModal(
          detalle: detalle,
          vehiculoIdActual: _selectedVehicle!.id,
          vehiculosList: _vehiclesList,
          marcaFromLista: _marcaAccesorioSeleccionado, // ← marca de API26
        ),
      ),
    );
  }

  void _handleMenuSelection(String itemTitle) {
    navigateToMenuPage(context, itemTitle, widget.userName, widget.userRole);
  }

  List<AccesorioModel> _getCurrentPageItems(List<AccesorioModel> all) {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = start + _itemsPerPage;
    return all.sublist(start, end > all.length ? all.length : end);
  }

  int _getTotalPages(int total) => (total / _itemsPerPage).ceil();

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 768;

    return BlocListener<AccessoryBloc, AccessoryState>(
      listener: (context, state) {
        // Vehículos
        if (state is VehiculosLoading) {
          setState(() {
            _isVehiclesLoading = true;
            _hasVehiclesError = false;
          });
        } else if (state is VehiculosLoaded) {
          setState(() {
            _vehiclesList = state.vehiculos;
            _isVehiclesLoading = false;
            _hasVehiclesError = false;
          });
        }
        
        // Error general (al cargar listas)
        if (state is AccessoryError) {
          setState(() {
            _isVehiclesLoading = false;
            _hasVehiclesError = true;
          });
          AppNotification.error(context, state.message);
        }

        // Detalle cargando
        if (state is DetalleAccesorioLoading) {
          _showLoadingDialog('Cargando información detallada del accesorio...');
        }

        // Detalle listo → decide qué modal abrir
        if (state is DetalleAccesorioLoaded) {
          if (_isLoadingDialogVisible) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          if (_pendingAction == _PendingAction.verDetalle) {
            _pendingAction = _PendingAction.none;
            showDetalleAccesorioModal(context, state.detalle, 0.0);
          } else if (_pendingAction == _PendingAction.editar) {
            _pendingAction = _PendingAction.none;
            _openEditAccessoryModal(state.detalle);
          }
        }

        // Actualizando
        if (state is ActualizandoAccesorio) {
          _showLoadingDialog('Guardando cambios...');
        }

        // Actualizado OK
        if (state is AccesorioActualizado) {
          if (_isLoadingDialogVisible) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          context.read<AccessoryBloc>().add(
            OnFetchAccesoriosByVehiculo(state.vehiculoId),
          );
          AppNotification.success(
            context,
            'Accesorio actualizado correctamente.',
          );
        }

        // Error de actualización
        if (state is ActualizacionError) {
          if (_isLoadingDialogVisible) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          AppNotification.error(context, state.message);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
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
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderWithAddButton(isMobile),
                            const SizedBox(height: 16),
                            _buildResponsiveTable(isMobile),
                            const SizedBox(height: 16),
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



  // ── Header con botón agregar + dropdown vehículo ──────────────────────────
  Widget _buildHeaderWithAddButton(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACCESORIO',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF303366),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 20),
        isMobile ? _buildMobileHeaderLayout() : _buildDesktopHeaderLayout(),
      ],
    );
  }

  Widget _buildMobileHeaderLayout() {
    return Column(
      children: [
        _botonAgregar(double.infinity, 16),
        const SizedBox(height: 12),
        _buildVehiculoDropdown(isMobile: true),
        const SizedBox(height: 12),
        _buildSearchBox(),
      ],
    );
  }

  Widget _buildDesktopHeaderLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _botonAgregar(220, 14),
            const SizedBox(width: 16),
            Expanded(child: _buildVehiculoDropdown(isMobile: false)),
          ],
        ),
        const SizedBox(height: 12),
        _buildSearchBox(),
      ],
    );
  }

  Widget _buildSearchBox() {
    return Container(
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
                hintText: 'Buscar por tipo/nombre, marca o estado...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
              onPressed: () => _searchController.clear(),
            ),
        ],
      ),
    );
  }

  Widget _botonAgregar(double width, double fontSize) {
    return InkWell(
      onTap: _openAddAccessoryModal,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF303366),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'AGREGAR ACCESORIO',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehiculoDropdown({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seleccionar Vehículo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF303366),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: isMobile ? double.infinity : null,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<VehiculoModel>(
              value: _selectedVehicle,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF303366)),
              hint: _isVehiclesLoading
                  ? const Row(
                      children: [
                        SizedBox(width: 4),
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Cargando vehículos...',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    )
                  : _hasVehiclesError
                      ? const Text('Error al cargar vehículos', style: TextStyle(color: Colors.red))
                      : _vehiclesList.isEmpty
                          ? const Text('No hay vehículos')
                          : const Text('Seleccione vehículo'),
              items: _vehiclesList
                  .map(
                    (v) => DropdownMenuItem<VehiculoModel>(
                      value: v,
                      child: Text(
                        v.placa,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _selectedVehicle = v;
                  _currentPage = 1;
                });
                if (v != null) {
                  context.read<AccessoryBloc>().add(
                    OnFetchAccesoriosByVehiculo(v.id),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // ── Tabla responsive ──────────────────────────────────────────────────────
  Widget _buildResponsiveTable(bool isMobile) {
    return BlocBuilder<AccessoryBloc, AccessoryState>(
      buildWhen: (_, current) =>
          current is AccesoriosByVehiculoLoaded ||
          current is AccesoriosByVehiculoLoading,
      builder: (context, state) {
        if (state is AccesoriosByVehiculoLoading) {
          return _emptyBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  _selectedVehicle != null
                      ? 'Cargando accesorios del vehículo ${_selectedVehicle!.placa}...'
                      : 'Cargando accesorios...',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF303366),
                  ),
                ),
              ],
            ),
          );
        }

        final accesorios = state is AccesoriosByVehiculoLoaded
            ? state.accesorios
            : <AccesorioModel>[];

        if (accesorios.isEmpty) {
          return _emptyBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 60,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No hay accesorios registrados',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_selectedVehicle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'para el vehículo ${_selectedVehicle!.placa}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ],
            ),
          );
        }

        // Aplicar búsqueda local
        final filtered = _filterAccesorios(accesorios);
        final pageItems = _getCurrentPageItems(filtered);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final minW = isMobile ? 740.0 : 1040.0;
              final tableW = constraints.maxWidth > minW
                  ? constraints.maxWidth
                  : minW;
              return Scrollbar(
                controller: _horizontalScrollController,
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Container(
                      width: tableW,
                      padding: const EdgeInsets.all(8),
                      child: DataTable(
                        headingRowHeight: 50,
                        dataRowHeight: 50,
                        horizontalMargin: isMobile ? 12 : 16,
                        columnSpacing: isMobile ? 8 : 24,
                        headingRowColor: WidgetStateProperty.all(
                          const Color(0xFF303366),
                        ),
                        columns: isMobile
                            ? [
                                _col('Tipo / Nombre', 130, isMobile),
                                _col('Marca', 90, isMobile),
                                _col('Instalación', 100, isMobile),
                                _col('Próx. Mantenimiento', 120, isMobile),
                                _col('Estado', 80, isMobile),
                                _col('Acción', 110, isMobile),
                              ]
                            : [
                                _col('Tipo / Nombre', 180, isMobile),
                                _col('Marca', 120, isMobile),
                                _col('Instalación', 140, isMobile),
                                _col('Próximo Mantenimiento', 160, isMobile),
                                _col('Estado', 100, isMobile),
                                _col('Acción', 130, isMobile),
                              ],
                        rows: pageItems
                            .map((acc) => _buildDataRow(acc, isMobile))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _emptyBox({required Widget child}) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(child: child),
    );
  }

  DataColumn _col(String label, double width, bool isMobile) {
    return DataColumn(
      label: SizedBox(
        width: width,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 11 : 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(AccesorioModel acc, bool isMobile) {
    return DataRow(
      color: WidgetStateProperty.all(_getRowColor(acc)),
      cells: [
        DataCell(
          Text(
            acc.tipoNombre,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(
          Text(
            acc.marca ?? '-',
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(
          Text(
            DateFormat('dd/MM/yyyy').format(acc.fechaInstalacion),
            style: const TextStyle(fontSize: 12),
          ),
        ),
        DataCell(
          Text(
            acc.ultimoMantenimiento?.proximaFecha ?? 'No programada',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        DataCell(_buildEstadoChip(acc.ultimoMantenimiento?.estado)),
        // Ojito + Lápiz
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Tooltip(
                message: 'Ver detalle',
                child: InkWell(
                  onTap: () {
                    _pendingAction = _PendingAction.verDetalle;
                    context.read<AccessoryBloc>().add(
                      OnFetchDetalleAccesorio(acc.accesorioId),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.remove_red_eye,
                      color: const Color(0xFF303366),
                      size: isMobile ? 17 : 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: 'Editar accesorio',
                child: InkWell(
                  onTap: () {
                    // Guarda marca ANTES de llamar API27 (que no la devuelve)
                    _marcaAccesorioSeleccionado = acc.marca ?? '';
                    _pendingAction = _PendingAction.editar;
                    context.read<AccessoryBloc>().add(
                      OnFetchDetalleAccesorio(acc.accesorioId),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.edit_outlined,
                      color: Colors.orange.shade700,
                      size: isMobile ? 17 : 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Chip de estado con colores semánticos ─────────────────────────────────
  Widget _buildEstadoChip(String? estado) {
    Color bg;
    switch (estado?.toLowerCase().trim()) {
      case 'activo':
        bg = const Color(0xFF1E8A4A); // verde
        break;
      case 'completado':
        bg = const Color(0xFF0D8ABC); // azulino
        break;
      case 'inactivo':
        bg = const Color(0xFF8E99AA); // gris
        break;
      default:
        bg = const Color(0xFF1E8A4A); // verde por defecto
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        estado ?? 'Activo',
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }

  // ── Paginación ────────────────────────────────────────────────────────────
  // Paginación ahora usa la lista filtrada
  Widget _buildPagination() {
    return BlocBuilder<AccessoryBloc, AccessoryState>(
      buildWhen: (_, s) => s is AccesoriosByVehiculoLoaded,
      builder: (context, state) {
        final raw = state is AccesoriosByVehiculoLoaded
            ? state.accesorios
            : <AccesorioModel>[];
        final filtered = _filterAccesorios(raw);
        final total = filtered.length;
        if (total == 0) return const SizedBox.shrink();

        final totalPages = _getTotalPages(total);
        final startItem = ((_currentPage - 1) * _itemsPerPage) + 1;
        final endItem = (_currentPage * _itemsPerPage) > total
            ? total
            : (_currentPage * _itemsPerPage);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      _searchQuery.isNotEmpty
                          ? 'Mostrando $startItem-$endItem de $total resultados'
                          : 'Mostrando $startItem al $endItem de $total accesorios',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$_itemsPerPage por pág.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: _currentPage > 1
                          ? () => setState(() => _currentPage--)
                          : null,
                      child: _pageBtn(
                        'Anterior',
                        isActive: false,
                        enabled: _currentPage > 1,
                      ),
                    ),
                    for (int i = 1; i <= totalPages; i++)
                      InkWell(
                        onTap: () => setState(() => _currentPage = i),
                        child: _pageBtn(
                          i.toString(),
                          isActive: _currentPage == i,
                          enabled: true,
                        ),
                      ),
                    InkWell(
                      onTap: _currentPage < totalPages
                          ? () => setState(() => _currentPage++)
                          : null,
                      child: _pageBtn(
                        'Siguiente',
                        isActive: false,
                        enabled: _currentPage < totalPages,
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

  Widget _pageBtn(String text, {bool isActive = false, bool enabled = true}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF303366)
            : (enabled ? Colors.white : Colors.grey[100]),
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive
              ? Colors.white
              : (enabled ? Colors.grey[600] : Colors.grey[400]),
          fontSize: 12,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  // ── Copyright ─────────────────────────────────────────────────────────────
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

enum _PendingAction { none, verDetalle, editar }
