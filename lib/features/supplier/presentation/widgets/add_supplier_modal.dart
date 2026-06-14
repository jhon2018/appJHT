// lib/features/supplier/presentation/widgets/add_supplier_modal.dart
// MEJORAS: A-RUC counter+tooltip, B-Tipo chips, C-Banco select Perú,
//          D-Banco junto a N°Cuenta, E-validaciones opcionales, F-tel validate, I-spinner azul
import 'dart:async';
import 'dart:convert';
import 'package:app_jht_front/core/utils/token_service.dart';
import 'package:app_jht_front/core/widgets/app_notification.dart';
import 'package:app_jht_front/features/config/environment_config.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_registro_dto.dart';
import 'package:app_jht_front/features/supplier/data/models/tipo_telefono_model.dart';
import 'package:app_jht_front/features/supplier/presentation/bloc/supplier_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

// ─── Design tokens ──────────────────────────────────────────────────────────
const _kPrimary   = Color(0xFF303366);
const _kPrimaryBg = Color(0xFFEEEFF5);
const _kBorder    = Color(0xFFE0E0E0);
const _kTextSub   = Color(0xFF757575);
const _kError     = Color(0xFFC62828);
const _kInfoBg    = Color(0xFFE3F2FD);
const _kInfo      = Color(0xFF1565C0);

// ─── Bancos del Perú ────────────────────────────────────────────────────────
const _kBancosPeru = [
  'BCP — Banco de Crédito del Perú',
  'BBVA Perú',
  'Scotiabank Perú',
  'Interbank',
  'BanBif',
  'Banco de la Nación',
  'Banco Pichincha',
  'Banco Falabella',
  'Banco Ripley',
  'Mibanco',
  'HSBC Perú',
  'Citibank Perú',
  'Santander Perú',
  'Otro',
];

// ─── Segmentos predefinidos de tipo proveedor ────────────────────────────────
const _kTiposPredef = ['Servicio', 'Producto', 'Servicio + Producto'];

class AddSupplierModal extends StatefulWidget {
  final Function()? onSupplierAdded;
  final BuildContext parentContext;

  const AddSupplierModal({
    super.key,
    this.onSupplierAdded,
    required this.parentContext,
  });

  @override
  State<AddSupplierModal> createState() => _AddSupplierModalState();
}

class _AddSupplierModalState extends State<AddSupplierModal> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _cargandoTiposTel = true;

  // Controladores
  final _razonSocialCtrl    = TextEditingController();
  final _direccionCtrl      = TextEditingController();
  final _rucCtrl            = TextEditingController();
  final _tipoCtrl           = TextEditingController();
  final _encargadoCtrl      = TextEditingController();
  final _representanteCtrl  = TextEditingController();
  final _ubicacionLinkCtrl  = TextEditingController();
  final _correoCtrl         = TextEditingController();
  final _numeroCuentaCtrl   = TextEditingController();
  final _observacionCtrl    = TextEditingController();

  // RUC — contador reactivo
  int _rucLen = 0;

  // Tipo proveedor
  String? _tipoSeleccionado;   // chip seleccionado

  // Banco — select
  String? _bancoSeleccionado;
  bool _bancoEsOtro = false;
  final _bancoOtroCtrl = TextEditingController();

  // Estado
  String? _estadoValue;

  // Sugerencias de correo
  final List<String> _dominios = ['gmail.com', 'hotmail.com', 'yahoo.com', 'outlook.com'];
  bool _mostrarDominios = false;

  // Teléfonos
  final List<TextEditingController> _telControllers = [TextEditingController()];
  final List<String?> _telTipos = [null];
  List<TipoTelefonoModel> _tiposTelefonoList = [];

  @override
  void initState() {
    super.initState();
    _rucCtrl.addListener(() => setState(() => _rucLen = _rucCtrl.text.length));
    _cargarTiposTelefono();
  }

  Future<void> _cargarTiposTelefono() async {
    try {
      final token = await TokenService.getToken();
      if (token == null || token.isEmpty) throw Exception('Sin token');
      final res = await http.get(
        Uri.parse('${EnvironmentConfig.baseUrl}/api/admin/consulta_tipo_telefono'),
        headers: {'Authorization': 'Bearer $token', 'accept': 'application/json'},
      );
      if (res.statusCode == 200) {
        final data = (json.decode(res.body)['data'] as List);
        if (mounted) setState(() {
          _tiposTelefonoList = data.map((e) => TipoTelefonoModel.fromJson(e)).toList();
          _cargandoTiposTel = false;
        });
      } else {
        throw Exception('HTTP ${res.statusCode}');
      }
    } catch (_) {
      if (mounted) setState(() {
        _tiposTelefonoList = [
          TipoTelefonoModel(id: 1, tipo: 'Celular',   uso: 'Personal'),
          TipoTelefonoModel(id: 2, tipo: 'Fijo',      uso: 'Oficina'),
          TipoTelefonoModel(id: 3, tipo: 'WhatsApp',  uso: 'Personal'),
        ];
        _cargandoTiposTel = false;
      });
    }
  }

  @override
  void dispose() {
    _razonSocialCtrl.dispose(); _direccionCtrl.dispose();
    _rucCtrl.dispose(); _tipoCtrl.dispose();
    _encargadoCtrl.dispose(); _representanteCtrl.dispose();
    _ubicacionLinkCtrl.dispose(); _correoCtrl.dispose();
    _numeroCuentaCtrl.dispose(); _observacionCtrl.dispose();
    _bancoOtroCtrl.dispose();
    for (final c in _telControllers) c.dispose();
    super.dispose();
  }

  // ── Helpers RUC ──────────────────────────────────────────────────────────
  String _rucTipo(String ruc) {
    if (ruc.length < 2) return '';
    final pref = ruc.substring(0, 2);
    if (pref == '10') return 'Persona Natural';
    if (pref == '20') return 'Empresa / Sociedad';
    if (pref == '15') return 'No domiciliado';
    return 'Tipo desconocido';
  }

  /// Longitud máxima según prefijo: 10 dígitos para Persona Natural (10xx),
  /// 11 dígitos para Empresa/Sociedad (20xx) y por defecto.
  int _rucMaxLen() {
    final text = _rucCtrl.text;
    if (text.length >= 2 && text.substring(0, 2) == '10') return 10;
    return 11;
  }

  Color _rucColor() {
    final maxLen = _rucMaxLen();
    if (_rucLen == maxLen) return const Color(0xFF2E7D32);
    if (_rucLen > maxLen)  return _kError;
    return _kTextSub;
  }

  // ── Helpers teléfono ─────────────────────────────────────────────────────
  String _detectarTipoTel(String numero) {
    final n = numero.replaceAll(RegExp(r'\s+'), '');
    if (n.isEmpty) return '';
    // Con código de país
    if (n.startsWith('51') && n.length == 11 && n[2] == '9') return '📱 Móvil (con código país)';
    if (n.startsWith('51') && n.length >= 10) return '📞 Fijo (con código país)';
    // Sin código
    if (n.startsWith('9') && n.length == 9) return '📱 Celular / Móvil';
    if (n.length == 7 || (n.length == 9 && n.startsWith('0'))) return '📞 Teléfono fijo';
    if (n.length >= 6 && n.length <= 9) return '📞 Posible fijo';
    return '';
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_estadoValue == null) {
      AppNotification.warning(context, 'Seleccione el estado del proveedor.', isModal: true);
      return;
    }
    for (int i = 0; i < _telControllers.length; i++) {
      if (_telTipos[i] == null) {
        AppNotification.warning(context, 'Seleccione el tipo para el teléfono ${i + 1}.', isModal: true);
        return;
      }
    }
    _registrar();
  }

  void _registrar() {
    setState(() => _isSubmitting = true);
    final bancoFinal = _bancoEsOtro ? _bancoOtroCtrl.text.trim() : (_bancoSeleccionado ?? '');
    final tipoFinal  = _tipoCtrl.text.trim().isNotEmpty ? _tipoCtrl.text.trim()
        : (_tipoSeleccionado ?? '');

    final telefonos = List<TelefonoDto>.generate(_telControllers.length, (i) {
      final parts = (_telTipos[i] ?? '').split(' - ');
      return TelefonoDto(
        numero: _telControllers[i].text.trim(),
        tipo:   parts[0],
        uso:    parts.length > 1 ? parts[1] : '',
      );
    });

    final dto = SupplierRegistroDto(
      razonSocial:   _razonSocialCtrl.text.trim(),
      representante: _representanteCtrl.text.trim(),
      direccion:     _direccionCtrl.text.trim(),
      linkUbicacion: _ubicacionLinkCtrl.text.trim(),
      ruc:           _rucCtrl.text.trim(),
      tipo:          tipoFinal,
      correo:        _correoCtrl.text.trim(),
      banco:         bancoFinal,
      numCuenta:     _numeroCuentaCtrl.text.trim(),
      encargado:     _encargadoCtrl.text.trim(),
      estado:        _estadoValue!,
      observaciones: _observacionCtrl.text.trim(),
      telefonos:     telefonos,
    );

    BlocProvider.of<SupplierBloc>(context).add(SupplierEvent.registrarProveedor(dto: dto));
  }

  void _agregarTelefono() => setState(() {
    _telControllers.add(TextEditingController());
    _telTipos.add(null);
  });

  void _eliminarTelefono(int index) {
    if (_telControllers.length <= 1) return;
    setState(() {
      _telControllers[index].dispose();
      _telControllers.removeAt(index);
      _telTipos.removeAt(index);
    });
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 768;

    return BlocListener<SupplierBloc, SupplierState>(
      listener: (ctx, state) {
        state.when(
          initial:       () {},
          loading:       () {},
          listLoaded:    (_) {},
          detailLoaded:  (_) {},
          updateSuccess: (_) {},
          success: (response) {
            if (!mounted) return;
            setState(() => _isSubmitting = false);
            Navigator.of(context).pop();
            AppNotification.success(widget.parentContext, response.message);
            widget.onSupplierAdded?.call();
          },
          error: (message) {
            if (!mounted) return;
            setState(() => _isSubmitting = false);
            AppNotification.error(context, message, isModal: true);
          },
        );
      },
      child: Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 40, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 640,
            maxHeight: MediaQuery.sizeOf(context).height * 0.92,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _buildHeader(),
            Flexible(child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // ── Datos principales ──────────────────────────────────
                  _sectionTitle('DATOS PRINCIPALES', Icons.business),
                  const SizedBox(height: 12),

                  _row2(isMobile,
                    _field('Razón Social *', _razonSocialCtrl,
                        validator: (v) => v!.isEmpty ? 'Requerido' : null),
                    _rucField(),
                  ),
                  _field('Dirección *', _direccionCtrl,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null),

                  // ── Tipo de proveedor (B) ──────────────────────────────
                  _tipoProveedorField(),

                  // ── Banco + N° Cuenta juntos (C + D) ──────────────────
                  _row2(isMobile, _bancoSelect(), _field('N° de Cuenta *', _numeroCuentaCtrl,
                      keyboard: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null)),

                  _row2(isMobile,
                    _field('Representante *', _representanteCtrl,
                        validator: (v) => v!.isEmpty ? 'Requerido' : null),
                    _field('Encargado *', _encargadoCtrl,
                        validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  ),
                  _correoField(),

                  // Opcionales (E)
                  _field('Link de Ubicación', _ubicacionLinkCtrl,
                      hint: 'https://maps.google.com/...'),
                  _estadoDropdown(),
                  _field('Observaciones', _observacionCtrl, maxLines: 3),

                  const SizedBox(height: 8),

                  // ── Teléfonos (F) ──────────────────────────────────────
                  _sectionTitle('TELÉFONOS', Icons.phone_outlined),
                  const SizedBox(height: 12),

                  if (_cargandoTiposTel)
                    _loadingWidget('Cargando tipos de contacto...')
                  else ...[
                    ...List.generate(_telControllers.length,
                        (i) => _telefonoRow(i, isMobile)),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _agregarTelefono,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('AGREGAR TELÉFONO',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kPrimary,
                        side: const BorderSide(color: _kPrimary),
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Botones acción
                  Row(children: [
                    Expanded(child: _actionBtn('CANCELAR', Colors.grey[100]!,
                        Colors.grey[700]!, () => Navigator.of(context).pop())),
                    const SizedBox(width: 12),
                    Expanded(child: _isSubmitting
                        ? _loadingWidget('Registrando proveedor...')
                        : _actionBtn('GUARDAR', _kPrimary, Colors.white, _submitForm,
                            icon: Icons.save_outlined)),
                  ]),
                ]),
              ),
            )),
          ]),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: _kPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.store_outlined, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text('AGREGAR PROVEEDOR',
              style: TextStyle(color: Colors.white, fontSize: 16,
                  fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        ),
      ]),
    );
  }

  // ── RUC field con contador + tooltip (A) ──────────────────────────────────
  Widget _rucField() {
    final tipo = _rucTipo(_rucCtrl.text);
    final maxLen = _rucMaxLen();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('RUC *',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kPrimary)),
          const SizedBox(width: 6),
          Tooltip(
            message: 'RUC Perú:\n• Empieza con 10 → Persona Natural (10 dígitos)\n'
                '• Empieza con 20 → Empresa / Sociedad (11 dígitos)',
            triggerMode: TooltipTriggerMode.tap,
            child: const Icon(Icons.info_outline, size: 14, color: _kTextSub),
          ),
          const Spacer(),
          Text('$_rucLen / $maxLen',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _rucColor())),
        ]),
        const SizedBox(height: 6),
        TextFormField(
          controller: _rucCtrl,
          keyboardType: TextInputType.number,
          maxLength: maxLen,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kError)),
            suffixIcon: _rucLen == maxLen
                ? const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 18)
                : null,
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Ingrese el RUC';
            final expectedLen = _rucMaxLen();
            if (v.length != expectedLen) return 'El RUC debe tener exactamente $expectedLen dígitos';
            return null;
          },
        ),
        // Indicador dinámico RUC 10 / RUC 20
        if (tipo.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _kInfoBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.info_outline, size: 12, color: _kInfo),
              const SizedBox(width: 4),
              Text(tipo, style: const TextStyle(fontSize: 11, color: _kInfo, fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ]),
    );
  }

  // ── Tipo proveedor con chips + texto libre (B) ────────────────────────────
  Widget _tipoProveedorField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Tipo de Proveedor *',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kPrimary)),
        const SizedBox(height: 8),
        // Chips de selección rápida
        Wrap(spacing: 8, runSpacing: 6, children: _kTiposPredef.map((t) {
          final selected = _tipoSeleccionado == t;
          return GestureDetector(
            onTap: () => setState(() {
              _tipoSeleccionado = selected ? null : t;
              if (!selected) _tipoCtrl.text = t;
              else if (_tipoCtrl.text == t) _tipoCtrl.clear();
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? _kPrimary : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? _kPrimary : _kBorder),
              ),
              child: Text(t, style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey[700],
              )),
            ),
          );
        }).toList()),
        const SizedBox(height: 10),
        // Campo libre (para otro tipo)
        TextFormField(
          controller: _tipoCtrl,
          onChanged: (_) => setState(() => _tipoSeleccionado = null),
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'O escribe otro tipo...',
            hintStyle: const TextStyle(fontSize: 13, color: _kTextSub),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kError)),
          ),
          validator: (v) {
            final selec = _tipoSeleccionado != null || (v != null && v.isNotEmpty);
            if (!selec) return 'Seleccione o escriba el tipo';
            return null;
          },
        ),
      ]),
    );
  }

  // ── Banco select (C) ──────────────────────────────────────────────────────
  Widget _bancoSelect() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Banco *',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kPrimary)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _bancoSeleccionado,
          isExpanded: true,
          style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kError)),
          ),
          hint: const Text('Seleccione banco', style: TextStyle(fontSize: 13, color: _kTextSub)),
          items: _kBancosPeru.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
          onChanged: (v) => setState(() {
            _bancoSeleccionado = v;
            _bancoEsOtro = v == 'Otro';
          }),
          validator: (v) => v == null ? 'Seleccione un banco' : null,
        ),
        // Campo "Otro banco" condicional
        if (_bancoEsOtro) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _bancoOtroCtrl,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Nombre del banco...',
              hintStyle: const TextStyle(fontSize: 13, color: _kTextSub),
              filled: true, fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _kBorder)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _kError)),
            ),
            validator: (v) => _bancoEsOtro && (v == null || v.isEmpty) ? 'Ingrese el banco' : null,
          ),
        ],
      ]),
    );
  }

  // ── Teléfono row con detector automático (F) ──────────────────────────────
  Widget _telefonoRow(int index, bool isMobile) {
    final numVal = _telControllers[index].text;
    final tipoDetectado = _detectarTipoTel(numVal);
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
          Row(children: [
            const Icon(Icons.phone, color: _kPrimary, size: 16),
            const SizedBox(width: 6),
            Text('Teléfono ${index + 1}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kPrimary)),
            const Spacer(),
            if (_telControllers.length > 1)
              GestureDetector(
                onTap: () => _eliminarTelefono(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(6)),
                  child: Icon(Icons.delete_outline, color: Colors.red[700], size: 16),
                ),
              ),
          ]),
          const SizedBox(height: 10),
          isMobile
              ? Column(children: [_tipoDrop(index), const SizedBox(height: 10), _numField(index)])
              : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: _tipoDrop(index)),
                  const SizedBox(width: 12),
                  Expanded(child: _numField(index)),
                ]),
          // Detector dinámico (tooltip tipo teléfono)
          if (tipoDetectado.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: tipoDetectado.contains('Móvil') ? const Color(0xFFE8F5E9) : _kInfoBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(tipoDetectado, style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: tipoDetectado.contains('Móvil') ? const Color(0xFF2E7D32) : _kInfo,
              )),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _tipoDrop(int index) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Tipo y Uso *',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kTextSub)),
      const SizedBox(height: 4),
      Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: _kBorder),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _telTipos[index],
            isExpanded: true,
            hint: const Text('Seleccione tipo', style: TextStyle(fontSize: 12)),
            items: _tiposTelefonoList.map((t) => DropdownMenuItem<String>(
              value: t.displayText,
              child: Text(t.displayText, style: const TextStyle(fontSize: 12)),
            )).toList(),
            onChanged: (v) => setState(() => _telTipos[index] = v),
          ),
        ),
      ),
    ]);
  }

  Widget _numField(int index) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('Número *',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kTextSub)),
        const SizedBox(width: 4),
        Tooltip(
          message: 'Fijo Lima: 01XXXXXXX o XXXXXXX (7 dígitos)\n'
              'Celular: 9XXXXXXXX (9 dígitos)\n'
              'Con país: 51 + 9 dígitos',
          triggerMode: TooltipTriggerMode.tap,
          child: const Icon(Icons.info_outline, size: 12, color: _kTextSub),
        ),
      ]),
      const SizedBox(height: 4),
      TextFormField(
        controller: _telControllers[index],
        keyboardType: TextInputType.phone,
        style: const TextStyle(fontSize: 13),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          filled: true, fillColor: Colors.white,
          hintText: 'Ej: 987654321',
          hintStyle: const TextStyle(fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _kBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _kBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _kError)),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Ingrese el número';
          final n = v.replaceAll(RegExp(r'\s+'), '');
          if (n.length < 7) return 'Número muy corto (mínimo 7 dígitos)';
          if (n.length > 12) return 'Número muy largo (máximo 12 dígitos)';
          return null;
        },
      ),
    ]);
  }

  // ── Correo con sugerencia de dominios ──────────────────────────────────────
  Widget _correoField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Correo *',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kPrimary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _correoCtrl,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 14),
          onChanged: (v) {
            setState(() {
              _mostrarDominios = v.contains('@') && !v.split('@').last.contains('.');
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            hintText: 'ejemplo@correo.com',
            hintStyle: const TextStyle(fontSize: 13, color: _kTextSub),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kError)),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Requerido';
            if (!v.contains('@')) return 'Correo inválido';
            return null;
          },
        ),
        if (_mostrarDominios) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _dominios.map((d) {
              return ActionChip(
                label: Text(d, style: const TextStyle(fontSize: 12, color: _kPrimary, fontWeight: FontWeight.w600)),
                backgroundColor: _kPrimaryBg,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                onPressed: () {
                  final partes = _correoCtrl.text.split('@');
                  if (partes.isNotEmpty) {
                    _correoCtrl.text = '${partes[0]}@$d';
                    _correoCtrl.selection = TextSelection.collapsed(offset: _correoCtrl.text.length);
                    setState(() => _mostrarDominios = false);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ]),
    );
  }

  // ── Estado dropdown ───────────────────────────────────────────────────────
  Widget _estadoDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Estado *',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _kPrimary)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _estadoValue,
          style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
          decoration: InputDecoration(
            filled: true, fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kError)),
          ),
          hint: const Text('Seleccione estado', style: TextStyle(fontSize: 13, color: _kTextSub)),
          items: const [
            DropdownMenuItem(value: 'Activo',   child: Text('Activo')),
            DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo')),
          ],
          onChanged: (v) => setState(() => _estadoValue = v),
          validator: (v) => v == null ? 'Seleccione el estado' : null,
        ),
      ]),
    );
  }

  // ── Loading widget azul (I) ───────────────────────────────────────────────
  Widget _loadingWidget(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: _kInfoBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kInfo.withOpacity(0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(
          width: 20, height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(_kInfo),
          ),
        ),
        const SizedBox(width: 12),
        Text(texto, style: const TextStyle(
            fontSize: 13, color: _kInfo, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  // ── Helpers layout ────────────────────────────────────────────────────────
  Widget _sectionTitle(String title, IconData icon) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: _kPrimary, size: 16),
        const SizedBox(width: 6),
        Text(title, style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700, color: _kPrimary, letterSpacing: 0.5)),
      ]),
      const SizedBox(height: 8),
      const Divider(color: _kBorder, height: 1),
      const SizedBox(height: 4),
    ]);
  }

  Widget _row2(bool isMobile, Widget left, Widget right) {
    if (isMobile) return Column(children: [left, right]);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: left),
      const SizedBox(width: 16),
      Expanded(child: right),
    ]);
  }

  Widget _field(String label, TextEditingController ctrl, {
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: _kPrimary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl, validator: validator,
          maxLines: maxLines, keyboardType: keyboard,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            filled: true, fillColor: Colors.grey[50],
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: _kTextSub),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kPrimary, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _kError)),
          ),
        ),
      ]),
    );
  }

  Widget _actionBtn(String label, Color bg, Color fg, VoidCallback onTap, {IconData? icon}) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg, foregroundColor: fg, elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (icon != null) ...[Icon(icon, size: 16), const SizedBox(width: 6)],
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _dialogBtn(String label, Color bg, Color fg, VoidCallback onTap) {
    return SizedBox(height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg, foregroundColor: fg, elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
