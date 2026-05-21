// lib/features/vehicle/presentation/pages/vehicle_page.dart
import 'package:app_jht_front/features/vehicle/data/models/vehicle_list_response.dart';
import 'dart:async';
import 'package:app_jht_front/core/widgets/app_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/shared/presentation/widgets/side_menu.dart';
import 'package:app_jht_front/features/vehicle/presentation/widgets/add_vehicle_modal.dart';
import 'package:app_jht_front/features/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:app_jht_front/features/vehicle/presentation/widgets/edit_vehicle_modal.dart';
import 'package:app_jht_front/features/vehicle/domain/entities/vehicle_entity.dart';
import 'package:app_jht_front/features/shared/presentation/mixins/navigation_helper_mixin.dart';

class VehiclePage extends StatefulWidget {
  final String userName;
  final String userRole;

  const VehiclePage({
    super.key,
    required this.userName,
    required this.userRole,
  });

  @override
  State<VehiclePage> createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage>
    with NavigationHelperMixin<VehiclePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _horizontalScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // Variables de paginación
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  // Variables de filtros
  String _searchQuery = '';
  Timer? _debounceTimer;
  String _filterEstado = 'Todos';

  @override
  void initState() {
    super.initState();
    context.read<VehicleBloc>().add(const VehicleEvent.cargarVehiculos());
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Métodos de paginación
  List<VehicleListData> _getCurrentPageVehicles(
    List<VehicleListData> allVehicles,
  ) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;

    if (startIndex >= allVehicles.length) {
      return [];
    }

    if (endIndex >= allVehicles.length) {
      return allVehicles.sublist(startIndex);
    }

    return allVehicles.sublist(startIndex, endIndex);
  }

  int _getTotalPages(int totalItems) {
    return (totalItems / _itemsPerPage).ceil();
  }

  void _resetPagination() {
    setState(() {
      _currentPage = 1;
    });
  }

  void _openAddVehicleModal() {
    AppNotification.info(context, 'Formulario de registro abierto');
    final vehicleBloc = context.read<VehicleBloc>();

    // Extraer placas existentes del estado actual del bloc
    final existingPlates = vehicleBloc.state.maybeWhen(
      vehiculosCargados: (vehicles) => vehicles.map((v) => v.placa).toList(),
      orElse: () => <String>[],
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocProvider.value(
        value: vehicleBloc,
        child: AddVehicleModal(
          existingPlates: existingPlates,
          onVehicleAdded: () {
            vehicleBloc.add(const VehicleEvent.cargarVehiculos());
            _resetPagination();
            AppNotification.success(
              context,
              'Vehículo registrado correctamente.',
            );
          },
        ),
      ),
    );
  }

  List<VehicleListData> _filterVehicles(List<VehicleListData> vehicles) {
    return vehicles.where((vehicle) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          vehicle.placa.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          vehicle.numeroVin.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          vehicle.marca.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          vehicle.modelo.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesEstado =
          _filterEstado == 'Todos' || vehicle.estado == _filterEstado;

      return matchesSearch && matchesEstado;
    }).toList();
  }

  void _handleMenuSelection(String itemTitle) {
    navigateToMenuPage(context, itemTitle, widget.userName, widget.userRole);
  }

  void _openEditVehicleModal(VehicleListData vehicle) {
    final vehicleBloc = context
        .read<VehicleBloc>(); // ← capturar ANTES del showDialog

    // Extraer placas existentes del estado actual del bloc
    final existingPlates = vehicleBloc.state.maybeWhen(
      vehiculosCargados: (vehicles) => vehicles.map((v) => v.placa).toList(),
      orElse: () => <String>[],
    );

    final vehicleEntity = VehicleEntity(
      vehiculoId: vehicle.vehiculoId,
      placa: vehicle.placa,
      marca: vehicle.marca,
      modelo: vehicle.modelo,
      numeroVin: vehicle.numeroVin,
      color: vehicle.color,
      numAsientos: vehicle.numAsientos,
      numEjes: vehicle.numEjes,
      pesoNeto: vehicle.pesoNeto,
      pesoBruto: vehicle.pesoBruto,
      cargaUtil: vehicle.cargaUtil,
      fechaFabricacion: DateTime.parse(vehicle.fechaFabricacion),
      largo: vehicle.largo,
      ancho: vehicle.ancho,
      alto: vehicle.alto,
      tipo: vehicle.tipo,
      kilometraje: vehicle.kilometraje,
      tarjetaUnicaCirculacion: vehicle.tarjetaUnicaCirculacion,
      fechaHabilitacionTUC: DateTime.parse(vehicle.fechaHabilitacionTUC),
      fechaVencimientoTUC: DateTime.parse(vehicle.fechaVencimientoTUC),
      fechaRegistro: DateTime.parse(vehicle.fechaRegistro),
      fechaBaja: vehicle.fechaBaja != null
          ? DateTime.parse(vehicle.fechaBaja!)
          : null,
      estado: vehicle.estado,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocProvider.value(
        value: vehicleBloc,
        child: EditVehicleModal(
          vehicle: vehicleEntity,
          existingPlates: existingPlates,
        ),
      ),
    );
  }

  void _showLoadingDialog(String message) {
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

  /*
  void _openAccesoriosModal(VehicleListData vehicle) {
    AppNotification.info(context, 'Accesorios de: \${vehicle.placa}');
  }
  */

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
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
      body: BlocListener<VehicleBloc, VehicleState>(
        listener: (context, state) {
          state.maybeWhen(
            actualizacionExitosa: (response) {
              AppNotification.success(context, response.message);
              context.read<VehicleBloc>().add(
                const VehicleEvent.cargarVehiculos(),
              );
              _resetPagination();
            },
            registroExitoso: (response) {
              // La notificación ya se muestra en el modal.
              // Solo recargar datos.
              context.read<VehicleBloc>().add(
                const VehicleEvent.cargarVehiculos(),
              );
              _resetPagination();
            },
            orElse: () {},
          );
        },
        child: Column(
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
                        padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderWithAddButton(isMobile),
                            const SizedBox(height: 16),
                            _buildMobileFilters(isMobile),
                            const SizedBox(height: 16),
                            _buildResponsiveTable(isMobile),
                            const SizedBox(height: 16),
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
          children: List.generate(
            3,
            (_) => Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderWithAddButton(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'VEHÍCULOS',
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
        InkWell(
          onTap: _openAddVehicleModal,
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
                  'AGREGAR VEHÍCULO',
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
        _buildSearchBar(),
      ],
    );
  }

  Widget _buildDesktopHeaderLayout() {
    return Row(
      children: [
        InkWell(
          onTap: _openAddVehicleModal,
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
                  'AGREGAR VEHÍCULO',
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
        Expanded(child: _buildSearchBar()),
      ],
    );
  }

  Widget _buildSearchBar() {
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
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _currentPage = 1;
                });
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Buscar por placa, VIN, marca o modelo...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                  _currentPage = 1;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMobileFilters(bool isMobile) {
    if (!isMobile) return const SizedBox.shrink();

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
            children: ['Todos', 'Activo', 'Inactivo'].map((estado) {
              return _buildFilterChip(estado);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterEstado == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterEstado = label;
          _currentPage = 1;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF303366),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF303366),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      shape: StadiumBorder(
        side: BorderSide(color: const Color(0xFF303366).withOpacity(0.3)),
      ),
    );
  }

  Widget _buildResponsiveTable(bool isMobile) {
    return BlocBuilder<VehicleBloc, VehicleState>(
      builder: (context, state) {
        return state.maybeWhen(
          loading: () => _buildLoadingWidget(),
          error: (message) => _buildErrorWidget(message),
          vehiculosCargados: (vehicles) =>
              _buildVehiclesContent(isMobile, vehicles),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF303366)),
            ),
            SizedBox(height: 16),
            Text('Cargando vehículos...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red[100]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.red[50],
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar vehículos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<VehicleBloc>().add(
              const VehicleEvent.cargarVehiculos(),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF303366),
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesContent(
    bool isMobile,
    List<VehicleListData> allVehicles,
  ) {
    final filteredVehicles = _filterVehicles(allVehicles);
    final totalPages = _getTotalPages(filteredVehicles.length);
    final currentPageVehicles = _getCurrentPageVehicles(filteredVehicles);

    if (filteredVehicles.isEmpty) {
      return _buildEmptyWidget();
    }

    return Column(
      children: [
        if (isMobile)
          _buildMobileCards(currentPageVehicles)
        else
          _buildDesktopTable(currentPageVehicles),
        const SizedBox(height: 16),
        _buildPagination(totalPages, filteredVehicles.length),
      ],
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(Icons.directions_car, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No se encontraron vehículos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          if (_searchQuery.isNotEmpty || _filterEstado != 'Todos') ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                  _filterEstado = 'Todos';
                  _currentPage = 1;
                });
              },
              child: const Text('Limpiar filtros'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileCards(List<VehicleListData> vehicles) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.placa,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF303366),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${vehicle.marca} ${vehicle.modelo}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: vehicle.estado == 'Activo'
                            ? Colors.green[50]
                            : Colors.red[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        vehicle.estado,
                        style: TextStyle(
                          fontSize: 11,
                          color: vehicle.estado == 'Activo'
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        Icons.vpn_key,
                        'VIN',
                        vehicle.numeroVin,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoRow(
                        Icons.palette,
                        'Color',
                        vehicle.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        Icons.calendar_today,
                        'Fabricación',
                        vehicle.fechaFabricacion,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoRow(
                        Icons.speed,
                        'KM',
                        '${vehicle.kilometraje} km',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _openEditVehicleModal(vehicle),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Editar'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                    ),
                    /*
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _openAccesoriosModal(vehicle),
                      icon: const Icon(Icons.build, size: 18),
                      label: const Text('Accesorios'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF303366),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    */
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTable(List<VehicleListData> vehicles) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Scrollbar(
            controller: _horizontalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  headingRowHeight: 50,
                  dataRowHeight: 55,
                  horizontalMargin: 16,
                  columnSpacing: 24,
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xFF303366),
                  ),
                  columns: const [
                    DataColumn(
                      label: SizedBox(
                        width: 100,
                        child: Text(
                          'Placa',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 150,
                        child: Text(
                          'VIN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 120,
                        child: Text(
                          'Marca/Modelo',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 80,
                        child: Text(
                          'Color',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 100,
                        child: Text(
                          'Fecha Fab.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 60,
                        child: Text(
                          'KM',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 80,
                        child: Text(
                          'Estado',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: SizedBox(
                        width: 100,
                        child: Text(
                          'Acciones',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                  rows: vehicles.map((vehicle) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            vehicle.placa,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Text(
                            vehicle.numeroVin,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DataCell(
                          Text(
                            '${vehicle.marca} ${vehicle.modelo}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Text(
                            vehicle.color,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Text(
                            vehicle.fechaFabricacion,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${vehicle.kilometraje}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: vehicle.estado == 'Activo'
                                  ? Colors.green[50]
                                  : Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              vehicle.estado,
                              style: TextStyle(
                                fontSize: 11,
                                color: vehicle.estado == 'Activo'
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                onPressed: () => _openEditVehicleModal(vehicle),
                                tooltip: 'Editar',
                              ),
                              /*
                      IconButton(
                        icon: const Icon(Icons.build, size: 20, color: Color(0xFF303366)),
                        onPressed: () => _openAccesoriosModal(vehicle),
                        tooltip: 'Ver accesorios',
                      ),
                      */
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPagination(int totalPages, int totalItems) {
    if (totalPages <= 1) return const SizedBox.shrink();

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
              Text(
                'Mostrando ${(_currentPage - 1) * _itemsPerPage + 1} al ${_currentPage * _itemsPerPage > totalItems ? totalItems : _currentPage * _itemsPerPage} de $totalItems vehículos',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Row(
                children: [
                  Text(
                    'Por página:',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 8),
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
                      '$_itemsPerPage',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPaginationButton(
                  'Anterior',
                  isActive: _currentPage > 1,
                  onPressed: _currentPage > 1
                      ? () {
                          setState(() {
                            _currentPage--;
                          });
                        }
                      : null,
                ),
                ...List.generate(totalPages, (index) {
                  final pageNumber = index + 1;
                  return _buildPaginationButton(
                    pageNumber.toString(),
                    isActive: _currentPage == pageNumber,
                    onPressed: () {
                      setState(() {
                        _currentPage = pageNumber;
                      });
                    },
                  );
                }),
                _buildPaginationButton(
                  'Siguiente',
                  isActive: _currentPage < totalPages,
                  onPressed: _currentPage < totalPages
                      ? () {
                          setState(() {
                            _currentPage++;
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton(
    String text, {
    bool isActive = false,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF303366) : Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : (onPressed != null ? Colors.grey[800] : Colors.grey[400]),
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCopyright() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
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
