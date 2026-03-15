// Ruta: lib/features/conductor/presentation/pages/conductor_page.dart
import 'package:app_jht_front/features/conductor/data/datasources/conductor_remote_data_source.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_event.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_state.dart';
import 'package:app_jht_front/features/conductor/presentation/widgets/editar_persona_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/shared/presentation/widgets/side_menu.dart';
import 'package:app_jht_front/features/conductor/presentation/widgets/add_conductor_modal.dart';
import 'package:app_jht_front/features/conductor/presentation/widgets/persona_detalle_modal.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_bloc.dart';
import 'package:app_jht_front/features/conductor/data/models/persona_model.dart';

class ConductorPage extends StatefulWidget {
  final String userName;
  final String userRole;
  final ConductorRemoteDataSource dataSource;

const ConductorPage({
    super.key,
    required this.userName,
    required this.userRole,
    required this.dataSource, // Requerido aquí
  });

  @override
  State<ConductorPage> createState() => _ConductorPageState();
}

class _ConductorPageState extends State<ConductorPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _horizontalScrollController = ScrollController();
  bool _isLoadingDetalle = false;
  int _currentPage = 1;
final int _itemsPerPage = 5; // Tu requerimiento de 5 registros por página

  @override
  void initState() {
    super.initState();
    // Cargar personas cuando se inicialice el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConductorBloc>().add(const ConductorEvent.listarPersonas());
    });
  }

  void _openAddConductorModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddConductorModal(
        onConductorAdded: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lista de conductores actualizada'),
              backgroundColor: Color(0xFF303366),
            ),
          );
          // Refrescar la lista después de agregar
          context.read<ConductorBloc>().add(
            const ConductorEvent.listarPersonas(),
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


void _openPersonaDetalleModal(PersonaModel persona) async { // ⬅️ Añadimos async
  // 1. Disparamos la petición ANTES de abrir nada
  final conductorBloc = context.read<ConductorBloc>();
  conductorBloc.add(ConductorEvent.obtenerPersonaDetalle(personaId: persona.personaId));

  // 2. Abrimos el modal de "Cargando"
  await showDialog( // ⬅️ Añadimos await aquí para controlar el flujo
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return BlocListener<ConductorBloc, ConductorState>(
        bloc: conductorBloc, 
        listenWhen: (previous, current) => current.maybeWhen(
          personaDetalleCargado: (_) => true,
          personaDetalleError: (_) => true,
          orElse: () => false,
        ),
        listener: (context, state) async { // ⬅️ Listener async para esperar el modal real
          // 3. Al recibir respuesta, cerramos el diálogo de "Cargando"
          if (Navigator.of(dialogContext).canPop()) {
            Navigator.of(dialogContext).pop();
          }

          state.whenOrNull(
            personaDetalleCargado: (personaDetalle) async {
              // 4. Abrimos el modal real y ESPERAMOS a que se cierre
              await showDialog(
                context: context,
                barrierDismissible: false, 
                builder: (context) => PopScope(
                  canPop: true, // ⬅️ Cambiado a true para permitir el cierre controlado
                  child: PersonaDetalleModal(persona: personaDetalle),
                ),
              );

              // 5. CLAVE: Cuando el modal real se cierra, restauramos la lista
              // Esto hace que la paginación y la tabla vuelvan a aparecer.
              if (mounted) {
                conductorBloc.add(const ConductorEvent.listarPersonas());
              }
            },
            personaDetalleError: (mensaje) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $mensaje'), backgroundColor: Colors.red),
              );
            },
          );
        },
        child: AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'Cargando detalles de\n${persona.nombreCorto}...',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    },
  );
}
  
void _mostrarOpcionEditar(PersonaModel persona) {
  // Guardamos la referencia del Bloc antes de entrar a contextos de diálogos
  final conductorBloc = context.read<ConductorBloc>();

  // 1. Mostramos el diálogo de carga inicial
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      // 2. Disparamos el evento para obtener el detalle real
      conductorBloc.add(
        ConductorEvent.obtenerPersonaDetalle(personaId: persona.personaId),
      );

      return BlocListener<ConductorBloc, ConductorState>(
        bloc: conductorBloc,
        listenWhen: (previous, current) => current.maybeWhen(
          personaDetalleCargado: (_) => true,
          personaDetalleError: (_) => true,
          orElse: () => false,
        ),
        listener: (context, state) {
          state.whenOrNull(
            personaDetalleCargado: (personaDetalleCompleta) async {
              // Cerramos el loading circular pequeño
              if (Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }

              // 3. Abrimos el modal de Edición y ESPERAMOS a que se cierre
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => EditarPersonaModal(
                  persona: personaDetalleCompleta,
                  dataSource: widget.dataSource,
                ),
              );

              // 4. AL CERRAR EL MODAL: Disparamos la recarga de la lista.
              // Esto hará que el Bloc emita 'personasCargando' y tu 
              // tabla muestre el widget '_buildLoadingIndicator()'
              if (mounted) {
                conductorBloc.add(const ConductorEvent.listarPersonas());
              }
            },
            personaDetalleError: (mensaje) {
              if (Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error al obtener datos: $mensaje'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          );
        },
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Preparando edición de ${persona.nombreCorto}...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    },
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

  Widget _buildHeaderWithAddButton(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CONDUCTORES',
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
          onTap: _openAddConductorModal,
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
                  'AGREGAR CONDUCTOR',
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
                    hintText: 'Buscar por DNI, nombre o teléfono...',
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
        Row(
          children: [
            InkWell(
              onTap: _openAddConductorModal,
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
                      'AGREGAR CONDUCTOR',
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
                          hintText: 'Buscar por DNI, nombre o teléfono...',
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
      )
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
              _buildFilterChip('Activos', false),
              _buildFilterChip('Inactivos', false),
              _buildFilterChip('Conductor', false),
              _buildFilterChip('Administrador', false),
            ],
          ),
        ],
      ),
    );
  }

Widget _buildResponsiveTable(bool isMobile) {
  return BlocBuilder<ConductorBloc, ConductorState>(
    buildWhen: (previous, current) => current.maybeWhen(
      personasCargadas: (_) => true,
      personasCargando: () => true,
      personaDetalleCargado: (_) => true,
      error: (_) => true,
      orElse: () => false, 
    ),
    builder: (context, state) {
      return state.maybeWhen(
        // CUANDO ESTÁ CARGANDO: Usamos el nuevo widget
        personasCargando: () => _buildLoadingIndicator(),
        
        // CUANDO CARGÓ: Segmentamos para la paginación y mostramos la tabla
        personasCargadas: (allPersonas) {
          final int startIndex = (_currentPage - 1) * _itemsPerPage;
          final int endIndex = startIndex + _itemsPerPage;
          final List<PersonaModel> pagedPersonas = allPersonas.length > startIndex
              ? allPersonas.sublist(startIndex, 
                  endIndex > allPersonas.length ? allPersonas.length : endIndex)
              : [];
          return _buildDataTable(pagedPersonas, isMobile);
        },
        
        error: (message) => _buildErrorWidget(message),
        orElse: () => const SizedBox.shrink(),
      );
    },
  );
}

  Widget _buildDataTable(List<PersonaModel> personas, bool isMobile) {
    if (personas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(60),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Column(
          children: [
            Icon(Icons.inbox_outlined, color: Colors.grey, size: 60),
            SizedBox(height: 10),
            Text(
              'No hay personas registradas',
              style: TextStyle(fontSize: 16, color: Colors.grey),
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
              columns: _buildTableColumns(isMobile),
              rows: personas.map((persona) {
                return _buildDataRowFromPersona(persona);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildTableColumns(bool isMobile) {
    if (isMobile) {
      return const [
        DataColumn(
          label: SizedBox(
            width: 80,
            child: Text(
              'Documento',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: 140,
            child: Text(
              'Nombre Apellido',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: 100,
            child: Text(
              'Cargo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: 90,
            child: Text(
              'Teléfono',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: 110,
            child: Text(
              'Fecha Ingreso',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: 70,
            child: Text(
              'Detalle',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: 70,
            child: Text(
              'Editar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ];
    } else {
      return const [
        DataColumn(
          label: SizedBox(
            width: 120,
            child: Text(
              'Documento',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: 200,
            child: Text(
              'Nombre Apellido',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: 150,
            child: Text(
              'Cargo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: 100,
            child: Text(
              'Teléfono',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: 100,
            child: Text(
              'Fecha Ingreso',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: 60,
            child: Text(
              'Detalle',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataColumn(
          label: SizedBox(
            width: 80,
            child: Text(
              'Editar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ];
    }
  }

  DataRow _buildDataRowFromPersona(PersonaModel persona) {
    return DataRow(
      cells: [
        DataCell(
          Text(persona.dni.toString(), style: const TextStyle(fontSize: 12)),
        ),
        DataCell(
          Container(
            child: Text(
              persona.nombreCorto,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          Text(
            persona.cargo ?? 'No asignado',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        DataCell(
          Text(
            persona.primerTelefono ?? 'No registrado',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        DataCell(
          Text(
            persona.fechaIngresoFormateada,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        // Botón DETALLE
        DataCell(
          IconButton(
            icon: const Icon(
              Icons.remove_red_eye,
              color: Colors.grey,
              size: 18,
            ),
            onPressed: () => _openPersonaDetalleModal(persona),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
        // Botón EDITAR
        DataCell(
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.grey, size: 18),
            onPressed: () => _mostrarOpcionEditar(persona),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
      ],
    );
  }

Widget _buildPagination() {
  return BlocBuilder<ConductorBloc, ConductorState>(
    builder: (context, state) {
      int itemCount = 0;
      
      state.whenOrNull(
        personasCargadas: (personas) => itemCount = personas.length,
      );

      // 1. Cálculo del total de páginas
      final int totalPages = (itemCount / _itemsPerPage).ceil();
      
      // 2. Cálculo del rango actual para el texto descriptivo
      final int firstItemIndex = itemCount > 0 ? ((_currentPage - 1) * _itemsPerPage) + 1 : 0;
      final int lastItemIndex = (_currentPage * _itemsPerPage) > itemCount 
          ? itemCount 
          : (_currentPage * _itemsPerPage);

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
                  itemCount > 0
                      ? 'Mostrando $firstItemIndex al $lastItemIndex de $itemCount personas'
                      : 'No hay datos para mostrar',
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$_itemsPerPage', // Muestra 5 dinámicamente
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
                  // BOTÓN ANTERIOR
                  _buildPaginationButton(
                    'Anterior', 
                    isActive: false,
                    onTap: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                  ),

                  // BOTONES NUMÉRICOS DINÁMICOS
                  ...List.generate(totalPages, (index) {
                    final page = index + 1;
                    return _buildPaginationButton(
                      '$page',
                      isActive: _currentPage == page,
                      onTap: () => setState(() => _currentPage = page),
                    );
                  }),

                  // BOTÓN SIGUIENTE
                  _buildPaginationButton(
                    'Siguiente', 
                    isActive: false,
                    onTap: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
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

Widget _buildPaginationButton(String text, {required bool isActive, VoidCallback? onTap}) {
  return InkWell(
    onTap: onTap, // 👈 Ahora el botón reacciona al click
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF303366) : (onTap == null ? Colors.grey[100] : Colors.white),
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? Colors.white : (onTap == null ? Colors.grey[400] : Colors.grey[600]),
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

Widget _buildLoadingIndicator() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF303366)),
        ),
        const SizedBox(height: 16),
        const Text(
          'Cargando lista de personas...',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF303366),
          ),
        ),
      ],
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
            'Error al cargar personas',
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
              context.read<ConductorBloc>().add(
                const ConductorEvent.listarPersonas(),
              );
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
}