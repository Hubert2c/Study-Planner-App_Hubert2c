import 'package:flutter/material.dart';
import 'package:dplanner/widgets/main_layout.dart';
import 'package:dplanner/services/database_helper.dart';
import 'package:dplanner/services/settings_service.dart';
import 'package:dplanner/services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  int _reminderMinutes = 10;
  final SimpleDatabaseHelper _dbHelper = SimpleDatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final defaultMinutes = await SettingsService.getDefaultReminderMinutes();
    final notificationsEnabled = await SettingsService.getNotificationsEnabled();
    setState(() {
      _reminderMinutes = defaultMinutes;
      _notificationsEnabled = notificationsEnabled;
    });
  }

  Future<void> _rescheduleAllTasks() async {
    try {
      
      // Get all tasks from database
      final tasks = await _dbHelper.getAllTodos();
      
      // Reschedule all tasks with new global reminder time
      await NotificationService.rescheduleAllTasks(tasks);
      
    } catch (e) {
        print('Error rescheduling tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Settings',
      currentIndex: 2,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Notifications Section
            _buildMinimalCard(
              icon: Icons.notifications,
              title: 'Reminder Notifications',
              subtitle: 'Get notified when app is open',
              child: Column(
                children: [
                  SwitchListTile(
                    value: _notificationsEnabled,
                    onChanged: (value) async {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      // Save to settings
                      await SettingsService.setNotificationsEnabled(value);
                      // Toggle notifications in notification service
                      await NotificationService.toggleNotifications(value);
                    },
                    title: const Text(
                      'Enable Notifications',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    activeColor: Colors.orange,
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_notificationsEnabled) ...[
                    const Divider(color: Colors.white30),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.timer, color: Colors.orange, size: 20),
                              const SizedBox(width: 12),
                              const Text(
                                'Remind Before:',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Plus/Minus buttons for reminder time
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Minus button
                              GestureDetector(
                                onTap: () async {
                                  if (_reminderMinutes > 1) {
                                    setState(() {
                                      _reminderMinutes--;
                                    });
                                    // Save to settings
                                    await SettingsService.setDefaultReminderMinutes(_reminderMinutes);
                                    // Reschedule all tasks with new global reminder time
                                    await _rescheduleAllTasks();
                                  }
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: _reminderMinutes > 1 ? Colors.orange : Colors.grey,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Display current value
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${_reminderMinutes} minutes',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Plus button
                              GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    _reminderMinutes++;
                                  });
                                  // Save to settings
                                  await SettingsService.setDefaultReminderMinutes(_reminderMinutes);
                                  // Reschedule all tasks with new global reminder time
                                  await _rescheduleAllTasks();
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
                const SizedBox(height: 20),

                // Clear Data Section
            _buildMinimalCard(
              icon: Icons.delete_forever,
              title: 'Clear All Data',
              subtitle: 'Delete all tasks and reset app',
              child: ListTile(
                title: const Text(
                  'Clear All Data',
                  style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'This action cannot be undone',
                  style: TextStyle(color: Colors.redAccent),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 16),
                onTap: _showClearDataDialog,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 250),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.orange, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }




  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text(
          'Clear All Data',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete all tasks? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAllData();
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  Future<void> _clearAllData() async {
    try {
      // Get all todos and delete them one by one
      final allTodos = await _dbHelper.getAllTodos();
      for (final todo in allTodos) {
        await _dbHelper.deleteTodo(todo.id);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data cleared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}