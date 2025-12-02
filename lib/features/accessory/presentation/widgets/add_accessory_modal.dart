// lib/features/accessory/presentation/widgets/add_accessory_modal.dart
// DESCRIPTION: Modal para agregar un nuevo accesorio con campos dinámicos y validación.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/accessory/presentation/bloc/accessory_bloc.dart';
import 'package:app_jht_front/features/accessory/data/models/segmento_model.dart';
import 'package:app_jht_front/features/accessory/data/models/tipo_accesorio_model.dart';
import 'package:app_jht_front/features/accessory/data/models/vehiculo_model.dart';
import 'add_accessory_type_modal.dart';

// Añade esta importación
import 'package:app_jht_front/features/accessory/data/models/accesorio_registro_dto.dart';

class AddAccessoryModal extends StatefulWidget {
  final Function()? onAccessoryAdded;

  const AddAccessoryModal({super.key, this.onAccessoryAdded});

  @override
  State<AddAccessoryModal> createState() => _AddAccessoryModalState();
}

class _AddAccessoryModalState extends State<AddAccessoryModal> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los nuevos campos
  final _nombreAccesorioController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _marcaController = TextEditingController();
  final _codigoFabricanteController = TextEditingController();
  final _kilometrajeInstalacionController = TextEditingController();
  final _kilometrajeRetiroController = TextEditingController();
  final _observacionesController = TextEditingController();

  DateTime? _fechaInstalacion;
  DateTime? _fechaRetiro;
  String? _estadoValue;

  // VARIABLES ACTUALIZADAS: Usamos IDs en lugar de objetos completos
  int? _selectedSegmentoId;
  int? _selectedTipoAccesorioId;
  int? _selectedVehiculoId;

  // Objetos para referencia (opcional)
  SegmentoModel? _selectedSegmento;
  TipoAccesorioModel? _selectedTipoAccesorio;
  VehiculoModel? _selectedVehiculo;

  // CACHE para segmentos - SOLUCIÓN DEFINITIVA
  List<SegmentoModel> _segmentosCache = [];

  // Opciones para los dropdowns
  final List<String> _estadoOptions = ['Activo', 'Inactivo'];

  AccesorioRegistroDto? _ultimoDtoEnviado;

  @override
  void initState() {
    super.initState();
    print('🎯 INICIANDO MODAL - AddAccessoryModal');

    // Reset inmediato
    _resetForm();

    // Cargar datos con un pequeño delay para asegurar que el widget esté montado
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
    // 1. Validaciones básicas
    if (_fechaInstalacion == null) {
      _showErrorSnackbar('Seleccione fecha de instalación');
      return;
    }

    if (_marcaController.text.isEmpty) {
      _showErrorSnackbar('Ingrese la marca del accesorio');
      return;
    }

    if (_codigoFabricanteController.text.isEmpty) {
      _showErrorSnackbar('Ingrese el código de fabricante');
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

    if (_estadoValue == null || _estadoValue!.isEmpty) {
      _showErrorSnackbar('Seleccione el estado');
      return;
    }

    // 2. Crear DTO con los datos
    final dto = AccesorioRegistroDto(
      marca: _marcaController.text.trim(),
      codigoFabricante: _codigoFabricanteController.text.trim(),
      fechaInstalacion: _fechaInstalacion!,
      kilometrajeInstalacion:
          int.tryParse(_kilometrajeInstalacionController.text) ?? 0,
      estado: _estadoValue!,
      observacion: _observacionesController.text.trim(),
      vehiculoId: _selectedVehiculoId!,
      tipoAccesorioId: _selectedTipoAccesorioId!,
    );

    // 3. Mostrar datos para debug
    print('=== ENVIANDO ACCESORIO AL API ===');
    print('DTO completo: ${dto.toString()}');
    print('JSON a enviar: ${dto.toJson()}');
    print('Fecha formateada: ${_formatDateForDebug(_fechaInstalacion!)}');

    // 4. Enviar al Bloc (o directamente al API si no tienes Bloc)
    _enviarAlApi(dto);
  }

  // Método auxiliar para mostrar errores
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Método auxiliar para formatear fecha (solo debug)
  String _formatDateForDebug(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}";
  }

  // Método para enviar al API (temporal - mientras configuras Bloc)
  void _enviarAlApi(AccesorioRegistroDto dto) {
    // Enviar evento al Bloc
    context.read<AccessoryBloc>().add(RegistrarAccesorioEvent(dto: dto));

    _ultimoDtoEnviado = dto;


  }

  void _agregarTipoAccesorio() {
    showDialog(
      context: context,
      barrierDismissible: false,
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

  Future<void> _selectDateConHora(
    BuildContext context,
    bool isInstalacion,
  ) async {
    // Primero seleccionar fecha
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (pickedDate != null) {
      // Luego seleccionar hora
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(
          hour: 10,
          minute: 30,
        ), // 10:30 AM por defecto
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );

      // Combinar fecha y hora
      final DateTime fechaCompleta = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime?.hour ?? 10, // Si no selecciona hora, usar 10
        pickedTime?.minute ?? 30, // Si no selecciona minuto, usar 30
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

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return BlocListener<AccessoryBloc, AccessoryState>(
      listener: (context, state) {
        print('🎧 Listener Principal - Estado: ${state.runtimeType}');

        // ACTUALIZAR CACHE DE SEGMENTOS CUANDO SE CARGUEN
        if (state is SegmentosLoaded) {
          print(
            '💾 Actualizando cache de segmentos: ${state.segmentos.length}',
          );
          if (mounted) {
            setState(() {
              _segmentosCache = state.segmentos;
            });
          }
        }

        // ACTUALIZAR CACHE DE VEHÍCULOS CUANDO SE CARGUEN
        if (state is VehiculosLoaded) {
          print('🚗 Vehículos cargados: ${state.vehiculos.length}');
          // Forzar reconstrucción para mostrar vehículos
          if (mounted) {
            setState(() {});
          }
        }
        // MANEJAR RESULTADO DEL REGISTRO DE ACCESORIO
        if (state is AccesorioRegistrado) {
          Navigator.of(context).pop(); // Cerrar modal

          // Crear mensaje personalizado con el DTO guardado
          final mensaje = _ultimoDtoEnviado != null
              ? '✅ Accesorio "${_ultimoDtoEnviado!.marca}" '
                    '(Código: ${_ultimoDtoEnviado!.codigoFabricante}) '
                    'registrado exitosamente'
              : state.response.message; // Fallback al mensaje original

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mensaje),
              backgroundColor: const Color(0xFF303366),
              duration: const Duration(seconds: 5),
            ),
          );

          if (widget.onAccessoryAdded != null) {
            widget.onAccessoryAdded!();
          }

          // Limpiar la variable después de usarla
          _ultimoDtoEnviado = null;
        }

        if (state is RegistroError) {
          // Si hay un DTO guardado, personalizar mensaje de error
          final mensajeError = _ultimoDtoEnviado != null
              ? '❌ Error al registrar accesorio "${_ultimoDtoEnviado!.marca}" '
                    '(Código: ${_ultimoDtoEnviado!.codigoFabricante}): ${state.message}'
              : '❌ Error: ${state.message}';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mensajeError),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );

          // Limpiar la variable
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
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
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
                            Expanded(child: _buildSegmentoDropdown()),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTipoAccesorioDropdown(),
                                  _buildAddTypeButton(),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildSegmentoDropdown(),
                            _buildTipoAccesorioDropdown(),
                            _buildAddTypeButton(),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // Vehículo
                      _buildVehiculoDropdown(),

                      // Descripción (se autocompleta cuando se selecciona tipo accesorio)
                      _buildFormField(
                        'Descripción del Accesorio',
                        _descripcionController,
                        (value) => null,
                        maxLines: 2,
                      ),

                      // Segunda fila: Marca y Código de Fabricante
                      if (!isMobile)
                        Row(
                          children: [
                            Expanded(
                              child: _buildFormField(
                                'Marca de Accesorio',
                                _marcaController,
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
                              child: _buildFormField(
                                'Código de Fabricante',
                                _codigoFabricanteController,
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
                            _buildFormField(
                              'Marca de Accesorio',
                              _marcaController,
                              (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingrese la marca del accesorio';
                                }
                                return null;
                              },
                            ),
                            _buildFormField(
                              'Código de Fabricante',
                              _codigoFabricanteController,
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
                              child: _buildDateField(
                                'Fecha de Instalación',
                                _fechaInstalacion,
                                () => _selectDateConHora(context, true),
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildDateField(
                              'Fecha de Instalación',
                              _fechaInstalacion,
                              () => _selectDateConHora(context, true),
                            ),
                          ],
                        ),

                      // Cuarta fila: Kilometraje de Instalación y Retiro
                      if (!isMobile)
                        Row(
                          children: [
                            Expanded(
                              child: _buildFormField(
                                'Kilometraje de Instalación',
                                _kilometrajeInstalacionController,
                                (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingrese el kilometraje de instalación';
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
                              'Kilometraje de Instalación',
                              _kilometrajeInstalacionController,
                              (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingrese el kilometraje de instalación';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),

                      // Estado
                      _buildEstadoDropdown(),

                      // Observaciones
                      _buildFormField(
                        'Observaciones',
                        _observacionesController,
                        (value) => null,
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

  // ========== DROPDOWNS ACTUALIZADOS ==========

  Widget _buildSegmentoDropdown() {
    print(
      '🔨 Construyendo SegmentoDropdown - Cache: ${_segmentosCache.length}',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Segmento',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF303366),
          ),
        ),
        const SizedBox(height: 8),

        // SIMPLE Y DIRECTO - Usando el cache
        _segmentosCache.isEmpty
            ? _buildLoadingDropdown('Cargando segmentos...')
            : _buildSegmentosDropdown(_segmentosCache),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSegmentosDropdown(List<SegmentoModel> segmentos) {
    print('🎯 Construyendo dropdown con ${segmentos.length} segmentos');

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedSegmentoId,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          hint: const Text('Seleccione segmento'),
          items: [
            DropdownMenuItem<int>(
              value: null,
              child: Text(
                'Seleccione segmento',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ...segmentos.map((segmento) {
              return DropdownMenuItem<int>(
                value: segmento.id,
                child: Text(segmento.nombre),
              );
            }).toList(),
          ],
          onChanged: (int? newId) {
            print('🎯 Segmento seleccionado: $newId');
            setState(() {
              _selectedSegmentoId = newId;
              _selectedTipoAccesorioId = null;
              _selectedTipoAccesorio = null;
              _descripcionController.clear();
            });

            if (newId != null) {
              print('🚀 Cargando tipos de accesorio para segmento: $newId');
              context.read<AccessoryBloc>().add(
                LoadTiposAccesorioEvent(segmentoId: newId),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildTipoAccesorioDropdown() {
    return BlocBuilder<AccessoryBloc, AccessoryState>(
      buildWhen: (previous, current) {
        // Solo reconstruir cuando cambien los tipos de accesorio
        return current is TiposAccesorioLoaded || current is AccessoryLoading;
      },
      builder: (context, state) {
        print('🔨 Builder TipoAccesorio - Estado: ${state.runtimeType}');

        List<TipoAccesorioModel> tiposAccesorio = [];
        bool isLoading = false;
        bool hasData = false;

        if (state is TiposAccesorioLoaded) {
          tiposAccesorio = state.tiposAccesorio;
          hasData = true;
          print('✅ Tipos accesorio cargados: ${tiposAccesorio.length}');
        } else if (state is AccessoryLoading) {
          isLoading = true;
          print('⏳ Cargando tipos de accesorio...');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nombre de Accesorio',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF303366),
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedTipoAccesorioId,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  hint: Text(
                    _selectedSegmentoId == null
                        ? 'Primero seleccione un segmento'
                        : (isLoading
                              ? 'Cargando...'
                              : 'Seleccione tipo de accesorio'),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  items: hasData
                      ? [
                          DropdownMenuItem<int>(
                            value: null,
                            child: Text(
                              'Seleccione tipo de accesorio',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          ...tiposAccesorio.map((tipo) {
                            return DropdownMenuItem<int>(
                              value: tipo.id,
                              child: Text(tipo.nombre),
                            );
                          }).toList(),
                        ]
                      : null,
                  onChanged:
                      (_selectedSegmentoId == null || isLoading || !hasData)
                      ? null
                      : (int? newId) {
                          print('🎯 Tipo accesorio seleccionado: $newId');

                          final selectedTipo = newId != null
                              ? tiposAccesorio.firstWhere(
                                  (t) => t.id == newId,
                                  orElse: () => TipoAccesorioModel(
                                    id: newId,
                                    nombre: 'Tipo $newId',
                                    descripcion: '',
                                  ),
                                )
                              : null;

                          setState(() {
                            _selectedTipoAccesorioId = newId;
                            _selectedTipoAccesorio = selectedTipo;
                            if (selectedTipo != null) {
                              _descripcionController.text =
                                  selectedTipo.descripcion;
                            } else {
                              _descripcionController.clear();
                            }
                          });
                        },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVehiculoDropdown() {
    return BlocListener<AccessoryBloc, AccessoryState>(
      listener: (context, state) {
        print('🎧 Listener Vehículo - Estado: ${state.runtimeType}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vehículo',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF303366),
            ),
          ),
          const SizedBox(height: 8),
          _buildVehiculosDropdownFromBloc(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildVehiculosDropdownFromBloc() {
    return BlocBuilder<AccessoryBloc, AccessoryState>(
      buildWhen: (previous, current) {
        // Reconstruir cuando cambien los vehículos o haya error
        return current is VehiculosLoaded ||
            current is AccessoryError ||
            current is AccessoryLoading;
      },
      builder: (context, state) {
        print('🚗 Builder Vehículos - Estado: ${state.runtimeType}');

        List<VehiculoModel> vehiculos = [];
        bool isLoading = false;

        if (state is VehiculosLoaded) {
          vehiculos = state.vehiculos;
          print('✅ Vehículos cargados: ${vehiculos.length}');
        } else if (state is AccessoryLoading) {
          isLoading = true;
          print('⏳ Cargando vehículos...');
        } else if (state is AccessoryError) {
          print('❌ Error cargando vehículos: ${state.message}');
        }

        // Si está cargando y no hay vehículos
        if (isLoading && vehiculos.isEmpty) {
          return _buildLoadingDropdown('Cargando vehículos...');
        }

        // Si hay error y no hay vehículos
        if (state is AccessoryError && vehiculos.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.error, color: Colors.red, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error: ${state.message}',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.read<AccessoryBloc>().add(LoadVehiculosEvent());
                  },
                  child: Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        // Dropdown normal con vehículos
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedVehiculoId,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              hint: const Text('Seleccione vehículo'),
              items: [
                DropdownMenuItem<int>(
                  value: null,
                  child: Text(
                    'Seleccione vehículo',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ...vehiculos.map((vehiculo) {
                  return DropdownMenuItem<int>(
                    value: vehiculo.id,
                    child: Text(
                      '${vehiculo.placa} (${vehiculo.kilometraje} km)',
                    ),
                  );
                }).toList(),
              ],
              onChanged: (int? newId) {
                print('🎯 Vehículo seleccionado: $newId');

                final selectedVehiculo = newId != null
                    ? vehiculos.firstWhere(
                        (v) => v.id == newId,
                        orElse: () => VehiculoModel(
                          id: newId,
                          placa: 'Vehículo $newId',
                          kilometraje: 0,
                        ),
                      )
                    : null;

                setState(() {
                  _selectedVehiculoId = newId;
                  _selectedVehiculo = selectedVehiculo;
                });
              },
            ),
          ),
        );
      },
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

  // ========== MÉTODOS AUXILIARES ==========

  Widget _buildLoadingDropdown(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(message, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(width: 8),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 16),
            SizedBox(width: 8),
            Text(
              'AGREGAR TIPO ACCESORIO',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF303366)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Color(0xFF303366),
                ),
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
