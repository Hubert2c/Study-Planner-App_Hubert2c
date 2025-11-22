import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:dplanner/models/todo.dart';
import 'package:dplanner/services/settings_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // Initialize the notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();

      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      
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
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      _initialized = true;
      print('Notification service initialized successfully');
    } catch (e) {
      print('Failed to initialize notification service: $e');
      // Don't rethrow in release mode to prevent crashes
      _initialized = false;
    }
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Handle notification tap - could navigate to specific task or show details
  }

  // Request notification permissions
  static Future<bool> requestPermissions() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // Schedule a notification for a task
  static Future<void> scheduleTaskReminder(Todo todo) async {
    try {
      print('Scheduling notification for task: ${todo.title}');
      print('Due date: ${todo.dueDate}');
      print('Reminder minutes: ${todo.reminderMinutes}');
      print('Has reminder: ${todo.hasReminder}');
      
      if (todo.dueDate == null) {
        print('Task has no due date, skipping notification');
        return;
      }

      // Check if notifications are globally enabled
      final notificationsEnabled = await SettingsService.getNotificationsEnabled();
      if (!notificationsEnabled) {
        print('Notifications are disabled in settings, skipping notification');
        return;
      }

      await initialize();
      if (!_initialized) {
        print('Notification service not initialized, skipping notification');
        return;
      }

      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        print('Notification permission not granted');
        return;
      }

    // Determine reminder minutes - use task's reminder or global default
    int reminderMinutes;
    if (todo.hasReminder) {
      // Use task's specific reminder time
      reminderMinutes = todo.reminderMinutes;
    } else {
      // Use global default reminder time from settings
      reminderMinutes = await SettingsService.getDefaultReminderMinutes();
    }

    // Calculate reminder time
    final reminderTime = todo.dueDate!.subtract(Duration(minutes: reminderMinutes));
    print('Calculated reminder time: $reminderTime');
    print('Current time: ${DateTime.now()}');
    
    // Don't schedule if reminder time is in the past
    if (reminderTime.isBefore(DateTime.now())) {
      print('Reminder time is in the past, not scheduling');
      return;
    }

    final notificationId = todo.id.hashCode;
    print('Notification ID: $notificationId');

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for task reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_stat_access_alarm',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Convert to local timezone
    final localTime = tz.TZDateTime.from(reminderTime, tz.local);
    print('Local reminder time: $localTime');
    print('Current local time: ${tz.TZDateTime.now(tz.local)}');
    
    try {
      // Try exact scheduling first
      await _notifications.zonedSchedule(
        notificationId,
        'Task Reminder: ${todo.title}',
        todo.description.isNotEmpty ? todo.description : 'Your task is due soon!',
        localTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: todo.id, // Add payload for notification handling
      );
      print('Successfully scheduled exact notification for task: ${todo.title} at $localTime');
    } catch (e) {
      print('Exact scheduling failed: $e');
      print('Falling back to inexact scheduling...');
      
      try {
        // Fallback to inexact scheduling
        await _notifications.zonedSchedule(
          notificationId,
          'Task Reminder: ${todo.title}',
          todo.description.isNotEmpty ? todo.description : 'Your task is due soon!',
          localTime,
          details,
          androidScheduleMode: AndroidScheduleMode.inexact,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          payload: todo.id, // Add payload for notification handling
        );
        print('✅ Successfully scheduled inexact notification for task: ${todo.title} at $localTime');
      } catch (fallbackError) {
        print('❌ Failed to schedule notification (both exact and inexact): $fallbackError');
        // Don't rethrow in release mode to prevent crashes
      }
    }
    } catch (e) {
      print('❌ Error in scheduleTaskReminder: $e');
      // Don't rethrow to prevent app crashes
    }
  }

  // Cancel a notification for a task
  static Future<void> cancelTaskReminder(String taskId) async {
    final notificationId = taskId.hashCode;
    await _notifications.cancel(notificationId);
    print('Cancelled notification for task: $taskId');
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('Cancelled all notifications');
  }

  // Toggle notifications globally
  static Future<void> toggleNotifications(bool enabled) async {
    if (!enabled) {
      // Cancel all scheduled notifications when disabled
      await cancelAllNotifications();
      print('Notifications disabled - all scheduled notifications cancelled');
    } else {
      print('Notifications enabled - new notifications can be scheduled');
    }
  }

  // Reschedule all tasks with new global reminder time
  static Future<void> rescheduleAllTasks(List<Todo> tasks) async {
    print('RESCHEDULING ALL TASKS: Starting reschedule process');
    print('Total tasks to reschedule: ${tasks.length}');
    
    // Cancel all existing notifications first
    await cancelAllNotifications();
    print('Cancelled all existing notifications');
    
    // Check if notifications are enabled
    final notificationsEnabled = await SettingsService.getNotificationsEnabled();
    if (!notificationsEnabled) {
      print('Notifications are disabled, not rescheduling tasks');
      return;
    }
    
    // Get current global default for logging
    final globalDefault = await SettingsService.getDefaultReminderMinutes();
    print('Current global default reminder time: $globalDefault minutes');
    
    // Reschedule each task
    int rescheduledCount = 0;
    for (final task in tasks) {
      if (task.dueDate != null) {
        print('Processing task: "${task.title}" (hasReminder: ${task.hasReminder})');
        await scheduleTaskReminder(task);
        rescheduledCount++;
      } else {
        print('Skipping task: "${task.title}" (no due date)');
      }
    }
    
    print('RESCHEDULE COMPLETE: Rescheduled $rescheduledCount out of ${tasks.length} tasks');
  }
}
