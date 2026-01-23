// lib/features/accessory/presentation/pages/accessory_page.dart
import 'package:app_jht_front/features/accessory/data/models/accesorio_detalle_model.dart';
import 'package:app_jht_front/features/accessory/presentation/widgets/detalle_accessory_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/shared/presentation/widgets/side_menu.dart';
import 'package:app_jht_front/features/accessory/presentation/widgets/add_accessory_modal.dart';
import 'package:app_jht_front/features/accessory/presentation/bloc/accessory_bloc.dart';
import 'package:app_jht_front/features/accessory/data/models/vehiculo_model.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_model.dart';
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

  List<VehiculoModel> _vehiculos = [];
  VehiculoModel? _selectedVehiculo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  void _cargarDatosIniciales() {
    context.read<AccessoryBloc>().add(LoadVehiculosEvent());
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navegando a: $itemTitle'),
        backgroundColor: const Color(0xFF303366),
      ),
    );
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

        // Loading cuando se inicia la consulta del detalle
        if (state is DetalleAccesorioLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: const Color(0xFF303366),
              contentPadding: const EdgeInsets.all(24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 20),
                  Text(
                    'Cargando detalles...',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Cuando llega el detalle → cerramos loading y abrimos modal
        if (state is DetalleAccesorioLoaded) {
          // Cerramos el diálogo de loading si está abierto
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          final kmActual = _selectedVehiculo?.kilometraje ?? 0.0;

          showDetalleAccesorioModal(
            context,
            state.detalle,
            kmActual,
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
            _buildCustomAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderWithAddButton(isMobile),
                    const SizedBox(height: 24),
                    _buildPaginatedTable(isMobile),
                  ],
                ),
              ),
            ),
            _buildCopyright(),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  Resto del código sin cambios (app bar, tabla, header, dropdown, copyright, data source)
  // ──────────────────────────────────────────────

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'JHT TRANSPORT',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF303366),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black87),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginatedTable(bool isMobile) {
    return BlocBuilder<AccessoryBloc, AccessoryState>(
      buildWhen: (p, c) => c is AccesoriosByVehiculoLoaded || c is AccesoriosByVehiculoLoading,
      builder: (context, state) {
        if (state is AccesoriosByVehiculoLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<AccesorioModel> accesorios = [];
        if (state is AccesoriosByVehiculoLoaded) {
          accesorios = state.accesorios;
        }

        return Theme(
          data: Theme.of(context).copyWith(
            cardTheme: const CardThemeData(elevation: 0, color: Colors.white),
          ),
          child: PaginatedDataTable(
            header: const Text('Listado de Accesorios', style: TextStyle(color: Color(0xFF303366), fontWeight: FontWeight.bold)),
            columns: const [
              DataColumn(label: Text('Tipo / Nombre')),
              DataColumn(label: Text('Marca')),
              DataColumn(label: Text('Instalación')),
              DataColumn(label: Text('Próx. Mantenimiento')),
              DataColumn(label: Text('Estado')),
              DataColumn(label: Text('Acción')),
            ],
            source: _AccessoryDataSource(accesorios, context, _selectedVehiculo, _getRowColor),
            rowsPerPage: accesorios.length < 5 && accesorios.isNotEmpty ? accesorios.length : 5,
            showFirstLastButtons: true,
            columnSpacing: isMobile ? 20 : 40,
            horizontalMargin: 10,
          ),
        );
      },
    );
  }

  Widget _buildHeaderWithAddButton(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACCESORIO',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF303366)),
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
          label: const Text('AGREGAR ACCESORIO', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF303366),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 12),
        _buildDropdownVehiculo(),
      ],
    );
  }

  Widget _buildDesktopHeaderLayout() {
    return Row(
      children: [
        SizedBox(
          width: 200,
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
        Expanded(child: _buildDropdownVehiculo()),
      ],
    );
  }

  Widget _buildDropdownVehiculo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Vehículo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF303366))),
        const SizedBox(height: 8),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<VehiculoModel>(
              value: _selectedVehiculo,
              isExpanded: true,
              hint: Text(_isLoading ? 'Cargando...' : 'Seleccione Vehículo'),
              items: _vehiculos.map((v) => DropdownMenuItem(value: v, child: Text(v.placa))).toList(),
              onChanged: (value) {
                setState(() => _selectedVehiculo = value);
                if (value != null) {
                  context.read<AccessoryBloc>().add(OnFetchAccesoriosByVehiculo(value.id));
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCopyright() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[50],
      child: Text(
        '© 2026 JHT Transport - Todos los derechos reservados',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// DATA SOURCE (sin cambios, pero con el botón de ojo disparando el evento)
// ──────────────────────────────────────────────

class _AccessoryDataSource extends DataTableSource {
  final List<AccesorioModel> _data;
  final BuildContext _context;
  final VehiculoModel? selectedVehiculo;
  final Color Function(AccesorioModel) getRowColor;

  _AccessoryDataSource(this._data, this._context, this.selectedVehiculo, this.getRowColor);

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) return null;
    final acc = _data[index];

    return DataRow(
      color: WidgetStateProperty.all(getRowColor(acc)),
      cells: [
        DataCell(Text(acc.tipoNombre, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
        DataCell(Text(acc.marca ?? '-', style: const TextStyle(fontSize: 12))),
        DataCell(Text(DateFormat('dd/MM/yyyy').format(acc.fechaInstalacion), style: const TextStyle(fontSize: 12))),
        DataCell(Text(acc.ultimoMantenimiento?.proximaFecha ?? 'No programada', style: const TextStyle(fontSize: 12))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: acc.ultimoMantenimiento?.estado == 'Pendiente' ? Colors.orange : Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              acc.ultimoMantenimiento?.estado ?? 'OK',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.remove_red_eye, color: Color(0xFF303366), size: 22),
            tooltip: 'Ver detalle completo',
            onPressed: () {
              // Dispara el evento → el BlocListener muestra el loading automáticamente
              _context.read<AccessoryBloc>().add(OnFetchDetalleAccesorio(acc.accesorioId));
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}