// lib/features/accessory/presentation/pages/accessory_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/shared/presentation/widgets/side_menu.dart';
import 'package:app_jht_front/features/accessory/presentation/widgets/add_accessory_modal.dart';
import 'package:app_jht_front/features/accessory/presentation/bloc/accessory_bloc.dart';
import 'package:app_jht_front/features/accessory/data/models/vehiculo_model.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_model.dart'; // Asegúrate de importar esto
import 'package:intl/intl.dart';

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

  List<VehiculoModel> _vehiculos = [];
  VehiculoModel?
  _selectedVehiculo; // Cambiado a objeto completo para lógica de KM
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  void _cargarDatosIniciales() {
    context.read<AccessoryBloc>().add(LoadVehiculosEvent());
  }

  // --- LÓGICA DE ALERTA DE MANTENIMIENTO (REQF07) ---
Color _getRowColor(AccesorioModel acc) {
  if (acc.ultimoMantenimiento == null) return Colors.transparent;
  
  final mant = acc.ultimoMantenimiento!;
  
  // Alerta por Fecha (15 días)
  if (mant.proximaFecha != null) {
    final proxima = DateTime.tryParse(mant.proximaFecha!);
    if (proxima != null && proxima.difference(DateTime.now()).inDays <= 15) {
      return Colors.red.withOpacity(0.15);
    }
  }

  // Alerta por Kilometraje (usando proximoKilometraje de tu modelo)
  if (mant.proximoKilometraje != null && _selectedVehiculo != null) {
    final kmRestante = mant.proximoKilometraje! - _selectedVehiculo!.kilometraje;
    if (kmRestante <= 500) {
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
          // Si hay un vehículo seleccionado, refrescar la lista
          if (_selectedVehiculo != null) {
            context.read<AccessoryBloc>().add(
              OnFetchAccesoriosByVehiculo(_selectedVehiculo!.id),
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

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return BlocListener<AccessoryBloc, AccessoryState>(
      listener: (context, state) {
        if (state is VehiculosLoading) {
          setState(() => _isLoading = true);
        } else if (state is VehiculosLoaded) {
          setState(() {
            _vehiculos = state.vehiculos;
            _isLoading = false;
          });
        } else if (state is AccessoryError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
                            _buildMobileFilters(),
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

  // --- WIDGETS DE UI ACTUALIZADOS ---

  Widget _buildDropdownVehiculo(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vehículo',
          style: TextStyle(
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
              value: _selectedVehiculo,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF303366)),
              hint: Text(_isLoading ? 'Cargando...' : 'Seleccione Vehículo'),
              items: _vehiculos
                  .map((v) => DropdownMenuItem(value: v, child: Text(v.placa)))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedVehiculo = value);
                if (value != null) {
                  context.read<AccessoryBloc>().add(
                    OnFetchAccesoriosByVehiculo(value.id),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveTable(bool isMobile) {
    return BlocBuilder<AccessoryBloc, AccessoryState>(
      buildWhen: (p, c) =>
          c is AccesoriosByVehiculoLoaded || c is AccesoriosByVehiculoLoading,
      builder: (context, state) {
        if (state is AccesoriosByVehiculoLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        List<AccesorioModel> accesorios = [];
        if (state is AccesoriosByVehiculoLoaded) {
          accesorios = state.accesorios;
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Scrollbar(
            controller: _horizontalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: Container(
                width: isMobile ? 750 : 1100, // Ajustado para nuevas columnas
                padding: const EdgeInsets.all(8),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xFF303366),
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Tipo / Nombre',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Marca',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Instalación',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Próx. Mantenimiento',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Estado',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Acción',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                  rows: accesorios
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

  DataRow _buildDataRow(AccesorioModel acc, bool isMobile) {
    return DataRow(
      color: WidgetStateProperty.all(
        _getRowColor(acc),
      ), // Aquí se aplica el rojo
      cells: [
        DataCell(
          Text(
            acc.tipoNombre,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        DataCell(Text(acc.marca ?? '-', style: const TextStyle(fontSize: 12))),
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
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: acc.ultimoMantenimiento?.estado == 'Pendiente'
                  ? Colors.orange
                  : Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              acc.ultimoMantenimiento?.estado ?? 'OK',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
DataCell(IconButton(
  icon: const Icon(Icons.remove_red_eye, color: Colors.grey, size: 20),
  onPressed: () {
    // USAMOS accesorioId que es como está en tu modelo
    context.read<AccessoryBloc>().add(OnFetchDetalleAccesorio(acc.accesorioId));
  },
))
      ],
    );
  }

  // --- OTROS MÉTODOS DE SOPORTE MANTENIDOS ---

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
        ElevatedButton.icon(
          onPressed: _openAddAccessoryModal,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'AGREGAR ACCESORIO',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF303366),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 12),
        _buildDropdownVehiculo(true),
      ],
    );
  }

  Widget _buildDesktopHeaderLayout() {
    return Row(
      children: [
        SizedBox(
          width: 220,
          child: ElevatedButton.icon(
            onPressed: _openAddAccessoryModal,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('AGREGAR', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF303366),
              padding: const EdgeInsets.all(18),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: _buildDropdownVehiculo(false)),
      ],
    );
  }

  Widget _buildMenuButton() {
    return IconButton(
      icon: const Icon(Icons.more_vert, color: Colors.black87),
      onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
    );
  }

  Widget _buildMobileFilters() => Container(); // Implementar si es necesario
  Widget _buildPagination() => Container(); // Implementar si es necesario
  Widget _buildCopyright() => Padding(
    padding: const EdgeInsets.all(16.0),
    child: Text(
      '© 2026 JHT Transport - Todos los derechos reservados',
      style: TextStyle(color: Colors.grey[600], fontSize: 12),
    ),
  );
}
