import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  bool _notificationsEnabled = false;
  bool _waterReminder = true;
  bool _workoutReminder = true;
  bool _sleepReminder = true;
  bool _healthCheckReminder = true;
  bool _cycleReminder = true;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get waterReminder => _waterReminder;
  bool get workoutReminder => _workoutReminder;
  bool get sleepReminder => _sleepReminder;
  bool get healthCheckReminder => _healthCheckReminder;
  bool get cycleReminder => _cycleReminder;

  NotificationProvider() {
    _init();
  }

  Future<void> _init() async {
    await _notificationService.initialize();
    notifyListeners();
  }

  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    if (enabled) {
      await _notificationService.requestPermission();
      await _rescheduleAll();
    } else {
      await _notificationService.cancelAll();
    }
    notifyListeners();
  }

  Future<void> toggleWaterReminder(bool enabled) async {
    _waterReminder = enabled;
    await _rescheduleAll();
    notifyListeners();
  }

  Future<void> toggleWorkoutReminder(bool enabled) async {
    _workoutReminder = enabled;
    await _rescheduleAll();
    notifyListeners();
  }

  Future<void> toggleSleepReminder(bool enabled) async {
    _sleepReminder = enabled;
    await _rescheduleAll();
    notifyListeners();
  }

  Future<void> toggleHealthCheckReminder(bool enabled) async {
    _healthCheckReminder = enabled;
    await _rescheduleAll();
    notifyListeners();
  }

  Future<void> toggleCycleReminder(bool enabled) async {
    _cycleReminder = enabled;
    await _rescheduleAll();
    notifyListeners();
  }

  Future<void> _rescheduleAll() async {
    if (!_notificationsEnabled) return;

    await _notificationService.cancelAll();

    if (_waterReminder) await _notificationService.scheduleWaterReminder();
    if (_workoutReminder) await _notificationService.scheduleWorkoutReminder();
    if (_sleepReminder) await _notificationService.scheduleSleepReminder();
    if (_healthCheckReminder) await _notificationService.scheduleHealthCheckReminder();
    if (_cycleReminder) await _notificationService.scheduleCycleReminder();
  }
}