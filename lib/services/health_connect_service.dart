import 'package:health/health.dart';
import '../models/health_data_model.dart';

class HealthConnectService {
  final Health _health = Health();  final List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WEIGHT,
  ];

  Future<bool> requestPermissions() async {
    return await _health.requestAuthorization(_types);
  }

  Future<HealthDataModel> fetchTodayData() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      int steps = (await _health.getTotalStepsInInterval(midnight, now)) ?? 0;
      double heartRate = await _getAverage(HealthDataType.HEART_RATE, midnight, now);
      double sleep = await _getAverage(HealthDataType.SLEEP_ASLEEP, midnight, now) / 60;
      double calories = await _getAverage(HealthDataType.ACTIVE_ENERGY_BURNED, midnight, now);
      double weight = await _getAverage(HealthDataType.WEIGHT, midnight, now);

      return HealthDataModel(
        steps: steps,
        heartRate: heartRate,
        sleepHours: sleep,
        calories: calories,
        weight: weight,
      );
    } catch (e) {
      print("Health Connect Error: $e");
      return HealthDataModel();
    }
  }

  Future<double> _getAverage(HealthDataType type, DateTime start, DateTime end) async {
    final data = await _health.getHealthDataFromTypes(
      types: [type],
      startTime: start,
      endTime: end,
    );
    if (data.isEmpty) return 0;

    double sum = 0;
    int count = 0;

    for (var e in data) {
      if (e.value is NumericHealthValue) {
        // Fix: Use .numericValue (correct property for health v10+)
        sum += (e.value as NumericHealthValue).numericValue;
        count++;
      }
    }

    return count == 0 ? 0 : sum / count;
  }
}