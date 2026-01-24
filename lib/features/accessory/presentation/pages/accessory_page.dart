// lib/features/accessory/presentation/pages/accessory_page.dart
// description: Página principal de accesorios con menú lateral, tabla responsiva y paginación.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:app_jht_front/features/shared/presentation/widgets/side_menu.dart';
import 'package:app_jht_front/features/accessory/presentation/widgets/add_accessory_modal.dart';
import 'package:app_jht_front/features/accessory/presentation/widgets/detalle_accessory_modal.dart';
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

  // Variables para el combobox de vehículos
  List<VehiculoModel> _vehiclesList = [];
  VehiculoModel? _selectedVehicle;
  
  // Variables para paginación
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _cargarVehiculos();
  }

  void _cargarVehiculos() {
    context.read<AccessoryBloc>().add(LoadVehiculosEvent());
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Color _getRowColor(AccesorioModel acc) {
    if (acc.ultimoMantenimiento == null) return Colors.transparent;

    final mant = acc.ultimoMantenimiento!;

    if (mant.proximaFecha != null) {
      final proxima = DateTime.tryParse(mant.proximaFecha!);
      if (proxima != null && proxima.difference(DateTime.now()).inDays <= 15) {
        return Colors.red.withOpacity(0.15);
      }
    }

    return Colors.transparent;
  }

  void _openAddAccessoryModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddAccessoryModal(
        onAccessoryAdded: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Accesorio agregado exitosamente'),
              backgroundColor: const Color(0xFF303366),
              duration: const Duration(seconds: 7),
            ),
          );
          // Recargar accesorios si hay un vehículo seleccionado
          if (_selectedVehicle != null) {
            context.read<AccessoryBloc>().add(
              OnFetchAccesoriosByVehiculo(_selectedVehicle!.id),
            );
          }
        },
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

  // Método para obtener los accesorios de la página actual
  List<AccesorioModel> _getCurrentPageItems(List<AccesorioModel> allItems) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return allItems.sublist(
      startIndex,
      endIndex > allItems.length ? allItems.length : endIndex,
    );
  }

  // Método para calcular el total de páginas
  int _getTotalPages(int totalItems) {
    return (totalItems / _itemsPerPage).ceil();
  }

  // Método para mostrar diálogo de carga con mensaje personalizado
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return BlocListener<AccessoryBloc, AccessoryState>(
      listener: (context, state) {
        // Mostrar loading cuando se cargan vehículos
        if (state is VehiculosLoading) {
          _showLoadingDialog('Cargando lista de vehículos...');
        } else if (state is VehiculosLoaded) {
          // Cerrar diálogo de loading si está abierto
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          setState(() {
            _vehiclesList = state.vehiculos;
          });
        } 
        
        // Mostrar loading cuando se cargan accesorios por vehículo
        else if (state is AccesoriosByVehiculoLoading) {
          if (_selectedVehicle != null) {
            _showLoadingDialog('Cargando accesorios del vehículo ${_selectedVehicle!.placa}...');
          } else {
            _showLoadingDialog('Cargando accesorios...');
          }
        } else if (state is AccesoriosByVehiculoLoaded) {
          // Cerrar diálogo de loading si está abierto
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
        
        else if (state is AccessoryError) {
          // Cerrar diálogo de loading si está abierto
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }

        // Loading cuando se consulta el detalle del accesorio
        if (state is DetalleAccesorioLoading) {
          _showLoadingDialog('Cargando información detallada del accesorio...');
        }

        // Cuando llega el detalle
        if (state is DetalleAccesorioLoaded) {
          // Cerrar diálogo de loading si está abierto
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          showDetalleAccesorioModal(
            context,
            state.detalle,
            0.0,
          );
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

  // MÉTODO PARA DROPDOWN MÓVIL
  Widget _buildMobileDropdown({
    required String label,
    required VehiculoModel? value,
    required List<VehiculoModel> items,
    required Function(VehiculoModel?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF303366),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<VehiculoModel>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF303366)),
              hint: _vehiclesList.isEmpty
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
                  : const Text('Seleccione vehículo'),
              items: items.map((VehiculoModel vehicle) {
                return DropdownMenuItem<VehiculoModel>(
                  value: vehicle,
                  child: Text(
                    vehicle.placa,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // MÉTODO PARA DROPDOWN DESKTOP
  Widget _buildDesktopDropdown({
    required String label,
    required VehiculoModel? value,
    required List<VehiculoModel> items,
    required Function(VehiculoModel?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF303366),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<VehiculoModel>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF303366)),
              hint: _vehiclesList.isEmpty
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
                  : const Text('Seleccione vehículo'),
              items: items.map((VehiculoModel vehicle) {
                return DropdownMenuItem<VehiculoModel>(
                  value: vehicle,
                  child: Text(
                    vehicle.placa,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton() {
    return InkWell(
      onTap: () {
        _scaffoldKey.currentState?.openEndDrawer();
      },
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
        // Botón AGREGAR - Toma todo el ancho
        InkWell(
          onTap: _openAddAccessoryModal,
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
                  'AGREGAR ACCESORIO',
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
        
        // ComboBox Seleccionar Vehículo (Móvil)
        _buildMobileDropdown(
          label: 'Seleccionar Vehículo',
          value: _selectedVehicle,
          items: _vehiclesList,
          onChanged: (value) {
            setState(() => _selectedVehicle = value);
            if (value != null) {
              // Reiniciar a página 1 cuando se selecciona nuevo vehículo
              _currentPage = 1;
              context.read<AccessoryBloc>().add(
                OnFetchAccesoriosByVehiculo(value.id),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildDesktopHeaderLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fila 1: Botón AGREGAR
        Row(
          children: [
            // Botón AGREGAR - tamaño fijo
            InkWell(
              onTap: _openAddAccessoryModal,
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
                      'AGREGAR ACCESORIO',
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
            // ComboBox Seleccionar Vehículo - ocupa el espacio restante
            Expanded(
              child: _buildDesktopDropdown(
                label: 'Seleccionar Vehículo',
                value: _selectedVehicle,
                items: _vehiclesList,
                onChanged: (value) {
                  setState(() => _selectedVehicle = value);
                  if (value != null) {
                    // Reiniciar a página 1 cuando se selecciona nuevo vehículo
                    _currentPage = 1;
                    context.read<AccessoryBloc>().add(
                      OnFetchAccesoriosByVehiculo(value.id),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF303366),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }



  Widget _buildResponsiveTable(bool isMobile) {
    return BlocBuilder<AccessoryBloc, AccessoryState>(
      buildWhen: (previous, current) => 
          current is AccesoriosByVehiculoLoaded || 
          current is AccesoriosByVehiculoLoading,
      builder: (context, state) {
        if (state is AccesoriosByVehiculoLoading) {
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
            ),
          );
        }

        List<AccesorioModel> accesorios = [];
        if (state is AccesoriosByVehiculoLoaded) {
          accesorios = state.accesorios;
        }

        // Verificar si hay datos
        if (accesorios.isEmpty) {
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
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        // Obtener solo los accesorios de la página actual
        final currentPageAccesorios = _getCurrentPageItems(accesorios);

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
                width: isMobile ? 700 : 1000,
                padding: const EdgeInsets.all(8),
                child: DataTable(
                  headingRowHeight: 50,
                  dataRowHeight: 50,
                  horizontalMargin: isMobile ? 12 : 16,
                  columnSpacing: isMobile ? 8 : 24,
                  headingRowColor: WidgetStateProperty.all(const Color(0xFF303366)),
                  columns: isMobile 
                      ? const [
                          DataColumn(
                            label: SizedBox(
                              width: 130,
                              child: Text(
                                'Tipo / Nombre', 
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 90,
                              child: Text(
                                'Marca', 
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 100,
                              child: Text(
                                'Instalación', 
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 120,
                              child: Text(
                                'Próx. Mantenimiento', 
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 80,
                              child: Text(
                                'Estado', 
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 70,
                              child: Text(
                                'Acción', 
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ]
                      : const [
                          DataColumn(
                            label: SizedBox(
                              width: 180,
                              child: Text(
                                'Tipo / Nombre', 
                                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 120,
                              child: Text(
                                'Marca', 
                                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 140,
                              child: Text(
                                'Instalación', 
                                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 160,
                              child: Text(
                                'Próximo Mantenimiento', 
                                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 100,
                              child: Text(
                                'Estado', 
                                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                              ),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 100,
                              child: Text(
                                'Acción', 
                                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                              ),
                            ),
                          ),
                        ],
                  rows: currentPageAccesorios.map((acc) => _buildDataRow(acc, isMobile)).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildDataRow(AccesorioModel acc, bool isMobile) {
    return DataRow(
      color: WidgetStateProperty.all(_getRowColor(acc)),
      cells: [
        DataCell(Container(
          child: Text(
            acc.tipoNombre,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        )),
        DataCell(Container(
          child: Text(
            acc.marca ?? '-',
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        )),
        DataCell(Container(
          child: Text(
            DateFormat('dd/MM/yyyy').format(acc.fechaInstalacion),
            style: const TextStyle(fontSize: 12),
          ),
        )),
        DataCell(Container(
          child: Text(
            acc.ultimoMantenimiento?.proximaFecha ?? 'No programada',
            style: const TextStyle(fontSize: 12),
          ),
        )),
        DataCell(Container(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: acc.ultimoMantenimiento?.estado == 'Pendiente' 
                  ? Colors.orange 
                  : Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              acc.ultimoMantenimiento?.estado ?? 'Activo',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        )),
        DataCell(Container(
          child: InkWell(
            onTap: () {
              context.read<AccessoryBloc>().add(
                OnFetchDetalleAccesorio(acc.accesorioId),
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.remove_red_eye, color: Color(0xFF303366), size: 18),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildPagination() {
    return BlocBuilder<AccessoryBloc, AccessoryState>(
      builder: (context, state) {
        List<AccesorioModel> accesorios = [];
        if (state is AccesoriosByVehiculoLoaded) {
          accesorios = state.accesorios;
        }

        final totalAccesorios = accesorios.length;
        final totalPages = _getTotalPages(totalAccesorios);
        final startItem = ((_currentPage - 1) * _itemsPerPage) + 1;
        final endItem = (_currentPage * _itemsPerPage) > totalAccesorios 
            ? totalAccesorios 
            : (_currentPage * _itemsPerPage);

        // Generar números de página
        List<int> pageNumbers = [];
        for (int i = 1; i <= totalPages; i++) {
          pageNumbers.add(i);
        }

        // Si no hay datos, no mostrar paginación
        if (totalAccesorios == 0) {
          return const SizedBox.shrink();
        }

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
                    'Mostrando $startItem al $endItem de $totalAccesorios accesorios',
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
                    // Botón Anterior
                    InkWell(
                      onTap: _currentPage > 1
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                            }
                          : null,
                      child: _buildPaginationButton(
                        'Anterior', 
                        isActive: _currentPage > 1,
                      ),
                    ),
                    
                    // Números de página
                    ...pageNumbers.map((pageNumber) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _currentPage = pageNumber;
                          });
                        },
                        child: _buildPaginationButton(
                          pageNumber.toString(),
                          isActive: _currentPage == pageNumber,
                        ),
                      );
                    }).toList(),
                    
                    // Botón Siguiente
                    InkWell(
                      onTap: _currentPage < totalPages
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                            }
                          : null,
                      child: _buildPaginationButton(
                        'Siguiente', 
                        isActive: _currentPage < totalPages,
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

  Widget _buildPaginationButton(String text, {bool isActive = false, bool isEnabled = true}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF303366) : Colors.white,
        border: Border.all(
          color: isEnabled ? Colors.grey[400]! : Colors.grey[200]!,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive 
              ? Colors.white 
              : (isEnabled ? Colors.grey[600] : Colors.grey[300]),
          fontSize: 12,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
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
          '© 2025 JHT Transport Company\nTodos los derechos reservados.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.4),
        ),
      ),
    );
  }
}