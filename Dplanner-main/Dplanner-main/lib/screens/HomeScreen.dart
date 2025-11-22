import 'package:flutter/material.dart';
import 'package:dplanner/widgets/main_layout.dart';
import 'package:dplanner/widgets/todo_card.dart';
import 'package:dplanner/widgets/add_task_dialog.dart';
import 'package:dplanner/widgets/edit_task_dialog.dart';
import 'package:dplanner/models/todo.dart';
import 'package:dplanner/services/database_helper.dart';
import 'package:dplanner/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Todo> todos = [];
  final SimpleDatabaseHelper _dbHelper = SimpleDatabaseHelper();
  bool _isLoading = true;
  DateTime? _selectedDate;
  String _currentGradient = 'assets/Gradient1.jpg';
  bool _showHiddenTasks = false;

  @override
  void initState() {
    super.initState();
    _selectRandomGradient();
    _initializeDatabase();
  }


  void _selectRandomGradient() {
    final gradients = [
      'assets/Gradient1.jpg',
      'assets/Gradient2.jpg',
      'assets/Gradient3.jpg',
    ];
    final random = DateTime.now().millisecondsSinceEpoch % gradients.length;
    _currentGradient = gradients[random];
  }

  Future<void> _initializeDatabase() async {
    try {
      // Test database connection
      final isConnected = await _dbHelper.testConnection();
      if (isConnected) {
        print('Database connection successful');
        await _loadTodos();
      } else {
        print('Database connection failed');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Database connection failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Database initialization error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadTodos() async {
    print('_loadTodos called - refreshing task list');
    setState(() {
      _isLoading = true;
    });
    try {
      final todosList = await _dbHelper.getAllTodos();
      print('Loaded ${todosList.length} todos from database');
      setState(() {
        todos = todosList;
        _isLoading = false;
      });
      print('Home screen refreshed with new task list');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading todos: $e')),
        );
      }
    }
  }

  List<Todo> get _filteredTodos {
    // Filter tasks based on visibility preference
    final filteredTodos = todos.where((todo) {
      if (_showHiddenTasks) {
        return todo.isHidden; // Show only hidden tasks
      } else {
        return !todo.isHidden; // Show only visible tasks
      }
    }).toList();
    
    if (_selectedDate == null) {
      return filteredTodos;
    }
    return filteredTodos.where((todo) {
      if (todo.dueDate == null) return false;
      return todo.dueDate!.year == _selectedDate!.year &&
             todo.dueDate!.month == _selectedDate!.month &&
             todo.dueDate!.day == _selectedDate!.day;
    }).toList();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  Future<void> _toggleTodo(String id) async {
    try {
      // Get the current todo state
      final todo = await _dbHelper.getTodoById(id);
      if (todo == null) return;
      
      // Toggle completion
      await _dbHelper.toggleTodo(id);
      
      // If task is now completed, hide it; if uncompleted, show it
      if (todo.isCompleted) {
        // Task was completed, now uncompleted - show it
        await _dbHelper.showTodo(id);
      } else {
        // Task was uncompleted, now completed - hide it
        await _dbHelper.hideTodo(id);
      }
      
      await _loadTodos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating todo: $e')),
        );
      }
    }
  }

  Future<void> _deleteTodo(String id) async {
    try {
      await _dbHelper.deleteTodo(id);
      await NotificationService.cancelTaskReminder(id);
      await _loadTodos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting todo: $e')),
        );
      }
    }
  }

  void _editTodo(Todo todo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditTaskDialog(
        todo: todo,
        onTaskUpdated: () {
          _loadTodos();
        },
      ),
    );
  }


  int get _hiddenTasksCount {
    return todos.where((todo) => todo.isHidden).length;
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 
                   'July', 'August', 'September', 'October', 'November', 'December'];
    
    final weekday = weekdays[now.weekday - 1];
    final day = now.day;
    final month = months[now.month - 1];
    final year = now.year;
    
    return '$weekday, ${day}${_getOrdinalSuffix(day)} $month $year';
  }

  String _getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  int _getPendingTasksCount() {
    return todos.where((todo) => !todo.isCompleted).length;
  }

  Future<int> _getCompletionRate() async {
    try {
      if (_selectedDate != null) {
        // Calculate completion rate for filtered todos
        final filteredTodos = _filteredTodos;
        if (filteredTodos.isEmpty) return 0;
        final completedCount = filteredTodos.where((todo) => todo.isCompleted).length;
        return ((completedCount / filteredTodos.length) * 100).round();
      } else {
        final rate = await _dbHelper.getCompletionRate();
        return rate.round();
      }
    } catch (e) {
      return 0;
    }
  }

  void _showAddTaskDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTaskDialog(
        onTaskAdded: () {
          print('onTaskAdded callback received in HomeScreen');
          _loadTodos();
        },
      ),
    );
  }

  Future<void> _navigateToCalendar() async {
    final result = await Navigator.pushNamed(context, '/calendar');
    if (result is DateTime) {
      _onDateSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 0,
      onFloatingActionPressed: _showAddTaskDialog,
      floatingActionTooltip: 'Add new task',
      onCalendarPressed: _navigateToCalendar,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            height: 160,
            child: Stack(
              children: [
                Image.asset(
                  _currentGradient,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color.fromARGB(255, 13, 5, 66).withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getCurrentDate(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Welcome back!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You have ${_getPendingTasksCount()} tasks pending',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Battery-like progress indicator
                        FutureBuilder<int>(
                          future: _getCompletionRate(),
                          builder: (context, snapshot) {
                            final rate = snapshot.data ?? 0;
                            return Container(
                              width: 40,
                              height: 20,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    width: (40 * rate / 100),
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      color: rate > 50 
                                          ? Colors.green 
                                          : rate > 25 
                                              ? Colors.orange 
                                              : Colors.red,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        FutureBuilder<int>(
                          future: _getCompletionRate(),
                          builder: (context, snapshot) {
                            final rate = snapshot.data ?? 0;
                            return Text(
                              '$rate%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
              );
            },
          ),
        ],
      ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Tasks',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Date filter indicator
                  if (_selectedDate != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.orange, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Tasks for ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDate = null;
                              });
                            },
                            child: const Icon(Icons.close, color: Colors.orange, size: 16),
                          ),
          ],
        ),
      ),
                  
                  // Unhide button (only show if there are hidden tasks)
                  if (_hiddenTasksCount > 0 && !_showHiddenTasks)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.visibility_off,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$_hiddenTasksCount completed task${_hiddenTasksCount > 1 ? 's' : ''} hidden',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showHiddenTasks = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.orange.withOpacity(0.5)),
                              ),
                              child: const Text(
                                'Show',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Hide button (only show when viewing hidden tasks)
                  if (_showHiddenTasks)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
         child: Row(
           children: [
                          Icon(
                            Icons.visibility,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Showing $_hiddenTasksCount completed task${_hiddenTasksCount > 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showHiddenTasks = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.green.withOpacity(0.5)),
                              ),
                              child: const Text(
                                'Hide',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  Expanded(
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Colors.orange,
                            ),
                          )
                        : _filteredTodos.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 64,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _selectedDate == null ? 'No tasks yet!' : 'No tasks for this date!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap the + button to add your first task',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _filteredTodos.length,
                                itemBuilder: (context, index) {
                                  final todo = _filteredTodos[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: TodoCard(
                                      todo: todo,
                                      onToggleComplete: () => _toggleTodo(todo.id),
                                      onDelete: () => _deleteTodo(todo.id),
                                      onEdit: () => _editTodo(todo),
                                    ),
                 );
               },
             ),
             ),
           ],
         ),
       ),
          ),
        ],
     ),
    );
  }
}