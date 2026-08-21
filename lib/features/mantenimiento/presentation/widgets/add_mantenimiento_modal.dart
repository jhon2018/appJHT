// lib/features/mantenimiento/presentation/widgets/add_mantenimiento_modal.dart
// REQF04 — Registrar Mantenimiento
// Flujo: API12 (datos base) → API13 (accesorios por vehículo) → API15 (conceptos por tipoId)
// Módulo Cambio si tipo.contains('cambio') sino Módulo Mantenimiento

import 'dart:convert';
import 'dart:io';
import 'package:app_jht_front/features/mantenimiento/data/models/accesorio_vehiculo_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:app_jht_front/core/utils/token_service.dart';
import 'package:app_jht_front/core/utils/role_constants.dart';
import '../../data/datasources/registro_mantenimiento_datasource.dart';
import '../../data/models/datos_iniciales_model.dart';
import '../../data/models/accesorio_models.dart';
import '../bloc/registro_mantenimiento_bloc.dart';
import '../bloc/registro_mantenimiento_event.dart';
import '../bloc/registro_mantenimiento_state.dart';
import '../../data/services/photo_upload_service.dart';
import '../../data/services/photo_file_helper.dart';

// ─── Color tokens ─────────────────────────────────────────────────────────────
const _primary = Color(0xFF303366);
const _primaryLight = Color(0xFFEEEFF6);
const _border = Color(0xFFE0E0E8);
const _textPrimary = Color(0xFF1A1A2E);
const _textSecondary = Color(0xFF6B7280);
const _bgPage = Color(0xFFF7F8FC);

const _green = Color(0xFF16A34A);
const _greenBg = Color(0xFFDCFCE7);
const _yellow = Color(0xFFD97706);
const _yellowBg = Color(0xFFFEF3C7);
const _red = Color(0xFFDC2626);
const _blue = Color(0xFF2563EB);
const _blueBg = Color(0xFFDBEAFE);

/// Formateador para convertir automáticamente a mayúsculas
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

// ─── Modelo interno de un ítem accesorio en el formulario ────────────────────
class _AccesorioItem {
  AccesorioVehiculoModel? accesorio;
  String codigoFabrica = '';
  String marca = '';
  String fechaInstalacion = '';
  ConceptoMantenimientoModel? concepto;
  String tipoMantenimiento = '';
  // Módulo Mantenimiento
  String proxKmMant = '';
  String proxFechaMant = '';
  String estadoMant = 'Pendiente';
  String observMant = '';
  SelectedPhoto? foto;
  String? fotoName;
  // Módulo Cambio
  String codFabCambio = '';
  String marcaCambio = '';
  String cantidadCambio = '';
  String proxFechaCambio = '';
  String proxKmCambio = '';
  String observCambio = '';
  String estadoCambio = 'Pendiente';

  // ── Flags de desbloqueo de campos readonly ─────────────────────────────
  bool unlockCodigo = false;
  bool unlockMarca = false;
  bool unlockFechaInst = false;
  bool unlockTipo = false;

  bool get esCambio => tipoMantenimiento.toLowerCase().contains('cambio');
}

// ─── Widget público ───────────────────────────────────────────────────────────
class AddMantenimientoModal extends StatelessWidget {
  final VoidCallback? onMantenimientoAdded;
  const AddMantenimientoModal({super.key, this.onMantenimientoAdded});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegistroMantenimientoBloc(
        dataSource: RegistroMantenimientoDataSourceImpl(),
      )..add(const CargarDatosInicialesEvent()),
      child: _ModalBody(onMantenimientoAdded: onMantenimientoAdded),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _ModalBody extends StatefulWidget {
  final VoidCallback? onMantenimientoAdded;
  const _ModalBody({this.onMantenimientoAdded});

  @override
  State<_ModalBody> createState() => _ModalBodyState();
}

class _ModalBodyState extends State<_ModalBody> {
  // ── Información base ──────────────────────────────────────────────────────
  int? _vehId;
  int? _provId;
  int? _conductorId;
  DateTime? _fechaMantenimiento;
  final _kmCtrl = TextEditingController();
  int? _segmentoId;

  // ── Accesorios del vehículo (API13) ───────────────────────────────────────
  List<AccesorioVehiculoModel> _accesoriosVehiculo = [];
  bool _loadingAccesorios = false;

  // ── Conceptos por tipoId (API15) — cache ─────────────────────────────────
  final Map<int, List<ConceptoMantenimientoModel>> _conceptosCache = {};
  final Map<int, bool> _loadingConceptos = {};

  // ── Lista de ítems ────────────────────────────────────────────────────────
  final List<_AccesorioItem> _items = [_AccesorioItem()];

  // ── Gasto ─────────────────────────────────────────────────────────────────
  String? _tipoGasto;
  String _tipoGastoGasto = 'Mantenimiento'; // gas_vtipo_gasto
  String? _moneda;
  final _nrFacturaCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  final _observGastoCtrl = TextEditingController();
  SelectedPhoto? _gastoFoto;
  String? _gastoFotoName;

  // ── Auth ──────────────────────────────────────────────────────────────────
  int? _perIid;
  String? _userRole;

  final _formKey = GlobalKey<FormState>();

  // ── Datasource singleton (evita instancias repetidas) ─────────────────
  late final RegistroMantenimientoDataSourceImpl _ds =
      RegistroMantenimientoDataSourceImpl();

  @override
  void initState() {
    super.initState();
    _fechaMantenimiento = DateTime.now(); // fecha hoy por defecto
    _loadAuth();
  }

  Future<void> _loadAuth() async {
    final token = await TokenService.getToken();
    final role = await TokenService.getUserRole();
    if (token != null) {
      try {
        final parts = token.split('.');
        final payload = base64.normalize(parts[1]);
        final map =
            jsonDecode(utf8.decode(base64.decode(payload)))
                as Map<String, dynamic>;
        final uid = map['UserId'] ?? map['userId'];
        if (mounted)
          setState(() {
            _perIid = int.tryParse(uid.toString());
            _userRole = role;
          });
      } catch (_) {}
    }
  }

  bool get _isAdmin =>
      _userRole == UserRoles.administrador || _userRole == UserRoles.root;

  @override
  void dispose() {
    _kmCtrl.dispose();
    _nrFacturaCtrl.dispose();
    _montoCtrl.dispose();
    _observGastoCtrl.dispose();
    super.dispose();
  }

  // ── API13 ─────────────────────────────────────────────────────────────────
  Future<void> _cargarAccesorios(int vehId) async {
    setState(() {
      _loadingAccesorios = true;
      _accesoriosVehiculo = [];
    });
    try {
      final res = await _ds.getAccesoriosPorVehiculo(vehId);
      if (mounted) setState(() => _accesoriosVehiculo = res);
    } catch (e) {
      _showAlert('Error', 'Error al cargar accesorios: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loadingAccesorios = false);
    }
  }

  // ── API15 ─────────────────────────────────────────────────────────────────
  Future<void> _cargarConceptos(int itemIdx, int tipoId) async {
    if (_conceptosCache.containsKey(tipoId)) {
      setState(() {});
      return;
    }
    setState(() => _loadingConceptos[itemIdx] = true);
    try {
      final res = await _ds.getConceptosMantenimiento(tipoId);
      if (mounted) {
        _conceptosCache[tipoId] = res;
        setState(() {});
      }
    } catch (e) {
      _showAlert('Error', 'Error al cargar conceptos: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loadingConceptos[itemIdx] = false);
    }
  }

  // ── Envío ─────────────────────────────────────────────────────────────────
  void _submit() {
    // ✅ Validar al menos 1 accesorio
    if (_items.isEmpty || _items.every((i) => i.accesorio == null)) {
      _showAlert(
        'Campo requerido',
        'Debe registrar al menos 1 accesorio',
        isError: true,
      );
      return;
    }

    // ✅ Validar formulario completo
    if (!_formKey.currentState!.validate()) {
      _showAlert(
        'Campos incompletos',
        'Complete todos los campos obligatorios marcados con *',
        isError: true,
      );
      return;
    }

    if (_vehId == null) {
      _showAlert('Vehículo requerido', 'Seleccione un vehículo', isError: true);
      return;
    }
    if (_provId == null) {
      _showAlert(
        'Proveedor requerido',
        'Seleccione un proveedor',
        isError: true,
      );
      return;
    }

    // ✅ Validar que todos los ítems tengan foto
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item.accesorio != null && item.foto == null) {
        _showAlert(
          'Foto requerida',
          'El accesorio ${i + 1} debe tener una foto adjunta',
          isError: true,
        );
        return;
      }
    }

    // ✅ Validar foto de gasto
    if (_gastoFoto == null) {
      _showAlert(
        'Foto requerida',
        'Debe adjuntar la foto del documento de gasto',
        isError: true,
      );
      return;
    }

    final perIid = _isAdmin ? (_conductorId ?? _perIid ?? 1) : (_perIid ?? 1);
    final km = int.tryParse(_kmCtrl.text) ?? 0;
    final fecha = _fechaMantenimiento ?? DateTime.now();
    final fechaStr = _dateToStr(fecha);

    // ── Construir lista de HistoricoItem ──────────────────────────────────────
    final historicos = _items.map((item) {
      final esCambio = item.esCambio;

      // ✅ NORMALIZAR dic_vtipo:
      final tipoNormalizado = esCambio
          ? item.tipoMantenimiento
          : 'Mantenimiento';

      return HistoricoItem(
        accIid: item.accesorio!.idAccesorio,
        hisVdescripcion: esCambio
            ? (item.observCambio.isEmpty ? 'Sin argumentos' : item.observCambio)
            : (item.observMant.isEmpty ? 'Sin argumentos' : item.observMant),
        hisIproxKilometraje: esCambio
            ? (int.tryParse(item.proxKmCambio) ?? 0)
            : (int.tryParse(item.proxKmMant) ?? 0),
        hisDproximaFech: _convertirFechaParaApi(
            esCambio ? item.proxFechaCambio : item.proxFechaMant),
        hisVestado: esCambio ? item.estadoCambio : item.estadoMant,
        dicVtipo: tipoNormalizado,
        dicIid: item.concepto!.id,
        foto: item.foto,
        accVmarca: esCambio ? item.marcaCambio : null,
        accVcodigoFabricante: esCambio ? item.codFabCambio : null,
        accIkilometrajeInstalacion: esCambio ? km : null,
        vehIid: esCambio ? _vehId : null,
        tipIid: esCambio ? item.accesorio!.tipoId : null,
      );
    }).toList();

    // ── Construir GastoRegistro ───────────────────────────────────────────────
    final gastoRegistro = GastoRegistro(
      gasVtipo: _tipoGasto ?? 'Boleta',
      gasVnumeroDocumento: _nrFacturaCtrl.text.trim(),
      gasVtipoGasto: _tipoGastoGasto,
      gasVmoneda: _moneda ?? 'Soles',
      gasBmonto: double.tryParse(_montoCtrl.text) ?? 0,
      gasDfechaGasto: fechaStr,
      gasVdescripcion: _observGastoCtrl.text.trim().isEmpty 
          ? 'Sin observaciones' 
          : _observGastoCtrl.text.trim(),
      foto: _gastoFoto,
    );

    debugPrint('\n══ SUBMIT Mantenimiento ════════════════════════════');
    debugPrint('perIid: $perIid | vehIid: ${_vehId} | proIid: ${_provId}');
    debugPrint('km: $km | fecha: $fechaStr');
    debugPrint('Items: ${historicos.length}');
    for (int i = 0; i < historicos.length; i++) {
      final h = historicos[i];
      debugPrint(
        '  [$i] acc=${h.accIid} tipo=${h.dicVtipo} '
        'dic=${h.dicIid} km=${h.hisIproxKilometraje} '
        'foto=${h.foto?.fileName ?? "ninguna"}',
      );
    }
    debugPrint(
      'Gasto: tipo=${gastoRegistro.gasVtipo} '
      'monto=${gastoRegistro.gasBmonto} '
      'moneda=${gastoRegistro.gasVmoneda}',
    );
    debugPrint('════════════════════════════════════════════════════\n');

    context.read<RegistroMantenimientoBloc>().add(
      RegistrarMantenimientoV2Event(
        perIid: perIid,
        vehIid: _vehId!,
        proIid: _provId!,
        bitKilometraje: km,
        bitFechaRegistro: fecha,
        historicos: historicos,
        gasto: gastoRegistro,
      ),
    );
  }

  /// Convierte DateTime a "yyyy-MM-dd"
  String _dateToStr(DateTime d) {
    final y = d.year.toString();
    final m = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return y + '-' + m + '-' + dd;
  }

  /// Convierte fecha "dd/MM/yyyy" a "yyyy-MM-dd" para la API
  String _convertirFechaParaApi(String fecha) {
    if (fecha.isEmpty) return '';
    try {
      final partes = fecha.split('/');
      if (partes.length == 3) {
        final d = partes[0].padLeft(2, '0');
        final m = partes[1].padLeft(2, '0');
        final y = partes[2];
        return '$y-$m-$d';
      }
    } catch (_) {}
    return fecha;
  }

  // ✅ ALERTA FRONTAL (reemplaza SnackBar)
  void _showAlert(
    String title,
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : isSuccess
                  ? Icons.check_circle_outline_rounded
                  : Icons.info_outline_rounded,
              color: isError
                  ? _red
                  : isSuccess
                  ? _green
                  : _blue,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: _textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Entendido',
              style: TextStyle(
                color: isError
                    ? _red
                    : isSuccess
                    ? _green
                    : _primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 768;

    return BlocListener<RegistroMantenimientoBloc, RegistroMantenimientoState>(
      listenWhen: (prev, curr) =>
          prev.enviando != curr.enviando ||
          prev.exitoRegistro != curr.exitoRegistro ||
          prev.errorRegistro != curr.errorRegistro,
      listener: (ctx, state) {
        debugPrint(
          "BlocListener: enviando=${state.enviando} exito=${state.exitoRegistro} error=${state.errorRegistro}",
        );

        if (state.exitoRegistro && mounted) {
          final id = state.bitacoraIdCreada?.toString() ?? 'N/A';

          Navigator.of(ctx).pop();

          // ✅ Usar showAlert en lugar de SnackBar
          if (mounted) {
            _showAlert(
              '¡Registro exitoso!',
              'Mantenimiento registrado correctamente (ID: $id)',
              isSuccess: true,
            );
            widget.onMantenimientoAdded?.call();
          }
        } else if (state.errorRegistro != null && !state.enviando && mounted) {
          _showAlert('Error', state.errorRegistro!, isError: true);
        }
      },
      child: isMobile ? _buildMobile() : _buildDesktop(),
    );
  }

  Widget _buildDesktop() => Dialog(
    backgroundColor: Colors.white,
    insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 860,
        maxHeight: MediaQuery.sizeOf(context).height * 0.92,
      ),
      child: Column(
        children: [
          _buildHeader(false),
          Expanded(child: _buildContent(false)),
          _buildFooter(false),
        ],
      ),
    ),
  );

  Widget _buildMobile() => Dialog.fullscreen(
    backgroundColor: Colors.white,
    child: Column(
      children: [
        _buildHeader(true),
        Expanded(child: _buildContent(true)),
        _buildFooter(true),
      ],
    ),
  );

  Widget _buildHeader(bool isMobile) => Container(
    padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 14),
    decoration: const BoxDecoration(
      color: _primary,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(14),
        topRight: Radius.circular(14),
      ),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.build_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registrar Mantenimiento',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 15 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'Complete los datos del servicio de mantenimiento',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );

  Widget _buildContent(bool isMobile) {
    return BlocBuilder<RegistroMantenimientoBloc, RegistroMantenimientoState>(
      builder: (ctx, state) {
        if (state.cargandoDatosIniciales) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: _primary),
                SizedBox(height: 14),
                Text(
                  'Cargando datos...',
                  style: TextStyle(color: _textSecondary),
                ),
              ],
            ),
          );
        }
        if (state.errorDatosIniciales != null) {
          return _buildErrorState(state.errorDatosIniciales!);
        }
        if (state.datosIniciales == null) return const SizedBox.shrink();

        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 14 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSeccionBase(state.datosIniciales!, isMobile),
                const SizedBox(height: 16),
                _buildSeccionAccesorios(isMobile),
                const SizedBox(height: 16),
                _buildSeccionGasto(isMobile),
              ],
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SECCIÓN 1 — INFORMACIÓN BASE
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSeccionBase(DatosInicialesModel datos, bool isMobile) {
    return _card(
      title: 'Información base *',
      child: Column(
        children: [
          // Fila 1: Vehículo | Fecha mantenimiento
          _row2(
            isMobile,
            left: _labelRequired(
              'Seleccionar vehículo',
              _SearchableDropdown<int>(
                value: _vehId,
                hint: 'Seleccionar vehículo',
                items: datos.vehiculos
                    .map(
                      (v) =>
                          _DropItem(v.id, '${v.placa} • ${v.kilometraje} km'),
                    )
                    .toList(),
                onChanged: (id) {
                  setState(() {
                    _vehId = id;
                    _accesoriosVehiculo = [];
                    for (final it in _items) {
                      _resetItem(it);
                    }
                  });
                  if (id != null) _cargarAccesorios(id);
                },
              ),
              tooltip:
                  'Seleccione el vehículo al que se realizará el mantenimiento',
            ),
            right: _label(
              'Fecha de mantenimiento',
              _dateField(
                value: _fechaMantenimiento,
                onPicked: (d) => setState(() => _fechaMantenimiento = d),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Fila 2: Proveedor | Kilometraje
          _row2(
            isMobile,
            left: _labelRequired(
              'Proveedor',
              _SearchableDropdown<int>(
                value: _provId,
                hint: 'Proveedor',
                items: datos.proveedores
                    .map((p) => _DropItem(p.id, p.razonSocial))
                    .toList(),
                onChanged: (id) => setState(() => _provId = id),
              ),
              tooltip: 'Seleccione el proveedor del servicio',
            ),
            right: _label(
              'Kilometraje',
              TextFormField(
                controller: _kmCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 13),
                decoration: _inputDec(hint: 'Kilometraje', suffix: 'km'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el kilometraje';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Fila 3: Colaborador (solo admin) | Diccionario
          _row2(
            isMobile,
            left: _isAdmin
                ? _label(
                    'Seleccionar colaborador',
                    _SearchableDropdown<int>(
                      value: _conductorId,
                      hint: 'Seleccionar colaborador',
                      items: datos.conductores
                          .map((c) => _DropItem(c.id, c.nombreCompleto))
                          .toList(),
                      onChanged: (id) => setState(() => _conductorId = id),
                    ),
                  )
                : _label(
                    'Colaborador asignado',
                    Tooltip(
                      message: 'El sistema registra este mantenimiento a su nombre automáticamente.',
                      child: Stack(
                        children: [
                          _readonlyField(
                            datos.conductores
                                .where((c) => c.id == _perIid)
                                .map((c) => c.nombreCompleto)
                                .firstWhere((_) => true, orElse: () => 'Conductor actual'),
                            'Colaborador',
                          ),
                          Positioned(
                            right: 12,
                            top: 0,
                            bottom: 0,
                            child: Icon(Icons.info_outline, size: 16, color: _textSecondary),
                          )
                        ],
                      ),
                    ),
                  ),
            right: _label(
              'Seleccionar diccionario',
              _SearchableDropdown<int>(
                value: _segmentoId,
                hint: 'Seleccionar diccionario',
                items: datos.segmentos
                    .map((s) => _DropItem(s.id, s.nombre))
                    .toList(),
                onChanged: (id) => setState(() => _segmentoId = id),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetItem(_AccesorioItem it) {
    it.accesorio = null;
    it.codigoFabrica = '';
    it.marca = '';
    it.fechaInstalacion = '';
    it.concepto = null;
    it.tipoMantenimiento = '';
    it.foto = null;
    it.fotoName = null;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SECCIÓN 2 — AGREGAR ACCESORIO
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSeccionAccesorios(bool isMobile) {
    return _card(
      title: 'Agregar accesorio *',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._items.asMap().entries.map(
            (e) => _buildItemAccesorio(e.key, e.value, isMobile),
          ),
          if (_items.length < 20) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => setState(() => _items.add(_AccesorioItem())),
                icon: const Icon(
                  Icons.add_circle_outline,
                  size: 16,
                  color: _primary,
                ),
                label: const Text(
                  'Agregar otro accesorio',
                  style: TextStyle(fontSize: 12, color: _primary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemAccesorio(int idx, _AccesorioItem item, bool isMobile) {
    final conceptos = item.accesorio != null
        ? (_conceptosCache[item.accesorio!.tipoId] ??
              <ConceptoMantenimientoModel>[])
        : <ConceptoMantenimientoModel>[];
    final isLoadingConc = _loadingConceptos[idx] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bgPage,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header ítem
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Accesorio ${idx + 1} *',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
              ),
              const Spacer(),
              if (_items.length > 1)
                InkWell(
                  onTap: () => setState(() => _items.removeAt(idx)),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Fila 1: Seleccionar accesorio | Código fabrica
          _row2(
            isMobile,
            left: _labelRequired(
              'Seleccionar accesorio',
              _loadingAccesorios
                  ? _loadingWidget('Cargando accesorios...')
                  : _vehId == null
                  ? _disabledField('Primero seleccione un vehículo')
                  : _SearchableDropdown<int>(
                      value: item.accesorio?.idAccesorio,
                      hint: 'Seleccionar accesorio',
                      items: _accesoriosVehiculo
                          .map((a) => _DropItem(a.idAccesorio, a.tipoNombre))
                          .toList(),
                      onChanged: (id) {
                        if (id == null) return;
                        final acc = _accesoriosVehiculo.firstWhere(
                          (a) => a.idAccesorio == id,
                        );
                        setState(() {
                          item.accesorio = acc;
                          item.codigoFabrica = acc.codigoFabricante;
                          item.marca = acc.marca;
                          item.fechaInstalacion = _fmtFecha(
                            acc.fechaInstalacion,
                          );
                          item.concepto = null;
                          item.tipoMantenimiento = '';
                          item.foto = null;
                          item.fotoName = null;
                        });
                        _cargarConceptos(idx, acc.tipoId);
                      },
                    ),
              tooltip: 'Seleccione el accesorio del vehículo',
            ),
            right: _label(
              'Código fabrica',
              _readonlyField(item.codigoFabrica, 'Código fabrica'),
            ),
          ),
          const SizedBox(height: 10),

          // Fila 2: Marca | Fecha instalación
          _row2(
            isMobile,
            left: _label(
              'Marca',
              _readonlyField(item.marca, 'Marca'),
            ),
            right: _label(
              'Fecha de instalación',
              _readonlyField(item.fechaInstalacion, 'Fecha de instalación'),
            ),
          ),
          const SizedBox(height: 10),

          // Fila 3: Seleccionar mantenimiento | Tipo mantenimiento
          _row2(
            isMobile,
            left: _labelRequired(
              'Seleccionar mantenimiento',
              item.accesorio == null
                  ? _disabledField('Primero seleccione accesorio')
                  : isLoadingConc
                  ? _loadingWidget('Cargando...')
                  : _SearchableDropdown<int>(
                      value: item.concepto?.id,
                      hint: 'Seleccionar mantenimiento',
                      items: conceptos
                          .map((c) => _DropItem(c.id, c.nombre))
                          .toList(),
                      onChanged: (id) {
                        if (id == null) return;
                        final conc = conceptos.firstWhere(
                          (ConceptoMantenimientoModel c) => c.id == id,
                        );
                        final km = int.tryParse(_kmCtrl.text) ?? 0;
                        final proxFecha = DateTime.now().add(
                          Duration(days: conc.frecuenciaTiempo),
                        );
                        setState(() {
                          item.concepto = conc;
                          item.tipoMantenimiento = conc.tipo;
                          item.proxKmMant = (km + conc.frecuenciaKilometros)
                              .toString();
                          item.proxKmCambio = item.proxKmMant;
                          item.proxFechaMant = _fmtFechaDate(proxFecha);
                          item.proxFechaCambio = item.proxFechaMant;
                        });
                      },
                    ),
              tooltip: 'Seleccione el tipo de mantenimiento',
            ),
            right: _label(
              'Tipo mantenimiento',
              _readonlyField(
                item.tipoMantenimiento,
                'Tipo mantenimiento',
                highlight: item.tipoMantenimiento.isNotEmpty,
              ),
            ),
          ),

          // ── Módulo según tipo ───────────────────────────────────────────────
          if (item.tipoMantenimiento.isNotEmpty) ...[
            const SizedBox(height: 14),
            item.esCambio
                ? _buildModuloCambio(idx, item, isMobile)
                : _buildModuloMantenimiento(idx, item, isMobile),
          ],
        ],
      ),
    );
  }

  // ── Módulo Mantenimiento ──────────────────────────────────────────────────
  Widget _buildModuloMantenimiento(
    int idx,
    _AccesorioItem item,
    bool isMobile,
  ) {
    return _moduloCard(
      title: 'Módulo de mantenimiento',
      color: _blue,
      colorBg: _blueBg,
      child: Column(
        children: [
          _row2(
            isMobile,
            left: _label(
              'Próximo kilometraje',
              _editableField(
                item.proxKmMant,
                'Próximo km',
                onChanged: (v) => setState(() => item.proxKmMant = v),
                isNumber: true,
              ),
            ),
            right: _label(
              'Próxima fecha',
              _editableField(
                item.proxFechaMant,
                'dd/mm/yyyy',
                onChanged: (v) => setState(() => item.proxFechaMant = v),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _label(
            'Observación',
            _editableField(
              item.observMant.isEmpty ? 'Sin argumentos' : item.observMant,
              'Sin argumentos',
              onChanged: (v) => setState(() => item.observMant = v),
            ),
          ),
          const SizedBox(height: 10),
          _row2(
            isMobile,
            left: _label(
              'Estado',
              _simpleDropdown(
                value: item.estadoMant,
                items: const ['Pendiente', 'Completo'],
                onChanged: (v) =>
                    setState(() => item.estadoMant = v ?? 'Pendiente'),
              ),
            ),
            right: _label(
              'Adjuntar foto *',
              _fotoPickerField(
                nombre: item.fotoName,
                foto: item.foto,
                onTap: () async {
                  final foto = await PhotoFileHelper.pickPhoto();
                  if (foto != null)
                    setState(() {
                      item.foto = foto;
                      item.fotoName = foto.fileName;
                    });
                },
                onViewPhoto: item.foto != null
                    ? () => _showPhotoDialog(
                        item.foto!,
                        'Foto accesorio ${idx + 1}',
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Módulo Cambio ─────────────────────────────────────────────────────────
  Widget _buildModuloCambio(int idx, _AccesorioItem item, bool isMobile) {
    return _moduloCard(
      title: 'Módulo de cambio',
      color: _yellow,
      colorBg: _yellowBg,
      child: Column(
        children: [
          _row2(
            isMobile,
            left: _label(
              'Código fabricante',
              _editableField(
                item.codFabCambio,
                'Código fabricante',
                onChanged: (v) => setState(() => item.codFabCambio = v),
              ),
            ),
            right: _label(
              'Marca',
              _editableField(
                item.marcaCambio,
                'Marca',
                onChanged: (v) => setState(() => item.marcaCambio = v),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _row2(
            isMobile,
            left: _label(
              'Cantidad',
              _editableField(
                item.cantidadCambio,
                'Cantidad',
                onChanged: (v) => setState(() => item.cantidadCambio = v),
                isNumber: true,
              ),
            ),
            right: _label(
              'Próxima fecha',
              _editableField(
                item.proxFechaCambio,
                'dd/mm/yyyy',
                onChanged: (v) => setState(() => item.proxFechaCambio = v),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _row2(
            isMobile,
            left: _label(
              'Próximo kilometraje',
              _editableField(
                item.proxKmCambio,
                'Próximo km',
                onChanged: (v) => setState(() => item.proxKmCambio = v),
                isNumber: true,
              ),
            ),
            right: _label(
              'Observación',
              _editableField(
                item.observCambio,
                'Observación',
                onChanged: (v) => setState(() => item.observCambio = v),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _row2(
            isMobile,
            left: _label(
              'Estado',
              _simpleDropdown(
                value: item.estadoCambio,
                items: const ['Pendiente', 'Completo'],
                onChanged: (v) =>
                    setState(() => item.estadoCambio = v ?? 'Pendiente'),
              ),
            ),
            right: _label(
              'Adjuntar foto *',
              _fotoPickerField(
                nombre: item.fotoName,
                foto: item.foto,
                onTap: () async {
                  final foto = await PhotoFileHelper.pickPhoto();
                  if (foto != null)
                    setState(() {
                      item.foto = foto;
                      item.fotoName = foto.fileName;
                    });
                },
                onViewPhoto: item.foto != null
                    ? () => _showPhotoDialog(
                        item.foto!,
                        'Foto accesorio ${idx + 1}',
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SECCIÓN 3 — DOCUMENTO DE GASTO
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSeccionGasto(bool isMobile) {
    return _card(
      title: 'Documento de gasto *',
      child: Column(
        children: [
          _row2(
            isMobile,
            left: _labelRequired(
              'Tipo de gasto',
              _simpleDropdown(
                value: _tipoGasto,
                items: const ['Boleta', 'Factura'],
                hint: 'Tipo de gasto',
                onChanged: (v) => setState(() => _tipoGasto = v),
              ),
              tooltip: 'Seleccione el tipo de documento',
            ),
            right: _label(
              'Tipo (gas_vtipo_gasto)',
              _simpleDropdown(
                value: _tipoGastoGasto,
                items: const ['Mantenimiento', 'Compra'],
                onChanged: (v) =>
                    setState(() => _tipoGastoGasto = v ?? 'Mantenimiento'),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _row2(
            isMobile,
            left: _label(
              'Nr. factura / DNI / RUC',
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _nrFacturaCtrl,
                builder: (context, value, child) {
                  String tooltipMsg = 'Ingrese N° Factura, Boleta, DNI o RUC';
                  IconData icon = Icons.badge_outlined;
                  Color iconColor = _textSecondary;
                  final text = value.text.trim();
                  final isOnlyDigits = RegExp(r'^\d+$').hasMatch(text);
                  
                  if (text.length == 8 && isOnlyDigits) {
                    tooltipMsg = 'DNI detectado (8 dígitos)';
                    icon = Icons.person;
                    iconColor = _primary;
                  } else if (text.length == 11 && isOnlyDigits) {
                    if (text.startsWith('10')) {
                      tooltipMsg = 'RUC Persona Natural (10)';
                      icon = Icons.person_pin;
                      iconColor = _blue;
                    } else if (text.startsWith('20')) {
                      tooltipMsg = 'RUC Empresa (20)';
                      icon = Icons.domain;
                      iconColor = _green;
                    } else {
                      tooltipMsg = 'RUC detectado (11 dígitos)';
                      icon = Icons.assignment_outlined;
                      iconColor = _blue;
                    }
                  } else if (text.isNotEmpty) {
                    if (RegExp(r'[a-zA-Z]').hasMatch(text) || text.contains('-') || text.contains('/')) {
                      tooltipMsg = 'Factura / Boleta / Doc. Alfanumérico';
                      icon = Icons.receipt_long_rounded;
                      iconColor = _primary;
                    } else {
                      tooltipMsg = 'Documento de referencia';
                      icon = Icons.badge_outlined;
                      iconColor = _primary;
                    }
                  }

                  return Tooltip(
                    message: tooltipMsg,
                    child: TextFormField(
                      controller: _nrFacturaCtrl,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9\-\/\s]'),
                        ),
                      ],
                      maxLength: 30,
                      style: const TextStyle(fontSize: 13),
                      decoration: _inputDec(
                        hint: 'Ej: F001-00012345, 10738495012 o DNI',
                        suffix: text.isNotEmpty ? '${text.length}/30' : null,
                      ).copyWith(
                        prefixIcon: Icon(icon, color: iconColor, size: 18),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return null; // No es obligatorio
                        }
                        final clean = val.trim();
                        if (clean.length < 3) {
                          return 'Debe ingresar al menos 3 caracteres';
                        }
                        if (clean.length > 30) {
                          return 'No puede superar 30 caracteres';
                        }
                        return null;
                      },
                    ),
                  );
                },
              ),
            ),
            right: const SizedBox.shrink(),
          ),
          const SizedBox(height: 10),
          _row2(
            isMobile,
            left: _labelRequired(
              'Moneda',
              _simpleDropdown(
                value: _moneda,
                items: const ['Soles', 'Dólares'],
                hint: 'Moneda',
                onChanged: (v) => setState(() => _moneda = v),
              ),
              tooltip: 'Seleccione la moneda',
            ),
            right: _labelRequired(
              'Monto',
              TextFormField(
                controller: _montoCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(fontSize: 13),
                decoration: _inputDec(
                  hint: '0.00',
                  prefix: _moneda == 'Dólares' ? 'US\$ ' : 'S/ ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Monto requerido';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Ingrese un número válido';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Monto debe ser mayor a 0';
                  }
                  return null;
                },
              ),
              tooltip: 'Ingrese el monto del gasto',
            ),
          ),
          const SizedBox(height: 10),
          _label(
            'Observaciones',
            TextFormField(
              controller: _observGastoCtrl,
              maxLines: 2,
              style: const TextStyle(fontSize: 13),
              decoration: _inputDec(hint: 'Observaciones del gasto...'),
            ),
          ),
          const SizedBox(height: 10),
          _labelRequired(
            'Adjuntar foto del gasto',
            _fotoPickerField(
              nombre: _gastoFotoName,
              foto: _gastoFoto,
              onTap: () async {
                final foto = await PhotoFileHelper.pickPhoto();
                if (foto != null)
                  setState(() {
                    _gastoFoto = foto;
                    _gastoFotoName = foto.fileName;
                  });
              },
              onViewPhoto: _gastoFoto != null
                  ? () =>
                        _showPhotoDialog(_gastoFoto!, 'Foto documento de gasto')
                  : null,
            ),
            tooltip: 'Adjunte la foto del comprobante de gasto',
          ),
        ],
      ),
    );
  }

  // ── Dialog para ver foto en grande ────────────────────────────────────────
  void _showPhotoDialog(SelectedPhoto foto, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black87,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.image, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            // Imagen
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: kIsWeb && foto.bytes != null
                    ? Image.memory(foto.bytes!, fit: BoxFit.contain)
                    : (foto.filePath != null
                          ? Image.file(
                              File(foto.filePath!),
                              fit: BoxFit.contain,
                            )
                          : const Icon(
                              Icons.image_not_supported,
                              size: 100,
                              color: Colors.white,
                            )),
              ),
            ),
            // Info
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.black54,
              child: Column(
                children: [
                  Text(
                    foto.fileName,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(foto.sizeBytes / 1024).toStringAsFixed(1)} KB',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────
  Widget _buildFooter(bool isMobile) {
    return BlocBuilder<RegistroMantenimientoBloc, RegistroMantenimientoState>(
      builder: (ctx, state) => Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 24,
          vertical: 12,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: _border)),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(14),
          ),
        ),
        child: Row(
          children: [
            const Spacer(),
            TextButton(
              onPressed: state.enviando
                  ? null
                  : () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: _textSecondary, fontSize: 13),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: state.enviando ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _primary.withOpacity(0.4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: state.enviando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Registrar',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: _red, size: 40),
          const SizedBox(height: 12),
          const Text(
            'Error al cargar datos',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _red,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: _textSecondary),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () => context.read<RegistroMantenimientoBloc>().add(
              const CargarDatosInicialesEvent(),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  // ══════════════════════════════════════════════════════════════════════════
  // HELPERS UI
  // ══════════════════════════════════════════════════════════════════════════
  Widget _card({required String title, required Widget child}) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: _border),
        Padding(padding: const EdgeInsets.all(14), child: child),
      ],
    ),
  );

  Widget _moduloCard({
    required String title,
    required Color color,
    required Color colorBg,
    required Widget child,
  }) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: colorBg.withOpacity(0.45),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.35)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              color == _blue
                  ? Icons.build_circle_outlined
                  : Icons.swap_horiz_rounded,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );

  Widget _row2(bool isMobile, {required Widget left, required Widget right}) {
    if (isMobile) {
      return Column(children: [left, const SizedBox(height: 10), right]);
    }
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 14),
        Expanded(child: right),
      ],
    );
  }

  Widget _label(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
        ),
      ),
      const SizedBox(height: 5),
      child,
    ],
  );

  Widget _labelRequired(String label, Widget child, {String? tooltip}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              Text(' *', style: const TextStyle(fontSize: 11, color: _red)),
              if (tooltip != null) ...[
                const SizedBox(width: 4),
                Tooltip(
                  message: tooltip,
                  child: Icon(
                    Icons.info_outline,
                    size: 14,
                    color: _textSecondary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 5),
          child,
        ],
      );

  Widget _simpleDropdown({
    required String? value,
    required List<String> items,
    String? hint,
    required void Function(String?) onChanged,
  }) => DropdownButtonFormField<String>(
    value: value,
    isExpanded: true,
    decoration: InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
    ),
    hint: hint != null
        ? Text(
            hint,
            style: const TextStyle(fontSize: 13, color: _textSecondary),
          )
        : null,
    items: items
        .map(
          (s) => DropdownMenuItem(
            value: s,
            child: Text(s, style: const TextStyle(fontSize: 13)),
          ),
        )
        .toList(),
    onChanged: onChanged,
    dropdownColor: Colors.white,
    style: const TextStyle(fontSize: 13, color: _textPrimary),
  );

  /// ✅ Campo con candado - SIN ValueKey para NO perder el foco
  Widget _lockableField({
    required String value,
    required String hint,
    required bool unlocked,
    required VoidCallback onToggleLock,
    required void Function(String) onChanged,
    bool highlight = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: unlocked
              ? TextFormField(
                  // ✅ ELIMINADO: ValueKey que causaba pérdida de foco
                  initialValue: value,
                  style: const TextStyle(fontSize: 13),
                  decoration: _inputDec(
                    hint: hint,
                  ).copyWith(fillColor: const Color(0xFFFFFBEB), filled: true),
                  onChanged: onChanged,
                  textInputAction: TextInputAction.next,
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: highlight && value.isNotEmpty
                        ? _primaryLight
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: highlight && value.isNotEmpty ? _primary : _border,
                    ),
                  ),
                  child: Text(
                    value.isEmpty ? hint : value,
                    style: TextStyle(
                      fontSize: 13,
                      color: value.isEmpty ? _textSecondary : _textPrimary,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 4),
        Tooltip(
          message: unlocked ? 'Bloquear campo' : 'Editar campo',
          child: InkWell(
            onTap: onToggleLock,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: unlocked ? _yellowBg : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: unlocked ? _yellow : _border),
              ),
              child: Icon(
                unlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                size: 14,
                color: unlocked ? _yellow : _textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Campo readonly simple sin candado (para tipo mantenimiento que viene del API)
  Widget _readonlyField(String value, String hint, {bool highlight = false}) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: highlight && value.isNotEmpty
              ? _primaryLight
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: highlight && value.isNotEmpty ? _primary : _border,
          ),
        ),
        child: Text(
          value.isEmpty ? hint : value,
          style: TextStyle(
            fontSize: 13,
            color: value.isEmpty ? _textSecondary : _textPrimary,
          ),
        ),
      );

  Widget _editableField(
    String initialValue,
    String hint, {
    required void Function(String) onChanged,
    bool isNumber = false,
  }) => TextFormField(
    initialValue: initialValue,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
    style: const TextStyle(fontSize: 13),
    decoration: _inputDec(hint: hint),
    onChanged: onChanged,
    textInputAction: TextInputAction.next,
  );

  Widget _dateField({
    required DateTime? value,
    required void Function(DateTime) onPicked,
  }) => InkWell(
    onTap: () async {
      final d = await showDatePicker(
        context: context,
        initialDate: value ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      );
      if (d != null) onPicked(d);
    },
    child: IgnorePointer(
      child: TextFormField(
        controller: TextEditingController(
          text: value != null ? _fmtFechaDate(value) : '',
        ),
        style: const TextStyle(fontSize: 13),
        decoration: _inputDec(
          hint: 'dd/mm/yyyy',
          icon: Icons.calendar_today_outlined,
        ),
      ),
    ),
  );

  Widget _disabledField(String msg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _border),
    ),
    child: Text(
      msg,
      style: const TextStyle(fontSize: 12, color: _textSecondary),
    ),
  );

  Widget _loadingWidget(String msg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: _blueBg,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: _blue),
        ),
        const SizedBox(width: 8),
        Text(msg, style: const TextStyle(fontSize: 12, color: _blue)),
      ],
    ),
  );

  /// Campo para seleccionar foto con preview y botón "Ver foto"
  Widget _fotoPickerField({
    required String? nombre,
    required VoidCallback onTap,
    SelectedPhoto? foto,
    VoidCallback? onViewPhoto,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: nombre != null ? _greenBg : const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: nombre != null ? _green : _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior: ícono + nombre + check
          Row(
            children: [
              Icon(
                nombre != null
                    ? Icons.image_rounded
                    : Icons.upload_file_outlined,
                size: 16,
                color: nombre != null ? _green : _textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  nombre ?? 'Adjuntar foto',
                  style: TextStyle(
                    fontSize: 12,
                    color: nombre != null ? _green : _textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (nombre != null)
                const Icon(Icons.check_circle_rounded, size: 14, color: _green),
            ],
          ),
          // ✅ Preview de la foto (si está seleccionada)
          if (foto != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                // Thumbnail
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _border),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: kIsWeb && foto.bytes != null
                        ? Image.memory(foto.bytes!, fit: BoxFit.cover)
                        : (foto.filePath != null
                              ? Image.file(
                                  File(foto.filePath!),
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.image_not_supported,
                                  size: 20,
                                )),
                  ),
                ),
                const SizedBox(width: 12),
                // Info + botón ver
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        foto.fileName,
                        style: const TextStyle(
                          fontSize: 10,
                          color: _textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(foto.sizeBytes / 1024).toStringAsFixed(1)} KB',
                        style: const TextStyle(
                          fontSize: 9,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Botón "Ver foto"
                if (onViewPhoto != null)
                  InkWell(
                    onTap: onViewPhoto,
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _blueBg,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: _blue.withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.visibility, size: 12, color: _blue),
                          SizedBox(width: 4),
                          Text(
                            'Ver',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    ),
  );

  InputDecoration _inputDec({
    required String hint,
    IconData? icon,
    String? suffix,
    String? prefix,
  }) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 13, color: _textSecondary),
    suffixText: suffix,
    prefixText: prefix,
    prefixIcon: icon != null
        ? Icon(icon, size: 16, color: _textSecondary)
        : null,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _border),
    ),
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
  );

  String _fmtFecha(String s) {
    try {
      return _fmtFechaDate(DateTime.parse(s));
    } catch (_) {
      return s;
    }
  }

  String _fmtFechaDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ══════════════════════════════════════════════════════════════════════════════
// Searchable Dropdown con buscador integrado vía Overlay
// ══════════════════════════════════════════════════════════════════════════════

class _DropItem<T> {
  final T value;
  final String label;
  const _DropItem(this.value, this.label);
}

class _SearchableDropdown<T> extends StatefulWidget {
  final T? value;
  final String hint;
  final List<_DropItem<T>> items;
  final void Function(T?) onChanged;

  const _SearchableDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  State<_SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<_SearchableDropdown<T>> {
  final _layerLink = LayerLink();
  final _searchCtrl = TextEditingController();
  OverlayEntry? _overlay;
  bool _open = false;
  List<_DropItem<T>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
  }

  @override
  void didUpdateWidget(_SearchableDropdown<T> old) {
    super.didUpdateWidget(old);
    if (old.items.length != widget.items.length) {
      _filtered = widget.items;
    }
  }

  void _toggle() => _open ? _close() : _openOverlay();

  void _openOverlay() {
    _searchCtrl.clear();
    _filtered = widget.items;
    setState(() => _open = true);

    final box = context.findRenderObject() as RenderBox;
    final size = box.size;

    _overlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // Barrier invisible — cierra al tocar fuera
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _close,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 2),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                child: StatefulBuilder(
                  builder: (ctx, setS) => ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 260),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Buscador
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextField(
                            controller: _searchCtrl,
                            autofocus: true,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Buscar...',
                              hintStyle: const TextStyle(
                                fontSize: 12,
                                color: _textSecondary,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                size: 16,
                                color: _textSecondary,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: _border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: _border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: _primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            onChanged: (q) => setS(() {
                              _filtered = widget.items
                                  .where(
                                    (i) => i.label.toLowerCase().contains(
                                      q.toLowerCase(),
                                    ),
                                  )
                                  .toList();
                            }),
                          ),
                        ),
                        const Divider(height: 1, color: _border),
                        // Lista
                        Flexible(
                          child: _filtered.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'Sin resultados',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _textSecondary,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _filtered.length,
                                  itemBuilder: (_, i) {
                                    final it = _filtered[i];
                                    final sel = it.value == widget.value;
                                    return InkWell(
                                      onTap: () {
                                        widget.onChanged(it.value);
                                        _close();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        color: sel
                                            ? _primaryLight
                                            : Colors.transparent,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                it.label,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: sel
                                                      ? _primary
                                                      : _textPrimary,
                                                  fontWeight: sel
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                            if (sel)
                                              const Icon(
                                                Icons.check_rounded,
                                                size: 14,
                                                color: _primary,
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlay!);
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
    if (mounted) setState(() => _open = false);
  }

  @override
  void dispose() {
    _close();
    _searchCtrl.dispose();
    super.dispose();
  }

  String get _displayLabel {
    if (widget.value == null) return '';
    try {
      return widget.items.firstWhere((i) => i.value == widget.value).label;
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) => CompositedTransformTarget(
    link: _layerLink,
    child: GestureDetector(
      onTap: _toggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _open ? _primary : _border,
            width: _open ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _displayLabel.isEmpty ? widget.hint : _displayLabel,
                style: TextStyle(
                  fontSize: 13,
                  color: _displayLabel.isEmpty ? _textSecondary : _textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              _open
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: _textSecondary,
            ),
          ],
        ),
      ),
    ),
  );
}
