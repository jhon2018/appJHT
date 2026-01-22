// lib/features/accessory/presentation/widgets/add_accessory_modal.dart
// DESCRIPTION: Modal para agregar un nuevo accesorio con campos dinámicos y validación.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/accessory/presentation/bloc/accessory_bloc.dart';
import 'package:app_jht_front/features/accessory/data/models/segmento_model.dart';
import 'package:app_jht_front/features/accessory/data/models/tipo_accesorio_model.dart';
import 'package:app_jht_front/features/accessory/data/models/vehiculo_model.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_registro_dto.dart';
import 'add_accessory_type_modal.dart';

class AddAccessoryModal extends StatefulWidget {
  final Function()? onAccessoryAdded;

  const AddAccessoryModal({super.key, this.onAccessoryAdded});

  @override
  State<AddAccessoryModal> createState() => _AddAccessoryModalState();
}

class _AddAccessoryModalState extends State<AddAccessoryModal> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _nombreAccesorioController = TextEditingController(); // Usado implícitamente por el dropdown
  final _descripcionController = TextEditingController();
  final _marcaController = TextEditingController();
  final _codigoFabricanteController = TextEditingController();
  final _kilometrajeInstalacionController = TextEditingController();
  final _kilometrajeRetiroController = TextEditingController();
  final _observacionesController = TextEditingController();

  DateTime? _fechaInstalacion;
  DateTime? _fechaRetiro;
  String? _estadoValue;

  // IDs seleccionados
  int? _selectedSegmentoId;
  int? _selectedTipoAccesorioId;
  int? _selectedVehiculoId;

  // Objetos seleccionados (referencia)
  SegmentoModel? _selectedSegmento;
  TipoAccesorioModel? _selectedTipoAccesorio;
  VehiculoModel? _selectedVehiculo;

  // Cache
  List<SegmentoModel> _segmentosCache = [];
  final List<String> _estadoOptions = ['Activo', 'Inactivo'];
  AccesorioRegistroDto? _ultimoDtoEnviado;

  @override
  void initState() {
    super.initState();
    print('🎯 INICIANDO MODAL - AddAccessoryModal');
    _resetForm();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatosIniciales();
    });
  }

  void _resetForm() {
    _selectedSegmentoId = null;
    _selectedTipoAccesorioId = null;
    _selectedVehiculoId = null;
    _selectedSegmento = null;
    _selectedTipoAccesorio = null;
    _selectedVehiculo = null;
    _estadoValue = null;
    _descripcionController.clear();
    _marcaController.clear();
    _codigoFabricanteController.clear();
    _kilometrajeInstalacionController.clear();
    _kilometrajeRetiroController.clear();
    _observacionesController.clear();
    _fechaInstalacion = null;
    _fechaRetiro = null;
  }

  void _cargarDatosIniciales() {
    print('🚀 Cargando datos iniciales...');
    context.read<AccessoryBloc>().add(LoadSegmentosEvent());
    context.read<AccessoryBloc>().add(LoadVehiculosEvent());
  }

  @override
  void dispose() {
    _nombreAccesorioController.dispose();
    _descripcionController.dispose();
    _marcaController.dispose();
    _codigoFabricanteController.dispose();
    _kilometrajeInstalacionController.dispose();
    _kilometrajeRetiroController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE FECHAS ---

  Future<void> _selectDateConHora(BuildContext context, bool isInstalacion) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (pickedDate != null) {
      if (!mounted) return;
      
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 10, minute: 30),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );

      final DateTime fechaCompleta = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime?.hour ?? 10,
        pickedTime?.minute ?? 30,
      );

      setState(() {
        if (isInstalacion) {
          _fechaInstalacion = fechaCompleta;
          print('📅 Fecha instalación seleccionada: $_fechaInstalacion');
        } else {
          _fechaRetiro = fechaCompleta;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Seleccionar fecha';
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  // --- LÓGICA DE REGISTRO ---

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _showConfirmationDialog();
    }
  }

  void _registrarAccessory() {
    // 1. Validaciones manuales extra
    if (_fechaInstalacion == null) {
      _showErrorSnackbar('Seleccione fecha de instalación');
      return;
    }
    if (_selectedVehiculoId == null || _selectedVehiculoId == 0) {
      _showErrorSnackbar('Seleccione un vehículo válido');
      return;
    }
    if (_selectedTipoAccesorioId == null || _selectedTipoAccesorioId == 0) {
      _showErrorSnackbar('Seleccione un tipo de accesorio válido');
      return;
    }

    // 2. Crear DTO
    final dto = AccesorioRegistroDto(
      marca: _marcaController.text.trim(),
      codigoFabricante: _codigoFabricanteController.text.trim(),
      fechaInstalacion: _fechaInstalacion!,
      kilometrajeInstalacion: int.tryParse(_kilometrajeInstalacionController.text) ?? 0,
      estado: _estadoValue!,
      observacion: _observacionesController.text.trim(),
      vehiculoId: _selectedVehiculoId!,
      tipoAccesorioId: _selectedTipoAccesorioId!,
    );

    _ultimoDtoEnviado = dto;

    // 3. Disparar Evento BLoC
    context.read<AccessoryBloc>().add(RegistrarAccesorioEvent(dto: dto));
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Confirmar Registro',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF303366))),
        content: const Text('¿Está seguro de que desea agregar este accesorio?', textAlign: TextAlign.center),
        actions: [
          Row(
            children: [
              Expanded(child: _buildDialogButton(text: 'CANCELAR', backgroundColor: Colors.grey[300]!, textColor: Colors.grey[700]!, onPressed: () => Navigator.pop(context))),
              const SizedBox(width: 12),
              Expanded(child: _buildDialogButton(text: 'CONFIRMAR', backgroundColor: const Color(0xFF303366), textColor: Colors.white, onPressed: () {
                Navigator.pop(context);
                _registrarAccessory();
              })),
            ],
          ),
        ],
      ),
    );
  }

  void _agregarTipoAccesorio() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AddAccessoryTypeModal(),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  // --- UI PRINCIPAL ---

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return BlocListener<AccessoryBloc, AccessoryState>(
      listener: (context, state) {
        // Cachear Segmentos
        if (state is SegmentosLoaded) {
          if (mounted) setState(() => _segmentosCache = state.segmentos);
        }
        // Cachear Vehículos (fuerza rebuild)
        if (state is VehiculosLoaded && mounted) {
          setState(() {}); 
        }
        // Registro Exitoso
        if (state is AccesorioRegistrado) {
          Navigator.of(context).pop(); // Cerrar Modal
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Accesorio registrado exitosamente'), backgroundColor: Color(0xFF303366)),
          );
          if (widget.onAccessoryAdded != null) widget.onAccessoryAdded!();
          _ultimoDtoEnviado = null;
        }
        // Error en Registro
        if (state is RegistroError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Error: ${state.message}'), backgroundColor: Colors.red),
          );
          _ultimoDtoEnviado = null;
        }
      },
      child: Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.all(isMobile ? 10 : 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isMobile ? MediaQuery.of(context).size.width - 20 : 600,
            maxHeight: MediaQuery.of(context).size.height * 0.90,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('AGREGAR ACCESORIO', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF303366))),
                const SizedBox(height: 8),
                const Divider(color: Colors.grey),
                const SizedBox(height: 20),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // --- Segmento y Tipo (Fila 1 en Desktop) ---
                      if (!isMobile)
                        Row(children: [
                          Expanded(child: _buildSegmentoDropdown()),
                          const SizedBox(width: 16),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTipoAccesorioDropdown(),
                              _buildAddTypeButton(),
                            ],
                          )),
                        ])
                      else
                        Column(children: [
                          _buildSegmentoDropdown(),
                          _buildTipoAccesorioDropdown(),
                          _buildAddTypeButton(),
                        ]),
                      
                      const SizedBox(height: 16),

                      // --- Vehículo ---
                      _buildVehiculoDropdown(),

                      // --- Descripción (Auto-filled) ---
                      _buildFormField('Descripción del Accesorio', _descripcionController, (_) => null, maxLines: 2),

                      // --- Marca y Código (Fila 2 en Desktop) ---
                      if (!isMobile)
                        Row(children: [
                          Expanded(child: _buildFormField('Marca de Accesorio', _marcaController, (v) => v!.isEmpty ? 'Requerido' : null)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildFormField('Código de Fabricante', _codigoFabricanteController, (v) => v!.isEmpty ? 'Requerido' : null)),
                        ])
                      else
                        Column(children: [
                          _buildFormField('Marca de Accesorio', _marcaController, (v) => v!.isEmpty ? 'Requerido' : null),
                          _buildFormField('Código de Fabricante', _codigoFabricanteController, (v) => v!.isEmpty ? 'Requerido' : null),
                        ]),

                      // --- Fecha Instalación (Fila 3) ---
                      if (!isMobile)
                         Row(children: [
                           Expanded(child: _buildDateField('Fecha de Instalación', _fechaInstalacion, () => _selectDateConHora(context, true))),
                         ])
                      else
                         _buildDateField('Fecha de Instalación', _fechaInstalacion, () => _selectDateConHora(context, true)),

                      // --- Kilometraje (Fila 4) ---
                      if (!isMobile)
                        Row(children: [
                          Expanded(child: _buildFormField('Kilometraje de Instalación', _kilometrajeInstalacionController, (v) => v!.isEmpty ? 'Requerido' : null, keyboardType: TextInputType.number)),
                        ])
                      else
                        _buildFormField('Kilometraje de Instalación', _kilometrajeInstalacionController, (v) => v!.isEmpty ? 'Requerido' : null, keyboardType: TextInputType.number),

                      // --- Estado y Observaciones ---
                      _buildEstadoDropdown(),
                      _buildFormField('Observaciones', _observacionesController, (_) => null, maxLines: 3),

                      const SizedBox(height: 32),

                      // --- Botones de Acción ---
                      Row(
                        children: [
                          Expanded(child: _buildButton(text: 'CANCELAR', backgroundColor: Colors.grey[300]!, textColor: Colors.grey[700]!, onPressed: () => Navigator.pop(context))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildButton(text: 'GUARDAR', backgroundColor: const Color(0xFF303366), textColor: Colors.white, onPressed: _submitForm)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildSegmentoDropdown() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Segmento', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF303366))),
      const SizedBox(height: 8),
      _segmentosCache.isEmpty 
        ? _buildLoadingDropdown('Cargando segmentos...')
        : _buildSegmentosDropdown(_segmentosCache),
      const SizedBox(height: 16),
    ]);
  }

  Widget _buildSegmentosDropdown(List<SegmentoModel> segmentos) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedSegmentoId,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          hint: const Text('Seleccione segmento'),
          items: segmentos.map((s) => DropdownMenuItem(value: s.id, child: Text(s.nombre))).toList(),
          onChanged: (newId) {
            setState(() {
              _selectedSegmentoId = newId;
              _selectedTipoAccesorioId = null;
              _selectedTipoAccesorio = null;
              _descripcionController.clear();
            });
            if (newId != null) {
              context.read<AccessoryBloc>().add(LoadTiposAccesorioEvent(segmentoId: newId));
            }
          },
        ),
      ),
    );
  }

  Widget _buildTipoAccesorioDropdown() {
    return BlocBuilder<AccessoryBloc, AccessoryState>(
      buildWhen: (prev, curr) => curr is TiposAccesorioLoaded || curr is AccessoryLoading,
      builder: (context, state) {
        List<TipoAccesorioModel> tipos = [];
        bool isLoading = (state is AccessoryLoading);
        if (state is TiposAccesorioLoaded) tipos = state.tiposAccesorio;

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Nombre de Accesorio', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF303366))),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedTipoAccesorioId,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                hint: Text(_selectedSegmentoId == null ? 'Seleccione segmento primero' : (isLoading ? 'Cargando...' : 'Seleccione tipo')),
                items: tipos.map((t) => DropdownMenuItem(value: t.id, child: Text(t.nombre))).toList(),
                onChanged: (_selectedSegmentoId == null || isLoading) ? null : (newId) {
                  final selected = tipos.firstWhere((t) => t.id == newId);
                  setState(() {
                    _selectedTipoAccesorioId = newId;
                    _selectedTipoAccesorio = selected;
                    _descripcionController.text = selected.descripcion;
                  });
                },
              ),
            ),
          ),
        ]);
      },
    );
  }

  Widget _buildVehiculoDropdown() {
    return BlocBuilder<AccessoryBloc, AccessoryState>(
      buildWhen: (prev, curr) => curr is VehiculosLoaded || curr is AccessoryLoading || curr is AccessoryError,
      builder: (context, state) {
        List<VehiculoModel> vehiculos = [];
        if (state is VehiculosLoaded) vehiculos = state.vehiculos;
        
        if (state is AccessoryLoading && vehiculos.isEmpty) return _buildLoadingDropdown('Cargando vehículos...');
        
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Vehículo', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF303366))),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedVehiculoId,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                hint: const Text('Seleccione vehículo'),
                items: vehiculos.map((v) => DropdownMenuItem(value: v.id, child: Text('${v.placa} (${v.kilometraje} km)'))).toList(),
                onChanged: (newId) {
                  setState(() => _selectedVehiculoId = newId);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
        ]);
      },
    );
  }

  Widget _buildEstadoDropdown() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Estado', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF303366))),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: _estadoValue,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: _estadoOptions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        onChanged: (val) => setState(() => _estadoValue = val),
        validator: (v) => v == null ? 'Requerido' : null,
      ),
      const SizedBox(height: 16),
    ]);
  }

  Widget _buildLoadingDropdown(String msg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
      child: Row(children: [Text(msg), const Spacer(), const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))]),
    );
  }

  Widget _buildAddTypeButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      child: OutlinedButton.icon(
        onPressed: _agregarTipoAccesorio,
        icon: const Icon(Icons.add, size: 16),
        label: const Text('AGREGAR TIPO ACCESORIO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF303366), side: const BorderSide(color: Color(0xFF303366))),
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, String? Function(String?) validator, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF303366))),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
      ),
      const SizedBox(height: 16),
    ]);
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF303366))),
      const SizedBox(height: 8),
      InkWell(
        onTap: onTap,
        child: IgnorePointer(
          child: TextFormField(
            controller: TextEditingController(text: _formatDate(date)),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF303366)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
    ]);
  }

  Widget _buildButton({required String text, required Color backgroundColor, required Color textColor, required VoidCallback onPressed}) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: backgroundColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        onPressed: onPressed,
        child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
    );
  }
  
  Widget _buildDialogButton({required String text, required Color backgroundColor, required Color textColor, required VoidCallback onPressed}) {
     return _buildButton(text: text, backgroundColor: backgroundColor, textColor: textColor, onPressed: onPressed);
  }
}