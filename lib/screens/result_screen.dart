import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_scanner/animations/animated_widgets.dart';
import 'package:food_scanner/models/food_item.dart';
import 'package:food_scanner/themes/app_theme.dart';
import 'package:lottie/lottie.dart';

class ResultScreen extends StatefulWidget {
  final String? barcode;
  final String? extractedText;
  final Map<String, dynamic>? nutritionInfo;
  final List<String>? ingredients;
  final List<String>? allergens;
  final String? imagePath;

  const ResultScreen({
    super.key,
    this.barcode,
    this.extractedText,
    this.nutritionInfo,
    this.ingredients,
    this.allergens,
    this.imagePath,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _confettiController;
  bool _isLoading = true;
  FoodItem? _foodItem;

  @override
  void initState() {
    super.initState();

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Simulate API call to get food data
    _loadFoodData();
  }

  Future<void> _loadFoodData() async {
    // In a real app, you would make an API call with the barcode or text data
    await Future.delayed(const Duration(seconds: 2));

    // Create mock food item for demonstration
    if (mounted) {
      setState(() {
        _foodItem = FoodItem(
          id: '123456',
          name: 'Greek Yogurt',
          barcode: widget.barcode ?? '7891234567890',
          imageUrl:
              'https://images.unsplash.com/photo-1488477181946-6428a0291777?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1587&q=80',
          description: 'Plain Greek yogurt with live and active cultures',
          nutritionInfo: NutritionInfo(
            calories: widget.nutritionInfo?['calories'] ?? 130.0,
            protein: widget.nutritionInfo?['protein'] ?? 12.0,
            fat: widget.nutritionInfo?['fat'] ?? 4.0,
            carbs: widget.nutritionInfo?['carbs'] ?? 8.0,
            sugar: widget.nutritionInfo?['sugar'] ?? 6.0,
            fiber: widget.nutritionInfo?['fiber'] ?? 0.0,
            sodium: widget.nutritionInfo?['sodium'] ?? 85.0,
            vitamins: {'Calcium': 20.0, 'Vitamin D': 15.0, 'Potassium': 8.0},
            minerals: {'Iron': 0.0, 'Magnesium': 5.0},
          ),
          ingredients:
              widget.ingredients ??
              [
                'Cultured Grade A Milk',
                'Cream',
                'Live Active Yogurt Cultures',
                'Vitamin D3',
              ],
          allergens: widget.allergens ?? ['Milk'],
          rating: 4.5,
        );

        _isLoading = false;
        _confettiController.forward();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? _buildLoadingView() : _buildResultView(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.network(
            'https://assets2.lottiefiles.com/temp/lf20_aKAfIn.json',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 24),
          AnimatedEntrance.fadeInUp(
            child: Text(
              'Analyzing Food Item...',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedEntrance.fadeInUp(
            child: Text(
              'We are searching our database and analyzing the nutritional content',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    if (_foodItem == null) {
      return Center(
        child: Text(
          'No food data found',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(),
        SliverList(
          delegate: SliverChildListDelegate([
            _buildHeader(),
            const SizedBox(height: 16),
            _buildNutritionCard(),
            const SizedBox(height: 16),
            _buildIngredientsCard(),
            const SizedBox(height: 16),
            _buildAllergensCard(),
            const SizedBox(height: 16),
            _buildActionsSection(),
            const SizedBox(height: 32),
          ]),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.favorite_border),
          tooltip: 'Add to favorites',
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.share),
          tooltip: 'Share',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Product image
            widget.imagePath != null
                ? Image.file(File(widget.imagePath!), fit: BoxFit.cover)
                : Image.network(_foodItem!.imageUrl, fit: BoxFit.cover),

            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
            ),

            // Confetti animation overlay
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                if (_confettiController.value == 0) {
                  return const SizedBox.shrink();
                }

                return Opacity(
                  opacity:
                      _confettiController.value < 0.5
                          ? _confettiController.value * 2
                          : 1 - ((_confettiController.value - 0.5) * 2),
                  child: Lottie.network(
                    'https://assets9.lottiefiles.com/packages/lf20_qmfs6c3i.json',
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),

            // Product name at bottom of image
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: AnimatedEntrance.fadeInUp(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _foodItem!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    if (widget.barcode != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.qr_code,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Barcode: ${widget.barcode}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedEntrance.fadeInLeft(
            child: Text(
              _foodItem!.description,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedEntrance.fadeInRight(
            child: Row(
              children: [
                // Rating stars
                ...List.generate(5, (index) {
                  return Icon(
                    index < _foodItem!.rating.floor()
                        ? Icons.star
                        : index < _foodItem!.rating
                        ? Icons.star_half
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  _foodItem!.rating.toString(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green[300]!, width: 1),
                  ),
                  child: Text(
                    'Healthy Choice',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AnimatedEntrance.fadeInUp(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lunch_dining,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Nutrition Facts',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildNutritionItem(
                        'Calories',
                        '${_foodItem!.nutritionInfo.calories.toInt()}',
                        'kcal',
                        Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: _buildNutritionItem(
                        'Protein',
                        _foodItem!.nutritionInfo.protein.toString(),
                        'g',
                        Colors.red,
                      ),
                    ),
                    Expanded(
                      child: _buildNutritionItem(
                        'Fat',
                        _foodItem!.nutritionInfo.fat.toString(),
                        'g',
                        Colors.yellow[700]!,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildNutritionItem(
                        'Carbs',
                        _foodItem!.nutritionInfo.carbs.toString(),
                        'g',
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildNutritionItem(
                        'Sugar',
                        _foodItem!.nutritionInfo.sugar.toString(),
                        'g',
                        Colors.pink,
                      ),
                    ),
                    Expanded(
                      child: _buildNutritionItem(
                        'Sodium',
                        _foodItem!.nutritionInfo.sodium.toInt().toString(),
                        'mg',
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View Complete Nutrition Information',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionItem(
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(text: value),
                  TextSpan(
                    text: unit,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildIngredientsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AnimatedEntrance.fadeInUp(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.eco, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Ingredients',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  children: List.generate(
                    _foodItem!.ingredients.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '),
                          Expanded(child: Text(_foodItem!.ingredients[index])),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllergensCard() {
    if (_foodItem!.allergens.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AnimatedEntrance.fadeInUp(
        child: Card(
          color: Colors.red[50],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Allergens',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    _foodItem!.allergens.length,
                    (index) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red[300]!, width: 1),
                      ),
                      child: Text(
                        _foodItem!.allergens[index],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AnimatedEntrance.fadeInUp(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.list_alt),
                label: const Text('Add to List'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_chart),
                label: const Text('Track Calories'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
