// Ruta: lib/core/theme/maintenance_colors.dart
// Design System — Color tokens centralizados
// 🟢 Verde   → éxito
// 🟡 Amarillo → advertencia
// 🔴 Rojo    → error
// 🔵 Azulino → datos guardados / actualizados / confirmados

import 'package:flutter/material.dart';

abstract class MaintenanceColors {
  MaintenanceColors._();

  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF303366);
  static const Color primaryLight = Color(0xFFEEEFF6);

  // ── Surfaces ──────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface    = Color(0xFFF8F9FC);
  static const Color border     = Color(0xFFE0E0E8);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);

  // ── 🟢 Éxito ──────────────────────────────────────────────────────────────
  static const Color success   = Color(0xFF16A34A);
  static const Color successBg = Color(0xFFDCFCE7);

  // ── 🟡 Advertencia ────────────────────────────────────────────────────────
  static const Color warning       = Color(0xFFFEF3C7);
  static const Color warningText   = Color(0xFFD97706);
  static const Color warningBorder = Color(0xFFF59E0B);

  // ── 🔴 Error ──────────────────────────────────────────────────────────────
  static const Color error   = Color(0xFFDC2626);
  static const Color errorBg = Color(0xFFFEE2E2);

  // ──  Confirmado / Guardado / Actualizado ────────────────────────────────
  static const Color info   = Color(0xFF2563EB);
  static const Color infoBg = Color(0xFFDBEAFE);

  // ✅ Colores de texto para fondos claros
  static const Color successText = Color(0xFF14532D);  // Verde oscuro
  static const Color errorText   = Color(0xFF991B1B);  // Rojo oscuro
  static const Color infoText    = Color(0xFF1E40AF);  // Azul oscuro

  // ✅ Fondo para campos readonly
  static const Color readonlyBg = Color(0xFFF3F4F6);   // Gris claro
}