// lib/core/widgets/app_notification.dart
// Utilidad centralizada de notificaciones con colores semánticos.
// Usa SnackBar por defecto. Cuando hay un modal abierto usa AlertDialog
// (porque el SnackBar queda detrás y no se ve).

import 'package:flutter/material.dart';

enum _NotifType { success, error, warning, info }

class AppNotification {
  AppNotification._();

  // ─── COLORES SEMÁNTICOS ────────────────────────────────────────────────────
  static const Color _green  = Color(0xFF2E7D32); // éxito
  static const Color _red    = Color(0xFFC62828); // error
  static const Color _amber  = Color(0xFFF57F17); // advertencia
  static const Color _blue   = Color(0xFF1565C0); // info

  // ─── API PÚBLICA ───────────────────────────────────────────────────────────

  /// ✅ Éxito — verde
  static void success(BuildContext context, String message,
      {bool isModal = false, Duration duration = const Duration(seconds: 3)}) {
    _show(context, message, _NotifType.success,
        isModal: isModal, duration: duration);
  }

  /// ❌ Error — rojo
  static void error(BuildContext context, String message,
      {bool isModal = false, Duration duration = const Duration(seconds: 4)}) {
    _show(context, message, _NotifType.error,
        isModal: isModal, duration: duration);
  }

  /// ⚠️ Advertencia — amarillo/ámbar
  static void warning(BuildContext context, String message,
      {bool isModal = false, Duration duration = const Duration(seconds: 3)}) {
    _show(context, message, _NotifType.warning,
        isModal: isModal, duration: duration);
  }

  /// ℹ️ Información — azul
  static void info(BuildContext context, String message,
      {bool isModal = false, Duration duration = const Duration(seconds: 3)}) {
    _show(context, message, _NotifType.info,
        isModal: isModal, duration: duration);
  }

  // ─── IMPLEMENTACIÓN ────────────────────────────────────────────────────────

  static void _show(
    BuildContext context,
    String message,
    _NotifType type, {
    required bool isModal,
    required Duration duration,
  }) {
    if (isModal) {
      _showAlertDialog(context, message, type);
    } else {
      _showSnackBar(context, message, type, duration);
    }
  }

  // SnackBar estilizado (para pantalla normal)
  static void _showSnackBar(
      BuildContext context, String message, _NotifType type, Duration duration) {
    if (!context.mounted) return;

    final color  = _colorFor(type);
    final icon   = _iconFor(type);
    final label  = _labelFor(type);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white70,
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
  }

  // AlertDialog (para usar dentro de modales, ya que el SnackBar queda oculto)
  static void _showAlertDialog(
      BuildContext context, String message, _NotifType type) {
    if (!context.mounted) return;

    final color = _colorFor(type);
    final icon  = _iconFor(type);
    final label = _labelFor(type);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Aceptar',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  static Color _colorFor(_NotifType t) {
    switch (t) {
      case _NotifType.success: return _green;
      case _NotifType.error:   return _red;
      case _NotifType.warning: return _amber;
      case _NotifType.info:    return _blue;
    }
  }

  static IconData _iconFor(_NotifType t) {
    switch (t) {
      case _NotifType.success: return Icons.check_circle_outline;
      case _NotifType.error:   return Icons.error_outline;
      case _NotifType.warning: return Icons.warning_amber_outlined;
      case _NotifType.info:    return Icons.info_outline;
    }
  }

  static String _labelFor(_NotifType t) {
    switch (t) {
      case _NotifType.success: return 'Operación exitosa';
      case _NotifType.error:   return 'Error';
      case _NotifType.warning: return 'Advertencia';
      case _NotifType.info:    return 'Información';
    }
  }
}
