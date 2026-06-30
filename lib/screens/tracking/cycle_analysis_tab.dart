import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cycle_log_provider.dart';

class CycleAnalysisTab extends StatelessWidget {
  const CycleAnalysisTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CycleLogProvider>(
      builder: (context, provider, child) {
        final stats = provider.cycleStats;
        final regularity = provider.cycleRegularity;
        final accuracy = provider.predictionAccuracy;
        final fertileConfidence = provider.fertileWindowConfidence;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cycle Summary
              _buildCycleSummary(stats),
              const SizedBox(height: 16),

              // Body Analysis
              _buildBodyAnalysis(regularity, accuracy, fertileConfidence),
              const SizedBox(height: 16),

              // Hormone Phase Breakdown
              _buildHormoneBreakdown(provider.currentPhase),
              const SizedBox(height: 16),

              // Health Insights
              _buildHealthInsights(provider),
              const SizedBox(height: 16),

              // Cycle Length Chart
              _buildCycleLengthChart(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCycleSummary(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cycle Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pink[900],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Avg Cycle Length',
                  '${stats['avgCycleLength'] ?? '--'} days',
                  Icons.calendar_today,
                  Colors.pink[400]!,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'Avg Period Length',
                  '${stats['avgPeriodLength'] ?? '--'} days',
                  Icons.water_drop,
                  Colors.pink[300]!,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Periods Logged',
                  '${stats['periodsLogged'] ?? 0}',
                  Icons.check_circle,
                  Colors.teal[400]!,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'Regularity',
                  stats['regularity'] ?? '--',
                  Icons.trending_up,
                  Colors.purple[400]!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyAnalysis(double regularity, double accuracy, double fertileConfidence) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Body Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pink[900],
            ),
          ),
          const SizedBox(height: 20),
          _buildProgressBar('Cycle Regularity', regularity, Colors.pink[400]!),
          const SizedBox(height: 16),
          _buildProgressBar('Prediction Accuracy', accuracy, Colors.purple[400]!),
          const SizedBox(height: 16),
          _buildProgressBar('Fertile Window Confidence', fertileConfidence, Colors.teal[400]!),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildHormoneBreakdown(String currentPhase) {
    final phases = [
      {'name': 'Menstrual', 'hormone': 'Low estrogen & progesterone', 'color': Colors.pink[300]!},
      {'name': 'Follicular', 'hormone': 'Rising estrogen', 'color': Colors.pink[200]!},
      {'name': 'Ovulation', 'hormone': 'Peak estrogen & LH surge', 'color': Colors.purple[200]!},
      {'name': 'Luteal', 'hormone': 'High progesterone', 'color': Colors.orange[200]!},
      {'name': 'PMS', 'hormone': 'Declining hormones', 'color': Colors.amber[200]!},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hormone Phase Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pink[900],
            ),
          ),
          const SizedBox(height: 20),
          ...phases.map((phase) {
            final isActive = phase['name'] == currentPhase;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive ? (phase['color'] as Color).withOpacity(0.2) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: isActive ? Border.all(color: phase['color'] as Color, width: 2) : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: phase['color'] as Color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.science, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          phase['name'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isActive ? (phase['color'] as Color) : Colors.grey[700],
                          ),
                        ),
                        Text(
                          phase['hormone'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isActive)
                    Icon(Icons.check_circle, color: phase['color'] as Color, size: 24),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHealthInsights(CycleLogProvider provider) {
    final insights = provider.healthInsights;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.pink[100]!, Colors.purple[100]!],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.pink[700], size: 24),
              const SizedBox(width: 8),
              Text(
                'Health Insights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.trending_up, color: Colors.pink[600], size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insight,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCycleLengthChart(CycleLogProvider provider) {
    final cycleLengths = provider.cycleLengthHistory;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cycle Length History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pink[900],
            ),
          ),
          const SizedBox(height: 20),
          if (cycleLengths.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Log more cycles to see trends',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: CustomPaint(
                size: Size.infinite,
                painter: _CycleLengthChartPainter(
                  data: cycleLengths,
                  color: Colors.pink[400]!,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CycleLengthChartPainter extends CustomPainter {
  final List<int> data;
  final Color color;

  _CycleLengthChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.reduce((a, b) => a > b ? a : b).toDouble();
    final minVal = data.reduce((a, b) => a < b ? a : b).toDouble();
    final range = maxVal - minVal;

    final barWidth = size.width / data.length * 0.6;
    final spacing = size.width / data.length * 0.4;

    for (int i = 0; i < data.length; i++) {
      final barHeight = range > 0
          ? ((data[i] - minVal) / range) * (size.height - 40)
          : size.height / 2;

      final x = i * (barWidth + spacing) + spacing / 2;
      final y = size.height - barHeight - 20;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(8),
      );

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.6), color],
        ).createShader(rect.outerRect);

      canvas.drawRRect(rect, paint);

      // Draw value label
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${data[i]}',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + barWidth / 2 - textPainter.width / 2, y - 15));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}