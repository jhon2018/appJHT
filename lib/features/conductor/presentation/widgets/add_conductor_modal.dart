//Ruta: lib/features/conductor/presentation/widgets/add_conductor_modal.dart
import 'dart:convert';
import 'package:app_jht_front/features/conductor/data/models/persona_actualizar_response.dart';
import 'package:app_jht_front/features/conductor/data/models/persona_model.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_event.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:app_jht_front/core/utils/token_service.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_bloc.dart';
import 'package:app_jht_front/features/conductor/data/models/conductor_registro_dto.dart';
import 'package:app_jht_front/features/supplier/data/models/tipo_telefono_model.dart';

class AddConductorModal extends StatefulWidget {
  final Function()? onConductorAdded;

  const AddConductorModal({super.key, this.onConductorAdded});

  @override
  State<AddConductorModal> createState() => _AddConductorModalState();
}

class _AddConductorModalState extends State<AddConductorModal> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para campos principales
  final _dniController = TextEditingController();
  final _primerNombreController = TextEditingController();
  final _segundoNombreController = TextEditingController();
  final _apellidoPaternoController = TextEditingController();
  final _apellidoMaternoController = TextEditingController();
  final _emailController = TextEditingController();
  final _salarioController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _fechaIngresoController = TextEditingController();
  final _fechaSalidaController = TextEditingController();

  // Controladores para conductor
  final _numeroLicenciaController = TextEditingController();
  final _claseLicenciaController = TextEditingController();
  final _categoriaLicenciaController = TextEditingController();
  final _fechaRegistroLicenciaController = TextEditingController();
  final _fechaVencimientoLicenciaController = TextEditingController();

  // Controladores para teléfonos
  final List<TextEditingController> _telefonoControllers = [
    TextEditingController(),
  ];
  final List<TipoTelefonoModel?> _telefonoTipos = [null];

  // Variables para dropdowns
  String? _estadoValue;
  String? _cargoValue;

  // Listas
  final List<String> _estadoOptions = ['Activo', 'Inactivo'];
  final List<String> _cargoOptions = ['Administrador', 'Conductor'];
  final List<String> _claseLicenciaOptions = ['A', 'B', 'C', 'D', 'E'];
  final List<String> _categoriaLicenciaOptions = [
    'I',
    'II-A',
    'II-B',
    'III-A',
    'III-B',
    'III-C',
  ];

  List<TipoTelefonoModel> _tiposTelefonoList = [];

  @override
  void initState() {
    super.initState();
    _cargarTiposTelefono();
    _fechaIngresoController.text = _formatDate(DateTime.now());
  }

  Future<void> _cargarTiposTelefono() async {
    try {
      print('🟡 Cargando tipos de teléfono...');

      final String? token = await TokenService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación.');
      }

      String getBaseUrl() {
        if (kIsWeb) {
          return 'http://localhost:7030';
        } else {
          return 'http://192.168.1.2:7030';
        }
      }

      final response = await http.get(
        Uri.parse('${getBaseUrl()}/api/admin/consulta_tipo_telefono'),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      );

      print('🟡 Response status tipos teléfono: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'] as List;
        final tipos = data
            .map((item) => TipoTelefonoModel.fromJson(item))
            .toList();

        setState(() {
          _tiposTelefonoList = tipos;
        });
        print('🟢 Tipos de teléfono cargados: ${tipos.length}');
      } else {
        throw Exception(
          'Error al obtener tipos de teléfono: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ ERROR al cargar tipos de teléfono: $e');
      setState(() {
        _tiposTelefonoList = [
          TipoTelefonoModel(id: 1, tipo: 'Celular', uso: 'Personal'),
          TipoTelefonoModel(id: 2, tipo: 'Fijo', uso: 'Oficina'),
          TipoTelefonoModel(id: 3, tipo: 'WhatsApp', uso: 'Personal'),
        ];
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    print('🟡 Seleccionando fecha para: ${controller.hashCode}');

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF303366),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF303366),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Forzar un rebuild del widget específico
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          controller.text = _formatDate(picked);
        });
      });
      print('🟢 Fecha seleccionada: $picked');
      print('🔵 Controller text actualizado: ${controller.text}');
    } else {
      print('🔴 No se seleccionó fecha');
    }
  }

  @override
  void dispose() {
    _dniController.dispose();
    _primerNombreController.dispose();
    _segundoNombreController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _emailController.dispose();
    _salarioController.dispose();
    _fechaNacimientoController.dispose();
    _fechaIngresoController.dispose();
    _fechaSalidaController.dispose();
    _numeroLicenciaController.dispose();
    _claseLicenciaController.dispose();
    _categoriaLicenciaController.dispose();
    _fechaRegistroLicenciaController.dispose();
    _fechaVencimientoLicenciaController.dispose();

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
        content: Text(
          '¿Está seguro de registrar a ${_primerNombreController.text} ${_apellidoPaternoController.text} como $_cargoValue?',
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
                    _registrarConductor();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _mostrarErrorDialog(String message) {
    String mensajeLimpio = _limpiarMensajeError(message);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Error de Validación',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.red,
          ),
        ),
        content: Text(
          mensajeLimpio,
          textAlign: TextAlign.center,
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
  }

  String _limpiarMensajeError(String message) {
    if (message.contains('DNI debe ser mayor que 0')) {
      return 'El DNI debe tener exactamente 8 dígitos numéricos y ser mayor que 0.';
    } else if (message.contains('Ocurrió un error al registrar')) {
      final partes = message.split(':');
      if (partes.length > 1) {
        return partes.last.trim();
      }
    }
    return message.replaceAll('Exception: ', '');
  }

  void _registrarConductor() {
    // Validar DNI antes de enviar
    final dniText = _dniController.text.trim();
    if (dniText.isEmpty) {
      _mostrarErrorDialog('El DNI es requerido');
      return;
    }

    if (dniText.length != 8) {
      _mostrarErrorDialog('El DNI debe tener exactamente 8 dígitos');
      return;
    }

    final dni = int.tryParse(dniText);
    if (dni == null || dni <= 0) {
      _mostrarErrorDialog('El DNI debe ser un número válido mayor que 0');
      return;
    }

    // Validar campos obligatorios
    for (int i = 0; i < _telefonoControllers.length; i++) {
      if (_telefonoTipos[i] == null) {
        _mostrarErrorDialog(
          'Seleccione el tipo y uso para el teléfono ${i + 1}',
        );
        return;
      }
    }

    // Validar cargo seleccionado
    if (_cargoValue == null) {
      _mostrarErrorDialog('Seleccione el cargo');
      return;
    }

    // Validar formulario
    if (_formKey.currentState!.validate() && _estadoValue != null) {
      // Crear DTO de persona
      final persona = PersonaDto(
        dni: int.parse(_dniController.text),
        primerNombre: _primerNombreController.text,
        segundoNombre: _segundoNombreController.text,
        apellidoPaterno: _apellidoPaternoController.text,
        apellidoMaterno: _apellidoMaternoController.text,
        fechaNacimiento: _fechaNacimientoController.text,
        correo: _emailController.text,
        cargo: _cargoValue!,
        salario: double.parse(_salarioController.text),
        estado: _estadoValue!,
        fechaIngreso: _fechaIngresoController.text,
      );

      // Crear DTO de conductor si cargo es "Conductor"
      ConductorDto? conductor;
      if (_cargoValue == 'Conductor') {
        conductor = ConductorDto(
          numeroLicencia: _numeroLicenciaController.text,
          claseLicencia: _claseLicenciaController.text,
          categoriaLicencia: _categoriaLicenciaController.text,
          fechaRegistroLicencia: _fechaRegistroLicenciaController.text,
          fechaVencimientoLicencia: _fechaVencimientoLicenciaController.text,
        );
      }

      // Crear lista de teléfonos DTO
      final telefonos = _telefonoControllers.asMap().entries.map((entry) {
        final index = entry.key;
        final controller = entry.value;
        return TelefonoConductorDto(
          numero: controller.text,
          tipoId: _telefonoTipos[index]!.id,
        );
      }).toList();

      // Crear DTO principal
      final dto = ConductorRegistroDto(
        persona: persona,
        conductor: conductor,
        telefonos: telefonos,
      );

      // Obtener el bloc y registrar
      final bloc = BlocProvider.of<ConductorBloc>(context);
      bloc.add(ConductorEvent.registrarConductor(dto: dto));
    }
  }

  void _agregarTelefono() {
    if (_telefonoControllers.length < 3) {
      setState(() {
        _telefonoControllers.add(TextEditingController());
        _telefonoTipos.add(null);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Máximo 3 teléfonos permitidos'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _eliminarTelefono(int index) {
    if (_telefonoControllers.length > 1) {
      setState(() {
        _telefonoControllers[index].dispose();
        _telefonoControllers.removeAt(index);
        _telefonoTipos.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return BlocListener<ConductorBloc, ConductorState>(
      listener: (context, state) {
        // Solo manejar estados de REGISTRO, no de listar personas
        state.when(
          initial: () {},
          loading: () {
            // Podrías mostrar un loading aquí
          },
          success: (response) {
            Navigator.of(context).pop(); // Cierra el modal
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${_primerNombreController.text} ${_apellidoPaternoController.text} (DNI: ${_dniController.text}) registrado como $_cargoValue correctamente',
                ),
                backgroundColor: const Color(0xFF303366),
                duration: const Duration(seconds: 5),
              ),
            );

            if (widget.onConductorAdded != null) {
              widget.onConductorAdded!();
            }
          },
          error: (message) {
            _mostrarErrorDialog(message);
          },
          // NO incluir los otros estados, no son relevantes para este modal
          personasCargando: () {},
          personasCargadas: (_) {},
          personaDetalleCargando: () {},
          personaDetalleCargado: (_) {},
          personaDetalleError: (_) {},
          personaActualizando: () {},
          personaActualizada: (PersonaActualizarResponse response) {},
          personaActualizacionError: (String message) {},
          tiposTelefonoCargando: () {},
          tiposTelefonoCargados: (List<TipoTelefonoModel> tipos) {},
          tiposTelefonoError: (String message) {},
        );
      },
      child: Dialog(
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
                      'AGREGAR CONDUCTOR o ADMINISTRADOR',
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
                        // Información Personal
                        _buildSectionTitle('INFORMACIÓN PERSONAL'),
                        const SizedBox(height: 16),

                        // Fila 1: DNI y Nombres
                        if (!isMobile)
                          Row(
                            children: [
                              Expanded(
                                child: _buildFormField(
                                  'DNI',
                                  _dniController,
                                  (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingrese el DNI';
                                    }
                                    if (value.length != 8) {
                                      return 'El DNI debe tener 8 dígitos';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildFormField(
                                  'Primer Nombre',
                                  _primerNombreController,
                                  (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingrese el primer nombre';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildFormField(
                                  'Segundo Nombre',
                                  _segundoNombreController,
                                  (value) => null, // Opcional
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildFormField(
                                'DNI',
                                _dniController,
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese el DNI';
                                  }
                                  if (value.length != 8) {
                                    return 'El DNI debe tener 8 dígitos';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                              ),
                              _buildFormField(
                                'Primer Nombre',
                                _primerNombreController,
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese el primer nombre';
                                  }
                                  return null;
                                },
                              ),
                              _buildFormField(
                                'Segundo Nombre',
                                _segundoNombreController,
                                (value) => null,
                              ),
                            ],
                          ),

                        // Fila 2: Apellidos
                        if (!isMobile)
                          Row(
                            children: [
                              Expanded(
                                child: _buildFormField(
                                  'Apellido Paterno',
                                  _apellidoPaternoController,
                                  (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingrese el apellido paterno';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildFormField(
                                  'Apellido Materno',
                                  _apellidoMaternoController,
                                  (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingrese el apellido materno';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildDateField(
                                  'Fecha Nacimiento',
                                  _fechaNacimientoController,
                                  () => _selectDate(
                                    context,
                                    _fechaNacimientoController,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildFormField(
                                'Apellido Paterno',
                                _apellidoPaternoController,
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese el apellido paterno';
                                  }
                                  return null;
                                },
                              ),
                              _buildFormField(
                                'Apellido Materno',
                                _apellidoMaternoController,
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese el apellido materno';
                                  }
                                  return null;
                                },
                              ),
                              _buildDateField(
                                'Fecha Nacimiento',
                                _fechaNacimientoController,
                                () => _selectDate(
                                  context,
                                  _fechaNacimientoController,
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 16),

                        // Información Laboral
                        _buildSectionTitle('INFORMACIÓN LABORAL'),
                        const SizedBox(height: 16),

                        // Fila 3: Cargo, Estado, Salario
                        if (!isMobile)
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdownField(
                                  'Cargo',
                                  _cargoValue,
                                  _cargoOptions,
                                  (value) {
                                    setState(() {
                                      _cargoValue = value;
                                    });
                                  },
                                  (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Seleccione el cargo';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
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
                                  (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Seleccione el estado';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildFormField(
                                  'Salario (S/)',
                                  _salarioController,
                                  (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingrese el salario';
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
                              _buildDropdownField(
                                'Cargo',
                                _cargoValue,
                                _cargoOptions,
                                (value) {
                                  setState(() {
                                    _cargoValue = value;
                                  });
                                },
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Seleccione el cargo';
                                  }
                                  return null;
                                },
                              ),
                              _buildDropdownField(
                                'Estado',
                                _estadoValue,
                                _estadoOptions,
                                (value) {
                                  setState(() {
                                    _estadoValue = value;
                                  });
                                },
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Seleccione el estado';
                                  }
                                  return null;
                                },
                              ),
                              _buildFormField(
                                'Salario (S/)',
                                _salarioController,
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese el salario';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),

                        // Fila 4: Email y Fechas
                        if (!isMobile)
                          Row(
                            children: [
                              Expanded(
                                child: _buildFormField(
                                  'Email',
                                  _emailController,
                                  (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingrese el email';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Ingrese un email válido';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildDateField(
                                  'Fecha Ingreso',
                                  _fechaIngresoController,
                                  () => _selectDate(
                                    context,
                                    _fechaIngresoController,
                                  ),
                                  isRequired: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildDateField(
                                  'Fecha Salida',
                                  _fechaSalidaController,
                                  () => _selectDate(
                                    context,
                                    _fechaSalidaController,
                                  ),
                                  isRequired: false,
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildFormField(
                                'Email',
                                _emailController,
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese el email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Ingrese un email válido';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.emailAddress,
                              ),
                              _buildDateField(
                                'Fecha Ingreso',
                                _fechaIngresoController,
                                () => _selectDate(
                                  context,
                                  _fechaIngresoController,
                                ),
                                isRequired: true,
                              ),
                              _buildDateField(
                                'Fecha Salida',
                                _fechaSalidaController,
                                () => _selectDate(
                                  context,
                                  _fechaSalidaController,
                                ),
                                isRequired: false,
                              ),
                            ],
                          ),

                        const SizedBox(height: 24),

                        // SECCIÓN DE TELÉFONOS
                        _buildSectionTitle('TELÉFONOS (Máximo 3)'),
                        const SizedBox(height: 16),

                        ...List.generate(_telefonoControllers.length, (index) {
                          return _buildTelefonoRow(index, isMobile);
                        }),

                        // Botón agregar teléfono
                        if (_telefonoControllers.length < 3)
                          Container(
                            width: double.infinity,
                            height: 40,
                            margin: const EdgeInsets.only(top: 8),
                            child: OutlinedButton(
                              onPressed: _agregarTelefono,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF303366),
                                side: const BorderSide(
                                  color: Color(0xFF303366),
                                ),
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

                        const SizedBox(height: 24),

                        // SECCIÓN CONDICIONAL: INFORMACIÓN DE CONDUCTOR
                        if (_cargoValue == 'Conductor') ...[
                          _buildSectionTitle('INFORMACIÓN DE CONDUCTOR'),
                          const SizedBox(height: 16),

                          // Fila 5: Licencia
                          if (!isMobile)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFormField(
                                    'Número Licencia',
                                    _numeroLicenciaController,
                                    (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ingrese el número de licencia';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDropdownField(
                                    'Clase Licencia',
                                    _claseLicenciaController.text.isEmpty
                                        ? null
                                        : _claseLicenciaController.text,
                                    _claseLicenciaOptions,
                                    (value) {
                                      setState(() {
                                        _claseLicenciaController.text =
                                            value ?? '';
                                      });
                                    },
                                    (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Seleccione la clase';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDropdownField(
                                    'Categoría Licencia',
                                    _categoriaLicenciaController.text.isEmpty
                                        ? null
                                        : _categoriaLicenciaController.text,
                                    _categoriaLicenciaOptions,
                                    (value) {
                                      setState(() {
                                        _categoriaLicenciaController.text =
                                            value ?? '';
                                      });
                                    },
                                    (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Seleccione la categoría';
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
                                  'Número Licencia',
                                  _numeroLicenciaController,
                                  (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingrese el número de licencia';
                                    }
                                    return null;
                                  },
                                ),
                                _buildDropdownField(
                                  'Clase Licencia',
                                  _claseLicenciaController.text.isEmpty
                                      ? null
                                      : _claseLicenciaController.text,
                                  _claseLicenciaOptions,
                                  (value) {
                                    setState(() {
                                      _claseLicenciaController.text =
                                          value ?? '';
                                    });
                                  },
                                  (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Seleccione la clase';
                                    }
                                    return null;
                                  },
                                ),
                                _buildDropdownField(
                                  'Categoría Licencia',
                                  _categoriaLicenciaController.text.isEmpty
                                      ? null
                                      : _categoriaLicenciaController.text,
                                  _categoriaLicenciaOptions,
                                  (value) {
                                    setState(() {
                                      _categoriaLicenciaController.text =
                                          value ?? '';
                                    });
                                  },
                                  (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Seleccione la categoría';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),

                          // Fila 6: Fechas Licencia
                          if (!isMobile)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDateField(
                                    'Fecha Registro Licencia',
                                    _fechaRegistroLicenciaController,
                                    () => _selectDate(
                                      context,
                                      _fechaRegistroLicenciaController,
                                    ),
                                    isRequired: true,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDateField(
                                    'Fecha Vencimiento Licencia',
                                    _fechaVencimientoLicenciaController,
                                    () => _selectDate(
                                      context,
                                      _fechaVencimientoLicenciaController,
                                    ),
                                    isRequired: true,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: SizedBox(),
                                ), // Espacio vacío
                              ],
                            )
                          else
                            Column(
                              children: [
                                _buildDateField(
                                  'Fecha Registro Licencia',
                                  _fechaRegistroLicenciaController,
                                  () => _selectDate(
                                    context,
                                    _fechaRegistroLicenciaController,
                                  ),
                                  isRequired: true,
                                ),
                                _buildDateField(
                                  'Fecha Vencimiento Licencia',
                                  _fechaVencimientoLicenciaController,
                                  () => _selectDate(
                                    context,
                                    _fechaVencimientoLicenciaController,
                                  ),
                                  isRequired: true,
                                ),
                              ],
                            ),
                        ],

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
    VoidCallback onTap, { // CAMBIADO: Ahora es VoidCallback
    bool isRequired = false,
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
          onTap: onTap, // Ahora recibe directamente el callback
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
                    controller.text.isEmpty
                        ? 'Seleccionar fecha'
                        : controller.text,
                    style: TextStyle(
                      color: controller.text.isEmpty
                          ? Colors.grey
                          : Colors.black,
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
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTelefonoRow(int index, bool isMobile) {
    return Column(
      children: [
        if (index > 0) const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tipo y uso del teléfono
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tipo y Uso',
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
                      child: DropdownButton<TipoTelefonoModel?>(
                        value: _telefonoTipos[index],
                        isExpanded: true,
                        hint: const Text(
                          'Seleccione tipo y uso',
                          style: TextStyle(fontSize: 12),
                        ),
                        items: _tiposTelefonoList.map((TipoTelefonoModel tipo) {
                          return DropdownMenuItem<TipoTelefonoModel>(
                            value: tipo,
                            child: Text(
                              tipo.displayText,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                        onChanged: (TipoTelefonoModel? value) {
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
                    child: Icon(Icons.delete, color: Colors.red[700], size: 18),
                  ),
                ),
              ),
          ],
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
