import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../providers/cycle_log_provider.dart';

class CycleTab extends StatelessWidget {
  const CycleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CycleLogProvider>(
      builder: (context, provider, child) {
        final cycleDay = provider.currentCycleDay;
        final cycleLength = provider.currentCycleLength;
        final phase = provider.currentPhase;
        final phaseDescription = provider.phaseDescription;
        final badges = provider.phaseBadges;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today's Forecast Hero
              _buildHeroCard(phase, phaseDescription, badges),
              const SizedBox(height: 24),

              // Cycle Progress Ring
              _buildProgressRing(cycleDay, cycleLength),
              const SizedBox(height: 24),

              // Phase Timeline Bar
              _buildPhaseTimeline(phase),
              const SizedBox(height: 24),

              // Upcoming Events
              _buildUpcomingEvents(provider),
              const SizedBox(height: 24),

              // Daily Insights
              _buildDailyInsights(phase),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroCard(String phase, String description, List<String> badges) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF97316), Color(0xFFEA580C)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Forecast",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            phase,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: badges.map((badge) => _buildBadge(badge)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProgressRing(int currentDay, int totalDays) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Cycle Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            height: 200,
            child: CustomPaint(
              painter: _CycleProgressPainter(
                currentDay: currentDay,
                totalDays: totalDays,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Day $currentDay',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF97316),
                      ),
                    ),
                    Text(
                      'of $totalDays',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseTimeline(String currentPhase) {
    final phases = ['Menstrual', 'Follicular', 'Ovulation', 'Luteal', 'PMS'];
    final colors = [
      const Color(0xFFF97316),
      const Color(0xFFFB923C),
      const Color(0xFFA855F7),
      const Color(0xFF3B82F6),
      const Color(0xFFEF4444),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phase Timeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(phases.length, (index) {
              final isActive = phases[index] == currentPhase;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isActive ? colors[index] : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                    border: isActive
                        ? Border.all(color: colors[index], width: 2)
                        : null,
                  ),
                  child: Text(
                    phases[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents(CycleLogProvider provider) {
    final nextPeriod = provider.nextPeriodDate;
    final ovulationDay = provider.ovulationDay;
    final fertileWindow = provider.fertileWindow;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Events',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildEventItem(
            Icons.calendar_today,
            'Next Period',
            nextPeriod != null
                ? '${nextPeriod.difference(DateTime.now()).inDays} days away'
                : 'Log a period to predict',
            const Color(0xFFF97316),
          ),
          const SizedBox(height: 12),
          _buildEventItem(
            Icons.favorite,
            'Ovulation Day',
            ovulationDay != null
                ? '${ovulationDay.difference(DateTime.now()).inDays} days away'
                : 'Not predicted yet',
            const Color(0xFFA855F7),
          ),
          const SizedBox(height: 12),
          _buildEventItem(
            Icons.local_florist,
            'Fertile Window',
            fertileWindow != null
                ? 'Starts in ${fertileWindow.difference(DateTime.now()).inDays} days'
                : 'Not predicted yet',
            const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(IconData icon, String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyInsights(String phase) {
    final insights = _getInsightsForPhase(phase);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Insights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle,
                    color: Color(0xFFF97316), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insight,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.white, height: 1.4),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<String> _getInsightsForPhase(String phase) {
    switch (phase) {
      case 'Menstrual':
        return [
          'Stay hydrated and rest as needed',
          'Light exercise like walking or yoga can help',
          'Iron-rich foods can help replenish lost nutrients',
        ];
      case 'Follicular':
        return [
          'Energy levels are rising - great time for workouts',
          'Focus on protein-rich foods',
          'Good time to start new projects',
        ];
      case 'Ovulation':
        return [
          'Peak fertility window - track carefully if trying to conceive',
          'Highest energy levels of the cycle',
          'Social and communicative phase',
        ];
      case 'Luteal':
        return [
          'PMS symptoms may start - practice self-care',
          'Reduce caffeine and salt intake',
          'Gentle exercise like swimming recommended',
        ];
      case 'PMS':
        return [
          'Prioritize rest and relaxation',
          'Magnesium-rich foods can help with cramps',
          'Stay hydrated and avoid processed foods',
        ];
      default:
        return ['Track your cycle for personalized insights'];
    }
  }
}

class _CycleProgressPainter extends CustomPainter {
  final int currentDay;
  final int totalDays;

  _CycleProgressPainter({required this.currentDay, required this.totalDays});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Background circle
    final bgPaint = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progress = (currentDay / totalDays).clamp(0.0, 1.0);
    final sweepAngle = 2 * math.pi * progress;

    final progressPaint = Paint()
      ..shader = const SweepGradient(
        colors: [Color(0xFFF97316), Color(0xFFEA580C)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}