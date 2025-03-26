import '../models/food_item.dart' as food_model;
import '../models/food_diary_entry.dart';
import '../models/user_profile.dart';

class NutritionService {
  static final NutritionService _instance = NutritionService._internal();
  factory NutritionService() => _instance;
  NutritionService._internal();

  // Calculate daily calorie needs based on user profile
  int calculateDailyCalorieNeeds(UserProfile profile) {
    // Using Mifflin-St Jeor equation for BMR
    final bmr = calculateBMR(profile);

    // Activity level multipliers
    final activityMultiplier = 1.2; // Sedentary by default

    return (bmr * activityMultiplier).round();
  }

  // Calculate Basal Metabolic Rate (BMR)
  double calculateBMR(UserProfile profile) {
    // TODO: Implement BMR calculation based on user stats
    return 2000.0; // Default value
  }

  // Calculate macro distribution based on daily calorie needs
  Map<String, double> calculateMacroDistribution(int dailyCalories) {
    return {
      'protein': (dailyCalories * 0.3) / 4.0, // 30% protein, 4 cal/g
      'carbs': (dailyCalories * 0.4) / 4.0, // 40% carbs, 4 cal/g
      'fat': (dailyCalories * 0.3) / 9.0, // 30% fat, 9 cal/g
    };
  }

  // Calculate nutrition score for a food item (0-100)
  int calculateNutritionScore(food_model.FoodItem item) {
    int score = 50; // Base score
    final nutrition = item.nutritionInfo;

    // Protein quality (up to +20)
    if (nutrition.protein >= 20)
      score += 20;
    else
      score += (nutrition.protein / 20 * 20).round();

    // Fiber content (up to +10)
    if (nutrition.fiber >= 6)
      score += 10;
    else
      score += (nutrition.fiber / 6 * 10).round();

    // Vitamin and mineral content (up to +20)
    final nutrientCount = nutrition.vitamins.length + nutrition.minerals.length;
    if (nutrientCount >= 5)
      score += 20;
    else
      score += (nutrientCount / 5 * 20).round();

    // Sugar penalty (up to -20)
    if (nutrition.sugar > 20)
      score -= 20;
    else
      score -= (nutrition.sugar / 20 * 20).round();

    // Saturated fat penalty (up to -15)
    if (nutrition.saturatedFat > 15)
      score -= 15;
    else
      score -= (nutrition.saturatedFat / 15 * 15).round();

    // Sodium penalty (up to -15)
    if (nutrition.sodium > 1000)
      score -= 15;
    else
      score -= (nutrition.sodium / 1000 * 15).round();

    return score.clamp(0, 100);
  }

  // Calculate Nutri-Score (A to E)
  String calculateNutriScore(food_model.FoodItem item) {
    final score = calculateNutritionScore(item);
    if (score >= 80) return 'A';
    if (score >= 60) return 'B';
    if (score >= 40) return 'C';
    if (score >= 20) return 'D';
    return 'E';
  }

  // Analyze meal balance
  Map<String, dynamic> analyzeMealBalance(List<FoodDiaryEntry> entries) {
    if (entries.isEmpty) {
      return {'balanced': true, 'issues': []};
    }

    var totalNutrition = entries.fold<food_model.NutritionInfo>(
      food_model.NutritionInfo(),
      (total, entry) {
        final actual = entry.actualNutrition;
        return food_model.NutritionInfo(
          calories: total.calories + actual.calories,
          protein: total.protein + actual.protein,
          fat: total.fat + actual.fat,
          saturatedFat: total.saturatedFat + actual.saturatedFat,
          carbs: total.carbs + actual.carbs,
          sugar: total.sugar + actual.sugar,
          fiber: total.fiber + actual.fiber,
          sodium: total.sodium + actual.sodium,
          vitamins: _mergeMaps(total.vitamins, actual.vitamins),
          minerals: _mergeMaps(total.minerals, actual.minerals),
        );
      },
    );

    // Calculate macro percentages
    final totalCalories = totalNutrition.calories;
    final proteinPercent = (totalNutrition.protein * 4 / totalCalories) * 100;
    final carbsPercent = (totalNutrition.carbs * 4 / totalCalories) * 100;
    final fatPercent = (totalNutrition.fat * 9 / totalCalories) * 100;

    // Check balance
    final isBalanced = _isInRange(proteinPercent, 20, 35) &&
        _isInRange(carbsPercent, 45, 65) &&
        _isInRange(fatPercent, 20, 35);

    // Generate suggestions
    final suggestions = <String>[];
    if (proteinPercent < 20) {
      suggestions.add('Add more protein-rich foods');
    }
    if (carbsPercent < 45) {
      suggestions.add('Include more complex carbohydrates');
    }
    if (fatPercent < 20) {
      suggestions.add('Add healthy fats');
    }
    if (totalNutrition.fiber < 7) {
      suggestions.add('Include more fiber-rich foods');
    }

    return {
      'isBalanced': isBalanced,
      'totalCalories': totalCalories,
      'macroDistribution': {
        'protein': proteinPercent,
        'carbs': carbsPercent,
        'fat': fatPercent,
      },
      'fiberContent': totalNutrition.fiber,
      'suggestions': suggestions,
    };
  }

  // Check if nutrient conflicts with medications or conditions
  List<String> checkNutrientConflicts(
    food_model.FoodItem item,
    List<String> medications,
    List<String> conditions,
  ) {
    final conflicts = <String>[];

    // Example conflicts (to be expanded based on medical data)
    if (medications.contains('warfarin') &&
        item.nutritionInfo.vitamins.containsKey('K')) {
      conflicts.add(
        'High vitamin K content may interact with warfarin',
      );
    }

    if (conditions.contains('hypertension') &&
        item.nutritionInfo.sodium > 400) {
      conflicts.add('High sodium content may affect blood pressure');
    }

    return conflicts;
  }

  // Generate personalized nutrition tips
  List<String> generateNutritionTips(
      UserProfile profile, DailyFoodSummary summary) {
    final tips = <String>[];
    final total = summary.totalNutrition;

    // Check protein intake
    if (total.protein < profile.preferences.dailyCalorieTarget * 0.3 / 4) {
      tips.add('Try to increase your protein intake');
    }

    // Check fiber intake
    if (total.fiber < 25) {
      tips.add('Add more fiber-rich foods to your diet');
    }

    // Check water intake (if tracked)
    tips.add('Remember to stay hydrated throughout the day');

    // Check meal timing
    if (summary.entriesByMeal[MealType.breakfast]?.isEmpty ?? true) {
      tips.add("Don't skip breakfast - it's important for a healthy start");
    }

    return tips;
  }

  // Helper methods
  bool _isInRange(double value, double min, double max) {
    return value >= min && value <= max;
  }

  Map<String, double> _mergeMaps(
    Map<String, double> map1,
    Map<String, double> map2,
  ) {
    final result = Map<String, double>.from(map1);
    map2.forEach((key, value) {
      result[key] = (result[key] ?? 0) + value;
    });
    return result;
  }
}
