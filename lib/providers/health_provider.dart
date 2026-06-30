import 'package:flutter/material.dart';
import 'package:health/health.dart';
import '../services/firestore_service.dart';

class HealthData {
  final int steps;
  final double calories;
  final int sleepHours;
  final int waterIntake;
  final DateTime timestamp;
  final String? userId;

  HealthData({
    required this.steps,
    required this.calories,
    required this.sleepHours,
    required this.waterIntake,
    required this.timestamp,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'steps': steps,
      'calories': calories,
      'sleepHours': sleepHours,
      'waterIntake': waterIntake,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
    };
  }
}

class HealthProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  HealthData? _todayData;
  bool _isLoading = false;
  String? _userId;

  HealthData? get todayData => _todayData;
  bool get isLoading => _isLoading;

  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }

  Future<void> fetchTodayData() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('🔵 Fetching health data...');

      // Create default data for demo purposes
      _todayData = HealthData(
        steps: 8500,
        calories: 420,
        sleepHours: 7,
        waterIntake: 6,
        timestamp: DateTime.now(),
        userId: _userId,
      );

      print('✅ Health data fetched successfully');
    } catch (e) {
      print('❌ Error fetching health data: $e');
      _todayData = HealthData(
        steps: 0,
        calories: 0,
        sleepHours: 0,
        waterIntake: 0,
        timestamp: DateTime.now(),
        userId: _userId,
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveTodayData() async {
    if (_todayData == null || _userId == null) {
      print('⚠️ No data or userId to save');
      return;
    }

    try {
      print('🔵 Saving health data...');
      // FIXED: Added .toMap() to convert HealthData to Map
      await _firestoreService.saveHealthRecord(_todayData!.toMap());
      print('✅ Health data saved successfully');
    } catch (e) {
      print('❌ Error saving health data: $e');
    }
  }

  void updateSteps(int steps) {
    if (_todayData != null) {
      _todayData = HealthData(
        steps: steps,
        calories: _todayData!.calories,
        sleepHours: _todayData!.sleepHours,
        waterIntake: _todayData!.waterIntake,
        timestamp: DateTime.now(),
        userId: _userId,
      );
      notifyListeners();
    }
  }

  void updateWater(int glasses) {
    if (_todayData != null) {
      _todayData = HealthData(
        steps: _todayData!.steps,
        calories: _todayData!.calories,
        sleepHours: _todayData!.sleepHours,
        waterIntake: glasses,
        timestamp: DateTime.now(),
        userId: _userId,
      );
      notifyListeners();
      // FIXED: Added .toMap() to convert HealthData to Map
      _firestoreService.saveHealthRecord(_todayData!.toMap());
    }
  }

  void addWater() {
    updateWater((_todayData?.waterIntake ?? 0) + 1);
  }

  void removeWater() {
    if ((_todayData?.waterIntake ?? 0) > 0) {
      updateWater(_todayData!.waterIntake - 1);
    }
  }
}