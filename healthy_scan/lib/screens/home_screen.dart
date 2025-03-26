import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';
import 'food_diary_screen.dart';
import 'scan_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Healthy Scan'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0, 0.5, curve: Curves.easeOutQuad),
                    )),
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0, 0.5),
                        ),
                      ),
                      child: _buildWelcomeCard(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick actions
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve:
                          const Interval(0.1, 0.6, curve: Curves.easeOutQuad),
                    )),
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0.1, 0.6),
                        ),
                      ),
                      child: _buildQuickActionsCard(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Daily statistics
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve:
                          const Interval(0.2, 0.7, curve: Curves.easeOutQuad),
                    )),
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0.2, 0.7),
                        ),
                      ),
                      child: _buildDailyStatsCard(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Healthy tips
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve:
                          const Interval(0.3, 0.8, curve: Curves.easeOutQuad),
                    )),
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0.3, 0.8),
                        ),
                      ),
                      child: _buildHealthyTipsCard(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    // Get current time of day
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

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
      child: Stack(
        children: [
          // Circuit decoration
          Positioned(
            top: 10,
            right: 10,
            child: CustomPaint(
              painter: CircuitBackgroundPainter(
                Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
              size: const Size(100, 100),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildAvatarContainer(),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'John Doe',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.health_and_safety,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'LEVEL 5',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Making great progress this week!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat('1,200', 'kcal Consumed'),
                  _buildDigitalDivider(),
                  _buildStat('800', 'kcal Remaining'),
                  _buildDigitalDivider(),
                  _buildStat('12', 'Days Streak'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarContainer() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFF05102C),
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Stack(
          children: [
            // Glow effect
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: -3,
                    ),
                  ],
                ),
              ),
            ),
            const Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitalDivider() {
    return Column(
      children: [
        Container(
          width: 1,
          height: 8,
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
        ),
        Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
          ),
        ),
        Container(
          width: 1,
          height: 20,
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
        ),
        Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
          ),
        ),
        Container(
          width: 1,
          height: 8,
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1128).withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
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
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'QUICK ACTIONS',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickAction(
                icon: Icons.qr_code_scanner_outlined,
                label: 'Scan',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScanScreen()),
                  );
                },
              ),
              _buildQuickAction(
                icon: Icons.book_outlined,
                label: 'Diary',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FoodDiaryScreen()),
                  );
                },
              ),
              _buildQuickAction(
                icon: Icons.add_outlined,
                label: 'Add Meal',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add meal feature coming soon!'),
                    ),
                  );
                },
              ),
              _buildQuickAction(
                icon: Icons.person_outlined,
                label: 'Profile',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF05102C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.secondary,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyStatsCard() {
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
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'TODAY\'S NUTRITION',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildNutrientProgressBar(
            label: 'Calories',
            value: 60,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          _buildNutrientProgressBar(
            label: 'Protein',
            value: 75,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildNutrientProgressBar(
            label: 'Carbs',
            value: 45,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildNutrientProgressBar(
            label: 'Fat',
            value: 30,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.data_usage,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'View Detailed Report',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientProgressBar({
    required String label,
    required int value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$value%',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            // Background
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF05102C),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Progress
            Container(
              height: 8,
              width: MediaQuery.of(context).size.width * (value / 100) * 0.7,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 6,
                    spreadRadius: -1,
                  ),
                ],
              ),
            ),
            // Digital overlay pattern
            SizedBox(
              height: 8,
              width: double.infinity,
              child: CustomPaint(
                painter: DigitalOverlayPainter(
                  Colors.white.withOpacity(0.2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthyTipsCard() {
    final List<Map<String, dynamic>> tips = [
      {
        'title': 'Stay Hydrated',
        'description':
            'Drink at least 8 glasses of water daily for optimal health.',
        'icon': Icons.water_drop_outlined,
      },
      {
        'title': 'Eat More Vegetables',
        'description':
            'Aim for 5 servings of vegetables daily for essential nutrients.',
        'icon': Icons.eco_outlined,
      },
      {
        'title': 'Limit Processed Foods',
        'description':
            'Choose whole foods over processed to reduce sodium and sugar intake.',
        'icon': Icons.no_food_outlined,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1128).withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
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
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'HEALTH INSIGHTS',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...tips.map((tip) => _buildTipItem(tip)).toList(),
        ],
      ),
    );
  }

  Widget _buildTipItem(Map<String, dynamic> tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF05102C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              tip['icon'],
              color: Theme.of(context).colorScheme.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip['description'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CircuitBackgroundPainter extends CustomPainter {
  final Color color;

  CircuitBackgroundPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Create circuit trace patterns
    final path = Path();

    // Horizontal lines
    path.moveTo(0, size.height * 0.3);
    path.lineTo(size.width * 0.4, size.height * 0.3);
    path.lineTo(size.width * 0.4, size.height * 0.6);
    path.lineTo(size.width * 0.7, size.height * 0.6);
    path.lineTo(size.width * 0.7, size.height * 0.9);
    path.lineTo(size.width, size.height * 0.9);

    // Additional lines
    path.moveTo(size.width * 0.2, 0);
    path.lineTo(size.width * 0.2, size.height * 0.15);
    path.lineTo(size.width * 0.6, size.height * 0.15);
    path.lineTo(size.width * 0.6, size.height * 0.4);

    path.moveTo(size.width * 0.8, 0);
    path.lineTo(size.width * 0.8, size.height * 0.7);
    path.lineTo(size.width, size.height * 0.7);

    canvas.drawPath(path, paint);

    // Add small circuit nodes
    paint.style = PaintingStyle.fill;

    // Node points at path intersections
    final nodePoints = [
      Offset(size.width * 0.4, size.height * 0.3),
      Offset(size.width * 0.4, size.height * 0.6),
      Offset(size.width * 0.7, size.height * 0.6),
      Offset(size.width * 0.7, size.height * 0.9),
      Offset(size.width * 0.2, size.height * 0.15),
      Offset(size.width * 0.6, size.height * 0.15),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.8, size.height * 0.7),
    ];

    for (var point in nodePoints) {
      canvas.drawCircle(point, 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DigitalOverlayPainter extends CustomPainter {
  final Color color;

  DigitalOverlayPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (int i = 1; i < size.width; i += 6) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
