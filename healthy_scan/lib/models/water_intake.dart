class WaterIntake {
  final String id;
  final String userId;
  final double amount; 
  final DateTime timestamp;
  final String? notes;

  WaterIntake({
    required this.id,
    required this.userId,
    required this.amount,
    required this.timestamp,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  factory WaterIntake.fromJson(Map<String, dynamic> json) {
    return WaterIntake(
      id: json['id'],
      userId: json['userId'],
      amount: json['amount'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      notes: json['notes'],
    );
  }
}

class DailyWaterSummary {
  final String userId;
  final DateTime date;
  final List<WaterIntake> intakes;
  final double targetAmount; 

  const DailyWaterSummary({
    required this.userId,
    required this.date,
    required this.intakes,
    required this.targetAmount,
  });

  // Calculate total water intake for the day
  double get totalIntake {
    return intakes.fold(0, (total, intake) => total + intake.amount);
  }

  // Calculate percentage of target reached
  double get percentageReached {
    return (totalIntake / targetAmount).clamp(0.0, 1.0);
  }

  // Check if target is reached
  bool get isTargetReached {
    return totalIntake >= targetAmount;
  }

  // Get intake by hour for chart display
  Map<int, double> get intakeByHour {
    final result = <int, double>{};
    
    for (var i = 0; i < 24; i++) {
      result[i] = 0;
    }
    
    for (final intake in intakes) {
      final hour = intake.timestamp.hour;
      result[hour] = (result[hour] ?? 0) + intake.amount;
    }
    
    return result;
  }
}
