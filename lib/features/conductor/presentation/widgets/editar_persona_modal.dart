// lib/features/conductor/presentation/widgets/editar_persona_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_bloc.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_event.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_state.dart';
import 'package:app_jht_front/features/conductor/data/models/persona_model.dart';
import 'package:app_jht_front/features/conductor/data/models/persona_actualizar_dto.dart';
import 'package:app_jht_front/features/conductor/data/datasources/conductor_remote_data_source.dart';
import 'package:app_jht_front/features/supplier/data/models/tipo_telefono_model.dart';

class EditarPersonaModal extends StatefulWidget {
  final PersonaModel persona;
  final ConductorRemoteDataSource dataSource; // <--- AÑADE ESTO
  const EditarPersonaModal({
    super.key, 
    required this.persona, 
    required this.dataSource // <--- AÑADE ESTO
  });

  @override
  State<EditarPersonaModal> createState() => _EditarPersonaModalState();
}

class _EditarPersonaModalState extends State<EditarPersonaModal> {
  final _formKey = GlobalKey<FormState>();
  final Color primaryColor = const Color(0xFF303366);
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  List<TipoTelefonoModel> _tiposTelefonoApi = [];
  bool _isLoadingTipos = true;

  late TextEditingController _dniController, _pNombreController, _sNombreController, 
      _apPaternoController, _apMaternoController, _fNacimientoController, 
      _correoController, _salarioController, _fIngresoController, _fSalidaController,
      _usuarioController, _passController, _nLicenciaController, 
      _fRegLicenciaController, _fVenLicenciaController;

  String? _estadoSel, _claseSel, _catSel;
  List<Map<String, dynamic>> _telefonosDynamic = [];

  @override
  void initState() {
    super.initState();
    _checkRoleAndInit();
    _fetchTipos(); 
  }

  void _checkRoleAndInit() {
    if (widget.persona.cargo?.toUpperCase() != "CONDUCTOR") {
      Future.delayed(Duration.zero, () => _showRoleWarning());
      return;
    }
    _initControllers();
  }

Future<void> _fetchTipos() async {
  try {
    // CAMBIA context.read POR widget.dataSource
    final tipos = await widget.dataSource.getTiposTelefono(); 
    if (mounted) {
      setState(() {
        _tiposTelefonoApi = tipos;
        _isLoadingTipos = false; 
      });
    }
  } catch (e) {
    debugPrint("Error al cargar tipos de teléfono: $e");
    if (mounted) setState(() => _isLoadingTipos = false);
  }
}

  void _initControllers() {
    final p = widget.persona;
    _dniController = TextEditingController(text: p.dni.toString());
    _pNombreController = TextEditingController(text: p.primerNombre);
    _sNombreController = TextEditingController(text: p.segundoNombre); // Cargará "Farronan"
    _apPaternoController = TextEditingController(text: p.apellidoPaterno);
    _apMaternoController = TextEditingController(text: p.apellidoMaterno);
    _fNacimientoController = TextEditingController(text: p.fechaNacimiento?.split('T')[0] ?? '');
    _correoController = TextEditingController(text: p.correo ?? '');
    _salarioController = TextEditingController(text: p.salario?.toString() ?? '0.0');
    _fIngresoController = TextEditingController(text: p.fechaIngreso?.split('T')[0] ?? '');
    _fSalidaController = TextEditingController(text: p.fechaSalida?.split('T')[0] ?? '');
    _usuarioController = TextEditingController(); // El API no devuelve usuario en el GET detalle usualmente
    _passController = TextEditingController();
    _nLicenciaController = TextEditingController(text: p.conductor?.numeroLicencia ?? '');
    _fRegLicenciaController = TextEditingController(text: p.conductor?.fechaRegistroLicencia?.split('T')[0] ?? '');
    _fVenLicenciaController = TextEditingController(text: p.conductor?.fechaVencimientoLicencia?.split('T')[0] ?? '');

    _estadoSel = p.estado.toUpperCase();
    _claseSel = (p.conductor?.claseLicencia != null && p.conductor!.claseLicencia.isNotEmpty) ? p.conductor!.claseLicencia : 'A';
    _catSel = (p.conductor?.categoriaLicencia != null && p.conductor!.categoriaLicencia.isNotEmpty) ? p.conductor!.categoriaLicencia : 'I';

    // 🔥 MAPEO DE TELÉFONOS CORREGIDO
    _telefonosDynamic = p.telefonos.map((t) => {
      'telId': t.telId,
      'controller': TextEditingController(text: t.numero), // Carga el número del API
      'titId': t.titId ?? 1, // Sincronizado con tipoId del API
      'uso': t.uso,
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.persona.cargo?.toUpperCase() != "CONDUCTOR") return const SizedBox.shrink();
    
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 700;

    return BlocListener<ConductorBloc, ConductorState>(
      listener: (context, state) {
        state.maybeWhen(
          personaActualizada: (_) {
ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("¡Conductor actualizado correctamente!"),
                backgroundColor: primaryColor, // <-- Usa tu variable 0xFF303366
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context);
          },

    personaActualizacionError: (msg) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.redAccent, // Color de error
              behavior: SnackBarBehavior.floating,
            ),
          ),
          orElse: () {},
        );
      },
      child: Dialog(
        insetPadding: EdgeInsets.all(isMobile ? 10 : 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: isMobile ? screenWidth : 1000,
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            children: [
              _buildHeader(isMobile),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildSectionTitle(Icons.person, "DATOS PERSONALES"),
                        _buildResponsiveGrid([
                          _buildField("DNI *", _dniController, isNumeric: true, isRequired: true),
                          _buildField("1er Nombre *", _pNombreController, isRequired: true),
                          _buildField("2do Nombre", _sNombreController),
                          _buildField("Ap. Paterno *", _apPaternoController, isRequired: true),
                          _buildField("Ap. Materno *", _apMaternoController, isRequired: true),
                          _buildDateField("F. Nacimiento", _fNacimientoController),
                          _buildDropdown("Estado *", _estadoSel, ['ACTIVO', 'INACTIVO'], (v) => setState(() => _estadoSel = v)),
                        ], isMobile),

                        _buildSectionTitle(Icons.work, "FECHAS LABORALES"),
                        _buildResponsiveGrid([
                          _buildDateField("Fecha Ingreso *", _fIngresoController),
                          _buildDateField("Fecha Salida", _fSalidaController),
                          _buildField("Salario (S/.)", _salarioController, isNumeric: true),
                          _buildField("Correo", _correoController),
                        ], isMobile),

                        _buildSectionTitle(Icons.security, "ACCESO AL SISTEMA"),
                        _buildResponsiveGrid([
                          _buildField("Usuario *", _usuarioController, isRequired: true, icon: Icons.person_pin),
                          _buildField("Contraseña *", _passController, isRequired: true, isPassword: true, icon: Icons.lock),
                        ], isMobile),

                        _buildSectionTitle(Icons.phone, "TELÉFONOS DINÁMICOS"),
                        _isLoadingTipos 
                          ? const Center(child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator())) 
                          : _buildTelefonosList(isMobile),

                        _buildSectionTitle(Icons.directions_car, "LICENCIA DE CONDUCIR"),
                        _buildResponsiveGrid([
                          _buildField("N° Licencia", _nLicenciaController),
                          _buildDropdown("Clase", _claseSel, ['A', 'B', 'C'], (v) => setState(() => _claseSel = v)),
                          _buildDropdown("Categoría", _catSel, ['I', 'II-A', 'II-B', 'III-A', 'III-B'], (v) => setState(() => _catSel = v)),
                          _buildDateField("F. Registro Licencia", _fRegLicenciaController),
                          _buildDateField("F. Vencimiento Licencia", _fVenLicenciaController),
                        ], isMobile),
                        
                        const SizedBox(height: 30),
                        _buildActions(isMobile),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: primaryColor,
      child: Row(children: [
        const Icon(Icons.edit, color: Colors.white),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            "EDITAR CONDUCTOR: ${widget.persona.primerNombre} ${widget.persona.apellidoPaterno}", 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white))
      ]),
    );
  }

Widget _buildTelefonosList(bool isMobile) {
    if (_tiposTelefonoApi.isEmpty && !_isLoadingTipos) {
      return const Text("No se cargaron tipos de teléfono.",
          style: TextStyle(fontSize: 12, color: Colors.red));
    }

    return Column(
      children: [
        ..._telefonosDynamic.asMap().entries.map((entry) {
          int i = entry.key;
          int currentTitId = _telefonosDynamic[i]['titId'];
          
          // Recuperamos el uso guardado para este teléfono específico
          final String usoActual = _telefonosDynamic[i]['uso'] ?? '';

          // 🔥 PROTECCIÓN: Si el ID que viene del API no existe en la lista de tipos
          bool existeId = _tiposTelefonoApi.any((t) => t.id == currentTitId);
          int validValue = existeId
              ? currentTitId
              : (_tiposTelefonoApi.isNotEmpty ? _tiposTelefonoApi.first.id : 1);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: isMobile ? 2 : 1,
                  child: DropdownButtonFormField<int>(
                    value: validValue,
                    items: _tiposTelefonoApi.map((t) {
                      return DropdownMenuItem<int>(
                        value: t.id,
                        // CONCATENACIÓN AQUÍ:
                        child: Text(
                          usoActual.isNotEmpty ? "${t.tipo} - $usoActual" : t.tipo,
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) =>
                        setState(() => _telefonosDynamic[i]['titId'] = v),
                    decoration: const InputDecoration(
                        isDense: true,
                        labelText: "Tipo",
                        border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: _buildField("Número", _telefonosDynamic[i]['controller'],
                      isNumeric: true),
                ),
                IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        setState(() => _telefonosDynamic.removeAt(i))),
              ],
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
              onPressed: () => setState(() => _telefonosDynamic.add({
                    'telId': 0,
                    'controller': TextEditingController(),
                    'titId': _tiposTelefonoApi.isNotEmpty
                        ? _tiposTelefonoApi[0].id
                        : 1,
                    'uso': 'Personal' // Valor por defecto para nuevos
                  })),
              icon: const Icon(Icons.add),
              label: const Text("Agregar Teléfono")),
        ),
      ],
    );
  }

  Widget _buildResponsiveGrid(List<Widget> children, bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: isMobile ? constraints.maxWidth : 250,
            mainAxisExtent: 110,
            crossAxisSpacing: 10,
            mainAxisSpacing: 0,
          ),
          itemCount: children.length,
          itemBuilder: (_, i) => children[i],
        );
      }
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool isRequired = false, bool isNumeric = false, bool isPassword = false, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          style: const TextStyle(fontSize: 13),
          validator: isRequired ? (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null : null,
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, size: 16) : null,
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () async {
            DateTime initialDate = DateTime.now();
            try {
              if (controller.text.isNotEmpty) initialDate = DateTime.parse(controller.text);
            } catch (_) {}
            
            final date = await showDatePicker(
              context: context, 
              initialDate: initialDate, 
              firstDate: DateTime(1900), 
              lastDate: DateTime(2100)
            );
            if (date != null) controller.text = _dateFormat.format(date);
          },
          decoration: const InputDecoration(
            isDense: true, 
            border: OutlineInputBorder(), 
            suffixIcon: Icon(Icons.calendar_month, size: 16), 
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12)
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? val, List<String> opts, Function(String?) onChange) {
    // 🔥 PROTECCIÓN: Si el valor actual no está en la lista de opciones (ej: vacío), seleccionamos la primera
    String? effectiveValue = opts.contains(val) ? val : opts.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: effectiveValue,
          items: opts.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 12)))).toList(),
          onChanged: onChange,
          decoration: const InputDecoration(isDense: true, border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(children: [
        Icon(icon, size: 20, color: primaryColor), 
        const SizedBox(width: 10), 
        Text(title, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)), 
        const Expanded(child: Divider(indent: 10))
      ]),
    );
  }

  Widget _buildActions(bool isMobile) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
      const SizedBox(width: 10),
      ElevatedButton(
        onPressed: _onSave, 
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, 
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 30, vertical: 18)
        ), 
        child: const Text("GUARDAR CAMBIOS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
      )
    ]);
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final dto = PersonaActualizarDto(
        personaId: widget.persona.personaId,
        dni: int.parse(_dniController.text),
        primerNombre: _pNombreController.text,
        segundoNombre: _sNombreController.text,
        apellidoPaterno: _apPaternoController.text,
        apellidoMaterno: _apMaternoController.text,
        fechaNacimiento: _fNacimientoController.text,
        correo: _correoController.text,
        cargo: "Conductor",
        salario: double.tryParse(_salarioController.text) ?? 0.0,
        estado: _estadoSel ?? 'ACTIVO',
        fechaIngreso: _fIngresoController.text,
        fechaSalida: _fSalidaController.text.isEmpty ? null : _fSalidaController.text,
        usuario: _usuarioController.text,
        nuevaContrasena: _passController.text,
        numeroLicencia: _nLicenciaController.text,
        claseLicencia: _claseSel ?? '',
        categoriaLicencia: _catSel ?? '',
        fechaRegistroLicencia: _fRegLicenciaController.text,
        fechaVencimientoLicencia: _fVenLicenciaController.text,
        telefonos: _telefonosDynamic.map((t) => TelefonoActualizarDto(
          telId: t['telId'], 
          numero: t['controller'].text, 
          titId: t['titId']
        )).toList(),
      );
      context.read<ConductorBloc>().add(ConductorEvent.actualizarPersona(dto: dto));
    }
  }

  void _showRoleWarning() {
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: const Text("Aviso"), 
        content: const Text("Solo se pueden editar perfiles con cargo 'Conductor'."), 
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cerrar"))]
      )
    );
  }
}