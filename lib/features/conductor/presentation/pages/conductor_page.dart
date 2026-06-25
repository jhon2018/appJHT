// Ruta: lib/features/conductor/presentation/pages/conductor_page.dart
import 'dart:async';
import 'package:app_jht_front/features/conductor/data/datasources/conductor_remote_data_source.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_event.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_state.dart';
import 'package:app_jht_front/features/conductor/presentation/widgets/editar_persona_modal.dart';
import 'package:app_jht_front/core/widgets/app_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/shared/presentation/widgets/side_menu.dart';
import 'package:app_jht_front/features/shared/presentation/widgets/scaffold_with_menu.dart';
import 'package:app_jht_front/features/conductor/presentation/widgets/add_conductor_modal.dart';
import 'package:app_jht_front/features/conductor/presentation/widgets/persona_detalle_modal.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_bloc.dart';
import 'package:app_jht_front/features/conductor/data/models/persona_model.dart';
import 'package:app_jht_front/features/shared/presentation/mixins/navigation_helper_mixin.dart';

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

class _ConductorPageState extends State<ConductorPage>
    with NavigationHelperMixin<ConductorPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _horizontalScrollController = ScrollController();
  bool _isLoadingDetalle = false;
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  // ── Búsqueda con debounce ─────────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounceTimer;
  String _activeFilter = 'Todos';
  String _modalToOpen = '';
  PersonaModel?
  _selectedPersonaFromList; // Guarda los datos de la lista (que sí tienen usuario/contraseña)
  List<PersonaModel> _allPersonasCache =
      []; // Para validación de DNI duplicado en edición

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConductorBloc>().add(const ConductorEvent.listarPersonas());
    });
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text;
          _currentPage = 1; // resetear paginación en cada búsqueda
        });
      }
    });
  }

  // Filtra por DNI, nombre y cargo
  List<PersonaModel> _filterPersonas(List<PersonaModel> all) {
    var filtered = all;
    if (_activeFilter == 'Activos') {
      filtered = filtered
          .where((p) => p.estado.toUpperCase() == 'ACTIVO')
          .toList();
    } else if (_activeFilter == 'Inactivos') {
      filtered = filtered
          .where((p) => p.estado.toUpperCase() == 'INACTIVO')
          .toList();
    } else if (_activeFilter == 'Conductor') {
      filtered = filtered
          .where((p) => p.cargo?.toUpperCase() == 'CONDUCTOR')
          .toList();
    } else if (_activeFilter == 'Administrador') {
      filtered = filtered
          .where((p) => p.cargo?.toUpperCase() == 'ADMINISTRADOR')
          .toList();
    }

    if (_searchQuery.isEmpty) return filtered;
    final q = _searchQuery.toLowerCase();
    return filtered
        .where(
          (p) =>
              p.dni.toString().contains(q) ||
              p.nombreCorto.toLowerCase().contains(q) ||
              (p.cargo?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  void _openAddConductorModal() {
    final conductorBloc = context.read<ConductorBloc>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: conductorBloc,
        child: AddConductorModal(
          onConductorAdded: () {
            AppNotification.success(
              context,
              'Colaborador registrado correctamente.',
            );
            conductorBloc.add(const ConductorEvent.listarPersonas());
          },
        ),
      ),
    );
  }

  void _handleMenuSelection(String itemTitle) {
    navigateToMenuPage(context, itemTitle, widget.userName, widget.userRole);
  }
  bool _isLoadingDialogVisible = false;

  void _showLoadingDialog([String message = 'Cargando...']) {
    if (_isLoadingDialogVisible) return;
    _isLoadingDialogVisible = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
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
      ),
    ).then((_) => _isLoadingDialogVisible = false);
  }

  void _openPersonaDetalleModal(PersonaModel persona) {
    setState(() => _modalToOpen = 'DETAIL');
    final conductorBloc = context.read<ConductorBloc>();
    conductorBloc.add(
      ConductorEvent.obtenerPersonaDetalle(personaId: persona.personaId),
    );
    _showLoadingDialog();
  }

  void _mostrarOpcionEditar(PersonaModel persona) {
    setState(() {
      _modalToOpen = 'EDIT';
      _selectedPersonaFromList = persona; // Guarda la persona con credenciales
    });
    final conductorBloc = context.read<ConductorBloc>();
    conductorBloc.add(
      ConductorEvent.obtenerPersonaDetalle(personaId: persona.personaId),
    );
    _showLoadingDialog();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 768;

    return BlocListener<ConductorBloc, ConductorState>(
      listenWhen: (previous, current) => current.maybeWhen(
        personasCargando: () => true,
        personasCargadas: (_) => true,
        error: (_) => true,
        personaDetalleCargado: (_) => true,
        personaDetalleError: (_) => true,
        orElse: () => false,
      ),
      listener: (context, state) {
        state.whenOrNull(
          error: (message) {
            AppNotification.error(context, message);
          },
          personaDetalleCargado: (personaDetalle) {
            if (_isLoadingDialogVisible) {
              Navigator.of(context, rootNavigator: true).pop();
            }

            // Mezclamos el detalle de la API con el usuario/contraseña de la lista
            PersonaModel mergedPersona = personaDetalle;
            if (_selectedPersonaFromList != null) {
              mergedPersona = PersonaModel(
                personaId: personaDetalle.personaId,
                dni: personaDetalle.dni,
                primerNombre: personaDetalle.primerNombre,
                segundoNombre: personaDetalle.segundoNombre,
                apellidoPaterno: personaDetalle.apellidoPaterno,
                apellidoMaterno: personaDetalle.apellidoMaterno,
                fechaNacimiento: personaDetalle.fechaNacimiento,
                correo: personaDetalle.correo,
                cargo: personaDetalle.cargo,
                salario: personaDetalle.salario,
                estado: personaDetalle.estado,
                fechaRegistro: personaDetalle.fechaRegistro,
                fechaIngreso: personaDetalle.fechaIngreso,
                fechaSalida: personaDetalle.fechaSalida,
                telefonos: personaDetalle.telefonos,
                conductor: personaDetalle.conductor,
                // Aquí tomamos los datos de acceso que la API de lista SÍ trae
                usuario:
                    personaDetalle.usuario ?? _selectedPersonaFromList!.usuario,
                contrasena:
                    personaDetalle.contrasena ??
                    _selectedPersonaFromList!.contrasena,
              );
            }

            if (_modalToOpen == 'EDIT') {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => BlocProvider.value(
                  value: context.read<ConductorBloc>(),
                  child: EditarPersonaModal(
                    persona: mergedPersona,
                    dataSource: widget.dataSource,
                    personasExistentes: _allPersonasCache,
                    // ── SnackBar azulino DESPUÉS de cerrar el modal ──
                    onActualizadoExitoso: (mensaje) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  mensaje,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF2563EB),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.all(12),
                        ),
                      );
                    },
                  ),
                ),
              ).then((_) {
                _selectedPersonaFromList = null;
                context.read<ConductorBloc>().add(
                  const ConductorEvent.listarPersonas(),
                );
              });
            } else if (_modalToOpen == 'DETAIL') {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (_) => PersonaDetalleModal(persona: mergedPersona),
              ).then((_) {
                _selectedPersonaFromList = null;
                context.read<ConductorBloc>().add(
                  const ConductorEvent.listarPersonas(),
                );
              });
            }
          },
          personaDetalleError: (mensaje) {
            if (_isLoadingDialogVisible) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            AppNotification.error(context, 'Error: $mensaje');
          },
        );
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    leading: isMobile
                        ? IconButton(
                            icon: const Icon(Icons.menu_rounded, color: Color(0xFF303366)),
                            onPressed: () {
                              context.findAncestorStateOfType<ScaffoldWithMenuState>()?.openMobileMenu();
                            },
                          )
                        : null,
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
                    actions: const [],
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
                          ],
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
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
          'COLABORADORES',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF303366),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 20),
        isMobile
            ? _buildMobileHeaderLayout(isMobile)
            : _buildDesktopHeaderLayout(isMobile),
      ],
    );
  }

  Widget _buildMobileHeaderLayout(bool isMobile) {
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'AGREGAR COLABORADOR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 15 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 45, maxHeight: 55),
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
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Buscar por DNI, nombre o cargo...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ),
              if (_searchQuery.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                  onPressed: () => _searchController.clear(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeaderLayout(bool isMobile) {
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'AGREGAR COLABORADOR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 13 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 45, maxHeight: 55),
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
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Buscar por DNI, nombre o cargo...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.clear,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: () => _searchController.clear(),
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
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = label;
          _currentPage = 1;
        });
      },
      child: Container(
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
              _buildFilterChip('Todos', _activeFilter == 'Todos'),
              _buildFilterChip('Activos', _activeFilter == 'Activos'),
              _buildFilterChip('Inactivos', _activeFilter == 'Inactivos'),
              _buildFilterChip('Conductor', _activeFilter == 'Conductor'),
              _buildFilterChip(
                'Administrador',
                _activeFilter == 'Administrador',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveTable(bool isMobile) {
    return BlocBuilder<ConductorBloc, ConductorState>(
      // ✅ FIX: personaDetalleCargado ya NO dispara rebuild de la tabla.
      // Antes causaba que el builder retornara SizedBox.shrink() → pantalla en blanco.
      buildWhen: (previous, current) => current.maybeWhen(
        personasCargadas: (_) => true,
        personasCargando: () => true,
        error: (_) => true,
        orElse: () => false,
      ),
      builder: (context, state) {
        return state.maybeWhen(
          personasCargando: () => _buildLoadingIndicator(),
          personasCargadas: (allPersonas) {
            _allPersonasCache = allPersonas;
            // Aplicar búsqueda
            final filtered = _filterPersonas(allPersonas);
            final int startIndex = (_currentPage - 1) * _itemsPerPage;
            final int endIndex = startIndex + _itemsPerPage;
            final List<PersonaModel> pagedPersonas =
                filtered.length > startIndex
                ? filtered.sublist(
                    startIndex,
                    endIndex > filtered.length ? filtered.length : endIndex,
                  )
                : [];
            return Column(
              children: [
                _buildDataTable(pagedPersonas, isMobile),
                const SizedBox(height: 16),
                _buildPaginationFromList(filtered),
              ],
            );
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final minW = isMobile ? 700.0 : 1000.0;
          final tableW = constraints.maxWidth > minW
              ? constraints.maxWidth
              : minW;
          return Scrollbar(
            controller: _horizontalScrollController,
            thumbVisibility: true,
            trackVisibility: true,
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Container(
                  width: tableW,
                  padding: const EdgeInsets.all(8),
                  child: DataTable(
                    headingRowHeight: 50,
                    dataRowHeight: 50,
                    horizontalMargin: isMobile ? 12 : 16,
                    columnSpacing: isMobile ? 8 : 24,
                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xFF303366),
                    ),
                    columns: _buildTableColumns(isMobile),
                    rows: personas.map((persona) {
                      return _buildDataRowFromPersona(persona);
                    }).toList(),
                  ), // ← DataTable
                ), // ← Container
              ), // ← ConstrainedBox
            ), // ← SingleChildScrollView
          ); // ← Scrollbar  ✅ punto y coma aquí
        }, // ← builder
      ), // ← LayoutBuilder
    ); // ← Container externo
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

  /// Paginación que recibe la lista ya filtrada (viene de _buildResponsiveTable)
  Widget _buildPaginationFromList(List<PersonaModel> filtered) {
    final int itemCount = filtered.length;
    final int totalPages = itemCount == 0
        ? 1
        : (itemCount / _itemsPerPage).ceil();
    final int firstItemIndex = itemCount > 0
        ? ((_currentPage - 1) * _itemsPerPage) + 1
        : 0;
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
              Flexible(
                child: Text(
                  itemCount > 0
                      ? 'Mostrando $firstItemIndex al $lastItemIndex de $itemCount conductor(es)'
                      : _searchQuery.isNotEmpty
                      ? 'Sin resultados para "$_searchQuery"'
                      : 'No hay datos para mostrar',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
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
                  '$_itemsPerPage por pág.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
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
                  isActive: false,
                  onTap: _currentPage > 1
                      ? () => setState(() => _currentPage--)
                      : null,
                ),
                ...List.generate(totalPages, (index) {
                  final page = index + 1;
                  return _buildPaginationButton(
                    '$page',
                    isActive: _currentPage == page,
                    onTap: () => setState(() => _currentPage = page),
                  );
                }),
                _buildPaginationButton(
                  'Siguiente',
                  isActive: false,
                  onTap: _currentPage < totalPages
                      ? () => setState(() => _currentPage++)
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
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap, // 👈 Ahora el botón reacciona al click
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF303366)
              : (onTap == null ? Colors.grey[100] : Colors.white),
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : (onTap == null ? Colors.grey[400] : Colors.grey[600]),
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
          '© 2026 JHT Transport Company\nTodos los derechos reservados.',
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
