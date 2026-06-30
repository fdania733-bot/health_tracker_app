import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification tapped: ${details.payload}');
      },
    );

    // Create Android notification channels
    await _createAndroidChannels();

    _initialized = true;
  }

  Future<void> _createAndroidChannels() async {
    const AndroidNotificationChannel waterChannel = AndroidNotificationChannel(
      'water_channel',
      'Water Reminders',
      description: 'Reminders to drink water',
      importance: Importance.high,
    );

    const AndroidNotificationChannel workoutChannel = AndroidNotificationChannel(
      'workout_channel',
      'Workout Reminders',
      description: 'Reminders for workouts',
      importance: Importance.high,
    );

    const AndroidNotificationChannel sleepChannel = AndroidNotificationChannel(
      'sleep_channel',
      'Sleep Reminders',
      description: 'Reminders for sleep schedule',
      importance: Importance.high,
    );

    const AndroidNotificationChannel healthChannel = AndroidNotificationChannel(
      'health_channel',
      'Health Check Reminders',
      description: 'Daily health check reminders',
      importance: Importance.high,
    );

    const AndroidNotificationChannel cycleChannel = AndroidNotificationChannel(
      'cycle_channel',
      'Cycle Reminders',
      description: 'Menstrual cycle tracking reminders',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(waterChannel);
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(workoutChannel);
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(sleepChannel);
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(healthChannel);
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(cycleChannel);
  }

  Future<bool> requestPermission() async {
    // FIX: Use correct permission_handler API
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // FIX: Return TZDateTime instead of DateTime
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.Location location = tz.local;
    final tz.TZDateTime now = tz.TZDateTime.now(location);
    tz.TZDateTime scheduled = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> scheduleWaterReminder() async {
    await _notifications.zonedSchedule(
      1,
      '💧 Stay Hydrated!',
      'Time to drink some water. Your body will thank you!',
      _nextInstanceOfTime(9, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_channel',
          'Water Reminders',
          channelDescription: 'Reminders to drink water',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleWorkoutReminder() async {
    await _notifications.zonedSchedule(
      2,
      '🏃 Time to Move!',
      'Your daily workout is waiting. Let\'s get active!',
      _nextInstanceOfTime(17, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'workout_channel',
          'Workout Reminders',
          channelDescription: 'Reminders for workouts',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleSleepReminder() async {
    await _notifications.zonedSchedule(
      3,
      '😴 Time to Sleep',
      'Good sleep is essential. Wind down and get some rest!',
      _nextInstanceOfTime(22, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sleep_channel',
          'Sleep Reminders',
          channelDescription: 'Reminders for sleep schedule',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleHealthCheckReminder() async {
    await _notifications.zonedSchedule(
      4,
      '🩺 Daily Health Check',
      'Don\'t forget to log your health metrics today!',
      _nextInstanceOfTime(8, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'health_channel',
          'Health Check Reminders',
          channelDescription: 'Daily health check reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleCycleReminder() async {
    await _notifications.zonedSchedule(
      5,
      '🌸 Cycle Reminder',
      'Time to log your cycle status. Stay on top of your health!',
      _nextInstanceOfTime(9, 30),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'cycle_channel',
          'Cycle Reminders',
          channelDescription: 'Menstrual cycle tracking reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleAllReminders({bool isFemale = false}) async {
    await cancelAll();
    await scheduleWaterReminder();
    await scheduleWorkoutReminder();
    await scheduleSleepReminder();
    await scheduleHealthCheckReminder();
    if (isFemale) {
      await scheduleCycleReminder();
    }
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}