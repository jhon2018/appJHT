// lib/features/supplier/presentation/pages/supplier_page.dart
// description: Página principal de proveedores con menú lateral, tabla responsiva y paginación.

import 'package:flutter/material.dart';
import 'package:app_jht_front/features/shared/presentation/widgets/side_menu.dart';
import 'package:app_jht_front/features/supplier/presentation/widgets/add_supplier_modal.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _horizontalScrollController = ScrollController();

void _openAddSupplierModal() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AddSupplierModal(
      onSupplierAdded: () {
        // TODO: Implementar refresh de lista
        print('Proveedor agregado - refrescar lista');
        // Aquí luego puedes llamar a:
        // _refreshSuppliers();
        // O mostrar snackbar:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Lista de proveedores actualizada'),
            backgroundColor: const Color(0xFF303366),
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

  DataRow _buildDataRow(int nr, String razonSocial, String direccion, 
                        String marca, String telefono, String ruc) {
    return DataRow(cells: [
      DataCell(Text(
        nr.toString(),
        style: const TextStyle(fontSize: 12),
      )),
      DataCell(Container(
        child: Text(
          razonSocial,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
      )),
      DataCell(Container(
        child: Text(
          direccion,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
      )),
      DataCell(Text(
        marca,
        style: const TextStyle(fontSize: 12),
      )),
      DataCell(Text(
        telefono,
        style: const TextStyle(fontSize: 12),
      )),
      DataCell(Text(
        ruc,
        style: const TextStyle(fontSize: 12),
      )),
      DataCell(Container(
        child: InkWell(
          onTap: () {
            print('Ver detalle del proveedor: $razonSocial');
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
          'PROVEEDORES',
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
                    hintText: 'Buscar por RUC, razón social o teléfono...',
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
                          hintText: 'Buscar por RUC, razón social o teléfono...',
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
              _buildFilterChip('Con deuda'),
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
                      // COLUMNAS MÓVIL
                      DataColumn(
                        label: SizedBox(
                          width: 50,
                          child: Text('Nr', 
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 120,
                          child: Text('Razón social', 
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 100,
                          child: Text('Dirección', 
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 80,
                          child: Text('Marca', 
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 90,
                          child: Text('Teléfono', 
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 80,
                          child: Text('RUC', 
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
                          width: 60,
                          child: Text('Nr', 
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 180,
                          child: Text('Razón Social', 
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 200,
                          child: Text('Dirección', 
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
                          child: Text('Teléfono', 
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 120,
                          child: Text('RUC', 
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
                _buildDataRow(1, 'Importadora ABC S.A.', 'Av. Principal 123', 'Toyota', '987654321', '20123456789'),
                _buildDataRow(2, 'Distribuidora XYZ E.I.R.L.', 'Calle Comercio 456', 'Nissan', '912345678', '10456789012'),
                _buildDataRow(3, 'Automotriz QRS S.A.C.', 'Jr. Industria 789', 'Ford', '934567890', '20678901234'),
                _buildDataRow(4, 'Repuestos MNO S.R.L.', 'Av. Libertad 101', 'Chevrolet', '956789012', '30890123456'),
                _buildDataRow(5, 'Servicios TUV S.A.', 'Calle Servicios 202', 'Mitsubishi', '978901234', '40123456789'),
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
                'Mostrando 1 al 5 de 25 proveedores',
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