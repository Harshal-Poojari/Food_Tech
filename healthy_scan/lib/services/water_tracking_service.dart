import 'package:uuid/uuid.dart';
import '../models/water_intake.dart';
import 'database_service.dart';

class WaterTrackingService {
  static final WaterTrackingService _instance =
      WaterTrackingService._internal();
  factory WaterTrackingService() => _instance;
  WaterTrackingService._internal();

  final DatabaseService _dbService = DatabaseService();
  final _uuid = const Uuid();

  // Default daily water target (in milliliters)
  static const double defaultDailyTarget = 2500.0;

  // Add water intake
  Future<WaterIntake> addWaterIntake({
    required String userId,
    required double amount,
    String? notes,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Amount must be greater than zero.');
    }

    final intake = WaterIntake(
      id: _uuid.v4(),
      userId: userId,
      amount: amount,
      timestamp: DateTime.now(),
      notes: notes,
    );

    await _dbService.setDocument(
      'waterIntakes/${intake.id}',
      intake.toJson(),
    );

    return intake;
  }

  // Get water intakes for a specific day
  Future<List<WaterIntake>> getWaterIntakesForDay(
    String userId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final snapshot = await _dbService.getCollection(
      'waterIntakes',
      whereField: 'userId',
      whereValue: userId,
    );

    return snapshot
        .map((doc) => WaterIntake.fromJson(doc))
        .where((intake) =>
            intake.timestamp.isAfter(startOfDay) &&
            intake.timestamp.isBefore(endOfDay))
        .toList();
  }

  // Get daily water summary
  Future<DailyWaterSummary> getDailyWaterSummary(
    String userId,
    DateTime date, {
    double? targetAmount,
  }) async {
    final intakes = await getWaterIntakesForDay(userId, date);

    double waterTarget = targetAmount ?? defaultDailyTarget;

    try {
      final userProfileDoc =
          await _dbService.getDocument('userProfiles/$userId');
      if (userProfileDoc != null && userProfileDoc.containsKey('waterTarget')) {
        waterTarget =
            userProfileDoc['waterTarget']?.toDouble() ?? defaultDailyTarget;
      }
    } catch (e) {
      // If profile doesn't exist or has no water target, use default
    }

    return DailyWaterSummary(
      userId: userId,
      date: date,
      intakes: intakes,
      targetAmount: waterTarget,
    );
  }

  // Update user's daily water target
  Future<void> updateWaterTarget(String userId, double targetAmount) async {
    if (targetAmount <= 0) {
      throw ArgumentError('Target amount must be greater than zero.');
    }

    final conn = await _dbService.connection;
    await conn.query(
      'UPDATE user_profiles SET water_target = ? WHERE user_id = ?',
      [targetAmount, userId]
    );
  }

  // Delete a water intake record
  Future<void> deleteWaterIntake(String intakeId) async {
    final conn = await _dbService.connection;
    await conn.query(
      'DELETE FROM water_intakes WHERE id = ?',
      [intakeId]
    );
  }

  // Get weekly water summary
  Future<Map<DateTime, DailyWaterSummary>> getWeeklyWaterSummary(
    String userId,
    DateTime weekStart,
  ) async {
    final result = <DateTime, DailyWaterSummary>{};

    for (var i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final summary = await getDailyWaterSummary(userId, day);
      result[day] = summary;
    }

    return result;
  }

  // Get water streak (consecutive days meeting target)
  Future<int> getWaterStreak(String userId) async {
    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (var i = 0; i < 30; i++) {
      final summary = await getDailyWaterSummary(userId, currentDate);

      if (summary.intakes.fold(0.0, (sum, intake) => sum + intake.amount) >=
          summary.targetAmount) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break; // Stop checking if the streak is broken
      }
    }

    return streak;
  }

  // Calculate hydration level based on recent intake
  Future<double> calculateHydrationLevel(String userId) async {
    final today = DateTime.now();

    final todaySummary = await getDailyWaterSummary(userId, today);

    double hydrationScore =
        todaySummary.intakes.fold(0.0, (sum, intake) => sum + intake.amount) /
            todaySummary.targetAmount;

    return hydrationScore.clamp(0.0, 1.0);
  }

  // Get hydration tips based on current level
  List<String> getHydrationTips(double hydrationLevel) {
    if (hydrationLevel < 0.3) {
      return [
        'You\'re severely dehydrated! Drink water immediately.',
        'Try to drink at least 500ml of water in the next hour.',
        'Set reminders to drink water throughout the day.',
      ];
    } else if (hydrationLevel < 0.6) {
      return [
        'You\'re mildly dehydrated. Increase your water intake.',
        'Try carrying a water bottle with you throughout the day.',
        'Drink a glass of water before each meal.',
      ];
    } else if (hydrationLevel < 0.9) {
      return [
        'You\'re doing well but could drink a bit more water.',
        'Try drinking herbal teas or infused water for variety.',
        'Remember to hydrate after exercise.',
      ];
    } else {
      return [
        'Excellent hydration! Keep it up!',
        'You\'re meeting your water goals consistently.',
        'Well-hydrated bodies function better and have more energy.',
      ];
    }
  }
}
