import 'package:flutter/material.dart';
import 'food_item.dart' as food_model;

enum MealType { breakfast, lunch, dinner, snack }

class NutritionInfo {
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double saturatedFat;
  final double sodium;
  final Map<String, double> vitamins;
  final Map<String, double> minerals;

  NutritionInfo({
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.fiber = 0,
    this.sugar = 0,
    this.saturatedFat = 0,
    this.sodium = 0,
    this.vitamins = const {},
    this.minerals = const {},
  });
}

class FoodDiaryEntry {
  final String id;
  final String userId;
  final food_model.FoodItem foodItem;
  final double servingAmount;
  final MealType mealType;
  final DateTime consumedAt;
  final String? notes;
  final Map<String, dynamic> customNutrition;
  final bool isCustomEntry;

  NutritionInfo get actualNutrition {
    final baseNutrition = foodItem.nutritionInfo;
    return NutritionInfo(
      calories: (baseNutrition.calories * servingAmount).round(),
      protein: baseNutrition.protein * servingAmount,
      carbs: baseNutrition.carbs * servingAmount,
      fat: baseNutrition.fat * servingAmount,
      fiber: baseNutrition.fiber * servingAmount,
      sugar: baseNutrition.sugar * servingAmount,
      saturatedFat: baseNutrition.saturatedFat * servingAmount,
      sodium: baseNutrition.sodium * servingAmount,
      vitamins: Map<String, double>.fromEntries(
        baseNutrition.vitamins.entries.map(
          (e) => MapEntry(e.key, e.value * servingAmount),
        ),
      ),
      minerals: Map<String, double>.fromEntries(
        baseNutrition.minerals.entries.map(
          (e) => MapEntry(e.key, e.value * servingAmount),
        ),
      ),
    );
  }

  FoodDiaryEntry({
    required this.id,
    required this.userId,
    required this.foodItem,
    required this.servingAmount,
    required this.mealType,
    required this.consumedAt,
    this.notes,
    this.customNutrition = const {},
    this.isCustomEntry = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'foodItem': foodItem.toJson(),
      'servingAmount': servingAmount,
      'mealType': mealType.toString().split('.').last,
      'consumedAt': consumedAt.toIso8601String(),
      'notes': notes,
      'customNutrition': customNutrition,
      'isCustomEntry': isCustomEntry,
    };
  }

  factory FoodDiaryEntry.fromJson(Map<String, dynamic> json) {
    return FoodDiaryEntry(
      id: json['id'],
      userId: json['userId'],
      foodItem: food_model.FoodItem.fromJson(json['foodItem']),
      servingAmount: json['servingAmount'],
      mealType: MealType.values.firstWhere(
        (e) => e.toString() == 'MealType.${json['mealType']}',
      ),
      consumedAt: DateTime.parse(json['consumedAt']),
      notes: json['notes'],
      customNutrition: json['customNutrition'] ?? {},
      isCustomEntry: json['isCustomEntry'] ?? false,
    );
  }

  IconData get mealTypeIcon {
    switch (mealType) {
      case MealType.breakfast:
        return Icons.free_breakfast;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.cookie;
    }
  }
}

class DailyFoodSummary {
  final String userId;
  final DateTime date;
  final List<FoodDiaryEntry> entries;

  DailyFoodSummary({
    required this.userId,
    required this.date,
    required this.entries,
  });

  Map<String, List<FoodDiaryEntry>> get entriesByMeal {
    return {
      for (var type in MealType.values)
        type.toString().split('.').last:
            entries.where((e) => e.mealType == type).toList(),
    };
  }

  NutritionInfo get totalNutrition {
    if (entries.isEmpty) {
      return NutritionInfo();
    }

    return entries.fold<NutritionInfo>(
      NutritionInfo(),
      (total, entry) {
        final nutrition = entry.actualNutrition;
        return NutritionInfo(
          calories: total.calories + nutrition.calories,
          protein: total.protein + nutrition.protein,
          carbs: total.carbs + nutrition.carbs,
          fat: total.fat + nutrition.fat,
          fiber: total.fiber + nutrition.fiber,
          sugar: total.sugar + nutrition.sugar,
          saturatedFat: total.saturatedFat + nutrition.saturatedFat,
          sodium: total.sodium + nutrition.sodium,
          vitamins: _mergeMaps(total.vitamins, nutrition.vitamins),
          minerals: _mergeMaps(total.minerals, nutrition.minerals),
        );
      },
    );
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
