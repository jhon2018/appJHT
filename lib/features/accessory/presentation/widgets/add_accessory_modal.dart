// lib/features/accessory/presentation/widgets/add_accessory_modal.dart
// DESCRIPCIÓN: Modal para agregar un nuevo accesorio.

import 'package:flutter/material.dart';
import 'add_accessory_type_modal.dart';

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
  
  // Controladores para los nuevos campos
  final _segmentoController = TextEditingController();
  final _nombreAccesorioController = TextEditingController();
  final _vehiculoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _marcaController = TextEditingController();
  final _codigoFabricanteController = TextEditingController();
  final _kilometrajeInstalacionController = TextEditingController();
  final _kilometrajeRetiroController = TextEditingController();
  final _observacionesController = TextEditingController();
  
  DateTime? _fechaInstalacion;
  DateTime? _fechaRetiro;
  String? _estadoValue;

  // Opciones para los dropdowns
  final List<String> _segmentoOptions = ['Selecciona segmento'];
  final List<String> _estadoOptions = ['Activo', 'Inactivo'];

  @override
  void dispose() {
    _segmentoController.dispose();
    _nombreAccesorioController.dispose();
    _vehiculoController.dispose();
    _descripcionController.dispose();
    _marcaController.dispose();
    _codigoFabricanteController.dispose();
    _kilometrajeInstalacionController.dispose();
    _kilometrajeRetiroController.dispose();
    _observacionesController.dispose();
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
    print('Registrar accesorio: ${_nombreAccesorioController.text}');
    
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Accesorio ${_nombreAccesorioController.text} registrado exitosamente'),
        backgroundColor: const Color(0xFF303366),
        duration: const Duration(seconds: 5),
      ),
    );
    
    if (widget.onAccessoryAdded != null) {
      widget.onAccessoryAdded!();
    }
  }

  void _agregarTipoAccesorio() {
    showDialog(
      context: context,
      barrierDismissible: false, // ← IMPIDE CERRAR HACIENDO CLIC AFUERA
      builder: (context) => const AddAccessoryTypeModal(),
    );
  }

    Future<void> _selectDate(BuildContext context, bool isInstalacion) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2030),
      );
      
      if (picked != null) {
        setState(() {
          if (isInstalacion) {
            _fechaInstalacion = picked;
          } else {
            _fechaRetiro = picked;
          }
        });
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
          maxWidth: isMobile ? double.infinity : 600,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                      // Primera fila: Segmento y Nombre de Accesorio
                      if (!isMobile) 
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownField(
                                'Segmento',
                                _segmentoController,
                                _segmentoOptions,
                                (value) {
                                  if (value == null || value == 'Selecciona el segmento') {
                                    return 'Seleccione un segmento';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDropdownField(
                                    'Nombre de Accesorio',
                                    _nombreAccesorioController,
                                    [], // Aquí irían las opciones reales
                                    (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Seleccione el nombre del accesorio';
                                      }
                                      return null;
                                    },
                                  ),
                                  _buildAddTypeButton(),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildDropdownField(
                              'Segmento',
                              _segmentoController,
                              _segmentoOptions,
                              (value) {
                                if (value == null || value == 'Selecciona el segmento') {
                                  return 'Seleccione un segmento';
                                }
                                return null;
                              },
                            ),
                            _buildDropdownField(
                              'Nombre de Accesorio',
                              _nombreAccesorioController,
                              [], // Aquí irían las opciones reales
                              (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Seleccione el nombre del accesorio';
                                }
                                return null;
                              },
                            ),
                            _buildAddTypeButton(),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // Vehículo
                      _buildDropdownField(
                        'Vehículo',
                        _vehiculoController,
                        [], // Aquí irían las opciones reales
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'Seleccione un vehículo';
                          }
                          return null;
                        },
                      ),

                      // Descripción
                      _buildFormField('Descripción del Accesorio', _descripcionController, 
                        (value) => null, // Opcional
                        maxLines: 2,
                      ),

                      // Segunda fila: Marca y Código de Fabricante
                      if (!isMobile) 
                        Row(
                          children: [
                            Expanded(
                              child: _buildFormField('Marca de Accesorio', _marcaController, 
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese la marca del accesorio';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFormField('Código de Fabricante', _codigoFabricanteController, 
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese el código del fabricante';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildFormField('Marca de Accesorio', _marcaController, 
                              (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingrese la marca del accesorio';
                                }
                                return null;
                              },
                            ),
                            _buildFormField('Código de Fabricante', _codigoFabricanteController, 
                              (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingrese el código del fabricante';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),

                      // Tercera fila: Fechas de Instalación y Retiro
                      if (!isMobile) 
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateField('Fecha de Instalación', _fechaInstalacion, 
                                  () => _selectDate(context, true)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDateField('Fecha de Retiro', _fechaRetiro, 
                                  () => _selectDate(context, false)),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildDateField('Fecha de Instalación', _fechaInstalacion, 
                                () => _selectDate(context, true)),
                            _buildDateField('Fecha de Retiro', _fechaRetiro, 
                                () => _selectDate(context, false)),
                          ],
                        ),

                      // Cuarta fila: Kilometraje de Instalación y Retiro
                      if (!isMobile) 
                        Row(
                          children: [
                            Expanded(
                              child: _buildFormField('Kilometraje de Instalación', _kilometrajeInstalacionController, 
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese el kilometraje de instalación';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFormField('Kilometraje de Retiro', _kilometrajeRetiroController, 
                                (value) => null, // Opcional
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildFormField('Kilometraje de Instalación', _kilometrajeInstalacionController, 
                              (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingrese el kilometraje de instalación';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                            ),
                            _buildFormField('Kilometraje de Retiro', _kilometrajeRetiroController, 
                              (value) => null, // Opcional
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),

                      // Estado
                      _buildDropdownField(
                        'Estado',
                        TextEditingController(text: _estadoValue),
                        _estadoOptions,
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'Seleccione el estado';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _estadoValue = value;
                          });
                        },
                      ),

                      // Observaciones
                      _buildFormField('Observaciones', _observacionesController, 
                        (value) => null, // Opcional
                        maxLines: 3,
                      ),

                      const SizedBox(height: 32),

                      // Botones
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

  Widget _buildAddTypeButton() {
    return Container(
      width: double.infinity,
      height: 40,
      margin: const EdgeInsets.only(top: 8),
      child: OutlinedButton(
        onPressed: _agregarTipoAccesorio,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF303366),
          side: const BorderSide(color: Color(0xFF303366)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 16),
            SizedBox(width: 8),
            Text(
              'AGREGAR TIPO ACCESORIO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, String? Function(String?) validator, {
    int maxLines = 1, 
    TextInputType keyboardType = TextInputType.text
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
          maxLines: maxLines,
          keyboardType: keyboardType,
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

  Widget _buildDropdownField(String label, TextEditingController controller, List<String> options, 
      String? Function(String?) validator, {Function(String?)? onChanged}) {
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
        DropdownButtonFormField<String>(
          value: controller.text.isEmpty ? null : controller.text,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF303366)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            controller.text = value ?? '';
            if (onChanged != null) {
              onChanged(value);
            }
          },
          validator: validator,
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