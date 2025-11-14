// lib/features/accessory/presentation/pages/accessory_page.dart
// description: Página principal de accesorios con menú lateral, tabla responsiva y paginación.

import 'package:flutter/material.dart';
import 'package:app_jht_front/features/shared/presentation/widgets/side_menu.dart';
import 'package:app_jht_front/features/accessory/presentation/widgets/add_accessory_modal.dart';

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

  // NUEVAS VARIABLES PARA LOS COMBOBOX
  String? _selectedVehicle;
  String? _selectedAccessoryType;
  
  // LISTAS DE OPCIONES (puedes cargarlas desde API después)
  final List<String> _vehicles = [
    'ABC-123 - Toyota Hilux',
    'DEF-456 - Nissan Frontier', 
    'GHI-789 - Ford Ranger',
    'JKL-012 - Chevrolet S10',
    'MNO-345 - Toyota Corolla'
  ];
  
  final List<String> _accessoryTypes = [
    'Sistema GPS',
    'Cámaras',
    'Alarmas',
    'Sensores',
    'Sistema de Audio',
    'Iluminación',
    'Accesorios de Seguridad'
  ];

void _openAddAccessoryModal() {
  showDialog(
    context: context,
    barrierDismissible: false, // ← ESTA LÍNEA IMPIDE CERRAR HACIENDO CLIC AFUERA
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
    );
  }


// MÉTODO PARA DROPDOWN MÓVIL
Widget _buildMobileDropdown({
  required String label,
  required String? value,
  required List<String> items,
  required Function(String?) onChanged,
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
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF303366)),
            hint: Text('Seleccione $label'),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
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
  required String? value,
  required List<String> items,
  required Function(String?) onChanged,
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
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF303366)),
            hint: Text('Seleccione $label'),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
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
      
      // NUEVO: ComboBox Seleccionar Vehículo (Móvil)
      _buildMobileDropdown(
        label: 'Seleccionar Vehículo',
        value: _selectedVehicle,
        items: _vehicles,
        onChanged: (value) {
          setState(() => _selectedVehicle = value);
        },
      ),
      const SizedBox(height: 12),
      
      // NUEVO: ComboBox Seleccionar Accesorio (Móvil)
      _buildMobileDropdown(
        label: 'Seleccionar Accesorio', 
        value: _selectedAccessoryType,
        items: _accessoryTypes,
        onChanged: (value) {
          setState(() => _selectedAccessoryType = value);
        },
      ),
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
      // Fila 1: Botón AGREGAR y Barra de búsqueda
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
      
      // Fila 2: ComboBoxes para Desktop
      Row(
        children: [
          // ComboBox Seleccionar Vehículo
          Expanded(
            child: _buildDesktopDropdown(
              label: 'Seleccionar Vehículo',
              value: _selectedVehicle,
              items: _vehicles,
              onChanged: (value) {
                setState(() => _selectedVehicle = value);
              },
            ),
          ),
          const SizedBox(width: 12),
          
          // ComboBox Seleccionar Accesorio
          Expanded(
            child: _buildDesktopDropdown(
              label: 'Seleccionar Accesorio',
              value: _selectedAccessoryType,
              items: _accessoryTypes,
              onChanged: (value) {
                setState(() => _selectedAccessoryType = value);
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
          width: isMobile ? 700 : 1000, // Ancho ajustado según dispositivo
          padding: const EdgeInsets.all(8),
          child: DataTable(
            headingRowHeight: 50,
            dataRowHeight: 50,
            horizontalMargin: isMobile ? 12 : 16,
            columnSpacing: isMobile ? 8 : 24,
            headingRowColor: WidgetStateProperty.all(const Color(0xFF303366)),
            columns: isMobile 
                ? const [
                    // COLUMNAS MÓVIL (más compactas)
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
                    // COLUMNAS DESKTOP
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
