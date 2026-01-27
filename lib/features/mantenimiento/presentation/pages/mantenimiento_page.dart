// Ruta: lib/features/mantenimiento/presentation/pages/mantenimiento_page.dart
import 'package:app_jht_front/features/mantenimiento/presentation/bloc/mantenimiento_event.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/bloc/mantenimiento_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/shared/presentation/widgets/side_menu.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/widgets/add_mantenimiento_modal.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/widgets/edit_mantenimiento_modal.dart';
import 'package:app_jht_front/features/mantenimiento/data/models/mantenimiento_model.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/bloc/mantenimiento_bloc.dart';

// ... resto del código

class MantenimientoPage extends StatefulWidget {
  final String userName;
  final String userRole;

  const MantenimientoPage({
    super.key,
    required this.userName,
    required this.userRole,
  });

  @override
  State<MantenimientoPage> createState() => _MantenimientoPageState();
}

class _MantenimientoPageState extends State<MantenimientoPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // El bloc se inicializará automáticamente cuando se construya el BlocProvider
  }

// En mantenimiento_page.dart, en el método _buildDataRow:
// En mantenimiento_page.dart, en el método _openEditMantenimientoModal:
void _openEditMantenimientoModal(MantenimientoModel mantenimiento) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => BlocProvider.value(
      value: context.read<MantenimientoBloc>(), // ✅ ESTA ES LA LÍNEA CLAVE
      child: EditMantenimientoModal(
        mantenimiento: mantenimiento,
        onMantenimientoActualizado: () {
          // La lista se actualizará automáticamente a través del BLoC
          context.read<MantenimientoBloc>().add(RefreshMantenimientosEvent());
        },
      ),
    ),
  );
}

DataRow _buildDataRow(MantenimientoModel mantenimiento) {
  return DataRow(cells: [
    // ... otras celdas ...
    DataCell(Container(
      child: InkWell(
        onTap: () {
          _openEditMantenimientoModal(mantenimiento);
        },
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Icon(Icons.edit, color: Colors.grey, size: 18),
        ),
      ),
    )),
  ]);
}

  void _openAddMantenimientoModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddMantenimientoModal(
        onMantenimientoAdded: () {
          print('Mantenimiento agregado - refrescar lista');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Lista de mantenimientos actualizada'),
              backgroundColor: const Color(0xFF303366),
            ),
          );
          // Refrescar la lista después de agregar
          context.read<MantenimientoBloc>().add(RefreshMantenimientosEvent());
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
                          _buildMantenimientosTable(isMobile),
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

  Widget _buildMantenimientosTable(bool isMobile) {
    return BlocBuilder<MantenimientoBloc, MantenimientoState>(
      builder: (context, state) {
        if (state is MantenimientoLoading) {
          return _buildLoadingIndicator();
        } else if (state is MantenimientoError) {
          return _buildErrorWidget(state.message);
        } else if (state is MantenimientoSuccess) {
          return _buildResponsiveTable(state.mantenimientos, isMobile);
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF303366),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[300]!),
        color: Colors.red[50],
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 10),
          const Text(
            'Error al cargar mantenimientos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              context.read<MantenimientoBloc>().add(LoadMantenimientosEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF303366),
            ),
            child: const Text(
              'Reintentar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveTable(List<MantenimientoModel> mantenimientos, bool isMobile) {
    if (mantenimientos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Column(
          children: [
            Icon(Icons.inbox_outlined, color: Colors.grey, size: 60),
            SizedBox(height: 10),
            Text(
              'No hay mantenimientos pendientes',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

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
                          width: 100,
                          child: Text('Accesorio', 
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 80,
                          child: Text('Vehículo', 
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 120,
                          child: Text('Dic. Mantenimiento', 
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 90,
                          child: Text('Estado', 
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 100,
                          child: Text('Fecha Registro', 
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 70,
                          child: Text('Editar', 
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ]
                  : const [
                      DataColumn(
                        label: SizedBox(
                          width: 150,
                          child: Text('Accesorio', 
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 120,
                          child: Text('Vehículo', 
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 180,
                          child: Text('Diccionario Mantenimiento', 
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
                          width: 140,
                          child: Text('Fecha Registro', 
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                          ),
                        ),
                      ),
                      DataColumn(
                        label: SizedBox(
                          width: 100,
                          child: Text('Editar', 
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                          ),
                        ),
                      ),
                    ],
              rows: mantenimientos.map((mantenimiento) {
                return _buildDataRow2(mantenimiento);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

DataRow _buildDataRow2(MantenimientoModel mantenimiento) {
  return DataRow(cells: [
    DataCell(Container(
      child: Text(
        mantenimiento.tipoAccesorio,
        style: const TextStyle(fontSize: 12),
        overflow: TextOverflow.ellipsis,
      ),
    )),
    DataCell(Text(
      mantenimiento.vehiculoPlaca,
      style: const TextStyle(fontSize: 12),
    )),
    DataCell(Text(
      mantenimiento.diccionarioMantenimiento,
      style: const TextStyle(fontSize: 12),
      overflow: TextOverflow.ellipsis,
    )),
    DataCell(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getEstadoColor(mantenimiento.estado),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          mantenimiento.estado,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
    DataCell(Text(
      _formatFechaRegistro(mantenimiento.fechaRegistro),
      style: const TextStyle(fontSize: 12),
    )),
    // ✅ SOLO UNA CELDA DE EDITAR - ELIMINAR LA DUPLICADA
    DataCell(Container(
      child: InkWell(
        onTap: () {
          _openEditMantenimientoModal(mantenimiento);
        },
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Icon(Icons.edit, color: Colors.grey, size: 18),
        ),
      ),
    )),
  ]);
}
  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'completado':
        return Colors.green;
      case 'en proceso':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatFechaRegistro(String fecha) {
    try {
      final dateTime = DateTime.parse(fecha);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } catch (e) {
      return fecha;
    }
  }

  Widget _buildHeaderWithAddButton(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MANTENIMIENTOS',
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
          onTap: _openAddMantenimientoModal,
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
                  'AGREGAR MANTENIMIENTO',
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
                    hintText: 'Buscar por vehículo, accesorio o estado...',
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
              onTap: _openAddMantenimientoModal,
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
                      'AGREGAR MANTENIMIENTO',
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
                          hintText: 'Buscar por vehículo, accesorio o estado...',
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

  Widget _buildFilterChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF303366) : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isActive ? Colors.white : Colors.grey[700],
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
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
              _buildFilterChip('Todos', true),
              _buildFilterChip('Pendientes', false),
              _buildFilterChip('Completados', false),
              _buildFilterChip('En proceso', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return BlocBuilder<MantenimientoBloc, MantenimientoState>(
      builder: (context, state) {
        int itemCount = 0;
        if (state is MantenimientoSuccess) {
          itemCount = state.mantenimientos.length;
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
                    'Mostrando 1 al $itemCount de $itemCount mantenimientos',
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
      },
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