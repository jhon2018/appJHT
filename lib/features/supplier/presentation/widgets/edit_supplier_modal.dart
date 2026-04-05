// lib/features/supplier/presentation/widgets/edit_supplier_modal.dart

import 'package:app_jht_front/features/supplier/data/models/supplier_detail_model.dart';
import 'package:app_jht_front/features/supplier/data/models/tipo_telefono_model.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_actualizar_dto.dart';
import 'package:app_jht_front/features/supplier/presentation/bloc/supplier_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/core/utils/token_service.dart';
import 'package:app_jht_front/features/config/environment_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ─────────────────────────────────────────────
//  TOKENS DE DISEÑO (idénticos al modal detalle)
// ─────────────────────────────────────────────
const _kPrimary   = Color(0xFF303366);
const _kPrimaryBg = Color(0xFFEEEFF5);
const _kBorder    = Color(0xFFE0E0E0);
const _kTextSub   = Color(0xFF757575);
const _kError     = Color(0xFFC62828);

// ─────────────────────────────────────────────
//  BUG FIX #2 — normalizador de estado
//  La API puede devolver "Activo", "ACTIVO", "activo".
//  Siempre normalizamos a MAYÚSCULAS para que el
//  DropdownButtonFormField encuentre su valor.
// ─────────────────────────────────────────────
String _normalizeEstado(String raw) {
  final upper = raw.trim().toUpperCase();
  if (upper == 'ACTIVO' || upper == 'INACTIVO') return upper;
  // Valor desconocido → dejamos null para que el dropdown quede sin selección
  return upper;
}

class EditSupplierModal extends StatefulWidget {
  final SupplierDetailModel proveedor;
  final VoidCallback onEditComplete;

  const EditSupplierModal({
    super.key,
    required this.proveedor,
    required this.onEditComplete,
  });

  @override
  State<EditSupplierModal> createState() => _EditSupplierModalState();
}

class _EditSupplierModalState extends State<EditSupplierModal> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _razonSocialCtrl;
  late final TextEditingController _direccionCtrl;
  late final TextEditingController _rucCtrl;
  late final TextEditingController _tipoCtrl;
  late final TextEditingController _bancoCtrl;
  late final TextEditingController _encargadoCtrl;
  late final TextEditingController _representanteCtrl;
  late final TextEditingController _ubicacionLinkCtrl;
  late final TextEditingController _correoCtrl;
  late final TextEditingController _numeroCuentaCtrl;
  late final TextEditingController _observacionCtrl;

  late List<TextEditingController> _telControllers;
  late List<int?> _telTipoIds;
  late List<int>  _telIds;

  // ✅ BUG FIX #2: normalizado a MAYÚSCULAS
  String? _estadoValue;

  List<TipoTelefonoModel> _tiposTelefono = [];
  bool _cargandoTipos = true;

  @override
  void initState() {
    super.initState();
    _inicializarControladores();
    _cargarTiposTelefono();
  }

  void _inicializarControladores() {
    final p = widget.proveedor;

    _razonSocialCtrl   = TextEditingController(text: p.razonSocial);
    _direccionCtrl     = TextEditingController(text: p.direccion);
    _rucCtrl           = TextEditingController(text: p.ruc.toString());
    _tipoCtrl          = TextEditingController(text: p.tipo);
    _bancoCtrl         = TextEditingController(text: p.banco);
    _encargadoCtrl     = TextEditingController(text: p.encargado);
    _representanteCtrl = TextEditingController(text: p.representante);
    _ubicacionLinkCtrl = TextEditingController(text: p.linkUbicacion);
    _correoCtrl        = TextEditingController(text: p.correo);
    _numeroCuentaCtrl  = TextEditingController(text: p.numeroCuenta.toString());
    _observacionCtrl   = TextEditingController(text: p.observaciones);

    // ✅ BUG FIX #2 aplicado aquí
    _estadoValue = _normalizeEstado(p.estado);
    // Si el valor normalizado no está en el dropdown, ponemos null
    if (_estadoValue != 'ACTIVO' && _estadoValue != 'INACTIVO') {
      _estadoValue = null;
    }

    _telControllers = [];
    _telTipoIds     = [];
    _telIds         = [];

    for (final tel in p.telefonos) {
      _telControllers.add(TextEditingController(text: tel.numero));
      _telTipoIds.add(tel.tipoId == 0 ? null : tel.tipoId);
      _telIds.add(tel.telefonoId);
    }

    if (_telControllers.isEmpty) {
      _telControllers.add(TextEditingController());
      _telTipoIds.add(null);
      _telIds.add(0);
    }
  }

  Future<void> _cargarTiposTelefono() async {
    try {
      final token = await TokenService.getToken();
      if (token == null || token.isEmpty) return;

      final res = await http.get(
        Uri.parse('${EnvironmentConfig.baseUrl}/api/admin/consulta_tipo_telefono'),
        headers: {'Authorization': 'Bearer $token', 'accept': 'application/json'},
      );

      if (res.statusCode == 200) {
        final data = (json.decode(res.body)['data'] as List);
        if (mounted) {
          setState(() {
            _tiposTelefono = data.map((e) => TipoTelefonoModel.fromJson(e)).toList();
            _cargandoTipos = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _cargandoTipos = false);
    }
  }

  void _agregarTelefono() => setState(() {
    _telControllers.add(TextEditingController());
    _telTipoIds.add(null);
    _telIds.add(0);
  });

  void _eliminarTelefono(int index) {
    if (_telControllers.length <= 1) return;
    setState(() {
      _telControllers[index].dispose();
      _telControllers.removeAt(index);
      _telTipoIds.removeAt(index);
      _telIds.removeAt(index);
    });
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_estadoValue == null) {
      _showSnack('Seleccione el estado del proveedor', isError: true);
      return;
    }
    // Validar tipos de teléfono
    for (int i = 0; i < _telControllers.length; i++) {
      if (_telTipoIds[i] == null) {
        _showSnack('Seleccione el tipo para el teléfono ${i + 1}', isError: true);
        return;
      }
    }
    _showConfirmDialog();
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _kPrimaryBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.save_outlined, color: _kPrimary, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Confirmar actualización',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _kPrimary)),
          ],
        ),
        content: const Text('¿Está seguro de que desea guardar los cambios en este proveedor?',
            style: TextStyle(fontSize: 14, color: Color(0xFF424242))),
        actions: [
          Row(children: [
            Expanded(child: _dialogBtn('CANCELAR', Colors.grey[100]!, Colors.grey[700]!,
                () => Navigator.of(context).pop())),
            const SizedBox(width: 12),
            Expanded(child: _dialogBtn('GUARDAR', _kPrimary, Colors.white, () {
              Navigator.of(context).pop();
              _actualizarProveedor();
            })),
          ]),
        ],
      ),
    );
  }

  void _actualizarProveedor() {
    final telefonos = List<TelefonoActualizarDto>.generate(
      _telControllers.length,
      (i) => TelefonoActualizarDto(
        telId:  _telIds[i],
        numero: _telControllers[i].text.trim(),
        titId:  _telTipoIds[i]!,
      ),
    );

    final dto = SupplierActualizarDto(
      proveedorId:  widget.proveedor.proveedorId,
      razonSocial:  _razonSocialCtrl.text.trim(),
      representante: _representanteCtrl.text.trim(),
      direccion:    _direccionCtrl.text.trim(),
      linkUbicacion: _ubicacionLinkCtrl.text.trim(),
      ruc:          int.tryParse(_rucCtrl.text) ?? 0,
      tipo:         _tipoCtrl.text.trim(),
      correo:       _correoCtrl.text.trim(),
      banco:        _bancoCtrl.text.trim(),
      numCuenta:    int.tryParse(_numeroCuentaCtrl.text) ?? 0,
      encargado:    _encargadoCtrl.text.trim(),
      estado:       _estadoValue!,
      observaciones: _observacionCtrl.text.trim(),
      telefonos:    telefonos,
    );

    context.read<SupplierBloc>().add(SupplierEvent.actualizarProveedor(dto: dto));
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: isError ? _kError : _kPrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  @override
  void dispose() {
    _razonSocialCtrl.dispose();
    _direccionCtrl.dispose();
    _rucCtrl.dispose();
    _tipoCtrl.dispose();
    _bancoCtrl.dispose();
    _encargadoCtrl.dispose();
    _representanteCtrl.dispose();
    _ubicacionLinkCtrl.dispose();
    _correoCtrl.dispose();
    _numeroCuentaCtrl.dispose();
    _observacionCtrl.dispose();
    for (final c in _telControllers) c.dispose();
    super.dispose();
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return BlocListener<SupplierBloc, SupplierState>(
      listener: (ctx, state) {
        state.whenOrNull(
          updateSuccess: (response) {
            Navigator.of(ctx).pop();
            _showSnack(response.message);
            widget.onEditComplete();
          },
          error: (msg) => _showSnack('Error: $msg', isError: true),
        );
      },
      child: Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 40,
          vertical: 24,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 680,
            maxHeight: MediaQuery.of(context).size.height * 0.92,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Sección: Datos principales ──
                        _sectionTitle('DATOS PRINCIPALES', Icons.business),
                        const SizedBox(height: 12),
                        _row2(isMobile,
                          _field('Razón Social *', _razonSocialCtrl,
                              validator: (v) => v!.isEmpty ? 'Requerido' : null),
                          _field('RUC *', _rucCtrl,
                              keyboard: TextInputType.number,
                              validator: (v) {
                                if (v!.isEmpty) return 'Requerido';
                                if (v.length != 11) return '11 dígitos';
                                return null;
                              }),
                        ),
                        _field('Dirección *', _direccionCtrl,
                            validator: (v) => v!.isEmpty ? 'Requerido' : null),
                        _row2(isMobile,
                          _field('Tipo Proveedor *', _tipoCtrl,
                              validator: (v) => v!.isEmpty ? 'Requerido' : null),
                          _field('Banco *', _bancoCtrl,
                              validator: (v) => v!.isEmpty ? 'Requerido' : null),
                        ),
                        _row2(isMobile,
                          _field('Representante *', _representanteCtrl,
                              validator: (v) => v!.isEmpty ? 'Requerido' : null),
                          _field('Encargado *', _encargadoCtrl,
                              validator: (v) => v!.isEmpty ? 'Requerido' : null),
                        ),
                        _row2(isMobile,
                          _field('Correo *', _correoCtrl,
                              keyboard: TextInputType.emailAddress,
                              validator: (v) {
                                if (v!.isEmpty) return 'Requerido';
                                if (!v.contains('@')) return 'Correo inválido';
                                return null;
                              }),
                          _field('N° Cuenta *', _numeroCuentaCtrl,
                              keyboard: TextInputType.number,
                              validator: (v) => v!.isEmpty ? 'Requerido' : null),
                        ),
                        _field('Link Ubicación', _ubicacionLinkCtrl),
                        _estadoDropdown(),
                        _field('Observaciones', _observacionCtrl, maxLines: 3),

                        const SizedBox(height: 8),
                        // ── Sección: Teléfonos ──
                        _sectionTitle('TELÉFONOS', Icons.phone_outlined),
                        const SizedBox(height: 12),

                        if (_cargandoTipos)
                          const Center(child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(color: _kPrimary),
                          ))
                        else ...[
                          ...List.generate(_telControllers.length,
                              (i) => _telefonoRow(i, isMobile)),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: _agregarTelefono,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('AGREGAR TELÉFONO',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _kPrimary,
                              side: const BorderSide(color: _kPrimary),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              minimumSize: const Size(double.infinity, 44),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),
                        // ── Botones acción ──
                        Row(children: [
                          Expanded(child: _actionBtn('CANCELAR', Colors.grey[100]!,
                              Colors.grey[700]!, () => Navigator.of(context).pop())),
                          const SizedBox(width: 12),
                          Expanded(child: _actionBtn('GUARDAR CAMBIOS', _kPrimary,
                              Colors.white, _submitForm,
                              icon: Icons.save_outlined)),
                        ]),
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

  // ── Header modal ──────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: _kPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('EDITAR PROVEEDOR',
                style: TextStyle(
                    color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // ── Título de sección ─────────────────────────────────────────────────────
  Widget _sectionTitle(String title, IconData icon) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: _kPrimary, size: 16),
        const SizedBox(width: 6),
        Text(title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                color: _kPrimary, letterSpacing: 0.5)),
      ]),
      const SizedBox(height: 8),
      const Divider(color: _kBorder, height: 1),
      const SizedBox(height: 4),
    ]);
  }

  // ── Helper: fila de 2 columnas (responsive) ───────────────────────────────
  Widget _row2(bool isMobile, Widget left, Widget right) {
    if (isMobile) return Column(children: [left, right]);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: left),
      const SizedBox(width: 16),
      Expanded(child: right),
    ]);
  }

  // ── Campo de texto genérico ───────────────────────────────────────────────
  Widget _field(
    String label,
    TextEditingController ctrl, {
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kPrimary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyboard,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kBorder)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kBorder)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kError)),
          ),
        ),
      ]),
    );
  }

  // ── Dropdown Estado ───────────────────────────────────────────────────────
  Widget _estadoDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Estado *',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kPrimary)),
        const SizedBox(height: 6),
        // ✅ BUG FIX #2: solo dos valores ACTIVO / INACTIVO en mayúsculas
        DropdownButtonFormField<String>(
          value: _estadoValue,
          style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kBorder)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kBorder)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
          ),
          items: const [
            DropdownMenuItem(value: 'ACTIVO',   child: Text('ACTIVO')),
            DropdownMenuItem(value: 'INACTIVO', child: Text('INACTIVO')),
          ],
          onChanged: (v) => setState(() => _estadoValue = v),
          validator: (v) => v == null ? 'Seleccione estado' : null,
        ),
        const SizedBox(height: 0),
      ]),
    );
  }

  // ── Fila de teléfono ──────────────────────────────────────────────────────
  Widget _telefonoRow(int index, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _kPrimaryBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kPrimary.withOpacity(0.15)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Encabezado fila
          Row(
            children: [
              Icon(Icons.phone, color: _kPrimary, size: 16),
              const SizedBox(width: 6),
              Text('Teléfono ${index + 1}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kPrimary)),
              const Spacer(),
              if (_telControllers.length > 1)
                GestureDetector(
                  onTap: () => _eliminarTelefono(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.delete_outline, color: Colors.red[700], size: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Campos tipo + número
          isMobile
              ? Column(children: [_tipoDrop(index), const SizedBox(height: 10), _numField(index)])
              : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: _tipoDrop(index)),
                  const SizedBox(width: 12),
                  Expanded(child: _numField(index)),
                ]),
        ]),
      ),
    );
  }

  Widget _tipoDrop(int index) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Tipo *',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kTextSub)),
      const SizedBox(height: 4),
      DropdownButtonFormField<int?>(
        value: _telTipoIds[index],
        style: const TextStyle(fontSize: 13, color: Color(0xFF212121)),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _kBorder)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _kBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
        ),
        hint: const Text('Seleccione tipo', style: TextStyle(fontSize: 12)),
        items: [
          const DropdownMenuItem<int?>(
            value: null,
            child: Text('Seleccione tipo', style: TextStyle(fontSize: 12, color: _kTextSub)),
          ),
          ..._tiposTelefono.map((t) => DropdownMenuItem<int?>(
                value: t.id,
                child: Text(t.displayText, style: const TextStyle(fontSize: 12)),
              )),
        ],
        onChanged: (v) => setState(() => _telTipoIds[index] = v),
        validator: (v) => v == null ? 'Requerido' : null,
      ),
    ]);
  }

  Widget _numField(int index) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Número *',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kTextSub)),
      const SizedBox(height: 4),
      TextFormField(
        controller: _telControllers[index],
        keyboardType: TextInputType.phone,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Ej: 987654321',
          hintStyle: const TextStyle(fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _kBorder)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _kBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
        ),
        validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
      ),
    ]);
  }

  // ── Botones ───────────────────────────────────────────────────────────────
  Widget _actionBtn(String label, Color bg, Color fg, VoidCallback onTap, {IconData? icon}) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 16), const SizedBox(width: 6)],
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _dialogBtn(String label, Color bg, Color fg, VoidCallback onTap) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      ),
    );
  }
}