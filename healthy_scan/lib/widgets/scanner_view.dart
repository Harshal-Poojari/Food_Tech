import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:async';

class ScannerView extends StatefulWidget {
  final MobileScannerController controller;
  final Function(BarcodeCapture) onBarcodeDetected;
  final bool scanMode;
  final VoidCallback onCancel;

  const ScannerView({
    super.key,
    required this.controller,
    required this.onBarcodeDetected,
    required this.scanMode,
    required this.onCancel,
  });

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scanLineAnimation;
  bool _torchEnabled = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: false);

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleTorch() async {
    setState(() {
      _torchEnabled = !_torchEnabled;
    });
    await widget.controller.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: widget.controller,
          onDetect: widget.onBarcodeDetected,
        ),
        // Scanning animation effect
        AnimatedBuilder(
          animation: _scanLineAnimation,
          builder: (context, child) {
            return Positioned(
              top: MediaQuery.of(context).size.height *
                  0.3 *
                  _scanLineAnimation.value,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // Cyberpunk-style HUD elements - Scanner status indicators
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.7),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "SCAN ACTIVE",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Control buttons
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                Icons.close,
                'CANCEL',
                widget.onCancel,
              ),
              _buildControlButton(
                _torchEnabled ? Icons.flashlight_off : Icons.flashlight_on,
                _torchEnabled ? 'TORCH OFF' : 'TORCH ON',
                _toggleTorch,
              ),
            ],
          ),
        ),
        // Digital frame corners
        Positioned.fill(
          child: CustomPaint(
            painter: DigitalFramePainter(
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.secondary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DigitalFramePainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  DigitalFramePainter(this.primaryColor, this.secondaryColor);

  @override
  void paint(Canvas canvas, Size size) {
    final cornerRadius = size.width * 0.1;
    final cornerLength = size.width * 0.06;
    final lineWidth = 2.0;

    // Define paints
    final primaryPaint = Paint()
      ..color = primaryColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth;

    final secondaryPaint = Paint()
      ..color = secondaryColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth;

    // Top left corner
    Path topLeftPath = Path()
      ..moveTo(cornerRadius, 0)
      ..lineTo(cornerLength, 0)
      ..moveTo(0, cornerRadius)
      ..lineTo(0, cornerLength);
    canvas.drawPath(topLeftPath, primaryPaint);

    // Top right corner
    Path topRightPath = Path()
      ..moveTo(size.width - cornerRadius, 0)
      ..lineTo(size.width - cornerLength, 0)
      ..moveTo(size.width, cornerRadius)
      ..lineTo(size.width, cornerLength);
    canvas.drawPath(topRightPath, primaryPaint);

    // Bottom left corner
    Path bottomLeftPath = Path()
      ..moveTo(cornerRadius, size.height)
      ..lineTo(cornerLength, size.height)
      ..moveTo(0, size.height - cornerRadius)
      ..lineTo(0, size.height - cornerLength);
    canvas.drawPath(bottomLeftPath, secondaryPaint);

    // Bottom right corner
    Path bottomRightPath = Path()
      ..moveTo(size.width - cornerRadius, size.height)
      ..lineTo(size.width - cornerLength, size.height)
      ..moveTo(size.width, size.height - cornerRadius)
      ..lineTo(size.width, size.height - cornerLength);
    canvas.drawPath(bottomRightPath, secondaryPaint);

    // Digital readout effect
    final pixelSize = 1.5;
    final pixelSpacing = 3.0;
    final totalPixels = 15;
    final pixelPaint = Paint()..style = PaintingStyle.fill;

    // Top edge pixels
    for (int i = 0; i < totalPixels; i++) {
      // Random flickering effect
      final opacity = (i % 3 == 0) ? 0.9 : 0.3;
      pixelPaint.color = primaryColor.withOpacity(opacity);

      canvas.drawCircle(
        Offset(
            (size.width / 2) -
                ((totalPixels / 2) * pixelSpacing) +
                (i * pixelSpacing),
            pixelSize),
        pixelSize,
        pixelPaint,
      );
    }

    // Right edge pixels
    for (int i = 0; i < totalPixels; i++) {
      final opacity = (i % 4 == 0) ? 0.9 : 0.3;
      pixelPaint.color = secondaryColor.withOpacity(opacity);

      canvas.drawCircle(
        Offset(
            size.width - pixelSize,
            (size.height / 2) -
                ((totalPixels / 2) * pixelSpacing) +
                (i * pixelSpacing)),
        pixelSize,
        pixelPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
