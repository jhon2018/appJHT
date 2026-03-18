// lib/features/supplier/presentation/widgets/detalle_supplier_modal.dart
import 'package:app_jht_front/features/supplier/data/models/supplier_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetalleSupplierModal extends StatelessWidget {
  final SupplierDetailModel proveedor;

  const DetalleSupplierModal({
    super.key,
    required this.proveedor,
  });

  // Función para abrir URLs - AHORA RECIBE EL CONTEXT COMO PARÁMETRO
  Future<void> _abrirEnlace(String url, BuildContext context) async {
    try {
      // Asegurar que la URL tenga el protocolo
      String urlCompleta = url;
      if (!urlCompleta.startsWith('http://') && !urlCompleta.startsWith('https://')) {
        urlCompleta = 'https://$urlCompleta';
      }
      
      final Uri uri = Uri.parse(urlCompleta);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se puede abrir el enlace: $url'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir el enlace: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    final bool isTablet = MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1024;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: isMobile ? double.infinity : (isTablet ? 700 : 800),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con título y botón cerrar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF303366),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'DETALLE DEL PROVEEDOR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // Contenido del modal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Estado y acciones
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: proveedor.estado.toLowerCase() == 'activo'
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            proveedor.estado,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Aquí irá la lógica de edición
                            print('Editar proveedor ID: ${proveedor.proveedorId}');
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('EDITAR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF303366),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Información principal con layout responsivo
                    _buildSeccionInfo(context, isMobile),
                    
                    const SizedBox(height: 24),
                    
                    // Teléfonos
                    _buildSeccionTelefonos(context),
                    
                    const SizedBox(height: 24),
                    
                    // Observaciones
                    if (proveedor.observaciones.isNotEmpty)
                      _buildSeccionObservaciones(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionInfo(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'INFORMACIÓN GENERAL',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF303366),
          ),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
        
        // Layout responsivo para la información
        if (isMobile) ...[
          _buildInfoRow('Razón Social:', proveedor.razonSocial),
          _buildInfoRow('Representante:', proveedor.representante),
          _buildInfoRow('RUC:', proveedor.ruc.toString()),
          _buildInfoRow('Tipo:', proveedor.tipo),
          _buildInfoRow('Correo:', proveedor.correo),
          _buildInfoRow('Dirección:', proveedor.direccion),
          if (proveedor.linkUbicacion.isNotEmpty)
            _buildInfoRowConEnlace('Link Ubicación:', proveedor.linkUbicacion, context),
          _buildInfoRow('Banco:', proveedor.banco),
          _buildInfoRow('N° Cuenta:', proveedor.numeroCuenta.toString()),
          _buildInfoRow('Encargado:', proveedor.encargado),
        ] else ...[
          // En desktop, podemos usar 2 columnas
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildInfoRow('Razón Social:', proveedor.razonSocial),
                    _buildInfoRow('Representante:', proveedor.representante),
                    _buildInfoRow('RUC:', proveedor.ruc.toString()),
                    _buildInfoRow('Tipo:', proveedor.tipo),
                    _buildInfoRow('Correo:', proveedor.correo),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _buildInfoRow('Dirección:', proveedor.direccion),
                    if (proveedor.linkUbicacion.isNotEmpty)
                      _buildInfoRowConEnlace('Link Ubicación:', proveedor.linkUbicacion, context),
                    _buildInfoRow('Banco:', proveedor.banco),
                    _buildInfoRow('N° Cuenta:', proveedor.numeroCuenta.toString()),
                    _buildInfoRow('Encargado:', proveedor.encargado),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSeccionTelefonos(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TELÉFONOS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF303366),
          ),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
        
        if (proveedor.telefonos.isEmpty)
          const Text(
            'No hay teléfonos registrados',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          // Grid responsivo para teléfonos
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: proveedor.telefonos.length,
                itemBuilder: (context, index) {
                  final telefono = proveedor.telefonos[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF303366).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF303366).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.phone,
                            color: Color(0xFF303366),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${telefono.tipo} - ${telefono.uso}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                telefono.numero,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildSeccionObservaciones(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OBSERVACIONES',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF303366),
          ),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            proveedor.observaciones,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'No especificado' : value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowConEnlace(String label, String url, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _abrirEnlace(url, context), // <-- AHORA PASA EL CONTEXT
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.map,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Ver en Google Maps',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}