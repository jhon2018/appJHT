// Ruta: lib/features/vehicle/presentation/widgets/add_vehicle_modal.dart
// Definición: Modal para agregar vehículos
// Objetivo: Proporcionar interfaz para registro de nuevos vehículos
// lib/features/vehicle/presentation/widgets/add_vehicle_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_registro_dto.dart';
import 'package:app_jht_front/features/vehicle/presentation/bloc/vehicle_bloc.dart';

class AddVehicleModal extends StatefulWidget {
  final VoidCallback? onVehicleAdded;

  const AddVehicleModal({
    super.key,
    this.onVehicleAdded,
  });

  @override
  State<AddVehicleModal> createState() => _AddVehicleModalState();
}

class _AddVehicleModalState extends State<AddVehicleModal> {
  final _formKey = GlobalKey<FormState>();

  // Controladores - Datos básicos
  final _placaController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _vinController = TextEditingController();
  final _colorController = TextEditingController();
  final _tipoController = TextEditingController();
  final _tarjetaCirculacionController = TextEditingController();

  // Controladores - Dimensiones y pesos
  final _asientosController = TextEditingController(text: '4');
  final _ejesController = TextEditingController(text: '2');
  final _pesoNetoController = TextEditingController(text: '1500.0');
  final _pesoBrutoController = TextEditingController(text: '2000.0');
  final _cargaUtilController = TextEditingController(text: '500.0');
  final _largoController = TextEditingController(text: '4.5');
  final _anchoController = TextEditingController(text: '1.8');
  final _altoController = TextEditingController(text: '1.6');
  final _kilometrajeController = TextEditingController(text: '0');

  String _selectedEstado = 'Activo';
  DateTime? _fechaFabricacion;
  DateTime? _fechaHabilitacionTuc;
  DateTime? _fechaVencimientoTuc;

  // Paleta de colores
  static const Color _primary = Color(0xFF303366);
  static const Color _primaryLight = Color(0xFF4A4F8A);
  static const Color _accent = Color(0xFF5B8DEF);
  static const Color _surface = Color(0xFFF8F9FC);
  static const Color _border = Color(0xFFE2E6F0);

  @override
  void dispose() {
    _placaController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _vinController.dispose();
    _colorController.dispose();
    _tipoController.dispose();
    _tarjetaCirculacionController.dispose();
    _asientosController.dispose();
    _ejesController.dispose();
    _pesoNetoController.dispose();
    _pesoBrutoController.dispose();
    _cargaUtilController.dispose();
    _largoController.dispose();
    _anchoController.dispose();
    _altoController.dispose();
    _kilometrajeController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _showConfirmationDialog();
    } else {
      // Feedback visual cuando hay errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('Por favor, complete todos los campos requeridos.'),
            ],
          ),
          backgroundColor: Colors.orange[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        actionsPadding: const EdgeInsets.all(16),
        title: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.directions_car, color: _primary, size: 28),
            ),
            const SizedBox(height: 12),
            const Text(
              'Confirmar Registro',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _primary,
              ),
            ),
          ],
        ),
        content: Text(
          '¿Está seguro que desea registrar el vehículo con placa "${_placaController.text.toUpperCase()}"?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _registrarVehiculo();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Confirmar', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _registrarVehiculo() {
    final dto = VehicleRegistroDto(
      vehVplaca: _placaController.text.toUpperCase(),
      vehVmarca: _marcaController.text,
      vehVmodelo: _modeloController.text,
      vehVnumeroVin: _vinController.text,
      vehVcolor: _colorController.text,
      vehInumAsientos: int.tryParse(_asientosController.text) ?? 4,
      vehInumEjes: int.tryParse(_ejesController.text) ?? 2,
      vehBpesoNeto: double.tryParse(_pesoNetoController.text) ?? 1500.0,
      vehBpesoBruto: double.tryParse(_pesoBrutoController.text) ?? 2000.0,
      vehBcargaUtil: double.tryParse(_cargaUtilController.text) ?? 500.0,
      vehBlargo: double.tryParse(_largoController.text) ?? 4.5,
      vehBancho: double.tryParse(_anchoController.text) ?? 1.8,
      vehBalto: double.tryParse(_altoController.text) ?? 1.6,
      vehIkilometraje: int.tryParse(_kilometrajeController.text) ?? 0,
      vehDfechFabricacion: _fechaFabricacion?.toIso8601String().split('T')[0] ?? '2023-01-01',
      vehVtipo: _tipoController.text,
      vehVtarjetaUnicaCirculacion: _tarjetaCirculacionController.text,
      vehDfechHabilitacionTuc: _fechaHabilitacionTuc?.toIso8601String().split('T')[0] ?? '2023-01-01',
      vehDfechVencimientoTuc: _fechaVencimientoTuc?.toIso8601String().split('T')[0] ?? '2026-01-01',
      vehVestado: _selectedEstado,
    );

    context.read<VehicleBloc>().add(VehicleEvent.registrarVehiculo(dto: dto));
  }

  Future<void> _selectDate(BuildContext context, {required Function(DateTime) onDateSelected}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onDateSelected(picked);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Seleccionar fecha';
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;
    final bool isTablet = screenWidth >= 768 && screenWidth < 1200;

    return BlocListener<VehicleBloc, VehicleState>(
      listener: (context, state) {
        state.whenOrNull(
          registroExitoso: (response) {
            Navigator.of(context).pop();
            widget.onVehicleAdded?.call(); // ← notifica a vehicle_page para recargar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        response.message,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green[700],
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          },
          error: (message) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                actionsPadding: const EdgeInsets.all(16),
                title: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.error_outline, color: Colors.red, size: 28),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Error al Registrar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
                ),
                actions: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : isTablet ? 40 : 80,
            vertical: isMobile ? 20 : 32,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 900,
              maxHeight: MediaQuery.of(context).size.height * 0.92,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModalHeader(),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Form(
                      key: _formKey,
                      child: isMobile
                          ? _buildMobileLayout()
                          : _buildDesktopLayout(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────

  Widget _buildModalHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
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
            child: const Icon(Icons.directions_car, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AGREGAR VEHÍCULO',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Complete todos los campos requeridos',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white70),
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }

  // ── LAYOUTS ───────────────────────────────────────────────────────────────

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _buildSectionTitle('Datos de Identificación', Icons.badge_outlined),
        const SizedBox(height: 12),
        _buildField('Placa *', _placaController,
            validator: _requiredValidator('la placa'),
            inputFormatters: [UpperCaseTextFormatter()],
            hint: 'Ej: ABC-123'),
        _buildField('Marca *', _marcaController,
            validator: _requiredValidator('la marca'), hint: 'Ej: Toyota'),
        _buildField('Modelo *', _modeloController,
            validator: _requiredValidator('el modelo'), hint: 'Ej: Hilux 2022'),
        _buildField('Número VIN *', _vinController,
            validator: _requiredValidator('el VIN'),
            hint: 'Ej: 1HGBH41JXMN109186'),
        _buildField('Color *', _colorController,
            validator: _requiredValidator('el color'), hint: 'Ej: Blanco'),
        _buildField('Tipo *', _tipoController,
            validator: _requiredValidator('el tipo'), hint: 'Ej: Camión, Bus'),
        _buildField('Tarjeta de Circulación *', _tarjetaCirculacionController,
            validator: _requiredValidator('la tarjeta'), hint: 'Número de tarjeta'),
        const SizedBox(height: 8),
        _buildSectionTitle('Dimensiones y Capacidad', Icons.straighten_outlined),
        const SizedBox(height: 12),
        _buildNumberField('N° Asientos *', _asientosController, isInt: true),
        _buildNumberField('N° Ejes *', _ejesController, isInt: true),
        _buildNumberField('Peso Neto (kg) *', _pesoNetoController),
        _buildNumberField('Peso Bruto (kg) *', _pesoBrutoController),
        _buildNumberField('Carga Útil (kg) *', _cargaUtilController),
        _buildNumberField('Largo (m) *', _largoController),
        _buildNumberField('Ancho (m) *', _anchoController),
        _buildNumberField('Alto (m) *', _altoController),
        _buildNumberField('Kilometraje *', _kilometrajeController, isInt: true),
        const SizedBox(height: 8),
        _buildSectionTitle('Fechas y Estado', Icons.calendar_month_outlined),
        const SizedBox(height: 12),
        _buildDateField('Fecha de Fabricación *', _fechaFabricacion,
            () => _selectDate(context, onDateSelected: (d) => setState(() => _fechaFabricacion = d))),
        _buildDateField('Fecha Habilitación TUC *', _fechaHabilitacionTuc,
            () => _selectDate(context, onDateSelected: (d) => setState(() => _fechaHabilitacionTuc = d))),
        _buildDateField('Fecha Vencimiento TUC *', _fechaVencimientoTuc,
            () => _selectDate(context, onDateSelected: (d) => setState(() => _fechaVencimientoTuc = d))),
        _buildEstadoDropdown(),
        const SizedBox(height: 24),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        // SECCIÓN 1 - Identificación (3 columnas)
        _buildSectionTitle('Datos de Identificación', Icons.badge_outlined),
        const SizedBox(height: 12),
        _buildThreeColumns(
          _buildField('Placa *', _placaController,
              validator: _requiredValidator('la placa'),
              inputFormatters: [UpperCaseTextFormatter()],
              hint: 'Ej: ABC-123'),
          _buildField('Marca *', _marcaController,
              validator: _requiredValidator('la marca'), hint: 'Ej: Toyota'),
          _buildField('Modelo *', _modeloController,
              validator: _requiredValidator('el modelo'), hint: 'Ej: Hilux 2022'),
        ),
        _buildThreeColumns(
          _buildField('Número VIN *', _vinController,
              validator: _requiredValidator('el VIN'),
              hint: 'Ej: 1HGBH41JXMN109186'),
          _buildField('Color *', _colorController,
              validator: _requiredValidator('el color'), hint: 'Ej: Blanco'),
          _buildField('Tipo *', _tipoController,
              validator: _requiredValidator('el tipo'), hint: 'Ej: Camión'),
        ),
        _buildField('Tarjeta Única de Circulación *', _tarjetaCirculacionController,
            validator: _requiredValidator('la tarjeta'), hint: 'Número de tarjeta de circulación'),

        const SizedBox(height: 20),

        // SECCIÓN 2 - Dimensiones (3 columnas)
        _buildSectionTitle('Dimensiones y Capacidad', Icons.straighten_outlined),
        const SizedBox(height: 12),
        _buildThreeColumns(
          _buildNumberField('N° Asientos *', _asientosController, isInt: true),
          _buildNumberField('N° Ejes *', _ejesController, isInt: true),
          _buildNumberField('Kilometraje *', _kilometrajeController, isInt: true),
        ),
        _buildThreeColumns(
          _buildNumberField('Peso Neto (kg) *', _pesoNetoController),
          _buildNumberField('Peso Bruto (kg) *', _pesoBrutoController),
          _buildNumberField('Carga Útil (kg) *', _cargaUtilController),
        ),
        _buildThreeColumns(
          _buildNumberField('Largo (m) *', _largoController),
          _buildNumberField('Ancho (m) *', _anchoController),
          _buildNumberField('Alto (m) *', _altoController),
        ),

        const SizedBox(height: 20),

        // SECCIÓN 3 - Fechas y estado (3 columnas)
        _buildSectionTitle('Fechas y Estado', Icons.calendar_month_outlined),
        const SizedBox(height: 12),
        _buildThreeColumns(
          _buildDateField('Fecha Fabricación *', _fechaFabricacion,
              () => _selectDate(context, onDateSelected: (d) => setState(() => _fechaFabricacion = d))),
          _buildDateField('Habilitación TUC *', _fechaHabilitacionTuc,
              () => _selectDate(context, onDateSelected: (d) => setState(() => _fechaHabilitacionTuc = d))),
          _buildDateField('Vencimiento TUC *', _fechaVencimientoTuc,
              () => _selectDate(context, onDateSelected: (d) => setState(() => _fechaVencimientoTuc = d))),
        ),
        _buildEstadoDropdown(compact: true),

        const SizedBox(height: 28),
        _buildActionButtons(),
      ],
    );
  }

  // ── HELPERS DE LAYOUT ─────────────────────────────────────────────────────

  Widget _buildThreeColumns(Widget col1, Widget col2, Widget col3) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: col1),
        const SizedBox(width: 16),
        Expanded(child: col2),
        const SizedBox(width: 16),
        Expanded(child: col3),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _primaryLight),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _primaryLight,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: _border, thickness: 1)),
      ],
    );
  }

  // ── CAMPOS ────────────────────────────────────────────────────────────────

  Widget _buildField(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _labelStyle),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: validator,
            inputFormatters: inputFormatters,
            style: const TextStyle(fontSize: 14),
            decoration: _inputDecoration(hint),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller, {bool isInt = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _labelStyle),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: !isInt),
            inputFormatters: [
              FilteringTextInputFormatter.allow(isInt ? RegExp(r'[0-9]') : RegExp(r'[0-9.]')),
            ],
            style: const TextStyle(fontSize: 14),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requerido';
              if (isInt && int.tryParse(value) == null) return 'Número entero';
              if (!isInt && double.tryParse(value) == null) return 'Número válido';
              return null;
            },
            decoration: _inputDecoration(null),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    final bool hasDate = date != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _labelStyle),
          const SizedBox(height: 6),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: hasDate ? _primary : _border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: hasDate ? _primary : Colors.grey[400],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _formatDate(date),
                      style: TextStyle(
                        fontSize: 14,
                        color: hasDate ? Colors.black87 : Colors.grey[400],
                      ),
                    ),
                  ),
                  if (hasDate)
                    Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoDropdown({bool compact = false}) {
    if (compact) {
      // En desktop, solo ocupa 1/3 del ancho
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: (MediaQuery.of(context).size.width - 160 - 32) / 3,
            child: _estadoDropdownContent(),
          ),
        ],
      );
    }
    return _estadoDropdownContent();
  }

  Widget _estadoDropdownContent() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estado', style: _labelStyle),
          const SizedBox(height: 6),
          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedEstado,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: _primary, size: 20),
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                items: ['Activo', 'Inactivo'].map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: value == 'Activo' ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(value),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedEstado = v!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTONES ───────────────────────────────────────────────────────────────

  Widget _buildActionButtons() {
    return BlocBuilder<VehicleBloc, VehicleState>(
      builder: (context, state) {
        final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);

        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('CANCELAR', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                  disabledBackgroundColor: _primary.withOpacity(0.5),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('GUARDAR VEHÍCULO', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── ESTILOS ───────────────────────────────────────────────────────────────

  static const TextStyle _labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF4A5568),
    letterSpacing: 0.2,
  );

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      filled: true,
      fillColor: _surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      errorStyle: const TextStyle(fontSize: 11),
      isDense: true,
    );
  }

  String? Function(String?) _requiredValidator(String fieldName) {
    return (value) {
      if (value == null || value.trim().isEmpty) return 'Ingrese $fieldName';
      return null;
    };
  }
}

// Formateador para convertir texto a mayúsculas automáticamente
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}