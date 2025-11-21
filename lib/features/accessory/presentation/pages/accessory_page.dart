// lib/features/accessory/presentation/pages/accessory_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/shared/presentation/widgets/side_menu.dart';
import 'package:app_jht_front/features/accessory/presentation/widgets/add_accessory_modal.dart';
import 'package:app_jht_front/features/accessory/presentation/bloc/accessory_bloc.dart';
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

  // VARIABLES PARA LOS DATOS DE API
  List<VehiculoModel> _vehiculos = [];
  String? _selectedVehiculoId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Cargar datos iniciales cuando el widget se inicializa
    _cargarDatosIniciales();
  }

  void _cargarDatosIniciales() {
    context.read<AccessoryBloc>().add(LoadVehiculosEvent());
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
              duration: const Duration(seconds: 5),
            ),
          );
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
        if (state is AccessoryLoading) {
          setState(() => _isLoading = true);
        } else if (state is VehiculosLoaded) {
          setState(() {
            _vehiculos = state.vehiculos;
            _isLoading = false;
          });
        } else if (state is AccessoryError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
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
                    actions: [
                      _buildMenuButton(),
                    ],
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

  // MÉTODO PARA DROPDOWN VEHÍCULO MÓVIL
  Widget _buildMobileVehiculoDropdown() {
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
          width: double.infinity,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedVehiculoId,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF303366)),
              hint: _isLoading 
                  ? const Text('Cargando...', style: TextStyle(color: Colors.grey))
                  : const Text('Seleccione Vehículo'),
              items: _vehiculos.map<DropdownMenuItem<String>>((vehiculo) {
                return DropdownMenuItem<String>(
                  value: vehiculo.id.toString(),
                  child: Text(
                    vehiculo.placa,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: _isLoading ? null : (value) {
                setState(() => _selectedVehiculoId = value);
              },
            ),
          ),
        ),
      ],
    );
  }

  // MÉTODO PARA DROPDOWN VEHÍCULO DESKTOP
  Widget _buildDesktopVehiculoDropdown() {
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
            child: DropdownButton<String>(
              value: _selectedVehiculoId,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF303366)),
              hint: _isLoading 
                  ? const Text('Cargando...', style: TextStyle(color: Colors.grey))
                  : const Text('Seleccione Vehículo'),
              items: _vehiculos.map<DropdownMenuItem<String>>((vehiculo) {
                return DropdownMenuItem<String>(
                  value: vehiculo.id.toString(),
                  child: Text(
                    vehiculo.placa,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: _isLoading ? null : (value) {
                setState(() => _selectedVehiculoId = value);
              },
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

  DataRow _buildDataRow(String codigoFabricante, String nombre, String fechaInstalacion, String unidadMedida) {
    return DataRow(cells: [
      DataCell(Container(
        child: Text(
          codigoFabricante,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
      )),
      DataCell(Container(
        child: Text(
          nombre,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
      )),
      DataCell(Container(
        child: Text(
          fechaInstalacion,
          style: const TextStyle(fontSize: 12),
        ),
      )),
      DataCell(Container(
        child: Text(
          unidadMedida,
          style: const TextStyle(fontSize: 12),
        ),
      )),
        DataCell(Container(
          child: InkWell(
            onTap: () {
              print('Editar vehículo con VIN: $codigoFabricante');
            },
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.remove_red_eye, color: Colors.grey, size: 18),
            ),
          ),
        )),
    ]);
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
        
        // ComboBox Vehículo (Móvil)
        _buildMobileVehiculoDropdown(),
        const SizedBox(height: 12),
        
        // Barra de búsqueda - Toma todo el ancho
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: const Row(
            children: [
              SizedBox(width: 16),
              Icon(Icons.search, color: Colors.grey, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Buscar accesorio...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeaderLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fila 1: Botón y Barra de búsqueda
        Row(
          children: [
            // Botón AGREGAR ACCESORIO
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
            // Barra de búsqueda - ocupa el espacio restante
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 16),
                    Icon(Icons.search, color: Colors.grey, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Buscar por código, nombre o fabricante...',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Fila 2: ComboBox Vehículo para Desktop
        Row(
          children: [
            // ComboBox Vehículo
            Expanded(
              child: _buildDesktopVehiculoDropdown(),
            ),
            const SizedBox(width: 12),
            // Espacio vacío para mantener el layout
            Expanded(child: Container()),
            const SizedBox(width: 12),
            Expanded(child: Container()),
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

  Widget _buildMobileFilters() {
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
              _buildFilterChip('Todos'),
              _buildFilterChip('Activos'),
              _buildFilterChip('Inactivos'),
              _buildFilterChip('En Mantenimiento'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveTable(bool isMobile) {
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
                          width: 110,
                          child: Text('Código fabricante', 
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 120,
                          child: Text('Nombre', 
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 100,
                          child: Text('Fecha instalacion', 
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 90,
                          child: Text('Unidad media', 
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 70,
                          child: Text('Detalle', 
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ]
                  : const [
                      DataColumn(
                        label: SizedBox(
                          width: 150,
                          child: Text('Código Fabricante', 
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 180,
                          child: Text('Nombre', 
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 140,
                          child: Text('Fecha Instalación', 
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 120,
                          child: Text('Unidad Medida', 
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 100,
                          child: Text('Detalle', 
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                          ),
                        ),
                      ),
                    ],
              rows: [
                _buildDataRow('FAB-001', isMobile ? 'GPS Tracker' : 'Sistema GPS Tracker', isMobile ? '15/09/23' : '15/09/2023', 'Unidad'),
                _buildDataRow('FAB-002', isMobile ? 'Cámara Atrás' : 'Cámara Marcha Atrás HD', isMobile ? '28/08/23' : '28/08/2023', 'Unidad'),
                _buildDataRow('FAB-003', isMobile ? 'Alarma' : 'Alarma Vehicular', isMobile ? '10/08/23' : '10/08/2023', 'Unidad'),
                _buildDataRow('FAB-004', isMobile ? 'Sensores' : 'Sensores de Parqueo', isMobile ? '05/08/23' : '05/08/2023', 'Set'),
                _buildDataRow('FAB-005', isMobile ? 'Radio' : 'Radio Comunicación', isMobile ? '22/07/23' : '22/07/2023', 'Unidad'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPagination() {
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
                'Mostrando 1 al 5 de 25 accesorios',
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
                      '5',
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
                _buildPaginationButton('Anterior', isActive: false),
                _buildPaginationButton('1', isActive: true),
                _buildPaginationButton('2', isActive: false),
                _buildPaginationButton('3', isActive: false),
                _buildPaginationButton('4', isActive: false),
                _buildPaginationButton('5', isActive: false),
                _buildPaginationButton('Siguiente', isActive: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton(String text, {bool isActive = false}) {
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