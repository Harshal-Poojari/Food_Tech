import 'package:uuid/uuid.dart';
import '../models/meal_plan.dart';
import '../models/food_diary_entry.dart';
import '../models/food_item.dart';
import 'database_service.dart';
import 'food_diary_service.dart';

class MealPlanService {
  static final MealPlanService _instance = MealPlanService._internal();
  factory MealPlanService() => _instance;
  MealPlanService._internal();

  final DatabaseService _dbService = DatabaseService();
  final FoodDiaryService _diaryService = FoodDiaryService();
  final _uuid = const Uuid();

  // Create a new meal plan
  Future<MealPlan> createMealPlan({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    List<MealPlanItem> items = const [],
    String? notes,
  }) async {
    final mealPlan = MealPlan(
      id: _uuid.v4(),
      userId: userId,
      items: items,
      startDate: startDate,
      endDate: endDate,
      notes: notes,
    );

    await _dbService.setDocument(
      'mealPlans/${mealPlan.id}',
      mealPlan.toJson(),
    );

    return mealPlan;
  }

  // Get all meal plans for a user
  Future<List<MealPlan>> getUserMealPlans(String userId) async {
    final snapshot = await _dbService.getCollection(
      'mealPlans',
      whereField: 'userId',
      whereValue: userId,
    );

    return snapshot.map((doc) => MealPlan.fromJson(doc)).toList();
  }

  // Get active meal plan for a user
  Future<MealPlan?> getActiveMealPlan(String userId) async {
    final snapshot = await _dbService.getCollection(
      'mealPlans',
      whereField: 'userId',
      whereValue: userId,
    );

    final plans = snapshot.map((doc) => MealPlan.fromJson(doc)).toList();
    return plans.isNotEmpty ? plans.first : null;
  }

  // Add item to meal plan
  Future<MealPlan> addItemToMealPlan({
    required String mealPlanId,
    required String userId,
    required FoodItem foodItem,
    required double servingAmount,
    required MealType mealType,
    required DateTime plannedFor,
    String? notes,
  }) async {
    // Get the current meal plan
    final mealPlanDoc = await _dbService.getDocument('mealPlans/$mealPlanId');
    if (mealPlanDoc == null) {
      throw Exception('Meal plan not found');
    }

    final mealPlan = MealPlan.fromJson(mealPlanDoc);

    // Create a new meal plan item
    final newItem = MealPlanItem(
      id: _uuid.v4(),
      userId: userId,
      foodItem: foodItem,
      servingAmount: servingAmount,
      mealType: mealType,
      plannedFor: plannedFor,
      notes: notes,
    );

    // Add the item to the meal plan
    final updatedItems = [...mealPlan.items, newItem];
    final updatedMealPlan = MealPlan(
      id: mealPlan.id,
      userId: mealPlan.userId,
      items: updatedItems,
      startDate: mealPlan.startDate,
      endDate: mealPlan.endDate,
      notes: mealPlan.notes,
    );

    // Update the meal plan in the database
    await _dbService.setDocument(
      'mealPlans/${mealPlan.id}',
      updatedMealPlan.toJson(),
    );

    return updatedMealPlan;
  }

  // Remove item from meal plan
  Future<MealPlan> removeItemFromMealPlan({
    required String mealPlanId,
    required String itemId,
  }) async {
    // Get the current meal plan
    final mealPlanDoc = await _dbService.getDocument('mealPlans/$mealPlanId');
    if (mealPlanDoc == null) {
      throw Exception('Meal plan not found');
    }

    final mealPlan = MealPlan.fromJson(mealPlanDoc);

    // Remove the item from the meal plan
    final updatedItems = mealPlan.items.where((item) => item.id != itemId).toList();
    final updatedMealPlan = MealPlan(
      id: mealPlan.id,
      userId: mealPlan.userId,
      items: updatedItems,
      startDate: mealPlan.startDate,
      endDate: mealPlan.endDate,
      notes: mealPlan.notes,
    );

    // Update the meal plan in the database
    await _dbService.setDocument(
      'mealPlans/${mealPlan.id}',
      updatedMealPlan.toJson(),
    );

    return updatedMealPlan;
  }

  // Mark meal plan item as completed and add to food diary
  Future<void> completeMealPlanItem({
    required String mealPlanId,
    required String itemId,
  }) async {
    // Get the current meal plan
    final mealPlanDoc = await _dbService.getDocument('mealPlans/$mealPlanId');
    if (mealPlanDoc == null) {
      throw Exception('Meal plan not found');
    }

    final mealPlan = MealPlan.fromJson(mealPlanDoc);

    // Find the item
    final item = mealPlan.items.firstWhere((item) => item.id == itemId);
    
    // Create a new item with completed status
    final updatedItem = MealPlanItem(
      id: item.id,
      userId: item.userId,
      foodItem: item.foodItem,
      servingAmount: item.servingAmount,
      mealType: item.mealType,
      plannedFor: item.plannedFor,
      notes: item.notes,
      status: MealPlanStatus.completed,
    );

    // Update the meal plan items
    final updatedItems = mealPlan.items.map((i) {
      return i.id == itemId ? updatedItem : i;
    }).toList();

    final updatedMealPlan = MealPlan(
      id: mealPlan.id,
      userId: mealPlan.userId,
      items: updatedItems,
      startDate: mealPlan.startDate,
      endDate: mealPlan.endDate,
      notes: mealPlan.notes,
    );

    // Update the meal plan in the database
    await _dbService.setDocument(
      'mealPlans/${mealPlan.id}',
      updatedMealPlan.toJson(),
    );

    // Add to food diary
    final diaryEntry = FoodDiaryEntry(
      id: '${item.id}_consumed',
      userId: item.userId,
      foodItem: item.foodItem,
      servingAmount: item.servingAmount,
      mealType: item.mealType,
      consumedAt: DateTime.now(),
      notes: item.notes,
      isCustomEntry: false,
    );
    await _diaryService.addEntry(diaryEntry);
  }

  // Mark meal plan item as skipped
  Future<void> skipMealPlanItem({
    required String mealPlanId,
    required String itemId,
  }) async {
    // Get the current meal plan
    final mealPlanDoc = await _dbService.getDocument('mealPlans/$mealPlanId');
    if (mealPlanDoc == null) {
      throw Exception('Meal plan not found');
    }

    final mealPlan = MealPlan.fromJson(mealPlanDoc);

    // Find the item
    final item = mealPlan.items.firstWhere((item) => item.id == itemId);
    
    // Create a new item with skipped status
    final updatedItem = MealPlanItem(
      id: item.id,
      userId: item.userId,
      foodItem: item.foodItem,
      servingAmount: item.servingAmount,
      mealType: item.mealType,
      plannedFor: item.plannedFor,
      notes: item.notes,
      status: MealPlanStatus.skipped,
    );

    // Update the meal plan items
    final updatedItems = mealPlan.items.map((i) {
      return i.id == itemId ? updatedItem : i;
    }).toList();

    final updatedMealPlan = MealPlan(
      id: mealPlan.id,
      userId: mealPlan.userId,
      items: updatedItems,
      startDate: mealPlan.startDate,
      endDate: mealPlan.endDate,
      notes: mealPlan.notes,
    );

    // Update the meal plan in the database
    await _dbService.setDocument(
      'mealPlans/${mealPlan.id}',
      updatedMealPlan.toJson(),
    );
  }

  // Generate a suggested meal plan based on user preferences and nutritional goals
  Future<MealPlan> generateSuggestedMealPlan({
    required String userId,
    required DateTime startDate,
    required int durationDays,
    required int targetCalories,
    required Map<String, double> macroTargets,
    List<String> preferredCategories = const [],
    List<String> allergies = const [],
  }) async {
    // Get a collection of food items to choose from
    final foodItems = await _dbService.getCollection('foodItems');
    final availableFoods = foodItems
        .map((doc) => FoodItem.fromJson(doc))
        .where((food) {
          // Filter out foods with allergens
          if (allergies.isNotEmpty) {
            return !food.allergens.any((allergen) => allergies.contains(allergen));
          }
          return true;
        })
        .toList();

    // Create a meal plan
    final mealPlan = await createMealPlan(
      userId: userId,
      startDate: startDate,
      endDate: startDate.add(Duration(days: durationDays)),
    );

    // Simple algorithm to distribute calories across meals
    const mealDistribution = {
      MealType.breakfast: 0.25,
      MealType.lunch: 0.35,
      MealType.dinner: 0.30,
      MealType.snack: 0.10,
    };

    // Generate meal plan items for each day
    for (var i = 0; i < durationDays; i++) {
      final day = startDate.add(Duration(days: i));
      
      // For each meal type
      for (final mealType in MealType.values) {
        // Calculate target calories for this meal
        final mealCalories = targetCalories * mealDistribution[mealType]!;
        
        // Select foods for this meal (simplified approach)
        final selectedFoods = _selectFoodsForMeal(
          availableFoods,
          mealCalories,
          preferredCategories,
        );
        
        // Add each food to the meal plan
        for (final food in selectedFoods.entries) {
          await addItemToMealPlan(
            mealPlanId: mealPlan.id,
            userId: userId,
            foodItem: food.key,
            servingAmount: food.value,
            mealType: mealType,
            plannedFor: DateTime(
              day.year,
              day.month,
              day.day,
              _getMealHour(mealType),
            ),
          );
        }
      }
    }

    // Return the updated meal plan
    final updatedMealPlan = await _dbService.getDocument('mealPlans/${mealPlan.id}');
    if (updatedMealPlan == null) {
      throw Exception('Meal plan not found');
    }
    return MealPlan.fromJson(updatedMealPlan);
  }

  // Helper method to select foods for a meal
  Map<FoodItem, double> _selectFoodsForMeal(
    List<FoodItem> availableFoods,
    double targetCalories,
    List<String> preferredCategories,
  ) {
    final result = <FoodItem, double>{};
    double currentCalories = 0;
    
    // Filter by preferred categories if specified
    var foodPool = availableFoods;
    if (preferredCategories.isNotEmpty) {
      foodPool = availableFoods
          .where((food) => preferredCategories.contains(food.category))
          .toList();
      
      // If no foods match preferred categories, fall back to all foods
      if (foodPool.isEmpty) {
        foodPool = availableFoods;
      }
    }
    
    // Shuffle to get random selection
    foodPool.shuffle();
    
    // Select foods until we reach target calories
    for (final food in foodPool) {
      if (currentCalories >= targetCalories) break;
      
      // Calculate how much of this food to add
      final caloriesNeeded = targetCalories - currentCalories;
      final servingsNeeded = caloriesNeeded / food.nutritionInfo.calories;
      
      // Add a reasonable amount (between 0.5 and 2 servings)
      final servings = servingsNeeded.clamp(0.5, 2.0);
      
      result[food] = servings;
      currentCalories += food.nutritionInfo.calories * servings;
      
      // Limit to 3 items per meal for simplicity
      if (result.length >= 3) break;
    }
    
    return result;
  }
  
  // Helper method to get hour for meal type
  int _getMealHour(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return 8;
      case MealType.lunch:
        return 13;
      case MealType.dinner:
        return 19;
      case MealType.snack:
        return 16;
    }
  }
}
