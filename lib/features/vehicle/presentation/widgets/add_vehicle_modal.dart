//RUTA: lib/features/vehicle/presentation/widgets/add_vehicle_modal.dart

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class AddVehicleModal extends StatefulWidget {
  final Function(String, String, String, String, String)? onVehicleAdded;

  const AddVehicleModal({super.key, this.onVehicleAdded});

  @override
  State<AddVehicleModal> createState() => _AddVehicleModalState();
}

class _AddVehicleModalState extends State<AddVehicleModal> {
  final _formKey = GlobalKey<FormState>();
  final _nrVinController = TextEditingController();
  final _placaController = TextEditingController();
  final _fechaFabricaController = TextEditingController();
  final _marcaController = TextEditingController();

  String _selectedEstado = 'Activo';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nrVinController.dispose();
    _placaController.dispose();
    _fechaFabricaController.dispose();
    _marcaController.dispose();
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
      barrierDismissible: false, // No permite salir haciendo click fuera
      builder: (context) => AlertDialog(
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
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'CANCELAR',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF303366),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra el diálogo de confirmación
                      _saveVehicle();
                    },
                    child: const Text(
                      'CONFIRMAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveVehicle() {
    setState(() {
      _isSubmitting = true;
    });

    // Simulamos un proceso de guardado
    Future.delayed(const Duration(milliseconds: 500), () {
      if (widget.onVehicleAdded != null) {
        widget.onVehicleAdded!(
          _nrVinController.text,
          _placaController.text,
          _fechaFabricaController.text,
          _marcaController.text,
          _selectedEstado,
        );
      }
      
      setState(() {
        _isSubmitting = false;
      });
      
      Navigator.of(context).pop(); // Cierra el modal principal
      
      // Mostrar snackbar de éxito notificación parte inferior
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vehículo ${_placaController.text} agregado exitosamente'),
          backgroundColor: const Color(0xFF303366),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _fechaFabricaController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return PopScope(
      canPop: false, // Bloquea el gesto de retroceso
      child: Dialog(
        insetPadding: const EdgeInsets.all(20),
        backgroundColor: Colors.white, // ← FONDO MODAL
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 500,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header centrado
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

                  // Formulario
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Nr. VIN
                        _buildFormField(
                          label: 'Nr. VIN',
                          controller: _nrVinController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese el número VIN';
                            }
                            if (value.length < 5) {
                              return 'El VIN debe tener al menos 5 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Placa
                        _buildFormField(
                          label: 'Placa',
                          controller: _placaController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese la placa';
                            }
                            if (value.length < 6) {
                              return 'La placa debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Fecha Fábrica
                        _buildDateField(
                          label: 'Fecha de Fabricación',
                          controller: _fechaFabricaController,
                          onTap: () => _selectDate(context),
                        ),
                        const SizedBox(height: 16),

                        // Marca
                        _buildFormField(
                          label: 'Marca',
                          controller: _marcaController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese la marca';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Estado (Dropdown)
                        _buildDropdownField(),
                        const SizedBox(height: 32),

                        // Botones
                        _isSubmitting
                            ? const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF303366)),
                                ),
                              )
                            : Row(
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF303366)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
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
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF303366)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: const Icon(Icons.calendar_today, size: 20, color: Color(0xFF303366)),
              ),
            ),
          ),
        ),
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
              items: ['Activo', 'Inactivo', 'En Mantenimiento']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedEstado = newValue!;
                });
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
}
