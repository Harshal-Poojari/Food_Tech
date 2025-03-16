import 'dart:math';
import 'package:flutter/material.dart';
import 'package:food_scanner/themes/app_theme.dart';

/// Stylish background designs for the app
class BackgroundThemes {
  /// Private constructor to prevent instantiation
  BackgroundThemes._();

  /// Default gradient background - Green to dark green
  static BoxDecoration get defaultGradient {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.primaryColor,
          AppTheme.primaryDarkColor,
        ],
      ),
    );
  }

  /// Soft wave pattern gradient
  static BoxDecoration get waveGradient {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.primaryLightColor,
          AppTheme.primaryColor,
          AppTheme.primaryDarkColor,
        ],
        stops: const [0.1, 0.5, 0.9],
      ),
    );
  }

  /// Diagonal gradient pattern
  static BoxDecoration get diagonalGradient {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.primaryColor,
          AppTheme.accentColor,
        ],
      ),
    );
  }

  /// Radial gradient background
  static BoxDecoration get radialGradient {
    return BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          AppTheme.primaryLightColor,
          AppTheme.primaryColor,
          AppTheme.primaryDarkColor,
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
    );
  }

  /// Food-themed pattern gradient
  static BoxDecoration get foodPatternGradient {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.primaryLightColor.withOpacity(0.8),
          AppTheme.primaryColor.withOpacity(0.7),
        ],
      ),
    );
  }

  /// Dark elegant gradient
  static BoxDecoration get darkElegantGradient {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1F1F1F),
          Color(0xFF2D2D2D),
          Color(0xFF3D3D3D),
        ],
      ),
    );
  }

  /// Light subtle gradient
  static BoxDecoration get lightSubtleGradient {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFF9F9F9),
          Color(0xFFF3F3F3),
          Color(0xFFECECEC),
        ],
      ),
    );
  }

  /// Clean white with shadow outline
  static BoxDecoration get cleanWhiteWithShadow {
    return BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  /// Get a stylish overlay pattern for various screens
  static Positioned getBackgroundPattern(BuildContext context,
      {int patternIndex = 0}) {
    final screenSize = MediaQuery.of(context).size;
    final patterns = [
      _circlePattern(screenSize),
      _dotsPattern(screenSize),
      _wavyPattern(screenSize),
      _gridPattern(screenSize),
      _leafPattern(screenSize),
    ];

    return patterns[patternIndex % patterns.length];
  }

  /// Circle background pattern
  static Positioned _circlePattern(Size screenSize) {
    return Positioned.fill(
      child: CustomPaint(
        painter: CirclePatternPainter(),
      ),
    );
  }

  /// Dots background pattern
  static Positioned _dotsPattern(Size screenSize) {
    return Positioned.fill(
      child: CustomPaint(
        painter: DotsPatternPainter(),
      ),
    );
  }

  /// Wavy background pattern
  static Positioned _wavyPattern(Size screenSize) {
    return Positioned.fill(
      child: CustomPaint(
        painter: WavyPatternPainter(),
      ),
    );
  }

  /// Grid background pattern
  static Positioned _gridPattern(Size screenSize) {
    return Positioned.fill(
      child: CustomPaint(
        painter: GridPatternPainter(),
      ),
    );
  }

  /// Leaf background pattern
  static Positioned _leafPattern(Size screenSize) {
    return Positioned.fill(
      child: CustomPaint(
        painter: LeafPatternPainter(),
      ),
    );
  }

  /// Image overlay with default gradient
  static Widget imageBackgroundWithOverlay({
    required Widget child,
    String? imagePath,
    BoxDecoration? decoration,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base container with gradient backdrop (fallback)
        Container(
          decoration: decoration ?? defaultGradient,
        ),

        // Image if provided
        if (imagePath != null)
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(); // Transparent fallback if image fails
            },
          ),

        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),

        // Content
        child,
      ],
    );
  }
}

/// Custom painter for circle patterns
class CirclePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final random = Random(42); // Fixed seed for consistent patterns

    for (int i = 0; i < 15; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      final double radius = 10 + random.nextDouble() * 40;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Custom painter for dots patterns
class DotsPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.07)
      ..style = PaintingStyle.fill;

    final dotSize = 4.0;
    final spacing = 30.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Custom painter for wavy patterns
class WavyPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final Path path = Path();
    final waveHeight = 20.0;
    final waveCount = 3;

    for (int j = 0; j < 5; j++) {
      final startY = j * 100.0;
      path.moveTo(0, startY);

      for (int i = 0; i < size.width / 10; i++) {
        path.quadraticBezierTo(
            (i * 20) + 10,
            startY + (i % 2 == 0 ? waveHeight : -waveHeight) * waveCount,
            (i * 20) + 20,
            startY);
      }

      canvas.drawPath(path, paint);
      path.reset();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Custom painter for grid patterns
class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const spacing = 40.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Custom painter for leaf-like patterns
class LeafPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final random = Random(13); // Fixed seed for consistent patterns

    for (int i = 0; i < 20; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      final double leafSize = 10 + random.nextDouble() * 20;

      final Path leafPath = Path();
      leafPath.moveTo(x, y);
      leafPath.quadraticBezierTo(
          x + leafSize, y - leafSize, x + leafSize * 2, y);
      leafPath.quadraticBezierTo(x + leafSize, y + leafSize, x, y);

      canvas.drawPath(leafPath, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
