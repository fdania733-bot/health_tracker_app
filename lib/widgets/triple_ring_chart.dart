import 'package:flutter/material.dart';

class TripleRingChart extends StatelessWidget {
  final int steps;
  final int stepGoal;
  final double calories;
  final double calorieGoal;
  final int activeMinutes;
  final int activeMinutesGoal;

  const TripleRingChart({
    super.key,
    required this.steps,
    required this.stepGoal,
    required this.calories,
    required this.calorieGoal,
    required this.activeMinutes,
    required this.activeMinutesGoal,
  });

  @override
  Widget build(BuildContext context) {
    final stepsPercent = (steps / stepGoal).clamp(0.0, 1.0);
    final caloriesPercent = (calories / calorieGoal).clamp(0.0, 1.0);
    final activePercent = (activeMinutes / activeMinutesGoal).clamp(0.0, 1.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer ring (Steps - Orange)
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            value: stepsPercent,
            strokeWidth: 8,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF97316)),
            strokeCap: StrokeCap.round,
          ),
        ),
        // Middle ring (Calories - Green)
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: caloriesPercent,
            strokeWidth: 8,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
            strokeCap: StrokeCap.round,
          ),
        ),
        // Inner ring (Active - Blue)
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            value: activePercent,
            strokeWidth: 8,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            strokeCap: StrokeCap.round,
          ),
        ),
      ],
    );
  }
}