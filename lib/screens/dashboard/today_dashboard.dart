import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:async';
import 'dart:math';
import '../../providers/auth_provider.dart';
import '../../providers/health_provider.dart';
import '../../providers/device_provider.dart';
import '../chat/ai_chat_screen.dart';
import '../profile/profile_screen.dart';
import '../tracking/cycle_tracking_screen.dart';

class TodayDashboard extends StatefulWidget {
  const TodayDashboard({super.key});

  @override
  State<TodayDashboard> createState() => _TodayDashboardState();
}

class _TodayDashboardState extends State<TodayDashboard> {
  int _steps = 0;
  int _stepGoal = 8000;
  double _calorieGoal = 350;
  double _workoutGoal = 30;
  double _calories = 0;
  double _workoutDuration = 0;
  int _heartRate = 72;
  int _sleepHours = 7;
  int _sleepMinutes = 30;
  int _bloodOxygen = 98;
  Timer? _heartRateTimer;
  Timer? _workoutTimer;
  StreamSubscription<StepCount>? _stepSubscription;

  @override
  void initState() {
    super.initState();
    _initPedometer();
    _startSimulations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.appUser != null) {
        context.read<HealthProvider>().setUserId(auth.appUser!.uid);
        context.read<HealthProvider>().fetchTodayData();
      }
    });
  }

  void _initPedometer() {
    try {
      final stepCountStream = Pedometer.stepCountStream;
      _stepSubscription = stepCountStream.listen(
            (StepCount event) {
          if (mounted) {
            setState(() {
              _steps = event.steps;
              _calories = (_steps * 0.04).roundToDouble();
            });
          }
        },
        onError: (error) {
          print('Pedometer error: $error');
        },
      );
    } catch (e) {
      print('Pedometer not available: $e');
    }
  }

  void _startSimulations() {
    // Heart rate updates every 3 seconds
    _heartRateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _heartRate = 65 + Random().nextInt(20);
        });
      }
    });

    // Workout duration timer
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _workoutDuration += 1;
        });
      }
    });
  }
  void _editGoal(String title, dynamic currentGoal, Function(dynamic) onSave) {
    TextEditingController controller = TextEditingController(text: currentGoal.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit $title Goal', style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'New Goal',
              labelStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF2A2A2A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () {
                final val = double.tryParse(controller.text) ?? currentGoal;
                onSave(title == 'Steps' ? val.toInt() : val);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316)),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  void _showStepsDetails() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Steps', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$_steps', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
              const Text('steps', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              Text('Goal: $_stepGoal steps', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_steps / _stepGoal).clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade800,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF97316)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => _editGoal('Steps', _stepGoal, (val) => setState(() => _stepGoal = val)),
              child: const Text('Edit Goal', style: TextStyle(color: Color(0xFFF97316))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showCaloriesDetails() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Calories', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${_calories.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
              const Text('kcal burned', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              Text('Goal: ${_calorieGoal.toStringAsFixed(0)} kcal', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_calories / _calorieGoal).clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade800,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF84CC16)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => _editGoal('Calories', _calorieGoal, (val) => setState(() => _calorieGoal = val)),
              child: const Text('Edit Goal', style: TextStyle(color: Color(0xFFF97316))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showWorkoutDetails() {
    final minutes = (_workoutDuration / 60).floor();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Workout Duration', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$minutes', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
              const Text('minutes', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              Text('Goal: ${_workoutGoal.toStringAsFixed(0)} min', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (minutes / _workoutGoal).clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade800,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF06B6D4)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => _editGoal('Workout', _workoutGoal, (val) => setState(() => _workoutGoal = val)),
              child: const Text('Edit Goal', style: TextStyle(color: Color(0xFFF97316))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
  @override
  void dispose() {
    _stepSubscription?.cancel();
    _heartRateTimer?.cancel();
    _workoutTimer?.cancel();
    super.dispose();
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Add Health Data',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildAddOption(Icons.water_drop, 'Log Water Intake', Colors.blue, () {
                  Navigator.pop(context);
                  _showWaterLogDialog();
                }),
                _buildAddOption(Icons.fitness_center, 'Log Workout', Colors.orange, () {
                  Navigator.pop(context);
                  _showWorkoutLogDialog();
                }),
                _buildAddOption(Icons.restaurant, 'Log Meal', Colors.green, () {
                  Navigator.pop(context);
                  _showMealLogDialog();
                }),
                _buildAddOption(Icons.bedtime, 'Log Sleep', Colors.purple, () {
                  Navigator.pop(context);
                  _showSleepLogDialog();
                }),
                _buildAddOption(Icons.monitor_weight, 'Log Weight', Colors.pink, () {
                  Navigator.pop(context);
                  _showWeightLogDialog();
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddOption(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      onTap: onTap,
    );
  }

  void _showWaterLogDialog() {
    int glasses = 0;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Log Water Intake', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.water_drop, color: Colors.blue, size: 64),
                  const SizedBox(height: 16),
                  Text('$glasses glasses', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.blue, size: 32),
                        onPressed: () => setState(() => glasses = glasses > 0 ? glasses - 1 : 0),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.blue, size: 32),
                        onPressed: () => setState(() => glasses++),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logged $glasses glasses of water!'), backgroundColor: Colors.blue),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showWorkoutLogDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Log Workout', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.fitness_center, color: Colors.orange, size: 64),
              const SizedBox(height: 16),
              const Text('Workout tracking coming soon!', style: TextStyle(color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showMealLogDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Log Meal', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.restaurant, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text('Meal tracking coming soon!', style: TextStyle(color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showSleepLogDialog() {
    int hours = _sleepHours;
    int minutes = _sleepMinutes;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Log Sleep', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bedtime, color: Colors.purple, size: 64),
                  const SizedBox(height: 16),
                  Text('$hours h $minutes m', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.purple, size: 32),
                        onPressed: () => setState(() {
                          if (minutes > 0) {
                            minutes--;
                          } else if (hours > 0) {
                            hours--;
                            minutes = 59;
                          }
                        }),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.purple, size: 32),
                        onPressed: () => setState(() {
                          if (minutes < 59) {
                            minutes++;
                          } else {
                            minutes = 0;
                            hours++;
                          }
                        }),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _sleepHours = hours;
                      _sleepMinutes = minutes;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sleep logged: $hours h $minutes m'), backgroundColor: Colors.purple),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showWeightLogDialog() {
    TextEditingController weightController = TextEditingController(text: '56');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Log Weight', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monitor_weight, color: Colors.pink, size: 64),
              const SizedBox(height: 16),
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Weight logged: ${weightController.text} kg'), backgroundColor: Colors.pink),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showWeightDetails() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  void _showHeartRateDetails() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Heart Rate', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$_heartRate bpm', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Resting: 65 bpm', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              const Text('Max: 180 bpm', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              const Icon(Icons.favorite, color: Color(0xFFEF4444), size: 64),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showSleepDetails() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Sleep Analysis', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$_sleepHours h $_sleepMinutes m', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Deep Sleep: 2h 15m', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              const Text('Light Sleep: 4h 15m', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              const Text('REM: 1h', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              const Icon(Icons.bedtime, color: Color(0xFF3B82F6), size: 64),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showBloodOxygenDetails() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Blood Oxygen', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$_bloodOxygen%', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Normal Range: 95-100%', style: TextStyle(color: Colors.green)),
              const SizedBox(height: 16),
              const Icon(Icons.water_drop, color: Color(0xFFF59E0B), size: 64),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final device = context.watch<DeviceProvider>();
    final user = auth.appUser;
    final isFemale = user?.gender == 'female';

    final steps = device.isConnected ? device.steps : _steps;
    final calories = device.isConnected ? device.calories : _calories;
    final workoutMinutes = device.isConnected ? device.sleepHours.toDouble() : (_workoutDuration / 60);
    final heartRate = device.isConnected ? device.heartRate : _heartRate;
    final sleepH = device.isConnected ? device.sleepHours : _sleepHours;
    final bloodOxygen = _bloodOxygen;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        title: const Text(
          'Health',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 32),
            onPressed: _showAddOptions,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular Progress Rings Section
            Row(
              children: [
                Expanded(
                  child: _buildCircularRings(steps, calories, workoutMinutes),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatButton('Steps', '$steps', '/$_stepGoal', const Color(0xFFF97316), _showStepsDetails),
                      const SizedBox(height: 8),
                      _buildStatButton('Calories', '${calories.toStringAsFixed(0)}', '/${_calorieGoal.toStringAsFixed(0)}', const Color(0xFF84CC16), _showCaloriesDetails),
                      const SizedBox(height: 8),
                      _buildStatButton('Workout', '${workoutMinutes.toStringAsFixed(0)}', '/${_workoutGoal.toStringAsFixed(0)}', const Color(0xFF06B6D4), _showWorkoutDetails),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // AI Health Card
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AiChatScreen()));
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Health',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'AI health analysis combines measured data and physical information.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF97316).withOpacity(0.3),
                            const Color(0xFFEA580C).withOpacity(0.3),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.analytics, color: Color(0xFFF97316), size: 50),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Grid Cards - Row 1
            Row(
              children: [
                Expanded(child: _buildMetricCard('Weight', '06-26 02:26 PM', '56 kg', _buildWeightGraph(), _showWeightDetails)),
                const SizedBox(width: 12),
                Expanded(
                  child: isFemale
                      ? _buildMetricCard('Cycle', 'Period tracker', '', const Icon(Icons.calendar_month, color: Color(0xFFEC4899), size: 48), () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CycleTrackingScreen()));
                  })
                      : _buildMetricCard('Heart Rate', 'Heart health', '$heartRate bpm', _buildHeartRateGraph(), _showHeartRateDetails),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Grid Cards - Row 2
            Row(
              children: [
                Expanded(child: _buildMetricCard('Sleep', 'Sleep analysis', '$sleepH h', const Icon(Icons.bedtime, color: Color(0xFF3B82F6), size: 48), _showSleepDetails)),
                const SizedBox(width: 12),
                Expanded(
                  child: isFemale
                      ? _buildMetricCard('Heart Rate', 'Heart health', '$heartRate bpm', _buildHeartRateGraph(), _showHeartRateDetails)
                      : _buildMetricCard('Blood Oxygen', 'Respiratory cycle', '$bloodOxygen%', const Icon(Icons.water_drop, color: Color(0xFFF59E0B), size: 48), _showBloodOxygenDetails),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Blood Oxygen for females (third row)
            if (isFemale)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard('Blood Oxygen', 'Respiratory cycle', '$bloodOxygen%', const Icon(Icons.water_drop, color: Color(0xFFF59E0B), size: 48), _showBloodOxygenDetails),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: SizedBox()),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularRings(int steps, double calories, double workoutMinutes) {
    return SizedBox(
      height: 180,
      width: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildCircularRing(8000, steps.toDouble(), const Color(0xFFF97316), 90),
          _buildCircularRing(350, calories, const Color(0xFF84CC16), 70),
          _buildCircularRing(30, workoutMinutes, const Color(0xFF06B6D4), 50),
        ],
      ),
    );
  }

  Widget _buildCircularRing(double max, double value, Color color, double radius) {
    final percentage = (value / max).clamp(0.0, 1.0);
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: radius * 2,
            height: radius * 2,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 8,
              backgroundColor: Colors.grey.shade800,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade700),
            ),
          ),
          SizedBox(
            width: radius * 2,
            height: radius * 2,
            child: CircularProgressIndicator(
              value: percentage,
              strokeWidth: 8,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeCap: StrokeCap.round,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStatButton(String label, String value, String suffix, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14), overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(suffix, style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: Colors.grey.shade500, size: 18),
          ],
        ),
      ),
    );
  }
  Widget _buildStatRow(String label, String value, String suffix, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(suffix, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
      ],
    );
  }

  Widget _buildMetricCard(String title, String subtitle, String value, Widget content, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            if (value.isNotEmpty)
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: content,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightGraph() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.only(right: 8),
          child: Icon(Icons.circle, color: Colors.white, size: 8),
        ),
      ),
    );
  }

  Widget _buildHeartRateGraph() {
    return CustomPaint(
      size: const Size(double.infinity, 40),
      painter: HeartRateGraphPainter(),
    );
  }
}

class HeartRateGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    path.moveTo(0, size.height / 2);

    for (double i = 0; i <= size.width; i++) {
      final y = size.height / 2 +
          (i % 20 < 10 ? -10 : 10) *
              (i / size.width > 0.7 ? 0.5 : 1.0);
      path.lineTo(i, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}