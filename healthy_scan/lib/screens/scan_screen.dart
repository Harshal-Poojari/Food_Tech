import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/scanner_service.dart';
import '../widgets/scan_option_card.dart';
import '../widgets/scanner_view.dart';
import '../widgets/gradient_background.dart';
import 'food_details_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  final ScannerService _scannerService = ScannerService();
  late MobileScannerController _scannerController;
  bool _isScanning = true;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  String _scanMode = ''; // 'barcode', 'ocr', 'image'

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Trigger entrance animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
      _scannerController.toggleTorch();
    });
  }

  void _toggleCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _scannerController.switchCamera();
    });
  }

  void _toggleScanning() {
    setState(() {
      _isScanning = !_isScanning;
      if (_isScanning) {
        _scannerController.start();
      } else {
        _scannerController.stop();
      }
    });
  }

  void _startBarcodeScanner() {
    setState(() {
      _isScanning = true;
      _scanMode = 'barcode';
    });
  }

  void _startOCRScanner() async {
    final imageFile = await _scannerService.takePhoto();
    if (imageFile != null) {
      // Process the image with OCR
      final text = await _scannerService.recognizeText(imageFile);
      if (text.isNotEmpty) {
        final nutritionInfo = _scannerService.extractNutritionInfo(text);
        if (nutritionInfo.isNotEmpty) {
          // Create a food item from the extracted info
          if (!mounted) return;
          // Navigate to food details screen with the nutrition info
          // For now, just show a snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Extracted info: $nutritionInfo')),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not extract nutrition information'),
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No text recognized')));
      }
    }
  }

  void _startImageRecognition() async {
    final imageFile = await _scannerService.takePhoto();
    if (imageFile != null) {
      // Process the image with image recognition
      final foodLabels = await _scannerService.detectFoodInImage(imageFile);
      if (foodLabels.isNotEmpty) {
        if (!mounted) return;
        // Show the detected labels
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Detected Food Items'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: foodLabels.map((label) => Text('• $label')).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No food items detected')));
      }
    }
  }

  void _onBarcodeDetected(BarcodeCapture capture) async {
    final barcode = await _scannerService.scanBarcode(capture);
    if (barcode != null) {
      setState(() {
        _isScanning = false;
      });

      // Get food information from the barcode
      final foodItem = await _scannerService.getFoodInformationFromBarcode(
        barcode,
      );
      if (foodItem != null) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailsScreen(foodItem: foodItem),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Food information not found for this barcode'),
          ),
        );
        // Resume scanning
        setState(() {
          _isScanning = true;
        });
      }
    }
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
      _scanMode = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Food Scanner'),
        actions: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
          ),
          IconButton(
            icon: Icon(_isFrontCamera ? Icons.camera_front : Icons.camera_rear),
            onPressed: _toggleCamera,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 80), // Space for app bar

          // Scanner view or scan options
          Expanded(
            child: _scanMode == 'barcode'
                ? _buildScannerView()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildScanOptions(),
                  ),
          ),

          // Bottom controls
          Padding(
            padding: const EdgeInsets.all(20),
            child: _scanMode == 'barcode'
                ? _buildScannerControls()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerView() {
    return Stack(
      children: [
        // Scanner camera view
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ScannerView(
              controller: _scannerController,
              onBarcodeDetected: _onBarcodeDetected,
              scanMode: true,
              onCancel: _stopScanning,
            ),
          ),
        ),

        // Scanning overlay animation
        Positioned.fill(
          child: AnimatedOpacity(
            opacity: _isScanning ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.8),
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      // Scanning line animation
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Positioned(
                            top: 250 * _animationController.value,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 3,
                              color: Theme.of(context).primaryColor,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanOptions() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title with circuit-like design
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOutCubic,
                )),
                child: FadeTransition(
                  opacity: _animationController,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1128).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                          blurRadius: 12,
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.radar,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'SCAN OPTIONS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Main scan options
              _buildScanOptionCategory('PRODUCT IDENTIFICATION'),

              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-0.5, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.1, 0.9, curve: Curves.easeOutCubic),
                )),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.1, 0.9, curve: Curves.easeOut),
                    ),
                  ),
                  child: ScanOptionCard(
                    title: 'Barcode Scanner',
                    description:
                        'Scan food product barcodes for nutrition facts',
                    icon: Icons.qr_code_scanner,
                    onTap: _startBarcodeScanner,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.5, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
                )),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
                    ),
                  ),
                  child: ScanOptionCard(
                    title: 'Nutrition Label OCR',
                    description:
                        'Extract information from nutrition facts labels',
                    icon: Icons.document_scanner,
                    onTap: _startOCRScanner,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Image-based recognition category
              _buildScanOptionCategory('IMAGE RECOGNITION'),

              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-0.5, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
                )),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                    ),
                  ),
                  child: ScanOptionCard(
                    title: 'Food Recognition',
                    description: 'Identify food and estimate nutrition values',
                    icon: Icons.camera_alt,
                    onTap: _startImageRecognition,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.5, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
                )),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
                    ),
                  ),
                  child: ScanOptionCard(
                    title: 'Portion Estimator',
                    description: 'Calculate serving size from food photos',
                    icon: Icons.photo_size_select_small,
                    onTap: () {
                      // Show coming soon message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Portion estimation coming soon!',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          backgroundColor: const Color(0xFF0A1128),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Advanced features category
              _buildScanOptionCategory('ADVANCED FEATURES'),

              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-0.5, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
                )),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
                    ),
                  ),
                  child: ScanOptionCard(
                    title: 'Ingredient Analyzer',
                    description: 'Analyze ingredients for health concerns',
                    icon: Icons.science,
                    onTap: () {
                      // Show coming soon message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Ingredient analysis coming soon!',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          backgroundColor: const Color(0xFF0A1128),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.5, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
                )),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
                    ),
                  ),
                  child: ScanOptionCard(
                    title: 'Recipe Matcher',
                    description: 'Find recipes based on scanned ingredients',
                    icon: Icons.menu_book,
                    onTap: () {
                      // Show coming soon message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Recipe matching coming soon!',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          backgroundColor: const Color(0xFF0A1128),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    isPremium: true,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Testing options category
              _buildScanOptionCategory('DEVELOPMENT & TESTING'),

              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
                )),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                    ),
                  ),
                  child: ScanOptionCard(
                    title: 'Simulate Scan',
                    description: 'Test with predefined or custom barcodes',
                    icon: Icons.bug_report,
                    onTap: _simulateBarcodeScanning,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
                )),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
                    ),
                  ),
                  child: ScanOptionCard(
                    title: 'Debug Mode',
                    description: 'View detailed scan information',
                    icon: Icons.code,
                    onTap: () {
                      // Show coming soon message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Debug mode coming soon!',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          backgroundColor: const Color(0xFF0A1128),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // New helper method to create category headers
  Widget _buildScanOptionCategory(String title) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 12),
      child: Row(
        children: [
          Container(
            height: 20,
            width: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            color: Colors.red,
            onPressed: () {
              setState(() {
                _scanMode = '';
                _isScanning = false;
                _scannerController.stop();
              });
            },
          ),
          IconButton(
            icon: Icon(_isScanning ? Icons.pause : Icons.play_arrow),
            color: Theme.of(context).primaryColor,
            onPressed: _toggleScanning,
          ),
          IconButton(
            icon: const Icon(Icons.photo_library),
            color: Colors.blue,
            onPressed: () async {
              // Implementation for scanning from gallery
              final imageFile = await _scannerService.takePhoto();
              if (imageFile != null) {
                try {
                  // Just show a message that this feature is coming soon since we don't have a method implementation
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gallery scanning coming soon!'),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error processing image: $e'),
                      ),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // Add this new method to simulate scanning a barcode
  void _simulateBarcodeScanning() async {
    // Show dialog to choose a test barcode
    final String? selectedBarcode = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Test Barcode'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTestBarcodeOption('Coca Cola', '737628064502'),
                _buildTestBarcodeOption('Cheerios', '041570350645'),
                _buildTestBarcodeOption('Nutella', '009800801122'),
                _buildTestBarcodeOption('Pringles Original', '038000138416'),
                _buildTestBarcodeOption('Custom Barcode', 'custom'),
              ],
            ),
          ),
        );
      },
    );

    if (selectedBarcode == null) return;

    if (selectedBarcode == 'custom') {
      // Show dialog to enter a custom barcode
      final customBarcode = await showDialog<String>(
        context: context,
        builder: (context) {
          String barcode = '';
          return AlertDialog(
            title: const Text('Enter Custom Barcode'),
            content: TextField(
              decoration: const InputDecoration(
                hintText: 'Enter barcode number',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                barcode = value;
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, barcode),
                child: const Text('Submit'),
              ),
            ],
          );
        },
      );

      if (customBarcode == null || customBarcode.isEmpty) return;

      _processSimulatedBarcode(customBarcode);
    } else {
      _processSimulatedBarcode(selectedBarcode);
    }
  }

  Widget _buildTestBarcodeOption(String label, String barcode) {
    return ListTile(
      title: Text(label),
      subtitle: Text(barcode),
      onTap: () => Navigator.pop(context, barcode),
    );
  }

  void _processSimulatedBarcode(String barcode) async {
    setState(() {
      _isScanning = false;
    });

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing barcode...'),
          ],
        ),
      ),
    );

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Close loading dialog
    if (!mounted) return;
    Navigator.pop(context);

    // Get food information from the barcode
    final foodItem =
        await _scannerService.getFoodInformationFromBarcode(barcode);

    if (foodItem != null) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoodDetailsScreen(foodItem: foodItem),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Food information not found for barcode: $barcode'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
