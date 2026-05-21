// lib/features/vehicle/presentation/widgets/edit_vehicle_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_update_dto.dart';
import 'package:app_jht_front/features/vehicle/domain/entities/vehicle_entity.dart';
import 'package:app_jht_front/features/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:app_jht_front/features/vehicle/presentation/widgets/vehicle_form_data.dart';
import 'package:intl/intl.dart';

class EditVehicleModal extends StatefulWidget {
  final VehicleEntity vehicle;
  final List<String> existingPlates;

  const EditVehicleModal({
    super.key,
    required this.vehicle,
    this.existingPlates = const [],
  });

  @override
  State<EditVehicleModal> createState() => _EditVehicleModalState();
}

class _EditVehicleModalState extends State<EditVehicleModal> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _placaController;
  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _numeroVinController;
  late TextEditingController _colorController;
  late TextEditingController _numAsientosController;
  late TextEditingController _numEjesController;
  late TextEditingController _pesoNetoController;
  late TextEditingController _pesoBrutoController;
  late TextEditingController _cargaUtilController;
  late TextEditingController _largoController;
  late TextEditingController _anchoController;
  late TextEditingController _altoController;
  late TextEditingController _tipoController;
  late TextEditingController _kilometrajeController;
  late TextEditingController _tarjetaCirculacionController;

  DateTime? _fechaFabricacion;
  DateTime? _fechaHabilitacionTUC;
  DateTime? _fechaVencimientoTUC;
  String _selectedEstado = 'ACTIVO';

  // Marca seleccionada para filtrar modelos
  String? _marcaSeleccionada;
  // Validación placa duplicada
  bool _placaDuplicada = false;

  static const _primaryColor = Color(0xFF303366);

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;

    _placaController = TextEditingController(text: v.placa);
    _marcaController = TextEditingController(text: v.marca);
    _modeloController = TextEditingController(text: v.modelo);
    _numeroVinController = TextEditingController(text: v.numeroVin);
    _colorController = TextEditingController(text: v.color);
    _numAsientosController = TextEditingController(text: v.numAsientos.toString());
    _numEjesController = TextEditingController(text: v.numEjes.toString());
    _pesoNetoController = TextEditingController(text: v.pesoNeto.toString());
    _pesoBrutoController = TextEditingController(text: v.pesoBruto.toString());
    _cargaUtilController = TextEditingController(text: v.cargaUtil.toString());
    _largoController = TextEditingController(text: v.largo.toString());
    _anchoController = TextEditingController(text: v.ancho.toString());
    _altoController = TextEditingController(text: v.alto.toString());
    _tipoController = TextEditingController(text: v.tipo);
    _kilometrajeController = TextEditingController(text: v.kilometraje.toString());
    _tarjetaCirculacionController = TextEditingController(text: v.tarjetaUnicaCirculacion);

    _fechaFabricacion = v.fechaFabricacion;
    _fechaHabilitacionTUC = v.fechaHabilitacionTUC;
    _fechaVencimientoTUC = v.fechaVencimientoTUC;
    _selectedEstado = v.estado == 'ACTIVO' || v.estado == 'Activo' ? 'Activo' : 'Inactivo';

    // Inicializar marca seleccionada para que Modelo cargue la lista correcta
    _marcaSeleccionada = v.marca;

    // Listener para validar placa duplicada
    _placaController.addListener(_checkPlacaDuplicada);
  }

  void _checkPlacaDuplicada() {
    final placa = _placaController.text.toUpperCase().trim();
    final placaOriginal = widget.vehicle.placa.toUpperCase().trim();
    // Es duplicada si: no está vacía, es diferente a la placa original, y existe en la BD
    final isDup = placa.isNotEmpty &&
        placa != placaOriginal &&
        widget.existingPlates.any((p) => p.toUpperCase().trim() == placa);
    if (isDup != _placaDuplicada) setState(() => _placaDuplicada = isDup);
  }
  @override
  void dispose() {
    _placaController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _numeroVinController.dispose();
    _colorController.dispose();
    _numAsientosController.dispose();
    _numEjesController.dispose();
    _pesoNetoController.dispose();
    _pesoBrutoController.dispose();
    _cargaUtilController.dispose();
    _largoController.dispose();
    _anchoController.dispose();
    _altoController.dispose();
    _tipoController.dispose();
    _kilometrajeController.dispose();
    _tarjetaCirculacionController.dispose();
    super.dispose();
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  String _fmt(DateTime? d) =>
      d == null ? 'Seleccionar fecha' : DateFormat('yyyy-MM-dd').format(d);

  Future<void> _pickDate(
    BuildContext ctx, {
    required DateTime? current,
    required void Function(DateTime) onPicked,
  }) async {
    final picked = await showDatePicker(
      context: ctx,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2035),
      locale: const Locale('es', 'ES'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  void _showCancelConfirm() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          '¿Cancelar edición?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _primaryColor,
          ),
        ),
        content: const Text(
          '¿Está seguro de que desea cancelar? Los cambios no se guardarán.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: _dialogBtn(
                  text: 'NO',
                  bg: Colors.grey[300]!,
                  fg: Colors.grey[700]!,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dialogBtn(
                  text: 'SÍ, CANCELAR',
                  bg: _primaryColor,
                  fg: Colors.white,
                  onTap: () {
                    Navigator.of(context).pop(); // cierra diálogo
                    Navigator.of(context).pop(); // cierra modal
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_placaDuplicada) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('La placa ya está registrada en el sistema.',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Confirmar actualización',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _primaryColor,
          ),
        ),
        content: const Text(
          '¿Está seguro de que desea guardar los cambios del vehículo?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: _dialogBtn(
                  text: 'CANCELAR',
                  bg: Colors.grey[300]!,
                  fg: Colors.grey[700]!,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dialogBtn(
                  text: 'CONFIRMAR',
                  bg: _primaryColor,
                  fg: Colors.white,
                  onTap: () {
                    Navigator.of(context).pop(); // cierra diálogo confirm
                    _dispatchUpdate();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _dispatchUpdate() {
    final dto = VehicleUpdateDto(
      vehiculoId: widget.vehicle.vehiculoId!,
      placa: _placaController.text.trim(),
      marca: _marcaController.text.trim(),
      modelo: _modeloController.text.trim(),
      numeroVin: _numeroVinController.text.trim(),
      color: _colorController.text.trim(),
      numAsientos: int.parse(_numAsientosController.text.trim()),
      numEjes: int.parse(_numEjesController.text.trim()),
      pesoNeto: double.parse(_pesoNetoController.text.trim()),
      pesoBruto: double.parse(_pesoBrutoController.text.trim()),
      cargaUtil: double.parse(_cargaUtilController.text.trim()),
      fechaFabricacion: _fmt(_fechaFabricacion),
      largo: double.parse(_largoController.text.trim()),
      ancho: double.parse(_anchoController.text.trim()),
      alto: double.parse(_altoController.text.trim()),
      tipo: _tipoController.text.trim(),
      kilometraje: int.parse(_kilometrajeController.text.trim()),
      tarjetaUnicaCirculacion: _tarjetaCirculacionController.text.trim(),
      fechaHabilitacionTUC: _fmt(_fechaHabilitacionTUC),
      fechaVencimientoTUC: _fmt(_fechaVencimientoTUC),
      fechaRegistro: widget.vehicle.fechaRegistro.toIso8601String(),
      fechaBaja: widget.vehicle.fechaBaja?.toIso8601String(),
      estado: _selectedEstado,
    );

    print('🔵 Dispatching actualizarVehiculo — id: ${dto.vehiculoId}');
    context.read<VehicleBloc>().add(VehicleEvent.actualizarVehiculo(dto: dto));
    
  }

  // ── build ─────────────────────────────────────────────────────────────────

@override
Widget build(BuildContext context) {
  final isMobile = MediaQuery.of(context).size.width < 768;

  return BlocListener<VehicleBloc, VehicleState>(
    listener: (context, state) {
      state.maybeWhen(
        actualizacionExitosa: (response) {
          Navigator.of(context).pop(); // cierra modal DESPUÉS del éxito
        },
        error: (message) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Error al actualizar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              content: Text(message, style: const TextStyle(fontSize: 14)),
              actions: [
                Center(
                  child: _dialogBtn(
                    text: 'ENTENDIDO',
                    bg: Colors.red,
                    fg: Colors.white,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          );
        },
        orElse: () {},
      );
    },
    child: PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showCancelConfirm();
      },
      child: Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.all(isMobile ? 16 : 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 680,
            maxHeight: MediaQuery.of(context).size.height * 0.92,
          ),
          child: Column(
            children: [
              _buildHeader(),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Form(
                    key: _formKey,
                    child: isMobile
                        ? _buildSingleColumn()
                        : _buildTwoColumns(),
                  ),
                ),
              ),
              const Divider(height: 1),
              _buildFooter(),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      child: Row(
        children: [
          const Icon(Icons.directions_car, color: _primaryColor, size: 24),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'EDITAR VEHÍCULO',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _primaryColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 22),
            onPressed: _showCancelConfirm,
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: BlocBuilder<VehicleBloc, VehicleState>(
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );
          return Row(
            children: [
              Expanded(
                child: _actionBtn(
                  text: 'CANCELAR',
                  bg: Colors.grey[300]!,
                  fg: Colors.grey[700]!,
                  onTap: isLoading ? null : _showCancelConfirm,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isLoading
                    ? Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                      )
                    : _actionBtn(
                        text: 'GUARDAR',
                        bg: _primaryColor,
                        fg: Colors.white,
                        onTap: _placaDuplicada ? null : _submitForm,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── layouts ───────────────────────────────────────────────────────────────

  Widget _buildSingleColumn() {
    return Column(children: _allFields());
  }

  Widget _buildTwoColumns() {
    final fields = _allFields();
    final left = <Widget>[];
    final right = <Widget>[];
    for (int i = 0; i < fields.length; i++) {
      if (i.isEven) {
        left.add(fields[i]);
      } else {
        right.add(fields[i]);
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Column(children: left)),
        const SizedBox(width: 16),
        Expanded(child: Column(children: right)),
      ],
    );
  }

  List<Widget> _allFields() => [
        _buildPlacaField(),
        _buildMarcaAutocomplete(),
        _buildModeloAutocomplete(),
        _textField('Número VIN', _numeroVinController, required: true),
        _textField('Color', _colorController, required: true),
        _textField('Tipo', _tipoController, required: true),
        _textField('Tarjeta Circulación', _tarjetaCirculacionController, required: true),
        _numField('N° Asientos', _numAsientosController, isInt: true),
        _numField('N° Ejes', _numEjesController, isInt: true),
        _numField('Peso Neto (kg)', _pesoNetoController),
        _numField('Peso Bruto (kg)', _pesoBrutoController),
        _numField('Carga Útil (kg)', _cargaUtilController),
        _numField('Largo (m)', _largoController),
        _numField('Ancho (m)', _anchoController),
        _numField('Alto (m)', _altoController),
        _numField('Kilometraje', _kilometrajeController, isInt: true),
        _dateField(
          'Fecha Fabricación',
          _fechaFabricacion,
          onTap: () => _pickDate(
            context,
            current: _fechaFabricacion,
            onPicked: (d) => setState(() => _fechaFabricacion = d),
          ),
        ),
        _dateField(
          'Fecha Habilitación TUC',
          _fechaHabilitacionTUC,
          onTap: () => _pickDate(
            context,
            current: _fechaHabilitacionTUC,
            onPicked: (d) => setState(() => _fechaHabilitacionTUC = d),
          ),
        ),
        _dateField(
          'Fecha Vencimiento TUC',
          _fechaVencimientoTUC,
          onTap: () => _pickDate(
            context,
            current: _fechaVencimientoTUC,
            onPicked: (d) => setState(() => _fechaVencimientoTUC = d),
          ),
        ),
        _dropdownEstado(),
      ];

  // ── field builders ────────────────────────────────────────────────────────

  Widget _textField(
    String label,
    TextEditingController ctrl, {
    bool required = false,
  }) {
    return _fieldWrapper(
      label,
      TextFormField(
        controller: ctrl,
        decoration: _inputDeco(label),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null
            : null,
      ),
    );
  }

  Widget _numField(
    String label,
    TextEditingController ctrl, {
    bool isInt = false,
  }) {
    return _fieldWrapper(
      label,
      TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: _inputDeco(label),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Requerido';
          final parsed = isInt ? int.tryParse(v.trim()) : double.tryParse(v.trim());
          if (parsed == null) return 'Número inválido';
          return null;
        },
      ),
    );
  }

  Widget _dateField(
    String label,
    DateTime? value, {
    required VoidCallback onTap,
  }) {
    return _fieldWrapper(
      label,
      InkWell(
        onTap: onTap,
        child: IgnorePointer(
          child: TextFormField(
            controller: TextEditingController(text: _fmt(value)),
            decoration: _inputDeco(label).copyWith(
              suffixIcon: const Icon(Icons.calendar_today,
                  size: 18, color: _primaryColor),
            ),
            validator: (_) =>
                value == null ? 'Seleccione una fecha' : null,
          ),
        ),
      ),
    );
  }

  Widget _dropdownEstado() {
    return _fieldWrapper(
      'Estado',
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedEstado,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: _primaryColor),
           items: ['Activo', 'Inactivo'].map((e) {
              return DropdownMenuItem(value: e, child: Text(e));
            }).toList(),
            onChanged: (v) => setState(() => _selectedEstado = v!),
          ),
        ),
      ),
    );
  }

  // ── micro helpers ─────────────────────────────────────────────────────────

  /// Campo Placa con validación de duplicado
  Widget _buildPlacaField() {
    return _fieldWrapper(
      'Placa *',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _placaController,
            decoration: _inputDeco('Placa').copyWith(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _placaDuplicada ? Colors.red : Colors.grey[400]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _placaDuplicada ? Colors.red : Colors.grey[400]!,
                  width: _placaDuplicada ? 1.5 : 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _placaDuplicada ? Colors.red : _primaryColor,
                  width: 1.5,
                ),
              ),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
          ),
          if (_placaDuplicada)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEC),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFF5C6CB)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFC62828), size: 16),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '⚠ Esta placa ya está registrada en el sistema',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFC62828),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Campo Marca con Autocomplete
  Widget _buildMarcaAutocomplete() {
    return _fieldWrapper(
      'Marca *',
      Autocomplete<String>(
        initialValue: TextEditingValue(text: _marcaController.text),
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) return kMarcasVehiculo;
          final query = textEditingValue.text.toLowerCase();
          return kMarcasVehiculo.where((m) => m.toLowerCase().contains(query));
        },
        onSelected: (String selection) {
          _marcaController.text = selection;
          setState(() {
            _marcaSeleccionada = selection;
            _modeloController.clear();
          });
        },
        fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
          textController.addListener(() {
            if (_marcaController.text != textController.text) {
              _marcaController.text = textController.text;
              // Actualizar marca seleccionada al escribir
              final typed = textController.text.trim();
              if (kMarcasVehiculo.contains(typed) && _marcaSeleccionada != typed) {
                setState(() => _marcaSeleccionada = typed);
              }
            }
          });
          return TextFormField(
            controller: textController,
            focusNode: focusNode,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            style: const TextStyle(fontSize: 14),
            decoration: _inputDeco('Buscar marca...').copyWith(
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 10, right: 6),
                child: Icon(Icons.search, size: 18, color: Color(0xFF9CA3AF)),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 34, minHeight: 0),
              suffixIcon: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.arrow_drop_down, size: 22, color: Color(0xFF6B7280)),
              ),
              suffixIconConstraints: const BoxConstraints(minWidth: 30, minHeight: 0),
            ),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 6,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 220, maxWidth: 300),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(option),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(children: [
                          const Icon(Icons.directions_car_outlined, size: 16, color: Color(0xFF6B7280)),
                          const SizedBox(width: 10),
                          Text(option, style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937))),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Campo Modelo dependiente de la Marca seleccionada
  Widget _buildModeloAutocomplete() {
    final modelos = kModelosPorMarca[_marcaSeleccionada] ?? [];

    // Si no hay modelos para la marca, mostrar TextFormField normal
    if (modelos.isEmpty) {
      return _textField('Modelo', _modeloController, required: true);
    }

    return _fieldWrapper(
      'Modelo *',
      Autocomplete<String>(
        initialValue: TextEditingValue(text: _modeloController.text),
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) return modelos;
          final query = textEditingValue.text.toLowerCase();
          return modelos.where((m) => m.toLowerCase().contains(query));
        },
        onSelected: (String selection) {
          _modeloController.text = selection;
        },
        fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
          textController.addListener(() {
            if (_modeloController.text != textController.text) {
              _modeloController.text = textController.text;
            }
          });
          return TextFormField(
            controller: textController,
            focusNode: focusNode,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            style: const TextStyle(fontSize: 14),
            decoration: _inputDeco('Buscar modelo...').copyWith(
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 10, right: 6),
                child: Icon(Icons.search, size: 18, color: Color(0xFF9CA3AF)),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 34, minHeight: 0),
              suffixIcon: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.arrow_drop_down, size: 22, color: Color(0xFF6B7280)),
              ),
              suffixIconConstraints: const BoxConstraints(minWidth: 30, minHeight: 0),
            ),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 6,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 220, maxWidth: 300),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(option),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(children: [
                          const Icon(Icons.model_training, size: 16, color: Color(0xFF6B7280)),
                          const SizedBox(width: 10),
                          Text(option, style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937))),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _fieldWrapper(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );

  Widget _actionBtn({
    required String text,
    required Color bg,
    required Color fg,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: onTap == null ? bg.withOpacity(0.5) : bg,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: fg,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _dialogBtn({
    required String text,
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: fg,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}