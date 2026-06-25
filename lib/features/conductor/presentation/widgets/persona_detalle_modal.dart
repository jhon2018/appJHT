//Ruta:  lib\features\conductor\presentation\widgets\persona_detalle_modal.dart


import 'package:flutter/material.dart';
import 'package:app_jht_front/features/conductor/data/models/persona_model.dart';

class PersonaDetalleModal extends StatelessWidget {
  final PersonaModel persona;
  final PersonaModel? personaInicial;
  
  const PersonaDetalleModal({
    super.key,
    required this.persona,
    this.personaInicial,
  });
  

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 768;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SelectionArea(
        child: Container(
          constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 600,
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildInfoSection('Información Personal', _buildPersonalInfo()),
                const SizedBox(height: 16),
                _buildInfoSection('Información Laboral', _buildLaboralInfo()),
                const SizedBox(height: 16),
                if (persona.telefonos.isNotEmpty)
                  _buildInfoSection('Teléfonos', _buildTelefonosInfo()),
                const SizedBox(height: 16),
                if (persona.conductor != null)
                  _buildInfoSection('Información de Conductor', _buildConductorInfo()),
                const SizedBox(height: 24),
                _buildCloseButton(context),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'DETALLE DE PERSONA',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF303366),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Divider(color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(
          persona.nombreCompleto,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          'DNI: ${persona.dni}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF303366),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: content,
        ),
      ],
    );
  }

Widget _buildPersonalInfo() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildInfoRow('Nombre completo:', persona.nombreCompleto),
      _buildInfoRow('DNI:', persona.dni.toString()),
      _buildInfoRow('Primer nombre:', persona.primerNombre),
      if (persona.segundoNombre != null && persona.segundoNombre!.isNotEmpty)
        _buildInfoRow('Segundo nombre:', persona.segundoNombre!),
      _buildInfoRow('Apellido paterno:', persona.apellidoPaterno),
      _buildInfoRow('Apellido materno:', persona.apellidoMaterno),
      _buildInfoRow('Fecha de nacimiento:', persona.fechaNacimiento ?? 'No registrada'),
      _buildInfoRow('Correo electrónico:', persona.correo ?? 'No registrado'),
      _buildInfoRow('Estado:', persona.estado),
      _buildInfoRow('Fecha de registro:', _formatDate(persona.fechaRegistro)),
    ],
  );
}

  Widget _buildLaboralInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Cargo:', persona.cargo ?? 'No asignado'),
        _buildInfoRow('Salario:', persona.salario != null ? 'S/. ${persona.salario!.toStringAsFixed(2)}' : 'No asignado'),
        _buildInfoRow('Fecha de ingreso:', persona.fechaIngresoFormateada),
        if (persona.fechaSalida != null)
          _buildInfoRow('Fecha de salida:', _formatDate(persona.fechaSalida!)),
      ],
    );
  }

  Widget _buildTelefonosInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: persona.telefonos.map((telefono) {
        return _buildInfoRow('${telefono.uso}:', telefono.numero);
      }).toList(),
    );
  }

  Widget _buildConductorInfo() {
    final conductor = persona.conductor!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Número de licencia:', conductor.numeroLicencia),
        _buildInfoRow('Clase de licencia:', conductor.claseLicencia),
        _buildInfoRow('Categoría de licencia:', conductor.categoriaLicencia),
        _buildInfoRow('Fecha registro licencia:', _formatDate(conductor.fechaRegistroLicencia)),
        _buildInfoRow('Fecha vencimiento licencia:', _formatDate(conductor.fechaVencimientoLicencia)),
      ],
    );
  }

Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF616161),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildCloseButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF303366),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'CERRAR',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}