import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class MaleDashboard extends StatefulWidget {
  const MaleDashboard({super.key});
  @override
  State<MaleDashboard> createState() => _MaleDashboardState();
}

class _MaleDashboardState extends State<MaleDashboard> {
  final GeminiService _geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().initialize();
    });
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
        title: const Text("Men's Health"),
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

            // Health Features Grid
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
                    about: 'Weight is a key indicator of overall health. Combined with height, it helps calculate BMI (Body Mass Index) using the formula: BMI = weight (kg) ÷ height² (m²). A healthy BMI range is 18.5 to 24.9.',
                    icon: Icons.monitor_weight,
                    color: const Color(0xFFF97316),
                    unit: 'kg',
                    minValue: 30,
                    maxValue: 200,
                    initialValue: user?.weightKg ?? 70,
                    divisions: 170,
                    healthyRange: 'BMI 18.5 - 24.9',
                  ),
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
                    about: 'Heart rate measures how many times your heart beats per minute. A normal resting heart rate for adults is between 60-100 BPM.',
                    icon: Icons.favorite,
                    color: Colors.red,
                    unit: 'BPM',
                    minValue: 40,
                    maxValue: 200,
                    initialValue: health.data.heartRate > 0 ? health.data.heartRate : 72,
                    divisions: 160,
                    healthyRange: '60 - 100 BPM (resting)',
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
                    about: 'Quality sleep is essential for physical recovery, mental clarity, and emotional well-being. Adults need 7-9 hours of sleep per night.',
                    icon: Icons.bedtime,
                    color: Colors.indigo,
                    unit: 'hrs',
                    minValue: 0,
                    maxValue: 14,
                    initialValue: health.data.sleepHours > 0 ? health.data.sleepHours : 7.5,
                    divisions: 140,
                    healthyRange: '7 - 9 hours per night',
                  ),
                ),
                MetricCard(
                  title: 'Blood Oxygen',
                  subtitle: 'SpO₂ monitoring',
                  icon: Icons.air,
                  color: Colors.cyan,
                  value: '98',
                  unit: '%',
                  onTap: () => _openMetricDetail(
                    context,
                    title: 'Blood Oxygen',
                    about: 'Blood oxygen saturation (SpO₂) measures the percentage of hemoglobin carrying oxygen in your blood. Normal levels are 95-100%.',
                    icon: Icons.air,
                    color: Colors.cyan,
                    unit: '%',
                    minValue: 80,
                    maxValue: 100,
                    initialValue: 98,
                    divisions: 20,
                    healthyRange: '95% - 100%',
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
                    about: 'Body Mass Index (BMI) is calculated from your weight and height: BMI = weight (kg) ÷ height² (m²).',
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
                MetricCard(
                  title: 'Stress',
                  subtitle: 'Stress level',
                  icon: Icons.psychology,
                  color: Colors.purple,
                  value: 'Low',
                  onTap: () => _openMetricDetail(
                    context,
                    title: 'Stress',
                    about: 'Stress levels are estimated based on heart rate variability (HRV) and other physiological markers.',
                    icon: Icons.psychology,
                    color: Colors.purple,
                    unit: '',
                    minValue: 0,
                    maxValue: 100,
                    initialValue: 30,
                    divisions: 100,
                    healthyRange: 'Below 50 (low stress)',
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
    return _geminiService.generateInsights(
      steps: health.data.steps,
      heartRate: health.data.heartRate,
      sleepHours: health.data.sleepHours,
      bmi: user?.bmi ?? 0,
      moodScore: 3,
    );
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