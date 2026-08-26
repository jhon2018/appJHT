import 'package:flutter/material.dart';

class TopItemData {
  final String title;
  final double costoTotal;

  TopItemData({required this.title, required this.costoTotal});
}

class HistorialTopList extends StatelessWidget {
  final List<TopItemData> data;

  const HistorialTopList({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Sin datos para mostrar',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: data.length,
      separatorBuilder: (context, index) => const Divider(color: Color(0xFFE0E0E8), height: 1),
      itemBuilder: (context, index) {
        final item = data[index];
        final rank = index + 1;
        
        Color rankColor;
        if (rank == 1) rankColor = const Color(0xFFF59E0B); // Oro
        else if (rank == 2) rankColor = const Color(0xFF94A3B8); // Plata
        else if (rank == 3) rankColor = const Color(0xFFB45309); // Bronce
        else rankColor = const Color(0xFF475569);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: rankColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      color: rankColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'S/${item.costoTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFDC2626), // error color for cost (red for expense)
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
