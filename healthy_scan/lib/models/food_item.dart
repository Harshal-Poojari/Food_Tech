import 'package:flutter/material.dart';

enum NutriScore { A, B, C, D, E }

class NutritionInfo {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double saturatedFat;
  final double sodium;
  final Map<String, double> vitamins;
  final Map<String, double> minerals;

  const NutritionInfo({
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

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'saturatedFat': saturatedFat,
      'sodium': sodium,
      'vitamins': vitamins,
      'minerals': minerals,
    };
  }

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: json['calories']?.toDouble() ?? 0,
      protein: json['protein']?.toDouble() ?? 0,
      carbs: json['carbs']?.toDouble() ?? 0,
      fat: json['fat']?.toDouble() ?? 0,
      fiber: json['fiber']?.toDouble() ?? 0,
      sugar: json['sugar']?.toDouble() ?? 0,
      saturatedFat: json['saturatedFat']?.toDouble() ?? 0,
      sodium: json['sodium']?.toDouble() ?? 0,
      vitamins: Map<String, double>.from(json['vitamins'] ?? {}),
      minerals: Map<String, double>.from(json['minerals'] ?? {}),
    );
  }
}

class FoodItem {
  final String id;
  final String name;
  final String? barcode;
  final String? brand;
  final String category;
  final String? imageUrl;
  final double servingSize;
  final String servingUnit;
  final NutritionInfo nutritionInfo;
  final NutriScore nutriScore;
  final int healthScore;
  final List<String> ingredients;
  final List<String> allergens;
  final List<String> additives;
  final Map<String, dynamic> metadata;
  final DateTime? scannedAt;

  const FoodItem({
    required this.id,
    required this.name,
    this.barcode,
    this.brand,
    required this.category,
    this.imageUrl,
    required this.servingSize,
    required this.servingUnit,
    required this.nutritionInfo,
    required this.nutriScore,
    required this.healthScore,
    this.ingredients = const [],
    this.allergens = const [],
    this.additives = const [],
    this.metadata = const {},
    this.scannedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'brand': brand,
      'category': category,
      'imageUrl': imageUrl,
      'servingSize': servingSize,
      'servingUnit': servingUnit,
      'nutritionInfo': nutritionInfo.toJson(),
      'nutriScore': nutriScore.toString().split('.').last,
      'healthScore': healthScore,
      'ingredients': ingredients,
      'allergens': allergens,
      'additives': additives,
      'metadata': metadata,
      'scannedAt': scannedAt?.toIso8601String(),
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      barcode: json['barcode'],
      brand: json['brand'],
      category: json['category'],
      imageUrl: json['imageUrl'],
      servingSize: json['servingSize']?.toDouble() ?? 0,
      servingUnit: json['servingUnit'],
      nutritionInfo: NutritionInfo.fromJson(json['nutritionInfo']),
      nutriScore: NutriScore.values.firstWhere(
        (e) => e.toString() == 'NutriScore.${json['nutriScore']}',
      ),
      healthScore: json['healthScore'],
      ingredients: List<String>.from(json['ingredients'] ?? []),
      allergens: List<String>.from(json['allergens'] ?? []),
      additives: List<String>.from(json['additives'] ?? []),
      metadata: json['metadata'] ?? {},
      scannedAt: json['scannedAt'] != null ? DateTime.parse(json['scannedAt']) : null,
    );
  }
}
