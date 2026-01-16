// Ruta: lib/features/mantenimiento/presentation/widgets/edit_mantenimiento_modal.dart
import 'package:app_jht_front/features/mantenimiento/presentation/bloc/mantenimiento_event.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/bloc/mantenimiento_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/features/mantenimiento/presentation/bloc/mantenimiento_bloc.dart';
import 'package:app_jht_front/features/mantenimiento/data/models/mantenimiento_model.dart';
import 'package:app_jht_front/features/mantenimiento/data/models/detalle_mantenimiento_model.dart';

class EditMantenimientoModal extends StatefulWidget {
  final MantenimientoModel mantenimiento;
  final Function()? onMantenimientoActualizado;

  const EditMantenimientoModal({
    super.key,
    required this.mantenimiento,
    this.onMantenimientoActualizado,
  });

  @override
  State<EditMantenimientoModal> createState() => _EditMantenimientoModalState();
}

class _EditMantenimientoModalState extends State<EditMantenimientoModal> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _proximoKilometrajeController = TextEditingController();
  final _proximaFechaController = TextEditingController();
  final _estadoController = TextEditingController();

  // Listas para dropdowns
  final List<String> _estadoOptions = ['Pendiente', 'En proceso', 'Completado'];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Cargar el detalle cuando se inicialice el modal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MantenimientoBloc>().add(
        LoadDetalleMantenimientoEvent(
          bitacoraId: widget.mantenimiento.bitacoraId,
          accesorioId: widget.mantenimiento.accesorioId,
        ),
      );
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _proximaFechaController.text = _formatDate(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _proximoKilometrajeController.dispose();
    _proximaFechaController.dispose();
    _estadoController.dispose();
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
          'Confirmar Actualización',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF303366),
          ),
        ),
        content: const Text(
          '¿Está seguro de actualizar este mantenimiento?',
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
                    _actualizarMantenimiento();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _actualizarMantenimiento() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final request = ActualizarMantenimientoRequest(
        bitacoraId: widget.mantenimiento.bitacoraId,
        accesorioId: widget.mantenimiento.accesorioId,
        descripcion: _descripcionController.text,
        proximoKilometraje: int.parse(_proximoKilometrajeController.text),
        proximaFecha: _proximaFechaController.text,
        estado: _estadoController.text,
      );

      // Disparar el evento de actualización
      context.read<MantenimientoBloc>().add(
        UpdateMantenimientoEvent(request: request),
      );

      // El BLoC se encargará de mostrar mensajes y cerrar el modal
      // a través de los listeners
    }
  }

  Widget _buildFieldNoEditable(String label, String value) {
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100],
          ),
          child: Text(
            value,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFieldEditable(
    String label,
    TextEditingController controller,
    String? Function(String?) validator, {
    bool isDropdown = false,
    List<String>? options,
  }) {
    if (isDropdown && options != null) {
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: options.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.text = value;
              }
            },
            validator: validator,
          ),
          const SizedBox(height: 16),
        ],
      );
    }

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

  Widget _buildDateField(String label, TextEditingController controller) {
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
          onTap: () => _selectDate(context),
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
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return BlocConsumer<MantenimientoBloc, MantenimientoState>(
      listener: (context, state) {
        // Llenar los controladores cuando se cargue el detalle
        if (state is DetalleMantenimientoSuccess) {
          _descripcionController.text = state.detalle.descripcion;
          _proximoKilometrajeController.text = state.detalle.proximoKilometraje.toString();
          _proximaFechaController.text = state.detalle.proximaFecha;
          _estadoController.text = state.detalle.estado;
        }
        
        // Manejar actualización exitosa
        if (state is MantenimientoUpdated) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${state.message}'),
              backgroundColor: const Color(0xFF303366),
              duration: const Duration(seconds: 3),
            ),
          );
          
          if (widget.onMantenimientoActualizado != null) {
            widget.onMantenimientoActualizado!();
          }
        }
        
        // Manejar error en actualización
        if (state is MantenimientoUpdateError) {
          setState(() {
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 600,
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
                        'EDITAR MANTENIMIENTO',
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

                    if (state is DetalleMantenimientoLoading)
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF303366),
                          ),
                        ),
                      )
                    else if (state is DetalleMantenimientoError)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 40),
                            const SizedBox(height: 10),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: () {
                                context.read<MantenimientoBloc>().add(
                                  LoadDetalleMantenimientoEvent(
                                    bitacoraId: widget.mantenimiento.bitacoraId,
                                    accesorioId: widget.mantenimiento.accesorioId,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF303366),
                              ),
                              child: const Text(
                                'Reintentar',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (state is DetalleMantenimientoSuccess)
                      _buildForm(state.detalle)
                    else
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF303366),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm(DetalleMantenimientoModel detalle) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Campos NO editables
          _buildFieldNoEditable(
            'Fecha de Registro',
            _formatFechaRegistro(detalle.fechaRegistro),
          ),
          _buildFieldNoEditable(
            'Vehículo',
            detalle.vehiculoPlaca,
          ),
          _buildFieldNoEditable(
            'Accesorio',
            detalle.tipoAccesorio,
          ),
          _buildFieldNoEditable(
            'Tipo de Mantenimiento',
            detalle.concepto,
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.grey),
          const SizedBox(height: 16),

          // Campos EDITABLES
          _buildFieldEditable(
            'Descripción',
            _descripcionController,
            (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese la descripción';
              }
              return null;
            },
          ),
          _buildFieldEditable(
            'Próximo Kilometraje',
            _proximoKilometrajeController,
            (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese el próximo kilometraje';
              }
              if (int.tryParse(value) == null) {
                return 'Ingrese un número válido';
              }
              return null;
            },
          ),
          _buildDateField('Próxima Fecha', _proximaFechaController),
          _buildFieldEditable(
            'Estado',
            _estadoController,
            (value) {
              if (value == null || value.isEmpty) {
                return 'Seleccione el estado';
              }
              return null;
            },
            isDropdown: true,
            options: _estadoOptions,
          ),

          const SizedBox(height: 24),

          // Botones
          if (_isSaving)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF303366),
              ),
            )
          else
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
                    text: 'GUARDAR CAMBIOS',
                    backgroundColor: const Color(0xFF303366),
                    textColor: Colors.white,
                    onPressed: _submitForm,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatFechaRegistro(String fecha) {
    try {
      final dateTime = DateTime.parse(fecha);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return fecha;
    }
  }

  Widget _buildButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    VoidCallback? onPressed,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: onPressed == null ? Colors.grey[300] : backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: onPressed == null ? Colors.grey[500] : textColor,
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