import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/food_item.dart';

class ScannerService {
  static final ScannerService _instance = ScannerService._internal();

  factory ScannerService() => _instance;

  ScannerService._internal();

  final TextRecognizer _textRecognizer = TextRecognizer();
  final ImageLabeler _imageLabeler = ImageLabeler(
    options: ImageLabelerOptions(confidenceThreshold: 0.7),
  );
  final ImagePicker _imagePicker = ImagePicker();

  // Cleanup resources
  void dispose() {
    _textRecognizer.close();
    _imageLabeler.close();
  }

  // Enhanced error handling for barcode scanning
  Future<String?> scanBarcode(BarcodeCapture capture) async {
    try {
      final List<Barcode> barcodes = capture.barcodes;
      if (barcodes.isEmpty) return null;
      
      // Validate barcode format
      final barcode = barcodes.first;
      if (barcode.rawValue == null || barcode.rawValue!.isEmpty) {
        throw Exception('Invalid barcode format');
      }
      
      return barcode.rawValue;
    } catch (e) {
      debugPrint('Error scanning barcode: $e');
      return null;
    }
  }

  // Enhanced food information retrieval with retry mechanism
  Future<FoodItem?> getFoodInformationFromBarcode(String barcode) async {
    const maxRetries = 3;
    int currentTry = 0;
    
    while (currentTry < maxRetries) {
      try {
        final response = await http.get(
          Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json'),
          headers: {'User-Agent': 'HealthyScan - Flutter App - Version 1.0.0'},
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 1) {
            final product = data['product'];
            return _parseFoodItemFromResponse(product, barcode);
          } else {
            throw Exception('Product not found');
          }
        } else if (response.statusCode == 429) {
          // Rate limit exceeded, wait before retrying
          await Future.delayed(Duration(seconds: pow(2, currentTry).toInt()));
          currentTry++;
          continue;
        } else {
          throw Exception('Failed to load product data');
        }
      } catch (e) {
        if (currentTry == maxRetries - 1) {
          debugPrint('Error getting food information: $e');
          return null;
        }
        currentTry++;
        await Future.delayed(Duration(seconds: pow(2, currentTry).toInt()));
      }
    }
    return null;
  }

  // Helper method to parse food item from API response
  FoodItem _parseFoodItemFromResponse(Map<String, dynamic> product, String barcode) {
    final nutriments = product['nutriments'] ?? {};
    
    // Extract ingredients with allergen highlighting
    final ingredientsText = product['ingredients_text'] ?? '';
    final ingredients = ingredientsText
        .split(',')
        .map((i) => i.trim())
        .where((i) => i.isNotEmpty)
        .toList();

    // Extract and process allergens
    final allergensText = product['allergens'] ?? '';
    final allergens = allergensText
        .split(',')
        .map((a) => a.trim())
        .where((a) => a.isNotEmpty)
        .toList();

    // Extract additives
    final additivesText = product['additives'] ?? '';
    final additives = additivesText
        .split(',')
        .map((a) => a.trim())
        .where((a) => a.isNotEmpty)
        .toList();

    // Calculate health score using multiple factors
    int healthScore = _calculateHealthScore(nutriments, ingredients, allergens);

    return FoodItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: product['product_name'] ?? 'Unknown Product',
      brand: product['brands'] ?? 'Unknown Brand',
      barcode: barcode,
      category: product['categories'] ?? 'Unknown',
      imageUrl: product['image_url'] ?? '',
      servingSize: (product['serving_size'] != null) 
          ? double.tryParse(product['serving_size'].toString()) ?? 100.0 
          : 100.0,
      servingUnit: 'g',
      nutritionInfo: NutritionInfo(
        calories: (nutriments['energy-kcal_100g'] ?? 0).toDouble(),
        protein: (nutriments['proteins_100g'] ?? 0).toDouble(),
        carbs: (nutriments['carbohydrates_100g'] ?? 0).toDouble(),
        fat: (nutriments['fat_100g'] ?? 0).toDouble(),
        fiber: (nutriments['fiber_100g'] ?? 0).toDouble(),
        sugar: (nutriments['sugars_100g'] ?? 0).toDouble(),
        saturatedFat: (nutriments['saturated-fat_100g'] ?? 0).toDouble(),
        sodium: (nutriments['sodium_100g'] ?? 0).toDouble(),
      ),
      nutriScore: _getNutriScoreFromGrade(product['nutriscore_grade'] ?? 'c'),
      healthScore: healthScore,
      ingredients: ingredients,
      allergens: allergens,
      additives: additives,
      scannedAt: DateTime.now(),
    );
  }

  // Enhanced health score calculation
  int _calculateHealthScore(Map<String, dynamic> nutriments, List<String> ingredients, List<String> allergens) {
    int score = 50; // Base score

    // Nutritional content scoring
    if ((nutriments['sugars_100g'] ?? 0) <= 5) score += 10;
    if ((nutriments['fat_100g'] ?? 0) <= 3) score += 10;
    if ((nutriments['saturated-fat_100g'] ?? 0) <= 1.5) score += 10;
    if ((nutriments['fiber_100g'] ?? 0) >= 3) score += 10;
    if ((nutriments['proteins_100g'] ?? 0) >= 10) score += 10;
    
    // Penalty for allergens
    score -= allergens.length * 5;
    
    // Penalty for artificial ingredients
    final artificialIngredients = ingredients.where((i) => 
      i.toLowerCase().contains('artificial') || 
      i.toLowerCase().contains('preservative') ||
      i.toLowerCase().contains('color e') ||
      i.toLowerCase().contains('flavour')
    ).length;
    
    score -= artificialIngredients * 3;
    
    // Clamp final score between 0 and 100
    return score.clamp(0, 100);
  }

  NutriScore _getNutriScoreFromGrade(String grade) {
    switch (grade.toLowerCase()) {
      case 'a':
        return NutriScore.A;
      case 'b':
        return NutriScore.B;
      case 'c':
        return NutriScore.C;
      case 'd':
        return NutriScore.D;
      case 'e':
        return NutriScore.E;
      default:
        return NutriScore.C;
    }
  }

  // Pick an image from gallery
  Future<XFile?> pickImage() async {
    try {
      return await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // Take a photo with camera
  Future<XFile?> takePhoto() async {
    try {
      return await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  // Recognize text from image (OCR)
  Future<String> recognizeText(XFile imageFile) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      debugPrint('Error recognizing text: $e');
      return '';
    }
  }

  // Detect food items in image using ML Kit
  Future<List<String>> detectFoodInImage(XFile imageFile) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final List<ImageLabel> labels = await _imageLabeler.processImage(
        inputImage,
      );

      // Filter for food-related categories
      return labels
          .where((label) => _isFoodRelated(label.label))
          .map(
            (label) =>
                '${label.label} (${(label.confidence * 100).toStringAsFixed(0)}%)',
          )
          .toList();
    } catch (e) {
      debugPrint('Error detecting food in image: $e');
      return [];
    }
  }

  // Basic check if the label is food-related
  bool _isFoodRelated(String label) {
    final foodRelatedTerms = [
      'food',
      'fruit',
      'vegetable',
      'meat',
      'dairy',
      'grain',
      'bread',
      'pasta',
      'rice',
      'cereal',
      'snack',
      'dessert',
      'cake',
      'cookie',
      'drink',
      'beverage',
      'apple',
      'banana',
      'orange',
      'chicken',
      'beef',
      'pork',
      'fish',
      'milk',
      'cheese',
      'yogurt',
      'egg',
    ];

    return foodRelatedTerms.any(
      (term) => label.toLowerCase().contains(term.toLowerCase()),
    );
  }

  // Extract nutrition information from OCR text
  Map<String, dynamic> extractNutritionInfo(String text) {
    final Map<String, dynamic> nutritionInfo = {};

    // Simple regex patterns for common nutrition info
    final caloriesPattern = RegExp(r'calories?[:\s]+(\d+)');
    final proteinPattern = RegExp(r'protein[s\s]*?[:\s]+(\d+\.?\d*)');
    final fatPattern = RegExp(r'fat[s\s]*?[:\s]+(\d+\.?\d*)');
    final carbsPattern = RegExp(r'carb(?:ohydrate)?[s\s]*?[:\s]+(\d+\.?\d*)');
    final sugarPattern = RegExp(r'sugar[s\s]*?[:\s]+(\d+\.?\d*)');
    final fiberPattern = RegExp(r'fiber[:\s]+(\d+\.?\d*)');

    // Extract values using regex
    try {
      final caloriesMatch = caloriesPattern.firstMatch(text.toLowerCase());
      if (caloriesMatch != null) {
        nutritionInfo['calories'] =
            double.tryParse(caloriesMatch.group(1) ?? '') ?? 0;
      }

      final proteinMatch = proteinPattern.firstMatch(text.toLowerCase());
      if (proteinMatch != null) {
        nutritionInfo['protein'] =
            double.tryParse(proteinMatch.group(1) ?? '') ?? 0;
      }

      final fatMatch = fatPattern.firstMatch(text.toLowerCase());
      if (fatMatch != null) {
        nutritionInfo['fat'] = double.tryParse(fatMatch.group(1) ?? '') ?? 0;
      }

      final carbsMatch = carbsPattern.firstMatch(text.toLowerCase());
      if (carbsMatch != null) {
        nutritionInfo['carbs'] =
            double.tryParse(carbsMatch.group(1) ?? '') ?? 0;
      }

      final sugarMatch = sugarPattern.firstMatch(text.toLowerCase());
      if (sugarMatch != null) {
        nutritionInfo['sugar'] =
            double.tryParse(sugarMatch.group(1) ?? '') ?? 0;
      }

      final fiberMatch = fiberPattern.firstMatch(text.toLowerCase());
      if (fiberMatch != null) {
        nutritionInfo['fiber'] =
            double.tryParse(fiberMatch.group(1) ?? '') ?? 0;
      }
    } catch (e) {
      debugPrint('Error extracting nutrition info: $e');
    }

    return nutritionInfo;
  }
}
