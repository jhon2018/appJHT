import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:app_jht_front/core/utils/token_service.dart';
import 'package:app_jht_front/features/accessory/presentation/bloc/accessory_bloc.dart';
import 'package:app_jht_front/features/accessory/data/models/segmento_model.dart';
import 'package:app_jht_front/features/accessory/data/models/tipo_accesorio_registro_dto.dart';
import 'package:app_jht_front/features/config/environment_config.dart';


class AddAccessoryTypeModal extends StatefulWidget {
  final Function()? onAccessoryTypeAdded;

  const AddAccessoryTypeModal({super.key, this.onAccessoryTypeAdded});

  @override
  State<AddAccessoryTypeModal> createState() => _AddAccessoryTypeModalState();
}

class _AddAccessoryTypeModalState extends State<AddAccessoryTypeModal> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para campos principales
  final _nombreController = TextEditingController();
  final _unidadMedidaController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _descripcionSegController = TextEditingController();
  final _descripcionAccesorioController = TextEditingController();

  // Controladores para diccionarios
  final List<TextEditingController> _diccionarioNombreControllers = [TextEditingController()];
  final List<TextEditingController> _diccionarioDescripcionControllers = [TextEditingController()];
  final List<TextEditingController> _diccionarioTipoControllers = [TextEditingController()];
  final List<TextEditingController> _frecuenciaKmControllers = [TextEditingController()];
  final List<TextEditingController> _frecuenciaTiempoControllers = [TextEditingController()];
  final List<String?> _diccionarioEstados = ['Activo'];

  // Variables para dropdowns
  SegmentoModel? _segmentoSeleccionado;
  
  // Listas
  List<SegmentoModel> _segmentosList = [];
  bool _cargandoSegmentos = false;

  // Opciones
  final List<String> _estadoOptions = ['Activo', 'Inactivo'];
  final List<String> _tipoManOptions = ['Preventivo', 'Correctivo', 'Predictivo'];

  @override
  void initState() {
    super.initState();
    // Agregar un mantenimiento inicial vacío
    _diccionarioNombreControllers[0].text = '';
    _diccionarioDescripcionControllers[0].text = '';
    _diccionarioTipoControllers[0].text = '';
    _frecuenciaKmControllers[0].text = '';
    _frecuenciaTiempoControllers[0].text = '';
  }

  Future<void> _cargarSegmentos() async {
    if (_cargandoSegmentos) return;
    
    setState(() {
      _cargandoSegmentos = true;
    });

    try {
      print('🟡 Cargando segmentos...');
            
            final String? token = await TokenService.getToken();
            
            if (token == null || token.isEmpty) {
              throw Exception('No hay token de autenticación.');
            }

            // ✅ Eliminada la función local getBaseUrl() para usar la centralizada
            final response = await http.get(
              Uri.parse('${EnvironmentConfig.baseUrl}/api/admin/listar_segmento_accesorio'),
              headers: {
                'Authorization': 'Bearer $token',
                'accept': 'application/json',
              },
            );

            print('🟡 Response status segmentos: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'] as List;
        final segmentos = data.map((item) => SegmentoModel.fromJson(item)).toList();
        
        setState(() {
          _segmentosList = segmentos;
          _cargandoSegmentos = false;
        });
        print('🟢 Segmentos cargados: ${segmentos.length}');
      } else {
        throw Exception('Error al obtener segmentos: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR al cargar segmentos: $e');
      setState(() {
        _segmentosList = [];
        _cargandoSegmentos = false;
      });
      
      // Mostrar error al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar segmentos: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _mostrarModalSegmentos() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar Segmento'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: _segmentosList.isEmpty && !_cargandoSegmentos
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No hay segmentos disponibles'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _cargarSegmentos,
                          child: const Text('Cargar Segmentos'),
                        ),
                      ],
                    ),
                  )
                : _cargandoSegmentos
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _segmentosList.length,
                        itemBuilder: (context, index) {
                          final segmento = _segmentosList[index];
                          return ListTile(
                            title: Text(segmento.nombre),
                            subtitle: Text(
                              segmento.definicion.length > 100
                                  ? '${segmento.definicion.substring(0, 100)}...'
                                  : segmento.definicion,
                            ),
                            onTap: () {
                              setState(() {
                                _segmentoSeleccionado = segmento;
                                _descripcionSegController.text = segmento.definicion;
                              });
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
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
          '¿Está seguro de registrar el tipo de accesorio "${_nombreController.text}"?',
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
    if (_segmentoSeleccionado == null) {
      _mostrarErrorDialog('Debe seleccionar un segmento');
      return;
    }

    // Validar campos requeridos
    if (_nombreController.text.isEmpty) {
      _mostrarErrorDialog('El nombre del accesorio es requerido');
      return;
    }

    if (_unidadMedidaController.text.isEmpty) {
      _mostrarErrorDialog('La unidad de medida es requerida');
      return;
    }

    if (_cantidadController.text.isEmpty) {
      _mostrarErrorDialog('La cantidad es requerida');
      return;
    }

    if (_descripcionAccesorioController.text.isEmpty) {
      _mostrarErrorDialog('La descripción del accesorio es requerida');
      return;
    }

    // Validar diccionarios
    for (int i = 0; i < _diccionarioNombreControllers.length; i++) {
      if (_diccionarioNombreControllers[i].text.isEmpty) {
        _mostrarErrorDialog('El nombre del mantenimiento ${i + 1} es requerido');
        return;
      }
      if (_diccionarioTipoControllers[i].text.isEmpty) {
        _mostrarErrorDialog('El tipo del mantenimiento ${i + 1} es requerido');
        return;
      }
      if (_frecuenciaKmControllers[i].text.isEmpty) {
        _mostrarErrorDialog('La frecuencia en km del mantenimiento ${i + 1} es requerida');
        return;
      }
      if (_frecuenciaTiempoControllers[i].text.isEmpty) {
        _mostrarErrorDialog('La frecuencia en tiempo del mantenimiento ${i + 1} es requerida');
        return;
      }
    }

    try {
      // Crear DTO de tipo de accesorio
      final tipoAccesorio = TipoAccesorioRegistro(
        tipVnombre: _nombreController.text,
        tipVunidadMedida: _unidadMedidaController.text,
        tipIcantidad: int.parse(_cantidadController.text),
        tipVdescripcion: _descripcionAccesorioController.text,
        segIid: _segmentoSeleccionado!.id,
      );

      // Crear lista de diccionarios
      final diccionarios = List.generate(_diccionarioNombreControllers.length, (index) {
        return DiccionarioDto(
          dicVnombre: _diccionarioNombreControllers[index].text,
          dicVdescripcion: _diccionarioDescripcionControllers[index].text,
          dicVtipo: _diccionarioTipoControllers[index].text,
          dicIfrecuenciaKilometros: int.parse(_frecuenciaKmControllers[index].text),
          dicIfrecuenciaTiempo: int.parse(_frecuenciaTiempoControllers[index].text),
          dicVestado: _diccionarioEstados[index] ?? 'Activo',
        );
      });

      // Crear DTO principal
      final dto = TipoAccesorioRegistroDto(
        tipoAccesorio: tipoAccesorio,
        diccionarios: diccionarios,
      );

      print('🟡 DTO a enviar: ${json.encode(dto.toJson())}');

      // Obtener el bloc y registrar
      final bloc = BlocProvider.of<AccessoryBloc>(context);
      bloc.add(RegistrarTipoAccesorioEvent(dto: dto));

    } catch (e) {
      _mostrarErrorDialog('Error al preparar datos: $e');
    }
  }

  void _mostrarErrorDialog(String message) {
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
          message,
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

  void _agregarMantenimiento() {
    setState(() {
      _diccionarioNombreControllers.add(TextEditingController());
      _diccionarioDescripcionControllers.add(TextEditingController());
      _diccionarioTipoControllers.add(TextEditingController());
      _frecuenciaKmControllers.add(TextEditingController());
      _frecuenciaTiempoControllers.add(TextEditingController());
      _diccionarioEstados.add('Activo');
    });
  }

  void _eliminarMantenimiento(int index) {
    if (_diccionarioNombreControllers.length > 1) {
      setState(() {
        _diccionarioNombreControllers[index].dispose();
        _diccionarioDescripcionControllers[index].dispose();
        _diccionarioTipoControllers[index].dispose();
        _frecuenciaKmControllers[index].dispose();
        _frecuenciaTiempoControllers[index].dispose();
        
        _diccionarioNombreControllers.removeAt(index);
        _diccionarioDescripcionControllers.removeAt(index);
        _diccionarioTipoControllers.removeAt(index);
        _frecuenciaKmControllers.removeAt(index);
        _frecuenciaTiempoControllers.removeAt(index);
        _diccionarioEstados.removeAt(index);
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _unidadMedidaController.dispose();
    _cantidadController.dispose();
    _descripcionSegController.dispose();
    _descripcionAccesorioController.dispose();
    
    for (var controller in _diccionarioNombreControllers) {
      controller.dispose();
    }
    for (var controller in _diccionarioDescripcionControllers) {
      controller.dispose();
    }
    for (var controller in _diccionarioTipoControllers) {
      controller.dispose();
    }
    for (var controller in _frecuenciaKmControllers) {
      controller.dispose();
    }
    for (var controller in _frecuenciaTiempoControllers) {
      controller.dispose();
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return BlocListener<AccessoryBloc, AccessoryState>(
      listener: (context, state) {
        if (state is RegistrandoTipoAccesorio) {
          // Podrías mostrar un loading aquí
        } else if (state is TipoAccesorioRegistrado) {
          Navigator.of(context).pop(); // Cierra el modal
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tipo de accesorio "${_nombreController.text}" registrado exitosamente'),
              backgroundColor: const Color(0xFF303366),
              duration: const Duration(seconds: 5),
            ),
          );
          
          if (widget.onAccessoryTypeAdded != null) {
            widget.onAccessoryTypeAdded!();
          }
        } else if (state is TipoAccesorioRegistroError) {
          _mostrarErrorDialog(state.message);
        }
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
                              // Campo Segmento con botón Select
                              Column(
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
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey[400]!),
                                            borderRadius: BorderRadius.circular(8),
                                            color: _segmentoSeleccionado != null 
                                              ? Colors.grey[50] 
                                              : Colors.white,
                                          ),
                                          child: Text(
                                            _segmentoSeleccionado?.nombre ?? 'No seleccionado',
                                            style: TextStyle(
                                              color: _segmentoSeleccionado != null 
                                                ? Colors.black 
                                                : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        height: 50,
                                        width: 120,
                                        child: ElevatedButton(
                                          onPressed: _mostrarModalSegmentos,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF303366),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text(
                                            'Select Segmento',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),

                              // Primera fila: Nombre, Unidad de medida, Cantidad
                              if (!isMobile)
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildFormField(
                                        'Nombre de accesorio', 
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
                                        'Unidad de medida', 
                                        _unidadMedidaController,
                                        (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Ingrese la unidad';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildFormField(
                                        'Cantidad', 
                                        _cantidadController,
                                        (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Ingrese la cantidad';
                                          }
                                          if (int.tryParse(value) == null) {
                                            return 'Ingrese un número válido';
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
                                      'Nombre de accesorio', 
                                      _nombreController,
                                      (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Ingrese el nombre';
                                        }
                                        return null;
                                      },
                                    ),
                                    _buildFormField(
                                      'Unidad de medida', 
                                      _unidadMedidaController,
                                      (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Ingrese la unidad';
                                        }
                                        return null;
                                      },
                                    ),
                                    _buildFormField(
                                      'Cantidad', 
                                      _cantidadController,
                                      (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Ingrese la cantidad';
                                        }
                                        if (int.tryParse(value) == null) {
                                          return 'Ingrese un número válido';
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),

                              const SizedBox(height: 16),

                              // Segunda fila: Descripción seg y Descripción accesorio
                              if (!isMobile)
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildFormField(
                                        'Descripción seg', 
                                        _descripcionSegController,
                                        null,
                                        maxLines: 3,
                                        readOnly: true,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildFormField(
                                        'Descripción accesorio', 
                                        _descripcionAccesorioController,
                                        (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Ingrese la descripción';
                                          }
                                          return null;
                                        },
                                        maxLines: 3,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    _buildFormField(
                                      'Descripción seg', 
                                      _descripcionSegController,
                                      null,
                                      maxLines: 3,
                                      readOnly: true,
                                    ),
                                    _buildFormField(
                                      'Descripción accesorio', 
                                      _descripcionAccesorioController,
                                      (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Ingrese la descripción';
                                        }
                                        return null;
                                      },
                                      maxLines: 3,
                                    ),
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
                        ..._diccionarioNombreControllers.asMap().entries.map((entry) {
                          final index = entry.key;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: _buildSeccionConBorde(
                              titulo: 'Diccionario de mantenimiento ${index + 1}',
                              mostrarBotonEliminar: _diccionarioNombreControllers.length > 1,
                              onEliminar: () => _eliminarMantenimiento(index),
                              contenido: _buildContenidoMantenimiento(index),
                            ),
                          );
                        }),

                        const SizedBox(height: 32),

                        // Botones (CERRAR y GUARDAR)
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

  Widget _buildContenidoMantenimiento(int index) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Column(
      children: [
        if (!isMobile)
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      'Nombre de mantenimiento', 
                      _diccionarioNombreControllers[index],
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
                      'Descripción man', 
                      _diccionarioDescripcionControllers[index],
                      null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFormField(
                      'Frecuencia en días', 
                      _frecuenciaTiempoControllers[index],
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese la frecuencia';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Ingrese un número válido';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      'Tipo de man', 
                      _diccionarioTipoControllers[index],
                      _tipoManOptions,
                      (value) {
                        setState(() {
                          _diccionarioTipoControllers[index].text = value ?? '';
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField(
                      'Estado', 
                      TextEditingController(text: _diccionarioEstados[index]),
                      _estadoOptions,
                      (value) {
                        setState(() {
                          _diccionarioEstados[index] = value;
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
                      'Frecuencia en kilómetros', 
                      _frecuenciaKmControllers[index],
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese la frecuencia';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Ingrese un número válido';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          )
        else
          Column(
            children: [
              _buildFormField(
                'Nombre de mantenimiento', 
                _diccionarioNombreControllers[index],
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el nombre';
                  }
                  return null;
                },
              ),
              _buildFormField(
                'Descripción man', 
                _diccionarioDescripcionControllers[index],
                null,
              ),
              _buildFormField(
                'Frecuencia en días', 
                _frecuenciaTiempoControllers[index],
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese la frecuencia';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              _buildDropdownField(
                'Tipo de man', 
                _diccionarioTipoControllers[index],
                _tipoManOptions,
                (value) {
                  setState(() {
                    _diccionarioTipoControllers[index].text = value ?? '';
                  });
                },
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Seleccione el tipo';
                  }
                  return null;
                },
              ),
              _buildDropdownField(
                'Estado', 
                TextEditingController(text: _diccionarioEstados[index]),
                _estadoOptions,
                (value) {
                  setState(() {
                    _diccionarioEstados[index] = value;
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
                'Frecuencia en kilómetros', 
                _frecuenciaKmControllers[index],
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese la frecuencia';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildAddMaintenanceButton() {
    return SizedBox(
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

  Widget _buildFormField(
    String label, 
    TextEditingController controller, 
    String? Function(String?)? validator, {
    int maxLines = 1, 
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
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
          readOnly: readOnly,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF303366)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: readOnly,
            fillColor: readOnly ? Colors.grey[100] : Colors.white,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdownField(
    String label, 
    TextEditingController controller, 
    List<String> options, Null Function(dynamic value) param3, String? Function(dynamic value) param4, {
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
          isExpanded: true,
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
                overflow: TextOverflow.ellipsis,
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