import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_diary_entry.dart';
import '../models/food_item.dart' as food_model;
import 'database_service.dart';

class FoodDiaryService {
  static final FoodDiaryService _instance = FoodDiaryService._internal();
  factory FoodDiaryService() => _instance;
  FoodDiaryService._internal();

  final DatabaseService _db = DatabaseService();

  // Get all entries for a user
  Future<List<FoodDiaryEntry>> getAllEntries(String userId) async {
    // Use the DatabaseService's method directly
    final conn = await _db.connection;
    final results = await conn.query('''
      SELECT 
        e.id as entry_id, e.user_id, e.food_item_id, e.serving_amount, e.meal_type, 
        e.consumed_at, e.notes, e.custom_nutrition, e.is_custom_entry,
        f.id, f.name, f.brand, f.barcode, f.image_url, f.serving_size, f.serving_unit, 
        f.category, f.nutrition_info, f.ingredients, f.allergens, f.additives, 
        f.nutri_score, f.health_score, f.scanned_at
      FROM food_diary_entries e
      INNER JOIN food_items f ON e.food_item_id = f.id
      WHERE e.user_id = ?
      ORDER BY e.consumed_at DESC
    ''', [userId]);

    final entries = <FoodDiaryEntry>[];
    
    for (var row in results) {
      final foodItem = food_model.FoodItem(
        id: row['id'].toString(),
        name: row['name'].toString(),
        brand: row['brand']?.toString(),
        barcode: row['barcode']?.toString(),
        category: row['category'].toString(),
        imageUrl: row['image_url']?.toString(),
        servingSize: double.parse(row['serving_size'].toString()),
        servingUnit: row['serving_unit'].toString(),
        nutritionInfo: food_model.NutritionInfo.fromJson(jsonDecode(row['nutrition_info'].toString())),
        ingredients: List<String>.from(jsonDecode(row['ingredients'].toString())),
        allergens: List<String>.from(jsonDecode(row['allergens'].toString())),
        additives: List<String>.from(jsonDecode(row['additives'].toString())),
        nutriScore: food_model.NutriScore.values.firstWhere(
          (e) => e.toString() == 'food_model.NutriScore.${row['nutri_score']}',
          orElse: () => food_model.NutriScore.C,
        ),
        healthScore: int.parse(row['health_score'].toString()),
        scannedAt: row['scanned_at'] != null ? DateTime.parse(row['scanned_at'].toString()) : null,
      );

      final entry = FoodDiaryEntry(
        id: row['entry_id'].toString(),
        userId: row['user_id'].toString(),
        foodItem: foodItem,
        servingAmount: double.parse(row['serving_amount'].toString()),
        mealType: MealType.values.firstWhere(
          (e) => e.toString() == 'MealType.${row['meal_type']}',
          orElse: () => MealType.snack,
        ),
        consumedAt: DateTime.parse(row['consumed_at'].toString()),
        notes: row['notes']?.toString(),
        customNutrition: row['custom_nutrition'] != null 
            ? jsonDecode(row['custom_nutrition'].toString()) 
            : {},
        isCustomEntry: int.parse(row['is_custom_entry'].toString()) == 1,
      );
      
      entries.add(entry);
    }

    return entries;
  }

  // Get entries for a specific date
  Future<List<FoodDiaryEntry>> getEntriesForDate(
    String userId,
    DateTime date,
  ) async {
    // Use the DatabaseService's method directly
    return _db.getFoodDiaryEntries(userId, date);
  }

  // Get entries for a specific meal type on a specific date
  Future<List<FoodDiaryEntry>> getEntriesForMealOnDate(
    String userId,
    DateTime date,
    MealType mealType,
  ) async {
    final entriesForDate = await getEntriesForDate(userId, date);
    return entriesForDate.where((entry) => entry.mealType == mealType).toList();
  }

  // Add a new entry
  Future<void> addEntry(FoodDiaryEntry entry) async {
    await _db.saveFoodDiaryEntry(entry);
  }

  // Update an existing entry
  Future<void> updateEntry(FoodDiaryEntry entry) async {
    await _db.saveFoodDiaryEntry(entry);
  }

  // Delete an entry
  Future<void> deleteEntry(String entryId) async {
    final conn = await _db.connection;
    await conn.query(
      'DELETE FROM food_diary_entries WHERE id = ?',
      [entryId],
    );
  }

  // Get daily summary
  Future<DailyFoodSummary> getDailySummary(String userId, DateTime date) async {
    // Use the DatabaseService's method directly
    return _db.getDailyFoodSummary(userId, date);
  }

  // Recent entries cache management
  Future<void> cacheRecentEntries(String userId, List<FoodDiaryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = entries.map((e) => e.toJson()).toList();
    await prefs.setString('recent_entries_$userId', jsonEncode(entriesJson));
  }

  Future<List<FoodDiaryEntry>> getCachedRecentEntries(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJsonString = prefs.getString('recent_entries_$userId');
    
    if (entriesJsonString == null) return [];
    
    final entriesJson = jsonDecode(entriesJsonString) as List;
    return entriesJson
        .map((json) => FoodDiaryEntry.fromJson(json))
        .toList();
  }

  // Favorite entries management
  Future<void> addToFavorites(String userId, FoodDiaryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJsonString = prefs.getString('favorites_$userId') ?? '[]';
    final favoritesJson = jsonDecode(favoritesJsonString) as List;
    
    // Check if already in favorites
    if (favoritesJson.any((json) => json['id'] == entry.id)) return;
    
    favoritesJson.add(entry.toJson());
    await prefs.setString('favorites_$userId', jsonEncode(favoritesJson));
  }

  Future<void> removeFromFavorites(String userId, String entryId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJsonString = prefs.getString('favorites_$userId') ?? '[]';
    final favoritesJson = jsonDecode(favoritesJsonString) as List;
    
    final updatedFavorites = favoritesJson
        .where((json) => json['id'] != entryId)
        .toList();
    
    await prefs.setString('favorites_$userId', jsonEncode(updatedFavorites));
  }

  Future<List<FoodDiaryEntry>> getFavorites(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJsonString = prefs.getString('favorites_$userId') ?? '[]';
    final favoritesJson = jsonDecode(favoritesJsonString) as List;
    
    return favoritesJson
        .map((json) => FoodDiaryEntry.fromJson(json))
        .toList();
  }
}
