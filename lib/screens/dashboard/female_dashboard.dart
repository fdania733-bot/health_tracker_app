import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../providers/health_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/gemini_service.dart';
import '../../widgets/triple_ring_chart.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/ai_analysis_card.dart';
import '../../widgets/statistics_card.dart';
import '../chat/ai_chat_screen.dart';
import '../metric_detail/metric_detail_screen.dart';
import '../devices/device_connectivity_screen.dart';
import '../tracking/cycle_tracking_screen.dart';
import '../tracking/mood_tracker_screen.dart';

class FemaleDashboard extends StatefulWidget {
  const FemaleDashboard({super.key});
  @override
  State<FemaleDashboard> createState() => _FemaleDashboardState();
}

class _FemaleDashboardState extends State<FemaleDashboard> {
  final GeminiService _geminiService = GeminiService();
  String _phase = 'Not tracked';
  int _cycleDay = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().initialize();
      _fetchCycleData();
    });
  }

  Future<void> _fetchCycleData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('cycles')
          .orderBy('startDate', descending: true)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty && mounted) {
        final data = snap.docs.first.data();
        setState(() {
          _phase = data['phase'] ?? 'Unknown';
          _cycleDay = data['cycleDay'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error fetching cycle: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final health = context.watch<HealthProvider>();
    final user = context.watch<AuthProvider>().appUser;

    final healthScore = _calculateHealthScore(health, user);
    final insights = _generateInsights(health, user);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: const Text("Women's Health"),
        actions: [
          IconButton(
            icon: const Icon(Icons.watch, color: Color(0xFFF97316)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DeviceConnectivityScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: health.loading && health.data.steps == 0
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF97316)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(
              'Hello, ${user?.name ?? 'User'} 👋',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Let\'s track your health today',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Activity Rings Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  TripleRingChart(
                    steps: health.data.steps,
                    stepGoal: 10000,
                    calories: health.data.calories,
                    calorieGoal: 500,
                    activeMinutes: (health.data.sleepHours * 60).toInt(),
                    activeMinutesGoal: 30,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRingStat('Steps', '${health.data.steps}', '10,000', const Color(0xFFF97316)),
                        const SizedBox(height: 12),
                        _buildRingStat('Calories', '${health.data.calories.toStringAsFixed(0)}', '500 kcal', const Color(0xFF22C55E)),
                        const SizedBox(height: 12),
                        _buildRingStat('Active', '${(health.data.sleepHours * 60).toInt()}', '30 min', const Color(0xFF3B82F6)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // AI Analysis Card
            AiAnalysisCard(
              healthScore: healthScore,
              insights: insights,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AiChatScreen()),
                );
              },
            ),
            const SizedBox(height: 20),

            // Statistics Card
            StatisticsCard(
              title: 'Weekly Statistics',
              stats: [
                {
                  'value': '${health.data.steps}',
                  'label': 'Steps',
                  'unit': 'today',
                  'color': const Color(0xFFF97316),
                },
                {
                  'value': '${health.data.calories.toStringAsFixed(0)}',
                  'label': 'Calories',
                  'unit': 'kcal',
                  'color': const Color(0xFF22C55E),
                },
                {
                  'value': '${health.data.sleepHours.toStringAsFixed(1)}',
                  'label': 'Sleep',
                  'unit': 'hours',
                  'color': const Color(0xFF3B82F6),
                },
              ],
            ),
            const SizedBox(height: 20),

            // Health Features Grid - WITH CYCLE TRACKING
            const Text(
              'Health Metrics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.95,
              children: [
                // CYCLE TRACKING CARD - PRESERVED
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CycleTrackingScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFEC4899), Color(0xFF9333EA)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.calendar_month, color: Colors.white, size: 24),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cycle',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _cycleDay > 0 ? 'Day $_cycleDay • $_phase' : 'Track & analyze',
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                MetricCard(
                  title: 'Weight',
                  subtitle: 'Goal management',
                  icon: Icons.monitor_weight,
                  color: const Color(0xFFF97316),
                  value: '${user?.weightKg ?? 0}',
                  unit: 'kg',
                  onTap: () => _openMetricDetail(
                    context,
                    title: 'Weight',
                    about: 'Weight is a key indicator of overall health. Combined with height, it helps calculate BMI.',
                    icon: Icons.monitor_weight,
                    color: const Color(0xFFF97316),
                    unit: 'kg',
                    minValue: 30,
                    maxValue: 200,
                    initialValue: user?.weightKg ?? 60,
                    divisions: 170,
                    healthyRange: 'BMI 18.5 - 24.9',
                  ),
                ),
                MetricCard(
                  title: 'Mood',
                  subtitle: 'Emotional wellness',
                  icon: Icons.mood,
                  color: Colors.pink,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MoodTrackerScreen()),
                    );
                  },
                ),
                MetricCard(
                  title: 'Heart Rate',
                  subtitle: 'Heart health',
                  icon: Icons.favorite,
                  color: Colors.red,
                  value: '${health.data.heartRate.toStringAsFixed(0)}',
                  unit: 'BPM',
                  onTap: () => _openMetricDetail(
                    context,
                    title: 'Heart Rate',
                    about: 'Heart rate measures how many times your heart beats per minute.',
                    icon: Icons.favorite,
                    color: Colors.red,
                    unit: 'BPM',
                    minValue: 40,
                    maxValue: 200,
                    initialValue: health.data.heartRate > 0 ? health.data.heartRate : 72,
                    divisions: 160,
                    healthyRange: '60 - 100 BPM',
                  ),
                ),
                MetricCard(
                  title: 'Sleep',
                  subtitle: 'Sleep analysis',
                  icon: Icons.bedtime,
                  color: Colors.indigo,
                  value: '${health.data.sleepHours.toStringAsFixed(1)}',
                  unit: 'hrs',
                  onTap: () => _openMetricDetail(
                    context,
                    title: 'Sleep',
                    about: 'Quality sleep is essential for physical recovery and well-being.',
                    icon: Icons.bedtime,
                    color: Colors.indigo,
                    unit: 'hrs',
                    minValue: 0,
                    maxValue: 14,
                    initialValue: health.data.sleepHours > 0 ? health.data.sleepHours : 7.5,
                    divisions: 140,
                    healthyRange: '7 - 9 hours',
                  ),
                ),
                MetricCard(
                  title: 'BMI',
                  subtitle: 'Body mass index',
                  icon: Icons.analytics,
                  color: Colors.blue,
                  value: '${user?.bmi ?? 0}',
                  onTap: () => _openMetricDetail(
                    context,
                    title: 'BMI',
                    about: 'Body Mass Index (BMI) is calculated from weight and height.',
                    icon: Icons.analytics,
                    color: Colors.blue,
                    unit: '',
                    minValue: 15,
                    maxValue: 40,
                    initialValue: user?.bmi ?? 22,
                    divisions: 250,
                    healthyRange: '18.5 - 24.9',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Devices Card
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DeviceConnectivityScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.watch, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connect Wearable',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Sync data from your smartwatch',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  int _calculateHealthScore(health, user) {
    return _geminiService.calculateHealthScore(
      steps: health.data.steps,
      heartRate: health.data.heartRate,
      sleepHours: health.data.sleepHours,
      bmi: user?.bmi ?? 0,
      moodScore: 3,
    );
  }

  List<String> _generateInsights(health, user) {
    final insights = _geminiService.generateInsights(
      steps: health.data.steps,
      heartRate: health.data.heartRate,
      sleepHours: health.data.sleepHours,
      bmi: user?.bmi ?? 0,
      moodScore: 3,
    );

    // Add cycle-specific insight for female users
    if (_cycleDay > 0) {
      if (_phase == 'Menstrual') {
        insights.insert(0, 'You\'re in your menstrual phase. Rest and hydrate well.');
      } else if (_phase == 'Ovulation') {
        insights.insert(0, 'Peak fertility window - track carefully if planning.');
      }
    }

    return insights;
  }

  Widget _buildRingStat(String label, String value, String goal, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text('/ $goal', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
            ),
          ],
        ),
      ],
    );
  }

  void _openMetricDetail(
      BuildContext context, {
        required String title,
        required String about,
        required IconData icon,
        required Color color,
        required String unit,
        required double minValue,
        required double maxValue,
        required double initialValue,
        required int divisions,
        String? healthyRange,
      }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MetricDetailScreen(
          title: title,
          about: about,
          icon: icon,
          color: color,
          unit: unit,
          minValue: minValue,
          maxValue: maxValue,
          initialValue: initialValue,
          divisions: divisions,
          healthyRange: healthyRange,
        ),
      ),
    );
  }
}