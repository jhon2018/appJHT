// lib/features/vehicle/presentation/pages/vehicle_page.dart
import 'package:flutter/material.dart';
import 'package:app_jht_front/features/shared/presentation/widgets/side_menu.dart';

class VehiclePage extends StatefulWidget {
  final String userName;
  final String userRole;
  final int nivelAcceso;

  const VehiclePage({
    super.key,
    required this.userName,
    required this.userRole,
    required this.nivelAcceso,
  });

  @override
  State<VehiclePage> createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _horizontalScrollController = ScrollController();

  void _handleMenuSelection(String itemTitle) {
    ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text('Navegando a: $itemTitle'),
        backgroundColor: const Color(0xFF303366),
      ),
    );

    switch (itemTitle) {
      case 'Vehículo':
        break;
      case 'Mantenimiento':
        break;
    }
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
          nivelAcceso: widget.nivelAcceso,
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
              width: 4, height: 4,
              decoration: const BoxDecoration(
                color: Colors.black87, shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 4, height: 4,
              decoration: const BoxDecoration(
                color: Colors.black87, shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 4, height: 4,
              decoration: const BoxDecoration(
                color: Colors.black87, shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(String nrVin, String placa, String fechaFabrica) {
    return DataRow(cells: [
      DataCell(Container(
        child: Text(
          nrVin,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
      )),
      DataCell(Container(
        child: Text(
          placa,
          style: const TextStyle(fontSize: 12),
        ),
      )),
      DataCell(Container(
        child: Text(
          fechaFabrica,
          style: const TextStyle(fontSize: 12),
        ),
      )),
      DataCell(Container(
        child: const Text(
          'Toyota',
          style: TextStyle(fontSize: 12),
        ),
      )),
      DataCell(Container(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[300]!),
          ),
          child: const Text(
            'Activo',
            style: TextStyle(
              fontSize: 11,
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      )),
      DataCell(Container(
        child: InkWell(
          onTap: () {
            print('Editar vehículo con VIN: $nrVin');
          },
          child: const Padding(
            padding: EdgeInsets.all(4.0),
            child: Icon(Icons.edit, color: Colors.grey, size: 18),
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
          'VEHÍCULO',
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
        Container(
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
                    hintText: 'Buscar vehículo...',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
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

  Widget _buildDesktopHeaderLayout() {
    return Row(
      children: [
        // Botón AGREGAR - tamaño fijo
        Container(
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
                      hintText: 'Buscar por placa, VIN o marca...',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
    if (isMobile) {
      // Versión móvil sin scroll horizontal
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: DataTable(
          headingRowHeight: 50,
          dataRowHeight: 50,
          horizontalMargin: 12,
          columnSpacing: 8,
          headingRowColor: WidgetStateProperty.all(const Color(0xFF303366)),
          columns: const [
            DataColumn(
              label: Expanded(
                child: Text('Nr. VIN', 
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text('Placa', 
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text('Fecha', 
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text('Marca', 
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text('Estado', 
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text('Acción', 
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          rows: [
            _buildDataRow('152560005', 'ABC-123', '15/09/18'),
            _buildDataRow('178492626', 'DEF-456', '28/08/18'),
            _buildDataRow('115445589', 'GHI-789', '10/08/18'),
            _buildDataRow('475892665', 'JKL-012', '05/08/18'),
            _buildDataRow('395657782', 'MNO-345', '22/07/18'),
          ],
        ),
      );
    } else {
      // Versión desktop con scroll horizontal
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
              width: 1200, // Ancho fijo para desktop
              padding: const EdgeInsets.all(8),
              child: DataTable(
                headingRowHeight: 50,
                dataRowHeight: 50,
                horizontalMargin: 16,
                columnSpacing: 24,
                headingRowColor: WidgetStateProperty.all(const Color(0xFF303366)),
                columns: const [
                  DataColumn(
                    label: SizedBox(
                      width: 140,
                      child: Text('Nr. VIN', 
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 120,
                      child: Text('Placa', 
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 140,
                      child: Text('Fecha Fábrica', 
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 120,
                      child: Text('Marca', 
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 120,
                      child: Text('Estado', 
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: 100,
                      child: Text('Acciones', 
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                      ),
                    ),
                  ),
                ],
                rows: [
                  _buildDataRow('152560005', 'ABC-123', '15/09/2018'),
                  _buildDataRow('178492626', 'DEF-456', '28/08/2018'),
                  _buildDataRow('115445589', 'GHI-789', '10/08/2018'),
                  _buildDataRow('475892665', 'JKL-012', '05/08/2018'),
                  _buildDataRow('395657782', 'MNO-345', '22/07/2018'),
                ],
              ),
            ),
          ),
        ),
      );
    }
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
                'Mostrando 1 al 5 de 25 vehículos',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Row(
                children: [
                  Text('Por página:', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('5', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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