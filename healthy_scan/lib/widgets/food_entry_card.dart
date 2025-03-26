import 'package:flutter/material.dart';
import '../models/food_diary_entry.dart';
import '../utils/helpers.dart';

class FoodEntryCard extends StatelessWidget {
  final FoodDiaryEntry entry;
  final VoidCallback? onDelete;

  const FoodEntryCard({
    super.key,
    required this.entry,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIndianFood = _isIndianFood(entry.foodItem.name);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF05102C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isIndianFood
              ? Theme.of(context).colorScheme.secondary.withOpacity(0.3)
              : Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isIndianFood
                ? Theme.of(context).colorScheme.secondary.withOpacity(0.2)
                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Navigate to food details screen
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${entry.foodItem.name} details coming soon!'),
                backgroundColor: const Color(0xFF0A1128),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Food image or icon
                _buildFoodImage(context, isIndianFood),
                const SizedBox(width: 12),

                // Food details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food name and time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                if (isIndianFood) ...[
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 14,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Expanded(
                                  child: Text(
                                    entry.foodItem.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _formatTime(entry.consumedAt),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (entry.foodItem.brand != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            entry.foodItem.brand!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      const SizedBox(height: 8),

                      // Quantity and calories
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isIndianFood
                                  ? Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.15)
                                  : Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${entry.foodItem.servingSize} ${entry.foodItem.servingUnit}',
                              style: TextStyle(
                                fontSize: 13,
                                color: isIndianFood
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          _buildNutritionChip(
                              context, entry.actualNutrition.calories.toInt(), isIndianFood),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Nutrients chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildNutrientChip(
                              'P',
                              entry.customNutrition['protein']!
                                      .toStringAsFixed(1) +
                                  'g',
                              Colors.blue,
                              context,
                            ),
                            const SizedBox(width: 6),
                            _buildNutrientChip(
                              'C',
                              entry.customNutrition['carbs']!
                                      .toStringAsFixed(1) +
                                  'g',
                              Colors.orange,
                              context,
                            ),
                            const SizedBox(width: 6),
                            _buildNutrientChip(
                              'F',
                              entry.customNutrition['fat']!.toStringAsFixed(1) +
                                  'g',
                              Colors.purple,
                              context,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Delete icon (if onDelete is provided)
                if (onDelete != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: onDelete,
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      splashRadius: 20,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFoodImage(BuildContext context, bool isIndianFood) {
    final indianFoodIcons = {
      'masala dosa': Icons.panorama_fish_eye,
      'sambar': Icons.soup_kitchen,
      'idli': Icons.circle,
      'chole bhature': Icons.grain,
      'biryani': Icons.dinner_dining,
      'naan': Icons.breakfast_dining,
      'butter chicken': Icons.lunch_dining,
      'paneer tikka': Icons.restaurant,
      'palak paneer': Icons.spa,
      'jeera rice': Icons.rice_bowl,
      'samosa': Icons.change_history,
      'pakora': Icons.circle,
      'masala chai': Icons.coffee,
    };

    IconData foodIcon = entry.mealTypeIcon;

    // Get specific icon for indian foods
    if (isIndianFood) {
      for (final food in indianFoodIcons.keys) {
        if (entry.foodItem.name.toLowerCase().contains(food)) {
          foodIcon = indianFoodIcons[food]!;
          break;
        }
      }
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isIndianFood
            ? Theme.of(context).colorScheme.secondary.withOpacity(0.2)
            : Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isIndianFood
              ? Theme.of(context).colorScheme.secondary.withOpacity(0.3)
              : Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: isIndianFood
            ? [
                BoxShadow(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ]
            : [],
        image: entry.foodItem.imageUrl != null
            ? DecorationImage(
                image: NetworkImage(entry.foodItem.imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: entry.foodItem.imageUrl == null
          ? Center(
              child: Icon(
                foodIcon,
                color: isIndianFood
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            )
          : null,
    );
  }

  Widget _buildNutritionChip(
      BuildContext context, int calories, bool isIndianFood) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isIndianFood
            ? Colors.orange.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isIndianFood
              ? Colors.orange.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department,
            size: 14,
            color: isIndianFood ? Colors.orange : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            '$calories',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isIndianFood ? Colors.orange : Colors.red,
            ),
          ),
          Text(
            ' kcal',
            style: TextStyle(
              fontSize: 12,
              color:
                  (isIndianFood ? Colors.orange : Colors.red).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientChip(
      String label, String value, Color color, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return DateTimeHelpers.formatTime(time);
  }

  bool _isIndianFood(String foodName) {
    final indianFoods = [
      'masala dosa',
      'dosa',
      'sambar',
      'idli',
      'chole',
      'bhature',
      'biryani',
      'naan',
      'butter chicken',
      'paneer',
      'palak',
      'jeera rice',
      'samosa',
      'pakora',
      'chai',
      'tikka'
    ];

    final lowerCaseName = foodName.toLowerCase();
    return indianFoods.any((food) => lowerCaseName.contains(food));
  }
}
