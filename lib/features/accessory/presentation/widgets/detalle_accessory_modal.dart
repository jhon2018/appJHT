// lib/features/accessory/presentation/widgets/detalle_accessory_modal.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/accesorio_detalle_model.dart';

void showDetalleAccesorioModal(
  BuildContext context,
  AccesorioDetalleModel detalle,
  num kilometrajeActualVehiculo, {
  String? proximaFechaMantenimiento,
}) {
  final ahora = DateTime.now();
  final instalacion = detalle.fechaInstalacion;

  final diasTranscurridos = ahora.difference(instalacion).inDays;
  final kmRecorridos = (kilometrajeActualVehiculo - detalle.kilometrajeInstalacion).floor();

  int? diasParaMantenimiento;
  if (proximaFechaMantenimiento != null && proximaFechaMantenimiento.isNotEmpty) {
    try {
      final fechaProx = DateTime.parse(proximaFechaMantenimiento);
      diasParaMantenimiento = fechaProx.difference(DateTime(ahora.year, ahora.month, ahora.day)).inDays;
    } catch (_) {}
  }

  final bool alertaDias = diasTranscurridos > 15;
  final bool alertaKm = kmRecorridos > 500;
  final bool alertaMantenimiento = diasParaMantenimiento != null && diasParaMantenimiento <= 45; // Mostrar si faltan 45 días o menos, o si ya pasó
  
  final bool mostrarAlerta = alertaDias || alertaKm || alertaMantenimiento;

  final Color colorNombre = mostrarAlerta ? Colors.red.shade700 : const Color(0xFF303366);

  final bool isMobile = MediaQuery.sizeOf(context).width < 600;

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        insetPadding: isMobile
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 24)
            : const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isMobile ? 380 : 500,
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 20 : 28,
                24,
                isMobile ? 20 : 28,
                28,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título principal
                  Text(
                    'DETALLE ACCESORIO',
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF303366),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Divider(height: 1, color: Colors.grey.shade400),
                  const SizedBox(height: 12),

                  // Nombre del accesorio (mayúsculas, más pequeño)
                  Text(
                    detalle.tipoNombre.isEmpty ? 'ACCESORIO' : detalle.tipoNombre.toUpperCase(),
                    style: TextStyle(
                      fontSize: isMobile ? 17 : 19,
                      fontWeight: FontWeight.w600,
                      color: colorNombre,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Contenido
                  _buildDetailRow('Código fabricante', detalle.codigoFabricante, isMobile),
                  _buildDetailRow('Tipo', detalle.tipoNombre, isMobile),
                  if (detalle.tipoDescripcion.isNotEmpty)
                    _buildDetailRow('Descripción tipo', detalle.tipoDescripcion, isMobile),
                  _buildDetailRow('Placa vehículo', detalle.placa, isMobile),

                  _buildDetailRowFecha(
                    'Fecha instalación',
                    detalle.fechaInstalacion,
                    diasTranscurridos: diasTranscurridos,
                    alerta: alertaDias,
                    isMobile: isMobile,
                  ),

                  _buildDetailRowKm(
                    'Kilometraje instalación',
                    detalle.kilometrajeInstalacion,
                    kmDiferencia: kmRecorridos,
                    alerta: alertaKm,
                    isMobile: isMobile,
                  ),

                  if (detalle.fechaRetiro != null) ...[
                    _buildDetailRowFecha('Fecha retiro', detalle.fechaRetiro!, isMobile: isMobile),
                    if (detalle.kilometrajeRetiro != null)
                      _buildDetailRowKm('Kilometraje retiro', detalle.kilometrajeRetiro!, isMobile: isMobile),
                  ],

                  _buildDetailRow(
                    'Estado',
                    detalle.estado,
                    valorColor: detalle.estado.toLowerCase().contains('activo')
                        ? Colors.green.shade700 : Colors.orange.shade800,
                    isMobile,
                  ),

                  const SizedBox(height: 24),

                  if (detalle.observacion.isNotEmpty) ...[
                    Text(
                      'Observación',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        detalle.observacion,
                        style: TextStyle(fontSize: isMobile ? 13 : 14, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  if (mostrarAlerta)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Requiere atención',
                                style: TextStyle(
                                  color: Colors.red.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (alertaDias)
                            Text('• Han pasado $diasTranscurridos días desde la instalación',
                                style: const TextStyle(color: Colors.red, fontSize: 14)),
                          if (alertaKm)
                            Text('• Se han recorrido $kmRecorridos km desde la instalación',
                                style: const TextStyle(color: Colors.red, fontSize: 14)),
                          if (alertaMantenimiento && diasParaMantenimiento != null)
                            Text(
                                diasParaMantenimiento! > 0
                                    ? '• Faltan $diasParaMantenimiento días para su próximo mantenimiento'
                                    : diasParaMantenimiento == 0
                                        ? '• El próximo mantenimiento es hoy'
                                        : '• Han pasado ${diasParaMantenimiento!.abs()} días desde su próximo mantenimiento programado',
                                style: const TextStyle(color: Colors.red, fontSize: 14)),
                        ],
                      ),
                    ),

                  const SizedBox(height: 36),

                  // Botón CANCELAR centrado
                  Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF303366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                        minimumSize: const Size(180, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('CANCELAR', style: TextStyle(fontSize: 15)),
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

// Helpers simplificados y compactos
Widget _buildDetailRow(String label, String value, bool isMobile, {Color? valorColor}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: isMobile ? 130 : 160,
          child: Text(label, style: TextStyle(fontSize: isMobile ? 13 : 14, color: Colors.grey)),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              color: valorColor ?? Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildDetailRowFecha(
  String label,
  DateTime fecha, {
  int? diasTranscurridos,
  bool alerta = false,
  required bool isMobile,
}) {
  final formato = DateFormat('dd/MM/yyyy');
  final color = alerta ? Colors.red.shade700 : null;

  return Padding(
    padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: isMobile ? 130 : 160,
          child: Text(label, style: TextStyle(fontSize: isMobile ? 13 : 14, color: Colors.grey)),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formato.format(fecha),
                style: TextStyle(fontSize: isMobile ? 14 : 15, color: color, fontWeight: FontWeight.w500),
              ),
              if (diasTranscurridos != null && diasTranscurridos > 0)
                Text(
                  '($diasTranscurridos días atrás)',
                  style: TextStyle(fontSize: isMobile ? 12 : 13, color: color ?? Colors.grey.shade700),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildDetailRowKm(
  String label,
  int km, {
  int? kmDiferencia,
  bool alerta = false,
  required bool isMobile,
}) {
  final color = alerta ? Colors.red.shade700 : null;

  return Padding(
    padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: isMobile ? 130 : 160,
          child: Text(label, style: TextStyle(fontSize: isMobile ? 13 : 14, color: Colors.grey)),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                NumberFormat('#,###').format(km),
                style: TextStyle(fontSize: isMobile ? 14 : 15, color: color, fontWeight: FontWeight.w500),
              ),
              if (kmDiferencia != null && kmDiferencia > 0)
                Text(
                  '(+$kmDiferencia km recorridos)',
                  style: TextStyle(fontSize: isMobile ? 12 : 13, color: color ?? Colors.grey.shade700),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}