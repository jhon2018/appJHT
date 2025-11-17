// lib/features/accessory/presentation/widgets/add_accessory_type_modal.dart
import 'package:flutter/material.dart';

class AddAccessoryTypeModal extends StatefulWidget {
  const AddAccessoryTypeModal({super.key});

  @override
  State<AddAccessoryTypeModal> createState() => _AddAccessoryTypeModalState();
}

class _AddAccessoryTypeModalState extends State<AddAccessoryTypeModal> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para los campos principales
  final _segmentoController = TextEditingController();
  final _nombreAccesorioController = TextEditingController();
  final _unidadMedidaController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _descripcionSegController = TextEditingController();
  final _descripcionAccesorioController = TextEditingController();
  
  // Lista dinámica para mantenimientos
  final List<Mantenimiento> _mantenimientos = [];

  // Opciones para dropdowns
  final List<String> _segmentoOptions = ['Seleccionar segmento'];
  final List<String> _estadoOptions = ['Activo', 'Inactivo'];
  final List<String> _tipoManOptions = ['Preventivo', 'Correctivo', 'Predictivo'];

  @override
  void initState() {
    super.initState();
    // Agregar un mantenimiento inicial vacío
    _mantenimientos.add(Mantenimiento());
  }

  @override
  void dispose() {
    _segmentoController.dispose();
    _nombreAccesorioController.dispose();
    _unidadMedidaController.dispose();
    _cantidadController.dispose();
    _descripcionSegController.dispose();
    _descripcionAccesorioController.dispose();
    
    // Dispose de todos los controladores de mantenimientos
    for (var mantenimiento in _mantenimientos) {
      mantenimiento.nombreController.dispose();
      mantenimiento.descripcionController.dispose();
      mantenimiento.frecuenciaDiasController.dispose();
      mantenimiento.tipoManController.dispose();
      mantenimiento.frecuenciaKmController.dispose();
    }
    
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
          '¿Está seguro de que desea agregar este tipo de accesorio?',
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
                    _registrarTipoAccesorio();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _registrarTipoAccesorio() {
    // TODO: Implementar lógica de registro
    print('Registrar tipo accesorio: ${_nombreAccesorioController.text}');
    
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tipo de accesorio ${_nombreAccesorioController.text} registrado exitosamente'),
        backgroundColor: const Color(0xFF303366),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _agregarMantenimiento() {
    setState(() {
      _mantenimientos.add(Mantenimiento());
    });
  }

  void _eliminarMantenimiento(int index) {
    if (_mantenimientos.length > 1) {
      setState(() {
        _mantenimientos.removeAt(index);
      });
    }
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
          maxWidth: isMobile ? double.infinity : 800,
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
                    'TIPO ACCESORIO',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sección: Tipo de accesorio con borde
                      _buildSeccionConBorde(
                        titulo: 'Tipo de accesorio',
                        contenido: Column(
                          children: [
                            // Primera fila: Segmento, Nombre, Unidad de medida, Cantidad
                            if (!isMobile)
                              Row(
                                children: [
                                  Expanded(child: _buildDropdownField('Segmento', _segmentoController, _segmentoOptions)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildFormField('Nombre de accesorio', _nombreAccesorioController)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildFormField('Unidad de medida', _unidadMedidaController)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildFormField('Cantidad', _cantidadController, keyboardType: TextInputType.number)),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  _buildDropdownField('Segmento', _segmentoController, _segmentoOptions),
                                  _buildFormField('Nombre de accesorio', _nombreAccesorioController),
                                  _buildFormField('Unidad de medida', _unidadMedidaController),
                                  _buildFormField('Cantidad', _cantidadController, keyboardType: TextInputType.number),
                                ],
                              ),

                            const SizedBox(height: 16),

                            // Segunda fila: Descripción seg y Descripción accesorio
                            if (!isMobile)
                              Row(
                                children: [
                                  Expanded(child: _buildFormField('Descripción seg', _descripcionSegController, maxLines: 3)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildFormField('Descripción accesorio', _descripcionAccesorioController, maxLines: 3)),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  _buildFormField('Descripción seg', _descripcionSegController, maxLines: 3),
                                  _buildFormField('Descripción accesorio', _descripcionAccesorioController, maxLines: 3),
                                ],
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Botón Agregar Mantenimiento
                      _buildAddMaintenanceButton(),

                      const SizedBox(height: 24),

                      // Secciones de mantenimientos dinámicas
                      ..._mantenimientos.asMap().entries.map((entry) {
                        final index = entry.key;
                        final mantenimiento = entry.value;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _buildSeccionConBorde(
                            titulo: 'Diccionario de mantenimiento ${index + 1}',
                            mostrarBotonEliminar: _mantenimientos.length > 1,
                            onEliminar: () => _eliminarMantenimiento(index),
                            contenido: _buildContenidoMantenimiento(mantenimiento, index),
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 32),

                      // Botones (SOLO CERRAR y GUARDAR - ELIMINADO EDITAR)
                      Row(
                        children: [
                          Expanded(
                            child: _buildButton(
                              text: 'CERRAR',
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

  Widget _buildSeccionConBorde({
    required String titulo,
    required Widget contenido,
    bool mostrarBotonEliminar = false,
    VoidCallback? onEliminar,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF303366),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF303366),
                ),
              ),
              if (mostrarBotonEliminar)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onEliminar,
                  tooltip: 'Eliminar mantenimiento',
                ),
            ],
          ),
          const SizedBox(height: 16),
          contenido,
        ],
      ),
    );
  }

  Widget _buildContenidoMantenimiento(Mantenimiento mantenimiento, int index) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Column(
      children: [
        if (!isMobile)
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildFormField('Nombre de mantenimiento', mantenimiento.nombreController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildFormField('Descripción man', mantenimiento.descripcionController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildFormField('Frecuencia en días', mantenimiento.frecuenciaDiasController, keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDropdownField('Tipo de man', mantenimiento.tipoManController, _tipoManOptions)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField(
                      'Estado', 
                      TextEditingController(text: mantenimiento.estadoValue), 
                      _estadoOptions, 
                      onChanged: (value) => setState(() => mantenimiento.estadoValue = value)
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _buildFormField('Frecuencia en kilómetros', mantenimiento.frecuenciaKmController, keyboardType: TextInputType.number)),
                ],
              ),
            ],
          )
        else
          Column(
            children: [
              _buildFormField('Nombre de mantenimiento', mantenimiento.nombreController),
              _buildFormField('Descripción man', mantenimiento.descripcionController),
              _buildFormField('Frecuencia en días', mantenimiento.frecuenciaDiasController, keyboardType: TextInputType.number),
              _buildDropdownField('Tipo de man', mantenimiento.tipoManController, _tipoManOptions),
              _buildDropdownField(
                'Estado', 
                TextEditingController(text: mantenimiento.estadoValue), 
                _estadoOptions, 
                onChanged: (value) => setState(() => mantenimiento.estadoValue = value)
              ),
              _buildFormField('Frecuencia en kilómetros', mantenimiento.frecuenciaKmController, keyboardType: TextInputType.number),
            ],
          ),
      ],
    );
  }

  Widget _buildAddMaintenanceButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _agregarMantenimiento,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF303366),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 20, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'AGREGAR MANTENIMIENTO',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, {
    int maxLines = 1, 
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
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

  Widget _buildDropdownField(String label, TextEditingController controller, List<String> options, {
    Function(String?)? onChanged,
    String? Function(String?)? validator,
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
        DropdownButtonFormField<String>(
          value: controller.text.isEmpty ? null : controller.text,
          isExpanded: true, // IMPORTANTE: Evita overflow
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
              child: Text(
                value,
                overflow: TextOverflow.ellipsis, // IMPORTANTE: Evita que el texto se salga
                style: const TextStyle(fontSize: 14),
              ),
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

// Clase para manejar los mantenimientos de forma dinámica
class Mantenimiento {
  final TextEditingController nombreController;
  final TextEditingController descripcionController;
  final TextEditingController frecuenciaDiasController;
  final TextEditingController tipoManController;
  final TextEditingController frecuenciaKmController;
  String? estadoValue;

  Mantenimiento({
    String? nombre,
    String? descripcion,
    String? frecuenciaDias,
    String? tipoMan,
    String? frecuenciaKm,
    this.estadoValue,
  }) : 
        nombreController = TextEditingController(text: nombre),
        descripcionController = TextEditingController(text: descripcion),
        frecuenciaDiasController = TextEditingController(text: frecuenciaDias),
        tipoManController = TextEditingController(text: tipoMan),
        frecuenciaKmController = TextEditingController(text: frecuenciaKm);
}