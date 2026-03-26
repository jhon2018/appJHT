// lib/core/widgets/pagination_widget.dart
import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final Function(int) onPageChanged;
  final Function(int) onItemsPerPageChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onPageChanged,
    required this.onItemsPerPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    final bool isTablet = MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1024;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Fila superior: información y selector de items por página
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Información de registros
              Expanded(
                child: Text(
                  'Mostrando ${_getStartItem()} al ${_getEndItem()} de $totalItems proveedores',
                  style: TextStyle(color: Colors.grey[600], fontSize: isMobile ? 11 : 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Selector de items por página
              if (!isMobile) ...[
                const SizedBox(width: 16),
                _buildItemsPerPageSelector(),
              ],
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Paginación responsiva
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPaginationButtons(isMobile || isTablet),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsPerPageSelector() {
    return Row(
      children: [
        Text(
          'Por página:',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: itemsPerPage,
              items: [5, 10, 20, 50].map((value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    value.toString(),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onItemsPerPageChanged(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPaginationButtons(bool isCompact) {
    List<Widget> buttons = [];
    
    // Botón Anterior
    buttons.add(_buildPaginationButton(
      'Anterior',
      isActive: false,
      isEnabled: currentPage > 1,
      onTap: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
    ));

    if (isCompact) {
      // Versión compacta para móvil/tablet
      buttons.add(_buildPaginationButton(
        currentPage.toString(),
        isActive: true,
        isEnabled: true,
        onTap: null,
      ));
      buttons.add(_buildPaginationButton(
        'de $totalPages',
        isActive: false,
        isEnabled: false,
        onTap: null,
      ));
    } else {
      // Versión completa para desktop
      final int startPage = (currentPage - 2).clamp(1, totalPages - 4);
      final int endPage = (startPage + 4).clamp(5, totalPages);

      for (int i = startPage; i <= endPage; i++) {
        buttons.add(_buildPaginationButton(
          i.toString(),
          isActive: i == currentPage,
          isEnabled: true,
          onTap: i == currentPage ? null : () => onPageChanged(i),
        ));
      }
    }

    // Botón Siguiente
    buttons.add(_buildPaginationButton(
      'Siguiente',
      isActive: false,
      isEnabled: currentPage < totalPages,
      onTap: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
    ));

    return buttons;
  }

  Widget _buildPaginationButton(
    String text, {
    required bool isActive,
    required bool isEnabled,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: isActive ? const Color(0xFF303366) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: !isActive ? Border.all(color: Colors.grey[400]!) : null,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : (isEnabled ? Colors.grey[700] : Colors.grey[400]),
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _getStartItem() {
    return ((currentPage - 1) * itemsPerPage) + 1;
  }

  int _getEndItem() {
    return (currentPage * itemsPerPage).clamp(0, totalItems);
  }
}