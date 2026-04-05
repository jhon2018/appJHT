// lib/features/supplier/presentation/widgets/detalle_supplier_modal.dart

import 'package:app_jht_front/features/supplier/data/models/supplier_detail_model.dart';
import 'package:app_jht_front/features/supplier/presentation/bloc/supplier_bloc.dart';
import 'package:app_jht_front/features/supplier/presentation/widgets/edit_supplier_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────
//  TOKENS DE DISEÑO
// ─────────────────────────────────────────────
const _kPrimary   = Color(0xFF303366);
const _kPrimaryBg = Color(0xFFEEEFF5);
const _kSuccess   = Color(0xFF2E7D32);
const _kSuccessBg = Color(0xFFE8F5E9);
const _kError     = Color(0xFFC62828);
const _kErrorBg   = Color(0xFFFFEBEE);
const _kBorder    = Color(0xFFE0E0E0);
const _kTextSub   = Color(0xFF757575);

class DetalleSupplierModal extends StatelessWidget {
  final SupplierDetailModel proveedor;
  final SupplierBloc supplierBloc;

  const DetalleSupplierModal({
    super.key,
    required this.proveedor,
    required this.supplierBloc,
  });

  // ── helpers ──────────────────────────────────
  Color _estadoColor(String estado) {
    final e = estado.toLowerCase();
    if (e == 'activo')   return _kSuccess;
    if (e == 'inactivo') return _kError;
    return _kTextSub;
  }

  Color _estadoBgColor(String estado) {
    final e = estado.toLowerCase();
    if (e == 'activo')   return _kSuccessBg;
    if (e == 'inactivo') return _kErrorBg;
    return Colors.grey[200]!;
  }

  Future<void> _abrirEnlace(String url, BuildContext context) async {
    try {
      String full = url.startsWith('http') ? url : 'https://$url';
      final uri = Uri.parse(full);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnack(context, 'No se puede abrir el enlace', isError: true);
      }
    } catch (e) {
      _showSnack(context, 'Error al abrir enlace', isError: true);
    }
  }

  void _showSnack(BuildContext context, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: isError ? _kError : _kPrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  // ── BUG FIX #3: guardar el contexto ANTES de hacer pop ───────────────────
  void _abrirEditar(BuildContext context) {
    // Capturamos el overlay context (el del Navigator raíz) antes de cerrar
    final overlayContext = Navigator.of(context, rootNavigator: true).context;

    // Cerramos el modal de detalle
    Navigator.of(context).pop();

    // Abrimos el modal de edición usando el overlay context que sigue vivo
    showDialog(
      context: overlayContext,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: supplierBloc,
        child: EditSupplierModal(
          proveedor: proveedor,
          onEditComplete: () {
            supplierBloc.add(const SupplierEvent.listarProveedores());
          },
        ),
      ),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 40,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 820,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(context),
                    const SizedBox(height: 24),
                    _buildSeccionInfo(isMobile),
                    const SizedBox(height: 24),
                    _buildSeccionTelefonos(),
                    if (proveedor.observaciones.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSeccionObservaciones(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: _kPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.storefront, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'DETALLE DEL PROVEEDOR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }

  // ── Barra estado + botón editar ───────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        // Chip estado
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _estadoBgColor(proveedor.estado),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _estadoColor(proveedor.estado).withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: _estadoColor(proveedor.estado),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                proveedor.estado.toUpperCase(),
                style: TextStyle(
                  color: _estadoColor(proveedor.estado),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Botón editar
        ElevatedButton.icon(
          onPressed: () => _abrirEditar(context),
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('EDITAR', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  // ── Sección información general ───────────────────────────────────────────
  Widget _buildSeccionInfo(bool isMobile) {
    return _buildSeccion(
      titulo: 'INFORMACIÓN GENERAL',
      icono: Icons.info_outline,
      child: isMobile
          ? Column(children: _infoItems(context: null, isMobile: true))
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Column(children: _infoItems(context: null, isMobile: false, left: true))),
                const SizedBox(width: 24),
                Expanded(child: Column(children: _infoItems(context: null, isMobile: false, left: false))),
              ],
            ),
    );
  }

  List<Widget> _infoItems({required BuildContext? context, required bool isMobile, bool left = true}) {
    // Columna izquierda en desktop / todos en mobile
    final leftItems = [
      _infoRow(Icons.business,       'Razón Social',  proveedor.razonSocial),
      _infoRow(Icons.person_outline, 'Representante', proveedor.representante),
      _infoRow(Icons.badge_outlined, 'RUC',           proveedor.ruc.toString()),
      _infoRow(Icons.category_outlined, 'Tipo',       proveedor.tipo),
      _infoRow(Icons.email_outlined, 'Correo',        proveedor.correo),
    ];
    final rightItems = [
      _infoRow(Icons.location_on_outlined, 'Dirección', proveedor.direccion),
      if (proveedor.linkUbicacion.isNotEmpty)
        _infoRowLink('Link Ubicación', proveedor.linkUbicacion),
      _infoRow(Icons.account_balance_outlined, 'Banco',     proveedor.banco),
      _infoRow(Icons.credit_card_outlined,     'N° Cuenta', proveedor.numeroCuenta.toString()),
      _infoRow(Icons.manage_accounts_outlined, 'Encargado', proveedor.encargado),
    ];

    if (isMobile) return [...leftItems, ...rightItems];
    return left ? leftItems : rightItems;
  }

  Widget _buildSeccionTelefonos() {
    return _buildSeccion(
      titulo: 'TELÉFONOS',
      icono: Icons.phone_outlined,
      child: proveedor.telefonos.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No hay teléfonos registrados',
                  style: TextStyle(color: _kTextSub, fontStyle: FontStyle.italic)),
            )
          : LayoutBuilder(builder: (ctx, constraints) {
              final cols = constraints.maxWidth > 500 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  childAspectRatio: cols == 2 ? 3.8 : 4.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: proveedor.telefonos.length,
                itemBuilder: (_, i) => _buildTelefonoCard(proveedor.telefonos[i].numero,
                    proveedor.telefonos[i].tipo, proveedor.telefonos[i].uso),
              );
            }),
    );
  }

  Widget _buildTelefonoCard(String numero, String tipo, String uso) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _kPrimaryBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kPrimary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: _kPrimary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.phone, color: _kPrimary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$tipo · $uso',
                    style: const TextStyle(fontSize: 11, color: _kTextSub),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(numero,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kPrimary)),
              ],
            ),
          ),
          // Copiar al portapapeles
          GestureDetector(
            onTap: () => Clipboard.setData(ClipboardData(text: numero)),
            child: const Tooltip(
              message: 'Copiar número',
              child: Icon(Icons.copy_outlined, size: 16, color: _kTextSub),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionObservaciones() {
    return _buildSeccion(
      titulo: 'OBSERVACIONES',
      icono: Icons.notes_outlined,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kBorder),
        ),
        child: Text(proveedor.observaciones,
            style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF424242))),
      ),
    );
  }

  // ── Contenedor de sección reutilizable ────────────────────────────────────
  Widget _buildSeccion({required String titulo, required IconData icono, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icono, color: _kPrimary, size: 18),
          const SizedBox(width: 8),
          Text(titulo,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: _kPrimary, letterSpacing: 0.5)),
        ]),
        const SizedBox(height: 10),
        const Divider(color: _kBorder, height: 1),
        const SizedBox(height: 14),
        child,
      ],
    );
  }

  // ── Fila de información ───────────────────────────────────────────────────
  Widget _infoRow(IconData icono, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 16, color: _kTextSub),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kTextSub)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRowLink(String label, String url) {
    return Builder(builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.map_outlined, size: 16, color: _kTextSub),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: Text(label,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kTextSub)),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _abrirEnlace(url, ctx),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.open_in_new, size: 14, color: Colors.blue),
                    SizedBox(width: 4),
                    Text('Ver en Google Maps',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue,
                            decoration: TextDecoration.underline)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}