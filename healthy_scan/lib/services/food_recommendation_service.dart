import '../models/food_item.dart';
import '../models/user_profile.dart';
import '../models/food_diary_entry.dart';
import 'database_service.dart';
import 'nutrition_service.dart';

class FoodRecommendationService {
  static final FoodRecommendationService _instance =
  FoodRecommendationService._internal();
  factory FoodRecommendationService() => _instance;
  FoodRecommendationService._internal();

  final DatabaseService _dbService = DatabaseService();
  final NutritionService _nutritionService = NutritionService();

  Future<List<MapEntry<FoodItem, double>>> getRecommendations({
    required UserProfile userProfile,
    required DailyFoodSummary dailySummary,
    int limit = 5,
    List<String> excludeCategories = const [],
  }) async {
    final foodItems = await _getAllFoodItems();
    final nutritionGaps = _calculateNutritionGaps(userProfile, dailySummary);
    final scoredItems = _scoreFoodItems(foodItems, nutritionGaps, excludeCategories);
    return scoredItems.take(limit).toList();
  }

  Future<List<FoodItem>> _getAllFoodItems() async {
    final snapshot = await _dbService.getCollection('foodItems');
    return snapshot.map((doc) => FoodItem.fromJson(doc)).toList();
  }

  Map<String, double> _calculateNutritionGaps(UserProfile profile, DailyFoodSummary dailySummary) {
    final dailyCalories = _nutritionService.calculateDailyCalorieNeeds(profile);
    final macroTargets = _nutritionService.calculateMacroDistribution(dailyCalories);
    final currentNutrition = dailySummary.totalNutrition;

    return {
      'calories': dailyCalories - currentNutrition.calories.toDouble(),
      'protein': macroTargets['protein']! - currentNutrition.protein,
      'carbs': macroTargets['carbs']! - currentNutrition.carbs,
      'fat': macroTargets['fat']! - currentNutrition.fat,
      'fiber': 25 - currentNutrition.fiber,
    };
  }

  List<MapEntry<FoodItem, double>> _scoreFoodItems(List<FoodItem> foodItems, Map<String, double> nutritionGaps, List<String> excludeCategories) {
    return foodItems
        .where((item) => !excludeCategories.contains(item.category))
        .map((item) => MapEntry(item, _calculateItemScore(item, nutritionGaps)))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..map((entry) => entry.key)
          .toList();
  }

  double _calculateItemScore(FoodItem item, Map<String, double> nutritionGaps) {
    double score = 0;
    final nutrition = item.nutritionInfo;
    final caloriesDouble = nutrition.calories.toDouble();

    if (nutritionGaps['calories']! > 0) {
      score += (caloriesDouble / nutritionGaps['calories']!).clamp(0, 1) * 10;
    }
    if (nutritionGaps['protein']! > 0) {
      score += (nutrition.protein / nutritionGaps['protein']!).clamp(0, 1) * 25;
    }
    if (nutritionGaps['carbs']! > 0) {
      score += (nutrition.carbs / nutritionGaps['carbs']!).clamp(0, 1) * 15;
    }
    if (nutritionGaps['fat']! > 0) {
      score += (nutrition.fat / nutritionGaps['fat']!).clamp(0, 1) * 15;
    }
    if (nutritionGaps['fiber']! > 0) {
      score += (nutrition.fiber / nutritionGaps['fiber']!).clamp(0, 1) * 20;
    }

    if (caloriesDouble > 0) {
      final proteinDensity = nutrition.protein / caloriesDouble;
      final fiberDensity = nutrition.fiber / caloriesDouble;
      score += proteinDensity * 50;
      score += fiberDensity * 50;
    }

    score -= (nutrition.sugar / 10).clamp(0, 5);
    score -= (nutrition.saturatedFat / 5).clamp(0, 5);
    score += (item.healthScore / 20);

    return score;
  }
}
