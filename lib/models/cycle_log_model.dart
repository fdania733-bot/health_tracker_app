import 'package:cloud_firestore/cloud_firestore.dart';

class CycleLogModel {
  final String date;
  final bool periodStarted;
  final int? flowLevel;
  final int? crampLevel;
  final List<String> symptoms;
  final int? mood;
  final List<String> habits;
  final String? discharge;
  final double? weight;
  final double? bodyTemp;
  final String? diaryText;
  final String? diaryPhotoUrl;
  final List<String> sexActivity;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CycleLogModel({
    required this.date,
    this.periodStarted = false,
    this.flowLevel,
    this.crampLevel,
    this.symptoms = const [],
    this.mood,
    this.habits = const [],
    this.discharge,
    this.weight,
    this.bodyTemp,
    this.diaryText,
    this.diaryPhotoUrl,
    this.sexActivity = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory CycleLogModel.fromMap(Map<String, dynamic> map, String date) {
    return CycleLogModel(
      date: date,
      periodStarted: map['periodStarted'] ?? false,
      flowLevel: map['flowLevel'],
      crampLevel: map['crampLevel'],
      symptoms: map['symptoms'] != null ? List<String>.from(map['symptoms']) : [],
      mood: map['mood'],
      habits: map['habits'] != null ? List<String>.from(map['habits']) : [],
      discharge: map['discharge'],
      weight: map['weight']?.toDouble(),
      bodyTemp: map['bodyTemp']?.toDouble(),
      diaryText: map['diaryText'],
      diaryPhotoUrl: map['diaryPhotoUrl'],
      sexActivity: map['sexActivity'] != null ? List<String>.from(map['sexActivity']) : [],
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'periodStarted': periodStarted,
      'flowLevel': flowLevel,
      'crampLevel': crampLevel,
      'symptoms': symptoms,
      'mood': mood,
      'habits': habits,
      'discharge': discharge,
      'weight': weight,
      'bodyTemp': bodyTemp,
      'diaryText': diaryText,
      'diaryPhotoUrl': diaryPhotoUrl,
      'sexActivity': sexActivity,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  CycleLogModel copyWith({
    String? date,
    bool? periodStarted,
    int? flowLevel,
    int? crampLevel,
    List<String>? symptoms,
    int? mood,
    List<String>? habits,
    String? discharge,
    double? weight,
    double? bodyTemp,
    String? diaryText,
    String? diaryPhotoUrl,
    List<String>? sexActivity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CycleLogModel(
      date: date ?? this.date,
      periodStarted: periodStarted ?? this.periodStarted,
      flowLevel: flowLevel ?? this.flowLevel,
      crampLevel: crampLevel ?? this.crampLevel,
      symptoms: symptoms ?? this.symptoms,
      mood: mood ?? this.mood,
      habits: habits ?? this.habits,
      discharge: discharge ?? this.discharge,
      weight: weight ?? this.weight,
      bodyTemp: bodyTemp ?? this.bodyTemp,
      diaryText: diaryText ?? this.diaryText,
      diaryPhotoUrl: diaryPhotoUrl ?? this.diaryPhotoUrl,
      sexActivity: sexActivity ?? this.sexActivity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}