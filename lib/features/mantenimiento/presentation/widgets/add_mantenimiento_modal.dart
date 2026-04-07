// lib/features/mantenimiento/presentation/widgets/add_mantenimiento_modal.dart
//
// Modal de registro de mantenimiento — REQF04
// Paneles progresivos: Base → Ítems → Gasto
// Responsive: desktop (Dialog 900px) / móvil (fullscreen bottom sheet)

import 'dart:convert';
import 'package:app_jht_front/features/mantenimiento/data/models/accesorio_vehiculo_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:app_jht_front/core/utils/token_service.dart';
import 'package:app_jht_front/core/utils/role_constants.dart';
import '../../data/datasources/registro_mantenimiento_datasource.dart';
import '../../data/models/datos_iniciales_model.dart';
import '../../data/models/accesorio_models.dart';
import '../../data/models/item_mantenimiento_form_model.dart';
import '../bloc/registro_mantenimiento_bloc.dart';
import '../bloc/registro_mantenimiento_event.dart';
import '../bloc/registro_mantenimiento_state.dart';

// ─── Tokens de color ────────────────────────────────────────────────────────
const _primary = Color(0xFF303366);
const _primaryLight = Color(0xFFEEEFF6);
const _surface = Colors.white;
const _border = Color(0xFFE0E0E8);
const _textPrimary = Color(0xFF1A1A2E);
const _textSecondary = Color(0xFF6B7280);

// Feedback semántico
const _colorSuccess = Color(0xFF16A34A);
const _colorSuccessBg = Color(0xFFDCFCE7);
const _colorWarning = Color(0xFFD97706);
const _colorWarningBg = Color(0xFFFEF3C7);
const _colorError = Color(0xFFDC2626);
const _colorErrorBg = Color(0xFFFEE2E2);
const _colorInfo = Color(0xFF2563EB);
const _colorInfoBg = Color(0xFFDBEAFE);

// ─── Widget público ──────────────────────────────────────────────────────────
class AddMantenimientoModal extends StatelessWidget {
  final VoidCallback? onMantenimientoAdded;

  const AddMantenimientoModal({super.key, this.onMantenimientoAdded});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegistroMantenimientoBloc(
        dataSource: RegistroMantenimientoDataSourceImpl(),
      )..add(const CargarDatosInicialesEvent()),
      child: _AddMantenimientoModalBody(
        onMantenimientoAdded: onMantenimientoAdded,
      ),
    );
  }
}

// ─── Body interno ────────────────────────────────────────────────────────────
class _AddMantenimientoModalBody extends StatefulWidget {
  final VoidCallback? onMantenimientoAdded;
  const _AddMantenimientoModalBody({this.onMantenimientoAdded});

  @override
  State<_AddMantenimientoModalBody> createState() =>
      _AddMantenimientoModalBodyState();
}

class _AddMantenimientoModalBodyState
    extends State<_AddMantenimientoModalBody> {
  // ── Controladores de gasto ────────────────────────────────────────────────
  final _numDocController = TextEditingController();
  final _montoController = TextEditingController();
  final _descGastoController = TextEditingController();

  String? _tipoGasto; // Boleta | Factura
  String? _moneda; // Soles | Dólares
  DateTime? _fechaGasto;
  String? _gastoFotoPath;
  String? _gastoFotoNombre;

  // ── Per_iid del token ─────────────────────────────────────────────────────
  int? _perIidFromToken;
  String? _userRole;

  // ── Form key ──────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fechaGasto = DateTime.now();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final token = await TokenService.getToken();
    final role = await TokenService.getUserRole();
    if (token != null) {
      try {
        // Decodificar JWT para extraer UserId
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          final normalized = base64.normalize(payload);
          final decoded = utf8.decode(base64.decode(normalized));
          final map = jsonDecode(decoded) as Map<String, dynamic>;
          final userId = map['UserId'] ?? map['userId'];
          if (userId != null && mounted) {
            setState(() {
              _perIidFromToken = int.tryParse(userId.toString());
              _userRole = role;
            });
          }
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _numDocController.dispose();
    _montoController.dispose();
    _descGastoController.dispose();
    super.dispose();
  }

  bool get _isAdmin =>
      _userRole == UserRoles.administrador || _userRole == UserRoles.root;

  // ─── Envío ────────────────────────────────────────────────────────────────
  void _submit(RegistroMantenimientoState state) {
    if (!_formKey.currentState!.validate()) return;
    if (state.items.isEmpty) {
      _showToast('Agregue al menos un ítem de mantenimiento', isError: true);
      return;
    }
    if (!state.items.every((i) => i.isComplete)) {
      _showToast('Complete todos los campos de los ítems', isError: true);
      return;
    }

    final perIid = _isAdmin
        ? (state.conductorIdSeleccionado ?? _perIidFromToken ?? 1)
        : (_perIidFromToken ?? 1);

    context.read<RegistroMantenimientoBloc>().add(
          RegistrarMantenimientoEvent(
            perIid: perIid,
            vehIid: state.vehiculoIdSeleccionado!,
            proIid: state.proveedorIdSeleccionado!,
            bitKilometraje: state.kilometrajeVehiculo,
            bitFechaRegistro: DateTime.now(),
            gasTipo: _tipoGasto ?? 'Boleta',
            gasMoneda: _moneda ?? 'Soles',
            gasNumeroDocumento:
                int.tryParse(_numDocController.text) ?? 0,
            gasMonto:
                double.tryParse(_montoController.text) ?? 0,
            gasFechaGasto: _fechaGasto ?? DateTime.now(),
            gasDescripcion: _descGastoController.text,
            gasTipoGasto: _tipoGasto ?? 'Boleta',
            gastoFotoPath: _gastoFotoPath,
          ),
        );
  }

  void _showToast(String msg, {bool isError = false, bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor:
            isError ? _colorError : isSuccess ? _colorSuccess : _colorInfo,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : isSuccess
                      ? Icons.check_circle_outline_rounded
                      : Icons.info_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(msg,
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return BlocListener<RegistroMantenimientoBloc, RegistroMantenimientoState>(
      listener: (ctx, state) {
        if (state.exitoRegistro) {
          Navigator.of(ctx).pop();
          _showToast(
            '✓ Mantenimiento registrado correctamente (ID: ${state.bitacoraIdCreada})',
            isSuccess: true,
          );
          widget.onMantenimientoAdded?.call();
        } else if (state.errorRegistro != null) {
          _showToast(state.errorRegistro!, isError: true);
        }
      },
      child: isMobile ? _buildMobile() : _buildDesktop(),
    );
  }

  // ─── Desktop: Dialog 900px ────────────────────────────────────────────────
  Widget _buildDesktop() {
    return Dialog(
      backgroundColor: _surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 900,
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        child: Column(
          children: [
            _buildHeader(isMobile: false),
            Expanded(child: _buildScrollContent(isMobile: false)),
            _buildFooter(isMobile: false),
          ],
        ),
      ),
    );
  }

  // ─── Móvil: fullscreen ────────────────────────────────────────────────────
  Widget _buildMobile() {
    return Dialog.fullscreen(
      backgroundColor: _surface,
      child: Column(
        children: [
          _buildHeader(isMobile: true),
          Expanded(child: _buildScrollContent(isMobile: true)),
          _buildFooter(isMobile: true),
        ],
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader({required bool isMobile}) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 24, vertical: 16),
      decoration: const BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.build_rounded, color: Colors.white, size: 20),
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
                    fontSize: isMobile ? 15 : 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'Complete los datos del servicio de mantenimiento',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }

  // ─── Scroll content ───────────────────────────────────────────────────────
  Widget _buildScrollContent({required bool isMobile}) {
    return BlocBuilder<RegistroMantenimientoBloc, RegistroMantenimientoState>(
      builder: (ctx, state) {
        if (state.cargandoDatosIniciales) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: _primary),
                SizedBox(height: 16),
                Text('Cargando datos...', style: TextStyle(color: _textSecondary)),
              ],
            ),
          );
        }
        if (state.errorDatosIniciales != null) {
          return _buildErrorState(state.errorDatosIniciales!);
        }
        if (state.datosIniciales == null) {
          return const SizedBox.shrink();
        }

        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PANEL 1: Datos base
                _buildPanelBase(state, isMobile),
                const SizedBox(height: 24),

                // PANEL 2: Ítems (aparece cuando hay segmento seleccionado)
                if (state.vehiculoIdSeleccionado != null &&
                    state.segmentoIdSeleccionado != null) ...[
                  _buildPanelItems(state, isMobile),
                  const SizedBox(height: 24),
                ],

                // PANEL 3: Gasto
                _buildPanelGasto(state, isMobile),
              ],
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PANEL 1 — DATOS BASE
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPanelBase(
      RegistroMantenimientoState state, bool isMobile) {
    final DatosInicialesModel datos = state.datosIniciales!;
    // typed local lists to avoid dynamic inference
    final vehiculos = datos.vehiculos;
    final proveedores = datos.proveedores;
    final conductores = datos.conductores;
    final segmentos = datos.segmentos;

    return _buildSectionCard(
      icon: Icons.directions_car_outlined,
      title: 'Datos del Servicio',
      subtitle: 'Seleccione el vehículo, proveedor y segmento',
      child: Column(
        children: [
          // Fila 1: Vehículo + Proveedor
          isMobile
              ? Column(children: [
                  _buildVehiculoSelect(state, datos),
                  const SizedBox(height: 12),
                  _buildProveedorSelect(state, datos),
                ])
              : Row(children: [
                  Expanded(child: _buildVehiculoSelect(state, datos)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildProveedorSelect(state, datos)),
                ]),
          const SizedBox(height: 12),

          // Fila 2: Conductor (solo admin) + Kilometraje
          if (_isAdmin) ...[
            isMobile
                ? Column(children: [
                    _buildConductorSelect(state, datos),
                    const SizedBox(height: 12),
                    _buildKilometrajeField(state),
                  ])
                : Row(children: [
                    Expanded(child: _buildConductorSelect(state, datos)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildKilometrajeField(state)),
                  ]),
            const SizedBox(height: 12),
          ] else ...[
            _buildKilometrajeField(state),
            const SizedBox(height: 12),
          ],

          // Segmento
          _buildSegmentoSelect(state, datos),
        ],
      ),
    );
  }

  Widget _buildVehiculoSelect(
      RegistroMantenimientoState state, DatosInicialesModel datos) {
    final List<VehiculoInicialModel> vehiculos = datos.vehiculos;
    return _buildFieldLabel(
      label: 'Vehículo *',
      child: _buildDropdown<int>(
        value: state.vehiculoIdSeleccionado,
        hint: 'Seleccione vehículo',
        items: vehiculos.map((VehiculoInicialModel v) => DropdownMenuItem<int>(
                  value: v.id,
                  child: Row(
                    children: [
                      const Icon(Icons.directions_car_outlined,
                          size: 14, color: _primary),
                      const SizedBox(width: 8),
                      Text(v.placa,
                          style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text('• ${v.kilometraje} km',
                          style: const TextStyle(
                              fontSize: 11, color: _textSecondary)),
                    ],
                  ),
                )).toList(),
        onChanged: (id) {
          if (id == null) return;
          final VehiculoInicialModel v =
              vehiculos.firstWhere((v) => v.id == id);
          context.read<RegistroMantenimientoBloc>().add(
                VehiculoSeleccionadoEvent(
                  vehiculoId: id,
                  kilometraje: v.kilometraje,
                ),
              );
        },
        validator: (v) => v == null ? 'Seleccione un vehículo' : null,
      ),
    );
  }

  Widget _buildProveedorSelect(
      RegistroMantenimientoState state, DatosInicialesModel datos) {
    final List<ProveedorInicialModel> proveedores = datos.proveedores;
    return _buildFieldLabel(
      label: 'Proveedor *',
      child: _buildDropdown<int>(
        value: state.proveedorIdSeleccionado,
        hint: 'Seleccione proveedor',
        items: proveedores.map((ProveedorInicialModel p) => DropdownMenuItem<int>(
                  value: p.id,
                  child: Text(p.razonSocial,
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis),
                )).toList(),
        onChanged: (id) {
          if (id == null) return;
          context.read<RegistroMantenimientoBloc>().emit(
                context
                    .read<RegistroMantenimientoBloc>()
                    .state
                    .copyWith(proveedorIdSeleccionado: id),
              );
        },
        validator: (v) => v == null ? 'Seleccione un proveedor' : null,
      ),
    );
  }

  Widget _buildConductorSelect(
      RegistroMantenimientoState state, DatosInicialesModel datos) {
    final List<ConductorInicialModel> conductores = datos.conductores;
    return _buildFieldLabel(
      label: 'Conductor *',
      child: _buildDropdown<int>(
        value: state.conductorIdSeleccionado,
        hint: 'Seleccione conductor',
        items: conductores.map((ConductorInicialModel c) => DropdownMenuItem<int>(
                  value: c.id,
                  child: Text(c.nombreCompleto,
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis),
                )).toList(),
        onChanged: (id) {
          if (id == null) return;
          context.read<RegistroMantenimientoBloc>().emit(
                context
                    .read<RegistroMantenimientoBloc>()
                    .state
                    .copyWith(conductorIdSeleccionado: id),
              );
        },
        validator: (v) =>
            _isAdmin && v == null ? 'Seleccione un conductor' : null,
      ),
    );
  }

  Widget _buildKilometrajeField(RegistroMantenimientoState state) {
    return _buildFieldLabel(
      label: 'Kilometraje del vehículo *',
      child: TextFormField(
        initialValue: state.kilometrajeVehiculo > 0
            ? state.kilometrajeVehiculo.toString()
            : '',
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 13),
        decoration: _inputDecoration(
          hint: 'Ingrese kilometraje',
          suffixText: 'km',
          icon: Icons.speed_outlined,
        ),
        onChanged: (v) {
          final km = int.tryParse(v) ?? 0;
          context.read<RegistroMantenimientoBloc>().emit(
                context
                    .read<RegistroMantenimientoBloc>()
                    .state
                    .copyWith(kilometrajeVehiculo: km),
              );
        },
        validator: (v) =>
            (v == null || v.isEmpty) ? 'Ingrese el kilometraje' : null,
      ),
    );
  }

  Widget _buildSegmentoSelect(
      RegistroMantenimientoState state, DatosInicialesModel datos) {
    final List<SegmentoInicialModel> segmentos = datos.segmentos;
    return _buildFieldLabel(
      label: 'Segmento de mantenimiento *',
      child: Column(
        children: [
          _buildDropdown<int>(
            value: state.segmentoIdSeleccionado,
            hint: state.vehiculoIdSeleccionado == null
                ? 'Primero seleccione un vehículo'
                : 'Seleccione segmento',
            enabled: state.vehiculoIdSeleccionado != null,
            items: segmentos.map((SegmentoInicialModel s) => DropdownMenuItem<int>(
                      value: s.id,
                      child: Text(s.nombre,
                          style: const TextStyle(fontSize: 13)),
                    )).toList(),
            onChanged: state.vehiculoIdSeleccionado == null
                ? null
                : (id) {
                    if (id == null) return;
                    context.read<RegistroMantenimientoBloc>().add(
                          SegmentoSeleccionadoEvent(
                            segmentoId: id,
                            vehiculoId: state.vehiculoIdSeleccionado!,
                          ),
                        );
                  },
            validator: (v) =>
                v == null ? 'Seleccione un segmento' : null,
          ),
          // Loading API14
          if (state.cargandoAccesoriosConcepto) ...[
            const SizedBox(height: 8),
            _buildInlineLoader('Cargando accesorios del concepto...'),
          ],
          // Error API14
          if (state.errorAccesoriosConcepto != null) ...[
            const SizedBox(height: 8),
            _buildInlineFeedback(
              state.errorAccesoriosConcepto!,
              color: _colorError,
              bg: _colorErrorBg,
              icon: Icons.error_outline_rounded,
            ),
          ],
          // Info: N accesorios encontrados
          if (!state.cargandoAccesoriosConcepto &&
              state.accesoriosConcepto.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInlineFeedback(
              '${state.accesoriosConcepto.length} accesorio(s) disponible(s) para este segmento',
              color: _colorSuccess,
              bg: _colorSuccessBg,
              icon: Icons.check_circle_outline_rounded,
            ),
          ],
          if (!state.cargandoAccesoriosConcepto &&
              state.segmentoIdSeleccionado != null &&
              state.accesoriosConcepto.isEmpty &&
              state.errorAccesoriosConcepto == null) ...[
            const SizedBox(height: 8),
            _buildInlineFeedback(
              'No hay accesorios para este segmento en el vehículo seleccionado',
              color: _colorWarning,
              bg: _colorWarningBg,
              icon: Icons.warning_amber_rounded,
            ),
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PANEL 2 — ÍTEMS DE MANTENIMIENTO
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPanelItems(
      RegistroMantenimientoState state, bool isMobile) {
    return _buildSectionCard(
      icon: Icons.list_alt_rounded,
      title: 'Ítems de Mantenimiento',
      subtitle:
          '${state.items.length}/20 ítems agregados • Seleccione los accesorios a mantener',
      headerTrailing: state.items.isNotEmpty
          ? _buildItemCountBadge(state.items.length)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lista de accesorios disponibles (API14)
          if (state.accesoriosConcepto.isNotEmpty) ...[
            _buildDisponiblesHeader(state),
            const SizedBox(height: 8),
            _buildAccesoriosDisponibles(state, isMobile),
            const SizedBox(height: 20),
          ],

          // Ítems agregados
          if (state.items.isEmpty)
            _buildEmptyItems()
          else ...[
            const Divider(color: _border),
            const SizedBox(height: 12),
            Text(
              'Ítems seleccionados',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            ...state.items.asMap().entries.map((entry) =>
                _buildItemCard(entry.key, entry.value, state, isMobile)),
          ],
        ],
      ),
    );
  }

  Widget _buildDisponiblesHeader(RegistroMantenimientoState state) {
    return Row(
      children: [
        const Icon(Icons.touch_app_outlined, size: 14, color: _textSecondary),
        const SizedBox(width: 6),
        Text(
          'Toque para agregar un accesorio',
          style: TextStyle(
              fontSize: 12, color: _textSecondary),
        ),
        const Spacer(),
        if (state.maxItemsAlcanzado)
          _buildInlineBadge('Máximo alcanzado (20)',
              color: _colorWarning, bg: _colorWarningBg),
      ],
    );
  }

  Widget _buildAccesoriosDisponibles(
      RegistroMantenimientoState state, bool isMobile) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: state.accesoriosConcepto.map((acc) {
        final yaAgregado = state.items.any(
          (i) => i.accesorioConcepto.accesorioId == acc.accesorioId,
        );
        return _buildAccesorioChip(acc, yaAgregado, state);
      }).toList(),
    );
  }

  Widget _buildAccesorioChip(
      AccesorioConceptoModel acc, bool yaAgregado,
      RegistroMantenimientoState state) {
    return InkWell(
      onTap: yaAgregado || state.maxItemsAlcanzado
          ? null
          : () {
              context
                  .read<RegistroMantenimientoBloc>()
                  .add(AgregarItemEvent(accesorioConcepto: acc));
            },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: yaAgregado ? _colorSuccessBg : _primaryLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: yaAgregado ? _colorSuccess : _primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              yaAgregado
                  ? Icons.check_circle_rounded
                  : acc.esCambio
                      ? Icons.swap_horiz_rounded
                      : Icons.build_circle_outlined,
              size: 14,
              color: yaAgregado ? _colorSuccess : _primary,
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  acc.tipoNombre,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: yaAgregado ? _colorSuccess : _primary,
                  ),
                ),
                Text(
                  acc.conceptoNombre,
                  style: TextStyle(
                    fontSize: 10,
                    color: yaAgregado
                        ? _colorSuccess.withOpacity(0.8)
                        : _textSecondary,
                  ),
                ),
              ],
            ),
            if (!yaAgregado) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: acc.esCambio
                      ? _colorWarningBg
                      : _colorInfoBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  acc.esCambio ? 'CAMBIO' : 'MTTO',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: acc.esCambio ? _colorWarning : _colorInfo,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyItems() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(Icons.playlist_add_rounded, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(
            'Ningún ítem seleccionado',
            style:
                TextStyle(fontSize: 13, color: _textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'Toque los chips de arriba para agregar ítems',
            style: TextStyle(
                fontSize: 11, color: _textSecondary.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  // ── Card de un ítem ───────────────────────────────────────────────────────
  Widget _buildItemCard(int index, ItemMantenimientoForm item,
      RegistroMantenimientoState state, bool isMobile) {
    final List<ConceptoMantenimientoModel> conceptos =
        state.conceptosPorItem[index] ?? <ConceptoMantenimientoModel>[];
    final bool isLoadingConceptos = state.cargandoConceptos[index] ?? false;
    final esCambio = item.esCambio;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: item.isComplete
              ? _colorSuccess.withOpacity(0.4)
              : _border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header del ítem
          _buildItemCardHeader(index, item, esCambio),
          const Divider(height: 1, color: _border),
          // Cuerpo del ítem
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Accesorios del vehículo (API13 — info visual)
                _buildAccesorioInfo(item),
                const SizedBox(height: 12),

                // Selector de concepto (API15)
                _buildConceptoSelector(
                    index, item, conceptos, isLoadingConceptos, state),

                // Si hay concepto seleccionado → mostrar campos
                if (item.conceptoSeleccionado != null) ...[
                  const SizedBox(height: 12),
                  _buildItemFields(index, item, esCambio, isMobile, state),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCardHeader(
      int index, ItemMantenimientoForm item, bool esCambio) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: esCambio ? _colorWarningBg : _colorInfoBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              esCambio
                  ? Icons.swap_horiz_rounded
                  : Icons.build_circle_outlined,
              size: 15,
              color: esCambio ? _colorWarning : _colorInfo,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.accesorioConcepto.tipoNombre,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                Text(
                  item.accesorioConcepto.conceptoNombre,
                  style: const TextStyle(
                      fontSize: 11, color: _textSecondary),
                ),
              ],
            ),
          ),
          // Badge tipo
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: esCambio ? _colorWarningBg : _colorInfoBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              esCambio ? 'CAMBIO' : 'MANTENIMIENTO',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: esCambio ? _colorWarning : _colorInfo,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Completado check
          if (item.isComplete)
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: _colorSuccessBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  size: 12, color: _colorSuccess),
            ),
          const SizedBox(width: 4),
          // Eliminar
          InkWell(
            onTap: () => context
                .read<RegistroMantenimientoBloc>()
                .add(EliminarItemEvent(itemIndex: index)),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close_rounded,
                  size: 16, color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccesorioInfo(ItemMantenimientoForm item) {
    final acc = item.accesorioConcepto;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 14, color: _textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${acc.marca} • ${acc.codigoFabricante} • Instalado: ${_formatFecha(acc.fechaInstalacion)}',
              style: const TextStyle(
                  fontSize: 11, color: _textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConceptoSelector(
    int index,
    ItemMantenimientoForm item,
    List<ConceptoMantenimientoModel> conceptos,
    bool isLoading,
    RegistroMantenimientoState state,
  ) {
    // Si aún no se cargaron conceptos, mostrar botón para cargar
    if (conceptos.isEmpty && !isLoading) {
      return OutlinedButton.icon(
        onPressed: () {
          context.read<RegistroMantenimientoBloc>().add(
                CargarConceptosPorTipoEvent(
                  tipoId: item.accesorioConcepto.accesorioId,
                  itemIndex: index,
                ),
              );
        },
        icon: const Icon(Icons.refresh_rounded, size: 14),
        label: const Text('Cargar conceptos disponibles',
            style: TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(
          foregroundColor: _primary,
          side: const BorderSide(color: _primary),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    if (isLoading) return _buildInlineLoader('Cargando conceptos...');

    return _buildFieldLabel(
      label: 'Concepto de mantenimiento *',
      child: _buildDropdown<int>(
        value: item.conceptoSeleccionado?.id,
        hint: 'Seleccione concepto',
        items: conceptos
            .map((ConceptoMantenimientoModel c) => DropdownMenuItem<int>(
                  value: c.id,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: c.esCambio
                              ? _colorWarningBg
                              : _colorInfoBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          c.esCambio ? 'CAMBIO' : 'MTTO',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: c.esCambio
                                ? _colorWarning
                                : _colorInfo,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(c.nombre,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ))
            .toList(),
        onChanged: (id) {
          if (id == null) return;
          final ConceptoMantenimientoModel concepto =
              conceptos.firstWhere((ConceptoMantenimientoModel c) => c.id == id);
          context.read<RegistroMantenimientoBloc>().add(
                ConceptoSeleccionadoEvent(
                  itemIndex: index,
                  concepto: concepto,
                  kilometrajeVehiculo: state.kilometrajeVehiculo,
                ),
              );
        },
      ),
    );
  }

  Widget _buildItemFields(
    int index,
    ItemMantenimientoForm item,
    bool esCambio,
    bool isMobile,
    RegistroMantenimientoState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Campos comunes ─────────────────────────────────────────────────
        isMobile
            ? Column(children: [
                _buildProximoKmField(index, item, state),
                const SizedBox(height: 10),
                _buildProximaFechaField(index, item),
              ])
            : Row(children: [
                Expanded(
                    child: _buildProximoKmField(index, item, state)),
                const SizedBox(width: 12),
                Expanded(child: _buildProximaFechaField(index, item)),
              ]),
        const SizedBox(height: 10),
        _buildDescripcionField(index, item),
        const SizedBox(height: 10),
        _buildEstadoSelector(index, item),
        const SizedBox(height: 10),
        _buildFotoAccesorioField(index, item),

        // ── Solo Cambio: nuevo accesorio ────────────────────────────────────
        if (esCambio) ...[
          const SizedBox(height: 16),
          _buildNuevoAccesorioSection(index, item, isMobile, state),
        ],
      ],
    );
  }

  Widget _buildProximoKmField(
      int index, ItemMantenimientoForm item, RegistroMantenimientoState state) {
    return _buildFieldLabel(
      label: 'Próximo kilometraje',
      child: TextFormField(
        key: ValueKey('km_$index'),
        initialValue: item.proximoKilometraje?.toString() ?? '',
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 13),
        decoration: _inputDecoration(hint: 'Km', suffixText: 'km'),
        onChanged: (v) => context.read<RegistroMantenimientoBloc>().add(
              ActualizarItemEvent(
                itemIndex: index,
                proximoKilometraje: int.tryParse(v),
              ),
            ),
      ),
    );
  }

  Widget _buildProximaFechaField(
      int index, ItemMantenimientoForm item) {
    return _buildFieldLabel(
      label: 'Próxima fecha',
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: item.proximaFecha ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2030),
          );
          if (picked != null) {
            context.read<RegistroMantenimientoBloc>().add(
                  ActualizarItemEvent(
                    itemIndex: index,
                    proximaFecha: picked,
                  ),
                );
          }
        },
        child: IgnorePointer(
          child: TextFormField(
            controller: TextEditingController(
              text: item.proximaFecha != null
                  ? _formatFechaDate(item.proximaFecha!)
                  : '',
            ),
            style: const TextStyle(fontSize: 13),
            decoration: _inputDecoration(
              hint: 'dd/mm/yyyy',
              icon: Icons.calendar_today_outlined,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescripcionField(int index, ItemMantenimientoForm item) {
    return _buildFieldLabel(
      label: 'Descripción / Observaciones',
      child: TextFormField(
        key: ValueKey('desc_$index'),
        initialValue: item.descripcion,
        maxLines: 2,
        style: const TextStyle(fontSize: 13),
        decoration: _inputDecoration(hint: 'Describa el trabajo realizado...'),
        onChanged: (v) => context.read<RegistroMantenimientoBloc>().add(
              ActualizarItemEvent(itemIndex: index, descripcion: v),
            ),
      ),
    );
  }

  Widget _buildEstadoSelector(int index, ItemMantenimientoForm item) {
    return _buildFieldLabel(
      label: 'Estado',
      child: Row(
        children: ['Pendiente', 'Completo'].map((estado) {
          final selected = item.estado == estado;
          return Expanded(
            child: GestureDetector(
              onTap: () => context.read<RegistroMantenimientoBloc>().add(
                    ActualizarItemEvent(itemIndex: index, estado: estado),
                  ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: EdgeInsets.only(
                    right: estado == 'Pendiente' ? 6 : 0),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? (estado == 'Completo'
                          ? _colorSuccessBg
                          : _colorWarningBg)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected
                        ? (estado == 'Completo'
                            ? _colorSuccess
                            : _colorWarning)
                        : _border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      estado == 'Completo'
                          ? Icons.check_circle_outline_rounded
                          : Icons.pending_outlined,
                      size: 14,
                      color: selected
                          ? (estado == 'Completo'
                              ? _colorSuccess
                              : _colorWarning)
                          : _textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      estado,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: selected
                            ? (estado == 'Completo'
                                ? _colorSuccess
                                : _colorWarning)
                            : _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFotoAccesorioField(int index, ItemMantenimientoForm item) {
    return _buildFieldLabel(
      label: 'Foto del accesorio (opcional)',
      child: InkWell(
        onTap: () async {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.image,
            allowMultiple: false,
          );
          if (result != null && result.files.isNotEmpty) {
            context.read<RegistroMantenimientoBloc>().add(
                  ActualizarItemEvent(
                    itemIndex: index,
                    fotoPath: result.files.first.path,
                  ),
                );
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  item.fotoPath != null ? _colorSuccess : _border,
              style: BorderStyle.solid,
            ),
            color: item.fotoPath != null
                ? _colorSuccessBg
                : const Color(0xFFF8F9FC),
          ),
          child: Row(
            children: [
              Icon(
                item.fotoPath != null
                    ? Icons.image_rounded
                    : Icons.add_photo_alternate_outlined,
                size: 16,
                color: item.fotoPath != null
                    ? _colorSuccess
                    : _textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.fotoPath != null
                      ? item.fotoPath!.split('/').last
                      : 'Toque para adjuntar imagen',
                  style: TextStyle(
                    fontSize: 12,
                    color: item.fotoPath != null
                        ? _colorSuccess
                        : _textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (item.fotoPath != null)
                Icon(Icons.check_circle_rounded,
                    size: 14, color: _colorSuccess),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sección nuevo accesorio (solo CAMBIO) ─────────────────────────────────
  Widget _buildNuevoAccesorioSection(
    int index,
    ItemMantenimientoForm item,
    bool isMobile,
    RegistroMantenimientoState state,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _colorWarningBg.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _colorWarning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.swap_horiz_rounded,
                  size: 16, color: _colorWarning),
              const SizedBox(width: 8),
              const Text(
                'Datos del nuevo accesorio',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _colorWarning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          isMobile
              ? Column(children: [
                  _buildNuevaMarcaField(index, item),
                  const SizedBox(height: 10),
                  _buildNuevoCodigoField(index, item),
                ])
              : Row(children: [
                  Expanded(child: _buildNuevaMarcaField(index, item)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildNuevoCodigoField(index, item)),
                ]),
          const SizedBox(height: 10),
          isMobile
              ? Column(children: [
                  _buildNuevaFechaField(index, item),
                  const SizedBox(height: 10),
                  _buildNuevoKmField(index, item, state),
                ])
              : Row(children: [
                  Expanded(child: _buildNuevaFechaField(index, item)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildNuevoKmField(index, item, state)),
                ]),
        ],
      ),
    );
  }

  Widget _buildNuevaMarcaField(int index, ItemMantenimientoForm item) =>
      _buildFieldLabel(
        label: 'Marca del nuevo accesorio *',
        child: TextFormField(
          key: ValueKey('nmarca_$index'),
          initialValue: item.nuevaMarca ?? '',
          style: const TextStyle(fontSize: 13),
          decoration: _inputDecoration(hint: 'Ej: Michelin, Bosch...'),
          onChanged: (v) => context.read<RegistroMantenimientoBloc>().add(
                ActualizarItemEvent(itemIndex: index, nuevaMarca: v),
              ),
          validator: (v) =>
              item.esCambio && (v == null || v.isEmpty)
                  ? 'Ingrese la marca'
                  : null,
        ),
      );

  Widget _buildNuevoCodigoField(int index, ItemMantenimientoForm item) =>
      _buildFieldLabel(
        label: 'Código de fabricante *',
        child: TextFormField(
          key: ValueKey('ncod_$index'),
          initialValue: item.nuevoCodigoFabricante ?? '',
          style: const TextStyle(fontSize: 13),
          decoration: _inputDecoration(hint: 'Código del fabricante'),
          onChanged: (v) => context.read<RegistroMantenimientoBloc>().add(
                ActualizarItemEvent(
                    itemIndex: index, nuevoCodigoFabricante: v),
              ),
          validator: (v) =>
              item.esCambio && (v == null || v.isEmpty)
                  ? 'Ingrese el código'
                  : null,
        ),
      );

  Widget _buildNuevaFechaField(int index, ItemMantenimientoForm item) =>
      _buildFieldLabel(
        label: 'Fecha de instalación *',
        child: InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2030),
            );
            if (picked != null) {
              context.read<RegistroMantenimientoBloc>().add(
                    ActualizarItemEvent(
                      itemIndex: index,
                      nuevaFechaInstalacion: picked,
                    ),
                  );
            }
          },
          child: IgnorePointer(
            child: TextFormField(
              controller: TextEditingController(
                text: item.nuevaFechaInstalacion != null
                    ? _formatFechaDate(item.nuevaFechaInstalacion!)
                    : '',
              ),
              style: const TextStyle(fontSize: 13),
              decoration: _inputDecoration(
                hint: 'dd/mm/yyyy',
                icon: Icons.calendar_today_outlined,
              ),
              validator: (v) =>
                  item.esCambio && (v == null || v.isEmpty)
                      ? 'Seleccione fecha'
                      : null,
            ),
          ),
        ),
      );

  Widget _buildNuevoKmField(
      int index, ItemMantenimientoForm item,
      RegistroMantenimientoState state) =>
      _buildFieldLabel(
        label: 'Km de instalación',
        child: TextFormField(
          key: ValueKey('nkm_$index'),
          initialValue: state.kilometrajeVehiculo > 0
              ? state.kilometrajeVehiculo.toString()
              : '',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 13),
          decoration:
              _inputDecoration(hint: 'Kilometraje', suffixText: 'km'),
          onChanged: (v) => context.read<RegistroMantenimientoBloc>().add(
                ActualizarItemEvent(
                  itemIndex: index,
                  nuevoKilometrajeInstalacion: int.tryParse(v),
                ),
              ),
        ),
      );

  // ══════════════════════════════════════════════════════════════════════════
  // PANEL 3 — GASTO / DOCUMENTO
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPanelGasto(
      RegistroMantenimientoState state, bool isMobile) {
    return _buildSectionCard(
      icon: Icons.receipt_long_outlined,
      title: 'Documento de Gasto',
      subtitle: 'Ingrese los datos de la boleta o factura',
      child: Column(
        children: [
          // Tipo cobro + Moneda
          isMobile
              ? Column(children: [
                  _buildTipoGastoSelector(),
                  const SizedBox(height: 12),
                  _buildMonedaSelector(),
                ])
              : Row(children: [
                  Expanded(child: _buildTipoGastoSelector()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMonedaSelector()),
                ]),
          const SizedBox(height: 12),

          // N° documento + Monto
          isMobile
              ? Column(children: [
                  _buildNumDocField(),
                  const SizedBox(height: 12),
                  _buildMontoField(),
                ])
              : Row(children: [
                  Expanded(child: _buildNumDocField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMontoField()),
                ]),
          const SizedBox(height: 12),

          // Fecha gasto
          _buildFechaGastoField(),
          const SizedBox(height: 12),

          // Descripción
          _buildFieldLabel(
            label: 'Descripción del gasto',
            child: TextFormField(
              controller: _descGastoController,
              maxLines: 2,
              style: const TextStyle(fontSize: 13),
              decoration:
                  _inputDecoration(hint: 'Descripción del gasto...'),
            ),
          ),
          const SizedBox(height: 12),

          // Foto factura
          _buildFotoGastoField(),
        ],
      ),
    );
  }

  Widget _buildTipoGastoSelector() {
    return _buildFieldLabel(
      label: 'Tipo de comprobante',
      child: Row(
        children: ['Boleta', 'Factura'].map((tipo) {
          final selected = _tipoGasto == tipo;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tipoGasto = tipo),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin:
                    EdgeInsets.only(right: tipo == 'Boleta' ? 6 : 0),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? _primaryLight : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected ? _primary : _border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tipo == 'Boleta'
                          ? Icons.receipt_outlined
                          : Icons.description_outlined,
                      size: 14,
                      color: selected ? _primary : _textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tipo,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color:
                            selected ? _primary : _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonedaSelector() {
    return _buildFieldLabel(
      label: 'Moneda',
      child: Row(
        children: [
          ('Soles', 'S/'),
          ('Dólares', 'US\$')
        ].map((entry) {
          final tipo = entry.$1;
          final simbolo = entry.$2;
          final selected = _moneda == tipo;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _moneda = tipo),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: EdgeInsets.only(
                    right: tipo == 'Soles' ? 6 : 0),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? _primaryLight : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected ? _primary : _border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$simbolo  $tipo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color:
                          selected ? _primary : _textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNumDocField() => _buildFieldLabel(
        label: 'N° de documento',
        child: TextFormField(
          controller: _numDocController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 13),
          decoration: _inputDecoration(
              hint: 'Número de documento',
              icon: Icons.tag_rounded),
        ),
      );

  Widget _buildMontoField() => _buildFieldLabel(
        label: 'Monto',
        child: TextFormField(
          controller: _montoController,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 13),
          decoration: _inputDecoration(
            hint: '0.00',
            prefixText:
                _moneda == 'Dólares' ? 'US\$ ' : 'S/ ',
          ),
        ),
      );

  Widget _buildFechaGastoField() => _buildFieldLabel(
        label: 'Fecha del gasto',
        child: InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _fechaGasto ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) setState(() => _fechaGasto = picked);
          },
          child: IgnorePointer(
            child: TextFormField(
              controller: TextEditingController(
                text: _fechaGasto != null
                    ? _formatFechaDate(_fechaGasto!)
                    : '',
              ),
              style: const TextStyle(fontSize: 13),
              decoration: _inputDecoration(
                hint: 'dd/mm/yyyy',
                icon: Icons.calendar_today_outlined,
              ),
            ),
          ),
        ),
      );

  Widget _buildFotoGastoField() {
    return _buildFieldLabel(
      label: 'Imagen del comprobante (opcional)',
      child: InkWell(
        onTap: () async {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.image,
            allowMultiple: false,
          );
          if (result != null && result.files.isNotEmpty) {
            setState(() {
              _gastoFotoPath = result.files.first.path;
              _gastoFotoNombre = result.files.first.name;
            });
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _gastoFotoPath != null ? _colorSuccess : _border,
            ),
            color: _gastoFotoPath != null
                ? _colorSuccessBg
                : const Color(0xFFF8F9FC),
          ),
          child: Row(
            children: [
              Icon(
                _gastoFotoPath != null
                    ? Icons.image_rounded
                    : Icons.upload_file_outlined,
                size: 18,
                color: _gastoFotoPath != null
                    ? _colorSuccess
                    : _textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _gastoFotoNombre ??
                      'Adjuntar imagen de boleta/factura',
                  style: TextStyle(
                    fontSize: 13,
                    color: _gastoFotoPath != null
                        ? _colorSuccess
                        : _textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_gastoFotoPath != null) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle_rounded,
                    size: 16, color: _colorSuccess),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () =>
                      setState(() {
                        _gastoFotoPath = null;
                        _gastoFotoNombre = null;
                      }),
                  child: const Icon(Icons.close_rounded,
                      size: 14, color: _textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── Footer ───────────────────────────────────────────────────────────────
  Widget _buildFooter({required bool isMobile}) {
    return BlocBuilder<RegistroMantenimientoBloc, RegistroMantenimientoState>(
      builder: (ctx, state) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(top: BorderSide(color: _border)),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              // Resumen ítems
              if (state.items.isNotEmpty)
                Expanded(
                  child: Row(
                    children: [
                      _buildItemCountBadge(state.items.length),
                      const SizedBox(width: 8),
                      Text(
                        '${state.items.where((i) => i.isComplete).length} completo(s)',
                        style: const TextStyle(
                            fontSize: 11, color: _textSecondary),
                      ),
                    ],
                  ),
                )
              else
                const Expanded(child: SizedBox.shrink()),

              // Botones
              TextButton(
                onPressed: state.enviando
                    ? null
                    : () => Navigator.of(ctx).pop(),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                      color: state.enviando
                          ? _textSecondary
                          : _textSecondary,
                      fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: state.enviando ||
                        !state.datosListos
                    ? null
                    : () => _submit(state),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _primary.withOpacity(0.4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
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
                    : const Text(
                        'Registrar Mantenimiento',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Helpers UI ───────────────────────────────────────────────────────────

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
    Widget? headerTrailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 14, color: _primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                            fontSize: 10, color: _textSecondary),
                      ),
                    ],
                  ),
                ),
                if (headerTrailing != null) headerTrailing,
              ],
            ),
          ),
          const Divider(height: 1, color: _border),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(
      {required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
    String? Function(T?)? validator,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        filled: !enabled,
        fillColor:
            !enabled ? const Color(0xFFF3F4F6) : null,
      ),
      hint: Text(hint,
          style: const TextStyle(
              fontSize: 13, color: _textSecondary)),
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      style: const TextStyle(
          fontSize: 13, color: _textPrimary),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(10),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? icon,
    String? suffixText,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
          fontSize: 13, color: _textSecondary),
      prefixText: prefixText,
      suffixText: suffixText,
      prefixIcon: icon != null
          ? Icon(icon, size: 16, color: _textSecondary)
          : null,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        borderSide: const BorderSide(color: _colorError),
      ),
    );
  }

  Widget _buildInlineLoader(String msg) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _colorInfoBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: _colorInfo),
          ),
          const SizedBox(width: 10),
          Text(msg,
              style: const TextStyle(
                  fontSize: 12, color: _colorInfo)),
        ],
      ),
    );
  }

  Widget _buildInlineFeedback(
    String msg, {
    required Color color,
    required Color bg,
    required IconData icon,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(msg,
                style: TextStyle(fontSize: 12, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineBadge(
    String text, {
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color)),
    );
  }

  Widget _buildItemCountBadge(int count) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count ítem${count != 1 ? 's' : ''}',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _primary,
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                  color: _colorErrorBg, shape: BoxShape.circle),
              child: const Icon(Icons.error_outline_rounded,
                  color: _colorError, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Error al cargar datos',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _colorError)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: _textSecondary)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context
                  .read<RegistroMantenimientoBloc>()
                  .add(const CargarDatosInicialesEvent()),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Formatters ───────────────────────────────────────────────────────────
  String _formatFecha(String fecha) {
    try {
      final dt = DateTime.parse(fecha);
      return _formatFechaDate(dt);
    } catch (_) {
      return fecha;
    }
  }

  String _formatFechaDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}