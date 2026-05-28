// lib/core/widgets/pagination_widget.dart
import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final Function(int) onPageChanged;
  final Function(int) onItemsPerPageChanged;
  /// Texto que aparece en "Mostrando X al Y de Z [label]"
  final String itemLabel;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onPageChanged,
    required this.onItemsPerPageChanged,
    this.itemLabel = 'registros',
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 768;
    final bool isTablet =
        MediaQuery.sizeOf(context).width >= 768 &&
        MediaQuery.sizeOf(context).width < 1024;

    return Column(
      children: [
        // Fila superior: info + selector por página
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                totalItems == 0
                    ? 'Sin $itemLabel'
                    : 'Mostrando ${_startItem()} – ${_endItem()} de $totalItems $itemLabel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isMobile ? 11 : 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!isMobile) ...[
              const SizedBox(width: 16),
              _buildItemsPerPageSelector(),
            ],
          ],
        ),

        const SizedBox(height: 12),

        // Botones de página
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildButtons(isMobile || isTablet),
          ),
        ),

        // Selector por página en móvil (debajo)
        if (isMobile) ...[
          const SizedBox(height: 12),
          _buildItemsPerPageSelector(),
        ],
      ],
    );
  }

  Widget _buildItemsPerPageSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Por página:', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: itemsPerPage,
              isDense: true,
              items: [5, 10, 20, 50].map((v) => DropdownMenuItem(
                value: v,
                child: Text(
                  v.toString(),
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              )).toList(),
              onChanged: (v) { if (v != null) onItemsPerPageChanged(v); },
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildButtons(bool compact) {
    final buttons = <Widget>[];

    // ── Anterior ──────────────────────────────────────────────────────────
    buttons.add(_pageBtn(
      icon: Icons.chevron_left_rounded,
      label: 'Anterior',
      isActive: false,
      enabled: currentPage > 1,
      onTap: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
      showLabel: !compact,
    ));

    // ── Números ───────────────────────────────────────────────────────────
    if (compact) {
      // Compacto: solo "página actual / total"
      buttons.add(_numberBtn(currentPage, isActive: true));
      buttons.add(_labelBtn('/ $totalPages'));
    } else {
      // Desktop: ventana deslizante de hasta 5 páginas
      final pages = _visiblePages();
      if (pages.first > 1) {
        buttons.add(_numberBtn(1));
        if (pages.first > 2) buttons.add(_labelBtn('…'));
      }
      for (final p in pages) {
        buttons.add(_numberBtn(p, isActive: p == currentPage));
      }
      if (pages.last < totalPages) {
        if (pages.last < totalPages - 1) buttons.add(_labelBtn('…'));
        buttons.add(_numberBtn(totalPages));
      }
    }

    // ── Siguiente ─────────────────────────────────────────────────────────
    buttons.add(_pageBtn(
      icon: Icons.chevron_right_rounded,
      label: 'Siguiente',
      isActive: false,
      enabled: currentPage < totalPages,
      onTap: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
      showLabel: !compact,
    ));

    return buttons;
  }

  List<int> _visiblePages() {
    const window = 5;
    int start = (currentPage - 2).clamp(1, (totalPages - window + 1).clamp(1, totalPages));
    int end = (start + window - 1).clamp(1, totalPages);
    return List.generate(end - start + 1, (i) => start + i);
  }

  Widget _numberBtn(int page, {bool isActive = false}) {
    return _btn(
      child: Text(
        page.toString(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
          color: isActive ? Colors.white : Colors.grey[700],
        ),
      ),
      isActive: isActive,
      enabled: !isActive,
      onTap: isActive ? null : () => onPageChanged(page),
    );
  }

  Widget _labelBtn(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
    );
  }

  Widget _pageBtn({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool enabled,
    VoidCallback? onTap,
    bool showLabel = true,
  }) {
    return _btn(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon == Icons.chevron_left_rounded) Icon(icon, size: 16, color: enabled ? Colors.grey[700] : Colors.grey[400]),
          if (showLabel) ...[
            if (icon == Icons.chevron_left_rounded) const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: enabled ? Colors.grey[700] : Colors.grey[400],
              ),
            ),
            if (icon == Icons.chevron_right_rounded) const SizedBox(width: 2),
          ],
          if (icon == Icons.chevron_right_rounded) Icon(icon, size: 16, color: enabled ? Colors.grey[700] : Colors.grey[400]),
        ],
      ),
      isActive: isActive,
      enabled: enabled,
      onTap: onTap,
    );
  }

  Widget _btn({
    required Widget child,
    required bool isActive,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: isActive ? const Color(0xFF303366) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              border: !isActive
                  ? Border.all(color: enabled ? Colors.grey[300]! : Colors.grey[200]!)
                  : null,
              borderRadius: BorderRadius.circular(6),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  int _startItem() => ((currentPage - 1) * itemsPerPage) + 1;
  int _endItem() => (currentPage * itemsPerPage).clamp(0, totalItems);
}