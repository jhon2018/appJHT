// lib/features/accessory/presentation/widgets/edit_accessory_modal.dart
//
// REQF08 — Editar Accesorio
// marcaFromLista: recibe la marca desde AccesorioModel (API26)
// porque API27 no devuelve el campo marca.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:app_jht_front/features/accessory/data/models/accesorio_detalle_model.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_actualizar_dto.dart';
import 'package:app_jht_front/features/accessory/data/models/vehiculo_model.dart';
import 'package:app_jht_front/features/accessory/data/models/segmento_model.dart';
import 'package:app_jht_front/features/accessory/data/models/tipo_accesorio_model.dart';
import 'package:app_jht_front/features/accessory/presentation/bloc/accessory_bloc.dart';

// ── Tokens de color ───────────────────────────────────────────────────────────
const _kPrimary       = Color(0xFF303366);
const _kPrimaryLight  = Color(0xFF2558A8);
const _kSurface       = Color(0xFFFFFFFF);
const _kSurfaceAlt    = Color(0xFFF4F6FA);
const _kBorder        = Color(0xFFD1D9E6);
const _kBorderFocus   = Color(0xFF2558A8);
const _kTextPrimary   = Color(0xFF1A2B45);
const _kTextSecondary = Color(0xFF5A6A85);
const _kTextDisabled  = Color(0xFFADB8CC);
const _kError         = Color(0xFFC0392B);

// ── Estados válidos (exactamente como los devuelve/envía la API) ──────────────
const _kEstados = ['Activo', 'Inactivo', 'Completado'];
const _kEstadoColores = {
  'Activo':     Color(0xFF1E8A4A), // verde
  'Inactivo':   Color(0xFF8E99AA), // gris
  'Completado': Color(0xFF0D8ABC), // azulino
};

/// Normaliza cualquier variante a los valores exactos de la lista.
/// 'ACTIVO' → 'Activo' | 'completado' → 'Completado'
/// Fallback seguro: 'Activo'
String _normalizarEstado(String raw) {
  final lower = raw.toLowerCase().trim();
  for (final e in _kEstados) {
    if (e.toLowerCase() == lower) return e;
  }
  return 'Activo';
}

class EditAccessoryModal extends StatefulWidget {
  final AccesorioDetalleModel detalle;
  final int vehiculoIdActual;
  final List<VehiculoModel> vehiculosList;
  /// Marca tomada de AccesorioModel (API26) porque API27 no la devuelve.
  final String marcaFromLista;

  const EditAccessoryModal({
    super.key,
    required this.detalle,
    required this.vehiculoIdActual,
    required this.vehiculosList,
    required this.marcaFromLista,
  });

  @override
  State<EditAccessoryModal> createState() => _EditAccessoryModalState();
}

class _EditAccessoryModalState extends State<EditAccessoryModal> {
  final _formKey  = GlobalKey<FormState>();
  final _dateFmt  = DateFormat('dd/MM/yyyy');

  // Controllers
  late final TextEditingController _marcaCtrl;
  late final TextEditingController _codigoCtrl;
  late final TextEditingController _kmInstalacionCtrl;
  late final TextEditingController _kmRetiroCtrl;
  late final TextEditingController _observacionCtrl;

  // Valores de selects
  DateTime? _fechaInstalacion;
  DateTime? _fechaRetiro;
  int?    _vehiculoId;
  int?    _segmentoId;
  int?    _tipoId;   // null hasta que el usuario seleccione segmento y carguen tipos
  String  _estado = 'Activo';

  // Listas locales
  List<SegmentoModel>      _segmentos = [];
  List<TipoAccesorioModel> _tipos     = [];
  bool _loadingSegmentos = false;
  bool _loadingTipos     = false;

  @override
  void initState() {
    super.initState();
    final d = widget.detalle;

    // Pre-llenar todos los campos
    // Marca: primero intenta el campo del detalle, si vacío usa marcaFromLista (API26)
    final marcaFinal = d.marca.isNotEmpty ? d.marca : widget.marcaFromLista;
    _marcaCtrl         = TextEditingController(text: marcaFinal);
    _codigoCtrl        = TextEditingController(text: d.codigoFabricante);
    _kmInstalacionCtrl = TextEditingController(text: d.kilometrajeInstalacion.toString());
    _kmRetiroCtrl      = TextEditingController(
        text: d.kilometrajeRetiro != null ? d.kilometrajeRetiro.toString() : '0');
    _observacionCtrl   = TextEditingController(text: d.observacion);

    _fechaInstalacion = d.fechaInstalacion;
    _fechaRetiro      = d.fechaRetiro;
    _vehiculoId       = d.vehiculoId;
    _estado           = _normalizarEstado(d.estado.isNotEmpty ? d.estado : 'Activo');

    // Usar el segmentoId real devuelto por API27 para pre-seleccionar
    // Si API no lo devuelve (null), arranca en null hasta que el usuario elija
    _segmentoId = d.segmentoId;
    _tipoId     = d.tipoId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarSegmentos();
      // Si ya tenemos el segmentoId, cargamos los tipos del segmento actual
      // para que el dropdown de Tipo muestre la lista correcta desde el inicio
      if (d.segmentoId != null) {
        _cargarTiposIniciales(d.segmentoId!);
      }
    });
  }

  @override
  void dispose() {
    _marcaCtrl.dispose();
    _codigoCtrl.dispose();
    _kmInstalacionCtrl.dispose();
    _kmRetiroCtrl.dispose();
    _observacionCtrl.dispose();
    super.dispose();
  }

  void _cargarSegmentos() {
    setState(() => _loadingSegmentos = true);
    context.read<AccessoryBloc>().add(LoadSegmentosEvent());
  }

  /// Carga los tipos del segmento inicial (sin limpiar _tipoId).
  /// Se usa en initState para que el dropdown Tipo ya tenga la lista correcta.
  void _cargarTiposIniciales(int segId) {
    setState(() => _loadingTipos = true);
    context.read<AccessoryBloc>().add(LoadTiposAccesorioEvent(segmentoId: segId));
  }

  void _cargarTiposPorSegmento(int segId) {
    setState(() {
      _loadingTipos = true;
      _tipos  = [];
      _tipoId = null; // reiniciar cuando el usuario cambia el segmento
    });
    context.read<AccessoryBloc>().add(LoadTiposAccesorioEvent(segmentoId: segId));
  }

  Future<void> _pickFecha({
    required DateTime? current,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: _kPrimaryLight, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) setState(() => onPicked(picked));
  }

  Future<bool> _confirmarGuardar() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            title: const Row(children: [
              Icon(Icons.edit_note, color: _kPrimaryLight),
              SizedBox(width: 8),
              Text('Confirmar cambios',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
            ]),
            content: const Text(
              '¿Estás seguro de guardar los cambios en este accesorio?',
              style: TextStyle(color: _kTextSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar',
                    style: TextStyle(color: _kTextSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimaryLight,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Guardar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tipoId == null) {
      _showSnack('Selecciona el segmento y tipo de accesorio',
          Colors.orange.shade700, Icons.warning_amber_rounded);
      return;
    }
    final ok = await _confirmarGuardar();
    if (!ok || !mounted) return;

    context.read<AccessoryBloc>().add(
      ActualizarAccesorioEvent(
        dto: AccesorioActualizarDto(
          accesorioId:            widget.detalle.accesorioId,
          marca:                  _marcaCtrl.text.trim(),
          codigoFabricante:       _codigoCtrl.text.trim(),
          fechaInstalacion:       _fechaInstalacion!,
          kilometrajeInstalacion: int.tryParse(_kmInstalacionCtrl.text) ?? 0,
          fechaRetiro:            _fechaRetiro,
          kilometrajeRetiro:      int.tryParse(_kmRetiroCtrl.text) ?? 0,
          estado:                 _estado,
          observacion:            _observacionCtrl.text.trim(),
          vehiculoId:             _vehiculoId!,
          tipoId:                 _tipoId!,
        ),
        vehiculoIdActual: widget.vehiculoIdActual,
      ),
    );
  }

  void _showSnack(String msg, Color bg, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: bg,
      content: Row(children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: const TextStyle(color: Colors.white))),
      ]),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return BlocListener<AccessoryBloc, AccessoryState>(
      listener: (context, state) {
        if (state is SegmentosLoaded) {
          setState(() {
            _segmentos        = state.segmentos;
            _loadingSegmentos = false;
          });
        }
        if (state is TiposAccesorioLoaded) {
          setState(() {
            _tipos        = state.tiposAccesorio;
            _loadingTipos = false;
            // Verificar si el tipoId actual existe en la lista recién cargada.
            // - Carga inicial: _tipoId ya tiene valor (de initState), lo mantenemos si existe.
            // - Cambio de segmento: _tipoId es null (reset en _cargarTiposPorSegmento), queda null.
            final existeActual = _tipos.any((t) => t.id == _tipoId);
            if (!existeActual) {
              // El tipo actual no pertenece a este segmento → limpiar selección
              _tipoId = null;
            }
            // Si existeActual == true, _tipoId se mantiene (ya tiene el valor correcto)
          });
        }
        if (state is AccesorioActualizado) {
          Navigator.of(context).pop();
        }
        if (state is ActualizacionError) {
          _showSnack(state.message, _kError, Icons.error_outline);
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 60,
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              color: _kSurface,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPremiumHeader(),
                  Flexible(child: _buildBody(isMobile)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: _kPrimary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.edit_note_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'EDITAR ACCESORIO',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Actualice la información del accesorio',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isMobile) {
    return BlocBuilder<AccessoryBloc, AccessoryState>(
      buildWhen: (_, cur) =>
          cur is ActualizandoAccesorio ||
          cur is AccesorioActualizado ||
          cur is ActualizacionError,
      builder: (context, state) {
        final isSaving = state is ActualizandoAccesorio;

        return Stack(children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Identificación
                _sectionTitle('Identificación', Icons.badge_outlined),
                _row2(isMobile, [
                  _textField(ctrl: _marcaCtrl, label: 'Marca *',
                      validator: (v) => v!.trim().isEmpty ? 'Ingresa la marca' : null),
                  _textField(ctrl: _codigoCtrl, label: 'Código fabricante *',
                      validator: (v) => v!.trim().isEmpty ? 'Ingresa el código' : null),
                ]),

                // Vehículo
                _sectionTitle('Vehículo', Icons.directions_bus_outlined),
                _vehiculoDropdown(),

                // Segmento / Tipo
                _sectionTitle('Segmento / Tipo', Icons.category_outlined),
                _segmentoDropdown(),
                const SizedBox(height: 12),
                _tipoDropdown(),
                if (_segmentoId == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(children: const [
                      Icon(Icons.info_outline, size: 13, color: _kTextSecondary),
                      SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'Selecciona el segmento para ver y confirmar el tipo del accesorio.',
                          style: TextStyle(fontSize: 12, color: _kTextSecondary),
                        ),
                      ),
                    ]),
                  ),

                // Instalación
                _sectionTitle('Instalación', Icons.build_circle_outlined),
                _row2(isMobile, [
                  _fechaField(
                    label: 'Fecha instalación *',
                    value: _fechaInstalacion,
                    onPicked: (d) => _fechaInstalacion = d,
                  ),
                  _kmField(ctrl: _kmInstalacionCtrl, label: 'Km instalación *', required: true),
                ]),

                // Retiro
                _sectionTitle('Retiro (opcional)', Icons.remove_circle_outline),
                _row2(isMobile, [
                  _fechaField(
                    label: 'Fecha retiro',
                    value: _fechaRetiro,
                    required: false,
                    onPicked: (d) => _fechaRetiro = d,
                    onClear: () => setState(() => _fechaRetiro = null),
                  ),
                  _kmField(ctrl: _kmRetiroCtrl, label: 'Km retiro', required: false),
                ]),

                // Estado y observaciones
                _sectionTitle('Estado y observaciones', Icons.info_outline),
                _estadoDropdown(),
                const SizedBox(height: 12),
                _observacionField(),

                const SizedBox(height: 28),
                _actions(isSaving),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Overlay cargando segmentos
          if (_loadingSegmentos)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.78),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: _kPrimaryLight),
                      SizedBox(height: 12),
                      Text('Cargando formulario…',
                          style: TextStyle(color: _kTextSecondary)),
                    ],
                  ),
                ),
              ),
            ),
        ]);
      },
    );
  }

  // ── Helpers UI ────────────────────────────────────────────────────────────
  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Row(children: [
        Icon(icon, size: 14, color: _kPrimaryLight),
        const SizedBox(width: 6),
        Text(title.toUpperCase(),
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: _kPrimaryLight)),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: _kBorder, thickness: 1)),
      ]),
    );
  }

  InputDecoration _deco(String label, {Widget? suffix}) => InputDecoration(
        labelText: label,
        suffixIcon: suffix,
        labelStyle: const TextStyle(fontSize: 13, color: _kTextSecondary),
        filled: true,
        fillColor: _kSurfaceAlt,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _kBorder)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _kBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _kBorderFocus, width: 1.8)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _kError)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _kError, width: 1.8)),
      );

  Widget _row2(bool isMobile, List<Widget> children) {
    if (isMobile) {
      return Column(
        children: children
            .expand((w) => [w, const SizedBox(height: 12)])
            .toList()
          ..removeLast(),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .expand((w) => [Expanded(child: w), const SizedBox(width: 12)])
          .toList()
        ..removeLast(),
    );
  }

  // ── Campos ────────────────────────────────────────────────────────────────
  Widget _textField({
    required TextEditingController ctrl,
    required String label,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
          controller: ctrl, decoration: _deco(label), validator: validator);

  Widget _vehiculoDropdown() => DropdownButtonFormField<int>(
        value: _vehiculoId,
        decoration: _deco('Vehículo *'),
        isExpanded: true,
        items: widget.vehiculosList
            .map((v) => DropdownMenuItem(
                  value: v.id,
                  child: Text('${v.placa}  ·  ${v.kilometraje} km',
                      style: const TextStyle(fontSize: 13)),
                ))
            .toList(),
        onChanged: (val) => setState(() => _vehiculoId = val),
        validator: (v) => v == null ? 'Selecciona un vehículo' : null,
      );

  Widget _segmentoDropdown() {
    final List<DropdownMenuItem<int>> items = [
      ..._segmentos.map((s) => DropdownMenuItem(
            value: s.id,
            child: Text(s.nombre, style: const TextStyle(fontSize: 13)),
          ))
    ];

    return DropdownButtonFormField<int>(
        value: _segmentos.any((s) => s.id == _segmentoId) ? _segmentoId : null,
        decoration: _deco('Segmento *',
            suffix: _loadingSegmentos
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : null),
        isExpanded: true,
        hint: Text(
          _loadingSegmentos ? 'Cargando segmentos…' : 'Selecciona segmento',
          style: const TextStyle(color: _kTextDisabled, fontSize: 13),
        ),
        items: items,
        onChanged: _loadingSegmentos
            ? null
            : (val) {
                if (val != null && val != _segmentoId) {
                  setState(() => _segmentoId = val);
                  _cargarTiposPorSegmento(val);
                }
              },
        validator: (v) => v == null ? 'Selecciona un segmento' : null,
      );
  }

  Widget _tipoDropdown() {
    // Garantiza que value exista en items o sea null — nunca un id huérfano
    final valorSeguro = _tipos.any((t) => t.id == _tipoId) ? _tipoId : null;
    final List<DropdownMenuItem<int>> items = _tipos
        .map((t) => DropdownMenuItem(
            value: t.id,
            child: Text(t.nombre, style: const TextStyle(fontSize: 13))))
        .toList();

    return DropdownButtonFormField<int>(
      value: valorSeguro,
      decoration: _deco('Tipo de accesorio *',
          suffix: _loadingTipos
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : null),
      isExpanded: true,
      hint: Text(
        _segmentoId == null
            ? 'Primero selecciona un segmento'
            : (_loadingTipos ? 'Cargando tipos…' : 'Selecciona tipo'),
        style: const TextStyle(color: _kTextDisabled, fontSize: 13),
      ),
      items: items,
      onChanged: (_loadingTipos || items.isEmpty)
          ? null
          : (val) => setState(() => _tipoId = val),
      validator: (v) => v == null ? 'Selecciona el tipo' : null,
    );
  }

  Widget _fechaField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime> onPicked,
    bool required = true,
    VoidCallback? onClear,
  }) =>
      InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _pickFecha(current: value, onPicked: onPicked),
        child: InputDecorator(
          decoration: _deco(label,
              suffix: onClear != null && value != null
                  ? IconButton(
                      icon: const Icon(Icons.close,
                          size: 16, color: _kTextSecondary),
                      onPressed: onClear,
                    )
                  : const Icon(Icons.calendar_today,
                      size: 16, color: _kTextSecondary)),
          child: Text(
            value != null
                ? _dateFmt.format(value)
                : (required ? 'Selecciona fecha' : 'Sin fecha'),
            style: TextStyle(
                fontSize: 14,
                color: value != null ? _kTextPrimary : _kTextDisabled),
          ),
        ),
      );

  Widget _kmField({
    required TextEditingController ctrl,
    required String label,
    bool required = true,
  }) =>
      TextFormField(
        controller: ctrl,
        decoration: _deco(label,
            suffix: const Padding(
              padding: EdgeInsets.only(right: 12, top: 14),
              child: Text('km',
                  style: TextStyle(color: _kTextSecondary, fontSize: 13)),
            )),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: required
            ? (v) =>
                v!.trim().isEmpty ? 'Ingresa el kilometraje' : null
            : null,
      );

  Widget _estadoDropdown() {
    final valorSeguro = _kEstados.contains(_estado) ? _estado : 'Activo';
    return DropdownButtonFormField<String>(
      value: valorSeguro,
      decoration: _deco('Estado *'),
      items: _kEstados.map((e) {
        final color = _kEstadoColores[e] ?? _kTextSecondary;
        return DropdownMenuItem(
          value: e,
          child: Row(children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 8),
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            Text(e, style: const TextStyle(fontSize: 13)),
          ]),
        );
      }).toList(),
      onChanged: (val) => setState(() => _estado = val ?? 'Activo'),
    );
  }

  Widget _observacionField() => TextFormField(
        controller: _observacionCtrl,
        decoration: _deco('Observaciones'),
        maxLines: 3,
        maxLength: 500,
      );

  Widget _actions(bool isSaving) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.close),
            label: const Text('Cancelar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _kTextSecondary,
              side: const BorderSide(color: _kBorder),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: isSaving ? null : () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            icon: isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(isSaving ? 'Guardando…' : 'Guardar cambios'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimaryLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: isSaving ? null : _submit,
          ),
        ],
      );
}