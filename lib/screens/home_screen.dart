import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:food_scanner/animations/animated_widgets.dart'
    as custom_animations;
import 'package:food_scanner/animations/animation_constants.dart';
import 'package:food_scanner/screens/scan_screen.dart';
import 'package:food_scanner/screens/login_screen.dart';
import 'package:food_scanner/themes/app_theme.dart';
import 'package:food_scanner/themes/background_themes.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _lottieController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoggedIn = false;
  int _backgroundPatternIndex = 0;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Randomly select a background pattern (0-4)
    _backgroundPatternIndex = DateTime.now().millisecond % 5;
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  void _navigateToScanScreen() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ScanScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToLoginScreen() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToRegisterScreen() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RegisterScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          // Background pattern
          BackgroundThemes.getBackgroundPattern(context,
              patternIndex: _backgroundPatternIndex),

          // Main content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildWelcomeSection(),
                        const SizedBox(height: 32),
                        _buildFeaturesList(),
                        const SizedBox(height: 32),
                        _buildScanButton(),
                        const SizedBox(height: 32),
                        _buildRecentItems(),
                        const SizedBox(height: 32),
                        _buildStatistics(),
                        const SizedBox(height: 32),
                        _buildInfoSection(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppTheme.primaryColor),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppTheme.primaryColor),
          onPressed: () {
            // Show search functionality
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: AppTheme.primaryColor),
          onPressed: () {
            // Show notifications
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: _buildInteractiveTitle(),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Light theme background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    AppTheme.primaryLightColor.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            // Animated food pattern
            CustomPaint(
              painter: _FoodPatternPainter(),
              child: Container(),
            ),
            // Subtle white overlay for better text contrast
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 80,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Interactive animated title
  Widget _buildInteractiveTitle() {
    return MouseRegion(
      onEnter: (_) {
        // Handle hover effect if needed
      },
      child: GestureDetector(
        onTap: () {
          // Optional: Do something fun when title is tapped
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Welcome to Food Scanner!'),
              backgroundColor: AppTheme.primaryColor,
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Food icon with rotation animation
              Icon(
                Icons.restaurant_menu,
                color: AppTheme.primaryColor,
                size: 24,
              )
                  .animate(
                    onPlay: (controller) => controller.repeat(),
                  )
                  .rotate(
                    duration: 3.seconds,
                    begin: 0,
                    end: 0.05,
                    curve: Curves.easeInOut,
                  )
                  .then()
                  .rotate(
                    duration: 3.seconds,
                    begin: 0.05,
                    end: 0,
                    curve: Curves.easeInOut,
                  ),
              const SizedBox(width: 8),
              // Stylish text with individual character animations
              Wrap(
                children: 'Food Scanner'.split('').map((char) {
                  return char == ' '
                      ? const SizedBox(width: 8)
                      : Text(
                          char,
                          style: TextStyle(
                            color: AppTheme.primaryDarkColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                          .animate(
                            onPlay: (controller) => controller.repeat(),
                            delay:
                                (0.1 * ('Food Scanner'.indexOf(char))).seconds,
                          )
                          .scaleXY(
                            begin: 1.0,
                            end: 1.1,
                            duration: 2.seconds,
                            curve: Curves.easeInOut,
                          )
                          .then()
                          .scaleXY(
                            begin: 1.1,
                            end: 1.0,
                            duration: 2.seconds,
                            curve: Curves.easeInOut,
                          );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Add tap interaction to welcome card
          final messages = [
            'Get detailed nutritional information!',
            'Discover what\'s in your food!',
            'Track your eating habits!',
            'Find allergens instantly!'
          ];
          final random = Random();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(messages[random.nextInt(messages.length)]),
              backgroundColor: AppTheme.primaryColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        splashColor: AppTheme.primaryLightColor.withOpacity(0.3),
        highlightColor: AppTheme.primaryLightColor.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                AppTheme.primaryLightColor.withOpacity(0.2),
              ],
            ),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  custom_animations.AnimatedEntrance.fadeInLeft(
                    child: Text(
                      'Welcome to Food Scanner',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryDarkColor,
                              ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.emoji_food_beverage,
                    color: AppTheme.primaryColor,
                  )
                      .animate(
                        onPlay: (controller) => controller.repeat(),
                      )
                      .scale(
                        duration: 2.seconds,
                        begin: const Offset(1, 1),
                        end: const Offset(1.2, 1.2),
                      )
                      .then()
                      .scale(
                        duration: 2.seconds,
                        begin: const Offset(1.2, 1.2),
                        end: const Offset(1, 1),
                      ),
                ],
              ),
              const SizedBox(height: 16),
              custom_animations.AnimatedEntrance.fadeInRight(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLightColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Scan food products to get detailed nutritional information and ingredients',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryDarkColor.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('Get Started'),
                    onPressed: _navigateToScanScreen,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Stack(
        children: [
          // Drawer background with pattern
          Container(
            decoration: BackgroundThemes.lightSubtleGradient,
          ),

          // Add subtle pattern overlay
          Opacity(
            opacity: 0.05,
            child: CustomPaint(
              painter: DotsPatternPainter(),
              size: Size.infinite,
            ),
          ),

          // Drawer content
          ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildDrawerHeader(),
              if (!_isLoggedIn) ...[
                ListTile(
                  leading:
                      const Icon(Icons.login, color: AppTheme.primaryColor),
                  title: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToLoginScreen();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_add,
                      color: AppTheme.primaryColor),
                  title: const Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToRegisterScreen();
                  },
                ),
                const Divider(),
              ],
              ListTile(
                leading: const Icon(Icons.home, color: AppTheme.primaryColor),
                title: const Text(
                  'Home',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.document_scanner,
                    color: AppTheme.primaryColor),
                title: const Text(
                  'Scan Food',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToScanScreen();
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.history, color: AppTheme.primaryColor),
                title: const Text(
                  'Scan History',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to scan history
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.add_alert, color: AppTheme.primaryColor),
                title: const Text(
                  'My Allergens',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to allergens screen
                },
              ),
              const Divider(),
              ListTile(
                leading:
                    const Icon(Icons.favorite, color: AppTheme.primaryColor),
                title: const Text(
                  'Favorite Products',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to favorites screen
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.bar_chart, color: AppTheme.primaryColor),
                title: const Text(
                  'Nutrition Insights',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to nutrition insights screen
                },
              ),
              const Divider(),
              ListTile(
                leading:
                    const Icon(Icons.settings, color: AppTheme.primaryColor),
                title: const Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to settings screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.help, color: AppTheme.primaryColor),
                title: const Text(
                  'Help & Support',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to help screen
                },
              ),
              if (_isLoggedIn) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _isLoggedIn = false;
                    });
                    // Perform logout
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, AppTheme.primaryDarkColor],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoggedIn)
            Text(
              'Welcome, User',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3,
                    color: Color.fromARGB(100, 0, 0, 0),
                  ),
                ],
              ),
            )
          else
            Text(
              'Welcome, Guest',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3,
                    color: Color.fromARGB(100, 0, 0, 0),
                  ),
                ],
              ),
            ),
          if (!_isLoggedIn)
            Text(
              'Please login to sync your data',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 2,
                    color: Color.fromARGB(100, 0, 0, 0),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {
        'icon': Icons.qr_code,
        'title': 'Barcode Scanner',
        'description': 'Scan product barcodes to get detailed information',
      },
      {
        'icon': Icons.camera_alt,
        'title': 'Image Recognition',
        'description':
            'Take photos of nutrition labels for automatic processing',
      },
      {
        'icon': Icons.notifications,
        'title': 'Allergen Alerts',
        'description': 'Get notified about allergens in scanned products',
      },
      {
        'icon': Icons.history,
        'title': 'Scan History',
        'description': 'Keep track of all your previously scanned items',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        custom_animations.AnimatedEntrance.fadeInLeft(
          child: Text(
            'Features',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        custom_animations.AnimatedList(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(
            features.length,
            (index) => Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLightColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        features[index]['icon'] as IconData,
                        color: AppTheme.primaryColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            features[index]['title'] as String,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            features[index]['description'] as String,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          custom_animations.AnimatedEntrance.fadeInUp(
            child: SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background pattern
                  CustomPaint(
                    painter: _ScanCirclesPainter(),
                    size: const Size(double.infinity, 180),
                  ),
                  // Centered Lottie animation
                  _buildLottieAnimation(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          custom_animations.AnimatedEntrance.popIn(
            child: InkWell(
              onTap: _navigateToScanScreen,
              borderRadius: BorderRadius.circular(50),
              splashColor: AppTheme.primaryLightColor,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryDarkColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.document_scanner, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      'Scan Food Item',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              )
                  .animate(
                    onPlay: (controller) => controller.repeat(),
                  )
                  .shimmer(
                    duration: 3.seconds,
                    color: Colors.white.withOpacity(0.2),
                  ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLottieAnimation() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing circle behind animation
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryLightColor.withOpacity(0.3),
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(),
            )
            .scale(
              duration: 1.5.seconds,
              begin: const Offset(1, 1),
              end: const Offset(1.2, 1.2),
              curve: Curves.easeInOut,
            )
            .then()
            .scale(
              duration: 1.5.seconds,
              begin: const Offset(1.2, 1.2),
              end: const Offset(1, 1),
              curve: Curves.easeInOut,
            ),

        // Lottie animation
        SizedBox(
          width: 150,
          height: 150,
          child: Lottie.asset(
            'assets/animations/scan_animation.json',
            controller: _lottieController,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to an icon if Lottie fails
              return Icon(
                Icons.document_scanner,
                size: 80,
                color: AppTheme.primaryColor,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentItems() {
    // Mock data for recent scans
    final recentItems = [
      {
        'name': 'Greek Yogurt',
        'image': 'yogurt',
        'date': 'Today',
        'calories': 130,
      },
      {
        'name': 'Granola Bar',
        'image': 'granola',
        'date': 'Yesterday',
        'calories': 210,
      },
      {
        'name': 'Apple Juice',
        'image': 'juice',
        'date': '2 days ago',
        'calories': 120,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        custom_animations.AnimatedEntrance.fadeInLeft(
          child: Text(
            'Recent Scans',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        custom_animations.AnimatedList(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(
            recentItems.length,
            (index) => Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildFoodItemImage(index),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recentItems[index]['name'] as String,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Scanned: ${recentItems[index]['date']}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${recentItems[index]['calories']} calories',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
          ),
        ),
        Center(
          child: TextButton(
            onPressed: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View All History',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodItemImage(int index) {
    // Use colored containers as placeholders
    final colors = [Colors.green[200], Colors.amber[200], Colors.orange[200]];

    return Container(
      width: 80,
      height: 80,
      color: colors[index % colors.length],
      child: Center(
        child: Icon(
          [
            Icons.lunch_dining,
            Icons.breakfast_dining,
            Icons.local_drink,
          ][index % 3],
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return custom_animations.AnimatedEntrance.fadeInUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Statistics',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildStatItem(
                        'Total Scans',
                        '32',
                        Icons.document_scanner,
                      ),
                      _buildStatItem('This Week', '8', Icons.calendar_today),
                      _buildStatItem('Favorites', '5', Icons.favorite),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Most Scanned Categories',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            _buildProgressBar('Snacks', 0.7, Colors.orange),
                            const SizedBox(height: 4),
                            _buildProgressBar('Dairy', 0.5, Colors.blue),
                            const SizedBox(height: 4),
                            _buildProgressBar('Beverages', 0.3, Colors.green),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryLightColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: 8,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  height: 8,
                  width: constraints.maxWidth * value,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return custom_animations.AnimateOnVisible.fadeInUp(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'How It Works',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...List.generate(3, (index) {
                final steps = [
                  {
                    'title': 'Scan the Barcode',
                    'description':
                        'Tap the scan button and aim your camera at the product barcode',
                  },
                  {
                    'title': 'Analyze Ingredients',
                    'description':
                        'The app will extract nutritional information and ingredients list',
                  },
                  {
                    'title': 'Get Detailed Information',
                    'description':
                        'View complete nutritional data, allergen alerts, and additives',
                  },
                ];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              steps[index]['title'] as String,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              steps[index]['description'] as String,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for food-themed pattern
class _FoodPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final random = Random(42); // Fixed seed for consistent patterns
    final icons = [
      _drawApple,
      _drawCarrot,
      _drawBroccoli,
      _drawBanana,
      _drawCup,
    ];

    // Add a subtle background pattern
    final dotPaint = Paint()
      ..color = AppTheme.primaryLightColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw subtle dots in the background
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 1 + random.nextDouble() * 2;

      canvas.drawCircle(Offset(x, y), radius, dotPaint);
    }

    // Draw food icons
    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final scale = 0.4 + random.nextDouble() * 0.8;
      final iconIndex = random.nextInt(icons.length);

      canvas.save();
      canvas.translate(x, y);
      canvas.scale(scale, scale);

      // Draw the food icon
      icons[iconIndex](canvas, paint);

      canvas.restore();
    }
  }

  void _drawApple(Canvas canvas, Paint paint) {
    final path = Path();

    // Apple body
    path.addOval(
        Rect.fromCenter(center: const Offset(0, 0), width: 20, height: 25));

    // Apple stem
    path.moveTo(-2, -12);
    path.quadraticBezierTo(0, -17, 3, -15);

    // Leaf
    path.moveTo(3, -15);
    path.quadraticBezierTo(8, -17, 10, -13);
    path.quadraticBezierTo(7, -12, 3, -15);

    canvas.drawPath(path, paint);
  }

  void _drawCarrot(Canvas canvas, Paint paint) {
    final path = Path();

    // Carrot body
    path.moveTo(0, -15);
    path.lineTo(8, 15);
    path.lineTo(-8, 15);
    path.close();

    // Carrot top
    for (int i = -6; i <= 6; i += 3) {
      path.moveTo(i.toDouble(), -15);
      path.quadraticBezierTo(i * 1.5, -25, i * 2, -20);
    }

    canvas.drawPath(path, paint);
  }

  void _drawBroccoli(Canvas canvas, Paint paint) {
    // Stem
    canvas.drawRect(
      Rect.fromLTWH(-3, 0, 6, 15),
      paint,
    );

    // Florets
    canvas.drawCircle(const Offset(0, -5), 10, paint);
    canvas.drawCircle(const Offset(-8, -3), 7, paint);
    canvas.drawCircle(const Offset(8, -3), 7, paint);
    canvas.drawCircle(const Offset(0, -12), 7, paint);
  }

  void _drawBanana(Canvas canvas, Paint paint) {
    final path = Path();

    path.moveTo(-10, 0);
    path.quadraticBezierTo(0, -20, 10, 0);
    path.quadraticBezierTo(0, 10, -10, 0);

    canvas.drawPath(path, paint);
  }

  void _drawCup(Canvas canvas, Paint paint) {
    // Cup body
    canvas.drawRect(
      Rect.fromLTWH(-7, -5, 14, 15),
      paint,
    );

    // Cup handle
    final handlePath = Path();
    handlePath.moveTo(7, 0);
    handlePath.quadraticBezierTo(14, 0, 14, 5);
    handlePath.quadraticBezierTo(14, 10, 7, 10);
    handlePath.quadraticBezierTo(10, 5, 7, 0);

    canvas.drawPath(handlePath, paint);

    // Steam
    final steamPath = Path();
    steamPath.moveTo(-3, -5);
    steamPath.quadraticBezierTo(0, -10, 3, -5);
    steamPath.quadraticBezierTo(6, -15, 0, -15);

    canvas.drawPath(steamPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Custom painter for scan button circles
class _ScanCirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = AppTheme.primaryColor.withOpacity(0.2);

    // Draw multiple circles
    for (int i = 0; i < 5; i++) {
      double radius = 20.0 + (i * 15.0);
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        radius,
        paint,
      );
    }

    // Draw some dots
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppTheme.primaryLightColor.withOpacity(0.2);

    final random = Random(42);
    for (int i = 0; i < 30; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final radius = 30 + random.nextDouble() * 80;
      final x = size.width / 2 + radius * cos(angle);
      final y = size.height / 2 + radius * sin(angle);
      final dotSize = 1 + random.nextDouble() * 3;

      canvas.drawCircle(Offset(x, y), dotSize, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
