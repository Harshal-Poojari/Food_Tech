import 'package:flutter/material.dart';
import 'dart:math' as math;

class ScanOptionCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPremium;

  const ScanOptionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.isPremium = false,
  });

  @override
  State<ScanOptionCard> createState() => _ScanOptionCardState();
}

class _ScanOptionCardState extends State<ScanOptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
        CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic));

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _handleHoverChanged(bool isHovered) {
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
    setState(() {
      _isHovered = isHovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHoverChanged(true),
      onExit: (_) => _handleHoverChanged(false),
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              children: [
                // Glow effect when hovered
                if (_isHovered)
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3 * _glowAnimation.value),
                            blurRadius: 12 * _glowAnimation.value,
                            spreadRadius: 2 * _glowAnimation.value,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Main card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1128).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isHovered
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.7)
                          : Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.3),
                      width: _isHovered ? 1.5 : 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onTap,
                      borderRadius: BorderRadius.circular(16),
                      splashColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      highlightColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.05),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Icon with circuit-like background
                            _buildIconContainer(),
                            const SizedBox(width: 16),

                            // Title and description
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        widget.title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      if (widget.isPremium) ...[
                                        const SizedBox(width: 8),
                                        _buildPremiumBadge(),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.description,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Arrow with animation
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              transform: Matrix4.translationValues(
                                  _isHovered ? 8.0 : 0.0, 0.0, 0.0),
                              child: Icon(
                                Icons.chevron_right,
                                color: _isHovered
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.6),
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconContainer() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF05102C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isHovered
              ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
              : Theme.of(context).colorScheme.secondary.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: _isHovered
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Circuit pattern background
          if (_isHovered)
            CustomPaint(
              painter: CircuitPainter(
                Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
              size: const Size(50, 50),
            ),

          // Icon with pulse effect
          Center(
            child: Icon(
              widget.icon,
              color: _isHovered
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class CircuitPainter extends CustomPainter {
  final Color color;

  CircuitPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final random = math.Random(42); // Fixed seed for consistent pattern

    // Create circuit trace patterns
    final path = Path();

    // Horizontal lines
    path.moveTo(0, size.height * 0.3);
    path.lineTo(size.width * 0.4, size.height * 0.3);
    path.lineTo(size.width * 0.4, size.height * 0.6);
    path.lineTo(size.width, size.height * 0.6);

    // Diagonal line
    path.moveTo(size.width * 0.7, 0);
    path.lineTo(size.width * 0.3, size.height * 0.8);
    path.lineTo(size.width * 0.3, size.height);

    canvas.drawPath(path, paint);

    // Add small circuit nodes
    paint.style = PaintingStyle.fill;

    // Node points at path intersections
    final nodePoints = [
      Offset(size.width * 0.4, size.height * 0.3),
      Offset(size.width * 0.4, size.height * 0.6),
      Offset(size.width * 0.3, size.height * 0.8),
    ];

    for (var point in nodePoints) {
      canvas.drawCircle(point, 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
