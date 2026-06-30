import 'package:cloud_firestore/cloud_firestore.dart';

class MenstrualCycleModel {
  final String id;
  final DateTime startDate;
  final int cycleLength;
  final DateTime? nextPeriodDate;
  final String phase;
  final int cycleDay;
  final DateTime createdAt;

  MenstrualCycleModel({
    this.id = '',
    required this.startDate,
    this.cycleLength = 28,
    this.nextPeriodDate,
    required this.phase,
    required this.cycleDay,
    required this.createdAt,
  });

  factory MenstrualCycleModel.fromMap(Map<String, dynamic> map, String id) {
    return MenstrualCycleModel(
      id: id,
      startDate: (map['startDate'] as Timestamp).toDate(),
      cycleLength: map['cycleLength'] ?? 28,
      nextPeriodDate: map['nextPeriodDate'] != null
          ? (map['nextPeriodDate'] as Timestamp).toDate()
          : null,
      phase: map['phase'] ?? 'Unknown',
      cycleDay: map['cycleDay'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startDate': Timestamp.fromDate(startDate),
      'cycleLength': cycleLength,
      'nextPeriodDate': nextPeriodDate != null
          ? Timestamp.fromDate(nextPeriodDate!)
          : null,
      'phase': phase,
      'cycleDay': cycleDay,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static String calculatePhase(DateTime startDate) {
    final cycleDay = DateTime.now().difference(startDate).inDays + 1;
    if (cycleDay <= 5) return 'Menstrual';
    if (cycleDay <= 13) return 'Follicular';
    if (cycleDay == 14) return 'Ovulation';
    return 'Luteal';
  }

  static int calculateCycleDay(DateTime startDate) {
    return DateTime.now().difference(startDate).inDays + 1;
  }
}