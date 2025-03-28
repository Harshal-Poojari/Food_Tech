import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../models/food_diary_entry.dart';
import '../models/user_profile.dart';
import '../services/food_recommendation_service.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/food_diary_service.dart';
import '../widgets/gradient_background.dart';
import 'food_details_screen.dart';

class FoodRecommendationsScreen extends StatefulWidget {
  const FoodRecommendationsScreen({super.key});

  @override
  State<FoodRecommendationsScreen> createState() =>
      _FoodRecommendationsScreenState();
}

class _FoodRecommendationsScreenState extends State<FoodRecommendationsScreen>
    with SingleTickerProviderStateMixin {
  final FoodRecommendationService _recommendationService =
      FoodRecommendationService();
  final DatabaseService _databaseService = DatabaseService();
  final FoodDiaryService _diaryService = FoodDiaryService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = true;
  UserProfile? _userProfile;
  DailyFoodSummary? _dailySummary;
  List<FoodItem>? _nutritionGapRecommendations;
  Map<MealType, List<FoodItem>>? _mealIdeas;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _loadData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final userId =
        Provider.of<AuthService>(context, listen: false).currentUser!.uid;

    try {
      // Load user profile
      final userProfileDoc =
          await _databaseService.getDocument('userProfiles/$userId');
      final userProfile = UserProfile.fromJson(userProfileDoc.toString());

      // Load today's food diary
      final today = DateTime.now();
      final entries = await _diaryService.getEntriesForDate(userId, today);
      final dailySummary = DailyFoodSummary(
        userId: userId,
        date: today,
        entries: entries,
      );

      // Get recommendations
      final nutritionGapRecommendations =
          await _recommendationService.getRecommendations(
        userProfile: userProfile,
        dailySummary: dailySummary,
        limit: 5,
      );

      // Get meal ideas
      final mealIdeas = await _recommendationService.getMealIdeas(
        userProfile,
        dailySummary,
      );

      setState(() {
        _userProfile = userProfile;
        _dailySummary = dailySummary;
        _nutritionGapRecommendations = nutritionGapRecommendations.cast<FoodItem>();
        _mealIdeas = mealIdeas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading recommendations: $e')),
        );
      }
    }
  }

  void _navigateToFoodDetails(FoodItem foodItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodDetailsScreen(foodItem: foodItem),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Food Recommendations'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(theme),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_userProfile == null || _dailySummary == null) {
      return const Center(
        child: Text('Unable to load recommendations'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nutrition gap recommendations
          if (_nutritionGapRecommendations != null &&
              _nutritionGapRecommendations!.isNotEmpty)
            _buildNutritionGapSection(theme),

          const SizedBox(height: 24),

          // Meal ideas
          if (_mealIdeas != null && _mealIdeas!.isNotEmpty)
            _buildMealIdeasSection(theme),

          // If no recommendations
          if ((_nutritionGapRecommendations == null ||
                  _nutritionGapRecommendations!.isEmpty) &&
              (_mealIdeas == null || _mealIdeas!.isEmpty))
            _buildNoRecommendationsMessage(theme),
        ],
      ),
    );
  }

  Widget _buildNutritionGapSection(ThemeData theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.recommend,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Recommended for Your Nutrition',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Based on your nutritional needs today',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ..._nutritionGapRecommendations!.map(
            (food) => _buildFoodItemCard(food, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildMealIdeasSection(ThemeData theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant_menu,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Meal Ideas for Today',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._mealIdeas!.entries.map((entry) {
            final mealType = entry.key;
            final foods = entry.value;

            if (foods.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getMealTypeIcon(mealType),
                      color: theme.colorScheme.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getMealTypeName(mealType),
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...foods.map((food) => _buildFoodItemCard(food, theme)),
                const SizedBox(height: 16),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNoRecommendationsMessage(ThemeData theme) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_food, size: 64, color: Colors.white70),
            const SizedBox(height: 16),
            Text(
              'No recommendations available',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re doing great with your nutrition today!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItemCard(FoodItem food, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _navigateToFoodDetails(food),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food image or placeholder
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  image: food.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(food.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: food.imageUrl == null
                    ? Icon(
                        Icons.restaurant,
                        color: theme.colorScheme.primary,
                        size: 30,
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Food details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: theme.textTheme.titleSmall,
                    ),
                    if (food.brand != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        food.brand!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildNutrientBadge(
                          'Cal',
                          food.nutritionInfo.calories.round().toString(),
                          theme,
                        ),
                        const SizedBox(width: 8),
                        _buildNutrientBadge(
                          'Protein',
                          '${food.nutritionInfo.protein.round()}g',
                          theme,
                        ),
                        const SizedBox(width: 8),
                        _buildNutrientBadge(
                          'Carbs',
                          '${food.nutritionInfo.carbs.round()}g',
                          theme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Health score
              Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getHealthScoreColor(food.healthScore),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        food.healthScore.toString(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Score',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientBadge(String label, String value, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMealTypeIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.free_breakfast;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.cookie;
    }
  }

  String _getMealTypeName(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'Breakfast Ideas';
      case MealType.lunch:
        return 'Lunch Ideas';
      case MealType.dinner:
        return 'Dinner Ideas';
      case MealType.snack:
        return 'Snack Ideas';
    }
  }

  Color _getHealthScoreColor(int score) {
    if (score >= 80) {
      return Colors.greenAccent;
    } else if (score >= 60) {
      return Colors.lightGreenAccent;
    } else if (score >= 40) {
      return Colors.yellowAccent;
    } else if (score >= 20) {
      return Colors.orangeAccent;
    } else {
      return Colors.redAccent;
    }
  }
}

extension on FoodRecommendationService {
  getMealIdeas(UserProfile userProfile, DailyFoodSummary dailySummary) {

  }
}
