class FoodItem {
  final String id;
  final String name;
  final String barcode;
  final String imageUrl;
  final String description;
  final NutritionInfo nutritionInfo;
  final List<String> ingredients;
  final List<String> allergens;
  final double rating;
  final Map<String, dynamic> additionalInfo;
  final DateTime scannedDate;

  FoodItem({
    required this.id,
    required this.name,
    required this.barcode,
    required this.imageUrl,
    required this.description,
    required this.nutritionInfo,
    required this.ingredients,
    required this.allergens,
    this.rating = 0.0,
    this.additionalInfo = const {},
    DateTime? scannedDate,
  }) : scannedDate = scannedDate ?? DateTime.now();

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      barcode: json['barcode'],
      imageUrl: json['image_url'],
      description: json['description'],
      nutritionInfo: NutritionInfo.fromJson(json['nutrition_info']),
      ingredients: List<String>.from(json['ingredients']),
      allergens: List<String>.from(json['allergens']),
      rating: json['rating'] ?? 0.0,
      additionalInfo: json['additional_info'] ?? {},
      scannedDate: json['scanned_date'] != null
          ? DateTime.parse(json['scanned_date'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'image_url': imageUrl,
      'description': description,
      'nutrition_info': nutritionInfo.toJson(),
      'ingredients': ingredients,
      'allergens': allergens,
      'rating': rating,
      'additional_info': additionalInfo,
      'scanned_date': scannedDate.toIso8601String(),
    };
  }

  FoodItem copyWith({
    String? id,
    String? name,
    String? barcode,
    String? imageUrl,
    String? description,
    NutritionInfo? nutritionInfo,
    List<String>? ingredients,
    List<String>? allergens,
    double? rating,
    Map<String, dynamic>? additionalInfo,
    DateTime? scannedDate,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      ingredients: ingredients ?? this.ingredients,
      allergens: allergens ?? this.allergens,
      rating: rating ?? this.rating,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      scannedDate: scannedDate ?? this.scannedDate,
    );
  }
}

class NutritionInfo {
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final double sugar;
  final double fiber;
  final double sodium;
  final Map<String, double> vitamins;
  final Map<String, double> minerals;

  NutritionInfo({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.sugar,
    required this.fiber,
    required this.sodium,
    this.vitamins = const {},
    this.minerals = const {},
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: json['calories'] ?? 0.0,
      protein: json['protein'] ?? 0.0,
      fat: json['fat'] ?? 0.0,
      carbs: json['carbs'] ?? 0.0,
      sugar: json['sugar'] ?? 0.0,
      fiber: json['fiber'] ?? 0.0,
      sodium: json['sodium'] ?? 0.0,
      vitamins: Map<String, double>.from(json['vitamins'] ?? {}),
      minerals: Map<String, double>.from(json['minerals'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'sugar': sugar,
      'fiber': fiber,
      'sodium': sodium,
      'vitamins': vitamins,
      'minerals': minerals,
    };
  }

  NutritionInfo copyWith({
    double? calories,
    double? protein,
    double? fat,
    double? carbs,
    double? sugar,
    double? fiber,
    double? sodium,
    Map<String, double>? vitamins,
    Map<String, double>? minerals,
  }) {
    return NutritionInfo(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      sugar: sugar ?? this.sugar,
      fiber: fiber ?? this.fiber,
      sodium: sodium ?? this.sodium,
      vitamins: vitamins ?? this.vitamins,
      minerals: minerals ?? this.minerals,
    );
  }
} 