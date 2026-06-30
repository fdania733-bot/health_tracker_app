import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math' as math;
import 'dart:io';
import '../models/cycle_log_model.dart';

class CycleLogProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  DateTime _selectedDate = DateTime.now();
  final Map<String, CycleLogModel> _logs = {};
  bool _isLoading = false;

  int _currentCycleDay = 1;
  int _currentCycleLength = 28;
  String _currentPhase = 'Follicular';

  DateTime get selectedDate => _selectedDate;
  Map<String, CycleLogModel> get logs => _logs;
  CycleLogModel? get currentLog => _logs[_formatDate(_selectedDate)];
  bool get isLoading => _isLoading;
  int get currentCycleDay => _currentCycleDay;
  int get currentCycleLength => _currentCycleLength;
  String get currentPhase => _currentPhase;

  CycleLogProvider() {
    _loadAllLogs();
  }

  String get phaseDescription {
    switch (_currentPhase) {
      case 'Menstrual':
        return 'Your body is shedding the uterine lining. Rest and self-care are important.';
      case 'Follicular':
        return 'Estrogen is rising. Energy levels are increasing. Great time for new activities.';
      case 'Ovulation':
        return 'Peak fertility window. You may feel more energetic and social.';
      case 'Luteal':
        return 'Progesterone is high. PMS symptoms may start. Focus on wellness.';
      case 'PMS':
        return 'Hormones are declining. Practice self-care and rest.';
      default:
        return 'Track your cycle for personalized insights.';
    }
  }

  List<String> get phaseBadges {
    final badges = <String>[];
    if (_currentPhase == 'Ovulation') badges.add('Peak Fertility');
    if (_currentPhase == 'Menstrual') badges.add('Period Active');
    if (_currentPhase == 'PMS' || _currentPhase == 'Luteal') badges.add('PMS Window');
    if (_currentCycleDay >= 10 && _currentCycleDay <= 16) badges.add('Fertile Window');
    return badges;
  }

  DateTime? get nextPeriodDate {
    final periodLogs = _logs.values.where((l) => l.periodStarted).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    if (periodLogs.isEmpty) return null;

    final startDate = DateTime.parse(periodLogs.first.date);
    return startDate.add(Duration(days: _currentCycleLength));
  }

  DateTime? get ovulationDay {
    final next = nextPeriodDate;
    if (next == null) return null;
    return next.subtract(const Duration(days: 14));
  }

  DateTime? get fertileWindow {
    final ovulation = ovulationDay;
    if (ovulation == null) return null;
    return ovulation.subtract(const Duration(days: 5));
  }

  Map<String, dynamic> get cycleStats {
    final periodLogs = _logs.values.where((l) => l.periodStarted).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (periodLogs.length < 2) {
      return {
        'avgCycleLength': '--',
        'avgPeriodLength': '--',
        'periodsLogged': periodLogs.length,
        'regularity': '--',
      };
    }

    final cycleLengths = <int>[];
    for (int i = 1; i < periodLogs.length; i++) {
      final prev = DateTime.parse(periodLogs[i - 1].date);
      final curr = DateTime.parse(periodLogs[i].date);
      cycleLengths.add(curr.difference(prev).inDays);
    }

    final avgCycle = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
    final avgPeriod = 5.0;

    final regularity = _calculateRegularity(cycleLengths);

    return {
      'avgCycleLength': avgCycle.round(),
      'avgPeriodLength': avgPeriod.round(),
      'periodsLogged': periodLogs.length,
      'regularity': regularity,
    };
  }

  double get cycleRegularity {
    final stats = cycleStats;
    if (stats['regularity'] == '--') return 0.5;
    if (stats['regularity'] == 'Very Regular') return 0.95;
    if (stats['regularity'] == 'Regular') return 0.80;
    return 0.50;
  }

  double get predictionAccuracy => 0.75;
  double get fertileWindowConfidence => 0.80;

  List<String> get healthInsights {
    final insights = <String>[];

    if (_currentPhase == 'Menstrual') {
      insights.add('Consider iron-rich foods to replenish nutrients');
      insights.add('Light exercise can help with cramps');
    } else if (_currentPhase == 'Ovulation') {
      insights.add('Peak fertility - track carefully if planning');
      insights.add('Energy levels are at their highest');
    } else if (_currentPhase == 'PMS') {
      insights.add('Magnesium-rich foods may help with symptoms');
      insights.add('Prioritize rest and stress management');
    }

    final periodCount = _logs.values.where((l) => l.periodStarted).length;
    if (periodCount < 3) {
      insights.add('Log more periods for better predictions');
    }

    if (insights.isEmpty) {
      insights.add('Keep tracking your cycle for personalized insights');
    }

    return insights;
  }

  List<int> get cycleLengthHistory {
    final periodLogs = _logs.values.where((l) => l.periodStarted).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (periodLogs.length < 2) return [];

    final lengths = <int>[];
    for (int i = 1; i < periodLogs.length; i++) {
      final prev = DateTime.parse(periodLogs[i - 1].date);
      final curr = DateTime.parse(periodLogs[i].date);
      lengths.add(curr.difference(prev).inDays);
    }

    return lengths;
  }

  String _calculateRegularity(List<int> cycleLengths) {
    if (cycleLengths.isEmpty) return '--';

    final avg = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
    final variance = cycleLengths.map((l) => (l - avg) * (l - avg)).reduce((a, b) => a + b) / cycleLengths.length;
    final stdDev = math.sqrt(variance);

    if (stdDev < 2) return 'Very Regular';
    if (stdDev < 4) return 'Regular';
    return 'Irregular';
  }

  Future<void> _loadAllLogs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('cycle_logs')
          .get();

      _logs.clear();
      for (var doc in snapshot.docs) {
        _logs[doc.id] = CycleLogModel.fromMap(doc.data(), doc.id);
      }

      _updateCycleCalculations();
    } catch (e) {
      debugPrint('Error loading logs: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _saveLog(CycleLogModel log) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('cycle_logs')
          .doc(log.date)
          .set(log.toMap(), SetOptions(merge: true));

      _logs[log.date] = log;
      _updateCycleCalculations();
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving log: $e');
      rethrow;
    }
  }

  Future<void> updatePeriodStarted(bool started) async {
    final dateStr = _formatDate(_selectedDate);
    final existingLog = _logs[dateStr] ?? CycleLogModel(date: dateStr);
    final updated = existingLog.copyWith(periodStarted: started);
    await _saveLog(updated);
  }

  Future<void> updateFlowLevel(int level) async {
    final dateStr = _formatDate(_selectedDate);
    final existingLog = _logs[dateStr] ?? CycleLogModel(date: dateStr);
    final updated = existingLog.copyWith(flowLevel: level);
    await _saveLog(updated);
  }

  Future<void> updateCrampLevel(int level) async {
    final dateStr = _formatDate(_selectedDate);
    final existingLog = _logs[dateStr] ?? CycleLogModel(date: dateStr);
    final updated = existingLog.copyWith(crampLevel: level);
    await _saveLog(updated);
  }

  Future<void> updateSymptoms(List<String> symptoms) async {
    final dateStr = _formatDate(_selectedDate);
    final existingLog = _logs[dateStr] ?? CycleLogModel(date: dateStr);
    final updated = existingLog.copyWith(symptoms: symptoms);
    await _saveLog(updated);
  }

  Future<void> updateMood(int mood) async {
    final dateStr = _formatDate(_selectedDate);
    final existingLog = _logs[dateStr] ?? CycleLogModel(date: dateStr);
    final updated = existingLog.copyWith(mood: mood);
    await _saveLog(updated);
  }

  Future<void> updateHabits(List<String> habits) async {
    final dateStr = _formatDate(_selectedDate);
    final existingLog = _logs[dateStr] ?? CycleLogModel(date: dateStr);
    final updated = existingLog.copyWith(habits: habits);
    await _saveLog(updated);
  }

  Future<void> updateDischarge(String discharge) async {
    final dateStr = _formatDate(_selectedDate);
    final existingLog = _logs[dateStr] ?? CycleLogModel(date: dateStr);
    final updated = existingLog.copyWith(discharge: discharge);
    await _saveLog(updated);
  }

  Future<void> updateWeight(double weight) async {
    final dateStr = _formatDate(_selectedDate);
    final existingLog = _logs[dateStr] ?? CycleLogModel(date: dateStr);
    final updated = existingLog.copyWith(weight: weight);
    await _saveLog(updated);
  }

  Future<void> updateBodyTemp(double temp) async {
    final dateStr = _formatDate(_selectedDate);
    final existingLog = _logs[dateStr] ?? CycleLogModel(date: dateStr);
    final updated = existingLog.copyWith(bodyTemp: temp);
    await _saveLog(updated);
  }

  Future<void> updateDiary(String text, String? photoUrl) async {
    final dateStr = _formatDate(_selectedDate);
    final existingLog = _logs[dateStr] ?? CycleLogModel(date: dateStr);
    final updated = existingLog.copyWith(diaryText: text, diaryPhotoUrl: photoUrl);
    await _saveLog(updated);
  }

  Future<void> updateSexActivity(List<String> activities) async {
    final dateStr = _formatDate(_selectedDate);
    final existingLog = _logs[dateStr] ?? CycleLogModel(date: dateStr);
    final updated = existingLog.copyWith(sexActivity: activities);
    await _saveLog(updated);
  }

  Future<void> logPeriod(DateTime startDate, DateTime? endDate, int flowLevel) async {
    final dateStr = _formatDate(startDate);
    final log = CycleLogModel(
      date: dateStr,
      periodStarted: true,
      flowLevel: flowLevel,
    );

    await _saveLog(log);

    if (endDate != null) {
      final days = endDate.difference(startDate).inDays;
      for (int i = 1; i <= days; i++) {
        final nextDate = startDate.add(Duration(days: i));
        final nextDateStr = _formatDate(nextDate);
        final nextLog = CycleLogModel(
          date: nextDateStr,
          periodStarted: true,
          flowLevel: flowLevel,
        );
        await _saveLog(nextLog);
      }
    }
  }

  Future<void> logSymptoms(DateTime date, List<String> symptoms, int mood, String notes) async {
    final dateStr = _formatDate(date);
    final existingLog = _logs[dateStr] ?? CycleLogModel(date: dateStr);

    final updatedLog = existingLog.copyWith(
      symptoms: symptoms,
      mood: mood,
      diaryText: notes.isNotEmpty ? notes : null,
    );

    await _saveLog(updatedLog);
  }

  void _updateCycleCalculations() {
    final periodLogs = _logs.values.where((l) => l.periodStarted).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (periodLogs.isEmpty) {
      _currentCycleDay = 1;
      _currentCycleLength = 28;
      _currentPhase = 'Follicular';
      return;
    }

    final lastPeriod = DateTime.parse(periodLogs.first.date);
    _currentCycleDay = DateTime.now().difference(lastPeriod).inDays + 1;

    if (periodLogs.length >= 2) {
      final prevPeriod = DateTime.parse(periodLogs[1].date);
      _currentCycleLength = lastPeriod.difference(prevPeriod).inDays;
    }

    _currentPhase = _calculateCurrentPhase(_currentCycleDay);
  }

  String _calculateCurrentPhase(int day) {
    if (day <= 5) return 'Menstrual';
    if (day <= 13) return 'Follicular';
    if (day >= 14 && day <= 16) return 'Ovulation';
    if (day <= 25) return 'Luteal';
    return 'PMS';
  }

  Future<String?> uploadPhoto(File imageFile) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      final dateStr = _formatDate(_selectedDate);
      final ref = _storage.ref().child('users/$uid/diary_photos/$dateStr.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading photo: $e');
      return null;
    }
  }
}