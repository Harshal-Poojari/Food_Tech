import 'package:flutter/material.dart';

class NutritionProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final double percentage;
  final Color color;

  const NutritionProgressBar({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '${value.toStringAsFixed(1)} $unit (${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage > 100 ? 1.0 : percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
