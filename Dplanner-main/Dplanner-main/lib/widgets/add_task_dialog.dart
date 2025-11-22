import 'package:flutter/material.dart';
import 'package:dplanner/models/todo.dart';
import 'package:dplanner/services/database_helper.dart';
import 'package:dplanner/services/settings_service.dart';
import 'package:dplanner/services/notification_service.dart';
import 'package:dplanner/widgets/date_time_picker.dart';

class AddTaskDialog extends StatefulWidget {
  final Function() onTaskAdded;

  const AddTaskDialog({super.key, required this.onTaskAdded});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedPriority = 'medium';
  bool _hasReminder = false;
  int _reminderMinutes = 10;
  late TextEditingController _reminderController;
  final SimpleDatabaseHelper _dbHelper = SimpleDatabaseHelper();
  bool _isSaving = false; // Prevent multiple saves

  @override
  void initState() {
    super.initState();
    _initializeReminderSettings();
  }

  Future<void> _initializeReminderSettings() async {
    final defaultMinutes = await SettingsService.getDefaultReminderMinutes();
    setState(() {
      _reminderMinutes = defaultMinutes;
    });
    _reminderController = TextEditingController(
      text: defaultMinutes.toString(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _reminderController.dispose();
    super.dispose();
  }

  void _selectDate() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DateTimePicker(
        initialDate: _selectedDate,
        onDateSelected: (date) {
          setState(() {
            _selectedDate = date;
          });
        },
        onClose: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _saveTask() async {
    if (_isSaving) {
      print('_saveTask already in progress, ignoring duplicate call');
      return;
    }

    print('_saveTask called - attempt to create task');
    if (_formKey.currentState!.validate()) {
      print('Form validation passed - creating task');
      _isSaving = true;
      try {
        // Get the current reminder minutes (either from settings or user input)
        final reminderMinutes = _hasReminder
            ? _reminderMinutes
            : await SettingsService.getDefaultReminderMinutes();

        // Debug logging for reminder time assignment
        if (_hasReminder) {
          print(
            'TASK CREATION: Task "${_titleController.text.trim()}" has hasReminder=true',
          );
          print(
            'TASK CREATION: Using user-specified reminder time: $reminderMinutes minutes',
          );
        } else {
          print(
            'TASK CREATION: Task "${_titleController.text.trim()}" has hasReminder=false',
          );
          print(
            'TASK CREATION: Using global default reminder time: $reminderMinutes minutes',
          );
        }

        final todo = Todo(
          id: Todo.generateId(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          isCompleted: false,
          createdAt: DateTime.now(),
          dueDate: _selectedDate,
          priority: _selectedPriority,
          hasReminder: _hasReminder,
          reminderMinutes: reminderMinutes,
        );

        await _dbHelper.insertTodo(todo);

        // Schedule notification for all tasks (both specific and global default)
        if (todo.dueDate != null) {
          print(
            'TASK CREATION: Scheduling notification for task "${todo.title}"',
          );
          await NotificationService.scheduleTaskReminder(todo);
        } else {
          print('TASK CREATION: No due date set, skipping notification');
        }

        // Close the form first
        print('Closing form and refreshing home screen');
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Then refresh the home screen
        widget.onTaskAdded();
        print('onTaskAdded callback called');

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        _isSaving = false; // Reset flag on error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating task: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 53, 53, 53),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Create New Task',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Form content
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 0, 0, 0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title field
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: TextFormField(
                                  controller: _titleController,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Task Title',
                                    hintText: 'What needs to be done?',
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(16),
                                    labelStyle: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter a task title';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Description field
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: TextFormField(
                                  controller: _descriptionController,
                                  style: const TextStyle(fontSize: 16),
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    labelText: 'Description (Optional)',
                                    hintText:
                                        'Add more details about this task...',
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(16),
                                    labelStyle: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Due date field
                              InkWell(
                                onTap: _selectDate,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.grey[600],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _selectedDate == null
                                              ? 'Due date (Optional)'
                                              : 'Due: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} ${_selectedDate!.hour.toString().padLeft(2, '0')}:${_selectedDate!.minute.toString().padLeft(2, '0')}:${_selectedDate!.second.toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            color: _selectedDate == null
                                                ? Colors.grey[600]
                                                : const Color.fromARGB(
                                                    221,
                                                    255,
                                                    255,
                                                    255,
                                                  ),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      if (_selectedDate != null)
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _selectedDate = null;
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.clear,
                                            color: Colors.grey,
                                            size: 18,
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 32,
                                            minHeight: 32,
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Priority field
                              const Text(
                                'Priority Level',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _buildPriorityChip(
                                    'low',
                                    'Low',
                                    Colors.green,
                                    Icons.keyboard_arrow_down,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildPriorityChip(
                                    'medium',
                                    'Medium',
                                    Colors.orange,
                                    Icons.remove,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildPriorityChip(
                                    'high',
                                    'High',
                                    Colors.red,
                                    Icons.keyboard_arrow_up,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Reminder settings
                              const Text(
                                'Reminder Settings',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SwitchListTile(
                                value: _hasReminder,
                                onChanged: (value) {
                                  setState(() {
                                    _hasReminder = value;
                                  });
                                },
                                title: const Text(
                                  'Enable Reminder',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                activeColor: Colors.orange,
                                contentPadding: EdgeInsets.zero,
                              ),
                              if (_hasReminder) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.timer,
                                            color: Colors.orange,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Remind Before:',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Plus/Minus buttons for reminder time
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Minus button
                                          GestureDetector(
                                            onTap: () {
                                              if (_reminderMinutes > 1) {
                                                setState(() {
                                                  _reminderMinutes--;
                                                  _reminderController.text =
                                                      _reminderMinutes
                                                          .toString();
                                                });
                                              }
                                            },
                                            child: Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: _reminderMinutes > 1
                                                    ? Colors.orange
                                                    : Colors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(16),
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
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                255,
                                                0,
                                                0,
                                                0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${_reminderMinutes} minutes',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          // Plus button
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _reminderMinutes++;
                                                _reminderController.text =
                                                    _reminderMinutes.toString();
                                              });
                                            },
                                            child: Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: Colors.orange,
                                                borderRadius:
                                                    BorderRadius.circular(16),
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
                      ),

                      const SizedBox(height: 20),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.orange, Color(0xFFFF8A65)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveTask,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  _isSaving ? 'Creating...' : 'Create Task',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(
    String value,
    String label,
    Color color,
    IconData icon,
  ) {
    final isSelected = _selectedPriority == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPriority = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
