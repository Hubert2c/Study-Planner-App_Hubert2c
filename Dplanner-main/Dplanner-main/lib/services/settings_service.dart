import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _reminderMinutesKey = 'default_reminder_minutes';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const int _defaultReminderMinutes = 10;
  static const bool _defaultNotificationsEnabled = true;

  // Get default reminder minutes from settings
  static Future<int> getDefaultReminderMinutes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_reminderMinutesKey) ?? _defaultReminderMinutes;
    } catch (e) {
      print('Error getting default reminder minutes: $e');
      return _defaultReminderMinutes;
    }
  }

  // Save default reminder minutes to settings
  static Future<void> setDefaultReminderMinutes(int minutes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_reminderMinutesKey, minutes);
    } catch (e) {
      print('Error saving default reminder minutes: $e');
    }
  }

  // Get notification enabled status
  static Future<bool> getNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_notificationsEnabledKey) ?? _defaultNotificationsEnabled;
    } catch (e) {
      print('Error getting notifications enabled status: $e');
      return _defaultNotificationsEnabled;
    }
  }

  // Save notification enabled status
  static Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsEnabledKey, enabled);
    } catch (e) {
      print('Error saving notifications enabled status: $e');
    }
  }
}