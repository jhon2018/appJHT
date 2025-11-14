// lib/features/accessory/presentation/widgets/add_accessory_modal.dart
// DESCRIPCIÓN: Modal para agregar un nuevo accesorio.

import 'package:flutter/material.dart';

class AddAccessoryModal extends StatefulWidget {
  final Function()? onAccessoryAdded;

  const AddAccessoryModal({
    super.key, 
    this.onAccessoryAdded
  });

  @override
  State<AddAccessoryModal> createState() => _AddAccessoryModalState();
}

class _AddAccessoryModalState extends State<AddAccessoryModal> {
  final _formKey = GlobalKey<FormState>();
  final _codigoFabricanteController = TextEditingController();
  final _nombreController = TextEditingController();
  final _unidadMedidaController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  DateTime? _fechaInstalacion;

  @override
  void dispose() {
    _codigoFabricanteController.dispose();
    _nombreController.dispose();
    _unidadMedidaController.dispose();
    _descripcionController.dispose();
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
          '¿Está seguro de que desea agregar este accesorio?',
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
                    _registrarAccessory();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _registrarAccessory() {
    // TODO: Implementar lógica de registro
    print('Registrar accesorio: ${_codigoFabricanteController.text}');
    
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Accesorio ${_nombreController.text} registrado exitosamente'),
        backgroundColor: const Color(0xFF303366),
        duration: const Duration(seconds: 5),
      ),
    );
    
    if (widget.onAccessoryAdded != null) {
      widget.onAccessoryAdded!();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() => _fechaInstalacion = picked);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Seleccionar fecha';
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
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
              children: [
                const Center(
                  child: Text(
                    'AGREGAR ACCESORIO',
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
                      _buildFormField('Código Fabricante', _codigoFabricanteController, (value) {
                        if (value == null || value.isEmpty) return 'Ingrese el código del fabricante';
                        return null;
                      }),
                      
                      _buildFormField('Nombre', _nombreController, (value) {
                        if (value == null || value.isEmpty) return 'Ingrese el nombre del accesorio';
                        return null;
                      }),

                      _buildDateField('Fecha Instalación', _fechaInstalacion, 
                          () => _selectDate(context)),
                      
                      _buildFormField('Unidad de Medida', _unidadMedidaController, (value) {
                        if (value == null || value.isEmpty) return 'Ingrese la unidad de medida';
                        return null;
                      }),

                      _buildFormField('Descripción', _descripcionController, (value) {
                        return null; // Opcional
                      }, maxLines: 3),

                      const SizedBox(height: 32),

                      Row(
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
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, String? Function(String?) validator, {int maxLines = 1}) {
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
          maxLines: maxLines,
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