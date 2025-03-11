import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../models/product_model.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isScanning = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scanBarcode();
  }

  Future<void> _scanBarcode() async {
    if (!_isScanning) return;

    try {
      final barcode = await FlutterBarcodeScanner.scanBarcode(
        '#2E7D32',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );

      // If user canceled the scan
      if (barcode == '-1') {
        if (mounted) {
          Navigator.pop(context);
        }
        return;
      }

      if (mounted) {
        setState(() {
          _isScanning = false;
          _isLoading = true;
        });
      }

      // In a real app, you would fetch product data from an API using the barcode
      // For this template, we'll simulate a response with mock data
      await Future.delayed(const Duration(seconds: 2));
      
      // Get mock product data
      final productData = Product.getMockProduct(barcode);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Navigate to results screen with the product data
        Navigator.pushReplacementNamed(
          context,
          '/results',
          arguments: productData,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scanning barcode: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Try Again',
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  _isScanning = true;
                });
                _scanBarcode();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Product'),
      ),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFF2E7D32),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Analyzing product...',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    size: 80,
                    color: Color(0xFF2E7D32),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Scanner was canceled',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please try again to scan a product barcode',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isScanning = true;
                      });
                      _scanBarcode();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Scan Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
} 