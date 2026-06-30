
class HealthDataModel {
  final int steps;
  final double heartRate;
  final double sleepHours;
  final double calories;
  final double weight;

  HealthDataModel({this.steps=0, this.heartRate=0, this.sleepHours=0, this.calories=0, this.weight=0});

  Map<String, dynamic> toMap() => {
    'steps': steps,
    'heartRate': heartRate,
    'sleepHours': sleepHours,
    'calories': calories,
    'weight': weight
  };
}