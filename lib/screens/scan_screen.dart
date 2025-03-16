import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:camera/camera.dart';
import 'package:food_scanner/animations/animated_widgets.dart';
import 'package:food_scanner/animations/animation_constants.dart';
import 'package:food_scanner/screens/result_screen.dart';
import 'package:food_scanner/services/scanner_service.dart';
import 'package:food_scanner/themes/app_theme.dart';
import 'package:lottie/lottie.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  final ScannerService _scannerService = ScannerService();
  bool _isCameraInitialized = false;
  bool _isLoading = false;
  bool _isFlashOn = false;
  bool _showCamera = true;
  bool _showGalleryOption = true;
  String? _imagePath;
  final bool _isWeb = kIsWeb;

  late AnimationController _scanAnimation;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();

    _scanAnimation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scanAnimation, curve: Curves.easeInOut));

    if (!_isWeb) {
      _initializeCamera();
    } else {
      // On web, we'll show a different UI
      setState(() {
        _showCamera = false;
        _showGalleryOption = true;
      });
    }
  }

  Future<void> _initializeCamera() async {
    setState(() => _isLoading = true);

    try {
      await _scannerService.initCamera();
      setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      _showErrorDialog(
        'Could not initialize camera. Please check permissions.',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleFlash() async {
    if (!_isCameraInitialized || _scannerService.cameraController == null) {
      return;
    }

    try {
      final newValue = !_isFlashOn;
      await _scannerService.cameraController!.setFlashMode(
        newValue ? FlashMode.torch : FlashMode.off,
      );
      setState(() => _isFlashOn = newValue);
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_isWeb) {
      _showWebFeatureNotAvailableDialog('Camera capture');
      return;
    }

    if (!_isCameraInitialized || _scannerService.cameraController == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final XFile? image = await _scannerService.takePicture();
      if (image != null) {
        setState(() {
          _imagePath = image.path;
          _showCamera = false;
          _showGalleryOption = false;
        });

        // Add slight delay to show capture animation
        await Future.delayed(const Duration(milliseconds: 500));
        _processCapturedImage(image);
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
      _showErrorDialog('Could not capture image. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImageFromGallery() async {
    if (_isWeb) {
      _showWebFeatureNotAvailableDialog('Image picking');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final XFile? image = await _scannerService.pickImage();
      if (image != null) {
        setState(() {
          _imagePath = image.path;
          _showCamera = false;
          _showGalleryOption = false;
        });

        // Add slight delay to show loading animation
        await Future.delayed(const Duration(milliseconds: 500));
        _processCapturedImage(image);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      _showErrorDialog('Could not pick image from gallery. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _scanBarcode() async {
    if (_isWeb) {
      _showWebFeatureNotAvailableDialog('Barcode scanning');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final barcode = await _scannerService.scanBarcodeWithCamera();
      if (barcode != null && barcode.isNotEmpty) {
        // For now, just navigate to result screen
        _navigateToResultScreen(barcode: barcode);
      } else {
        _showErrorDialog('Could not detect barcode. Please try again.');
      }
    } catch (e) {
      debugPrint('Error scanning barcode: $e');
      _showErrorDialog('Could not scan barcode. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showWebFeatureNotAvailableDialog(String feature) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('$feature Not Available'),
            content: Text(
              'This feature is not available in the web version of the app. '
              'Please try using the mobile app for full functionality.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _processCapturedImage(XFile image) async {
    setState(() => _isLoading = true);

    try {
      // First try to detect a barcode in the image
      final barcode = await _scannerService.scanBarcodeFromImage(image);

      if (barcode != null && barcode.isNotEmpty) {
        _navigateToResultScreen(barcode: barcode, imagePath: image.path);
        return;
      }

      // If no barcode, try to extract text
      final text = await _scannerService.recognizeTextFromImage(image);
      if (text != null && text.isNotEmpty) {
        // Extract nutrition info from text
        final nutritionInfo = _scannerService.parseNutritionInfo(text);
        final ingredients = _scannerService.parseIngredients(text);
        final allergens = _scannerService.parseAllergens(text);

        _navigateToResultScreen(
          extractedText: text,
          nutritionInfo: nutritionInfo,
          ingredients: ingredients,
          allergens: allergens,
          imagePath: image.path,
        );
      } else {
        _showErrorDialog(
          'Could not extract information from image. Please try again.',
        );
        setState(() {
          _showCamera = true;
          _showGalleryOption = true;
          _imagePath = null;
        });
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
      _showErrorDialog('Error processing image. Please try again.');
      setState(() {
        _showCamera = true;
        _showGalleryOption = true;
        _imagePath = null;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToResultScreen({
    String? barcode,
    String? extractedText,
    Map<String, dynamic>? nutritionInfo,
    List<String>? ingredients,
    List<String>? allergens,
    String? imagePath,
  }) {
    // For web demo, use mock data if needed
    if (_isWeb) {
      barcode = barcode ?? '5901234123457';
      extractedText =
          extractedText ?? 'Sample nutrition information for demo purposes.';
      nutritionInfo =
          nutritionInfo ??
          {
            'calories': 250.0,
            'protein': 10.0,
            'fat': 5.0,
            'carbs': 40.0,
            'sugar': 8.0,
          };
      ingredients =
          ingredients ?? ['Wheat flour', 'Sugar', 'Vegetable oil', 'Salt'];
      allergens = allergens ?? ['Wheat', 'May contain traces of nuts'];
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => ResultScreen(
              barcode: barcode,
              extractedText: extractedText,
              nutritionInfo: nutritionInfo,
              ingredients: ingredients,
              allergens: allergens,
              imagePath: imagePath,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeInOut));

          return FadeTransition(opacity: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _scanAnimation.dispose();
    _scannerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Food Item'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
          ),

          // Camera or captured image
          if (_showCamera && _isCameraInitialized && !_isWeb)
            AnimatedEntrance.fadeIn(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width:
                        _scannerService
                            .cameraController!
                            .value
                            .previewSize!
                            .height,
                    height:
                        _scannerService
                            .cameraController!
                            .value
                            .previewSize!
                            .width,
                    child: CameraPreview(_scannerService.cameraController!),
                  ),
                ),
              ),
            )
          else if (_imagePath != null && !_isWeb)
            AnimatedEntrance.fadeIn(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image.file(File(_imagePath!), fit: BoxFit.cover),
              ),
            )
          else if (_isWeb)
            _buildWebPlaceholder(),

          // Scan animation overlay when camera is active
          if (_showCamera && _isCameraInitialized && !_isWeb)
            _buildScanOverlay(),

          // Controls at the bottom
          Positioned(left: 0, right: 0, bottom: 0, child: _buildControls()),

          // Loading indicator
          if (_isLoading)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLoadingAnimation(),
                      const SizedBox(height: 16),
                      const Text(
                        'Processing...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWebPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt,
            size: 80,
            color: AppTheme.primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Camera preview not available in web',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try our mobile app for full functionality',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => _navigateToResultScreen(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('View Demo Results'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    return SizedBox(
      width: 150,
      height: 150,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        strokeWidth: 6,
      ),
    );
  }

  Widget _buildScanOverlay() {
    return Stack(
      children: [
        // Scan frame overlay
        Center(
          child: AnimatedEntrance.fadeIn(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),

        // Moving scan line
        Center(
          child: AnimatedBuilder(
            animation: _scanLineAnimation,
            builder: (context, child) {
              return Positioned(
                top:
                    (MediaQuery.of(context).size.width * 0.8 - 2) *
                        _scanLineAnimation.value -
                    (MediaQuery.of(context).size.width * 0.8) / 2 +
                    MediaQuery.of(context).size.height / 2,
                left: MediaQuery.of(context).size.width * 0.1,
                right: MediaQuery.of(context).size.width * 0.1,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppTheme.primaryColor.withOpacity(0.8),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Text guides
        Positioned(
          top:
              MediaQuery.of(context).size.height / 2 +
              (MediaQuery.of(context).size.width * 0.8) / 2 +
              24,
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedEntrance.fadeInUp(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Position barcode or nutrition label in the frame',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          color: Colors.black.withOpacity(0.5),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_showCamera)
                      AnimatedEntrance.fadeInUp(
                        child: IconButton(
                          onPressed: _toggleFlash,
                          icon: Icon(
                            _isFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                            size: 28,
                          ),
                          tooltip:
                              _isFlashOn ? 'Turn off flash' : 'Turn on flash',
                        ),
                      ),
                    const SizedBox(width: 24),
                    AnimatedEntrance.fadeInUp(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _showCamera ? _takePicture : null,
                            customBorder: const CircleBorder(),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Icon(
                                _showCamera ? Icons.camera_alt : Icons.check,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    if (_showGalleryOption)
                      AnimatedEntrance.fadeInUp(
                        child: IconButton(
                          onPressed: _pickImageFromGallery,
                          icon: const Icon(
                            Icons.photo_library,
                            color: Colors.white,
                            size: 28,
                          ),
                          tooltip: 'Choose from gallery',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                AnimatedEntrance.fadeInUp(
                  child: TextButton(
                    onPressed: _scanBarcode,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Scan Barcode',
                          style: Theme.of(
                            context,
                          ).textTheme.labelLarge?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
