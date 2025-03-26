import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_diary_entry.dart' as diary;
import '../services/food_diary_service.dart';
import '../services/auth_service.dart';

class FoodDiaryScreen extends StatefulWidget {
  const FoodDiaryScreen({Key? key}) : super(key: key);

  @override
  _FoodDiaryScreenState createState() => _FoodDiaryScreenState();
}

class _FoodDiaryScreenState extends State<FoodDiaryScreen> {
  final FoodDiaryService _diaryService = FoodDiaryService();
  late AuthService _authService;
  DateTime _selectedDate = DateTime.now();
  List<diary.FoodDiaryEntry> _entries = [];
  diary.DailyFoodSummary? _dailySummary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final prefs = await SharedPreferences.getInstance();
    _authService = AuthService(prefs);
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
    });
    
    final userId = _authService.currentUser?.id;
    if (userId != null) {
      final entries = await _diaryService.getEntriesForDate(userId, _selectedDate);
      final summary = await _diaryService.getDailySummary(userId, _selectedDate);
      
      if (mounted) {
        setState(() {
          _entries = entries;
          _dailySummary = summary;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatMacros(diary.NutritionInfo nutrition) {
    return 'P: ${nutrition.protein.toStringAsFixed(1)}g '
        'C: ${nutrition.carbs.toStringAsFixed(1)}g '
        'F: ${nutrition.fat.toStringAsFixed(1)}g';
  }

  Widget _buildMealSection(String title, List<diary.FoodDiaryEntry> mealEntries) {
    final totalCalories = mealEntries.fold<int>(
      0,
      (sum, entry) => sum + entry.foodItem.nutritionInfo.calories.toInt(),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(title),
            trailing: Text('$totalCalories cal'),
          ),
          if (mealEntries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No entries'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mealEntries.length,
              itemBuilder: (context, index) {
                final entry = mealEntries[index];
                return ListTile(
                  title: Text(entry.foodItem.name),
                  subtitle: Text(_formatMacros(entry.actualNutrition)),
                  trailing: Text(
                    '${entry.actualNutrition.calories.toInt()} cal',
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDailySummary() {
    if (_dailySummary == null) {
      return const SizedBox.shrink();
    }

    final totalNutrition = _dailySummary!.totalNutrition;
    
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Total Calories: ${totalNutrition.calories.toInt()}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            Text('Macronutrients:'),
            Text(_formatMacros(totalNutrition)),
            const SizedBox(height: 8.0),
            LinearProgressIndicator(
              value: totalNutrition.calories.toInt() / 2000, // TODO: Use user's target
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                totalNutrition.calories.toInt() > 2000
                    ? Colors.red
                    : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final breakfastEntries = _entries
        .where((e) => e.mealType == diary.MealType.breakfast)
        .toList();
    final lunchEntries = _entries
        .where((e) => e.mealType == diary.MealType.lunch)
        .toList();
    final dinnerEntries = _entries
        .where((e) => e.mealType == diary.MealType.dinner)
        .toList();
    final snackEntries = _entries
        .where((e) => e.mealType == diary.MealType.snack)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Diary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2025),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
                _loadEntries();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: const CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEntries,
              child: ListView(
                children: [
                  _buildDailySummary(),
                  _buildMealSection('Breakfast', breakfastEntries),
                  _buildMealSection('Lunch', lunchEntries),
                  _buildMealSection('Dinner', dinnerEntries),
                  _buildMealSection('Snacks', snackEntries),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add food entry
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Coming soon!')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
