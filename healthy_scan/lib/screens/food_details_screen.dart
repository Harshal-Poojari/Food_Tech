import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../utils/helpers.dart';
import '../widgets/nutrition_info_card.dart';
// import '../widgets/ingredient_list.dart';
import '../widgets/allergen_warning.dart';

class FoodDetailsScreen extends StatelessWidget {
  final FoodItem foodItem;

  const FoodDetailsScreen({
    Key? key,
    required this.foodItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(StringHelpers.truncate(foodItem.name, 30)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (foodItem.imageUrl != null && foodItem.imageUrl!.isNotEmpty)
              Image.network(
                foodItem.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodItem.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (foodItem.brand != null && foodItem.brand!.isNotEmpty)
                    Text(
                      foodItem.brand!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          'Nutri-Score ${foodItem.nutriScore.toString().split('.').last}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: NutritionHelpers.getNutriScoreColor(
                          foodItem.nutriScore,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          'Health Score: ${foodItem.healthScore}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: NutritionHelpers.getHealthScoreColor(
                          foodItem.healthScore,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nutrition Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Per ${foodItem.servingSize} ${foodItem.servingUnit}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Divider(),
                          NutrientRow(
                            'Calories',
                            NutritionHelpers.formatCalories(
                              foodItem.nutritionInfo.calories,
                            ),
                          ),
                          NutrientRow(
                            'Protein',
                            NutritionHelpers.formatMacroNutrient(
                              foodItem.nutritionInfo.protein,
                            ),
                          ),
                          NutrientRow(
                            'Carbs',
                            NutritionHelpers.formatMacroNutrient(
                              foodItem.nutritionInfo.carbs,
                            ),
                          ),
                          NutrientRow(
                            'Fat',
                            NutritionHelpers.formatMacroNutrient(
                              foodItem.nutritionInfo.fat,
                            ),
                          ),
                          NutrientRow(
                            'Fiber',
                            NutritionHelpers.formatMacroNutrient(
                              foodItem.nutritionInfo.fiber,
                            ),
                          ),
                          NutrientRow(
                            'Sugar',
                            NutritionHelpers.formatMacroNutrient(
                              foodItem.nutritionInfo.sugar,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (foodItem.ingredients.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Ingredients',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(foodItem.ingredients.join(', ')),
                      ),
                    ),
                  ],
                  if (foodItem.allergens.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Allergens',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          foodItem.allergens.join(', '),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (foodItem.additives.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Additives',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(foodItem.additives.join(', ')),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Additional Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (foodItem.barcode != null && foodItem.barcode!.isNotEmpty)
                            InfoRow('Barcode', foodItem.barcode!),
                          if (foodItem.category.isNotEmpty)
                            InfoRow('Category', foodItem.category),
                          InfoRow(
                            'Health Rating',
                            NutritionHelpers.getHealthScoreLabel(
                              foodItem.healthScore,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NutrientRow extends StatelessWidget {
  final String label;
  final String value;

  const NutrientRow(this.label, this.value, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow(this.label, this.value, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }
}
