// lib/features/supplier/presentation/widgets/add_supplier_modal.dart
// DESCRIPCIÓN: Modal para agregar un nuevo proveedor con todos los campos requeridos.

import 'package:flutter/material.dart';

class AddSupplierModal extends StatefulWidget {
  final Function()? onSupplierAdded;

  const AddSupplierModal({
    super.key, 
    this.onSupplierAdded
  });

  @override
  State<AddSupplierModal> createState() => _AddSupplierModalState();
}

class _AddSupplierModalState extends State<AddSupplierModal> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para los campos principales
  final _razonSocialController = TextEditingController();
  final _direccionController = TextEditingController();
  final _rucController = TextEditingController();
  final _tipoController = TextEditingController();
  final _bancoController = TextEditingController();
  final _encargadoController = TextEditingController();
  final _representanteController = TextEditingController();
  final _ubicacionLinkController = TextEditingController();
  final _correoController = TextEditingController();
  final _numeroCuentaController = TextEditingController();
  final _observacionController = TextEditingController();
  
  // Controladores para teléfonos (lista dinámica)
  final List<TextEditingController> _telefonoControllers = [TextEditingController()];
  final List<String?> _telefonoTipos = [null];
  final List<String?> _telefonoUsos = [null];
  
  // Variables para dropdowns
  String? _estadoValue;
  String? _selectedTipoTelefono;
  String? _selectedUsoTelefono;
  
  // Opciones para dropdowns
  final List<String> _estadoOptions = ['Activo', 'Inactivo'];
  final List<String> _tipoTelefonoOptions = ['Móvil', 'Fijo', 'WhatsApp', 'Telegram'];
  final List<String> _usoTelefonoOptions = ['Personal', 'Trabajo', 'Emergencia', 'Facturación'];
  
  @override
  void dispose() {
    _razonSocialController.dispose();
    _direccionController.dispose();
    _rucController.dispose();
    _tipoController.dispose();
    _bancoController.dispose();
    _encargadoController.dispose();
    _representanteController.dispose();
    _ubicacionLinkController.dispose();
    _correoController.dispose();
    _numeroCuentaController.dispose();
    _observacionController.dispose();
    
    for (var controller in _telefonoControllers) {
      controller.dispose();
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
          '¿Está seguro de que desea agregar este proveedor?',
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
                    _registrarSupplier();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _registrarSupplier() {
    // TODO: Implementar lógica de registro
    print('=== DATOS DEL PROVEEDOR ===');
    print('Razón Social: ${_razonSocialController.text}');
    print('RUC: ${_rucController.text}');
    print('Teléfonos:');
    for (int i = 0; i < _telefonoControllers.length; i++) {
      print('  - ${_telefonoTipos[i]}: ${_telefonoControllers[i].text} (${_telefonoUsos[i]})');
    }
    
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Proveedor ${_razonSocialController.text} registrado exitosamente'),
        backgroundColor: const Color(0xFF303366),
        duration: const Duration(seconds: 5),
      ),
    );
    
    if (widget.onSupplierAdded != null) {
      widget.onSupplierAdded!();
    }
  }

  // Método para agregar nuevo campo de teléfono
  void _agregarTelefono() {
    setState(() {
      _telefonoControllers.add(TextEditingController());
      _telefonoTipos.add(null);
      _telefonoUsos.add(null);
    });
  }

  // Método para eliminar campo de teléfono
  void _eliminarTelefono(int index) {
    if (_telefonoControllers.length > 1) {
      setState(() {
        _telefonoControllers[index].dispose();
        _telefonoControllers.removeAt(index);
        _telefonoTipos.removeAt(index);
        _telefonoUsos.removeAt(index);
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
                    'AGREGAR PROVEEDOR',
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
                      // Fila 1: Razón Social y RUC
                      if (!isMobile)
                        Row(
                          children: [
                            Expanded(
                              child: _buildFormField(
                                'Razón Social',
                                _razonSocialController,
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese la razón social';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFormField(
                                'RUC',
                                _rucController,
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese el RUC';
                                  }
                                  if (value.length != 11) {
                                    return 'El RUC debe tener 11 dígitos';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildFormField(
                              'Razón Social',
                              _razonSocialController,
                              (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingrese la razón social';
                                }
                                return null;
                              },
                            ),
                            _buildFormField(
                              'RUC',
                              _rucController,
                              (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingrese el RUC';
                                }
                                if (value.length != 11) {
                                  return 'El RUC debe tener 11 dígitos';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),

                      // Dirección
                      _buildFormField(
                        'Dirección',
                        _direccionController,
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese la dirección';
                          }
                          return null;
                        },
                      ),

                      // Fila 2: Tipo y Banco
                      if (!isMobile)
                        Row(
                          children: [
                            Expanded(
                              child: _buildFormField(
                                'Tipo',
                                _tipoController,
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese el tipo';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFormField(
                                'Banco',
                                _bancoController,
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese el banco';
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
                            _buildFormField(
                              'Tipo',
                              _tipoController,
                              (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingrese el tipo';
                                }
                                return null;
                              },
                            ),
                            _buildFormField(
                              'Banco',
                              _bancoController,
                              (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingrese el banco';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),

                      // Encargado
                      _buildFormField(
                        'Encargado',
                        _encargadoController,
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el encargado';
                          }
                          return null;
                        },
                      ),

                      // SECCIÓN DE TELÉFONOS (dinámica)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Teléfonos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF303366),
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Lista de teléfonos
                          ...List.generate(_telefonoControllers.length, (index) {
                            return _buildTelefonoRow(index, isMobile);
                          }),
                          
                          // Botón para agregar más teléfonos
                          Container(
                            width: double.infinity,
                            height: 40,
                            margin: const EdgeInsets.only(top: 8),
                            child: OutlinedButton(
                              onPressed: _agregarTelefono,
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
                                    'AGREGAR TELÉFONO',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Representante
                      _buildFormField(
                        'Representante',
                        _representanteController,
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el representante';
                          }
                          return null;
                        },
                      ),

                      // Link de ubicación
                      _buildFormField(
                        'Link de Ubicación',
                        _ubicacionLinkController,
                        (value) => null, // Opcional
                      ),

                      // Correo
                      _buildFormField(
                        'Correo',
                        _correoController,
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el correo';
                          }
                          if (!value.contains('@')) {
                            return 'Ingrese un correo válido';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),

                      // Número de Cuenta
                      _buildFormField(
                        'Número de Cuenta',
                        _numeroCuentaController,
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el número de cuenta';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),

                      // Estado (dropdown)
                      _buildEstadoDropdown(),

                      // Observaciones
                      _buildFormField(
                        'Observaciones',
                        _observacionController,
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

  // Widget para fila de teléfono (tipo, uso, número, eliminar)
  Widget _buildTelefonoRow(int index, bool isMobile) {
    return Column(
      children: [
        if (index > 0) const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tipo de teléfono (dropdown)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tipo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF303366),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _telefonoTipos[index],
                        isExpanded: true,
                        hint: const Text(
                          'Seleccione',
                          style: TextStyle(fontSize: 12),
                        ),
                        items: _tipoTelefonoOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _telefonoTipos[index] = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            
            // Uso del teléfono (dropdown)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Uso',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF303366),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _telefonoUsos[index],
                        isExpanded: true,
                        hint: const Text(
                          'Seleccione',
                          style: TextStyle(fontSize: 12),
                        ),
                        items: _usoTelefonoOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _telefonoUsos[index] = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            
            // Número de teléfono
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Teléfono',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF303366),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _telefonoControllers[index],
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      hintText: 'Ej: 987654321',
                      hintStyle: const TextStyle(fontSize: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el teléfono';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            
            // Botón eliminar (solo si hay más de uno)
            if (_telefonoControllers.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 28, left: 8),
                child: InkWell(
                  onTap: () => _eliminarTelefono(index),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.delete,
                      color: Colors.red[700],
                      size: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller,
    String? Function(String?) validator, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEstadoDropdown() {
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
        DropdownButtonFormField<String>(
          value: _estadoValue,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF303366)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: _estadoOptions.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _estadoValue = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Seleccione el estado';
            }
            return null;
          },
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