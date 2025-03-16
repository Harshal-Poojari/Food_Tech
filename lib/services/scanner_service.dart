import 'dart:async';
import 'dart:io';

import 'package:barcode_scan2/barcode_scan2.dart' as scanner2;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class ScannerService {
  final BarcodeScanner _barcodeScanner = BarcodeScanner(
    formats: [BarcodeFormat.all],
  );
  final TextRecognizer _textRecognizer = TextRecognizer();
  final ImagePicker _imagePicker = ImagePicker();

  late List<CameraDescription> cameras;
  CameraController? cameraController;
  bool _isProcessing = false;

  // Initialize camera
  Future<void> initCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) return;

      cameraController = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup:
            Platform.isAndroid
                ? ImageFormatGroup.yuv420
                : ImageFormatGroup.bgra8888,
      );

      await cameraController!.initialize();
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: ${e.description}');
      rethrow;
    }
  }

  void dispose() {
    cameraController?.dispose();
    _barcodeScanner.close();
    _textRecognizer.close();
  }

  // Take a picture and process it
  Future<XFile?> takePicture() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return null;
    }

    if (cameraController!.value.isTakingPicture) {
      return null;
    }

    try {
      final XFile file = await cameraController!.takePicture();
      return file;
    } on CameraException catch (e) {
      debugPrint('Error taking picture: ${e.description}');
      return null;
    }
  }

  // Pick image from gallery
  Future<XFile?> pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
      );
      return pickedFile;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // Process image with barcode scanner
  Future<String?> scanBarcodeFromImage(XFile file) async {
    if (_isProcessing) return null;
    _isProcessing = true;

    try {
      final inputImage = InputImage.fromFilePath(file.path);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      String? barcodeValue;
      for (final barcode in barcodes) {
        barcodeValue = barcode.rawValue;
        if (barcodeValue != null && barcodeValue.isNotEmpty) {
          break;
        }
      }

      _isProcessing = false;
      return barcodeValue;
    } catch (e) {
      _isProcessing = false;
      debugPrint('Error scanning barcode: $e');
      return null;
    }
  }

  // Scan barcode using barcode_scan2 package (camera overlay)
  Future<String?> scanBarcodeWithCamera() async {
    try {
      final scanner2.ScanResult result = await scanner2.BarcodeScanner.scan();
      return result.rawContent.isNotEmpty ? result.rawContent : null;
    } on PlatformException catch (e) {
      if (e.code == scanner2.BarcodeScanner.cameraAccessDenied) {
        debugPrint('Camera permission denied');
      } else {
        debugPrint('Error scanning barcode: $e');
      }
      return null;
    } on FormatException {
      // User pressed back button before scanning
      return null;
    } catch (e) {
      debugPrint('Error scanning barcode: $e');
      return null;
    }
  }

  // Process image with text recognition
  Future<String?> recognizeTextFromImage(XFile file) async {
    if (_isProcessing) return null;
    _isProcessing = true;

    try {
      final inputImage = InputImage.fromFilePath(file.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      _isProcessing = false;
      return recognizedText.text;
    } catch (e) {
      _isProcessing = false;
      debugPrint('Error recognizing text: $e');
      return null;
    }
  }

  // Attempt to parse nutrition information from recognized text
  Map<String, dynamic> parseNutritionInfo(String text) {
    // This is a simplified implementation - in a real app, this would be more sophisticated
    final Map<String, dynamic> result = {};

    // Look for calories
    final caloriesRegex = RegExp(
      r'(\d+)\s*(?:kcal|calories|cal)',
      caseSensitive: false,
    );
    final caloriesMatch = caloriesRegex.firstMatch(text);
    if (caloriesMatch != null) {
      result['calories'] =
          double.tryParse(caloriesMatch.group(1) ?? '0') ?? 0.0;
    }

    // Look for protein
    final proteinRegex = RegExp(
      r'protein[:\s]*(\d+(?:\.\d+)?)\s*g',
      caseSensitive: false,
    );
    final proteinMatch = proteinRegex.firstMatch(text);
    if (proteinMatch != null) {
      result['protein'] = double.tryParse(proteinMatch.group(1) ?? '0') ?? 0.0;
    }

    // Look for fat
    final fatRegex = RegExp(
      r'fat[:\s]*(\d+(?:\.\d+)?)\s*g',
      caseSensitive: false,
    );
    final fatMatch = fatRegex.firstMatch(text);
    if (fatMatch != null) {
      result['fat'] = double.tryParse(fatMatch.group(1) ?? '0') ?? 0.0;
    }

    // Look for carbs
    final carbsRegex = RegExp(
      r'carb(?:ohydrate)?s?[:\s]*(\d+(?:\.\d+)?)\s*g',
      caseSensitive: false,
    );
    final carbsMatch = carbsRegex.firstMatch(text);
    if (carbsMatch != null) {
      result['carbs'] = double.tryParse(carbsMatch.group(1) ?? '0') ?? 0.0;
    }

    // Look for sugar
    final sugarRegex = RegExp(
      r'sugar[s]?[:\s]*(\d+(?:\.\d+)?)\s*g',
      caseSensitive: false,
    );
    final sugarMatch = sugarRegex.firstMatch(text);
    if (sugarMatch != null) {
      result['sugar'] = double.tryParse(sugarMatch.group(1) ?? '0') ?? 0.0;
    }

    // Look for sodium
    final sodiumRegex = RegExp(
      r'sodium[:\s]*(\d+(?:\.\d+)?)\s*(?:mg|g)',
      caseSensitive: false,
    );
    final sodiumMatch = sodiumRegex.firstMatch(text);
    if (sodiumMatch != null) {
      double value = double.tryParse(sodiumMatch.group(1) ?? '0') ?? 0.0;

      // Convert to mg if in g
      final unit = sodiumMatch.group(2);
      if (unit?.toLowerCase() == 'g') {
        value *= 1000;
      }

      result['sodium'] = value;
    }

    return result;
  }

  // Attempt to extract ingredients from text
  List<String> parseIngredients(String text) {
    // This is a simplified implementation
    final ingredientsRegex = RegExp(
      r'ingredients:?\s*([^.]*)',
      caseSensitive: false,
    );
    final match = ingredientsRegex.firstMatch(text);

    if (match != null && match.group(1) != null) {
      final ingredientsText = match.group(1)!.trim();
      return ingredientsText
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return [];
  }

  // Attempt to extract allergens from text
  List<String> parseAllergens(String text) {
    // This is a simplified implementation
    final allergensRegex = RegExp(
      r'allergens:?\s*([^.]*)',
      caseSensitive: false,
    );
    final match = allergensRegex.firstMatch(text);

    if (match != null && match.group(1) != null) {
      final allergensText = match.group(1)!.trim();
      return allergensText
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    // Look for common allergens in the text
    final commonAllergens = [
      'milk',
      'eggs',
      'fish',
      'shellfish',
      'tree nuts',
      'peanuts',
      'wheat',
      'soybeans',
      'gluten',
    ];

    return commonAllergens
        .where(
          (allergen) => text.toLowerCase().contains(allergen.toLowerCase()),
        )
        .toList();
  }
}
