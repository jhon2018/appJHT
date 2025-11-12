// Ruta: lib/features/vehicle/presentation/widgets/add_vehicle_modal.dart
// Definición: Modal para agregar vehículos
// Objetivo: Proporcionar interfaz para registro de nuevos vehículos

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/vehicle/data/models/vehicle_registro_dto.dart';
import 'package:app_jht_front/features/vehicle/presentation/bloc/vehicle_bloc.dart';

class AddVehicleModal extends StatefulWidget {
  final Function(VehicleRegistroDto)? onVehicleAdded; // objetivo: callback al agregar vehículo tiene el dto del vehículo agregado

  const AddVehicleModal({
    super.key, 
    this.onVehicleAdded // objetivo: inicializar callback para notificar al agregar vehículo
  });

  @override
  State<AddVehicleModal> createState() => _AddVehicleModalState();
}

class _AddVehicleModalState extends State<AddVehicleModal> {
  final _formKey = GlobalKey<FormState>();
  final _placaController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _vinController = TextEditingController();
  final _colorController = TextEditingController();
  final _tipoController = TextEditingController();
  final _tarjetaCirculacionController = TextEditingController();
  
  // NUEVOS CONTROLADORES PARA CAMPOS NUMÉRICOS
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

  @override
  void dispose() {
    _placaController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _vinController.dispose();
    _colorController.dispose();
    _tipoController.dispose();
    _tarjetaCirculacionController.dispose();
    // NUEVOS CONTROLADORES
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
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // ✅ FONDO BLANCO
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Confirmar Registro',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF303366),
          ),
        ),
        content: const Text(
          '¿Está seguro de que desea agregar este vehículo?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: _buildDialogButton(
                  text: 'CANCELAR',
                  backgroundColor: Colors.grey[300]!,
                  textColor: Colors.grey[700]!,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDialogButton(
                  text: 'CONFIRMAR',
                  backgroundColor: const Color(0xFF303366),
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop();
                    _registrarVehiculo();
                  },
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
      vehVplaca: _placaController.text,
      vehVmarca: _marcaController.text,
      vehVmodelo: _modeloController.text,
      vehVnumeroVin: _vinController.text,
      vehVcolor: _colorController.text,
      // CAMPOS NUMÉRICOS ACTUALIZADOS
      vehInumAsientos: int.tryParse(_asientosController.text) ?? 4,
      vehInumEjes: int.tryParse(_ejesController.text) ?? 2,
      vehBpesoNeto: double.tryParse(_pesoNetoController.text) ?? 1500.0,
      vehBpesoBruto: double.tryParse(_pesoBrutoController.text) ?? 2000.0,
      vehBcargaUtil: double.tryParse(_cargaUtilController.text) ?? 500.0,
      vehBlargo: double.tryParse(_largoController.text) ?? 4.5,
      vehBancho: double.tryParse(_anchoController.text) ?? 1.8,
      vehBalto: double.tryParse(_altoController.text) ?? 1.6,
      vehIkilometraje: int.tryParse(_kilometrajeController.text) ?? 0,
      // FIN CAMPOS NUMÉRICOS
      vehDfechFabricacion: _fechaFabricacion?.toIso8601String().split('T')[0] ?? '2023-01-01',
      vehVtipo: _tipoController.text,
      vehVtarjetaUnicaCirculacion: _tarjetaCirculacionController.text,
      vehDfechHabilitacionTuc: _fechaHabilitacionTuc?.toIso8601String().split('T')[0] ?? '2023-01-01',
      vehDfechVencimientoTuc: _fechaVencimientoTuc?.toIso8601String().split('T')[0] ?? '2026-01-01',
      vehVestado: _selectedEstado,
    );

    context.read<VehicleBloc>().add(VehicleEvent.registrarVehiculo(dto: dto)); // Envío del evento al BLoC para registrar el vehículo
  }

  Future<void> _selectDate(BuildContext context, {required Function(DateTime) onDateSelected}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Seleccionar fecha';
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  
  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

  return BlocListener<VehicleBloc, VehicleState>(
    listener: (context, state) {
      state.whenOrNull(
        registroExitoso: (response) {
          Navigator.of(context).pop(); // Cierra el modal de Agregar Vehículo
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message), // ✅ Usar el mensaje de éxito de la respuesta Vehiculo registrado con exito
              backgroundColor: const Color(0xFF303366),
              duration: const Duration(seconds: 5),
            ),
          );
        },
        error: (message) {
          // ✅ SOLUCIÓN: Mostrar diálogo de error en lugar de SnackBar
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white, // ✅ FONDO BLANCO
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Error de Registro',
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
                style: const TextStyle(fontSize: 14),
              ),
              actions: [
                Center(
                  child: _buildDialogButton(
                    text: 'ENTENDIDO',
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    onPressed: () => Navigator.of(context).pop(),
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
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 600, // Aumentado para más campos
              maxHeight: MediaQuery.of(context).size.height * 0.95,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text(
                        'AGREGAR VEHÍCULO',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF303366),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 24),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // PRIMERA COLUMNA - DATOS BÁSICOS
                          _buildFormField('Placa', _placaController, (value) {
                            if (value == null || value.isEmpty) return 'Ingrese la placa';
                            return null;
                          }),
                          
                          _buildFormField('Marca', _marcaController, (value) {
                            if (value == null || value.isEmpty) return 'Ingrese la marca';
                            return null;
                          }),
                          
                          _buildFormField('Modelo', _modeloController, (value) {
                            if (value == null || value.isEmpty) return 'Ingrese el modelo';
                            return null;
                          }),
                          
                          _buildFormField('Número VIN', _vinController, (value) {
                            if (value == null || value.isEmpty) return 'Ingrese el VIN';
                            return null;
                          }),
                          
                          _buildFormField('Color', _colorController, (value) {
                            if (value == null || value.isEmpty) return 'Ingrese el color';
                            return null;
                          }),
                          
                          _buildFormField('Tipo', _tipoController, (value) {
                            if (value == null || value.isEmpty) return 'Ingrese el tipo';
                            return null;
                          }),
                          
                          _buildFormField('Tarjeta Circulación', _tarjetaCirculacionController, (value) {
                            if (value == null || value.isEmpty) return 'Ingrese la tarjeta';
                            return null;
                          }),

                          // SEGUNDA COLUMNA - CAMPOS NUMÉRICOS
                          _buildNumberField('Número de Asientos', _asientosController),
                          _buildNumberField('Número de Ejes', _ejesController),
                          _buildNumberField('Peso Neto (kg)', _pesoNetoController),
                          _buildNumberField('Peso Bruto (kg)', _pesoBrutoController),
                          _buildNumberField('Carga Útil (kg)', _cargaUtilController),
                          _buildNumberField('Largo (m)', _largoController),
                          _buildNumberField('Ancho (m)', _anchoController),
                          _buildNumberField('Alto (m)', _altoController),
                          _buildNumberField('Kilometraje', _kilometrajeController),

                          // TERCERA COLUMNA - FECHAS Y ESTADO
                          _buildDateField('Fecha Fabricación', _fechaFabricacion, 
                              () => _selectDate(context, onDateSelected: (date) {
                                setState(() => _fechaFabricacion = date);
                              })),
                          
                          _buildDateField('Fecha Habilitación TUC', _fechaHabilitacionTuc,
                              () => _selectDate(context, onDateSelected: (date) {
                                setState(() => _fechaHabilitacionTuc = date);
                              })),
                          
                          _buildDateField('Fecha Vencimiento TUC', _fechaVencimientoTuc,
                              () => _selectDate(context, onDateSelected: (date) {
                                setState(() => _fechaVencimientoTuc = date);
                              })),

                          _buildDropdownField(),
                          const SizedBox(height: 32),

                          BlocBuilder<VehicleBloc, VehicleState>(
                            builder: (context, state) {
                              return state.maybeWhen(
                                loading: () => const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF303366)),
                                  ),
                                ),
                                orElse: () => Row(
                                  children: [
                                    Expanded(
                                      child: _buildButton(
                                        text: 'CANCELAR',
                                        backgroundColor: Colors.grey[300]!,
                                        textColor: Colors.grey[700]!,
                                        onPressed: () => Navigator.of(context).pop(),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildButton(
                                        text: 'GUARDAR',
                                        backgroundColor: const Color(0xFF303366),
                                        textColor: Colors.white,
                                        onPressed: _submitForm,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, String? Function(String?) validator) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF303366),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF303366)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF303366),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Ingrese $label';
            if (double.tryParse(value) == null) return 'Ingrese un número válido';
            return null;
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF303366)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF303366),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: IgnorePointer(
            child: TextFormField(
              controller: TextEditingController(text: _formatDate(date)),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF303366)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: const Icon(Icons.calendar_today, size: 20, color: Color(0xFF303366)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estado',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF303366),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedEstado,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF303366)),
              items: ['Activo', 'Inactivo'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() => _selectedEstado = newValue!);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}