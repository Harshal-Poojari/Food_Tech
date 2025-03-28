import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:mysql1/mysql1.dart';
import '../models/food_item.dart' as food_model;
import '../models/user_profile.dart';
import '../models/food_diary_entry.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static MySqlConnection? _connection;
  final String _host = 'localhost'; // Change to your MySQL server host
  final int _port = 3306; // Default MySQL port
  final String _user = 'root'; // Change to your MySQL username
  final String _password = 'mysql123'; // Change to your MySQL password
  final String _db = 'healthy_scan'; // Change to your database name

  Future<MySqlConnection> get connection async {
    if (_connection != null) return _connection!;
    _connection = await _initConnection();
    return _connection!;
  }

  Future<MySqlConnection> _initConnection() async {
    try {
      final settings = ConnectionSettings(
        host: _host,
        port: _port,
        user: _user,
        password: _password,
        db: _db,
      );

      final conn = await MySqlConnection.connect(settings);

      // Check if tables exist, if not create them
      await _createTablesIfNotExist(conn);

      return conn;
    } catch (e) {
      debugPrint('Error initializing MySQL connection: $e');
      rethrow;
    }
  }

  Future<void> _createTablesIfNotExist(MySqlConnection conn) async {
    try {
      // Check if users table exists
      final tables = await conn.query("SHOW TABLES LIKE 'users'");

      if (tables.isEmpty) {
        await _createDb(conn);
      }
    } catch (e) {
      debugPrint('Error checking/creating tables: $e');
      rethrow;
    }
  }

  Future<void> _createDb(MySqlConnection conn) async {
    await conn.query('''
      CREATE TABLE IF NOT EXISTS users (
        id VARCHAR(255) PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        photo_url TEXT,
        created_at DATETIME NOT NULL,
        preferences JSON NOT NULL,
        stats JSON NOT NULL
      )
    ''');

    await conn.query('''
      CREATE TABLE IF NOT EXISTS food_items (
        id VARCHAR(255) PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        brand VARCHAR(255),
        barcode VARCHAR(255) UNIQUE,
        image_url TEXT,
        serving_size VARCHAR(255) NOT NULL,
        serving_unit VARCHAR(50) NOT NULL,
        category VARCHAR(100) NOT NULL,
        nutrition_info JSON NOT NULL,
        ingredients JSON NOT NULL,
        allergens JSON NOT NULL,
        additives JSON NOT NULL,
        nutri_score VARCHAR(1) NOT NULL,
        health_score INT NOT NULL,
        scanned_at DATETIME
      )
    ''');

    await conn.query('''
      CREATE TABLE IF NOT EXISTS food_diary_entries (
        id VARCHAR(255) PRIMARY KEY,
        user_id VARCHAR(255) NOT NULL,
        food_item_id VARCHAR(255) NOT NULL,
        serving_amount FLOAT NOT NULL,
        meal_type VARCHAR(50) NOT NULL,
        consumed_at DATETIME NOT NULL,
        notes TEXT,
        custom_nutrition JSON,
        is_custom_entry BOOLEAN NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (food_item_id) REFERENCES food_items (id) ON DELETE CASCADE
      )
    ''');

    await conn.query('''
      CREATE INDEX idx_food_diary_user_date ON food_diary_entries (user_id, consumed_at)
    ''');
  }

  // User operations
  Future<void> saveUser(UserProfile user) async {
    await _withTransaction((conn) async {
      await conn.query('''
        INSERT INTO users (
          id, name, email, photo_url, created_at, preferences, stats
        ) VALUES (?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE 
          name = VALUES(name), 
          email = VALUES(email), 
          photo_url = VALUES(photo_url), 
          preferences = VALUES(preferences), 
          stats = VALUES(stats)
      ''', [
        user.id,
        user.name,
        user.email,
        user.photoUrl,
        user.createdAt.toIso8601String(),
        jsonEncode(user.preferences.toJson()),
        jsonEncode(user.stats.toJson()),
      ]);
    });
  }

  Future<UserProfile?> getUser(String id) async {
    final conn = await connection;
    final results = await conn.query('SELECT * FROM users WHERE id = ?', [id]);

    if (results.isEmpty) return null;

    final row = results.first;
    return UserProfile(
      id: row['id'].toString(),
      name: row['name'].toString(),
      email: row['email'].toString(),
      photoUrl: row['photo_url']?.toString(),
      createdAt: DateTime.parse(row['created_at'].toString()),
      preferences:
          UserPreferences.fromJson(jsonDecode(row['preferences'].toString())),
      stats: UserStats.fromJson(jsonDecode(row['stats'].toString())),
    );
  }

  // Food item operations
  Future<void> saveFoodItem(food_model.FoodItem item) async {
    await _withTransaction((conn) async {
      await conn.query('''
        INSERT INTO food_items (
          id, name, brand, barcode, image_url, serving_size, serving_unit, category,
          nutrition_info, ingredients, allergens, additives, nutri_score, health_score, scanned_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE 
          name = VALUES(name), 
          brand = VALUES(brand), 
          barcode = VALUES(barcode), 
          image_url = VALUES(image_url), 
          serving_size = VALUES(serving_size),
          serving_unit = VALUES(serving_unit),
          category = VALUES(category),
          nutrition_info = VALUES(nutrition_info), 
          ingredients = VALUES(ingredients), 
          allergens = VALUES(allergens), 
          additives = VALUES(additives), 
          nutri_score = VALUES(nutri_score), 
          health_score = VALUES(health_score), 
          scanned_at = VALUES(scanned_at)
      ''', [
        item.id,
        item.name,
        item.brand ?? '',
        item.barcode ?? '',
        item.imageUrl ?? '',
        item.servingSize,
        item.servingUnit,
        item.category,
        jsonEncode(item.nutritionInfo.toJson()),
        jsonEncode(item.ingredients),
        jsonEncode(item.allergens),
        jsonEncode(item.additives),
        item.nutriScore.toString().split('.').last,
        item.healthScore,
        item.scannedAt?.toIso8601String(),
      ]);
    });
  }

  Future<food_model.FoodItem?> getFoodItem(String id) async {
    final conn = await connection;
    final results =
        await conn.query('SELECT * FROM food_items WHERE id = ?', [id]);

    if (results.isEmpty) return null;

    final row = results.first;
    return food_model.FoodItem(
      id: row['id'].toString(),
      name: row['name'].toString(),
      brand: row['brand']?.toString(),
      barcode: row['barcode']?.toString(),
      imageUrl: row['image_url']?.toString(),
      servingSize: double.parse(row['serving_size'].toString()),
      servingUnit: row['serving_unit'].toString(),
      category: row['category'].toString(),
      nutritionInfo: food_model.NutritionInfo.fromJson(
          jsonDecode(row['nutrition_info'].toString())),
      ingredients: List<String>.from(jsonDecode(row['ingredients'].toString())),
      allergens: List<String>.from(jsonDecode(row['allergens'].toString())),
      additives: List<String>.from(jsonDecode(row['additives'].toString())),
      nutriScore: food_model.NutriScore.values.firstWhere(
        (e) => e.toString() == 'food_model.NutriScore.${row['nutri_score']}',
        orElse: () => food_model.NutriScore.C,
      ),
      healthScore: int.parse(row['health_score'].toString()),
      scannedAt: row['scanned_at'] != null
          ? DateTime.parse(row['scanned_at'].toString())
          : null,
    );
  }

  Future<food_model.FoodItem?> getFoodItemByBarcode(String barcode) async {
    final conn = await connection;
    final results = await conn
        .query('SELECT * FROM food_items WHERE barcode = ?', [barcode]);

    if (results.isEmpty) return null;

    final row = results.first;
    return food_model.FoodItem(
      id: row['id'].toString(),
      name: row['name'].toString(),
      brand: row['brand']?.toString(),
      barcode: row['barcode']?.toString(),
      imageUrl: row['image_url']?.toString(),
      servingSize: double.parse(row['serving_size'].toString()),
      servingUnit: row['serving_unit'].toString(),
      category: row['category'].toString(),
      nutritionInfo: food_model.NutritionInfo.fromJson(
          jsonDecode(row['nutrition_info'].toString())),
      ingredients:
          List<String>.from(jsonDecode(row['ingredients'].toString())),
      allergens: List<String>.from(jsonDecode(row['allergens'].toString())),
      additives: List<String>.from(jsonDecode(row['additives'].toString())),
      nutriScore: food_model.NutriScore.values.firstWhere(
        (e) => e.toString() == 'food_model.NutriScore.${row['nutri_score']}',
        orElse: () => food_model.NutriScore.C,
      ),
      healthScore: int.parse(row['health_score'].toString()),
      scannedAt: row['scanned_at'] != null
          ? DateTime.parse(row['scanned_at'].toString())
          : null,
    );
  }

  // Food diary operations
  Future<void> saveFoodDiaryEntry(FoodDiaryEntry entry) async {
    await _withTransaction((conn) async {
      await conn.query('''
        INSERT INTO food_diary_entries (
          id, user_id, food_item_id, serving_amount, meal_type, consumed_at, notes, custom_nutrition, is_custom_entry
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE 
          user_id = VALUES(user_id), 
          food_item_id = VALUES(food_item_id), 
          serving_amount = VALUES(serving_amount), 
          meal_type = VALUES(meal_type), 
          consumed_at = VALUES(consumed_at), 
          notes = VALUES(notes), 
          custom_nutrition = VALUES(custom_nutrition), 
          is_custom_entry = VALUES(is_custom_entry)
      ''', [
        entry.id,
        entry.userId,
        entry.foodItem.id,
        entry.servingAmount,
        entry.mealType.toString().split('.').last,
        entry.consumedAt.toIso8601String(),
        entry.notes,
        jsonEncode(entry.customNutrition),
        entry.isCustomEntry ? 1 : 0,
      ]);
    });
  }

  Future<List<FoodDiaryEntry>> getFoodDiaryEntries(
    String userId,
    DateTime date,
  ) async {
    final conn = await connection;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    final results = await conn.query('''
      SELECT 
        e.id as entry_id, e.user_id, e.food_item_id, e.serving_amount, e.meal_type, 
        e.consumed_at, e.notes, e.custom_nutrition, e.is_custom_entry,
        f.id, f.name, f.brand, f.barcode, f.image_url, f.serving_size, f.serving_unit, 
        f.category, f.nutrition_info, f.ingredients, f.allergens, f.additives, 
        f.nutri_score, f.health_score, f.scanned_at
      FROM food_diary_entries e
      INNER JOIN food_items f ON e.food_item_id = f.id
      WHERE e.user_id = ? AND e.consumed_at BETWEEN ? AND ?
    ''', [userId, startOfDay.toIso8601String(), endOfDay.toIso8601String()]);

    final entries = <FoodDiaryEntry>[];

    for (var row in results) {
      final foodItem = food_model.FoodItem(
        id: row['food_item_id'].toString(),
        name: row['name'].toString(),
        brand: row['brand']?.toString(),
        barcode: row['barcode']?.toString(),
        imageUrl: row['image_url']?.toString(),
        servingSize: double.parse(row['serving_size'].toString()),
        servingUnit: row['serving_unit'].toString(),
        category: row['category'].toString(),
        nutritionInfo: food_model.NutritionInfo.fromJson(
            jsonDecode(row['nutrition_info'].toString())),
        ingredients:
            List<String>.from(jsonDecode(row['ingredients'].toString())),
        allergens: List<String>.from(jsonDecode(row['allergens'].toString())),
        additives: List<String>.from(jsonDecode(row['additives'].toString())),
        nutriScore: food_model.NutriScore.values.firstWhere(
          (e) => e.toString() == 'food_model.NutriScore.${row['nutri_score']}',
          orElse: () => food_model.NutriScore.C,
        ),
        healthScore: int.parse(row['health_score'].toString()),
        scannedAt: row['scanned_at'] != null
            ? DateTime.parse(row['scanned_at'].toString())
            : null,
      );

      final entry = FoodDiaryEntry(
        id: row['entry_id'].toString(),
        userId: row['user_id'].toString(),
        foodItem: foodItem,
        servingAmount: (row['serving_amount'] as num).toDouble(),
        mealType: MealType.values.firstWhere(
          (e) => e.toString() == 'MealType.${row['meal_type']}',
          orElse: () => MealType.snack,
        ),
        consumedAt: DateTime.parse(row['consumed_at'].toString()),
        notes: row['notes']?.toString(),
        customNutrition: row['custom_nutrition'] != null
            ? jsonDecode(row['custom_nutrition'].toString())
            : {},
        isCustomEntry: (row['is_custom_entry'] as int) == 1,
      );

      entries.add(entry);
    }

    return entries;
  }

  Future<DailyFoodSummary> getDailyFoodSummary(
    String userId,
    DateTime date,
  ) async {
    final entries = await getFoodDiaryEntries(userId, date);
    return DailyFoodSummary(
      userId: userId,
      date: date,
      entries: entries,
    );
  }

  // Document operations
  Future<void> setDocument(String path, Map<String, dynamic> data) async {
    final pathParts = path.split('/');
    if (pathParts.length != 2) {
      throw ArgumentError('Path must be in format: collection/documentId');
    }

    final collection = pathParts[0];
    final documentId = pathParts[1];

    await _withTransaction((conn) async {
      // Check if table exists
      final tables = await conn.query(
        "SHOW TABLES LIKE ?",
        [collection],
      );

      // Create table if it doesn't exist
      if (tables.isEmpty) {
        await conn.query('''
          CREATE TABLE $collection (
            id VARCHAR(255) PRIMARY KEY,
            data JSON NOT NULL,
            created_at DATETIME NOT NULL,
            updated_at DATETIME NOT NULL
          )
        ''');
      }

      // Insert or update document
      await conn.query('''
        INSERT INTO $collection (id, data, created_at, updated_at)
        VALUES (?, ?, NOW(), NOW())
        ON DUPLICATE KEY UPDATE
          data = VALUES(data),
          updated_at = VALUES(updated_at)
      ''', [documentId, jsonEncode(data)]);
    });
  }

  Future<Map<String, dynamic>?> getDocument(String path) async {
    final pathParts = path.split('/');
    if (pathParts.length != 2) {
      throw ArgumentError('Path must be in format: collection/documentId');
    }

    final collection = pathParts[0];
    final documentId = pathParts[1];

    final conn = await connection;
    
    // Check if table exists
    final tables = await conn.query(
      "SHOW TABLES LIKE ?",
      [collection],
    );

    if (tables.isEmpty) {
      return null;
    }

    final results = await conn.query(
      'SELECT data FROM $collection WHERE id = ?',
      [documentId],
    );

    if (results.isEmpty) {
      return null;
    }

    return jsonDecode(results.first['data'].toString());
  }

  Future<List<Map<String, dynamic>>> getCollection(String collection, {
    String? whereField,
    dynamic whereValue,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    final conn = await connection;

    // Check if table exists
    final tables = await conn.query(
      "SHOW TABLES LIKE ?",
      [collection],
    );

    if (tables.isEmpty) {
      return [];
    }

    var query = 'SELECT data FROM $collection';
    final params = <dynamic>[];

    if (whereField != null && whereValue != null) {
      query += ' WHERE JSON_EXTRACT(data, ?) = ?';
      params.add('\$.$whereField');
      params.add(jsonEncode(whereValue));
    }

    if (orderBy != null) {
      query += ' ORDER BY JSON_EXTRACT(data, ?) ${descending ? 'DESC' : 'ASC'}';
      params.add('\$.$orderBy');
    }

    if (limit != null) {
      query += ' LIMIT ?';
      params.add(limit);
    }

    final results = await conn.query(query, params);
    return results.map((row) => jsonDecode(row['data'].toString()) as Map<String, dynamic>).toList();
  }

  // Transaction handling
  Future<T> _withTransaction<T>(
      Future<T> Function(MySqlConnection conn) action) async {
    final conn = await connection;
    try {
      await conn.query('START TRANSACTION');
      final result = await action(conn);
      await conn.query('COMMIT');
      return result;
    } catch (e) {
      await conn.query('ROLLBACK');
      debugPrint('Error in database transaction: $e');
      rethrow;
    }
  }

  // Close connection when app is closed
  Future<void> closeConnection() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }
}
