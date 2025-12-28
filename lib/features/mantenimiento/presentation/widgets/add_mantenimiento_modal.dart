// Ruta: lib/features/mantenimiento/presentation/widgets/add_mantenimiento_modal.dart
import 'package:flutter/material.dart';

class AddMantenimientoModal extends StatefulWidget {
  final Function()? onMantenimientoAdded;

  const AddMantenimientoModal({super.key, this.onMantenimientoAdded});

  @override
  State<AddMantenimientoModal> createState() => _AddMantenimientoModalState();
}

class _AddMantenimientoModalState extends State<AddMantenimientoModal> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para INFORMACIÓN BASE
  final _vehiculoController = TextEditingController();
  final _proveedorController = TextEditingController();
  final _colaboradorController = TextEditingController();
  final _fechaMantenimientoController = TextEditingController();
  final _kilometrajeController = TextEditingController();
  final _diccionarioController = TextEditingController();

  // Controladores para AGREGAR ACCESORIO
  final _accesorioController = TextEditingController();
  final _nombreController = TextEditingController();
  final _marcaController = TextEditingController();
  final _codigoFabricaController = TextEditingController();
  final _fechaInstalacionController = TextEditingController();
  final _tipoController = TextEditingController();

  // Controladores adicionales de la imagen
  final _codigoFabricanteController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _proximoKilometrajeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _proximaFechaController = TextEditingController();
  final _observacionController = TextEditingController();
  final _nrFacturaController = TextEditingController();
  final _montoController = TextEditingController();
  final _tipoGastoController = TextEditingController();
  final _monedaController = TextEditingController();

  // Valores para dropdowns
  String? _vehiculoValue;
  String? _proveedorValue;
  String? _colaboradorValue;
  String? _diccionarioValue;
  String? _accesorioValue;
  String? _tipoValue;
  String? _estadoValue;
  String? _tipoGastoValue;
  String? _monedaValue;

  // Listas para dropdowns
  final List<String> _vehiculoOptions = ['777-777', 'ABC-123', 'XYZ-789', 'DEF-456'];
  final List<String> _proveedorOptions = ['Proveedor A', 'Proveedor B', 'Proveedor C'];
  final List<String> _colaboradorOptions = ['Juan Pérez', 'María Gómez', 'Carlos Rodríguez'];
  final List<String> _diccionarioOptions = ['alineamiento de llanta', 'cambio de filtro', 'revisión eléctrica'];
  final List<String> _accesorioOptions = ['Llanta 9 pulgadas', 'Filtro de aceite', 'Batería', 'Aceite motor'];
  final List<String> _tipoOptions = ['Preventivo', 'Correctivo', 'Predictivo'];
  final List<String> _estadoOptions = ['Pendiente', 'En proceso', 'Completado'];
  final List<String> _tipoGastoOptions = ['Mantenimiento', 'Reparación', 'Accesorio'];
  final List<String> _monedaOptions = ['Soles (S/)', 'Dólares (\$)', 'Euros (€)'];

  @override
  void initState() {
    super.initState();
    _fechaMantenimientoController.text = _formatDate(DateTime.now());
    _fechaInstalacionController.text = _formatDate(DateTime.now());
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = _formatDate(picked);
    }
  }

  @override
  void dispose() {
    _vehiculoController.dispose();
    _proveedorController.dispose();
    _colaboradorController.dispose();
    _fechaMantenimientoController.dispose();
    _kilometrajeController.dispose();
    _diccionarioController.dispose();
    _accesorioController.dispose();
    _nombreController.dispose();
    _marcaController.dispose();
    _codigoFabricaController.dispose();
    _fechaInstalacionController.dispose();
    _tipoController.dispose();
    _codigoFabricanteController.dispose();
    _cantidadController.dispose();
    _proximoKilometrajeController.dispose();
    _estadoController.dispose();
    _proximaFechaController.dispose();
    _observacionController.dispose();
    _nrFacturaController.dispose();
    _montoController.dispose();
    _tipoGastoController.dispose();
    _monedaController.dispose();
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
        content: Text(
          '¿Está seguro de registrar el mantenimiento para ${_vehiculoValue ?? 'el vehículo'}?',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
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
                    _registrarMantenimiento();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _registrarMantenimiento() {
    // Aquí iría la lógica para registrar el mantenimiento
    print('Registrando mantenimiento...');
    
    // Simulación de registro exitoso
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mantenimiento registrado correctamente'),
          backgroundColor: const Color(0xFF303366),
        ),
      );
      
      if (widget.onMantenimientoAdded != null) {
        widget.onMantenimientoAdded!();
      }
    });
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
          maxWidth: isMobile ? double.infinity : 900,
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
                    'AGREGAR MANTENIMIENTO',
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
                      // SECCIÓN: INFORMACIÓN BASE con borde
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF303366), width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _buildSectionTitle('INFORMACIÓN BASE'),
                            const SizedBox(height: 16),

                            // Fila 1: Vehículo y Proveedor
                            if (!isMobile)
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDropdownField(
                                      'Seleccionar vehículo',
                                      _vehiculoValue,
                                      _vehiculoOptions,
                                      (value) {
                                        setState(() {
                                          _vehiculoValue = value;
                                        });
                                      },
                                      (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Seleccione el vehículo';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDropdownField(
                                      'Proveedor',
                                      _proveedorValue,
                                      _proveedorOptions,
                                      (value) {
                                        setState(() {
                                          _proveedorValue = value;
                                        });
                                      },
                                      (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Seleccione el proveedor';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDropdownField(
                                      'Seleccionar colaborador',
                                      _colaboradorValue,
                                      _colaboradorOptions,
                                      (value) {
                                        setState(() {
                                          _colaboradorValue = value;
                                        });
                                      },
                                      (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Seleccione el colaborador';
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
                                  _buildDropdownField(
                                    'Seleccionar vehículo',
                                    _vehiculoValue,
                                    _vehiculoOptions,
                                    (value) {
                                      setState(() {
                                        _vehiculoValue = value;
                                      });
                                    },
                                    (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Seleccione el vehículo';
                                      }
                                      return null;
                                    },
                                  ),
                                  _buildDropdownField(
                                    'Proveedor',
                                    _proveedorValue,
                                    _proveedorOptions,
                                    (value) {
                                      setState(() {
                                        _proveedorValue = value;
                                      });
                                    },
                                    (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Seleccione el proveedor';
                                      }
                                      return null;
                                    },
                                  ),
                                  _buildDropdownField(
                                    'Seleccionar colaborador',
                                    _colaboradorValue,
                                    _colaboradorOptions,
                                    (value) {
                                      setState(() {
                                        _colaboradorValue = value;
                                      });
                                    },
                                    (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Seleccione el colaborador';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),

                            // Fila 2: Fecha, Kilometraje y Diccionario
                            if (!isMobile)
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDateField(
                                      'Fecha de mantenimiento',
                                      _fechaMantenimientoController,
                                      () => _selectDate(context, _fechaMantenimientoController),
                                      isRequired: true,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildFormField(
                                      'Kilometraje',
                                      _kilometrajeController,
                                      (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Ingrese el kilometraje';
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDropdownField(
                                      'Seleccionar diccionario',
                                      _diccionarioValue,
                                      _diccionarioOptions,
                                      (value) {
                                        setState(() {
                                          _diccionarioValue = value;
                                        });
                                      },
                                      (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Seleccione el diccionario';
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
                                  _buildDateField(
                                    'Fecha de mantenimiento',
                                    _fechaMantenimientoController,
                                    () => _selectDate(context, _fechaMantenimientoController),
                                    isRequired: true,
                                  ),
                                  _buildFormField(
                                    'Kilometraje',
                                    _kilometrajeController,
                                    (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ingrese el kilometraje';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                  ),
                                  _buildDropdownField(
                                    'Seleccionar diccionario',
                                    _diccionarioValue,
                                    _diccionarioOptions,
                                    (value) {
                                      setState(() {
                                        _diccionarioValue = value;
                                      });
                                    },
                                    (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Seleccione el diccionario';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // SECCIÓN: AGREGAR ACCESORIO
                      _buildSectionTitle('AGREGAR ACCESORIO'),
                      const SizedBox(height: 16),

                      // Fila 3: Accesorio y Nombre
                      if (!isMobile)
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownField(
                                'Seleccionar accesorio',
                                _accesorioValue,
                                _accesorioOptions,
                                (value) {
                                  setState(() {
                                    _accesorioValue = value;
                                  });
                                },
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Seleccione el accesorio';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFormField(
                                'Nombre',
                                _nombreController,
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese el nombre';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFormField(
                                'Marca',
                                _marcaController,
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese la marca';
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
                            _buildDropdownField(
                              'Seleccionar accesorio',
                              _accesorioValue,
                              _accesorioOptions,
                              (value) {
                                setState(() {
                                  _accesorioValue = value;
                                });
                              },
                              (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Seleccione el accesorio';
                                }
                                return null;
                              },
                            ),
                            _buildFormField(
                              'Nombre',
                              _nombreController,
                              (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingrese el nombre';
                                }
                                return null;
                              },
                            ),
                            _buildFormField(
                              'Marca',
                              _marcaController,
                              (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingrese la marca';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),

                      // Fila 4: Código Fábrica, Fecha Instalación y Tipo
                      if (!isMobile)
                        Row(
                          children: [
                            Expanded(
                              child: _buildFormField(
                                'Código fábrica',
                                _codigoFabricaController,
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese el código fábrica';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDateField(
                                'Fecha de instalación',
                                _fechaInstalacionController,
                                () => _selectDate(context, _fechaInstalacionController),
                                isRequired: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDropdownField(
                                'Seleccionar tipo',
                                _tipoValue,
                                _tipoOptions,
                                (value) {
                                  setState(() {
                                    _tipoValue = value;
                                  });
                                },
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Seleccione el tipo';
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
                              'Código fábrica',
                              _codigoFabricaController,
                              (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingrese el código fábrica';
                                }
                                return null;
                              },
                            ),
                            _buildDateField(
                              'Fecha de instalación',
                              _fechaInstalacionController,
                              () => _selectDate(context, _fechaInstalacionController),
                              isRequired: true,
                            ),
                            _buildDropdownField(
                              'Seleccionar tipo',
                              _tipoValue,
                              _tipoOptions,
                              (value) {
                                setState(() {
                                  _tipoValue = value;
                                });
                              },
                              (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Seleccione el tipo';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),

                      // Campos adicionales (opcionales)
                      const SizedBox(height: 16),
                      _buildSectionTitle('INFORMACIÓN ADICIONAL'),
                      const SizedBox(height: 16),

                      if (!isMobile)
                        Row(
                          children: [
                            Expanded(
                              child: _buildFormField(
                                'Código fabricante',
                                _codigoFabricanteController,
                                (value) => null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFormField(
                                'Cantidad',
                                _cantidadController,
                                (value) => null,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFormField(
                                'Próximo kilometraje',
                                _proximoKilometrajeController,
                                (value) => null,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildFormField(
                              'Código fabricante',
                              _codigoFabricanteController,
                              (value) => null,
                            ),
                            _buildFormField(
                              'Cantidad',
                              _cantidadController,
                              (value) => null,
                              keyboardType: TextInputType.number,
                            ),
                            _buildFormField(
                              'Próximo kilometraje',
                              _proximoKilometrajeController,
                              (value) => null,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),

                      if (!isMobile)
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownField(
                                'Estado',
                                _estadoValue,
                                _estadoOptions,
                                (value) {
                                  setState(() {
                                    _estadoValue = value;
                                  });
                                },
                                (value) => null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDateField(
                                'Próxima fecha',
                                _proximaFechaController,
                                () => _selectDate(context, _proximaFechaController),
                                isRequired: false,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFormField(
                                'Observación',
                                _observacionController,
                                (value) => null,
                                maxLines: 3,
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildDropdownField(
                              'Estado',
                              _estadoValue,
                              _estadoOptions,
                              (value) {
                                setState(() {
                                  _estadoValue = value;
                                });
                              },
                              (value) => null,
                            ),
                            _buildDateField(
                              'Próxima fecha',
                              _proximaFechaController,
                              () => _selectDate(context, _proximaFechaController),
                              isRequired: false,
                            ),
                            _buildFormField(
                              'Observación',
                              _observacionController,
                              (value) => null,
                              maxLines: 3,
                            ),
                          ],
                        ),

                      // Información de factura
                      const SizedBox(height: 16),
                      _buildSectionTitle('INFORMACIÓN DE FACTURA'),
                      const SizedBox(height: 16),

                      if (!isMobile)
                        Row(
                          children: [
                            Expanded(
                              child: _buildFormField(
                                'Nr. factura',
                                _nrFacturaController,
                                (value) => null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildFormField(
                                'Monto',
                                _montoController,
                                (value) => null,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Adjuntar foto',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF303366),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey[400]!),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.attach_file, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildFormField(
                              'Nr. factura',
                              _nrFacturaController,
                              (value) => null,
                            ),
                            _buildFormField(
                              'Monto',
                              _montoController,
                              (value) => null,
                              keyboardType: TextInputType.number,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Adjuntar foto',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF303366),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[400]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.attach_file, color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                      // Tipo de gasto y moneda
                      if (!isMobile)
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownField(
                                'Tipo de gasto',
                                _tipoGastoValue,
                                _tipoGastoOptions,
                                (value) {
                                  setState(() {
                                    _tipoGastoValue = value;
                                  });
                                },
                                (value) => null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDropdownField(
                                'Moneda',
                                _monedaValue,
                                _monedaOptions,
                                (value) {
                                  setState(() {
                                    _monedaValue = value;
                                  });
                                },
                                (value) => null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: Container()), // Espacio vacío
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildDropdownField(
                              'Tipo de gasto',
                              _tipoGastoValue,
                              _tipoGastoOptions,
                              (value) {
                                setState(() {
                                  _tipoGastoValue = value;
                                });
                              },
                              (value) => null,
                            ),
                            _buildDropdownField(
                              'Moneda',
                              _monedaValue,
                              _monedaOptions,
                              (value) {
                                setState(() {
                                  _monedaValue = value;
                                });
                              },
                              (value) => null,
                            ),
                          ],
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

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF303366).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF303366),
        ),
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller,
    String? Function(String?) validator, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
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
          keyboardType: keyboardType,
          maxLines: maxLines,
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

  Widget _buildDateField(
    String label,
    TextEditingController controller,
    VoidCallback onTap,
    {bool isRequired = false}
  ) {
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
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? 'Seleccionar fecha' : controller.text,
                    style: TextStyle(
                      color: controller.text.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (isRequired && controller.text.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Este campo es requerido',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> items,
    void Function(String?) onChanged,
    String? Function(String?) validator,
  ) {
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
          value: value,
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
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
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