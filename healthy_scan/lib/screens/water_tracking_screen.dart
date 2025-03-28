import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/water_intake.dart';
import '../services/water_tracking_service.dart';
import '../services/auth_service.dart';
import '../widgets/gradient_background.dart';

class WaterTrackingScreen extends StatefulWidget {
  const WaterTrackingScreen({super.key});

  @override
  State<WaterTrackingScreen> createState() => _WaterTrackingScreenState();
}

class _WaterTrackingScreenState extends State<WaterTrackingScreen> with SingleTickerProviderStateMixin {
  final WaterTrackingService _waterService = WaterTrackingService();
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  DailyWaterSummary? _todaySummary;
  Map<DateTime, DailyWaterSummary>? _weeklySummary;
  int _streak = 0;
  List<String> _hydrationTips = [];
  bool _isLoading = true;
  
  // Predefined amounts for quick add buttons (in ml)
  final List<double> _quickAddAmounts = [100, 250, 500, 750];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
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
    
    final userId = Provider.of<AuthService>(context, listen: false).currentUser!.uid;
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    
    try {
      final todaySummary = await _waterService.getDailyWaterSummary(userId, today);
      final weeklySummary = await _waterService.getWeeklyWaterSummary(userId, weekStart);
      final streak = await _waterService.getWaterStreak(userId);
      final hydrationTips = _waterService.getHydrationTips(await _waterService.calculateHydrationLevel(userId));
      
      setState(() {
        _todaySummary = todaySummary;
        _weeklySummary = weeklySummary;
        _streak = streak;
        _hydrationTips = hydrationTips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading water data: $e')),
        );
      }
    }
  }
  
  Future<void> _addWaterIntake(double amount) async {
    final userId = Provider.of<AuthService>(context, listen: false).currentUser!.uid;
    
    try {
      await _waterService.addWaterIntake(
        userId: userId,
        amount: amount,
      );
      
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added ${amount.toInt()} ml of water')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding water intake: $e')),
        );
      }
    }
  }
  
  Future<void> _updateWaterTarget() async {
    final userId = Provider.of<AuthService>(context, listen: false).currentUser!.uid;
    
    // Show dialog to get new target
    final result = await showDialog<double>(
      context: context,
      builder: (context) => _UpdateWaterTargetDialog(
        currentTarget: _todaySummary?.targetAmount ?? WaterTrackingService.defaultDailyTarget,
      ),
    );
    
    if (result != null) {
      try {
        await _waterService.updateWaterTarget(userId, result);
        await _loadData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Updated daily water target to ${result.toInt()} ml')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating water target: $e')),
          );
        }
      }
    }
  }
  
  Future<void> _showCustomAmountDialog() async {
    final result = await showDialog<double>(
      context: context,
      builder: (context) => const _CustomWaterAmountDialog(),
    );
    
    if (result != null) {
      await _addWaterIntake(result);
    }
  }
  
  Future<void> _deleteWaterIntake(WaterIntake intake) async {
    try {
      await _waterService.deleteWaterIntake(intake.id);
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Water intake record deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting water intake: $e')),
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
          title: const Text('Water Tracking'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
              tooltip: 'Refresh',
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _updateWaterTarget,
              tooltip: 'Update Target',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(theme),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showCustomAmountDialog,
          icon: const Icon(Icons.add),
          label: const Text('Custom Amount'),
        ),
      ),
    );
  }
  
  Widget _buildContent(ThemeData theme) {
    if (_todaySummary == null) {
      return const Center(
        child: Text('No water data available'),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Water progress card
          _buildWaterProgressCard(theme),
          
          const SizedBox(height: 24),
          
          // Quick add buttons
          _buildQuickAddSection(theme),
          
          const SizedBox(height: 24),
          
          // Weekly chart
          if (_weeklySummary != null) _buildWeeklyChart(theme),
          
          const SizedBox(height: 24),
          
          // Hydration tips
          _buildHydrationTips(theme),
          
          const SizedBox(height: 24),
          
          // Today's intake list
          _buildTodayIntakeList(theme),
        ],
      ),
    );
  }
  
  Widget _buildWaterProgressCard(ThemeData theme) {
    final percentage = _todaySummary!.percentageReached;
    final totalIntake = _todaySummary!.totalIntake;
    final targetAmount = _todaySummary!.targetAmount;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Hydration',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${totalIntake.toInt()} / ${targetAmount.toInt()} ml',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(percentage * 100).toInt()}% of daily goal',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    children: [
                      // Progress indicator
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return CircularProgressIndicator(
                            value: percentage * _animation.value,
                            strokeWidth: 10,
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getHydrationColor(percentage),
                            ),
                          );
                        },
                      ),
                      // Water drop icon
                      Center(
                        child: Icon(
                          Icons.water_drop,
                          size: 40,
                          color: _getHydrationColor(percentage),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Streak info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    '$_streak day${_streak == 1 ? '' : 's'} streak',
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickAddSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Add Water',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _quickAddAmounts.map((amount) {
            return _buildQuickAddButton(amount, theme);
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildQuickAddButton(double amount, ThemeData theme) {
    return InkWell(
      onTap: () => _addWaterIntake(amount),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 70,
        height: 90,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.water_drop,
              color: Colors.lightBlueAccent,
            ),
            const SizedBox(height: 8),
            Text(
              '${amount.toInt()}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              'ml',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeeklyChart(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Progress',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildBarChart(theme),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBarChart(ThemeData theme) {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: theme.colorScheme.surface.withOpacity(0.8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final day = weekStart.add(Duration(days: groupIndex));
              final summary = _weeklySummary![day];
              return BarTooltipItem(
                '${summary?.totalIntake.toInt() ?? 0} ml\n${summary?.percentageReached != null ? (summary!.percentageReached * 100).toInt() : 0}%',
                TextStyle(color: theme.colorScheme.onSurface),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    weekDays[value.toInt()],
                    style: theme.textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value % 25 == 0) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '${value.toInt()}%',
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.dividerColor.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(7, (index) {
          final day = weekStart.add(Duration(days: index));
          final summary = _weeklySummary![day];
          final percentage = summary?.percentageReached ?? 0;
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: percentage * 100,
                color: _getHydrationColor(percentage),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
      swapAnimationDuration: const Duration(milliseconds: 500),
    );
  }
  
  Widget _buildHydrationTips(ThemeData theme) {
    return Card(
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
                  Icons.lightbulb,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Hydration Tips',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._hydrationTips.map((tip) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(tip, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTodayIntakeList(ThemeData theme) {
    final intakes = _todaySummary!.intakes;
    
    if (intakes.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Sort by most recent first
    final sortedIntakes = List<WaterIntake>.from(intakes)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Intake',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: sortedIntakes.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final intake = sortedIntakes[index];
              return ListTile(
                leading: const Icon(Icons.water_drop, color: Colors.lightBlueAccent),
                title: Text('${intake.amount.toInt()} ml'),
                subtitle: Text(DateFormat('h:mm a').format(intake.timestamp)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteWaterIntake(intake),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Color _getHydrationColor(double percentage) {
    if (percentage < 0.3) {
      return Colors.redAccent;
    } else if (percentage < 0.6) {
      return Colors.orangeAccent;
    } else if (percentage < 0.9) {
      return Colors.lightBlueAccent;
    } else {
      return Colors.greenAccent;
    }
  }
}

class _UpdateWaterTargetDialog extends StatefulWidget {
  final double currentTarget;
  
  const _UpdateWaterTargetDialog({required this.currentTarget});
  
  @override
  _UpdateWaterTargetDialogState createState() => _UpdateWaterTargetDialogState();
}

class _UpdateWaterTargetDialogState extends State<_UpdateWaterTargetDialog> {
  late double _targetAmount;
  
  @override
  void initState() {
    super.initState();
    _targetAmount = widget.currentTarget;
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: const Text('Update Water Target'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_targetAmount.toInt()} ml',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: _targetAmount,
            min: 1000,
            max: 5000,
            divisions: 40,
            label: '${_targetAmount.toInt()} ml',
            onChanged: (value) {
              setState(() {
                _targetAmount = value;
              });
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('1000 ml'),
              const Text('5000 ml'),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Recommended daily water intake is about 2500-3000 ml for adults.',
            style: TextStyle(fontSize: 12, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _targetAmount),
          child: const Text('Update'),
        ),
      ],
    );
  }
}

class _CustomWaterAmountDialog extends StatefulWidget {
  const _CustomWaterAmountDialog();
  
  @override
  _CustomWaterAmountDialogState createState() => _CustomWaterAmountDialogState();
}

class _CustomWaterAmountDialogState extends State<_CustomWaterAmountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  
  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Custom Amount'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (ml)',
            hintText: 'Enter water amount',
            suffixText: 'ml',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
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
              final amount = double.parse(_amountController.text);
              Navigator.pop(context, amount);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
