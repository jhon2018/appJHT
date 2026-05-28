// Ruta: lib/features/conductor/presentation/widgets/editar_persona_modal.dart
//
// FIXES INCLUIDOS:
//  1. fechaRegistroLicencia → se pasa null (no "") al DTO; toJson lo omite → 400 resuelto
//  2. Teléfonos → badge Móvil/Fijo, límites visibles, validación clara
//  3. DNI duplicado → tooltip de advertencia inline + botón Guardar bloqueado
//  4. Feedback dentro del modal → AlertDialog (no SnackBar mientras está abierto)
//     Al cerrar con éxito → SnackBar azulino en la página padre
//  5. Responsive mobile / desktop

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_bloc.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_event.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_state.dart';
import 'package:app_jht_front/features/conductor/data/models/persona_model.dart';
import 'package:app_jht_front/features/conductor/data/models/persona_actualizar_dto.dart';
import 'package:app_jht_front/features/conductor/data/datasources/conductor_remote_data_source.dart';
import 'package:app_jht_front/features/supplier/data/models/tipo_telefono_model.dart';

// ── Color tokens ──────────────────────────────────────────────────────────────
const _primary = Color(0xFF303366);
const _primaryLight = Color(0xFFEEEFF6);
const _border = Color(0xFFE0E0E8);
const _surface = Color(0xFFF8F9FC);
const _textPri = Color(0xFF1A1A2E);
const _textSec = Color(0xFF6B7280);
const _green = Color(0xFF16A34A);
const _greenBg = Color(0xFFDCFCE7);
const _yellow = Color(0xFFD97706);
const _yellowBg = Color(0xFFFEF3C7);
const _red = Color(0xFFDC2626);
const _redBg = Color(0xFFFEE2E2);
const _blue = Color(0xFF2563EB);
const _blueBg = Color(0xFFDBEAFE);

class EditarPersonaModal extends StatefulWidget {
  final PersonaModel persona;
  final ConductorRemoteDataSource dataSource;
  final List<PersonaModel> personasExistentes;

  /// Callback que se llama después de cerrar el modal para mostrar SnackBar
  final void Function(String mensaje)? onActualizadoExitoso;

  const EditarPersonaModal({
    super.key,
    required this.persona,
    required this.dataSource,
    this.personasExistentes = const [],
    this.onActualizadoExitoso,
  });

  @override
  State<EditarPersonaModal> createState() => _EditarPersonaModalState();
}

class _EditarPersonaModalState extends State<EditarPersonaModal> {
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat('yyyy-MM-dd');

  // ── Controllers ──────────────────────────────────────────────────────────
  late final TextEditingController _dniCtrl,
      _pNombreCtrl,
      _sNombreCtrl,
      _apPaCtrl,
      _apMaCtrl,
      _fNacCtrl,
      _correoCtrl,
      _salarioCtrl,
      _fIngCtrl,
      _fSalCtrl,
      _usuarioCtrl,
      _passCtrl,
      _nLicCtrl,
      _fRegLicCtrl,
      _fVenLicCtrl;

  // ── Dropdowns ─────────────────────────────────────────────────────────────
  String? _estadoSel, _claseSel, _catSel;

  // ── Teléfonos: listas tipadas separadas (igual que AddSupplierModal) ────────
  final List<TextEditingController> _telControllers = [];
  final List<int> _telTitIds = []; // id del tipo de teléfono
  final List<int> _telIds = []; // telId para el DTO (0 = nuevo)
  List<TipoTelefonoModel> _tiposTel = [];
  bool _loadingTipos = true;

  // ── UI ────────────────────────────────────────────────────────────────────
  bool _obscurePass = true;
  bool _isSaving = false;
  // FIX 3: DNI duplicado
  bool _dniDuplicado = false;

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _initControllers();
    _fetchTipos();
  }

  void _initControllers() {
    final p = widget.persona;
    _dniCtrl = TextEditingController(text: p.dni.toString());
    _pNombreCtrl = TextEditingController(text: p.primerNombre);
    _sNombreCtrl = TextEditingController(text: p.segundoNombre);
    _apPaCtrl = TextEditingController(text: p.apellidoPaterno);
    _apMaCtrl = TextEditingController(text: p.apellidoMaterno);
    _fNacCtrl = TextEditingController(
      text: p.fechaNacimiento?.split('T')[0] ?? '',
    );
    _correoCtrl = TextEditingController(text: p.correo ?? '');
    _salarioCtrl = TextEditingController(text: p.salario?.toString() ?? '0');
    _fIngCtrl = TextEditingController(
      text: p.fechaIngreso?.split('T')[0] ?? '',
    );
    _fSalCtrl = TextEditingController(text: p.fechaSalida?.split('T')[0] ?? '');
    _usuarioCtrl = TextEditingController(text: p.usuario ?? '');
    _passCtrl = TextEditingController();
    _nLicCtrl = TextEditingController(text: p.conductor?.numeroLicencia ?? '');
    _fRegLicCtrl = TextEditingController(
      text: p.conductor?.fechaRegistroLicencia?.split('T')[0] ?? '',
    );
    _fVenLicCtrl = TextEditingController(
      text: p.conductor?.fechaVencimientoLicencia?.split('T')[0] ?? '',
    );

    _estadoSel = _normalizeEstado(p.estado);
    _claseSel = (p.conductor?.claseLicencia.isNotEmpty == true)
        ? p.conductor!.claseLicencia
        : 'A';
    _catSel = (p.conductor?.categoriaLicencia.isNotEmpty == true)
        ? p.conductor!.categoriaLicencia
        : 'I';

    // Inicializar listas de teléfonos con tipos seguros (sin Map)
    for (final t in p.telefonos) {
      _telControllers.add(TextEditingController(text: t.numero));
      _telTitIds.add(t.titId ?? 1);
      _telIds.add(t.telId ?? 0);
    }
  }

  String _normalizeEstado(String e) {
    final up = e.toUpperCase();
    return ['ACTIVO', 'INACTIVO'].contains(up) ? up : 'ACTIVO';
  }

  Future<void> _fetchTipos() async {
    try {
      final tipos = await widget.dataSource.getTiposTelefono();
      if (mounted)
        setState(() {
          _tiposTel = tipos;
          _loadingTipos = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loadingTipos = false);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _dniCtrl,
      _pNombreCtrl,
      _sNombreCtrl,
      _apPaCtrl,
      _apMaCtrl,
      _fNacCtrl,
      _correoCtrl,
      _salarioCtrl,
      _fIngCtrl,
      _fSalCtrl,
      _usuarioCtrl,
      _passCtrl,
      _nLicCtrl,
      _fRegLicCtrl,
      _fVenLicCtrl,
    ]) {
      c.dispose();
    }
    for (final c in _telControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ── FIX 3: validación DNI en tiempo real ──────────────────────────────────
  void _onDniChanged(String value) {
    final duplicado = widget.personasExistentes.any(
      (p) =>
          p.dni.toString() == value && p.personaId != widget.persona.personaId,
    );
    if (duplicado != _dniDuplicado) setState(() => _dniDuplicado = duplicado);
  }

  // ── FIX 1: _onSave corregido ──────────────────────────────────────────────
  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      _showAlert(
        title: 'Campos incompletos',
        message: 'Revise los campos marcados en rojo antes de continuar.',
        type: _AlertType.warning,
      );
      return;
    }
    if (_dniDuplicado) {
      _showAlert(
        title: 'DNI duplicado',
        message:
            'El DNI ${_dniCtrl.text} ya está registrado en otro colaborador.',
        type: _AlertType.warning,
      );
      return;
    }

    // FIX 1: fechas de licencia → null cuando vacías (no "")
    final String? fRegLic = _fRegLicCtrl.text.isEmpty
        ? null
        : _fRegLicCtrl.text;
    final String? fVenLic = _fVenLicCtrl.text.isEmpty
        ? null
        : _fVenLicCtrl.text;

    final dto = PersonaActualizarDto(
      personaId: widget.persona.personaId,
      dni: int.parse(_dniCtrl.text),
      primerNombre: _pNombreCtrl.text.trim(),
      segundoNombre: _sNombreCtrl.text.trim(),
      apellidoPaterno: _apPaCtrl.text.trim(),
      apellidoMaterno: _apMaCtrl.text.trim(),
      fechaNacimiento: _fNacCtrl.text,
      correo: _correoCtrl.text.trim(),
      cargo: widget.persona.cargo ?? 'Colaborador',
      salario: double.tryParse(_salarioCtrl.text) ?? 0.0,
      estado: _estadoSel ?? 'ACTIVO',
      fechaIngreso: _fIngCtrl.text,
      fechaSalida: _fSalCtrl.text.isEmpty ? null : _fSalCtrl.text,
      usuario: _usuarioCtrl.text.trim(),
      nuevaContrasena: _passCtrl.text.isEmpty ? null : _passCtrl.text,
      numeroLicencia: _nLicCtrl.text.trim(),
      claseLicencia: _claseSel ?? '',
      categoriaLicencia: _catSel ?? '',
      fechaRegistroLicencia: fRegLic, // ← null cuando vacío
      fechaVencimientoLicencia: fVenLic, // ← null cuando vacío
      telefonos: List<TelefonoActualizarDto>.generate(
        _telControllers.length,
        (i) => TelefonoActualizarDto(
          telId: _telIds[i],
          numero: _telControllers[i].text.trim(),
          titId: _telTitIds[i],
        ),
      ),
    );

    setState(() => _isSaving = true);
    context.read<ConductorBloc>().add(
      ConductorEvent.actualizarPersona(dto: dto),
    );
  }

  // ── FIX 4: AlertDialog dentro del modal ──────────────────────────────────
  void _showAlert({
    required String title,
    required String message,
    required _AlertType type,
    VoidCallback? onConfirm,
  }) {
    if (!mounted) return;
    final cfg = _alertConfig(type);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(cfg.icon, color: cfg.iconColor, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: cfg.textColor,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 13, color: _textSec),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                onConfirm?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cfg.btnColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Entendido',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isMobile = w < 700;

    return BlocListener<ConductorBloc, ConductorState>(
      listener: (ctx, state) {
        state.maybeWhen(
          // ── Éxito ───────────────────────────────────────────────────────
          personaActualizada: (_) {
            setState(() => _isSaving = false);
            // FIX 4: cerrar modal primero, luego SnackBar azulino en la page
            Navigator.of(context).pop();
            widget.onActualizadoExitoso?.call(
              '${widget.persona.primerNombre} ${widget.persona.apellidoPaterno} actualizado correctamente',
            );
          },
          // ── Error ────────────────────────────────────────────────────────
          personaActualizacionError: (msg) {
            setState(() => _isSaving = false);
            _showAlert(
              title: 'Error al actualizar',
              message: msg,
              type: _AlertType.error,
            );
          },
          orElse: () {},
        );
      },
      child: Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        insetPadding: EdgeInsets.all(isMobile ? 8 : 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 960,
            maxHeight: MediaQuery.sizeOf(context).height * 0.92,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(isMobile),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 14 : 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _section(Icons.person_outline, 'DATOS PERSONALES'),
                        _grid([
                          _dniField(isMobile),
                          _field('1er Nombre *', _pNombreCtrl, required: true),
                          _field('2do Nombre', _sNombreCtrl),
                          _field('Ap. Paterno *', _apPaCtrl, required: true),
                          _field('Ap. Materno *', _apMaCtrl, required: true),
                          _dateField('F. Nacimiento', _fNacCtrl),
                          _dropdown(
                            'Estado *',
                            _estadoSel,
                            ['ACTIVO', 'INACTIVO'],
                            (v) => setState(() => _estadoSel = v),
                          ),
                        ], isMobile),

                        _section(Icons.work_outline, 'FECHAS LABORALES'),
                        _grid([
                          _dateField('Fecha Ingreso *', _fIngCtrl),
                          _dateField('Fecha Salida', _fSalCtrl),
                          _field(
                            'Salario (S/.)',
                            _salarioCtrl,
                            isNumeric: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[\d.]'),
                              ),
                            ],
                          ),
                          _field(
                            'Correo',
                            _correoCtrl,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ], isMobile),

                        _section(Icons.security_outlined, 'ACCESO AL SISTEMA'),
                        _grid([
                          _field(
                            'Usuario',
                            _usuarioCtrl,
                            icon: Icons.person_pin_outlined,
                          ),
                          _passwordField(isMobile),
                        ], isMobile),

                        _section(Icons.phone_outlined, 'TELÉFONOS'),
                        _loadingTipos
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                    color: _primary,
                                  ),
                                ),
                              )
                            : _buildTelefonos(isMobile),

                        if (widget.persona.cargo?.toUpperCase() ==
                            'CONDUCTOR') ...[
                          _section(
                            Icons.directions_car_outlined,
                            'LICENCIA DE CONDUCIR',
                          ),
                          _grid([
                            _field('N° Licencia', _nLicCtrl),
                            _dropdown('Clase', _claseSel, [
                              'A',
                              'B',
                              'C',
                              'D',
                              'E',
                            ], (v) => setState(() => _claseSel = v)),
                            _dropdown('Categoría', _catSel, [
                              'I',
                              'II-A',
                              'II-B',
                              'III-A',
                              'III-B',
                              'III-C',
                            ], (v) => setState(() => _catSel = v)),
                            _dateField('F. Registro Lic.', _fRegLicCtrl),
                            _dateField('F. Vencimiento Lic.', _fVenLicCtrl),
                          ], isMobile),
                        ],

                        const SizedBox(height: 24),
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

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(bool isMobile) => Container(
    padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 14),
    decoration: const BoxDecoration(
      color: _primary,
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Editar Colaborador',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${widget.persona.primerNombre} ${widget.persona.apellidoPaterno}',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ── Section title ─────────────────────────────────────────────────────────
  Widget _section(IconData icon, String title) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 12),
    child: Row(
      children: [
        Icon(icon, size: 18, color: _primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: _primary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: _border)),
      ],
    ),
  );

  // ── Responsive grid ───────────────────────────────────────────────────────
  Widget _grid(List<Widget> children, bool isMobile) => LayoutBuilder(
    builder: (_, constraints) => GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: isMobile ? constraints.maxWidth : 220,
        mainAxisExtent: 92,
        crossAxisSpacing: 12,
        mainAxisSpacing: 4,
      ),
      itemCount: children.length,
      itemBuilder: (_, i) => children[i],
    ),
  );

  // ── FIX 3: campo DNI con tooltip de duplicado ─────────────────────────────
  Widget _dniField(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DNI *',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _textPri,
          ),
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            TextFormField(
              controller: _dniCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
              style: const TextStyle(fontSize: 13),
              onChanged: _onDniChanged,
              decoration: InputDecoration(
                isDense: true,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 11,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _dniDuplicado ? _yellow : _border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _dniDuplicado ? _yellow : _primary,
                    width: 1.5,
                  ),
                ),
                suffixIcon: _dniDuplicado
                    ? Tooltip(
                        message:
                            'Este DNI ya está registrado en otro colaborador',
                        triggerMode: TooltipTriggerMode.tap,
                        decoration: BoxDecoration(
                          color: _yellowBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _yellow),
                        ),
                        textStyle: const TextStyle(
                          color: _yellow,
                          fontSize: 12,
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: _yellow,
                          size: 18,
                        ),
                      )
                    : null,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Obligatorio';
                if (v.length != 8) return '8 dígitos';
                if (_dniDuplicado) return 'DNI ya registrado';
                return null;
              },
            ),
          ],
        ),
        // Badge de advertencia debajo del campo
        if (_dniDuplicado)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Row(
              children: const [
                Icon(Icons.info_outline, size: 11, color: _yellow),
                SizedBox(width: 3),
                Flexible(
                  child: Text(
                    'DNI ya existe',
                    style: TextStyle(
                      fontSize: 10,
                      color: _yellow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Teléfonos: patrón idéntico a AddSupplierModal ─────────────────────────
  Widget _buildTelefonos(bool isMobile) {
    if (_tiposTel.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _redBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.error_outline, color: _red, size: 16),
            SizedBox(width: 8),
            Text(
              'No se pudieron cargar los tipos de teléfono.',
              style: TextStyle(color: _red, fontSize: 12),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(
          _telControllers.length,
          (i) => _telefonoRow(i, isMobile),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => setState(() {
            _telControllers.add(TextEditingController());
            _telTitIds.add(_tiposTel.isNotEmpty ? _tiposTel.first.id : 1);
            _telIds.add(0);
          }),
          icon: const Icon(Icons.add, size: 16),
          label: const Text(
            'AGREGAR TELÉFONO',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: _primary,
            side: const BorderSide(color: _primary),
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _telefonoRow(int i, bool isMobile) {
    final titId = _telTitIds[i];
    final existe = _tiposTel.any((t) => t.id == titId);
    final validId = existe ? titId : _tiposTel.first.id;
    final tipoSel = existe
        ? _tiposTel.firstWhere((t) => t.id == titId)
        : _tiposTel.first;
    final esFijo = tipoSel.tipo.toLowerCase().contains('fijo');
    final esMovil =
        tipoSel.tipo.toLowerCase().contains('celular') ||
        tipoSel.tipo.toLowerCase().contains('móvil');
    final tipoDetectado = _detectarTipoTel(_telControllers[i].text);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _primaryLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _primary.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.phone, color: _primary, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Teléfono ${i + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() {
                    _telControllers[i].dispose();
                    _telControllers.removeAt(i);
                    _telTitIds.removeAt(i);
                    _telIds.removeAt(i);
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _redBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: _red,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            isMobile
                ? Column(
                    children: [
                      _tipoDrop(i, validId),
                      const SizedBox(height: 10),
                      _numField(i, esFijo, esMovil),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _tipoDrop(i, validId)),
                      const SizedBox(width: 12),
                      Expanded(child: _numField(i, esFijo, esMovil)),
                    ],
                  ),
            if (tipoDetectado.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      tipoDetectado.contains('Móvil') ||
                          tipoDetectado.contains('Celular')
                      ? _greenBg
                      : _blueBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tipoDetectado,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color:
                        tipoDetectado.contains('Móvil') ||
                            tipoDetectado.contains('Celular')
                        ? _green
                        : _blue,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tipoDrop(int i, int validId) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Tipo y Uso *',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _textSec,
        ),
      ),
      const SizedBox(height: 4),
      Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: validId,
            isExpanded: true,
            dropdownColor: Colors.white,
            hint: const Text('Seleccione tipo', style: TextStyle(fontSize: 12)),
            items: _tiposTel
                .map(
                  (t) => DropdownMenuItem<int>(
                    value: t.id,
                    child: Text(
                      t.displayText,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _telTitIds[i] = v);
            },
          ),
        ),
      ),
    ],
  );

  Widget _numField(int i, bool esFijo, bool esMovil) {
    final limitTxt = esFijo ? '7-9 dígitos' : '9-11 dígitos';
    final maxLen = esFijo ? 9 : 11;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Número *',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _textSec,
              ),
            ),
            const SizedBox(width: 4),
            Tooltip(
              message:
                  'Fijo Lima: 01XXXXXXX o XXXXXXX (7 dígitos)\n'
                  'Celular: 9XXXXXXXX (9 dígitos)\nCon país: 51 + 9 dígitos',
              triggerMode: TooltipTriggerMode.tap,
              child: const Icon(Icons.info_outline, size: 12, color: _textSec),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _telControllers[i],
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontSize: 13),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(maxLen),
          ],
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            isDense: true,
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            hintText: limitTxt,
            hintStyle: const TextStyle(fontSize: 12, color: _textSec),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _red),
            ),
            errorStyle: const TextStyle(fontSize: 10, height: 0.9),
          ),
          validator: (val) {
            if (val == null || val.isEmpty) return 'Obligatorio';
            final n = val.replaceAll(RegExp(r'\s+'), '');
            if (esFijo && (n.length < 7 || n.length > 9))
              return 'Fijo: 7 a 9 dígitos';
            if (esMovil && n.length != 9 && n.length != 11)
              return 'Móvil: 9 u 11 dígitos';
            return null;
          },
        ),
      ],
    );
  }

  String _detectarTipoTel(String numero) {
    final n = numero.replaceAll(RegExp(r'\s+'), '');
    if (n.isEmpty) return '';
    if (n.startsWith('51') && n.length == 11 && n[2] == '9')
      return '📱 Móvil (con código país)';
    if (n.startsWith('51') && n.length >= 10)
      return '📞 Fijo (con código país)';
    if (n.startsWith('9') && n.length == 9) return '📱 Celular / Móvil';
    if (n.length == 7 || (n.length == 9 && n.startsWith('0')))
      return '📞 Teléfono fijo';
    if (n.length >= 6 && n.length <= 9) return '📞 Posible fijo';
    return '';
  }

  // ── Campo texto genérico ──────────────────────────────────────────────────
  Widget _field(
    String label,
    TextEditingController ctrl, {
    bool required = false,
    bool isNumeric = false,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _textPri,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: ctrl,
          keyboardType: isNumeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : keyboardType,
          inputFormatters:
              inputFormatters ??
              (isNumeric ? [FilteringTextInputFormatter.digitsOnly] : null),
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            counterText: '',
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 12, color: _textSec),
            prefixIcon: icon != null
                ? Icon(icon, size: 16, color: _textSec)
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 11,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _red),
            ),
            errorStyle: const TextStyle(fontSize: 10, height: 0.8),
          ),
          validator:
              validator ??
              (required
                  ? (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null
                  : null),
        ),
      ],
    );
  }

  // ── Campo contraseña ──────────────────────────────────────────────────────
  Widget _passwordField(bool isMobile) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Contraseña',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _textPri,
        ),
      ),
      const SizedBox(height: 4),
      TextFormField(
        controller: _passCtrl,
        obscureText: _obscurePass,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Solo si desea cambiarla',
          hintStyle: const TextStyle(fontSize: 11, color: _textSec),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 11,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _primary, width: 1.5),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePass
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 16,
              color: _textSec,
            ),
            onPressed: () => setState(() => _obscurePass = !_obscurePass),
          ),
        ),
      ),
    ],
  );

  // ── Campo fecha ───────────────────────────────────────────────────────────
  Widget _dateField(String label, TextEditingController ctrl) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _textPri,
        ),
      ),
      const SizedBox(height: 4),
      TextFormField(
        controller: ctrl,
        readOnly: true,
        style: const TextStyle(fontSize: 13),
        onTap: () async {
          DateTime init = DateTime.now();
          try {
            if (ctrl.text.isNotEmpty) init = DateTime.parse(ctrl.text);
          } catch (_) {}
          final d = await showDatePicker(
            context: context,
            initialDate: init,
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (d != null) ctrl.text = _dateFormat.format(d);
        },
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 11,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _primary, width: 1.5),
          ),
          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
            size: 15,
            color: _textSec,
          ),
        ),
      ),
    ],
  );

  // ── Dropdown ──────────────────────────────────────────────────────────────
  Widget _dropdown(
    String label,
    String? val,
    List<String> opts,
    void Function(String?) onChange,
  ) {
    final effective = opts.contains(val) ? val : opts.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _textPri,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: effective,
          isExpanded: true,
          items: opts
              .map(
                (o) => DropdownMenuItem(
                  value: o,
                  child: Text(o, style: const TextStyle(fontSize: 12)),
                ),
              )
              .toList(),
          onChanged: onChange,
          dropdownColor: Colors.white,
          style: const TextStyle(fontSize: 13, color: _textPri),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: _border),
            ),
          ),
        ),
      ],
    );
  }

  // ── Acciones ──────────────────────────────────────────────────────────────
  Widget _buildActions(bool isMobile) {
    // FIX 3: botón deshabilitado si DNI duplicado o guardando
    final canSave = !_dniDuplicado && !_isSaving;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: _isSaving ? Colors.grey : _textSec,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: canSave ? _onSave : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _primary.withOpacity(0.4),
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.save_outlined, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _dniDuplicado ? 'DNI duplicado' : 'Guardar Cambios',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Alert helpers ─────────────────────────────────────────────────────────────
enum _AlertType { success, warning, error, info }

class _AlertConfig {
  final IconData icon;
  final Color iconColor, textColor, btnColor;
  const _AlertConfig({
    required this.icon,
    required this.iconColor,
    required this.textColor,
    required this.btnColor,
  });
}

_AlertConfig _alertConfig(_AlertType t) {
  switch (t) {
    case _AlertType.success:
      return const _AlertConfig(
        icon: Icons.check_circle_outline_rounded,
        iconColor: _green,
        textColor: Color(0xFF14532D),
        btnColor: _green,
      );
    case _AlertType.warning:
      return const _AlertConfig(
        icon: Icons.warning_amber_rounded,
        iconColor: _yellow,
        textColor: _yellow,
        btnColor: _yellow,
      );
    case _AlertType.error:
      return const _AlertConfig(
        icon: Icons.error_outline_rounded,
        iconColor: _red,
        textColor: Color(0xFF991B1B),
        btnColor: _red,
      );
    case _AlertType.info:
      return const _AlertConfig(
        icon: Icons.info_outline_rounded,
        iconColor: _blue,
        textColor: Color(0xFF1E40AF),
        btnColor: _blue,
      );
  }
}
