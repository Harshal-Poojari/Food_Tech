import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/meal_plan.dart';
import '../models/food_diary_entry.dart';
import '../services/meal_plan_service.dart';
import '../services/auth_service.dart';
import '../widgets/gradient_background.dart';
import '../widgets/animated_scale_button.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> with SingleTickerProviderStateMixin {
  final MealPlanService _mealPlanService = MealPlanService();
  MealPlan? _activeMealPlan;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    
    _loadMealPlan();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMealPlan() async {
    setState(() {
      _isLoading = true;
    });
    
    final userId = Provider.of<AuthService>(context, listen: false).currentUser!.uid;
    try {
      final activePlan = await _mealPlanService.getActiveMealPlan(userId);
      
      setState(() {
        _activeMealPlan = activePlan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading meal plan: $e')),
        );
      }
    }
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  Future<void> _createNewMealPlan() async {
    final userId = Provider.of<AuthService>(context, listen: false).currentUser!.uid;
    
    // Show dialog to get meal plan details
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _CreateMealPlanDialog(),
    );
    
    if (result != null) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Create a new meal plan
        await _mealPlanService.createMealPlan(
          userId: userId,
          startDate: result['startDate'],
          endDate: result['endDate'],
          notes: result['notes'],
        );
        
        // Reload the meal plan
        await _loadMealPlan();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meal plan created successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating meal plan: $e')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markItemAsCompleted(String itemId) async {
    if (_activeMealPlan == null) return;
    
    try {
      await _mealPlanService.completeMealPlanItem(
        mealPlanId: _activeMealPlan!.id,
        itemId: itemId,
      );
      
      // Reload the meal plan
      await _loadMealPlan();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item marked as completed and added to food diary')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing meal plan item: $e')),
        );
      }
    }
  }

  Future<void> _markItemAsSkipped(String itemId) async {
    if (_activeMealPlan == null) return;
    
    try {
      await _mealPlanService.skipMealPlanItem(
        mealPlanId: _activeMealPlan!.id,
        itemId: itemId,
      );
      
      // Reload the meal plan
      await _loadMealPlan();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item marked as skipped')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error skipping meal plan item: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Meal Planner'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadMealPlan,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(theme),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _createNewMealPlan,
          icon: const Icon(Icons.add),
          label: const Text('New Plan'),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_activeMealPlan == null) {
      return Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.restaurant_menu, size: 80, color: Colors.white70),
              const SizedBox(height: 16),
              Text(
                'No Active Meal Plan',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Create a new meal plan to get started',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _createNewMealPlan,
                icon: const Icon(Icons.add),
                label: const Text('Create Meal Plan'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Get items for the selected date
    final dayItems = _activeMealPlan!.getItemsForDay(_selectedDate);
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Column(
      children: [
        // Date selector
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meal Plan',  // Replace _activeMealPlan!.name with a static title
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${dateFormat.format(_activeMealPlan!.startDate)} - ${dateFormat.format(_activeMealPlan!.endDate)}',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  _buildDateSelector(theme),
                ],
              ),
            ),
          ),
        ),
        
        // Meal plan items for selected date
        Expanded(
          child: dayItems.isEmpty
              ? _buildEmptyDayMessage(theme)
              : _buildMealPlanItems(dayItems, theme),
        ),
      ],
    );
  }

  Widget _buildDateSelector(ThemeData theme) {
    final days = _getDaysInMealPlan();
    
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = day.year == _selectedDate.year &&
                            day.month == _selectedDate.month &&
                            day.day == _selectedDate.day;
          
          return AnimatedScaleButton(
            onTap: () => _selectDate(day),
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary : theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(day).substring(0, 3),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day.day.toString(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<DateTime> _getDaysInMealPlan() {
    if (_activeMealPlan == null) return [];
    
    final days = <DateTime>[];
    final startDate = _activeMealPlan!.startDate;
    final endDate = _activeMealPlan!.endDate;
    
    for (var i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    
    return days;
  }

  Widget _buildEmptyDayMessage(ThemeData theme) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_meals, size: 64, color: Colors.white70),
            const SizedBox(height: 16),
            Text(
              'No meals planned for this day',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add meals',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealPlanItems(List<MealPlanItem> items, ThemeData theme) {
    // Group items by meal type
    final groupedItems = <MealType, List<MealPlanItem>>{};
    for (final type in MealType.values) {
      groupedItems[type] = items.where((item) => item.mealType == type).toList();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: MealType.values.length,
      itemBuilder: (context, index) {
        final mealType = MealType.values[index];
        final mealItems = groupedItems[mealType] ?? [];
        
        if (mealItems.isEmpty) return const SizedBox.shrink();
        
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getMealTypeIcon(mealType),
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getMealTypeName(mealType),
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const Divider(),
                  ...mealItems.map((item) => _buildMealPlanItemTile(item, theme)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealPlanItemTile(MealPlanItem item, ThemeData theme) {
    final isCompleted = item.status == MealPlanStatus.completed;
    final isSkipped = item.status == MealPlanStatus.skipped;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food image or placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              image: item.foodItem.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(item.foodItem.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: item.foodItem.imageUrl == null
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
                  item.foodItem.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    decoration: isCompleted || isSkipped
                        ? TextDecoration.lineThrough
                        : null,
                    color: isSkipped ? Colors.white54 : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.servingAmount} ${item.foodItem.servingUnit}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.foodItem.nutritionInfo.calories.round() * item.servingAmount.round()} calories',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (item.status != MealPlanStatus.pending)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      isCompleted ? 'Completed' : 'Skipped',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isCompleted
                            ? theme.colorScheme.primary
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Action buttons
          if (item.status == MealPlanStatus.pending)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  color: theme.colorScheme.primary,
                  onPressed: () => _markItemAsCompleted(item.id),
                  tooltip: 'Mark as completed',
                ),
                IconButton(
                  icon: const Icon(Icons.cancel_outlined),
                  color: Colors.orange,
                  onPressed: () => _markItemAsSkipped(item.id),
                  tooltip: 'Skip',
                ),
              ],
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
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }
}

class _CreateMealPlanDialog extends StatefulWidget {
  @override
  _CreateMealPlanDialogState createState() => _CreateMealPlanDialogState();
}

class _CreateMealPlanDialogState extends State<_CreateMealPlanDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 6));
  bool _autoGenerate = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (pickedDate != null && pickedDate != _startDate) {
      setState(() {
        _startDate = pickedDate;
        // Ensure end date is not before start date
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 6));
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 30)),
    );
    
    if (pickedDate != null && pickedDate != _endDate) {
      setState(() {
        _endDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return AlertDialog(
      title: const Text('Create Meal Plan'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Plan Name',
                  hintText: 'Weekly Meal Plan',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text('Start Date', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectStartDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dateFormat.format(_startDate)),
                      const Icon(Icons.calendar_today, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('End Date', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectEndDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dateFormat.format(_endDate)),
                      const Icon(Icons.calendar_today, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Auto-generate meals'),
                subtitle: const Text('Generate a suggested meal plan based on your preferences'),
                value: _autoGenerate,
                onChanged: (value) {
                  setState(() {
                    _autoGenerate = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'name': _nameController.text,
                'startDate': _startDate,
                'endDate': _endDate,
                'autoGenerate': _autoGenerate,
              });
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
