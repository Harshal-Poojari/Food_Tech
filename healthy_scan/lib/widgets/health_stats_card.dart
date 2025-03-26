import 'package:flutter/material.dart';
import 'dart:math' as math;

class HealthStatsCard extends StatefulWidget {
  final double height;
  final double weight;
  final double bmi;
  final String bmiCategory;
  final int dailyCalorieTarget;

  const HealthStatsCard({
    super.key,
    required this.height,
    required this.weight,
    required this.bmi,
    required this.bmiCategory,
    required this.dailyCalorieTarget,
  });

  @override
  State<HealthStatsCard> createState() => _HealthStatsCardState();
}

class _HealthStatsCardState extends State<HealthStatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1128).withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(
                                  0.2 + 0.1 * _animationController.value),
                          blurRadius: 8,
                          spreadRadius: 1 + _animationController.value,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.monitor_heart_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Text(
                'HEALTH METRICS',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Hexagonal stats display
          _buildHexagonalStats(context),

          const SizedBox(height: 24),

          // Additional stats
          Row(
            children: [
              Expanded(
                child: _buildAdvancedStatItem(
                  'BMI',
                  '${widget.bmi.toStringAsFixed(1)}',
                  _getBmiColor(widget.bmiCategory),
                  subtitle: widget.bmiCategory,
                  context: context,
                ),
              ),
              Expanded(
                child: _buildAdvancedStatItem(
                  'CALORIE TARGET',
                  '${widget.dailyCalorieTarget}',
                  Theme.of(context).colorScheme.primary,
                  subtitle: 'kcal/day',
                  context: context,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHexagonalStats(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildHexagonStat(
            'HEIGHT',
            '${widget.height}',
            'cm',
            Theme.of(context).colorScheme.primary,
            context,
          ),
          _buildHexagonStat(
            'WEIGHT',
            '${widget.weight}',
            'kg',
            Colors.cyan,
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildHexagonStat(String label, String value, String unit, Color color,
      BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer hex
            CustomPaint(
              size: const Size(85, 85),
              painter: HexagonPainter(
                color: color.withOpacity(0.2),
                strokeColor: color.withOpacity(0.5),
                strokeWidth: 2,
              ),
            ),
            // Inner hex
            CustomPaint(
              size: const Size(70, 70),
              painter: HexagonPainter(
                color: color.withOpacity(0.1),
                strokeColor: color.withOpacity(0.3),
                strokeWidth: 1.5,
              ),
            ),
            // Value
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.8),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedStatItem(
    String label,
    String value,
    Color color, {
    required String subtitle,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF05102C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  label.contains('BMI')
                      ? Icons.sync_alt
                      : Icons.local_fire_department,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              subtitle,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBmiColor(String category) {
    switch (category.toLowerCase()) {
      case 'underweight':
        return Colors.orange;
      case 'normal weight':
        return Colors.green;
      case 'overweight':
        return Colors.orange;
      case 'obese':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}

class HexagonPainter extends CustomPainter {
  final Color color;
  final Color strokeColor;
  final double strokeWidth;

  HexagonPainter({
    required this.color,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 + 30) * math.pi / 180;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
