import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      dynamic rawTz = await FlutterTimezone.getLocalTimezone();
      String tzName = rawTz.toString();
      if (tzName.contains("TimezoneInfo(")) {
        final match = RegExp(r'TimezoneInfo\(([^,]+)').firstMatch(tzName);
        if (match != null) tzName = match.group(1)!;
      }
      tz.setLocalLocation(tz.getLocation(tzName));
      debugPrint("[NotificationService] Timezone initialized to: $tzName");
    } catch (e) {
      debugPrint("[NotificationService] ERROR initializing timezone: $e");
    }
    
    const androidSettings = AndroidInitializationSettings('ic_stat_notifications_active');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint("[NotificationService] Notification tapped: ${details.payload}");
      },
    );

    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay scheduledTime,
    List<int>? days,
  }) async {
    await cancelNotification(id);

    final notificationDays = (days == null || days.isEmpty) ? [1, 2, 3, 4, 5, 6, 7] : days;

    for (var day in notificationDays) {
      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, scheduledTime.hour, scheduledTime.minute);
      
      while (scheduledDate.weekday != day) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 7));
      }

      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
      final uniqueId = (id.abs() % 1000000) * 10 + day;

      debugPrint("[NotificationService] Scheduling ID: $uniqueId for $scheduledDate (Local)");

      try {
        await _notificationsPlugin.zonedSchedule(
          uniqueId,
          title,
          body,
          tzScheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'habit_reminders_final_v1',
              'Habit Reminders',
              channelDescription: 'Notifications for your daily habits',
              importance: Importance.max,
              priority: Priority.high,
              icon: 'ic_stat_notifications_active',
              showWhen: true,
              category: AndroidNotificationCategory.reminder,
              visibility: NotificationVisibility.public,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
        debugPrint("[NotificationService] SUCCESS: Scheduled ID: $uniqueId for $tzScheduledDate");
      } catch (e) {
        debugPrint("[NotificationService] ERROR scheduling ID $uniqueId: $e");
        // Fallback to non-exact if exact fails (common on Android 14 if permission missing)
        try {
          await _notificationsPlugin.zonedSchedule(
            uniqueId,
            title,
            body,
            tzScheduledDate,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'habit_reminders_final_v1',
                'Habit Reminders',
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
              iOS: DarwinNotificationDetails(),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
          debugPrint("[NotificationService] SUCCESS: Scheduled ID: $uniqueId using INEXACT fallback");
        } catch (e2) {
          debugPrint("[NotificationService] CRITICAL ERROR: Fallback also failed: $e2");
        }
      }
    }
  }

  Future<void> openAlarmSettings() async {
    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final isGranted = await androidPlugin.requestExactAlarmsPermission();
      debugPrint("[NotificationService] Exact Alarms Permission: $isGranted");
    }
  }

  Future<void> cancelNotification(int id) async {
    final baseId = (id.abs() % 1000000) * 10;
    for (int day = 1; day <= 7; day++) {
      await _notificationsPlugin.cancel(baseId + day);
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
