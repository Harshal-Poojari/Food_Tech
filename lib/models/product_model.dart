class Product {
  final String name;
  final String barcode;
  final List<Ingredient> ingredients;

  Product({
    required this.name,
    required this.barcode,
    required this.ingredients,
  });

  // Factory constructor to create a Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] ?? 'Unknown Product',
      barcode: json['barcode'] ?? '',
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((ingredient) => Ingredient.fromJson(ingredient))
              .toList() ??
          [],
    );
  }

  // Mock data for testing
  static Product getMockProduct(String barcode) {
    return Product(
      name: "Sample Cereal",
      barcode: barcode,
      ingredients: [
        Ingredient(
          name: "Sugar",
          harmful: true,
          reason: "High in added sugars",
        ),
        Ingredient(
          name: "Whole Grain Wheat",
          harmful: false,
          reason: "Good source of fiber",
        ),
        Ingredient(
          name: "Corn Syrup",
          harmful: true,
          reason: "Processed sweetener linked to obesity",
        ),
        Ingredient(
          name: "Vitamin D",
          harmful: false,
          reason: "Essential vitamin for bone health",
        ),
        Ingredient(
          name: "Artificial Color (Yellow 5)",
          harmful: true,
          reason: "Synthetic dye linked to hyperactivity",
        ),
      ],
    );
  }
}

class Ingredient {
  final String name;
  final bool harmful;
  final String reason;

  Ingredient({
    required this.name,
    required this.harmful,
    required this.reason,
  });

  // Factory constructor to create an Ingredient from JSON
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] ?? 'Unknown Ingredient',
      harmful: json['harmful'] ?? false,
      reason: json['reason'] ?? '',
    );
  }
} 