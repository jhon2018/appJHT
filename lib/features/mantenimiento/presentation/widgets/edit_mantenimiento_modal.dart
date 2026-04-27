// Ruta: lib/features/mantenimiento/presentation/widgets/edit_mantenimiento_modal.dart
// REQF03 — Actualización de actividades pendientes
// API18 → detalle-mantenimiento (GET)
// API30 → actualizar-historico  (PUT)
//
// BUGS CORREGIDOS:
//  1. Overflow foto en desktop → _FotoPreview usa AspectRatio(1) + mainAxisSize.min
//     en lugar de SizedBox(height:120) fijo que era menor que el contenido real.
//  2. Grid desaparece al guardar → patrón _cachedDetalle: el formulario se
//     alimenta de una variable local, NO del estado del bloc. Cuando el bloc
//     emite MantenimientoUpdating el form permanece visible con el spinner.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/mantenimiento/data/models/mantenimiento_model.dart';
import 'package:app_jht_front/features/mantenimiento/data/models/detalle_mantenimiento_model.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/bloc/mantenimiento_bloc.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/bloc/mantenimiento_event.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/bloc/mantenimiento_state.dart';
import 'package:app_jht_front/core/theme/maintenance_colors.dart';
import 'maintenance_form_fields.dart';

class EditMantenimientoModal extends StatefulWidget {
  final MantenimientoModel mantenimiento;
  final VoidCallback? onMantenimientoActualizado;

  const EditMantenimientoModal({
    super.key,
    required this.mantenimiento,
    this.onMantenimientoActualizado,
  });

  @override
  State<EditMantenimientoModal> createState() => _EditMantenimientoModalState();
}

class _EditMantenimientoModalState extends State<EditMantenimientoModal> {
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ──────────────────────────────────────────────────────────
  final _descripcionController = TextEditingController();
  final _proxKmController      = TextEditingController();
  final _proxFechaController   = TextEditingController();

  // ── Estado local ─────────────────────────────────────────────────────────
  bool    _isSaving          = false;
  String? _descripcionError;
  String? _proxKmError;
  String? _proxFechaError;
  String? _estadoError;
  String? _estadoSeleccionado;

  // ── FIX BUG 2: cache del detalle ─────────────────────────────────────────
  // El formulario se renderiza desde aquí, NO desde el estado del bloc.
  // Cuando el bloc emite MantenimientoUpdating/MantenimientoUpdated el form
  // permanece visible porque _cachedDetalle sigue siendo no-null.
  DetalleMantenimientoModel? _cachedDetalle;

  static const _estadoOptions = ['Pendiente', 'En proceso', 'Completado'];

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MantenimientoBloc>().add(
          LoadDetalleMantenimientoEvent(
            bitacoraId:  widget.mantenimiento.bitacoraId,
            accesorioId: widget.mantenimiento.accesorioId,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _proxKmController.dispose();
    _proxFechaController.dispose();
    super.dispose();
  }

  // ── Inline Validation ─────────────────────────────────────────────────────
  void _validateDescripcion(String? v) => setState(() {
        final s = v?.trim() ?? '';
        _descripcionError = s.isEmpty
            ? 'La descripción es requerida'
            : s.length < 5
                ? 'Mínimo 5 caracteres'
                : null;
      });

  void _validateProxKm(String? v) => setState(() {
        final n = int.tryParse(v ?? '');
        _proxKmError = n == null
            ? 'Ingrese un número válido'
            : n <= 0
                ? 'Debe ser mayor a 0'
                : null;
      });

  void _validateProxFecha(String? v) => setState(() {
        _proxFechaError = (v == null || v.isEmpty)
            ? 'Seleccione una fecha'
            : !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v)
                ? 'Formato: AAAA-MM-DD'
                : null;
      });

  void _validateEstado(String? v) => setState(() {
        _estadoError =
            (v == null || v.isEmpty) ? 'Seleccione un estado' : null;
      });

  bool get _formValido =>
      _descripcionError == null &&
      _proxKmError      == null &&
      _proxFechaError   == null &&
      _estadoError      == null;

  // ── Date Picker ───────────────────────────────────────────────────────────
  Future<void> _selectDate(BuildContext ctx) async {
    final initial =
        DateTime.tryParse(_proxFechaController.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context:     ctx,
      initialDate: initial,
      firstDate:   DateTime(2020),
      lastDate:    DateTime(2035),
      locale: const Locale('es', 'ES'),
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme: const ColorScheme.light(
            primary:   MaintenanceColors.primary,
            onPrimary: Colors.white,
            surface:   MaintenanceColors.surface,
            onSurface: MaintenanceColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      final f =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        _proxFechaController.text = f;
        _proxFechaError = null;
      });
    }
  }

  // ── Confirmation Dialog ───────────────────────────────────────────────────
  void _showConfirmationDialog() {
    showDialog(
      context:            context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded,
                color: MaintenanceColors.info, size: 22),
            SizedBox(width: 8),
            Text('Confirmar Actualización',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        content: const Text(
          '¿Está seguro de guardar los cambios en este mantenimiento?',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          Row(
            children: [
              Expanded(
                child: _DialogButton(
                  text:      'CANCELAR',
                  bgColor:   Colors.grey[200]!,
                  textColor: Colors.grey[700]!,
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DialogButton(
                  text:      'CONFIRMAR',
                  bgColor:   MaintenanceColors.primary,
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.pop(ctx);
                    _actualizarMantenimiento();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── API30 ─────────────────────────────────────────────────────────────────
  void _actualizarMantenimiento() {
    setState(() => _isSaving = true);
    context.read<MantenimientoBloc>().add(
      UpdateMantenimientoEvent(
        request: ActualizarMantenimientoRequest(
          bitacoraId:         widget.mantenimiento.bitacoraId,
          accesorioId:        widget.mantenimiento.accesorioId,
          descripcion:        _descripcionController.text.trim(),
          proximoKilometraje: int.parse(_proxKmController.text),
          proximaFecha:       _proxFechaController.text,
          estado:             _estadoSeleccionado!,
        ),
      ),
    );
  }

  void _submitForm() {
    _validateDescripcion(_descripcionController.text);
    _validateProxKm(_proxKmController.text);
    _validateProxFecha(_proxFechaController.text);
    _validateEstado(_estadoSeleccionado);

    if (_formValido) {
      _showConfirmationDialog();
    } else {
      _showFeedbackDialog(
        title:   'Campos incompletos',
        message: 'Complete los campos obligatorios marcados con *',
        type:    FeedbackType.warning,
        icon:    Icons.warning_amber_rounded,
      );
    }
  }

  // ── Feedback Dialog ───────────────────────────────────────────────────────
  void _showFeedbackDialog({
    required String       title,
    required String       message,
    required FeedbackType type,
    required IconData     icon,
    VoidCallback?         onConfirm,
  }) {
    if (!mounted) return;
    final cfg = _feedbackConfig(type);
    showDialog(
      context:            context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(icon, color: cfg.iconColor, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      fontSize:   16,
                      fontWeight: FontWeight.w600,
                      color:      cfg.textColor)),
            ),
          ],
        ),
        content: Text(message,
            style: TextStyle(fontSize: 14, color: cfg.messageColor)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm?.call();
            },
            child: Text('Entendido',
                style: TextStyle(
                    color:      cfg.buttonColor,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  _FeedbackConfig _feedbackConfig(FeedbackType t) {
    switch (t) {
      case FeedbackType.success:
        return const _FeedbackConfig(
          textColor:    MaintenanceColors.successText,
          messageColor: MaintenanceColors.textPrimary,
          iconColor:    MaintenanceColors.success,
          buttonColor:  MaintenanceColors.success,
        );
      case FeedbackType.warning:
        return const _FeedbackConfig(
          textColor:    MaintenanceColors.warningText,
          messageColor: MaintenanceColors.textPrimary,
          iconColor:    MaintenanceColors.warningText,
          buttonColor:  MaintenanceColors.warningText,
        );
      case FeedbackType.error:
        return const _FeedbackConfig(
          textColor:    MaintenanceColors.errorText,
          messageColor: MaintenanceColors.textPrimary,
          iconColor:    MaintenanceColors.error,
          buttonColor:  MaintenanceColors.error,
        );
      case FeedbackType.info:
        return const _FeedbackConfig(
          textColor:    MaintenanceColors.infoText,
          messageColor: MaintenanceColors.textPrimary,
          iconColor:    MaintenanceColors.info,
          buttonColor:  MaintenanceColors.info,
        );
    }
  }

  // ── Foto dialog ───────────────────────────────────────────────────────────
  void _showPhotoDialog(String url, String title) {
    if (url.isEmpty) {
      _showFeedbackDialog(
        title:   'Sin imagen',
        message: 'Este mantenimiento no tiene foto registrada',
        type:    FeedbackType.info,
        icon:    Icons.image_not_supported_rounded,
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding:    const EdgeInsets.all(16),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth:  MediaQuery.of(context).size.width  * 0.9,
          ),
          decoration: BoxDecoration(
              color: Colors.black, borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.image, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              color:      Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize:   14),
                          overflow: TextOverflow.ellipsis),
                    ),
                    IconButton(
                      icon:        const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed:   () => Navigator.of(ctx).pop(),
                      padding:     EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white24, height: 1),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12)),
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.network(
                      url,
                      fit:     BoxFit.contain,
                      headers: const {'Accept': '*/*'},
                      loadingBuilder: (_, child, prog) {
                        if (prog == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: MaintenanceColors.primary,
                            value: prog.expectedTotalBytes != null
                                ? prog.cumulativeBytesLoaded /
                                    prog.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image_rounded,
                                color: Colors.white70, size: 48),
                            SizedBox(height: 8),
                            Text('No se pudo cargar la imagen',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                color:   Colors.black87,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.link, size: 13, color: Colors.white54),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(url.split('/').last,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return BlocConsumer<MantenimientoBloc, MantenimientoState>(
      listener: (context, state) {

        // ── API18 OK → cachear + poblar campos ──────────────────────────────
        if (state is DetalleMantenimientoSuccess) {
          setState(() {
            _cachedDetalle = state.detalle;                     // ← FIX BUG 2
            _descripcionController.text = state.detalle.descripcion;
            _proxKmController.text      = state.detalle.proximoKilometraje.toString();
            _proxFechaController.text   = state.detalle.proximaFecha;
            _estadoSeleccionado         = _estadoOptions.contains(state.detalle.estado)
                ? state.detalle.estado
                : _estadoOptions.first;
            _descripcionError = null;
            _proxKmError      = null;
            _proxFechaError   = null;
            _estadoError      = null;
          });
        }

        // ── API30 OK → feedback + refrescar + cerrar ─────────────────────────
        if (state is MantenimientoUpdated) {
          setState(() => _isSaving = false);
          _showFeedbackDialog(
            title:   '¡Actualización exitosa!',
            message: state.message,
            type:    FeedbackType.success,
            icon:    Icons.check_circle_rounded,
            onConfirm: () {
              widget.onMantenimientoActualizado?.call();
              Future.delayed(const Duration(milliseconds: 200), () {
                if (mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              });
            },
          );
        }

        // ── API30 error ──────────────────────────────────────────────────────
        if (state is MantenimientoUpdateError) {
          setState(() => _isSaving = false);
          _showFeedbackDialog(
            title:   'Error al actualizar',
            message: state.message,
            type:    FeedbackType.error,
            icon:    Icons.error_outline_rounded,
          );
        }
      },

      builder: (context, state) {
        return Dialog(
          backgroundColor: MaintenanceColors.background,
          insetPadding: EdgeInsets.all(isMobile ? 16 : 24),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:  isMobile ? double.infinity : 720,
              maxHeight: MediaQuery.of(context).size.height * 0.92,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(isMobile),
                Flexible(child: _buildContent(state, isMobile)),
                _buildFooter(state, isMobile),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(bool isMobile) => Container(
        padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 20, vertical: 14),
        decoration: const BoxDecoration(
          color:        MaintenanceColors.primary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:        Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.build_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Editar Mantenimiento',
                      style: TextStyle(
                          color:      Colors.white,
                          fontSize:   isMobile ? 15 : 17,
                          fontWeight: FontWeight.w700)),
                  const Text('Actualice los campos permitidos',
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      );

  // ── Content ───────────────────────────────────────────────────────────────
  // FIX BUG 2: la visibilidad del formulario depende de _cachedDetalle,
  // NO del tipo de estado del bloc.
  Widget _buildContent(MantenimientoState state, bool isMobile) {
    // Cargando por primera vez (sin datos en cache)
    if (state is DetalleMantenimientoLoading && _cachedDetalle == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: MaintenanceColors.primary),
              SizedBox(height: 14),
              Text('Cargando información...',
                  style: TextStyle(
                      color:    MaintenanceColors.textSecondary,
                      fontSize: 13)),
            ],
          ),
        ),
      );
    }

    // Error sin datos previos
    if (state is DetalleMantenimientoError && _cachedDetalle == null) {
      return _buildErrorState(state.message);
    }

    // Formulario visible si hay datos (incluye durante MantenimientoUpdating)
    if (_cachedDetalle != null) return _buildForm(isMobile);

    return const SizedBox.shrink();
  }

  // ── Formulario ────────────────────────────────────────────────────────────
  Widget _buildForm(bool isMobile) {
    final det = _cachedDetalle!;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Información del Registro', isMobile),
            const SizedBox(height: 10),
            _ReadonlyGridWithPhoto(
              isMobile:    isMobile,
              items: [
                ReadonlyItem(
                    label: 'Fecha de Registro',
                    value: _fmtFecha(det.fechaRegistro)),
                ReadonlyItem(label: 'Vehículo',  value: det.vehiculoPlaca),
                ReadonlyItem(label: 'Accesorio', value: det.tipoAccesorio),
                ReadonlyItem(
                    label: 'Tipo de Mantenimiento', value: det.concepto),
              ],
              fotoUrl:    det.linkFoto,
              onViewPhoto: () =>
                  _showPhotoDialog(det.linkFoto, 'Foto de mantenimiento'),
            ),
            const SizedBox(height: 20),
            const Divider(color: MaintenanceColors.border, height: 1),
            const SizedBox(height: 20),
            _sectionTitle('Datos a Actualizar', isMobile),
            const SizedBox(height: 10),
            MaintenanceEditableGrid(
              isMobile: isMobile,
              children: [
                MaintenanceFormField.text(
                  label:      'Descripción *',
                  controller:  _descripcionController,
                  hint:        'Ingrese una descripción detallada',
                  errorText:   _descripcionError,
                  onChanged:   _validateDescripcion,
                  validator:   (_) => _descripcionError,
                  maxLines:    3,
                ),
                MaintenanceFormField.number(
                  label:     'Próximo Kilometraje *',
                  controller: _proxKmController,
                  hint:       'Ej: 50000',
                  errorText:  _proxKmError,
                  onChanged:  _validateProxKm,
                  suffix:     'km',
                ),
                MaintenanceFormField.date(
                  label:     'Próxima Fecha *',
                  controller: _proxFechaController,
                  hint:       'AAAA-MM-DD',
                  errorText:  _proxFechaError,
                  onTap:      () => _selectDate(context),
                  onValidate: _validateProxFecha,
                ),
                MaintenanceFormField.dropdown(
                  label:     'Estado *',
                  value:      _estadoSeleccionado,
                  items:      _estadoOptions,
                  hint:       'Seleccione el estado',
                  errorText:  _estadoError,
                  onChanged:  (v) {
                    if (v != null) {
                      setState(() => _estadoSeleccionado = v);
                      _validateEstado(v);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t, bool isMobile) => Row(
        children: [
          Container(
            width:  4,
            height: 16,
            decoration: BoxDecoration(
              color:        MaintenanceColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(t,
              style: TextStyle(
                  fontSize:   isMobile ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color:      MaintenanceColors.textPrimary)),
        ],
      );

  Widget _buildErrorState(String message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                    color: MaintenanceColors.errorBg, shape: BoxShape.circle),
                child: const Icon(Icons.error_outline_rounded,
                    color: MaintenanceColors.error, size: 36),
              ),
              const SizedBox(height: 16),
              const Text('No se pudo cargar el detalle',
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12,
                      color:    MaintenanceColors.textSecondary)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.read<MantenimientoBloc>().add(
                      LoadDetalleMantenimientoEvent(
                        bitacoraId:  widget.mantenimiento.bitacoraId,
                        accesorioId: widget.mantenimiento.accesorioId,
                      ),
                    ),
                icon:  const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MaintenanceColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      );

  // ── Footer ────────────────────────────────────────────────────────────────
  Widget _buildFooter(MantenimientoState state, bool isMobile) {
    final isBusy  = _isSaving || state is MantenimientoUpdating;
    final hasData = _cachedDetalle != null;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 20, vertical: 14),
      decoration: const BoxDecoration(
        color:  MaintenanceColors.surface,
        border: Border(top: BorderSide(color: MaintenanceColors.border)),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: isBusy ? null : () => Navigator.of(context).pop(),
            child: Text('Cancelar',
                style: TextStyle(
                    color: isBusy
                        ? Colors.grey[400]
                        : MaintenanceColors.textSecondary,
                    fontSize:   13,
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: (isBusy || !hasData) ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    MaintenanceColors.primary,
                foregroundColor:         Colors.white,
                disabledBackgroundColor:
                    MaintenanceColors.primary.withOpacity(0.45),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: isBusy
                  ? const SizedBox(
                      width:  18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.save_rounded, size: 16),
                        SizedBox(width: 8),
                        Text('Guardar Cambios',
                            style: TextStyle(
                                fontSize:   13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtFecha(String f) {
    try {
      final dt = DateTime.parse(f);
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}  '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return f;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FIX BUG 1 — Grid readonly + foto SIN overflow en desktop
//
// Causa original: SizedBox(height: 120) era menor que el contenido interno
// (thumbnail 80px + padding + texto "Ver foto" ≈ 140-150px → overflow 10-30px).
//
// Solución aplicada:
//  · En desktop: SizedBox(width: 130) sin altura → la Column interna dicta
//    la altura real del widget.
//  · _FotoPreview usa mainAxisSize.min → no fuerza expansión vertical.
//  · El thumbnail usa AspectRatio(1) → siempre cuadrado, nunca desborda.
// ═══════════════════════════════════════════════════════════════════════════════
class _ReadonlyGridWithPhoto extends StatelessWidget {
  final bool             isMobile;
  final List<ReadonlyItem> items;
  final String           fotoUrl;
  final VoidCallback?    onViewPhoto;

  const _ReadonlyGridWithPhoto({
    required this.isMobile,
    required this.items,
    required this.fotoUrl,
    this.onViewPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final grid = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < items.length; i += (isMobile ? 1 : 2)) ...[
          if (isMobile)
            _ReadonlyTile(item: items[i])
          else
            Row(
              children: [
                Expanded(child: _ReadonlyTile(item: items[i])),
                const SizedBox(width: 14),
                Expanded(
                  child: i + 1 < items.length
                      ? _ReadonlyTile(item: items[i + 1])
                      : const SizedBox(),
                ),
              ],
            ),
          if (i + (isMobile ? 1 : 2) < items.length)
            const SizedBox(height: 10),
        ],
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          grid,
          if (fotoUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            _FotoPreview(url: fotoUrl, onTap: onViewPhoto),
          ],
        ],
      );
    }

    // Desktop: ancho fijo 130 para la foto, SIN altura fija → no hay overflow
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: grid),
        if (fotoUrl.isNotEmpty) ...[
          const SizedBox(width: 16),
          SizedBox(
            width: 130,
            // Sin height fijo — la altura la dicta _FotoPreview (mainAxisSize.min)
            child: _FotoPreview(url: fotoUrl, onTap: onViewPhoto),
          ),
        ],
      ],
    );
  }
}

class _ReadonlyTile extends StatelessWidget {
  final ReadonlyItem item;
  const _ReadonlyTile({required this.item});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.label,
              style: const TextStyle(
                  fontSize:   11,
                  fontWeight: FontWeight.w600,
                  color:      MaintenanceColors.textSecondary)),
          const SizedBox(height: 4),
          Container(
            width:   double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color:        MaintenanceColors.readonlyBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: MaintenanceColors.border),
            ),
            child: Text(
              item.value.isEmpty ? '—' : item.value,
              style: const TextStyle(
                  fontSize:   13,
                  color:      MaintenanceColors.textPrimary,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      );
}

// FIX BUG 1: mainAxisSize.min + AspectRatio(1) = nunca overflow vertical
class _FotoPreview extends StatelessWidget {
  final String       url;
  final VoidCallback? onTap;
  const _FotoPreview({required this.url, this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap:        onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color:        MaintenanceColors.infoBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: MaintenanceColors.info.withOpacity(0.35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // ← no fuerza altura
            children: [
              // Thumbnail cuadrado con AspectRatio → nunca desborda
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    url,
                    fit:     BoxFit.cover,
                    headers: const {'Accept': '*/*'},
                    loadingBuilder: (_, child, prog) {
                      if (prog == null) return child;
                      return Container(
                        color: MaintenanceColors.border,
                        child: const Center(
                          child: SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color:       MaintenanceColors.info),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: MaintenanceColors.border,
                      child: const Icon(Icons.image_not_supported_outlined,
                          color: MaintenanceColors.textSecondary, size: 22),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisSize:      MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.visibility_outlined,
                      size: 13, color: MaintenanceColors.info),
                  SizedBox(width: 4),
                  Flexible(
                    child: Text('Ver foto',
                        style: TextStyle(
                            fontSize:   11,
                            fontWeight: FontWeight.w600,
                            color:      MaintenanceColors.infoText),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers privados del archivo
// ─────────────────────────────────────────────────────────────────────────────
class _DialogButton extends StatelessWidget {
  final String       text;
  final Color        bgColor;
  final Color        textColor;
  final VoidCallback onPressed;
  const _DialogButton({
    required this.text,
    required this.bgColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 42,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: textColor,
            elevation:       0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(text,
              style: TextStyle(
                  color:      textColor,
                  fontSize:   12,
                  fontWeight: FontWeight.w600)),
        ),
      );
}

enum FeedbackType { success, warning, error, info }

class _FeedbackConfig {
  final Color textColor, messageColor, iconColor, buttonColor;
  const _FeedbackConfig({
    required this.textColor,
    required this.messageColor,
    required this.iconColor,
    required this.buttonColor,
  });
}