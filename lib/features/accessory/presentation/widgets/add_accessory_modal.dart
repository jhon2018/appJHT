//Ruta: lib/features/accessory/presentation/widgets/add_accessory_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener intl
import 'package:app_jht_front/features/accessory/presentation/bloc/accessory_bloc.dart';
import 'package:app_jht_front/features/accessory/data/models/segmento_model.dart';
import 'package:app_jht_front/features/accessory/data/models/tipo_accesorio_model.dart';
import 'package:app_jht_front/features/accessory/data/models/vehiculo_model.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_registro_dto.dart';
import 'package:app_jht_front/features/accessory/data/models/accesorio_detalle_model.dart'; // Importa el nuevo modelo
import 'add_accessory_type_modal.dart';

class AddAccessoryModal extends StatefulWidget {
  final Function()? onAccessoryAdded;
  final bool isViewOnly; // Nuevo: Controla si es solo lectura
  final AccesorioDetalleModel? detalle; // Nuevo: Datos para mostrar

  const AddAccessoryModal({
    super.key, 
    this.onAccessoryAdded,
    this.isViewOnly = false,
    this.detalle,
  });

  @override
  State<AddAccessoryModal> createState() => _AddAccessoryModalState();
}

class _AddAccessoryModalState extends State<AddAccessoryModal> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _descripcionController = TextEditingController();
  final _marcaController = TextEditingController();
  final _codigoFabricanteController = TextEditingController();
  final _kilometrajeInstalacionController = TextEditingController();
  final _observacionesController = TextEditingController();

  // Controladores EXTRA para modo lectura (reemplazan dropdowns)
  final _vehiculoTextController = TextEditingController();
  final _tipoAccesorioTextController = TextEditingController();
  final _segmentoTextController = TextEditingController();

  DateTime? _fechaInstalacion;
  String? _estadoValue;

  // IDs para modo Registro
  int? _selectedSegmentoId;
  int? _selectedTipoAccesorioId;
  int? _selectedVehiculoId;
  List<SegmentoModel> _segmentosCache = [];
  final List<String> _estadoOptions = ['Activo', 'Inactivo', 'Pendiente', 'OK']; // Agregué OK/Pendiente por tu imagen

  @override
  void initState() {
    super.initState();
    if (widget.isViewOnly && widget.detalle != null) {
      _cargarDatosDetalle();
    } else {
      _cargarDatosInicialesRegistro();
    }
  }

  // REQUERIMIENTO 14: Llenar datos y bloquear
  void _cargarDatosDetalle() {
    final d = widget.detalle!;
    _descripcionController.text = d.tipoDescripcion; // O d.observacion según prefieras
    _marcaController.text = d.marca.isEmpty ? "No especificada" : d.marca; 
    _codigoFabricanteController.text = d.codigoFabricante;
    _kilometrajeInstalacionController.text = d.kilometrajeInstalacion.toString();
    _observacionesController.text = d.observacion;
    
    // Campos de texto plano en lugar de dropdowns
    _vehiculoTextController.text = d.placa;
    _tipoAccesorioTextController.text = d.tipoNombre;
    _segmentoTextController.text = "Cargado de Detalle"; // API 27 no devolvió segmento, ponemos default o lo ocultamos
    
    _fechaInstalacion = d.fechaInstalacion;
    _estadoValue = d.estado;
  }

  void _cargarDatosInicialesRegistro() {
    context.read<AccessoryBloc>().add(LoadSegmentosEvent());
    context.read<AccessoryBloc>().add(LoadVehiculosEvent());
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    // Si es viewOnly, usamos un título diferente
    final String titulo = widget.isViewOnly ? 'DETALLE ACCESORIO' : 'AGREGAR ACCESORIO';

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.all(isMobile ? 10 : 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 800, maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF303366))),
              const Divider(height: 30, color: Colors.grey),
              
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // FILA 1: Vehículo y Tipo (En modo lectura son TextFields, en registro Dropdowns)
                    if (widget.isViewOnly) 
                      Row(children: [
                        Expanded(child: _buildReadOnlyField('Vehículo', _vehiculoTextController)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildReadOnlyField('Tipo Accesorio', _tipoAccesorioTextController)),
                      ])
                    else 
                      // ... Aquí iría tu lógica de Dropdowns existente para registro ...
                      // Por brevedad, asumo que mantienes los métodos _buildVehiculoDropdown() etc.
                      Column(children: [_buildVehiculoDropdown(), _buildTipoAccesorioDropdown()]), 

                    const SizedBox(height: 16),

                    // FILA 2: Descripción y Marca
                    Row(children: [
                      Expanded(child: _buildFormField('Descripción', _descripcionController, maxLines: 1)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildFormField('Marca', _marcaController)),
                    ]),

                    // FILA 3: Código y Fecha
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: _buildFormField('Cód. Fabricante', _codigoFabricanteController)),
                      const SizedBox(width: 16),
                      Expanded(child: widget.isViewOnly 
                        ? _buildReadOnlyField('Fecha Instalación', TextEditingController(text: _formatDate(_fechaInstalacion)))
                        : _buildDateField('Fecha Instalación', _fechaInstalacion, () => _selectDate(context))),
                    ]),

                    // FILA 4: Kilometraje y Estado
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: _buildFormField('Km Instalación', _kilometrajeInstalacionController)),
                      const SizedBox(width: 16),
                      Expanded(child: widget.isViewOnly
                        ? _buildReadOnlyField('Estado', TextEditingController(text: _estadoValue))
                        : _buildEstadoDropdown()),
                    ]),

                    // Observaciones
                    const SizedBox(height: 16),
                    _buildFormField('Observaciones', _observacionesController, maxLines: 3),

                    const SizedBox(height: 30),

                    // BOTONES
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildButton(
                          text: widget.isViewOnly ? 'CERRAR' : 'CANCELAR',
                          backgroundColor: Colors.grey[300]!,
                          textColor: Colors.black87,
                          onPressed: () => Navigator.pop(context),
                        ),
                        if (!widget.isViewOnly) ...[
                          const SizedBox(width: 12),
                          _buildButton(
                            text: 'GUARDAR',
                            backgroundColor: const Color(0xFF303366),
                            textColor: Colors.white,
                            onPressed: _submitForm, // Tu función de guardar existente
                          ),
                        ]
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET MODIFICADO: Soporta modo lectura (bloqueado)
  Widget _buildFormField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF303366))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          readOnly: widget.isViewOnly, // REQUERIMIENTO 14: BLOQUEADO
          enabled: !widget.isViewOnly, // Visualmente deshabilitado
          style: TextStyle(color: widget.isViewOnly ? Colors.grey[700] : Colors.black),
          decoration: InputDecoration(
            filled: widget.isViewOnly,
            fillColor: widget.isViewOnly ? Colors.grey[100] : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  // Widget específico para campos que siempre son texto en modo lectura
  Widget _buildReadOnlyField(String label, TextEditingController controller) {
    return _buildFormField(label, controller);
  }

  // --- Helpers existentes (simplificados para el ejemplo) ---
  String _formatDate(DateTime? date) => date == null ? '' : DateFormat('dd/MM/yyyy HH:mm').format(date);
  
  // (Mantén tus métodos _selectDate, _buildVehiculoDropdown, _buildTipoAccesorioDropdown, _submitForm del código anterior, 
  // solo asegúrate de que _buildVehiculoDropdown retorne un SizedBox() si isViewOnly es true para no duplicar UI)
  Widget _buildVehiculoDropdown() {
     if (widget.isViewOnly) return const SizedBox.shrink(); // Ocultar en modo lectura
     // ... tu código original del dropdown ...
     return Container(); // Placeholder
  }
  
  Widget _buildTipoAccesorioDropdown() {
     if (widget.isViewOnly) return const SizedBox.shrink();
     // ... tu código original ...
     return Container(); 
  }

  Widget _buildEstadoDropdown() {
    // ... tu código original del dropdown ...
     return Container();
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
      // ... tu código original ...
      return Container();
  }
  
  Future<void> _selectDate(BuildContext context) async { /* ... */ }
  void _submitForm() { /* ... */ }

  Widget _buildButton({required String text, required Color backgroundColor, required Color textColor, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: backgroundColor, foregroundColor: textColor),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}