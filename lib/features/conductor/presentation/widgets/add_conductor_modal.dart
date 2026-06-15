//Ruta: lib/features/conductor/presentation/widgets/add_conductor_modal.dart
import 'dart:convert';
import 'package:app_jht_front/features/conductor/data/models/persona_actualizar_response.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_event.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:app_jht_front/core/utils/token_service.dart';
import 'package:app_jht_front/features/conductor/presentation/bloc/conductor_bloc.dart';
import 'package:app_jht_front/features/conductor/data/models/conductor_registro_dto.dart';
import 'package:app_jht_front/features/supplier/data/models/tipo_telefono_model.dart';
import 'package:app_jht_front/features/config/environment_config.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

// ── Color tokens ──────────────────────────────────────────────────────────────
const _primary = Color(0xFF303366);
const _primaryLt = Color(0xFFEEEFF6);
const _border = Color(0xFFD1D5DB);
const _surface = Color(0xFFF8F9FC);
const _textPri = Color(0xFF1A1A2E);
const _textSec = Color(0xFF6B7280);
const _green = Color(0xFF16A34A);
const _greenBg = Color(0xFFDCFCE7);
const _yellow = Color(0xFFD97706);
const _yellowBg = Color(0xFFFEF3C7);
const _red = Color(0xFFDC2626);
const _redBg = Color(0xFFFEE2E2);
const _blue = Color(0xFF2563EB);
const _blueBg = Color(0xFFDBEAFE);

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
  // Usamos int para el id del tipo (evita IdentityMap en Flutter Web)
  final List<int?> _telefonoTitIds = [null];

  // Variables para dropdowns
  String? _estadoValue;
  String? _cargoValue;

  // DNI duplicado y error inline
  bool _dniDuplicado = false;
  String? _dniError; // mensaje de error inline bajo el campo DNI

  // Email suggestions
  bool _showEmailSuggestions = false;
  final List<String> _emailDomains = [
    'gmail.com',
    'hotmail.com',
    'outlook.com',
    'yahoo.com',
    'empresa.pe',
    'jht.pe',
  ];
  List<String> _emailSuggestions = [];

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
      debugPrint('🟡 Cargando tipos de teléfono...');

      final String? token = await TokenService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación.');
      }

      // ✅ Usando EnvironmentConfig para centralizar la URL
      final response = await http.get(
        Uri.parse(
          '${EnvironmentConfig.baseUrl}/api/admin/consulta_tipo_telefono',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      );

      debugPrint('🟡 Response status tipos teléfono: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'] as List;
        final tipos = data
            .map((item) => TipoTelefonoModel.fromJson(item))
            .toList();

        setState(() {
          _tiposTelefonoList = tipos;
        });
        debugPrint('🟢 Tipos de teléfono cargados: ${tipos.length}');
      } else {
        throw Exception(
          'Error al obtener tipos de teléfono: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('❌ ERROR al cargar tipos de teléfono: $e');
      if (mounted)
        setState(() {
          _tiposTelefonoList = [
            TipoTelefonoModel(id: 1, tipo: 'Celular', uso: 'Personal'),
            TipoTelefonoModel(id: 2, tipo: 'Fijo', uso: 'Oficina'),
            TipoTelefonoModel(id: 3, tipo: 'Celular', uso: 'WhatsApp'),
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
    debugPrint('🟡 Seleccionando fecha para: ${controller.hashCode}');

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
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
      setState(() {
        controller.text = _formatDate(picked);
      });
      debugPrint('🟢 Fecha seleccionada: $picked');
      debugPrint('🔵 Controller text actualizado: ${controller.text}');
    } else {
      debugPrint('🔴 No se seleccionó fecha');
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
                  isMobile: MediaQuery.sizeOf(context).width < 768,
                  text: 'CANCELAR',
                  backgroundColor: Colors.grey[300]!,
                  textColor: Colors.grey[700]!,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDialogButton(
                  isMobile: MediaQuery.sizeOf(context).width < 768,
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
              isMobile: MediaQuery.sizeOf(context).width < 768,
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
      return 'El DNI debe ser numérico y mayor que 0.';
    } else if (message.contains('Ocurrió un error al registrar')) {
      final partes = message.split(':');
      if (partes.length > 1) {
        return partes.last.trim();
      }
    }
    return message.replaceAll('Exception: ', '');
  }

  void _registrarConductor() {
    // ── Validar DNI (solo mostrar aviso inline, NO cerrar modal) ──────────────
    final dniText = _dniController.text.trim();

    if (dniText.isEmpty) {
      setState(() => _dniError = 'El DNI es requerido');
      _mostrarSnackBarError('Complete el campo DNI');
      return;
    }

    if (dniText.length != 8) {
      setState(() => _dniError = 'El DNI debe tener exactamente 8 dígitos');
      _mostrarSnackBarError('El DNI debe tener exactamente 8 dígitos');
      return;
    }

    final dni = int.tryParse(dniText);
    if (dni == null || dni <= 0) {
      setState(() => _dniError = 'El DNI debe ser un número mayor que 0');
      _mostrarSnackBarError('El DNI debe ser un número válido mayor que 0');
      return;
    }

    // DNI OK → limpiar error inline
    setState(() => _dniError = null);

    // ── Validar DNI duplicado ─────────────────────────────────────────────────
    if (_dniDuplicado) {
      setState(() => _dniError = 'Este DNI ya está registrado');
      _mostrarSnackBarError('El DNI ${_dniController.text} ya está registrado.');
      return;
    }

    // ── Validar teléfonos ─────────────────────────────────────────────────────
    for (int i = 0; i < _telefonoControllers.length; i++) {
      if (_telefonoTitIds[i] == null) {
        _mostrarSnackBarError(
            'Seleccione el tipo y uso para el teléfono ${i + 1}');
        return;
      }
    }

    // ── Validar cargo ─────────────────────────────────────────────────────────
    if (_cargoValue == null) {
      _mostrarSnackBarError('Seleccione el cargo del colaborador');
      return;
    }

    // ── Validar fechas (campos InkWell, ignorados por Form.validate) ──────────
    if (_fechaIngresoController.text.isEmpty) {
      _mostrarSnackBarError('La fecha de ingreso es requerida.');
      return;
    }
    if (_cargoValue == 'Conductor') {
      if (_fechaRegistroLicenciaController.text.isEmpty) {
        _mostrarSnackBarError('La fecha de registro de licencia es requerida.');
        return;
      }
      if (_fechaVencimientoLicenciaController.text.isEmpty) {
        _mostrarSnackBarError(
            'La fecha de vencimiento de licencia es requerida.');
        return;
      }
    }

    // ── Validar salario ───────────────────────────────────────────────────────
    final salarioText = _salarioController.text.trim();
    final salarioValue = double.tryParse(salarioText);
    if (salarioValue == null || salarioValue < 0) {
      _mostrarSnackBarError(
          'El salario debe ser un número válido mayor o igual a 0.');
      return;
    }

    // ── Construir y enviar DTO ────────────────────────────────────────────────
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
        salario: salarioValue,
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

      // Crear lista de teléfonos DTO (usar _telefonoTitIds para evitar IdentityMap)
      final telefonos = List<TelefonoConductorDto>.generate(
        _telefonoControllers.length,
        (i) => TelefonoConductorDto(
          numero: _telefonoControllers[i].text.trim(),
          tipoId: _telefonoTitIds[i] ?? 1,
        ),
      );

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

  // ── Inline snackbar (no cierra el modal) ────────────────────────────────────
  void _mostrarSnackBarError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFC62828),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
        content: Row(children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
              child: Text(message,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500))),
        ]),
      ),
    );
  }

  // ── DNI helpers ──────────────────────────────────────────────────────────
  void _onDniChanged(String v) {
    final dup = _getPersonasActuales().any((p) => p.dni.toString() == v);
    // Limpiar error inline cuando el usuario corrige el campo
    setState(() {
      _dniDuplicado = dup;
      // Si el usuario escribe y tiene 8 dígitos → limpiar el error
      if (v.length == 8) _dniError = null;
    });
  }

  List<dynamic> _getPersonasActuales() {
    final s = context.read<ConductorBloc>().state;
    return s.maybeWhen(personasCargadas: (list) => list, orElse: () => []);
  }

  // ── Email helpers ──────────────────────────────────────────────────────────
  void _onEmailChanged(String v) {
    if (v.contains('@')) {
      final parts = v.split('@');
      final domain = parts.last.toLowerCase();
      final sugs = domain.isEmpty
          ? _emailDomains.map((d) => '${parts.first}@$d').toList()
          : _emailDomains
                .where((d) => d.startsWith(domain))
                .map((d) => '${parts.first}@$d')
                .toList();
      setState(() {
        _emailSuggestions = sugs;
        _showEmailSuggestions = sugs.isNotEmpty;
      });
    } else {
      setState(() {
        _emailSuggestions = [];
        _showEmailSuggestions = false;
      });
    }
  }

  void _agregarTelefono() {
    if (_telefonoControllers.length < 3) {
      setState(() {
        _telefonoControllers.add(TextEditingController());
        _telefonoTitIds.add(null);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _yellow,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Máximo 3 teléfonos permitidos',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _eliminarTelefono(int index) {
    if (_telefonoControllers.length > 1) {
      setState(() {
        _telefonoControllers[index].dispose();
        _telefonoControllers.removeAt(index);
        _telefonoTitIds.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 768;

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
        surfaceTintColor: Colors.white,
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 800,
            maxHeight: MediaQuery.sizeOf(context).height * 0.95,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- CABECERA ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.badge_outlined,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'AGREGAR COLABORADOR',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Complete todos los campos requeridos',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // --- FORMULARIO ---
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    child: Form(
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
                                child: _buildDniField(),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildPrimerNombreField(),
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
                              _buildDniField(),
                              _buildPrimerNombreField(),
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
                                child: _buildEmailField(),
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
                              _buildEmailField(),
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

                        SizedBox(height: isMobile ? 16 : 32),

                        // Botones
                        Row(
                          children: [
                            Expanded(
                              child: _buildButton(
                                isMobile: isMobile,
                                text: 'CANCELAR',
                                backgroundColor: Colors.grey[300]!,
                                textColor: Colors.grey[700]!,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: _yellow,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      content: const Row(
                                        children: [
                                          Icon(Icons.info_outline,
                                              color: Colors.white, size: 18),
                                          SizedBox(width: 8),
                                          Text(
                                            'No se registró colaborador',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildButton(
                                isMobile: isMobile,
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section title ──────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 12),
        child: Row(children: [
          const Icon(Icons.chevron_right, size: 18, color: _primary),
          const SizedBox(width: 6),
          Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                  letterSpacing: 0.6)),
          const SizedBox(width: 10),
          const Expanded(child: Divider(color: _border)),
        ]),
      );

  // ── Generic text field ─────────────────────────────────────────────────────
  Widget _buildFormField(
    String label,
    TextEditingController controller,
    String? Function(String?) validator, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
    String? hintText,
    void Function(String)? onChanged,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: _textPri)),
      const SizedBox(height: 4),
      TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          isDense: true,
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 12, color: _textSec),
          suffixIcon: suffixIcon,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _red),
          ),
          errorStyle: const TextStyle(fontSize: 10, color: _red, height: 0.9),
        ),
      ),
      const SizedBox(height: 14),
    ]);
  }

  // ── DNI field with duplicate tooltip ──────────────────────────────────────
  Widget _buildDniField() {
    final dniLength = _dniController.text.length;
    
    // Calcular mensaje de estado de longitud
    String lengthMessage = '';
    Color lengthColor = _textSec;
    IconData lengthIcon = Icons.info_outline;

    if (dniLength > 0 && dniLength < 8) {
      lengthMessage = 'Faltan ${8 - dniLength} dígitos para DNI';
      lengthColor = _primary; // Color primario para progreso
    } else if (dniLength == 8) {
      lengthMessage = 'DNI válido (8 dígitos)';
      lengthColor = const Color(0xFF4CAF50); // Verde para éxito
      lengthIcon = Icons.check_circle_outline;
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('DNI *',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: _textPri)),
        const SizedBox(width: 4),
        Tooltip(
          message: 'DNI peruano: 8 dígitos',
          triggerMode: TooltipTriggerMode.tap,
          child: const Icon(Icons.info_outline, size: 13, color: _textSec),
        ),
      ]),
      const SizedBox(height: 4),
      TextFormField(
        controller: _dniController,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 13),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(8),
        ],
        onChanged: _onDniChanged,
        decoration: InputDecoration(
          isDense: true,
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          hintText: '12345678',
          hintStyle: const TextStyle(fontSize: 12, color: _textSec),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: _dniError != null
                    ? _red
                    : _dniDuplicado
                        ? _yellow
                        : _border,
                width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: _dniError != null
                    ? _red
                    : _dniDuplicado
                        ? _yellow
                        : _primary,
                width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _red),
          ),
          errorStyle: const TextStyle(fontSize: 10, color: _red, height: 0.9),
          suffixIcon: _dniError != null
              ? const Icon(Icons.cancel_outlined, color: _red, size: 18)
              : _dniDuplicado
                  ? Tooltip(
                      message: '⚠️ Este DNI ya está registrado',
                      triggerMode: TooltipTriggerMode.tap,
                      decoration: BoxDecoration(
                        color: _yellowBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _yellow),
                      ),
                      textStyle:
                          const TextStyle(color: _yellow, fontSize: 12),
                      child: const Icon(Icons.warning_amber_rounded,
                          color: _yellow, size: 18),
                    )
                  : (dniLength == 8)
                      ? const Icon(Icons.check_circle_outline,
                          color: Color(0xFF4CAF50), size: 18)
                      : null,
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Obligatorio';
          if (v.length != 8) return 'Debe tener exactamente 8 dígitos';
          if (_dniDuplicado) return 'DNI ya registrado';
          return null;
        },
      ),
      // ── Mensajes inline (prioridad: error > duplicado > progreso) ────────────
      if (_dniError != null)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(children: [
            const Icon(Icons.cancel_outlined, size: 12, color: _red),
            const SizedBox(width: 4),
            Expanded(
              child: Text(_dniError!,
                  style: const TextStyle(
                      fontSize: 11,
                      color: _red,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
        )
      else if (_dniDuplicado)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(children: const [
            Icon(Icons.warning_amber_rounded, size: 12, color: _yellow),
            SizedBox(width: 4),
            Text('DNI ya registrado',
                style: TextStyle(
                    fontSize: 11,
                    color: _yellow,
                    fontWeight: FontWeight.w600)),
          ]),
        )
      else if (lengthMessage.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(children: [
            Icon(lengthIcon, size: 12, color: lengthColor),
            const SizedBox(width: 4),
            Text(lengthMessage,
                style: TextStyle(
                    fontSize: 11,
                    color: lengthColor,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      const SizedBox(height: 14),
    ]);
  }

  // ── Primer Nombre field with min 4 chars tooltip ──────────────────────────
  Widget _buildPrimerNombreField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('Primer Nombre *',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: _textPri)),
        const SizedBox(width: 4),
        Tooltip(
          message: 'Mínimo 4 caracteres requeridos\npor seguridad en la creación de cuenta',
          triggerMode: TooltipTriggerMode.tap,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(color: Colors.white, fontSize: 11),
          child: const Icon(Icons.info_outline, size: 13, color: _textSec),
        ),
      ]),
      const SizedBox(height: 4),
      TextFormField(
        controller: _primerNombreController,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Ej: Juan (mín. 4 caracteres)',
          hintStyle: const TextStyle(fontSize: 12, color: _textSec),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _red),
          ),
          errorStyle: const TextStyle(fontSize: 10, color: _red, height: 0.9),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Ingrese el primer nombre';
          }
          if (value.trim().length < 4) {
            // Mostrar AlertDialog de seguridad después del frame actual
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _mostrarAlertaNombreCorto(value.trim());
            });
            return 'Mínimo 4 caracteres requeridos';
          }
          return null;
        },
      ),
      const SizedBox(height: 14),
    ]);
  }

  // ── AlertDialog: Nombre demasiado corto ────────────────────────────────────
  void _mostrarAlertaNombreCorto(String nombre) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _yellowBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.security, color: _yellow, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Nombre muy corto',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF303366),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: _textPri, height: 1.5),
                children: [
                  const TextSpan(
                    text: 'El nombre "',
                  ),
                  TextSpan(
                    text: nombre,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: _red),
                  ),
                  TextSpan(
                    text: '" tiene solo ${nombre.length} ${nombre.length == 1 ? 'carácter' : 'caracteres'}.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _yellowBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _yellow.withOpacity(0.3)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: _yellow, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Por seguridad en la creación de la cuenta del colaborador, el primer nombre debe tener al menos 4 caracteres.',
                      style: TextStyle(fontSize: 12, color: _textPri, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: _buildDialogButton(
              isMobile: MediaQuery.of(ctx).size.width < 768,
              text: 'ENTENDIDO',
              backgroundColor: const Color(0xFF303366),
              textColor: Colors.white,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Email field with @domain suggestions ──────────────────────────────────
  Widget _buildEmailField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Correo electrónico *',
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: _textPri)),
      const SizedBox(height: 4),
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(fontSize: 13),
        onChanged: _onEmailChanged,
        onFieldSubmitted: (_) =>
            setState(() => _showEmailSuggestions = false),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          hintText: 'usuario@gmail.com',
          hintStyle: const TextStyle(fontSize: 12, color: _textSec),
          prefixIcon: const Icon(Icons.email_outlined,
              size: 16, color: _textSec),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _red),
          ),
          errorStyle:
              const TextStyle(fontSize: 10, color: _red, height: 0.9),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Obligatorio';
          if (!v.contains('@') || !v.contains('.'))
            return 'Correo inválido';
          return null;
        },
      ),
      // Suggestions dropdown
      if (_showEmailSuggestions && _emailSuggestions.isNotEmpty)
        Container(
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _primary.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            children: _emailSuggestions
                .take(4)
                .map((s) => InkWell(
                      onTap: () {
                        _emailController.text = s;
                        setState(() => _showEmailSuggestions = false);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(children: [
                          const Icon(Icons.alternate_email,
                              size: 13, color: _primary),
                          const SizedBox(width: 8),
                          Text(s,
                              style: const TextStyle(
                                  fontSize: 12, color: _textPri)),
                        ]),
                      ),
                    ))
                .toList(),
          ),
        ),
      const SizedBox(height: 14),
    ]);
  }

  // ── Date field ─────────────────────────────────────────────────────────────
  Widget _buildDateField(
    String label,
    TextEditingController controller,
    VoidCallback onTap, {
    bool isRequired = false,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: _textPri)),
      const SizedBox(height: 4),
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Row(children: [
            Expanded(
              child: Text(
                controller.text.isEmpty ? 'Seleccionar fecha' : controller.text,
                style: TextStyle(
                    fontSize: 13,
                    color: controller.text.isEmpty ? _textSec : _textPri),
              ),
            ),
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: _textSec),
          ]),
        ),
      ),
      if (isRequired && controller.text.isEmpty)
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text('Obligatorio',
              style: TextStyle(fontSize: 10, color: _red)),
        ),
      const SizedBox(height: 14),
    ]);
  }

  // ── Dropdown ───────────────────────────────────────────────────────────────
  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> items,
    void Function(String?) onChanged,
    String? Function(String?) validator,
  ) {
    final effective = items.contains(value) ? value : null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: _textPri)),
      const SizedBox(height: 4),
      DropdownButtonFormField<String>(
        value: effective,
        dropdownColor: Colors.white,
        style: const TextStyle(fontSize: 13, color: _textPri),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _red),
          ),
          errorStyle:
              const TextStyle(fontSize: 10, color: _red, height: 0.9),
        ),
        items: items
            .map((i) => DropdownMenuItem(
                value: i, child: Text(i, style: const TextStyle(fontSize: 13))))
            .toList(),
        onChanged: onChanged,
        validator: validator,
      ),
      const SizedBox(height: 14),
    ]);
  }

  // ── Teléfono row ──────────────────────────────────────────────────────────
  Widget _buildTelefonoRow(int index, bool isMobile) {
    final titId = _telefonoTitIds[index];
    final tipoSel = titId != null
        ? _tiposTelefonoList.firstWhere((t) => t.id == titId,
            orElse: () => _tiposTelefonoList.first)
        : null;
    final esFijo = tipoSel?.tipo.toLowerCase().contains('fijo') == true;
    final esMovil = tipoSel?.tipo.toLowerCase().contains('celular') == true ||
        tipoSel?.tipo.toLowerCase().contains('móvil') == true;
    final limitTxt = esFijo ? '7-9 dígitos' : '9-11 dígitos';
    final maxLen = esFijo ? 9 : 11;
    final numVal = _telefonoControllers[index].text;
    final tipoDetectado = _detectarTipoTel(numVal);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _primaryLt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _primary.withOpacity(0.15)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header row
          Row(children: [
            const Icon(Icons.phone, color: _primary, size: 15),
            const SizedBox(width: 6),
            Text('Teléfono ${index + 1}',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _primary)),
            const Spacer(),
            if (_telefonoControllers.length > 1)
              GestureDetector(
                onTap: () => _eliminarTelefono(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: _redBg,
                      borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.delete_outline,
                      color: _red, size: 15),
                ),
              ),
          ]),
          const SizedBox(height: 10),
          // Tipo + Numero responsive
          isMobile
              ? Column(children: [
                  _tipoDropTel(index, titId),
                  const SizedBox(height: 8),
                  _numFieldTel(
                      index, esFijo, esMovil, limitTxt, maxLen),
                ])
              : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: _tipoDropTel(index, titId)),
                  const SizedBox(width: 10),
                  Expanded(child: _numFieldTel(
                      index, esFijo, esMovil, limitTxt, maxLen)),
                ]),
          // Dynamic type badge
          if (tipoDetectado.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: tipoDetectado.contains('Móvil') ||
                        tipoDetectado.contains('Celular')
                    ? _greenBg
                    : _blueBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(tipoDetectado,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: tipoDetectado.contains('Móvil') ||
                            tipoDetectado.contains('Celular')
                        ? _green
                        : _blue,
                  )),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _tipoDropTel(int index, int? titId) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tipo y Uso *',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _textSec)),
          const SizedBox(height: 4),
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(
                  color: titId == null ? _yellow : _border),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: titId,
                isExpanded: true,
                dropdownColor: Colors.white,
                hint: const Text('Seleccione tipo',
                    style: TextStyle(fontSize: 12, color: _textSec)),
                items: _tiposTelefonoList
                    .map((t) => DropdownMenuItem<int>(
                          value: t.id,
                          child: Text(t.displayText,
                              style: const TextStyle(fontSize: 12)),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null)
                    setState(() => _telefonoTitIds[index] = v);
                },
              ),
            ),
          ),
          if (titId == null)
            const Padding(
              padding: EdgeInsets.only(top: 3),
              child: Text('Seleccione un tipo',
                  style: TextStyle(fontSize: 10, color: _yellow)),
            ),
        ],
      );

  Widget _numFieldTel(int index, bool esFijo, bool esMovil,
      String limitTxt, int maxLen) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('Número *',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _textSec)),
        const SizedBox(width: 4),
        Tooltip(
          message: 'Fijo Lima: 01XXXXXXX (7-9 dígitos)\n'
              'Celular: 9XXXXXXXX (9 dígitos)\n'
              'Con país Perú: 51XXXXXXXXX (11 dígitos)',
          triggerMode: TooltipTriggerMode.tap,
          child:
              const Icon(Icons.info_outline, size: 12, color: _textSec),
        ),
      ]),
      const SizedBox(height: 4),
      TextFormField(
        controller: _telefonoControllers[index],
        keyboardType: TextInputType.phone,
        style: const TextStyle(fontSize: 13),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(maxLen),
        ],
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          isDense: true,
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          hintText: limitTxt,
          hintStyle: const TextStyle(fontSize: 12, color: _textSec),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: _primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _red),
          ),
          errorStyle:
              const TextStyle(fontSize: 10, color: _red, height: 0.9),
        ),
        validator: (val) {
          if (val == null || val.isEmpty) return 'Obligatorio';
          final n = val.replaceAll(RegExp(r'\s+'), '');
          if (esFijo && (n.length < 7 || n.length > 9))
            return 'Fijo: 7 a 9 dígitos';
          if (esMovil && n.length != 9 && n.length != 11)
            return 'Móvil: 9 u 11 dígitos';
          return null;
        },
      ),
    ]);
  }

  String _detectarTipoTel(String numero) {
    final n = numero.replaceAll(RegExp(r'\s+'), '');
    if (n.isEmpty) return '';
    if (n.startsWith('51') && n.length == 11 && n[2] == '9')
      return '📱 Móvil (con código país)';
    if (n.startsWith('51') && n.length >= 10)
      return '📞 Fijo (con código país)';
    if (n.startsWith('9') && n.length == 9) return '📱 Celular / Móvil';
    if (n.length == 7 || (n.length == 9 && n.startsWith('0')))
      return '📞 Teléfono fijo';
    return '';
  }

  // ── Main button ────────────────────────────────────────────────────────────
  Widget _buildButton({
    required bool isMobile,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return SizedBox(
      height: isMobile ? 42 : 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
          ],
          Text(text,
              style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  // ── Dialog button ──────────────────────────────────────────────────────────
  Widget _buildDialogButton({
    required bool isMobile,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: isMobile ? 38 : 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text,
            style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

