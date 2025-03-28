import 'dart:convert';

class UserPreferences {
  final int dailyCalorieTarget;
  final List<String> dietaryRestrictions;
  final List<String> allergens;
  final bool darkMode;
  final Map<String, bool> notifications;
  final List<String> favoriteCategories;

  UserPreferences({
    this.dailyCalorieTarget = 2000,
    this.dietaryRestrictions = const [],
    this.allergens = const [],
    this.darkMode = true,
    this.notifications = const {
      'mealReminders': true,
      'scanReminders': true,
      'weeklyReports': true,
    },
    this.favoriteCategories = const [],
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      dailyCalorieTarget: json['dailyCalorieTarget'] ?? 2000,
      dietaryRestrictions: List<String>.from(json['dietaryRestrictions'] ?? []),
      allergens: List<String>.from(json['allergens'] ?? []),
      darkMode: json['darkMode'] ?? true,
      notifications: Map<String, bool>.from(json['notifications'] ?? {
        'mealReminders': true,
        'scanReminders': true,
        'weeklyReports': true,
      }),
      favoriteCategories: List<String>.from(json['favoriteCategories'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyCalorieTarget': dailyCalorieTarget,
      'dietaryRestrictions': dietaryRestrictions,
      'allergens': allergens,
      'darkMode': darkMode,
      'notifications': notifications,
      'favoriteCategories': favoriteCategories,
    };
  }

  UserPreferences copyWith({
    int? dailyCalorieTarget,
    List<String>? dietaryRestrictions,
    List<String>? allergens,
    bool? darkMode,
    Map<String, bool>? notifications,
    List<String>? favoriteCategories,
  }) {
    return UserPreferences(
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      allergens: allergens ?? this.allergens,
      darkMode: darkMode ?? this.darkMode,
      notifications: notifications ?? this.notifications,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
    );
  }
}

class UserStats {
  final DateTime joinDate;
  final DateTime lastActive;
  final int streakDays;
  final int totalEntries;
  final Map<String, int> nutritionAverages;
  final String activityLevel;

  UserStats({
    required this.joinDate,
    required this.lastActive,
    this.streakDays = 0,
    this.totalEntries = 0,
    this.nutritionAverages = const {
      'calories': 0,
      'protein': 0,
      'carbs': 0,
      'fat': 0,
    },
    this.activityLevel = 'moderate',
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      joinDate: DateTime.parse(json['joinDate']),
      lastActive: DateTime.parse(json['lastActive']),
      streakDays: json['streakDays'] ?? 0,
      totalEntries: json['totalEntries'] ?? 0,
      nutritionAverages: Map<String, int>.from(json['nutritionAverages'] ?? {
        'calories': 0,
        'protein': 0,
        'carbs': 0,
        'fat': 0,
      }),
      activityLevel: json['activityLevel'] ?? 'moderate',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'joinDate': joinDate.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'streakDays': streakDays,
      'totalEntries': totalEntries,
      'nutritionAverages': nutritionAverages,
      'activityLevel': activityLevel,
    };
  }

  UserStats copyWith({
    DateTime? joinDate,
    DateTime? lastActive,
    int? streakDays,
    int? totalEntries,
    Map<String, int>? nutritionAverages,
    String? activityLevel,
  }) {
    return UserStats(
      joinDate: joinDate ?? this.joinDate,
      lastActive: lastActive ?? this.lastActive,
      streakDays: streakDays ?? this.streakDays,
      totalEntries: totalEntries ?? this.totalEntries,
      nutritionAverages: nutritionAverages ?? this.nutritionAverages,
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final UserPreferences preferences;
  final UserStats stats;

  String get uid => id;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    DateTime? createdAt,
    required this.preferences,
    required this.stats,
  }) : this.createdAt = createdAt ?? DateTime.now();

  factory UserProfile.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonString is String ? 
        jsonDecode(jsonString) : 
        jsonString as Map<String, dynamic>;
    
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      preferences: UserPreferences.fromJson(json['preferences']),
      stats: UserStats.fromJson(json['stats']),
    );
  }

  String toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'preferences': preferences.toJson(),
      'stats': stats.toJson(),
    }.toString();
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    UserPreferences? preferences,
    UserStats? stats,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
    );
  }
}
