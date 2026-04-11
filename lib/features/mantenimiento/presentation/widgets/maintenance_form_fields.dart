// Ruta: lib/features/mantenimiento/presentation/widgets/maintenance_form_fields.dart
// Componentes reutilizables del formulario de mantenimiento.
// Incluye: ReadonlyItem, MaintenanceReadonlyGrid,
//          MaintenanceEditableGrid, MaintenanceFormField (factory estático).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_jht_front/core/theme/maintenance_colors.dart';

// ─── Data class ───────────────────────────────────────────────────────────────
class ReadonlyItem {
  final String label;
  final String value;
  const ReadonlyItem({required this.label, required this.value});
}

// ─── MaintenanceReadonlyGrid ──────────────────────────────────────────────────
/// Grilla responsive de campos de SOLO LECTURA.
/// Desktop: 2 columnas · Móvil: 1 columna.
class MaintenanceReadonlyGrid extends StatelessWidget {
  final bool isMobile;
  final List<ReadonlyItem> items;

  const MaintenanceReadonlyGrid({
    super.key,
    required this.isMobile,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: [
          for (final item in items) ...[
            _ReadonlyTile(item: item),
            const SizedBox(height: 10),
          ],
        ],
      );
    }

    // Desktop: pares en Row
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      final right = (i + 1 < items.length) ? items[i + 1] : null;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _ReadonlyTile(item: items[i])),
            const SizedBox(width: 16),
            Expanded(
              child: right != null ? _ReadonlyTile(item: right) : const SizedBox(),
            ),
          ],
        ),
      );
      if (i + 2 < items.length) rows.add(const SizedBox(height: 10));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}

class _ReadonlyTile extends StatelessWidget {
  final ReadonlyItem item;
  const _ReadonlyTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: MaintenanceColors.textSecondary,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: MaintenanceColors.border),
          ),
          child: Text(
            item.value.isEmpty ? '—' : item.value,
            style: const TextStyle(
              fontSize: 13,
              color: MaintenanceColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── MaintenanceEditableGrid ──────────────────────────────────────────────────
/// Grilla responsive de campos EDITABLES.
/// Desktop: 2 columnas · Móvil: 1 columna.
class MaintenanceEditableGrid extends StatelessWidget {
  final bool isMobile;
  final List<Widget> children;

  const MaintenanceEditableGrid({
    super.key,
    required this.isMobile,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: [
          for (final child in children) ...[
            child,
            const SizedBox(height: 12),
          ],
        ],
      );
    }

    final rows = <Widget>[];
    for (int i = 0; i < children.length; i += 2) {
      final right = (i + 1 < children.length) ? children[i + 1] : null;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: children[i]),
            const SizedBox(width: 16),
            Expanded(child: right ?? const SizedBox()),
          ],
        ),
      );
      if (i + 2 < children.length) rows.add(const SizedBox(height: 12));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}

// ─── MaintenanceFormField ─────────────────────────────────────────────────────
/// Clase de fábrica estática para construir campos de formulario con:
/// · Etiqueta superior
/// · Validación inline (error debajo del campo exacto)
/// · Estilo consistente con el design system
class MaintenanceFormField {
  MaintenanceFormField._(); // No instanciable

  // ── InputDecoration base ──────────────────────────────────────────────────
  static InputDecoration _dec({
    required String hint,
    String? suffixText,
    IconData? prefixIcon,
    bool hasError = false,
  }) {
    final normalBorder = hasError ? MaintenanceColors.error : MaintenanceColors.border;
    final activeBorder = hasError ? MaintenanceColors.error : MaintenanceColors.primary;

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 13,
        color: MaintenanceColors.textSecondary,
      ),
      suffixText: suffixText,
      suffixStyle: const TextStyle(
        fontSize: 12,
        color: MaintenanceColors.textSecondary,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 16, color: MaintenanceColors.textSecondary)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      isDense: true,
      // Ocultamos el mensaje de error nativo del TextFormField;
      // lo mostramos nosotros debajo con estilo propio.
      errorStyle: const TextStyle(height: 0, fontSize: 0),
      counterText: '',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: normalBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: normalBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: activeBorder, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: MaintenanceColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: MaintenanceColors.error, width: 1.5),
      ),
    );
  }

  // ── Wrapper label + campo + error inline ──────────────────────────────────
  static Widget _wrap({
    required String label,
    required Widget field,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: MaintenanceColors.textPrimary,
          ),
        ),
        const SizedBox(height: 5),
        field,
        // Inline validation — aparece debajo del campo exacto que falló
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 12,
                color: MaintenanceColors.error,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  errorText,
                  style: const TextStyle(
                    fontSize: 11,
                    color: MaintenanceColors.error,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CAMPOS PÚBLICOS
  // ══════════════════════════════════════════════════════════════════════════

  /// Campo de texto libre — soporta multiline
  static Widget text({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? errorText,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
    int maxLines = 1,
    int? maxLength,
  }) {
    return _wrap(
      label: label,
      errorText: errorText,
      field: TextFormField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        style: const TextStyle(fontSize: 13, color: MaintenanceColors.textPrimary),
        decoration: _dec(hint: hint, hasError: errorText != null),
        onChanged: onChanged,
        validator: validator,
        textInputAction:
            maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
      ),
    );
  }

  /// Campo numérico — solo dígitos enteros
  static Widget number({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? errorText,
    void Function(String)? onChanged,
    String? suffix,
  }) {
    return _wrap(
      label: label,
      errorText: errorText,
      field: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 13, color: MaintenanceColors.textPrimary),
        decoration: _dec(
          hint: hint,
          suffixText: suffix,
          hasError: errorText != null,
        ),
        onChanged: onChanged,
        textInputAction: TextInputAction.next,
      ),
    );
  }

  /// Campo de fecha — solo lectura, abre DatePicker al tocar
  static Widget date({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? errorText,
    VoidCallback? onTap,
    void Function(String?)? onValidate,
  }) {
    return _wrap(
      label: label,
      errorText: errorText,
      field: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: IgnorePointer(
          child: TextFormField(
            controller: controller,
            readOnly: true,
            style: const TextStyle(fontSize: 13, color: MaintenanceColors.textPrimary),
            decoration: _dec(
              hint: hint,
              prefixIcon: Icons.calendar_today_outlined,
              hasError: errorText != null,
            ),
            validator: onValidate != null
                ? (v) {
                    onValidate(v);
                    // Devolvemos el errorText para activar el estado visual del campo
                    return (errorText != null && errorText.isNotEmpty) ? '' : null;
                  }
                : null,
          ),
        ),
      ),
    );
  }

  /// Campo dropdown con lista de strings
  static Widget dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required String hint,
    String? errorText,
    required void Function(String?) onChanged,
  }) {
    final normalBorder = errorText != null
        ? MaintenanceColors.error
        : MaintenanceColors.border;

    return _wrap(
      label: label,
      errorText: errorText,
      field: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
          errorStyle: const TextStyle(height: 0, fontSize: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: normalBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: normalBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: MaintenanceColors.primary,
              width: 1.5,
            ),
          ),
        ),
        hint: Text(
          hint,
          style: const TextStyle(
            fontSize: 13,
            color: MaintenanceColors.textSecondary,
          ),
        ),
        items: items
            .map(
              (s) => DropdownMenuItem(
                value: s,
                child: Text(
                  s,
                  style: const TextStyle(
                    fontSize: 13,
                    color: MaintenanceColors.textPrimary,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        dropdownColor: Colors.white,
        style: const TextStyle(
          fontSize: 13,
          color: MaintenanceColors.textPrimary,
        ),
      ),
    );
  }
}