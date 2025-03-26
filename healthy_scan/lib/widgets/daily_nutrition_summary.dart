import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DailyNutritionSummary extends StatelessWidget {
  final int calories;
  final double proteinPercentage;
  final double carbsPercentage;
  final double fatPercentage;

  const DailyNutritionSummary({
    super.key,
    required this.calories,
    required this.proteinPercentage,
    required this.carbsPercentage,
    required this.fatPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final double caloriesPercentage = (calories / 2000 * 100).clamp(0.0, 100.0);
    final int remainingCalories = 2000 - calories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calories section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$calories',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'calories consumed',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '$remainingCalories remaining',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Calories progress bar
        _buildProgressBar(caloriesPercentage, context),
        const SizedBox(height: 24),

        // Macronutrients
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'MACRONUTRIENTS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildMacronutrientsSection(context),
      ],
    );
  }

  Widget _buildProgressBar(double percentage, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${percentage.toInt()}% of daily goal',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildMacronutrientsSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMacroItem(
            'Protein',
            proteinPercentage,
            Colors.blue.shade400,
            context,
          ),
        ),
        Expanded(
          child: _buildMacroItem(
            'Carbs',
            carbsPercentage,
            Colors.green.shade400,
            context,
          ),
        ),
        Expanded(
          child: _buildMacroItem(
            'Fat',
            fatPercentage,
            Colors.purple.shade300,
            context,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroItem(
    String name,
    double percentage,
    Color color,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
              border: Border.all(
                color: color.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${(percentage * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
