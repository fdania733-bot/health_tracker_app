import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/cycle_log_provider.dart';
import 'symptoms_selector_screen.dart';
import 'numeric_keypad_screen.dart';

class CycleLogScreen extends StatefulWidget {
  const CycleLogScreen({super.key});
  @override
  State<CycleLogScreen> createState() => _CycleLogScreenState();
}

class _CycleLogScreenState extends State<CycleLogScreen> {
  String _mode = 'Track period';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Mode tabs
          _buildModeTabs(),
          // Calendar
          _buildCalendar(),
          // Log form
          Expanded(child: _buildLogForm()),
        ],
      ),
    );
  }

  Widget _buildModeTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildModeTab('Track period'),
          const SizedBox(width: 8),
          _buildModeTab('Try to conceive'),
          const SizedBox(width: 8),
          _buildModeTab('Track my pregnancy'),
        ],
      ),
    );
  }

  Widget _buildModeTab(String label) {
    final isSelected = _mode == label;
    return GestureDetector(
      onTap: () => setState(() => _mode = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Consumer<CycleLogProvider>(
      builder: (context, provider, child) {
        return TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: provider.selectedDate,
          selectedDayPredicate: (day) => isSameDay(provider.selectedDate, day),
          onDaySelected: (selectedDay, focusedDay) {
            provider.setSelectedDate(selectedDay);
          },
          calendarStyle: CalendarStyle(
            selectedDecoration: const BoxDecoration(
              color: Colors.pink,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.pink.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        );
      },
    );
  }

  Widget _buildLogForm() {
    return Consumer<CycleLogProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final log = provider.currentLog;
        if (log == null) {
          return const Center(child: Text('No data available'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPeriodStartsRow(log),
            const SizedBox(height: 16),
            _buildFlowRow(log),
            const SizedBox(height: 16),
            _buildCrampsRow(log),
            const SizedBox(height: 16),
            _buildSexRow(log),
            const SizedBox(height: 16),
            _buildSymptomsRow(log),
            const SizedBox(height: 16),
            _buildMoodRow(log),
            const SizedBox(height: 16),
            _buildHabitsRow(log),
            const SizedBox(height: 16),
            _buildDischargeRow(log),
            const SizedBox(height: 16),
            _buildWeightRow(log),
            const SizedBox(height: 16),
            _buildBodyTempRow(log),
            const SizedBox(height: 16),
            _buildDiaryRow(log),
          ],
        );
      },
    );
  }

  Widget _buildPeriodStartsRow(log) {
    return _buildRowWithTitle(
      'Period starts',
      Row(
        children: [
          _buildToggleButton(
            'No',
            !log.periodStarted,
                () => context.read<CycleLogProvider>().updatePeriodStarted(false),
          ),
          const SizedBox(width: 8),
          _buildToggleButton(
            'Yes',
            log.periodStarted,
                () => context.read<CycleLogProvider>().updatePeriodStarted(true),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowRow(log) {
    return _buildRowWithTitle(
      'Flow',
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          final level = index + 1;
          final isSelected = log.flowLevel == level;
          return GestureDetector(
            onTap: () => context.read<CycleLogProvider>().updateFlowLevel(level),
            child: Icon(
              Icons.water_drop,
              color: isSelected ? Colors.pink : Colors.grey[300],
              size: 32,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCrampsRow(log) {
    return _buildRowWithTitle(
      'Menstrual cramps',
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          final level = index + 1;
          final isSelected = log.crampLevel == level;
          return GestureDetector(
            onTap: () => context.read<CycleLogProvider>().updateCrampLevel(level),
            child: Icon(
              Icons.bolt,
              color: isSelected ? Colors.orange : Colors.grey[300],
              size: 32,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSexRow(log) {
    return _buildRowWithTitle(
      'Sex',
      GestureDetector(
        onTap: () => _showSexSelector(log),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.pink),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.add, color: Colors.pink),
        ),
      ),
    );
  }

  Widget _buildSymptomsRow(log) {
    return _buildRowWithTitle(
      'Symptoms',
      GestureDetector(
        onTap: () => _showSymptomsSelector(log),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.pink),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.add, color: Colors.pink),
        ),
      ),
    );
  }

  Widget _buildMoodRow(log) {
    final emojis = ['😞', '', '😐', '🙂', '😄'];
    return _buildRowWithTitle(
      'Mood',
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          final isSelected = log.mood == (index + 1);
          return GestureDetector(
            onTap: () => context.read<CycleLogProvider>().updateMood(index + 1),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.pink.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(emojis[index], style: const TextStyle(fontSize: 28)),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHabitsRow(log) {
    final icons = [
      Icons.self_improvement,
      Icons.set_meal,
      Icons.local_cafe,
      Icons.fitness_center,
      Icons.water_drop,
    ];
    return _buildRowWithTitle(
      'Habit',
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          final isSelected = log.habits.contains('habit_$index');
          return GestureDetector(
            onTap: () {
              final habits = List<String>.from(log.habits);
              if (isSelected) {
                habits.remove('habit_$index');
              } else {
                habits.add('habit_$index');
              }
              context.read<CycleLogProvider>().updateHabits(habits);
            },
            child: Icon(
              icons[index],
              color: isSelected ? Colors.teal : Colors.grey[300],
              size: 32,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDischargeRow(log) {
    return _buildRowWithTitle(
      'Vaginal discharge',
      GestureDetector(
        onTap: () => _showDischargeSelector(log),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.pink),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.add, color: Colors.pink),
        ),
      ),
    );
  }

  Widget _buildWeightRow(log) {
    return _buildRowWithTitle(
      'Weight',
      GestureDetector(
        onTap: () => _showWeightInput(log),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.pink),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            log.weight != null ? '${log.weight} kg' : 'Add weight',
            style: TextStyle(color: log.weight != null ? Colors.pink : Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyTempRow(log) {
    return _buildRowWithTitle(
      'Body temperature',
      GestureDetector(
        onTap: () => _showTempInput(log),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.pink),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            log.bodyTemp != null ? '${log.bodyTemp}°C' : 'Add temp',
            style: TextStyle(color: log.bodyTemp != null ? Colors.pink : Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildDiaryRow(log) {
    return _buildRowWithTitle(
      'Diary',
      Row(
        children: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.pink),
            onPressed: () => _showDiaryInput(log),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.pink),
            onPressed: () => _showDiaryInput(log),
          ),
        ],
      ),
    );
  }

  Widget _buildRowWithTitle(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showSexSelector(log) {
    // Implement sex selector
  }

  Future<void> _showSymptomsSelector(log) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SymptomsSelectorScreen()),
    );
    if (result != null && result is List<String>) {
      await context.read<CycleLogProvider>().updateSymptoms(result);
    }
  }

  void _showDischargeSelector(log) {
    // Implement discharge selector
  }

  Future<void> _showWeightInput(log) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NumericKeypadScreen(title: 'Weight', unit: 'kg')),
    );
    if (result != null && result is double) {
      await context.read<CycleLogProvider>().updateWeight(result);
    }
  }

  Future<void> _showTempInput(log) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NumericKeypadScreen(title: 'Body Temperature', unit: '°C')),
    );
    if (result != null && result is double) {
      await context.read<CycleLogProvider>().updateBodyTemp(result);
    }
  }

  Future<void> _showDiaryInput(log) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final photoUrl = await context.read<CycleLogProvider>().uploadPhoto(File(pickedFile.path));
      await context.read<CycleLogProvider>().updateDiary(log.diaryText ?? '', photoUrl);
    }
  }
}