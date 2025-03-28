import 'food_item.dart' as food_model;
import 'food_diary_entry.dart' as diary_model;

enum MealPlanStatus { pending, completed, skipped }

class MealPlanItem {
  final String id;
  final String userId;
  final food_model.FoodItem foodItem;
  final double servingAmount;
  final diary_model.MealType mealType;
  final DateTime plannedFor;
  final String? notes;
  final MealPlanStatus status;
  
  MealPlanItem({
    required this.id,
    required this.userId,
    required this.foodItem,
    required this.servingAmount,
    required this.mealType,
    required this.plannedFor,
    this.notes,
    this.status = MealPlanStatus.pending,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'foodItem': foodItem.toJson(),
      'servingAmount': servingAmount,
      'mealType': mealType.toString().split('.').last,
      'plannedFor': plannedFor.toIso8601String(),
      'notes': notes,
      'status': status.toString().split('.').last,
    };
  }
  
  factory MealPlanItem.fromJson(Map<String, dynamic> json) {
    return MealPlanItem(
      id: json['id'],
      userId: json['userId'],
      foodItem: food_model.FoodItem.fromJson(json['foodItem']),
      servingAmount: json['servingAmount'].toDouble(),
      mealType: diary_model.MealType.values.firstWhere(
        (e) => e.toString() == 'MealType.${json['mealType']}',
      ),
      plannedFor: DateTime.parse(json['plannedFor']),
      notes: json['notes'],
      status: MealPlanStatus.values.firstWhere(
        (e) => e.toString() == 'MealPlanStatus.${json['status']}',
        orElse: () => MealPlanStatus.pending,
      ),
    );
  }

  diary_model.NutritionInfo get nutritionInfo {
    final baseNutrition = foodItem.nutritionInfo;
    
    final multiplier = servingAmount / foodItem.servingSize;
    return diary_model.NutritionInfo(
      calories: (baseNutrition.calories * multiplier).round(),
      protein: baseNutrition.protein * multiplier,
      carbs: baseNutrition.carbs * multiplier,
      fat: baseNutrition.fat * multiplier,
      fiber: baseNutrition.fiber * multiplier,
      sugar: baseNutrition.sugar * multiplier,
      saturatedFat: baseNutrition.saturatedFat * multiplier,
      sodium: baseNutrition.sodium * multiplier,
    );
  }
}

class MealPlan {
  final String id;
  final String userId;
  final List<MealPlanItem> items;
  final DateTime startDate;
  final DateTime endDate;
  final String? notes;

  MealPlan({
    required this.id,
    required this.userId,
    required this.items,
    required this.startDate,
    required this.endDate,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'notes': notes,
    };
  }

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'],
      userId: json['userId'],
      items: (json['items'] as List)
          .map((item) => MealPlanItem.fromJson(item))
          .toList(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      notes: json['notes'],
    );
  }

  List<MealPlanItem> getItemsForDay(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return items.where((item) {
      final itemDate = DateTime(
        item.plannedFor.year,
        item.plannedFor.month,
        item.plannedFor.day,
      );
      return itemDate == dateOnly;
    }).toList();
  }

  diary_model.NutritionInfo? getNutritionForDay(DateTime date) {
    final dayItems = getItemsForDay(date);
    if (dayItems.isEmpty) return null;

    var totalNutrition = diary_model.NutritionInfo(
      calories: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      fiber: 0,
      sugar: 0,
      saturatedFat: 0,
      sodium: 0,
    );

    for (var item in dayItems) {
      final itemNutrition = item.nutritionInfo;
      totalNutrition = diary_model.NutritionInfo(
        calories: totalNutrition.calories + itemNutrition.calories,
        protein: totalNutrition.protein + itemNutrition.protein,
        carbs: totalNutrition.carbs + itemNutrition.carbs,
        fat: totalNutrition.fat + itemNutrition.fat,
        fiber: totalNutrition.fiber + itemNutrition.fiber,
        sugar: totalNutrition.sugar + itemNutrition.sugar,
        saturatedFat: totalNutrition.saturatedFat + itemNutrition.saturatedFat,
        sodium: totalNutrition.sodium + itemNutrition.sodium,
      );
    }

    return totalNutrition;
  }
}
