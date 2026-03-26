// lib/features/supplier/presentation/widgets/edit_supplier_modal.dart
import 'package:app_jht_front/features/supplier/data/models/supplier_detail_model.dart';
import 'package:app_jht_front/features/supplier/data/models/tipo_telefono_model.dart';
import 'package:app_jht_front/features/supplier/data/models/supplier_actualizar_dto.dart';
import 'package:app_jht_front/features/supplier/presentation/bloc/supplier_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_jht_front/core/utils/token_service.dart';
import 'package:app_jht_front/features/config/environment_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditSupplierModal extends StatefulWidget {
  final SupplierDetailModel proveedor;
  final VoidCallback onEditComplete;

  const EditSupplierModal({
    super.key,
    required this.proveedor,
    required this.onEditComplete,
  });

  @override
  State<EditSupplierModal> createState() => _EditSupplierModalState();
}

class _EditSupplierModalState extends State<EditSupplierModal> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _razonSocialController;
  late final TextEditingController _direccionController;
  late final TextEditingController _rucController;
  late final TextEditingController _tipoController;
  late final TextEditingController _bancoController;
  late final TextEditingController _encargadoController;
  late final TextEditingController _representanteController;
  late final TextEditingController _ubicacionLinkController;
  late final TextEditingController _correoController;
  late final TextEditingController _numeroCuentaController;
  late final TextEditingController _observacionController;
  
  late List<TextEditingController> _telefonoControllers;
  late List<int?> _telefonoTipoIds;
  late List<int> _telefonoIds;
  
  String? _estadoValue;
  List<TipoTelefonoModel> _tiposTelefonoList = [];

  @override
  void initState() {
    super.initState();
    _inicializarControladores();
    _cargarTiposTelefono();
  }

  void _inicializarControladores() {
    final p = widget.proveedor;
    
    _razonSocialController = TextEditingController(text: p.razonSocial);
    _direccionController = TextEditingController(text: p.direccion);
    _rucController = TextEditingController(text: p.ruc.toString());
    _tipoController = TextEditingController(text: p.tipo);
    _bancoController = TextEditingController(text: p.banco);
    _encargadoController = TextEditingController(text: p.encargado);
    _representanteController = TextEditingController(text: p.representante);
    _ubicacionLinkController = TextEditingController(text: p.linkUbicacion);
    _correoController = TextEditingController(text: p.correo);
    _numeroCuentaController = TextEditingController(text: p.numeroCuenta.toString());
    _observacionController = TextEditingController(text: p.observaciones);
    
    _estadoValue = p.estado;
    
    _telefonoControllers = [];
    _telefonoTipoIds = [];
    _telefonoIds = [];
    
    for (var tel in p.telefonos) {
      _telefonoControllers.add(TextEditingController(text: tel.numero));
     _telefonoTipoIds.add(tel.tipoId == 0 ? null : tel.tipoId);
      _telefonoIds.add(tel.telefonoId);
    }
    
    if (_telefonoControllers.isEmpty) {
      _telefonoControllers.add(TextEditingController());
      _telefonoTipoIds.add(null);
      _telefonoIds.add(0);
    }
  }

  Future<void> _cargarTiposTelefono() async {
    try {
      final String? token = await TokenService.getToken();
      if (token == null || token.isEmpty) return;

      final response = await http.get(
        Uri.parse('${EnvironmentConfig.baseUrl}/api/admin/consulta_tipo_telefono'),
        headers: {'Authorization': 'Bearer $token', 'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'] as List;
        setState(() {
          _tiposTelefonoList = data.map((item) => TipoTelefonoModel.fromJson(item)).toList();
        });
      }
    } catch (e) {
      print('❌ Error cargando tipos: $e');
    }
  }

  void _agregarTelefono() {
    setState(() {
      _telefonoControllers.add(TextEditingController());
      _telefonoTipoIds.add(null);
      _telefonoIds.add(0);
    });
  }

  void _eliminarTelefono(int index) {
    if (_telefonoControllers.length > 1) {
      setState(() {
        _telefonoControllers[index].dispose();
        _telefonoControllers.removeAt(index);
        _telefonoTipoIds.removeAt(index);
        _telefonoIds.removeAt(index);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _estadoValue != null) {
      _showConfirmationDialog();
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Confirmar Actualización', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF303366))),
        content: const Text('¿Está seguro de que desea actualizar este proveedor?', textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
        actions: [
          Row(
            children: [
              Expanded(child: _buildDialogButton('CANCELAR', Colors.grey[300]!, Colors.grey[700]!, () => Navigator.of(context).pop())),
              const SizedBox(width: 12),
              Expanded(child: _buildDialogButton('CONFIRMAR', const Color(0xFF303366), Colors.white, () {
                Navigator.of(context).pop();
                _actualizarProveedor();
              })),
            ],
          ),
        ],
      ),
    );
  }

void _actualizarProveedor() {
  // Validar teléfonos - ahora verificamos si es null
  for (int i = 0; i < _telefonoControllers.length; i++) {
    if (_telefonoTipoIds[i] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Seleccione el tipo para el teléfono ${i + 1}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
  }

  final telefonos = List<TelefonoActualizarDto>.generate(
    _telefonoControllers.length,
    (index) => TelefonoActualizarDto(
      telId: _telefonoIds[index],
      numero: _telefonoControllers[index].text,
      titId: _telefonoTipoIds[index]!, // ✅ Ahora seguro que no es null
    ),
  );

    final dto = SupplierActualizarDto(
      proveedorId: widget.proveedor.proveedorId,
      razonSocial: _razonSocialController.text,
      representante: _representanteController.text,
      direccion: _direccionController.text,
      linkUbicacion: _ubicacionLinkController.text,
      ruc: int.tryParse(_rucController.text) ?? 0,
      tipo: _tipoController.text,
      correo: _correoController.text,
      banco: _bancoController.text,
      numCuenta: int.tryParse(_numeroCuentaController.text) ?? 0,
      encargado: _encargadoController.text,
      estado: _estadoValue!,
      observaciones: _observacionController.text,
      telefonos: telefonos,
    );

    context.read<SupplierBloc>().add(SupplierEvent.actualizarProveedor(dto: dto));
  }

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
    for (var c in _telefonoControllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      print('🔵 [DEBUG] EditSupplierModal - build ejecutándose');
  print('   Proveedor ID: ${widget.proveedor.proveedorId}');
  print('   Razón Social: ${widget.proveedor.razonSocial}');
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return BlocListener<SupplierBloc, SupplierState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {},
          success: (response) {},
          listLoaded: (response) {},
          detailLoaded: (response) {},
          updateSuccess: (response) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.message),
                backgroundColor: const Color(0xFF303366),
              ),
            );
            widget.onEditComplete();
          },
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $message'),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
      },
      child: Dialog(
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
                  const Center(child: Text('EDITAR PROVEEDOR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF303366)))),
                  const SizedBox(height: 8),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 24),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        isMobile
                            ? Column(children: [
                                _buildFormField('Razón Social', _razonSocialController, (v) => v?.isEmpty ?? true ? 'Ingrese razón social' : null),
                                _buildFormField('RUC', _rucController, (v) {
                                  if (v?.isEmpty ?? true) return 'Ingrese RUC';
                                  if (v!.length != 11) return 'RUC debe tener 11 dígitos';
                                  return null;
                                }, keyboardType: TextInputType.number),
                              ])
                            : Row(children: [
                                Expanded(child: _buildFormField('Razón Social', _razonSocialController, (v) => v?.isEmpty ?? true ? 'Ingrese razón social' : null)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildFormField('RUC', _rucController, (v) {
                                  if (v?.isEmpty ?? true) return 'Ingrese RUC';
                                  if (v!.length != 11) return 'RUC debe tener 11 dígitos';
                                  return null;
                                }, keyboardType: TextInputType.number)),
                              ]),

                        _buildFormField('Dirección', _direccionController, (v) => v?.isEmpty ?? true ? 'Ingrese dirección' : null),

                        isMobile
                            ? Column(children: [
                                _buildFormField('Tipo', _tipoController, (v) => v?.isEmpty ?? true ? 'Ingrese tipo' : null),
                                _buildFormField('Banco', _bancoController, (v) => v?.isEmpty ?? true ? 'Ingrese banco' : null),
                              ])
                            : Row(children: [
                                Expanded(child: _buildFormField('Tipo', _tipoController, (v) => v?.isEmpty ?? true ? 'Ingrese tipo' : null)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildFormField('Banco', _bancoController, (v) => v?.isEmpty ?? true ? 'Ingrese banco' : null)),
                              ]),

                        _buildFormField('Encargado', _encargadoController, (v) => v?.isEmpty ?? true ? 'Ingrese encargado' : null),

                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Teléfonos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF303366))),
                          const SizedBox(height: 8),
                          ...List.generate(_telefonoControllers.length, (index) => _buildTelefonoRow(index, isMobile)),
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 8),
                            child: OutlinedButton(
                              onPressed: _agregarTelefono,
                              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF303366), side: const BorderSide(color: Color(0xFF303366))),
                              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add, size: 16), SizedBox(width: 8), Text('AGREGAR TELÉFONO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))]),
                            ),
                          ),
                        ]),

                        const SizedBox(height: 16),
                        _buildFormField('Representante', _representanteController, (v) => v?.isEmpty ?? true ? 'Ingrese representante' : null),
                        _buildFormField('Link Ubicación', _ubicacionLinkController, (v) => null),
                        _buildFormField('Correo', _correoController, (v) {
                          if (v?.isEmpty ?? true) return 'Ingrese correo';
                          if (!v!.contains('@')) return 'Correo inválido';
                          return null;
                        }, keyboardType: TextInputType.emailAddress),
                        _buildFormField('N° Cuenta', _numeroCuentaController, (v) => v?.isEmpty ?? true ? 'Ingrese número de cuenta' : null, keyboardType: TextInputType.number),
                        _buildEstadoDropdown(),
                        _buildFormField('Observaciones', _observacionController, (v) => null, maxLines: 3),

                        const SizedBox(height: 32),
                        Row(children: [
                          Expanded(child: _buildButton('CANCELAR', Colors.grey[300]!, Colors.grey[700]!, () => Navigator.of(context).pop())),
                          const SizedBox(width: 12),
                          Expanded(child: _buildButton('GUARDAR', const Color(0xFF303366), Colors.white, _submitForm)),
                        ]),
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

Widget _buildTelefonoRow(int index, bool isMobile) {
  return Column(children: [
    if (index > 0) const SizedBox(height: 12),
    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        flex: 2,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Tipo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF303366))),
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
              child: DropdownButton<int?>(
                value: _telefonoTipoIds[index], // ✅ Ahora es int? (nullable)
                isExpanded: true,
                hint: const Text('Seleccione tipo', style: TextStyle(fontSize: 12)),
                items: [
                  // ✅ Opción por defecto para cuando no hay selección
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Seleccione un tipo', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                  ..._tiposTelefonoList.map((tipo) => DropdownMenuItem<int?>(
                    value: tipo.id,
                    child: Text(tipo.displayText, style: const TextStyle(fontSize: 12)),
                  )),
                ],
                onChanged: (value) => setState(() => _telefonoTipoIds[index] = value),
              ),
            ),
          ),
        ]),
      ),
      const SizedBox(width: 8),
      Expanded(
        flex: 2,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Teléfono', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF303366))),
          const SizedBox(height: 4),
          TextFormField(
            controller: _telefonoControllers[index],
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              hintText: 'Ej: 987654321',
              hintStyle: const TextStyle(fontSize: 12),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Ingrese teléfono' : null,
          ),
        ]),
      ),
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
    ]),
  ]);
}

  Widget _buildFormField(String label, TextEditingController controller, String? Function(String?) validator, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF303366))),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF303366))),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      const SizedBox(height: 16),
    ]);
  }

  Widget _buildEstadoDropdown() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Estado', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF303366))),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: _estadoValue,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF303366))),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: const [DropdownMenuItem(value: 'ACTIVO', child: Text('ACTIVO')), DropdownMenuItem(value: 'INACTIVO', child: Text('INACTIVO'))],
        onChanged: (value) => setState(() => _estadoValue = value),
        validator: (value) => value == null ? 'Seleccione estado' : null,
      ),
      const SizedBox(height: 16),
    ]);
  }

  Widget _buildButton(String text, Color bgColor, Color textColor, VoidCallback onPressed) {
    return Container(height: 50, decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)), child: TextButton(onPressed: onPressed, child: Text(text, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600))));
  }

  Widget _buildDialogButton(String text, Color bgColor, Color textColor, VoidCallback onPressed) {
    return Container(height: 45, decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)), child: TextButton(onPressed: onPressed, child: Text(text, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600))));
  }
}