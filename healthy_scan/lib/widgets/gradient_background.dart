import 'package:flutter/material.dart';
import 'dart:math' as math;

class GradientBackground extends StatefulWidget {
  final Widget child;
  final bool animated;
  final List<Color> colors;

  const GradientBackground({
    super.key,
    required this.child,
    this.animated = true,
    this.colors = const [
      Color(0xFF0A1128),
      Color(0xFF1C2541),
      Color(0xFF0B3954),
      Color(0xFF051937),
    ],
  });

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Alignment> _alignments = [
    Alignment.topLeft,
    Alignment.topRight,
    Alignment.bottomRight,
    Alignment.bottomLeft,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    if (widget.animated) {
      _controller.addListener(() {
        setState(() {
          // Rotate the alignments to create a continuous animation
          _alignments = _rotateList(_alignments, 0.001);
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Helper method to rotate a list with a smooth transition
  List<T> _rotateList<T>(List<T> list, double factor) {
    int shift = (factor * list.length).floor();
    if (shift == 0) return list;
    return [...list.sublist(shift), ...list.sublist(0, shift)];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep space background
        Container(
          color: const Color(0xFF050A1A), // Deep space blue/black
        ),

        // Animated gradient background
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: _alignments[0],
                  end: _alignments[2],
                  colors: widget.colors,
                  stops: const [0.0, 0.33, 0.67, 1.0],
                  transform: GradientRotation(_controller.value * 2 * math.pi),
                ),
              ),
            );
          },
        ),

        // Grid overlay effect
        CustomPaint(
          painter: GridPainter(),
          size: Size.infinite,
        ),

        // Glowing particles/stars
        Positioned.fill(
          child: BubblesDecoration(
            numberOfBubbles: 100,
            maxRadius: 2.0,
            speed: 0.3,
            color: Colors.cyanAccent.withOpacity(0.6),
          ),
        ),

        // Larger glowing accents
        Positioned.fill(
          child: BubblesDecoration(
            numberOfBubbles: 20,
            maxRadius: 6.0,
            speed: 0.1,
            color: const Color(0xFF00FF9D).withOpacity(0.5), // Neon green
          ),
        ),

        // Digital circuit lines
        CustomPaint(
          painter: CircuitPainter(),
          size: Size.infinite,
        ),

        // Content child
        widget.child,
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.05)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw horizontal lines
    double spacing = 20;
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => false;
}

class CircuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FF9D).withOpacity(0.2) // Neon green
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final random = math.Random(42); // Fixed seed for consistent results

    // Draw some circuit-like lines
    for (int i = 0; i < 8; i++) {
      final path = Path();
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;

      path.moveTo(x, y);

      // Create branching paths that look like circuit traces
      for (int j = 0; j < 6; j++) {
        // Decide if we're going horizontal or vertical
        if (random.nextBool()) {
          // Horizontal movement
          x += (random.nextDouble() * 150) * (random.nextBool() ? 1 : -1);
          path.lineTo(x, y);
        } else {
          // Vertical movement
          y += (random.nextDouble() * 150) * (random.nextBool() ? 1 : -1);
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);

      // Add circuit nodes (small circles) at line intersections
      paint.style = PaintingStyle.fill;
      paint.color = const Color(0xFF00FF9D).withOpacity(0.3);
      for (int j = 0; j < 3; j++) {
        double nodeX = random.nextDouble() * size.width;
        double nodeY = random.nextDouble() * size.height;
        canvas.drawCircle(Offset(nodeX, nodeY), 3.0, paint);
      }
      paint.style = PaintingStyle.stroke;
      paint.color = const Color(0xFF00FF9D).withOpacity(0.2);
    }
  }

  @override
  bool shouldRepaint(CircuitPainter oldDelegate) => false;
}

class BubblesDecoration extends StatefulWidget {
  final int numberOfBubbles;
  final double maxRadius;
  final double speed;
  final Color color;

  const BubblesDecoration({
    super.key,
    this.numberOfBubbles = 10,
    this.maxRadius = 30,
    this.speed = 1.0,
    this.color = Colors.white,
  });

  @override
  State<BubblesDecoration> createState() => _BubblesDecorationState();
}

class _BubblesDecorationState extends State<BubblesDecoration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Bubble> _bubbles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    final rnd = math.Random();
    _bubbles = List.generate(
      widget.numberOfBubbles,
      (index) => Bubble(
        x: rnd.nextDouble(),
        y: rnd.nextDouble(),
        radius: widget.maxRadius * (0.3 + rnd.nextDouble() * 0.7),
        speed: widget.speed * (0.5 + rnd.nextDouble()),
        direction: rnd.nextBool(),
        glow: rnd.nextDouble() > 0.7, // 30% chance of having a glow
      ),
    );

    _controller.addListener(() {
      for (var bubble in _bubbles) {
        bubble.update(_controller.value);
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BubblesPainter(
        bubbles: _bubbles,
        color: widget.color,
      ),
      size: Size.infinite,
    );
  }
}

class Bubble {
  double x; // Position x (0.0 to 1.0)
  double y; // Position y (0.0 to 1.0)
  final double radius;
  final double speed;
  final bool direction; // true for up, false for down
  final bool glow; // whether this bubble has a glow effect

  Bubble({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.direction,
    this.glow = false,
  });

  void update(double animationValue) {
    // Move bubble based on animation value and speed
    double movement = speed * 0.01;

    // Add some horizontal motion using a sine wave
    x += math.sin(animationValue * 2 * math.pi) * movement * 0.5;

    // Make sure x stays within bounds
    if (x < 0) x = 1.0;
    if (x > 1) x = 0.0;

    // Main vertical movement
    if (direction) {
      y -= movement;
      if (y < -0.1) y = 1.1; // Reappear from bottom when out of view
    } else {
      y += movement;
      if (y > 1.1) y = -0.1; // Reappear from top when out of view
    }
  }
}

class BubblesPainter extends CustomPainter {
  final List<Bubble> bubbles;
  final Color color;

  BubblesPainter({
    required this.bubbles,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (var bubble in bubbles) {
      final center = Offset(
        bubble.x * size.width,
        bubble.y * size.height,
      );

      if (bubble.glow) {
        // Add a glow effect
        final glowPaint = Paint()
          ..color = color.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
        canvas.drawCircle(center, bubble.radius * 1.5, glowPaint);
      }

      canvas.drawCircle(center, bubble.radius, paint);
    }
  }

  @override
  bool shouldRepaint(BubblesPainter oldDelegate) => true;
}
