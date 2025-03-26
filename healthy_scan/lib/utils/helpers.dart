import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/food_item.dart';
import '../models/food_diary_entry.dart';

class DateTimeHelpers {
  static String formatDate(DateTime date) {
    return DateFormat('MMMM d, y').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMMM d, y h:mm a').format(dateTime);
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }
}

class NutritionHelpers {
  static String formatNutrientValue(double value, {bool showDecimals = true}) {
    if (showDecimals) {
      return value.toStringAsFixed(1);
    }
    return value.round().toString();
  }

  static String formatCalories(double calories) {
    return '${calories.round()} kcal';
  }

  static String formatMacroNutrient(double value) {
    return '${value.toStringAsFixed(1)}g';
  }

  static String formatMicroNutrient(double value, String unit) {
    return '${value.toStringAsFixed(1)}$unit';
  }

  static String formatPercentage(double value) {
    return '${(value * 100).round()}%';
  }

  static Color getNutriScoreColor(NutriScore score) {
    switch (score) {
      case NutriScore.A:
        return Colors.green;
      case NutriScore.B:
        return Colors.lightGreen;
      case NutriScore.C:
        return Colors.yellow;
      case NutriScore.D:
        return Colors.orange;
      case NutriScore.E:
        return Colors.red;
    }
  }

  static Color getHealthScoreColor(int score) {
    if (score >= 80) {
      return Colors.green;
    } else if (score >= 60) {
      return Colors.lightGreen;
    } else if (score >= 40) {
      return Colors.yellow;
    } else if (score >= 20) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  static String getHealthScoreLabel(int score) {
    if (score >= 80) {
      return 'Excellent';
    } else if (score >= 60) {
      return 'Good';
    } else if (score >= 40) {
      return 'Fair';
    } else if (score >= 20) {
      return 'Poor';
    } else {
      return 'Very Poor';
    }
  }

  static Map<String, double> calculateDailyNutrition(List<FoodDiaryEntry> entries) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalFat = 0;
    double totalCarbs = 0;
    double totalFiber = 0;
    double totalSugar = 0;

    for (var entry in entries) {
      final nutrition = entry.actualNutrition;
      totalCalories += nutrition.calories;
      totalProtein += nutrition.protein;
      totalFat += nutrition.fat;
      totalCarbs += nutrition.carbs;
      totalFiber += nutrition.fiber;
      totalSugar += nutrition.sugar;
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'fat': totalFat,
      'carbs': totalCarbs,
      'fiber': totalFiber,
      'sugar': totalSugar,
    };
  }
}

class StringHelpers {
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String titleCase(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
