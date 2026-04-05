// lib/features/accessory/presentation/pages/accessory_page.dart
// CAMBIOS vs versión anterior:
//   1. _marcaAccesorioSeleccionado: guarda marca de AccesorioModel al presionar lápiz
//   2. _openEditAccessoryModal: pasa marcaFromLista al modal
//   3. _buildEstadoChip: colores semánticos Activo=verde / Completado=azul / Inactivo=gris
//   Todo lo demás idéntico al original.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:app_jht_front/features/shared/presentation/widgets/side_menu.dart';
import 'package:app_jht_front/features/accessory/presentation/widgets/add_accessory_modal.dart';
import 'package:app_jht_front/features/accessory/presentation/widgets/detalle_accessory_modal.dart';
import 'package:app_jht_front/features/accessory/presentation/widgets/edit_accessory_modal.dart';
import 'package:app_jht_front/features/accessory/presentation/bloc/accessory_bloc.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_model.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_detalle_model.dart';
import 'package:app_jht_front/features/accessory/data/models/vehiculo_model.dart';

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

class _AccessoryPageState extends State<AccessoryPage> {
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

  @override
  void initState() {
    super.initState();
    context.read<AccessoryBloc>().add(LoadVehiculosEvent());
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  // ── Color de fila por alerta de mantenimiento ─────────────────────────────
  Color _getRowColor(AccesorioModel acc) {
    if (acc.ultimoMantenimiento == null) return Colors.transparent;
    final proxima = DateTime.tryParse(
        acc.ultimoMantenimiento!.proximaFecha ?? '');
    if (proxima != null &&
        proxima.difference(DateTime.now()).inDays <= 15) {
      return Colors.red.withOpacity(0.15);
    }
    return Colors.transparent;
  }

  // ── Loading dialog ────────────────────────────────────────────────────────
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Agregar accesorio ─────────────────────────────────────────────────────
  void _openAddAccessoryModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddAccessoryModal(
        onAccessoryAdded: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Accesorio agregado exitosamente'),
              backgroundColor: Color(0xFF303366),
              duration: Duration(seconds: 5),
            ),
          );
          if (_selectedVehicle != null) {
            context.read<AccessoryBloc>().add(
                OnFetchAccesoriosByVehiculo(_selectedVehicle!.id));
          }
        },
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
    ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text('Navegando a: $itemTitle'),
        backgroundColor: const Color(0xFF303366),
      ),
    );
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
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return BlocListener<AccessoryBloc, AccessoryState>(
      listener: (context, state) {
        // Vehículos
        if (state is VehiculosLoading) {
          _showLoadingDialog('Cargando lista de vehículos...');
        } else if (state is VehiculosLoaded) {
          if (Navigator.canPop(context)) Navigator.pop(context);
          setState(() => _vehiclesList = state.vehiculos);

        // Accesorios por vehículo
        } else if (state is AccesoriosByVehiculoLoading) {
          _showLoadingDialog(
            _selectedVehicle != null
                ? 'Cargando accesorios del vehículo ${_selectedVehicle!.placa}...'
                : 'Cargando accesorios...',
          );
        } else if (state is AccesoriosByVehiculoLoaded) {
          if (Navigator.canPop(context)) Navigator.pop(context);

        // Error general
        } else if (state is AccessoryError) {
          if (Navigator.canPop(context)) Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
          ));
        }

        // Detalle cargando
        if (state is DetalleAccesorioLoading) {
          _showLoadingDialog('Cargando información detallada del accesorio...');
        }

        // Detalle listo → decide qué modal abrir
        if (state is DetalleAccesorioLoaded) {
          if (Navigator.canPop(context)) Navigator.pop(context);
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
          if (Navigator.canPop(context)) Navigator.pop(context);
          context.read<AccessoryBloc>().add(
              OnFetchAccesoriosByVehiculo(state.vehiculoId));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF0D8ABC),
            content: Row(children: const [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('Accesorio actualizado correctamente',
                  style: TextStyle(color: Colors.white)),
            ]),
          ));
        }

        // Error de actualización
        if (state is ActualizacionError) {
          if (Navigator.canPop(context)) Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
            content: Row(children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(state.message,
                      style: const TextStyle(color: Colors.white))),
            ]),
          ));
        }
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
                          color: Color(0xFF303366)),
                    ),
                    actions: [_buildMenuButton()],
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

  // ── Menú ──────────────────────────────────────────────────────────────────
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
          children: [_dot(), _dot(), _dot()],
        ),
      ),
    );
  }

  Widget _dot() => Container(
        width: 4,
        height: 4,
        decoration: const BoxDecoration(
            color: Colors.black87, shape: BoxShape.circle),
      );

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
              letterSpacing: 1.0),
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
      ],
    );
  }

  Widget _buildDesktopHeaderLayout() {
    return Row(
      children: [
        _botonAgregar(220, 14),
        const SizedBox(width: 16),
        Expanded(child: _buildVehiculoDropdown(isMobile: false)),
      ],
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
            borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('AGREGAR ACCESORIO',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildVehiculoDropdown({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Seleccionar Vehículo',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF303366))),
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
              icon: const Icon(Icons.arrow_drop_down,
                  color: Color(0xFF303366)),
              hint: _vehiclesList.isEmpty
                  ? const Row(children: [
                      SizedBox(width: 4),
                      SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 12),
                      Text('Cargando vehículos...',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey)),
                    ])
                  : const Text('Seleccione vehículo'),
              items: _vehiclesList
                  .map((v) => DropdownMenuItem<VehiculoModel>(
                        value: v,
                        child: Text(v.placa,
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _selectedVehicle = v;
                  _currentPage = 1;
                });
                if (v != null) {
                  context.read<AccessoryBloc>().add(
                      OnFetchAccesoriosByVehiculo(v.id));
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
                      fontSize: 14, color: Color(0xFF303366)),
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
                const Icon(Icons.inventory_2_outlined,
                    size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No hay accesorios registrados',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500)),
                if (_selectedVehicle != null) ...[
                  const SizedBox(height: 8),
                  Text('para el vehículo ${_selectedVehicle!.placa}',
                      style: const TextStyle(
                          fontSize: 14, color: Colors.grey)),
                ],
              ],
            ),
          );
        }

        final pageItems = _getCurrentPageItems(accesorios);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Scrollbar(
            controller: _horizontalScrollController,
            thumbVisibility: true,
            trackVisibility: true,
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: Container(
                width: isMobile ? 740 : 1040,
                padding: const EdgeInsets.all(8),
                child: DataTable(
                  headingRowHeight: 50,
                  dataRowHeight: 50,
                  horizontalMargin: isMobile ? 12 : 16,
                  columnSpacing: isMobile ? 8 : 24,
                  headingRowColor: WidgetStateProperty.all(
                      const Color(0xFF303366)),
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
    );
  }

  Widget _emptyBox({required Widget child}) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!)),
      child: Center(child: child),
    );
  }

  DataColumn _col(String label, double width, bool isMobile) {
    return DataColumn(
      label: SizedBox(
        width: width,
        child: Text(label,
            style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 11 : 13,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  DataRow _buildDataRow(AccesorioModel acc, bool isMobile) {
    return DataRow(
      color: WidgetStateProperty.all(_getRowColor(acc)),
      cells: [
        DataCell(Text(acc.tipoNombre,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis)),
        DataCell(Text(acc.marca ?? '-',
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis)),
        DataCell(Text(
            DateFormat('dd/MM/yyyy').format(acc.fechaInstalacion),
            style: const TextStyle(fontSize: 12))),
        DataCell(Text(
            acc.ultimoMantenimiento?.proximaFecha ?? 'No programada',
            style: const TextStyle(fontSize: 12))),
        DataCell(_buildEstadoChip(acc.ultimoMantenimiento?.estado)),
        // Ojito + Lápiz
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: 'Ver detalle',
              child: InkWell(
                onTap: () {
                  _pendingAction = _PendingAction.verDetalle;
                  context
                      .read<AccessoryBloc>()
                      .add(OnFetchDetalleAccesorio(acc.accesorioId));
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.remove_red_eye,
                      color: const Color(0xFF303366),
                      size: isMobile ? 17 : 18),
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
                  context
                      .read<AccessoryBloc>()
                      .add(OnFetchDetalleAccesorio(acc.accesorioId));
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.edit_outlined,
                      color: Colors.orange.shade700,
                      size: isMobile ? 17 : 18),
                ),
              ),
            ),
          ],
        )),
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
          color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(
        estado ?? 'Activo',
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }

  // ── Paginación ────────────────────────────────────────────────────────────
  Widget _buildPagination() {
    return BlocBuilder<AccessoryBloc, AccessoryState>(
      builder: (context, state) {
        final accesorios = state is AccesoriosByVehiculoLoaded
            ? state.accesorios
            : <AccesorioModel>[];

        final total = accesorios.length;
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
              borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mostrando $startItem al $endItem de $total accesorios',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Row(children: [
                    Text('Por página:',
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 12)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text('$_itemsPerPage',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 12)),
                    ),
                  ]),
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
                      child: _pageBtn('Anterior',
                          isActive: _currentPage > 1),
                    ),
                    ...[
                      for (int i = 1; i <= totalPages; i++)
                        InkWell(
                          onTap: () => setState(() => _currentPage = i),
                          child: _pageBtn(i.toString(),
                              isActive: _currentPage == i),
                        )
                    ],
                    InkWell(
                      onTap: _currentPage < totalPages
                          ? () => setState(() => _currentPage++)
                          : null,
                      child: _pageBtn('Siguiente',
                          isActive: _currentPage < totalPages),
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

  Widget _pageBtn(String text, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF303366) : Colors.white,
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey[600],
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
          color: Colors.white),
      child: Center(
        child: Text(
          '© 2025 JHT Transport Company\nTodos los derechos reservados.',
          textAlign: TextAlign.center,
          style:
              TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.4),
        ),
      ),
    );
  }
}

enum _PendingAction { none, verDetalle, editar }