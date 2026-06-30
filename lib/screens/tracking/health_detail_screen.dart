import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/health_provider.dart';

class HealthDetailScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const HealthDetailScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final health = context.watch<HealthProvider>();

    String value = '';
    String unit = '';
    String description = '';

    switch (title.toLowerCase()) {
      case 'steps':
        value = '${health.data.steps}';
        unit = 'steps';
        description = 'Daily step count tracked from your device. Goal: 10,000 steps.';
        break;
      case 'heart rate':
        value = '${health.data.heartRate.toStringAsFixed(0)}';
        unit = 'BPM';
        description = 'Average heart rate today. Normal resting: 60-100 BPM.';
        break;
      case 'calories':
        value = '${health.data.calories.toStringAsFixed(0)}';
        unit = 'kcal';
        description = 'Active calories burned today through movement and exercise.';
        break;
      case 'sleep':
        value = '${health.data.sleepHours.toStringAsFixed(1)}';
        unit = 'hours';
        description = 'Total sleep duration last night. Recommended: 7-9 hours.';
        break;
      default:
        value = 'N/A';
        description = 'No data available.';
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: color),
            const SizedBox(height: 32),
            Text(
              value,
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              unit,
              style: const TextStyle(fontSize: 24, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'About',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}