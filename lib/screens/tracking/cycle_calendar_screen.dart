import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/menstrual_cycle_model.dart';

class CycleCalendarScreen extends StatefulWidget {
  const CycleCalendarScreen({super.key});
  @override
  State<CycleCalendarScreen> createState() => _CycleCalendarScreenState();
}

class _CycleCalendarScreenState extends State<CycleCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _displayMonth = DateTime.now();
  MenstrualCycleModel? _currentCycle;
  Map<DateTime, String> _dayPhases = {};

  @override
  void initState() {
    super.initState();
    _loadCycleData();
  }

  Future<void> _loadCycleData() async {
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
        final startDate = (data['startDate'] as Timestamp).toDate();
        final cycleLength = data['cycleLength'] ?? 28;

        setState(() {
          _currentCycle = MenstrualCycleModel(
            id: snap.docs.first.id,
            startDate: startDate,
            cycleLength: cycleLength,
            phase: data['phase'] ?? 'Unknown',
            cycleDay: data['cycleDay'] ?? 0,
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          );
          _calculateDayPhases(startDate, cycleLength);
        });
      }
    } catch (e) {
      debugPrint('Error loading cycle data: $e');
    }
  }

  void _calculateDayPhases(DateTime startDate, int cycleLength) {
    _dayPhases.clear();

    // Calculate phases for current cycle
    for (int i = 0; i < cycleLength; i++) {
      final date = startDate.add(Duration(days: i));
      final dayNum = i + 1;

      String phase;
      if (dayNum <= 5) {
        phase = 'period';
      } else if (dayNum <= 13) {
        phase = 'follicular';
      } else if (dayNum == 14) {
        phase = 'ovulation';
      } else {
        phase = 'luteal';
      }

      _dayPhases[date] = phase;
    }

    // Predict next cycle phases
    final nextStartDate = startDate.add(Duration(days: cycleLength));
    for (int i = 0; i < cycleLength; i++) {
      final date = nextStartDate.add(Duration(days: i));
      final dayNum = i + 1;

      String phase;
      if (dayNum <= 5) {
        phase = 'predicted_period';
      } else if (dayNum >= 12 && dayNum <= 16) {
        phase = 'fertile';
      } else {
        phase = 'predicted_luteal';
      }

      _dayPhases[date] = phase;
    }
  }

  Future<void> _selectPeriodStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
      await _saveCycleData(picked);
    }
  }

  Future<void> _saveCycleData(DateTime startDate) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final cycleDay = MenstrualCycleModel.calculateCycleDay(startDate);
      final phase = MenstrualCycleModel.calculatePhase(startDate);
      final cycleLength = _currentCycle?.cycleLength ?? 28;
      final nextPeriodDate = startDate.add(Duration(days: cycleLength));

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('cycles')
          .add({
        'startDate': Timestamp.fromDate(startDate),
        'cycleLength': cycleLength,
        'nextPeriodDate': Timestamp.fromDate(nextPeriodDate),
        'phase': phase,
        'cycleDay': cycleDay,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _loadCycleData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cycle data saved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    }
  }

  Color _getDayColor(DateTime date) {
    final phase = _dayPhases[date];
    if (phase == null) return Colors.transparent;

    switch (phase) {
      case 'period':
        return Colors.pink.withOpacity(0.8);
      case 'predicted_period':
        return Colors.pink.withOpacity(0.3);
      case 'follicular':
        return Colors.blue.withOpacity(0.3);
      case 'ovulation':
        return Colors.purple;
      case 'fertile':
        return Colors.purple.withOpacity(0.5);
      case 'luteal':
        return Colors.orange.withOpacity(0.3);
      case 'predicted_luteal':
        return Colors.orange.withOpacity(0.2);
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cycle Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _selectPeriodStartDate,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Month navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _displayMonth = DateTime(
                        _displayMonth.year,
                        _displayMonth.month - 1,
                      );
                    });
                  },
                ),
                Text(
                  '${_displayMonth.month}/${_displayMonth.year}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _displayMonth = DateTime(
                        _displayMonth.year,
                        _displayMonth.month + 1,
                      );
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Weekday headers
            Row(
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map((day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            // Calendar grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
              ),
              itemCount: startingWeekday - 1 + daysInMonth,
              itemBuilder: (context, index) {
                if (index < startingWeekday - 1) {
                  return const SizedBox();
                }

                final day = index - (startingWeekday - 1) + 1;
                final date = DateTime(_displayMonth.year, _displayMonth.month, day);
                final isToday = date.day == DateTime.now().day &&
                    date.month == DateTime.now().month &&
                    date.year == DateTime.now().year;
                final isSelected = date.day == _selectedDate.day &&
                    date.month == _selectedDate.month &&
                    date.year == _selectedDate.year;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDate = date);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: _getDayColor(date),
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: Colors.teal, width: 2)
                          : isSelected
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          color: isToday || isSelected ? Colors.teal : null,
                          fontWeight: isToday ? FontWeight.bold : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Legend
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Legend',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildLegendItem(Colors.pink.withOpacity(0.8), 'Period'),
                  _buildLegendItem(Colors.pink.withOpacity(0.3), 'Predicted Period'),
                  _buildLegendItem(Colors.blue.withOpacity(0.3), 'Follicular Phase'),
                  _buildLegendItem(Colors.purple, 'Ovulation'),
                  _buildLegendItem(Colors.purple.withOpacity(0.5), 'Fertile Window'),
                  _buildLegendItem(Colors.orange.withOpacity(0.3), 'Luteal Phase'),
                ],
              ),
            ),
            if (_currentCycle != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Cycle',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Day ${_currentCycle!.cycleDay}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _currentCycle!.phase,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}